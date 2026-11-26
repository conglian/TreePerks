import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treeperks/TPBase/TPLaunchController.dart';
import 'package:treeperks/TPBase/TPTabBar.dart';
import 'package:treeperks/TPDialog/TPAccountDialogs.dart';
import 'package:treeperks/TPDialog/TPQuizDialogs.dart';
import 'package:treeperks/TPGuide/TPOnboardingFlow.dart';
import 'package:treeperks/TPGuide/TPOnboardingManager.dart';
import 'package:treeperks/TPMainVC/TPCashPage.dart';
import 'package:treeperks/TPMainVC/TPDicePage.dart';
import 'package:treeperks/TPMainVC/TPHomePage.dart';
import 'package:treeperks/TPMainVC/TPQuizPage.dart';
import 'package:treeperks/TPTool/TPImg.dart';
import 'package:treeperks/main.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('cloudx_flutter_sdk'),
      (call) async => switch (call.method) {
        'isInitialized' => false,
        'initialize' => {'success': true},
        _ => throw MissingPluginException(call.method),
      },
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('com.treeperks.growthrecord/topon'),
      (call) async {
        if (call.method != 'initialize') {
          throw MissingPluginException(call.method);
        }
        return null;
      },
    );
  });

  testWidgets('Closing the finished guide opens Quiz and keeps the live tabs', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      TPOnboardingManager.progressKey: 16,
    });
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const TPApp());
    await tester.pump();
    expect(find.byType(TPHomePage), findsNothing);

    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.text('Loading...'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('tp_launch_consent')));
    await tester.pump();
    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.text('Loading...'), findsOneWidget);

    await tester.pump(
      TPLaunchController.debugDuration - const Duration(milliseconds: 1),
    );
    expect(find.byType(TPHomePage), findsNothing);
    await tester.pump(const Duration(milliseconds: 17));
    await tester.pump(const Duration(milliseconds: 350));
    await _closeLastOnboardingStep(tester);
    await tester.tap(find.byKey(const ValueKey('tp-tab-tree')));
    await tester.pump();
    expect(find.byType(TPHomePage), findsOneWidget);
    expect(find.text('Withdraw'), findsOneWidget);

    for (final (tab, page) in [
      ('dice', TPDicePage),
      ('quiz', TPQuizPage),
      ('cash', TPCashPage),
    ]) {
      await tester.tap(find.byKey(ValueKey('tp-tab-$tab')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 650));
      expect(find.byKey(ValueKey('tp-page-$tab')), findsOneWidget);
      expect(find.byType(page), findsOneWidget);
      expect(find.byType(TPHomePage), findsNothing);
    }

    await tester.tap(find.byKey(const ValueKey('tp-tab-dice')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tp-dice-home')));
    await tester.pump();
    expect(find.byType(TPHomePage), findsOneWidget);

    await tester.tap(find.text('Withdraw'));
    await tester.pump();
    expect(find.byType(TPCashPage), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tp-tab-quiz')));
    await tester.pump();
    await tester.tap(find.text('Withdraw'));
    await tester.pump();
    expect(find.byType(TPCashPage), findsOneWidget);
  });

  testWidgets('The Settings button opens the shared dialog from each tab', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      TPOnboardingManager.progressKey: TPOnboardingManager.lastStep + 1,
    });
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: TPOnboardingFlow(repeatAfterCompletion: false)),
    );
    await tester.pump();

    final settings = find.byType(TPHomeSettings);
    final dialog = find.byType(TPAccountDialog);
    for (final tab in [TPTab.tree, TPTab.quiz, TPTab.cash]) {
      await tester.tap(find.byKey(ValueKey('tp-tab-${tab.name}')));
      await tester.pump();
      expect(settings.hitTestable(), findsOneWidget);
      await tester.tap(settings);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        tester.widget<TPAccountDialog>(dialog).kind,
        TPAccountDialogKind.settings,
      );
      expect(find.text('Sound Effects'), findsOneWidget);

      await tester.tap(find.byTooltip('Close'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(dialog, findsNothing);
      expect(find.byKey(ValueKey('tp-page-${tab.name}')), findsOneWidget);
    }
  });

  testWidgets('Each Quiz 06 state shows its own answer panel below the tip', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const states = [
      TPQuizDialogKind.withdrawalAccess,
      TPQuizDialogKind.appleStage,
      TPQuizDialogKind.goldenAppleStage,
    ];
    final panel = find.byKey(const ValueKey('tp-quiz-dialog-answer-panel'));
    final tip = find.byKey(const ValueKey('tp-quiz-dialog-tip'));
    for (final kind in states) {
      await tester.pumpWidget(
        MaterialApp(
          home: TPQuizDialog(kind: kind, onClose: () {}),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(TPQuizPage), findsNothing);
      expect(panel, findsOneWidget);
      expect(
        tester.getTopLeft(panel).dy,
        greaterThan(tester.getBottomRight(tip).dy),
      );
      expect(tester.getBottomRight(panel).dy, lessThan(568));
      expect(
        find.descendant(
          of: panel,
          matching: find.text('When can you withdraw\nyou cash?'),
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('A, Jupiter, Correct'), findsOneWidget);
      expect(find.bySemanticsLabel('B, Mars, Incorrect'), findsOneWidget);
    }
  });

  testWidgets('A cold start restores consent and the current onboarding step', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final start = find.text('Start');
    final consent = find.byKey(const ValueKey('tp_launch_consent'));

    await tester.pumpWidget(const TPApp());
    await tester.pump();
    expect(start, findsOneWidget);
    expect(consent, findsOneWidget);

    await tester.tap(consent);
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    SharedPreferences.resetStatic();

    await tester.pumpWidget(const TPApp());
    await tester.pump();
    expect(start, findsOneWidget);
    expect(tester.widget<Semantics>(consent).properties.checked, isFalse);
    await tester.tap(consent);
    await tester.pump();
    await tester.tap(start);
    await tester.pump();
    expect(find.text('Loading...'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    SharedPreferences.resetStatic();

    await tester.pumpWidget(const TPApp());
    expect(start, findsNothing);
    expect(consent, findsNothing);
    await tester.pump();
    expect(start, findsNothing);
    expect(consent, findsNothing);
    expect(find.text('Loading...'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0,
    );

    await tester.pump(
      TPLaunchController.debugDuration - const Duration(milliseconds: 1),
    );
    expect(find.byType(TPHomePage), findsNothing);
    await tester.pump(const Duration(milliseconds: 17));
    await tester.pump(const Duration(milliseconds: 350));
    await _showOnboardingStep(tester, 1);
    await tester.tap(find.byKey(const ValueKey('tp-onboarding-next-1')));
    await _showOnboardingStep(tester, 2);

    await tester.pumpWidget(const SizedBox.shrink());
    SharedPreferences.resetStatic();
    await tester.pumpWidget(const TPApp());
    await tester.pump();
    expect(start, findsNothing);
    expect(find.text('Loading...'), findsOneWidget);
    await tester.pump(
      TPLaunchController.debugDuration + const Duration(milliseconds: 16),
    );
    await tester.pump(const Duration(milliseconds: 350));
    await _showOnboardingStep(tester, 2);
  });

  testWidgets('All 16 onboarding steps lead to Quiz and restart on cold boot', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'tp_launch_start_accepted': true});
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const TPApp());
    await tester.pump();
    await tester.pump(
      TPLaunchController.debugDuration + const Duration(milliseconds: 16),
    );
    await tester.pump(const Duration(milliseconds: 350));

    State<TPMainTabPage>? liveTabs;
    for (var step = 1; step <= TPOnboardingManager.lastStep; step++) {
      await _showOnboardingStep(tester, step);
      expect(find.text('Skip', findRichText: true), findsNothing);
      if (step == 5) {
        expect(find.byType(TPHomePage), findsOneWidget);
        liveTabs = tester.state<State<TPMainTabPage>>(
          find.byType(TPMainTabPage),
        );
      }
      if (step == 7) {
        await tester.pump(const Duration(milliseconds: 1500));
        continue;
      }
      if (step == 9) {
        expect(find.byType(TPQuizPage), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('tp-quiz-answer-b')));
        await tester.pump();
        expect(
          find.byKey(const ValueKey('tp-onboarding-step-9')),
          findsOneWidget,
        );
      }
      if (step == 13) expect(find.byType(TPDicePage), findsOneWidget);
      final next = find.byKey(
        ValueKey(step == 9 ? 'tp-quiz-answer-a' : 'tp-onboarding-next-$step'),
      );
      expect(next.hitTestable(), findsOneWidget);
      await tester.tap(next);
    }
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey('tp-onboarding-overlay')), findsNothing);
    expect(find.byType(TPQuizPage), findsOneWidget);
    expect(tester.state(find.byType(TPMainTabPage)), same(liveTabs));

    await tester.pumpWidget(const SizedBox.shrink());
    SharedPreferences.resetStatic();
    await tester.pumpWidget(const TPApp());
    await tester.pump();
    await tester.pump(
      TPLaunchController.debugDuration + const Duration(milliseconds: 16),
    );
    await tester.pump(const Duration(milliseconds: 350));
    await _showOnboardingStep(tester, 1);
  });

  testWidgets(
    'The small-screen introduction fills the display and saves progress',
    (tester) async {
      const size = Size(320, 568);
      await tester.binding.setSurfaceSize(size);
      tester.view.devicePixelRatio = 1;
      const insets = FakeViewPadding(top: 24, bottom: 28);
      tester.view.padding = insets;
      tester.view.viewPadding = insets;
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
        tester.view.reset();
      });
      await tester.pumpWidget(const MaterialApp(home: TPOnboardingFlow()));
      await _showOnboardingStep(tester, 1);
      expect(
        tester.getRect(
          find.byKey(const ValueKey('tp-onboarding-intro-backdrop')),
        ),
        Offset.zero & size,
      );
      await tester.tap(find.byKey(const ValueKey('tp-onboarding-next-1')));
      await _showOnboardingStep(tester, 2);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getInt(TPOnboardingManager.progressKey), 2);
    },
  );

  testWidgets('The small-screen guide scrolls and taps the live Quiz page', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      TPOnboardingManager.progressKey: 9,
    });
    await tester.binding.setSurfaceSize(const Size(320, 568));
    tester.view.devicePixelRatio = 1;
    const insets = FakeViewPadding(top: 24, bottom: 28);
    tester.view.padding = insets;
    tester.view.viewPadding = insets;
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
      tester.view.reset();
    });
    await tester.pumpWidget(const MaterialApp(home: TPOnboardingFlow()));
    await _showOnboardingStep(tester, 9);

    await tester.dragFrom(const Offset(160, 360), const Offset(0, -170));
    await tester.pump(const Duration(milliseconds: 350));
    final answer = find.byKey(const ValueKey('tp-quiz-answer-a'));
    expect(answer.hitTestable(), findsOneWidget);
    await tester.tap(answer);
    await _showOnboardingStep(tester, 10);
    expect(find.byType(TPHomePage), findsOneWidget);
  });

  testWidgets('Step 07 bills rise from the cash artwork and fade in order', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      TPOnboardingManager.progressKey: 7,
    });
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: TPOnboardingFlow()));
    await tester.pump();

    final step = find.byKey(const ValueKey('tp-onboarding-step-7'));
    final flight = find.byKey(const ValueKey('tp-onboarding-reward-flight-7'));
    final cashArtwork = find.descendant(
      of: step,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is TPImg && widget.name.endsWith('/tp_home_cash.png'),
      ),
    );
    final firstBill = find.byKey(const ValueKey('tp-onboarding-reward-bill-0'));
    final secondBill = find.byKey(
      const ValueKey('tp-onboarding-reward-bill-1'),
    );

    await tester.pump(const Duration(milliseconds: 16));
    final start = tester.getCenter(firstBill);
    expect((start - tester.getCenter(cashArtwork)).distance, lessThan(2));
    await tester.pump(const Duration(milliseconds: 284));
    expect(tester.getCenter(firstBill).dy, lessThan(start.dy - 50));

    await tester.pump(const Duration(milliseconds: 570));
    expect(
      tester.getCenter(firstBill).dy,
      closeTo(tester.getTopLeft(flight).dy + 145, .1),
    );
    await tester.tapAt(const Offset(187, 563));
    await tester.pump(const Duration(milliseconds: 75));
    expect(firstBill, findsNothing);
    expect(secondBill, findsOneWidget);

    await tester.pump(const Duration(milliseconds: 554));
    expect(step, findsOneWidget);
    expect(find.byKey(const ValueKey('tp-onboarding-step-8')), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    await _showOnboardingStep(tester, 8);
  });

  testWidgets('Step 08 callouts slide in from the actual display edges', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      TPOnboardingManager.progressKey: 8,
    });
    const size = Size(320, 568);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: TPOnboardingFlow()));
    await tester.pump();
    final left = find.byKey(const ValueKey('tp-onboarding-callout-left-8'));
    final right = find.byKey(const ValueKey('tp-onboarding-callout-right-8'));

    expect(tester.getRect(left).right, lessThanOrEqualTo(.1));
    expect(tester.getRect(right).left, greaterThanOrEqualTo(size.width - .1));
    await tester.pump(const Duration(milliseconds: 610));
    expect(tester.getRect(left).left, lessThan(0));
    expect(tester.getRect(left).right, greaterThan(0));
    await tester.pump(const Duration(milliseconds: 360));
    expect(tester.getRect(left).left, closeTo(0, .1));
    expect(tester.getRect(right).left, closeTo(size.width, .1));
    await tester.pump(const Duration(milliseconds: 730));
    expect(tester.getRect(right).right, closeTo(size.width, .1));
  });

  testWidgets('Step 16 bulletins loop left and a tap opens the live Quiz', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      TPOnboardingManager.progressKey: 16,
    });
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: TPOnboardingFlow()));
    await _showOnboardingStep(tester, 16);
    await tester.pump(const Duration(milliseconds: 1800));

    List<double> offsets() => [
      for (var lane = 1; lane <= 3; lane++)
        tester
            .getTopLeft(
              find
                  .descendant(
                    of: find.byKey(
                      ValueKey('tp-onboarding-earnings-lane-$lane'),
                    ),
                    matching: find.byType(RichText),
                  )
                  .first,
            )
            .dx,
    ];

    final first = offsets();
    await tester.pump(const Duration(milliseconds: 200));
    final second = offsets();
    for (var lane = 0; lane < first.length; lane++) {
      expect(second[lane], lessThan(first[lane]));
    }

    await tester.tapAt(const Offset(187, 651));
    await tester.pump();
    expect(find.byKey(const ValueKey('tp-onboarding-overlay')), findsNothing);
    expect(find.byType(TPQuizPage), findsOneWidget);
  });

  testWidgets('The two step 05 bulletins scroll left with generated copy', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      TPOnboardingManager.progressKey: 5,
    });
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: TPOnboardingFlow()));
    await _showOnboardingStep(tester, 5);

    Finder tickerText(int lane) => find
        .descendant(
          of: find.byKey(ValueKey('tp-onboarding-bulletin-$lane')),
          matching: find.byType(RichText),
        )
        .first;

    double tickerX(int lane) => tester.getTopLeft(tickerText(lane)).dx;

    void checkCopy(int lane) {
      final text = tester.widget<RichText>(tickerText(lane)).text.toPlainText();
      expect(text, matches(RegExp(r'Player_[a-zA-Z0-9]+')));
      expect(text, matches(RegExp(r'\$(100|120|150|200)!?$')));
    }

    checkCopy(1);
    checkCopy(2);
    final first = tickerX(1);
    final second = tickerX(2);
    await tester.pump(const Duration(milliseconds: 250));
    expect(tickerX(1), lessThan(first));
    expect(tickerX(2), lessThan(second));

    await tester.pump(const Duration(seconds: 25));
    final laterFirst = tickerX(1);
    final laterSecond = tickerX(2);
    await tester.pump(const Duration(milliseconds: 250));
    expect(tickerX(1), isNot(closeTo(laterFirst, .1)));
    expect(tickerX(2), isNot(closeTo(laterSecond, .1)));
    checkCopy(1);
    checkCopy(2);
  });

  testWidgets('Comparison cards appear one at a time with a visible pause', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      TPOnboardingManager.progressKey: 2,
    });
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: TPOnboardingFlow()));
    await tester.pump();

    double opacity(String side) => tester
        .widget<Opacity>(find.byKey(ValueKey('tp-onboarding-comparison-$side')))
        .opacity;

    expect(opacity('left'), 0);
    expect(opacity('right'), 0);
    await tester.pump(const Duration(milliseconds: 700));
    expect(opacity('left'), inExclusiveRange(0, 1));
    expect(opacity('right'), 0);
    await tester.pump(const Duration(milliseconds: 500));
    expect(opacity('left'), 1);
    expect(opacity('right'), 0);
    await tester.pump(const Duration(milliseconds: 450));
    expect(opacity('right'), inExclusiveRange(0, 1));
    await tester.pump(const Duration(milliseconds: 500));
    expect(opacity('right'), 1);
  });

  testWidgets('Logo rows scroll together and dialogues enter independently', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: TPOnboardingFlow()));
    await tester.pump();

    double dialogueOpacity(int index) => tester
        .widget<Opacity>(find.byKey(ValueKey('tp-onboarding-dialogue-$index')))
        .opacity;

    for (var row = 1; row <= 3; row++) {
      final logoRow = find.byKey(ValueKey('tp-onboarding-brand-row-$row'));
      expect(logoRow, findsOneWidget);
      expect(
        find.ancestor(of: logoRow, matching: find.byType(Opacity)),
        findsNothing,
      );
    }
    expect(dialogueOpacity(1), 0);
    expect(dialogueOpacity(2), 0);
    await tester.pump(const Duration(milliseconds: 360));
    expect(dialogueOpacity(1), inExclusiveRange(0, 1));
    expect(dialogueOpacity(2), 0);
    await tester.pump(const Duration(milliseconds: 390));
    expect(dialogueOpacity(1), 1);
    expect(dialogueOpacity(2), 0);
    await tester.pump(const Duration(milliseconds: 340));
    expect(dialogueOpacity(2), inExclusiveRange(0, 1));
    await tester.pump(const Duration(milliseconds: 1310));
    expect(dialogueOpacity(2), 1);

    List<double> rowOffsets() => [
      for (var row = 1; row <= 3; row++)
        tester
            .getTopLeft(
              find
                  .descendant(
                    of: find.byKey(ValueKey('tp-onboarding-brand-row-$row')),
                    matching: find.byType(TPImg),
                  )
                  .first,
            )
            .dx,
    ];

    final first = rowOffsets();
    await tester.pump(const Duration(milliseconds: 250));
    final second = rowOffsets();
    expect(second[0], lessThan(first[0]));
    expect(second[1], greaterThan(first[1]));
    expect(second[2], lessThan(first[2]));

    await tester.pump(const Duration(seconds: 30));
    final later = rowOffsets();
    await tester.pump(const Duration(milliseconds: 250));
    final stillMoving = rowOffsets();
    for (var row = 0; row < later.length; row++) {
      expect(stillMoving[row], isNot(closeTo(later[row], 0.1)));
    }
  });

  testWidgets('Home bubbles reveal in order and breathe after the reveal', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_bubbleTestApp());
    await tester.pump();

    for (var order = 0; order < 6; order++) {
      expect(_bubbleOpacity(tester, order), 0);
    }

    for (var current = 0; current < 6; current++) {
      await tester.pump(Duration(milliseconds: current == 0 ? 160 : 320));
      for (var order = 0; order < 6; order++) {
        expect(_bubbleOpacity(tester, order), order < current ? 1 : 0);
      }

      await tester.pump(const Duration(milliseconds: 40));
      expect(_bubbleOpacity(tester, current), inExclusiveRange(0, 1));

      if (current == 2) {
        await tester.tap(find.byKey(const ValueKey('tp-tab-dice')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await tester.tap(find.byKey(const ValueKey('tp-tab-tree')));
        await tester.pump();
        await tester.pump();
        expect(_bubbleOpacity(tester, current), isPositive);
        expect(_bubbleOpacity(tester, current + 1), 0);
      }
    }

    await tester.pump(const Duration(milliseconds: 340));
    final widths = List.generate(6, (order) {
      expect(_bubbleOpacity(tester, order), 1);
      return tester.getRect(_bubbleArt(order)).width;
    });

    await tester.pump(const Duration(milliseconds: 350));
    for (var order = 0; order < 6; order++) {
      expect(
        tester.getRect(_bubbleArt(order)).width,
        isNot(closeTo(widths[order], 0.05)),
      );
    }
  });

  testWidgets('Home progress fills animate and move the golden bird', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_bubbleTestApp());
    await tester.pump();

    final balanceFill = find.byKey(const ValueKey('tp-home-balance-fill'));
    final rewardFill = find.byKey(const ValueKey('tp-home-reward-fill'));
    final bird = find.byKey(const ValueKey('tp-home-reward-bird'));
    final birdStart = tester.getTopLeft(bird).dx;
    expect(tester.getSize(balanceFill).width, 0);
    expect(tester.getSize(rewardFill).width, 0);
    expect(find.text('0%'), findsWidgets);

    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.getSize(balanceFill).width, allOf(isPositive, lessThan(294)));
    expect(tester.getSize(rewardFill).width, allOf(isPositive, lessThan(124)));
    final birdMiddle = tester.getTopLeft(bird).dx;
    expect(birdMiddle, greaterThan(birdStart));

    await tester.pump(const Duration(milliseconds: 650));
    expect(tester.getSize(balanceFill).width, closeTo(294, 0.1));
    expect(tester.getSize(rewardFill).width, closeTo(124, 0.1));
    expect(tester.getTopLeft(bird).dx, greaterThan(birdMiddle));
    expect(find.text('92%'), findsWidgets);
  });

  testWidgets('Reduced motion shows all six home bubbles immediately', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(_bubbleTestApp());

    expect(
      tester.getSize(find.byKey(const ValueKey('tp-home-balance-fill'))).width,
      closeTo(294, 0.1),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('tp-home-reward-fill'))).width,
      closeTo(124, 0.1),
    );

    final widths = List.generate(6, (order) {
      expect(_bubbleOpacity(tester, order), 1);
      return tester.getRect(_bubbleArt(order)).width;
    });

    await tester.pump(const Duration(milliseconds: 1100));
    for (var order = 0; order < 6; order++) {
      expect(tester.getRect(_bubbleArt(order)).width, widths[order]);
    }
  });

  for (final size in [
    const Size(320, 568),
    const Size(430, 932),
    const Size(800, 1024),
  ]) {
    testWidgets(
      'Launch and home controls fit at ${size.width}×${size.height}',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          TPOnboardingManager.progressKey: 16,
        });
        await tester.binding.setSurfaceSize(size);
        tester.view.devicePixelRatio = 1;
        const systemInsets = FakeViewPadding(top: 24, bottom: 28);
        tester.view.padding = systemInsets;
        tester.view.viewPadding = systemInsets;
        addTearDown(() async {
          await tester.binding.setSurfaceSize(null);
          tester.view.resetDevicePixelRatio();
          tester.view.resetPadding();
          tester.view.resetViewPadding();
        });

        await tester.pumpWidget(const TPApp());
        await tester.pump();
        final consent = find.byKey(const ValueKey('tp_launch_consent'));
        expect(consent.hitTestable(), findsOneWidget);
        expect(tester.getSize(consent).height, greaterThanOrEqualTo(48));
        await tester.tap(consent);
        await tester.pump();
        await tester.tap(find.text('Start').hitTestable());
        await tester.pump();
        expect(find.text('Loading...'), findsOneWidget);
        await tester.pump(
          TPLaunchController.debugDuration + const Duration(milliseconds: 16),
        );
        await tester.pump(const Duration(milliseconds: 350));
        await _closeLastOnboardingStep(tester);
        await tester.tap(find.byKey(const ValueKey('tp-tab-tree')));
        await tester.pump();
        expect(find.byType(TPHomePage), findsOneWidget);

        final lastRank = find.text('6');
        await tester.ensureVisible(lastRank);
        await tester.pump();
        expect(lastRank.hitTestable(), findsOneWidget);

        for (final (tab, actionKey) in [
          ('dice', 'tp-dice-throw'),
          ('quiz', 'tp-quiz-answer-b'),
          ('cash', 'tp-cash-withdraw'),
        ]) {
          final tabButton = find.byKey(ValueKey('tp-tab-$tab'));
          final bounds = tester.getRect(tabButton);
          expect(bounds.width, greaterThanOrEqualTo(48));
          expect(bounds.height, greaterThanOrEqualTo(48));
          expect(bounds.bottom, lessThanOrEqualTo(size.height - 28));
          await tester.tap(tabButton.hitTestable());
          await tester.pump();
          expect(find.byKey(ValueKey('tp-page-$tab')), findsOneWidget);

          final action = find.byKey(ValueKey(actionKey));
          await tester.ensureVisible(action);
          await tester.pump();
          expect(action.hitTestable(), findsOneWidget);
          expect(tester.getRect(action).bottom, lessThanOrEqualTo(bounds.top));
        }
      },
    );
  }
}

Future<void> _showOnboardingStep(WidgetTester tester, int step) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 370));
  expect(find.byKey(ValueKey('tp-onboarding-step-$step')), findsOneWidget);
}

Future<void> _closeLastOnboardingStep(WidgetTester tester) async {
  await _showOnboardingStep(tester, 16);
  final close = find.byKey(const ValueKey('tp-onboarding-close-16'));
  expect(close.hitTestable(), findsOneWidget);
  await tester.tap(close);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  expect(find.byKey(const ValueKey('tp-onboarding-overlay')), findsNothing);
  expect(find.byType(TPQuizPage), findsOneWidget);
}

Widget _bubbleTestApp() =>
    MaterialApp(home: TPMainTabPage(homeBuilder: (_) => const TPHomePage()));

Finder _bubbleArt(int order) => find.descendant(
  of: find.byKey(ValueKey('tp-home-bubble-$order')),
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is TPImg && widget.name.endsWith('/tp_home_button_back.png'),
  ),
);

double _bubbleOpacity(WidgetTester tester, int order) {
  final opacity = find.ancestor(
    of: _bubbleArt(order),
    matching: find.byType(Opacity),
  );
  return opacity.evaluate().isEmpty
      ? 1
      : tester.widget<Opacity>(opacity.first).opacity;
}
