import 'package:flutter/material.dart';

import '../TPTool/TPFonts.dart';
import '../TPTool/TPImg.dart';
import '../TPTool/TPResponsive.dart';
import '../TPTool/TPText.dart';
import 'TPDialogWidgets.dart';

const _tpQuizDialogArt = 'assets/image/dialog/quiz';
const _tpEventDialogArt = 'assets/image/dialog/event';
const _tpQuizCardArt = 'assets/image/quiz';

/// 第三排答题弹层的各个展示状态。
enum TPQuizDialogKind {
  /// 03 答题收益、待入账奖励和提现进度。
  rewards,

  /// 04 在答题板内提示继续答题。
  continueQuiz,

  /// 05 提示骰子可加快提现进度。
  bonusTip,

  /// 06 提示继续答题可解锁提现流程。
  withdrawalAccess,

  /// 06-1 普通苹果收集阶段。
  appleStage,

  /// 06-2 金苹果收集阶段。
  goldenAppleStage,
}

/// 独立答题弹层，负责展示奖励和传递操作。
class TPQuizDialog extends StatelessWidget {
  const TPQuizDialog({
    super.key,
    required this.kind,
    required this.onClose,
    this.onNext,
    this.onClaim,
  });

  final TPQuizDialogKind kind;
  final VoidCallback onClose;
  final ValueChanged<TPQuizDialogKind>? onNext;
  final VoidCallback? onClaim;

  VoidCallback _next(TPQuizDialogKind next) {
    final callback = onNext;
    return callback == null ? onClose : () => callback(next);
  }

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      key: ValueKey(kind),
      children: switch (kind) {
        TPQuizDialogKind.rewards => [
          Positioned(
            left: 19,
            top: 202,
            width: 338,
            height: 409,
            child: TPDialogMotion(
              effect: TPDialogEffect.celebration,
              child: _TPQuizRewards(
                onClaim: onClaim ?? _next(TPQuizDialogKind.continueQuiz),
              ),
            ),
          ),
        ],
        TPQuizDialogKind.continueQuiz || TPQuizDialogKind.bonusTip => [
          Positioned(
            left: 33,
            top: 369,
            width: 309,
            height: 294,
            child: _TPQuizContinuePanel(
              highlighted: kind == TPQuizDialogKind.continueQuiz,
              onContinue: kind == TPQuizDialogKind.continueQuiz
                  ? _next(TPQuizDialogKind.bonusTip)
                  : _next(TPQuizDialogKind.withdrawalAccess),
            ),
          ),
          if (kind == TPQuizDialogKind.bonusTip)
            Positioned(
              left: 26,
              top: 265,
              width: 323,
              height: 121,
              child: TPDialogMotion(
                effect: TPDialogEffect.rise,
                child: _TPQuizTip(
                  arrowAtTop: true,
                  title: 'More ways to earn money Just for you.',
                  body: const TextSpan(
                    text:
                        'Use your 🎲 to unlock extra progress and reach your cashout faster.',
                  ),
                  onPressed: _next(TPQuizDialogKind.withdrawalAccess),
                ),
              ),
            ),
        ],
        TPQuizDialogKind.withdrawalAccess ||
        TPQuizDialogKind.appleStage ||
        TPQuizDialogKind.goldenAppleStage => _withdrawalStage(),
      },
    );
  }

  List<Widget> _withdrawalStage() {
    final isAccess = kind == TPQuizDialogKind.withdrawalAccess;
    final isGold = kind == TPQuizDialogKind.goldenAppleStage;
    final title = switch (kind) {
      TPQuizDialogKind.withdrawalAccess => 'Unlock Withdrawal Access',
      TPQuizDialogKind.appleStage => 'Apple Stage Unlocked!',
      _ => 'Go for Gold!',
    };
    final body = switch (kind) {
      TPQuizDialogKind.withdrawalAccess => const TextSpan(
        text:
            "Advertisers need a quick check to confirm you're real.\n\nPass 3 easy questions and move closer to cashing out!",
      ),
      TPQuizDialogKind.appleStage => const TextSpan(
        text: 'Answer quizzes to collect ',
        children: [
          TextSpan(
            text: '10',
            style: TextStyle(
              color: Color(0xFF0BFFF3),
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(text: ' apples and reach your '),
          TextSpan(
            text: r'$100',
            style: TextStyle(
              color: Color(0xFF95FF00),
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(text: ' cash-out goal.'),
        ],
      ),
      _ => const TextSpan(
        text: 'Answer quizzes to collect ',
        children: [
          TextSpan(
            text: '5',
            style: TextStyle(
              color: Color(0xFF0BFFF3),
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(text: ' golden apples for priority payout.'),
        ],
      ),
    };
    return [
      const Positioned(
        left: 10,
        top: 263,
        width: 356,
        height: 458,
        child: TPDialogMotion(
          effect: TPDialogEffect.rise,
          delay: Duration(milliseconds: 90),
          child: _TPQuizDialogAnswerPanel(),
        ),
      ),
      Positioned(
        left: 27,
        top: isAccess ? 103 : 133,
        width: 323,
        height: isAccess ? 153 : 123,
        child: TPDialogMotion(
          effect: TPDialogEffect.rise,
          child: _TPQuizTip(
            title: title,
            body: body,
            centeredTitle: isAccess,
            onPressed: onClose,
          ),
        ),
      ),
      if (!isAccess)
        Positioned(
          left: isGold ? 258 : 274,
          top: isGold ? 85 : 100,
          width: isGold ? 94 : 62,
          height: isGold ? 96 : 64,
          child: IgnorePointer(
            child: TPDialogMotion(
              effect: TPDialogEffect.celebration,
              delay: const Duration(milliseconds: 150),
              child: TPImg(
                name:
                    '$_tpEventDialogArt/${isGold ? 'gold_apple' : 'red_apple'}.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
    ];
  }
}

/// 答题 06 的展示卡，三个弹窗状态共用题目和已揭晓的答案。
class _TPQuizDialogAnswerPanel extends StatelessWidget {
  const _TPQuizDialogAnswerPanel();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      key: ValueKey('tp-quiz-dialog-answer-panel'),
      fit: StackFit.expand,
      children: [
        TPImg(name: '$_tpQuizCardArt/tp_quiz_board.png', fit: BoxFit.contain),
        Positioned(
          left: 100,
          right: 101,
          top: 45.5,
          height: 42,
          child: TPFitText(
            span: TextSpan(
              text: 'Qiuz',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: Color(0xFF7E3003),
                shadows: [
                  Shadow(
                    color: Color(0xFFFFF7CD),
                    offset: Offset(0, 1),
                    blurRadius: 1.2,
                  ),
                ],
              ),
            ),
            align: TextAlign.center,
          ),
        ),
        Positioned(
          left: 27,
          top: 115,
          width: 302,
          height: 151,
          child: TPImg(
            name: '$_tpQuizCardArt/tp_quiz_question.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          left: 42,
          top: 126,
          width: 278,
          height: 114,
          child: TPImg(
            name: '$_tpQuizDialogArt/tp_quiz_dialog_question_glow.png',
          ),
        ),
        Positioned(
          left: 47,
          right: 52,
          top: 161,
          height: 46,
          child: TPText(
            text: 'When can you withdraw\nyou cash?',
            size: 20,
            color: Colors.white,
            weight: FontWeight.w500,
            maxLines: 2,
          ),
        ),
        Positioned(
          left: 31,
          top: 282,
          width: 289,
          height: 50,
          child: _TPQuizDialogAnswer(
            letter: 'A',
            answer: 'Jupiter',
            correct: true,
          ),
        ),
        Positioned(
          left: 31,
          top: 342,
          width: 289,
          height: 50,
          child: _TPQuizDialogAnswer(
            letter: 'B',
            answer: 'Mars',
            correct: false,
          ),
        ),
      ],
    );
  }
}

class _TPQuizDialogAnswer extends StatelessWidget {
  const _TPQuizDialogAnswer({
    required this.letter,
    required this.answer,
    required this.correct,
  });

  final String letter;
  final String answer;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$letter, $answer, ${correct ? 'Correct' : 'Incorrect'}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: correct ? const Color(0xFFE6FCE0) : const Color(0xFFFCE0E0),
          border: Border.all(
            color: correct ? const Color(0xFF31ED28) : const Color(0xFFED2828),
            width: 2,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 10,
              width: 32,
              top: 0,
              bottom: 0,
              child: TPText(
                text: letter,
                size: 20,
                color: correct
                    ? const Color(0xFF09C500)
                    : const Color(0xFFC50000),
                weight: FontWeight.w700,
              ),
            ),
            Positioned(
              left: 46,
              top: 11,
              width: 1.5,
              height: 28,
              child: ColoredBox(
                color: correct
                    ? const Color(0xFF74B271)
                    : const Color(0xFFB27171),
              ),
            ),
            Positioned.fill(
              left: 54,
              right: 53,
              child: TPText(
                text: answer,
                size: 20,
                color: correct
                    ? const Color(0xFF094707)
                    : const Color(0xFF05081D),
                weight: FontWeight.w500,
              ),
            ),
            Positioned(
              right: 7,
              top: correct ? 7 : 8,
              width: 34,
              height: 34,
              child: TPDialogMotion(
                key: ValueKey('tp-quiz-answer-badge-${letter.toLowerCase()}'),
                effect: TPDialogEffect.pop,
                delay: Duration(milliseconds: correct ? 540 : 720),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    TPImg(
                      name:
                          '$_tpQuizDialogArt/tp_quiz_dialog_answer_${correct ? 'correct' : 'incorrect'}.png',
                    ),
                    if (!correct)
                      const Positioned(
                        left: 8,
                        top: 8,
                        width: 18.58,
                        height: 18.38,
                        child: TPImg(
                          name:
                              '$_tpQuizDialogArt/tp_quiz_dialog_answer_cross.png',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TPQuizRewards extends StatelessWidget {
  const _TPQuizRewards({required this.onClaim});

  final VoidCallback onClaim;

  static const _green = Color(0xFF1BAD14);
  static const _brown = Color(0xFF5A1700);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const TPImg(name: '$_tpQuizDialogArt/reward_frame.png'),
        const Positioned(
          left: 55,
          right: 55,
          top: 49,
          height: 31,
          child: _TPQuizHeading(text: 'Quiz Rewards', size: 22, color: _brown),
        ),
        const Positioned(
          left: 20,
          right: 20,
          top: 103,
          child: TPText(
            text: r'$ 849.99',
            size: 48,
            color: _green,
            weight: FontWeight.w900,
          ),
        ),
        Positioned(
          left: 19,
          right: 19,
          top: 164,
          height: 30,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  const TextSpan(
                    text: 'Just ',
                    children: [
                      TextSpan(
                        text: r'$Xx',
                        style: TextStyle(color: _green),
                      ),
                      TextSpan(text: ' Away From '),
                    ],
                  ),
                  style: _tpQuizTextStyle(15, const Color(0xFF16090A)),
                ),
                const TPImg(
                  name: 'assets/image/cash/tp_cash_paypal_idle.png',
                  width: 63,
                  height: 17,
                  fit: BoxFit.contain,
                ),
                const TPText(
                  text: ' Withdrawal!',
                  size: 15,
                  color: Color(0xFF16090A),
                  weight: FontWeight.normal,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 28,
          right: 25,
          top: 198,
          height: 64,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D7),
              border: Border.all(color: const Color(0xFFE9C37E)),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Row(
              children: [
                Expanded(child: _TPQuizBonusColumn(label: 'Earned Bonus')),
                SizedBox(
                  width: 1,
                  height: 40,
                  child: ColoredBox(color: Color(0xFFD99E44)),
                ),
                Expanded(child: _TPQuizBonusColumn(label: 'Pending Bonus')),
              ],
            ),
          ),
        ),
        Positioned(
          left: 26,
          right: 26,
          top: 273,
          height: 29,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Color(0xFFD2C9AE)),
                const _TPQuizRewardsProgressFill(),
                const Center(
                  child: TPText(
                    text: r'Current Withdrawal Progress: $Xx / $Xx',
                    size: 12,
                    color: Colors.white,
                    weight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 26,
          right: 23,
          top: 321,
          height: 59,
          child: Semantics(
            button: true,
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFFFDC),
                      Color(0xFFFFCA36),
                      Color(0xFFFFB400),
                      Color(0xFFFFF39A),
                    ],
                    stops: [0, .43, .78, 1],
                  ),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: const Color(0xFFD67403), width: 2),
                ),
                child: InkWell(
                  key: const ValueKey('tp-quiz-dialog-claim'),
                  borderRadius: BorderRadius.circular(34),
                  onTap: onClaim,
                  child: const Center(
                    child: TPText(
                      text: r'Tap & Get Cash $Xx',
                      size: 22,
                      color: _brown,
                      weight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 先展示卡片，随后填充画板既有的进度。
class _TPQuizRewardsProgressFill extends StatelessWidget {
  const _TPQuizRewardsProgressFill();

  static const _target = .74;

  @override
  Widget build(BuildContext context) {
    final paint = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF3991FD),
        border: Border.all(color: const Color(0xFF0368F0)),
        borderRadius: BorderRadius.circular(24),
      ),
    );
    Widget fill(double value, Widget? child) => FractionallySizedBox(
      key: const ValueKey('tp-quiz-rewards-progress-fill'),
      widthFactor: value,
      heightFactor: .87,
      child: child,
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: MediaQuery.disableAnimationsOf(context)
          ? fill(_target, paint)
          : TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _target),
              duration: const Duration(milliseconds: 1050),
              curve: const Interval(350 / 1050, 1, curve: Curves.easeOutCubic),
              child: paint,
              builder: (context, value, child) => fill(value, child),
            ),
    );
  }
}

class _TPQuizBonusColumn extends StatelessWidget {
  const _TPQuizBonusColumn({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TPText(
          text: label,
          size: 15,
          color: Colors.black,
          weight: FontWeight.normal,
        ),
        const SizedBox(height: 3),
        const TPText(
          text: r'$Xx.Xx',
          size: 15,
          color: _TPQuizRewards._green,
          weight: FontWeight.bold,
        ),
      ],
    );
  }
}

class _TPQuizContinuePanel extends StatelessWidget {
  const _TPQuizContinuePanel({
    required this.highlighted,
    required this.onContinue,
  });

  final bool highlighted;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final panel = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD9000000),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (highlighted)
            const Positioned(
              left: 16,
              right: 16,
              top: 10,
              height: 40,
              child: _TPQuizHeading(
                text: 'Continue !',
                size: 30,
                color: Color(0xFFF6FF00),
              ),
            ),
          Positioned(
            left: 67,
            top: 55,
            width: 176,
            height: 176,
            child: TPDialogMotion(
              effect: highlighted
                  ? TPDialogEffect.celebration
                  : TPDialogEffect.fade,
              child: Opacity(
                opacity: highlighted ? 1 : .25,
                child: const TPImg(
                  name: '$_tpQuizDialogArt/continue_mascot.png',
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 29,
            child: TPText(
              text: 'Answering & Earning',
              size: 20,
              color: highlighted ? Colors.white : const Color(0x8AFFFFFF),
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
    return Semantics(
      button: true,
      label: 'Continue quiz',
      child: GestureDetector(
        key: const ValueKey('tp-quiz-dialog-continue'),
        onTap: onContinue,
        child: panel,
      ),
    );
  }
}

class _TPQuizTip extends StatelessWidget {
  const _TPQuizTip({
    required this.title,
    required this.body,
    required this.onPressed,
    this.arrowAtTop = false,
    this.centeredTitle = false,
  });

  final String title;
  final TextSpan body;
  final VoidCallback onPressed;
  final bool arrowAtTop;
  final bool centeredTitle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        key: const ValueKey('tp-quiz-dialog-tip'),
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: CustomPaint(
          painter: _TPQuizTipBackground(arrowAtTop),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              centeredTitle ? 28 : 18,
              arrowAtTop ? 23 : 14,
              centeredTitle ? 28 : 14,
              arrowAtTop ? 8 : 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: arrowAtTop ? 40 : 24,
                  child: TPFitText(
                    span: TextSpan(
                      text: title,
                      style: _tpQuizTextStyle(
                        18,
                        Colors.white,
                        FontWeight.w600,
                      ),
                    ),
                    align: centeredTitle ? TextAlign.center : TextAlign.left,
                    maxLines: arrowAtTop ? 2 : 1,
                  ),
                ),
                SizedBox(height: arrowAtTop ? 8 : 10),
                Flexible(
                  child: TPFitText(
                    span: TextSpan(
                      style: _tpQuizTextStyle(14, Colors.white),
                      children: [body],
                    ),
                    align: TextAlign.left,
                    maxLines: centeredTitle ? 5 : 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TPQuizTipBackground extends CustomPainter {
  const _TPQuizTipBackground(this.arrowAtTop);

  final bool arrowAtTop;

  @override
  void paint(Canvas canvas, Size size) {
    final top = arrowAtTop ? 10.0 : .5;
    final bottom = size.height - (arrowAtTop ? .5 : 10);
    const tipX = 48.0;
    const radius = 11.0;
    final path = Path()
      ..moveTo(radius, top)
      ..quadraticBezierTo(.5, top, .5, top + radius)
      ..lineTo(.5, bottom - radius)
      ..quadraticBezierTo(.5, bottom, radius, bottom);
    if (!arrowAtTop) {
      path
        ..lineTo(tipX - 7, bottom)
        ..lineTo(tipX - 1.5, size.height - 1)
        ..quadraticBezierTo(tipX, size.height, tipX + 1.5, size.height - 1)
        ..lineTo(tipX + 7, bottom);
    }
    path
      ..lineTo(size.width - radius, bottom)
      ..quadraticBezierTo(
        size.width - .5,
        bottom,
        size.width - .5,
        bottom - radius,
      )
      ..lineTo(size.width - .5, top + radius)
      ..quadraticBezierTo(size.width - .5, top, size.width - radius, top);
    if (arrowAtTop) {
      path
        ..lineTo(tipX + 7, top)
        ..lineTo(tipX + 1.5, 1)
        ..quadraticBezierTo(tipX, 0, tipX - 1.5, 1)
        ..lineTo(tipX - 7, top);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF476AC7), Color(0xFF23C36B)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xAFFFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant _TPQuizTipBackground oldDelegate) {
    return arrowAtTop != oldDelegate.arrowAtTop;
  }
}

class _TPQuizHeading extends StatelessWidget {
  const _TPQuizHeading({
    required this.text,
    required this.size,
    required this.color,
  });

  final String text;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: _tpQuizTextStyle(
          size,
          color,
          FontWeight.w900,
        ).copyWith(fontStyle: size == 22 ? FontStyle.italic : FontStyle.normal),
      ),
    );
  }
}

TextStyle _tpQuizTextStyle(
  double size,
  Color color, [
  FontWeight weight = FontWeight.normal,
]) {
  return TextStyle(
    fontFamily: TPFonts.family,
    fontSize: size,
    height: 1.05,
    color: color,
    fontWeight: weight,
    decoration: TextDecoration.none,
  );
}
