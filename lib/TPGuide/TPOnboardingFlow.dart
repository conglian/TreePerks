import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../TPBase/TPTabBar.dart';
import '../TPMainVC/TPCashPage.dart';
import '../TPMainVC/TPDicePage.dart';
import '../TPMainVC/TPHomePage.dart';
import '../TPMainVC/TPQuizPage.dart';
import '../TPTool/TPImg.dart';
import 'TPOnboardingManager.dart';
import 'TPOnboardingSteps01To05.dart';
import 'TPOnboardingSteps06To10.dart';
import 'TPOnboardingSteps11To16.dart';
import 'TPOnboardingWidgets.dart';

class TPOnboardingFlow extends StatefulWidget {
  const TPOnboardingFlow({super.key, this.repeatAfterCompletion = true});

  final bool repeatAfterCompletion;

  @override
  State<TPOnboardingFlow> createState() => _TPOnboardingFlowState();
}

class _TPOnboardingFlowState extends State<TPOnboardingFlow> {
  late final _manager = TPOnboardingManager(
    repeatAfterCompletion: widget.repeatAfterCompletion,
  );
  TPTab _completedTab = TPTab.tree;

  @override
  void initState() {
    super.initState();
    unawaited(_manager.restore());
  }

  Future<void> _advance(int step) async {
    final moved = await _manager.advance(step);
    if (mounted && moved && _manager.isCompleted) {
      setState(() => _completedTab = TPTab.quiz);
    }
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _manager,
      builder: (context, child) {
        final step = _manager.currentStep;
        final isGuide = step != null && step >= 5;
        return Stack(
          fit: StackFit.expand,
          children: [
            if (isGuide || _manager.isCompleted) _buildMainTabs(step),
            if (step != null && isGuide)
              TPOnboardingGuideMask(
                step: step,
                onNext: () => unawaited(_advance(step)),
              ),
            if (!_manager.isCompleted)
              _buildOverlay(step, isGuide: isGuide, reduceMotion: reduceMotion),
          ],
        );
      },
    );
  }

  Widget _buildMainTabs(int? step) => TPMainTabPage(
    key: const ValueKey('tp-onboarding-live-app'),
    requestedTab: switch (step) {
      9 || 12 => TPTab.quiz,
      13 || 14 || 15 => TPTab.dice,
      null => _completedTab,
      _ => TPTab.tree,
    },
    homeBuilder: (selectTab) => TPHomePage(
      onDice: () => selectTab(TPTab.dice),
      onQuiz: () => selectTab(TPTab.quiz),
      onCash: () => selectTab(TPTab.cash),
      showTree: step != 10 && step != 11,
    ),
    pageBuilders: {
      TPTab.dice: (selectTab) => TPDicePage(
        onHome: () => selectTab(TPTab.tree),
        showGuideDie: step == 13,
      ),
      TPTab.quiz: (selectTab) => TPQuizPage(
        onCash: () => selectTab(TPTab.cash),
        onGuideAnswer: step == 9
            ? (answer) {
                if (answer == 0) unawaited(_advance(9));
              }
            : null,
      ),
      TPTab.cash: (_) => const TPCashPage(),
    },
    pageBackdrops: const {
      TPTab.dice: TPDiceBackdrop(),
      TPTab.quiz: TPQuizBackdrop(),
    },
  );

  Widget _buildOverlay(
    int? step, {
    required bool isGuide,
    required bool reduceMotion,
  }) {
    final brightness = isGuide ? Brightness.light : Brightness.dark;
    const introBackground = Color(0xFFE7F0FB);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: brightness,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Material(
        type: isGuide ? MaterialType.transparency : MaterialType.canvas,
        color: isGuide ? null : introBackground,
        child: TPOnboardingStage(
          key: const ValueKey('tp-onboarding-overlay'),
          backgroundColor: isGuide ? Colors.transparent : introBackground,
          edgeOverlay: switch (step) {
            8 => const TPOnboardingRewardCallouts(),
            16 => const TPOnboardingEarningsBulletins(),
            _ => null,
          },
          backdrop: step != null && !isGuide
              ? const TPImg(
                  key: ValueKey('tp-onboarding-intro-backdrop'),
                  name: TPOnboardingSteps01To05.backdropAsset,
                  fit: BoxFit.fill,
                )
              : null,
          child: AnimatedSwitcher(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (current, previous) => Stack(
              fit: StackFit.expand,
              children: [
                for (final page in previous)
                  IgnorePointer(child: ExcludeSemantics(child: page)),
                ?current,
              ],
            ),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0, .012), end: Offset.zero),
                ),
                child: child,
              ),
            ),
            child: step == null
                ? const SizedBox.expand()
                : KeyedSubtree(
                    key: ValueKey('tp-onboarding-step-$step'),
                    child: _buildStep(step),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int step) {
    void next() => unawaited(_advance(step));

    if (step <= 5) {
      return TPOnboardingSteps01To05(step: step, onNext: next);
    }
    if (step <= 10) {
      return TPOnboardingSteps06To10(step: step, onNext: next);
    }
    return TPOnboardingSteps11To16(step: step, onNext: next);
  }
}
