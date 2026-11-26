import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../TPTool/TPFonts.dart';
import '../TPTool/TPText.dart';
import 'TPDialogWidgets.dart';

enum TPDiceDialogKind {
  notEnoughDice,
  bonusWheelReveal,
  dailyCheckIn,
  checkInGuide,
  fortuneReward,
  fortuneResult,
}

/// 骰子、签到和幸运转盘的弹窗内容。
class TPDiceDialog extends StatelessWidget {
  const TPDiceDialog({
    super.key,
    required this.kind,
    required this.onClose,
    this.onNext,
  });

  final TPDiceDialogKind kind;
  final VoidCallback onClose;
  final ValueChanged<TPDiceDialogKind>? onNext;

  void _advance(TPDiceDialogKind kind) {
    final onNext = this.onNext;
    if (onNext == null) {
      onClose();
    } else {
      onNext(kind);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      TPDiceDialogKind.notEnoughDice => _TPDiceUnavailable(
        onPressed: () => _advance(TPDiceDialogKind.bonusWheelReveal),
      ),
      TPDiceDialogKind.bonusWheelReveal => _TPDiceWheelReveal(
        onPressed: () => _advance(TPDiceDialogKind.dailyCheckIn),
      ),
      TPDiceDialogKind.dailyCheckIn => _TPDiceCheckIn(
        onContinue: () => _advance(TPDiceDialogKind.checkInGuide),
        onClose: onClose,
      ),
      TPDiceDialogKind.checkInGuide => _TPDiceCheckInGuide(
        onPressed: () => _advance(TPDiceDialogKind.fortuneReward),
      ),
      TPDiceDialogKind.fortuneReward => _TPDiceFortuneReward(
        onPressed: () => _advance(TPDiceDialogKind.fortuneResult),
        onClose: onClose,
      ),
      TPDiceDialogKind.fortuneResult => _TPDiceFortuneResult(onClose: onClose),
    };
  }
}

/// 骰子不足时，突出棋盘上的骰子并提供寻找入口。
class _TPDiceUnavailable extends StatelessWidget {
  const _TPDiceUnavailable({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        const Positioned(
          left: 69,
          top: 296,
          width: 243,
          height: 36,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFFAEFDC),
                border: Border.fromBorderSide(
                  BorderSide(color: Color(0xFFFBF6B5), width: 2),
                ),
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Center(
                child: TPText(
                  text: 'Not enough dice to roll',
                  color: Color(0xFF58150E),
                  weight: FontWeight.w700,
                  size: 15,
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          left: 119,
          top: 351,
          width: 136,
          height: 136,
          child: TPDialogMotion(
            effect: TPDialogEffect.celebration,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF700D0D),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Padding(
                padding: EdgeInsets.all(7),
                child: _TPDiceImage('assets/image/dice/tp_dice_roll_die.png'),
              ),
            ),
          ),
        ),
        Positioned(
          left: 78,
          top: 616,
          width: 219,
          height: 73,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            delay: const Duration(milliseconds: 100),
            child: _TPDiceOrangeButton(label: 'Find it', onPressed: onPressed),
          ),
        ),
      ],
    );
  }
}

/// 签到、开奖和退出提示共用的转盘背景。
class TPDiceWheelBackdrop extends StatelessWidget {
  const TPDiceWheelBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFEEE48), Color(0xFFFFFCDF), Colors.white],
        ),
      ),
      child: TPDialogStage(
        children: [
          Positioned.fill(child: _TPDiceArt('wheel_background')),
          Positioned(
            left: 0,
            top: 545,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00FFFFFF), Colors.white, Colors.white],
                  stops: [0, .57, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 313,
            top: 39,
            width: 50,
            height: 50,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: _TPDiceImage('assets/image/dice/tp_dice_home.png'),
            ),
          ),
          Positioned(
            left: 14,
            top: 83,
            width: 348,
            height: 152,
            child: _TPDiceArt('wheel_title'),
          ),
          Positioned(
            left: 32,
            top: 248,
            width: 312,
            height: 312,
            child: _TPDiceWheelFace(),
          ),
          Positioned(
            left: 139,
            top: 345,
            width: 98,
            height: 98,
            child: IgnorePointer(child: _TPDiceArt('wheel_center')),
          ),
          Positioned(
            left: 78,
            top: 616,
            width: 219,
            height: 73,
            child: _TPDiceOrangeButton(label: 'Spin'),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 94,
            child: _TPDiceImage(
              'assets/image/dice/tp_dice_footer_money.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 7,
            right: 7,
            bottom: 7,
            height: 53,
            child: _TPDiceWheelTabs(),
          ),
        ],
      ),
    );
  }
}

class _TPDiceWheelFace extends StatelessWidget {
  const _TPDiceWheelFace();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        const Positioned(
          left: -10,
          top: -10,
          right: -10,
          bottom: -10,
          child: _TPDiceArt('wheel_ring'),
        ),
        const SizedBox.square(
          dimension: 280,
          child: CustomPaint(painter: _TPDiceWedges()),
        ),
        for (var index = 0; index < 6; index++)
          Transform.rotate(
            angle: index * math.pi / 3,
            child: Transform.translate(
              offset: const Offset(0, -99),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TPDiceOutlinedText(
                    text: r'$100',
                    size: 20,
                    color: Color(0xFFDBF71C),
                    outline: Color(0xFF47520C),
                    italic: false,
                  ),
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: _TPDiceImage(
                      'assets/image/dice/tp_dice_tile_money.png',
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TPDiceWedges extends CustomPainter {
  const _TPDiceWedges();

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 - 1;
    final center = size.center(Offset.zero);
    final bounds = Rect.fromCircle(center: center, radius: radius);
    const colors = [
      Color(0xFFFFD100),
      Color(0xFFFF537C),
      Color(0xFFAADB1C),
      Color(0xFFFF8715),
      Color(0xFF17C0E9),
      Color(0xFFAB53E8),
    ];
    const sweep = math.pi / 3;
    final paint = Paint();
    for (var i = 0; i < colors.length; i++) {
      final start = -2 * math.pi / 3 + sweep * i;
      canvas.drawArc(bounds, start, sweep, true, paint..color = colors[i]);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * .76),
        start,
        sweep,
        true,
        paint..color = Colors.white.withValues(alpha: .09),
      );
      canvas.drawLine(
        center,
        center + Offset(math.cos(start), math.sin(start)) * radius,
        paint
          ..color = const Color(0xFFAA5705)
          ..strokeWidth = 1.2,
      );
    }
    canvas.drawCircle(
      center,
      radius,
      paint
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFB45C04)
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _TPDiceWedges oldDelegate) => false;
}

class _TPDiceWheelTabs extends StatelessWidget {
  const _TPDiceWheelTabs();

  @override
  Widget build(BuildContext context) {
    const tabs = [
      ('Tree', 'tp_tab_tree_off.png'),
      ('Dice', 'tp_tab_dice_on_icon.png'),
      ('Quiz', 'tp_tab_quiz_off.png'),
      ('Cash', 'tp_tab_cash_off.png'),
    ];
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(42),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final (label, art) in tabs)
              SizedBox(
                width: 55,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: label == 'Dice'
                            ? const Color(0xFF00A86A)
                            : Colors.transparent,
                      ),
                      child: SizedBox.square(
                        dimension: 28,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: _TPDiceImage('assets/image/tabs/$art'),
                        ),
                      ),
                    ),
                    TPText(
                      text: label,
                      size: 14,
                      color: label == 'Dice'
                          ? const Color(0xFF00885C)
                          : const Color(0xFFADADAD),
                      weight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 幸运转盘公布横幅与飞入的纸钞。
class _TPDiceWheelReveal extends StatelessWidget {
  const _TPDiceWheelReveal({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        const Positioned(
          left: 21,
          top: 264,
          width: 332,
          height: 261,
          child: TPDialogMotion(
            effect: TPDialogEffect.fade,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xC7FFD653), Color(0x00FFD653)],
                ),
              ),
            ),
          ),
        ),
        for (final (left, top, turns, billDelay) in const [
          (241.0, 90.0, 0.0, 95),
          (20.0, 209.0, -.91, 120),
          (280.0, 468.0, .8, 170),
          (4.0, 534.0, .14, 140),
          (254.0, 583.0, -1.26, 180),
          (112.0, 672.0, .06, 220),
        ])
          Positioned(
            left: left,
            top: top,
            width: 106,
            height: 76,
            child: IgnorePointer(
              child: TPDialogMotion(
                delay: Duration(milliseconds: billDelay),
                effect: TPDialogEffect.rise,
                child: Transform.rotate(
                  angle: turns,
                  child: const _TPDiceArt('floating_bill'),
                ),
              ),
            ),
          ),
        const Positioned(
          left: 66,
          top: 278,
          width: 100,
          height: 109,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            child: _TPDiceImage('assets/image/home/tp_home_cash.png'),
          ),
        ),
        const Positioned(
          left: 208,
          top: 274,
          width: 112,
          height: 108,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            child: _TPDiceImage('assets/image/home/tp_home_cash.png'),
          ),
        ),
        const Positioned(
          left: 120,
          top: 235,
          width: 152,
          height: 152,
          child: TPDialogMotion(
            effect: TPDialogEffect.celebration,
            child: _TPDiceArt('wheel_promo'),
          ),
        ),
        Positioned(
          left: -18,
          top: 339,
          width: 414,
          height: 133,
          child: TPDialogMotion(
            effect: TPDialogEffect.pop,
            delay: const Duration(milliseconds: 60),
            child: Transform.rotate(
              angle: -.1665,
              child: _TPDiceTap(
                label: 'Finally! Bonus Cash Wheel!',
                onPressed: onPressed,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFF5B08),
                        Color(0xFFFFAD1C),
                        Color(0xFFFF6012),
                      ],
                    ),
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: Color(0xD9FFE7AA),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: const CustomPaint(
                    painter: _TPDiceBannerDots(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TPDiceOutlinedText(text: 'FINALLY!', size: 38),
                        _TPDiceOutlinedText(
                          text: 'BONUS CASH WHEEL!',
                          size: 31,
                        ),
                      ],
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

class _TPDiceBannerDots extends CustomPainter {
  const _TPDiceBannerDots();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var y = 6.0; y < size.height; y += 9) {
      for (var x = 6.0; x < size.width; x += 9) {
        final edgeWeight = ((x - size.width / 2) / (size.width / 2)).abs();
        canvas.drawCircle(
          Offset(x + ((y ~/ 9).isOdd ? 3 : 0), y),
          1.4,
          paint..color = Colors.white.withValues(alpha: edgeWeight * .33),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TPDiceBannerDots oldDelegate) => false;
}

/// 每日签到七天奖励与确认按钮。
class _TPDiceCheckIn extends StatelessWidget {
  const _TPDiceCheckIn({required this.onContinue, required this.onClose});

  final VoidCallback onContinue;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        Positioned(
          left: 27,
          top: 204,
          width: 322,
          height: 428,
          child: TPDialogMotion(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: ColoredBox(
                color: Colors.white,
                child: Stack(
                  children: [
                    const Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: 90,
                      child: _TPDiceCheckInHeader(),
                    ),
                    for (var day = 0; day < 6; day++)
                      Positioned(
                        left: 12 + (day % 4) * 77,
                        top: 113 + (day ~/ 4) * 114,
                        width: 66,
                        height: 104,
                        child: TPDialogMotion(
                          effect: TPDialogEffect.rise,
                          delay: Duration(milliseconds: 20 * day),
                          child: _TPDiceDay(day: day + 1),
                        ),
                      ),
                    const Positioned(
                      left: 165,
                      top: 227,
                      width: 143,
                      height: 104,
                      child: TPDialogMotion(
                        effect: TPDialogEffect.rise,
                        delay: Duration(milliseconds: 120),
                        child: _TPDiceDay(day: 7),
                      ),
                    ),
                    Positioned(
                      left: 62,
                      top: 354,
                      width: 199,
                      height: 55,
                      child: _TPDiceCheckInAction(onPressed: onContinue),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          left: 180,
          top: 137,
          width: 178,
          height: 165,
          child: IgnorePointer(
            child: TPDialogMotion(
              effect: TPDialogEffect.celebration,
              delay: Duration(milliseconds: 80),
              child: _TPDiceArt('check_in'),
            ),
          ),
        ),
        Positioned(
          left: 166,
          top: 656,
          child: TPDialogCloseButton(onPressed: onClose),
        ),
      ],
    );
  }
}

class _TPDiceCheckInHeader extends StatelessWidget {
  const _TPDiceCheckInHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEDFF5B),
                  Color(0xFFADFE40),
                  Color(0xFFF1FF68),
                ],
              ),
            ),
          ),
        ),
        const Positioned(
          left: 49,
          top: -31,
          child: _TPDiceOutlinedText(
            text: 'Daily',
            italic: false,
            color: Color(0x62BCF339),
            outline: Color(0x90FDFFE0),
            size: 90,
          ),
        ),
        Positioned(
          left: 29,
          top: 13,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TPText(
                text: 'Daily',
                size: 32,
                color: Color(0xFF262D05),
                weight: FontWeight.w900,
                align: TextAlign.left,
              ),
              const TPText(
                text: 'Check-In',
                size: 22,
                color: Color(0xFF262D05),
                weight: FontWeight.w800,
                align: TextAlign.left,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TPDiceDay extends StatelessWidget {
  const _TPDiceDay({required this.day});

  final int day;

  @override
  Widget build(BuildContext context) {
    final completed = day == 1;
    final prize = day == 7;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: prize
              ? const [Color(0xFFFFDF60), Color(0xFFFFF37F)]
              : const [Color(0xFFF8F9FB), Color(0xFFFCFCFD)],
        ),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Stack(
        children: [
          Positioned(
            left: prize ? 12 : 0,
            right: prize ? 97 : 0,
            top: 10,
            child: Column(
              children: [
                TPText(
                  text: 'DAY',
                  size: 14,
                  color: prize
                      ? const Color(0xFFAE825A)
                      : const Color(0xFFB5B7BE),
                  weight: FontWeight.w500,
                ),
                const SizedBox(height: 3),
                TPText(
                  text: day.toString().padLeft(2, '0'),
                  size: 24,
                  color: completed
                      ? const Color(0xFF69BC23)
                      : const Color(0xFF3E3E48),
                  weight: FontWeight.w700,
                ),
              ],
            ),
          ),
          if (prize)
            const Positioned(
              right: 9,
              bottom: 6,
              width: 94,
              height: 81,
              child: _TPDiceArt('chest'),
            )
          else
            Positioned(
              bottom: 8,
              left: 21,
              width: 24,
              height: 24,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed
                      ? const Color(0xFF67C62B)
                      : Colors.transparent,
                  border: Border.all(
                    color: completed
                        ? const Color(0xFF67C62B)
                        : const Color(0xFFE9EAED),
                  ),
                ),
                child: completed
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _TPDiceCheckInAction extends StatelessWidget {
  const _TPDiceCheckInAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _TPDiceTap(
      label: 'Continue',
      onPressed: onPressed,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF9108), Color(0xFFFF4067)],
          ),
          borderRadius: BorderRadius.all(Radius.circular(40)),
          border: Border.fromBorderSide(
            BorderSide(color: Color(0xFFFCA347), width: 1.5),
          ),
        ),
        child: Center(
          child: TPText(
            text: 'Continue',
            size: 22,
            color: Colors.white,
            weight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// 签到操作引导，大图和提示均可点击。
class _TPDiceCheckInGuide extends StatelessWidget {
  const _TPDiceCheckInGuide({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        Positioned(
          left: 54,
          top: 272,
          width: 267,
          height: 294,
          child: _TPDiceTap(
            label: "Tap to complete today's check-in",
            onPressed: onPressed,
            child: TPDialogTapHint(
              builder: (context, pressure) => Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 10,
                    top: 12,
                    width: 242,
                    height: 224,
                    child: TPDialogMotion(
                      effect: TPDialogEffect.celebration,
                      child: Transform.scale(
                        key: const ValueKey('tp-dice-check-in-calendar'),
                        alignment: const Alignment(.20, .80),
                        scale: 1 - .05 * pressure,
                        transformHitTests: false,
                        child: const _TPDiceArt('wheel_calendar'),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 134,
                    top: 204,
                    width: 126,
                    height: 113,
                    child: TPDialogMotion(
                      effect: TPDialogEffect.rise,
                      delay: const Duration(milliseconds: 130),
                      child: Transform.translate(
                        key: const ValueKey('tp-dice-check-in-hand'),
                        offset: const Offset(-7, -6) * pressure,
                        transformHitTests: false,
                        child: const _TPDiceArt('hand'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 25,
          top: 597,
          width: 325,
          height: 71,
          child: TPDialogMotion(
            delay: const Duration(milliseconds: 120),
            effect: TPDialogEffect.rise,
            child: _TPDiceTap(
              label: "Tap to complete today's check-in",
              onPressed: onPressed,
              child: const Center(
                child: _TPDiceOutlinedText(
                  text: "TAP TO COMPLETE TODAY'S\nCHECK-IN!",
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 幸运奖励到账前展示进度、金额和确认入口。
class _TPDiceFortuneReward extends StatelessWidget {
  const _TPDiceFortuneReward({required this.onPressed, required this.onClose});

  final VoidCallback onPressed;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        const Positioned(
          left: 20,
          top: 143,
          width: 335,
          height: 51,
          child: _TPDiceRewardHeading(),
        ),
        Positioned(
          left: 26,
          top: 194,
          width: 324,
          height: 376,
          child: TPDialogMotion(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColoredBox(
                color: Colors.white,
                child: Stack(
                  children: [
                    const Positioned(
                      left: 0,
                      top: 0,
                      width: 324,
                      height: 283,
                      child: _TPDiceArt('paypal_card'),
                    ),
                    const Positioned(
                      left: 0,
                      top: 0,
                      width: 324,
                      height: 176,
                      child: _TPDiceArt('paypal_pattern'),
                    ),
                    const Positioned(
                      left: 78,
                      top: 60,
                      width: 175,
                      height: 173,
                      child: TPDialogMotion(
                        delay: Duration(milliseconds: 100),
                        effect: TPDialogEffect.celebration,
                        child: _TPDiceArt('reward_bills'),
                      ),
                    ),
                    const Positioned(
                      left: 10,
                      right: 10,
                      top: 225,
                      height: 53,
                      child: Center(
                        child: _TPDiceOutlinedText(
                          text: r'$226.02',
                          size: 40,
                          color: Colors.white,
                          outline: Color(0xFF2142D0),
                          italic: false,
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 20,
                      top: 309,
                      child: TPText(
                        text: r'$55.55',
                        size: 24,
                        color: Color(0xFF00B058),
                        weight: FontWeight.w700,
                      ),
                    ),
                    const Positioned(
                      left: 129,
                      right: 15,
                      top: 319,
                      height: 23,
                      child: TPText(
                        text: r'Only $2.35 to Cash Out!',
                        size: 15,
                        color: Color(0xFF0E1C40),
                        weight: FontWeight.w400,
                      ),
                    ),
                    const Positioned(
                      left: 20,
                      right: 23,
                      top: 344,
                      height: 12,
                      child: _TPDiceProgress(
                        value: 123 / 281,
                        background: Color(0xFFDEE3EE),
                        fill: Color(0xFF3998FF),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      top: 2,
                      width: 38,
                      height: 38,
                      child: _TPDiceTap(
                        label: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        onPressed: onClose,
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFFDDEDFF),
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 46,
          top: 598,
          width: 285,
          height: 80,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            delay: const Duration(milliseconds: 150),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 24,
                  height: 55,
                  child: TPDialogButton(
                    label: 'Add To Account',
                    onPressed: onPressed,
                  ),
                ),
                const Positioned(
                  left: 39,
                  top: 41,
                  width: 28,
                  height: 22,
                  child: IgnorePointer(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _TPDiceAdBadge(),
                    ),
                  ),
                ),
                const Positioned(
                  right: 0,
                  top: 1,
                  width: 93,
                  height: 29,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFFA730A),
                        borderRadius: BorderRadius.all(Radius.circular(17)),
                      ),
                      child: Center(
                        child: TPText(
                          text: r'$10.06',
                          size: 16,
                          color: Color(0xFFEEFF00),
                          weight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 幸运奖励到账后，展示转盘上方金额和奖励动画。
class _TPDiceFortuneResult extends StatelessWidget {
  const _TPDiceFortuneResult({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        const Positioned(
          left: 0,
          top: 241,
          width: 375,
          height: 400,
          child: IgnorePointer(
            child: TPDialogMotion(
              effect: TPDialogEffect.fade,
              child: _TPDiceArt('reward_rays'),
            ),
          ),
        ),
        const Positioned(
          left: 20,
          top: 265,
          width: 335,
          height: 52,
          child: _TPDiceRewardHeading(),
        ),
        Positioned(
          left: 71,
          top: 339,
          width: 230,
          height: 201,
          child: TPDialogMotion(
            effect: TPDialogEffect.celebration,
            delay: const Duration(milliseconds: 100),
            child: _TPDiceTap(
              label: 'Collect reward',
              onPressed: onClose,
              child: const Stack(
                children: [
                  Positioned(
                    left: 45,
                    top: 2,
                    width: 142,
                    height: 128,
                    child: _TPDiceArt('reward_bills'),
                  ),
                  Positioned(
                    left: 6,
                    top: 79,
                    width: 87,
                    height: 58,
                    child: _TPDiceImage('assets/image/home/tp_home_cash.png'),
                  ),
                  Positioned(
                    right: 12,
                    top: 63,
                    width: 89,
                    height: 78,
                    child: _TPDiceImage('assets/image/home/tp_home_cash.png'),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 7,
                    child: _TPDiceOutlinedText(
                      text: r'$10.51',
                      size: 41,
                      color: Color(0xFF9AFF20),
                      outline: Color(0xA63E6409),
                      italic: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 18,
          top: 73,
          width: 345,
          height: 101,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            child: _TPDiceWallet(onClose: onClose),
          ),
        ),
      ],
    );
  }
}

class _TPDiceRewardHeading extends StatelessWidget {
  const _TPDiceRewardHeading();

  @override
  Widget build(BuildContext context) {
    return const TPDialogMotion(
      effect: TPDialogEffect.rise,
      child: Center(
        child: _TPDiceOutlinedText(
          text: 'Fortune Smiles on You!',
          color: Color(0xFFFFD900),
          outline: Color(0xFF721B00),
          size: 32,
        ),
      ),
    );
  }
}

class _TPDiceWallet extends StatelessWidget {
  const _TPDiceWallet({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2571F8), Color(0xFF0B46A8)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: _TPDiceImage(
                'assets/image/home/tp_home_card_pattern.png',
                fit: BoxFit.cover,
              ),
            ),
            const Positioned(
              left: 0,
              top: 10,
              width: 55,
              height: 42,
              child: _TPDiceImage('assets/image/home/tp_home_paypal.png'),
            ),
            const Positioned(
              left: 62,
              top: 18,
              child: TPText(
                text: r'$999.75',
                size: 28,
                color: Colors.white,
                weight: FontWeight.w700,
              ),
            ),
            Positioned(
              right: 20,
              top: 16,
              width: 113,
              height: 30,
              child: _TPDiceTap(
                label: 'Withdraw',
                onPressed: onClose,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                  child: Center(
                    child: TPText(
                      text: 'Withdraw',
                      size: 14,
                      color: Color(0xFF1361F7),
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 9,
              right: 9,
              top: 60,
              height: 16,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _TPDiceProgress(
                      value: .92,
                      background: Color(0xFF063082),
                      fill: Color(0xFF28C0F6),
                      padding: 2,
                    ),
                  ),
                  Center(
                    child: TPText(
                      text: '92%',
                      color: Colors.white,
                      size: 10,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 9,
              top: 82,
              child: TPText(
                text: r'Only $.025 more to withdraw $1000 !',
                size: 12,
                color: Colors.white,
                weight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TPDiceProgress extends StatelessWidget {
  const _TPDiceProgress({
    required this.value,
    required this.background,
    required this.fill,
    this.padding = 0,
  });

  final double value;
  final Color background;
  final Color fill;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    final reduced = MediaQuery.disableAnimationsOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: radius),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: reduced ? value : 0, end: value),
          duration: reduced ? Duration.zero : const Duration(milliseconds: 625),
          curve: Curves.easeOutCubic,
          builder: (context, widthFactor, child) => FractionallySizedBox(
            widthFactor: widthFactor,
            alignment: Alignment.centerLeft,
            child: child,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(color: fill, borderRadius: radius),
          ),
        ),
      ),
    );
  }
}

class _TPDiceAdBadge extends StatelessWidget {
  const _TPDiceAdBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: TPText(
              text: 'AD',
              size: 10,
              color: Color(0xFF1773FC),
              weight: FontWeight.w800,
            ),
          ),
        ),
        const Icon(Icons.videocam_rounded, color: Colors.white, size: 10),
      ],
    );
  }
}

class _TPDiceOrangeButton extends StatelessWidget {
  const _TPDiceOrangeButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final artwork = Stack(
      children: [
        const Positioned.fill(
          child: _TPDiceImage('assets/image/dice/tp_dice_button.png'),
        ),
        Positioned(
          top: 11,
          left: 12,
          right: 12,
          height: 42,
          child: Center(
            child: _TPDiceOutlinedText(
              text: label,
              size: 32,
              color: Colors.white,
              outline: const Color(0xFFA22F21),
            ),
          ),
        ),
      ],
    );
    final action = onPressed;
    return action == null
        ? artwork
        : _TPDiceTap(label: label, onPressed: action, child: artwork);
  }
}

class _TPDiceTap extends StatelessWidget {
  const _TPDiceTap({
    required this.label,
    required this.onPressed,
    required this.child,
  });

  final String label;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(onTap: onPressed, child: child),
      ),
    );
  }
}

class _TPDiceOutlinedText extends StatelessWidget {
  const _TPDiceOutlinedText({
    required this.text,
    required this.size,
    this.color = const Color(0xFFFFF3B4),
    this.outline = const Color(0xFFA33018),
    this.italic = true,
  });

  final String text;
  final double size;
  final Color color;
  final Color outline;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: color,
      fontFamily: TPFonts.family,
      fontSize: size,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontWeight: FontWeight.w900,
      height: 1.10,
      decoration: TextDecoration.none,
    );
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ExcludeSemantics(
            child: RichText(
              textAlign: TextAlign.center,
              textScaler: MediaQuery.textScalerOf(context),
              text: TextSpan(
                text: text,
                style: style.copyWith(
                  foreground: Paint()
                    ..color = outline
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2.3
                    ..strokeJoin = StrokeJoin.round,
                ),
              ),
            ),
          ),
          Text(text, style: style, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _TPDiceArt extends StatelessWidget {
  const _TPDiceArt(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return _TPDiceImage('assets/image/dialog/dice/tp_dialog_dice_$name.png');
  }
}

class _TPDiceImage extends StatelessWidget {
  const _TPDiceImage(this.path, {this.fit = BoxFit.contain});

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(path, fit: fit, excludeFromSemantics: true);
  }
}
