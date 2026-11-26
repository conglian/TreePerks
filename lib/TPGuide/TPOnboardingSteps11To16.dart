import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../TPTool/TPFonts.dart';
import '../TPTool/TPImg.dart';
import '../TPTool/TPResponsive.dart';
import 'TPOnboardingWidgets.dart';

const _tpAsset = 'assets/image/onboarding/11_16/';

class TPOnboardingSteps11To16 extends StatelessWidget {
  const TPOnboardingSteps11To16({
    super.key,
    required this.step,
    required this.onNext,
  });

  final int step;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => switch (step) {
    11 => _TPAdvertiserStep(onNext: onNext),
    12 => const _TPQuizBonusStep(),
    13 => const _TPDiceBonusStep(),
    14 => _TPWithdrawalNoticeStep(onNext: onNext),
    15 => _TPRewardStep(onNext: onNext),
    16 => _TPQuizInviteStep(onClose: onNext),
    _ => throw ArgumentError.value(step, 'step', 'Expected steps 11–16'),
  };
}

class _TPAdvertiserStep extends StatefulWidget {
  const _TPAdvertiserStep({required this.onNext});

  final VoidCallback onNext;

  @override
  State<_TPAdvertiserStep> createState() => _TPAdvertiserStepState();
}

class _TPAdvertiserStepState extends State<_TPAdvertiserStep> {
  late final Timer _advanceTimer;
  bool _advanced = false;

  @override
  void initState() {
    super.initState();
    _advanceTimer = Timer(const Duration(milliseconds: 3600), _advance);
  }

  void _advance() {
    if (_advanced) return;
    _advanced = true;
    _advanceTimer.cancel();
    widget.onNext();
  }

  @override
  void dispose() {
    _advanceTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 269,
          left: 0,
          right: 0,
          height: 245,
          child: _TPTapTarget(
            key: const ValueKey('tp-onboarding-next-11'),
            label: 'Continue',
            onTap: _advance,
            child: const _TPAdvertiserBanner(),
          ),
        ),
      ],
    );
  }
}

class _TPAdvertiserBanner extends StatelessWidget {
  const _TPAdvertiserBanner();

  @override
  Widget build(BuildContext context) {
    const pile = [
      (-5.0, 86.0, 69.0, true),
      (20.0, 109.0, 76.0, true),
      (61.0, 102.0, 76.0, true),
      (92.0, 68.0, 69.0, true),
      (147.0, 109.0, 76.0, false),
      (191.0, 101.0, 52.0, true),
      (216.0, 108.0, 76.0, false),
      (258.0, 77.0, 77.0, true),
      (303.0, 110.0, 76.0, true),
      (309.0, 69.0, 77.0, false),
    ];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned(
          left: 73,
          top: -6,
          width: 244,
          height: 240,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xAEFFDC40), Color(0x00FFDA59)],
                stops: [0, 0.63],
              ),
            ),
          ),
        ),
        const Positioned(
          left: 63,
          top: -5,
          width: 266,
          height: 266,
          child: TPOnboardingArtMotion(
            distance: 0,
            scale: 0.06,
            rotation: 0.12,
            period: Duration(milliseconds: 2600),
            child: TPImg(name: '${_tpAsset}banner_flare.png'),
          ),
        ),
        for (final (left, top, size, mirror) in pile)
          Positioned(
            left: left,
            top: top,
            width: size,
            height: size,
            child: Transform.flip(
              flipX: mirror,
              child: const TPImg(name: '${_tpAsset}money.png'),
            ),
          ),
        const Positioned(
          left: 133,
          top: 0,
          width: 142,
          height: 148,
          child: TPOnboardingArtMotion(
            distance: 7,
            scale: 0.035,
            child: TPImg(name: '${_tpAsset}crown.png'),
          ),
        ),
        const Positioned(
          left: 236,
          top: 32,
          width: 57,
          height: 56,
          child: TPOnboardingArtMotion(
            distance: 8,
            rotation: 0.08,
            period: Duration(milliseconds: 1600),
            child: TPImg(name: '${_tpAsset}money.png'),
          ),
        ),
        const Positioned(
          left: 105,
          top: 11,
          width: 29,
          height: 27,
          child: TPOnboardingArtMotion(
            distance: 5,
            rotation: 0.18,
            period: Duration(milliseconds: 1550),
            child: TPImg(name: '${_tpAsset}money.png'),
          ),
        ),
        const Positioned(
          left: 72,
          top: 46,
          width: 31,
          height: 28,
          child: TPOnboardingArtMotion(
            distance: 4,
            rotation: 0.14,
            period: Duration(milliseconds: 1750),
            child: TPImg(name: '${_tpAsset}money.png'),
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          top: 122,
          height: 113,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 1,
                width: 375,
                height: 111,
                child: TPImg(name: '${_tpAsset}banner.png'),
              ),
              Positioned(
                left: 0,
                top: -1,
                width: 375,
                height: 6,
                child: TPImg(name: '${_tpAsset}line_top.png'),
              ),
              Positioned(
                left: 0,
                top: 107,
                width: 375,
                height: 6,
                child: TPImg(name: '${_tpAsset}line_top.png'),
              ),
              CustomPaint(painter: _TPBannerPattern()),
              Center(
                child: Text(
                  'The Advertiser Identifies You\nAs A High-Quality User.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: TPFonts.family,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Color(0xFFFF7500), offset: Offset(0, 4)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TPBannerPattern extends CustomPainter {
  const _TPBannerPattern();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x65FFE74B);
    for (var column = 0; column < 10; column++) {
      for (var row = 0; row < 12 - column; row++) {
        canvas.drawCircle(
          Offset(size.width - 3.0 - column * 4, 9.0 + row * 5),
          1.2,
          paint,
        );
      }
    }
    for (var column = 0; column < 9; column++) {
      canvas.drawCircle(Offset(4.0 + column * 5, 8 + column * 1.2), 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TPBannerPattern oldDelegate) => false;
}

class _TPQuizBonusStep extends StatelessWidget {
  const _TPQuizBonusStep();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 22,
          top: 292,
          width: 330,
          height: 172,
          child: _TPBonusMessage(
            title: 'More ways to earn money Just for you.',
            description: TextSpan(
              text:
                  'Use your 🎲 to unlock extra progress and reach your cashout faster.',
            ),
          ),
        ),
      ],
    );
  }
}

class _TPDiceBonusStep extends StatelessWidget {
  const _TPDiceBonusStep();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 22,
          top: 532,
          width: 330,
          height: 152,
          child: _TPBonusMessage(
            title: 'Extra bonus activated.',
            description: TextSpan(
              children: [
                TextSpan(text: 'Collect '),
                TextSpan(
                  text: '3',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: ' times to earn '),
                TextSpan(
                  text: '1',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8C00),
                  ),
                ),
                TextSpan(text: ' spin.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TPBonusMessage extends StatelessWidget {
  const _TPBonusMessage({required this.title, required this.description});

  final String title;
  final TextSpan description;

  @override
  Widget build(BuildContext context) => _TPModalEntrance(
    child: Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 19,
          height: 53,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2110CF), Color(0xFF3200F2)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 29,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F8),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Positioned(
          left: 25,
          right: 23,
          top: 78,
          height: 24,
          child: Align(
            alignment: Alignment.topLeft,
            child: TPFitText(
              span: TextSpan(
                text: title,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 27,
          right: 23,
          top: 112,
          bottom: 15,
          child: Align(
            alignment: Alignment.topLeft,
            child: TPFitText(
              maxLines: 2,
              span: TextSpan(
                children: [description],
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.15,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          top: 0,
          left: 133,
          width: 67,
          height: 67,
          child: TPOnboardingArtMotion(
            distance: 3,
            scale: 0.025,
            child: TPImg(name: '${_tpAsset}avatar.png'),
          ),
        ),
      ],
    ),
  );
}

class _TPWithdrawalNoticeStep extends StatelessWidget {
  const _TPWithdrawalNoticeStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Positioned(
        left: 14,
        top: 154,
        width: 346,
        height: 542,
        child: _TPModalEntrance(
          child: Stack(
            children: [
              const Positioned.fill(
                child: TPImg(name: '${_tpAsset}notice_bg.png'),
              ),
              const Positioned(
                left: 0,
                right: 0,
                top: 14,
                child: _TPNoticeTitle('Official Notice'),
              ),
              const Positioned(
                left: 23,
                right: 23,
                top: 45,
                child: _TPDashedDivider(),
              ),
              const Positioned(
                left: 31,
                top: 46,
                width: 286,
                height: 161,
                child: TPOnboardingArtMotion(
                  distance: 5,
                  scale: 0.025,
                  rotation: 0.022,
                  child: TPImg(name: '${_tpAsset}lock.png'),
                ),
              ),
              const Positioned(
                left: 18,
                right: 18,
                top: 216,
                child: Text(
                  'Withdrawal Access\nUnlocked',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: TPFonts.family,
                    color: Color(0xFF030C47),
                    fontSize: 24,
                    height: 1.15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Positioned(
                left: 35,
                right: 35,
                top: 281,
                child: Text(
                  'Your account has passed the security verification and is now eligible for withdrawal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: TPFonts.family,
                    color: Color(0xFF3F4769),
                    fontSize: 12,
                    height: 1.16,
                  ),
                ),
              ),
              Positioned(
                left: 33,
                top: 320,
                width: 282,
                height: 64,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC5E8FF)),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE4F3FA),
                        Colors.white,
                        Color(0xFFE4F3FA),
                      ],
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Current Earnings',
                        style: TextStyle(
                          fontFamily: TPFonts.family,
                          fontSize: 12,
                          color: Color(0xFF0651B1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      _TPEarningsAmount(fontSize: 32),
                    ],
                  ),
                ),
              ),
              const Positioned(
                left: 41,
                right: 30,
                top: 394,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'Keep going!\nAnswer a few more quizzes correctly.\nPass ',
                      ),
                      TextSpan(
                        text: '2,367',
                        style: TextStyle(
                          color: Color(0xFF0B53FE),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: ' users and get '),
                      TextSpan(
                        text: r'$100',
                        style: TextStyle(
                          color: Color(0xFF0AA212),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: ' instantly.'),
                    ],
                  ),
                  style: TextStyle(
                    fontFamily: TPFonts.family,
                    color: Color(0xFF3A4068),
                    fontSize: 14,
                    height: 1.18,
                  ),
                ),
              ),
              const Positioned(
                left: 23,
                right: 23,
                top: 458,
                child: _TPDashedDivider(),
              ),
              Positioned(
                left: 57,
                top: 472,
                width: 235,
                height: 55,
                child: _TPBlueButton(
                  key: const ValueKey('tp-onboarding-next-14'),
                  title: 'Earn Now',
                  onTap: onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _TPRewardStep extends StatelessWidget {
  const _TPRewardStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Positioned(
        left: 15,
        top: 158,
        width: 346,
        height: 503,
        child: _TPModalEntrance(
          child: Stack(
            children: [
              const Positioned.fill(
                child: TPImg(name: '${_tpAsset}reward_bg.png'),
              ),
              const Positioned(
                left: 0,
                right: 0,
                top: 18,
                child: _TPNoticeTitle('Rewards await you'),
              ),
              const Positioned(
                left: 0,
                right: 0,
                top: 58,
                child: _TPEarningsAmount(fontSize: 40),
              ),
              const Positioned(
                left: 0,
                right: 0,
                top: 110,
                child: Text(
                  'My Income',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: TPFonts.family,
                    color: Color(0xFF313761),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Positioned(
                left: 23,
                top: 124,
                width: 294,
                height: 196,
                child: TPOnboardingArtMotion(
                  distance: 6,
                  scale: 0.03,
                  rotation: 0.025,
                  period: Duration(milliseconds: 2050),
                  child: TPImg(name: '${_tpAsset}chest.png'),
                ),
              ),
              const Positioned(
                left: 8,
                right: 8,
                top: 328,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Play for '),
                      TextSpan(
                        text: '30s',
                        style: TextStyle(color: Color(0xFF0941FE)),
                      ),
                      TextSpan(text: ' to earn '),
                      TextSpan(
                        text: r'$50 !',
                        style: TextStyle(color: Color(0xFF0AA212)),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: TPFonts.family,
                    color: Color(0xFF05073F),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Positioned(
                left: 28,
                right: 28,
                top: 365,
                height: 34,
                child: _TPWithdrawalProgress(),
              ),
              const Positioned(
                left: 23,
                right: 23,
                top: 412,
                child: _TPDashedDivider(),
              ),
              Positioned(
                left: 56,
                top: 429,
                width: 235,
                height: 55,
                child: _TPBlueButton(
                  key: const ValueKey('tp-onboarding-next-15'),
                  title: 'Play & Earn',
                  onTap: onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _TPQuizInviteStep extends StatelessWidget {
  const _TPQuizInviteStep({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Positioned(
        left: 163,
        top: 682,
        width: 48,
        height: 48,
        child: _TPTapTarget(
          key: const ValueKey('tp-onboarding-close-16'),
          label: 'Close',
          onTap: onClose,
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE9E9E9), width: 2),
              ),
              child: const Icon(
                Icons.close,
                size: 22,
                color: Color(0xFFD9D9D9),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class TPOnboardingEarningsBulletins extends StatefulWidget {
  const TPOnboardingEarningsBulletins({super.key});

  @override
  State<TPOnboardingEarningsBulletins> createState() =>
      _TPOnboardingEarningsBulletinsState();
}

class _TPOnboardingEarningsBulletinsState
    extends State<TPOnboardingEarningsBulletins>
    with SingleTickerProviderStateMixin {
  static const _designWidth = 375.0;
  static const _stripWidth = 352.0;
  static const _stagger = Duration(milliseconds: 730);
  static const _lanes = [
    (left: 70.0, top: 367.0, speed: 78.0),
    (left: -14.0, top: 474.0, speed: 71.0),
    (left: 116.0, top: 572.0, speed: 84.0),
  ];

  Duration _elapsed = Duration.zero;
  late final Ticker _ticker = createTicker((elapsed) {
    setState(() => _elapsed = elapsed);
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ticker.stop();
      _elapsed = Duration.zero;
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double _leftForLane(double viewportWidth, int index, bool reduceMotion) {
    final lane = _lanes[index];
    if (reduceMotion) return (viewportWidth - _designWidth) / 2 + lane.left;

    final time = _elapsed - _stagger * index;
    final seconds =
        math.max(0, time.inMicroseconds) / Duration.microsecondsPerSecond;
    final distance = seconds * lane.speed;
    // Wrap when the strip has moved completely past the left edge.
    return viewportWidth - distance % (viewportWidth + _stripWidth);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) => ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            for (var index = 0; index < _lanes.length; index++)
              Positioned(
                left: 0,
                top: _lanes[index].top,
                width: _stripWidth,
                height: 49,
                child: Transform.translate(
                  key: ValueKey('tp-onboarding-earnings-lane-${index + 1}'),
                  offset: Offset(
                    _leftForLane(constraints.maxWidth, index, reduceMotion),
                    0,
                  ),
                  child: const _TPEarningStrip(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TPEarningStrip extends StatelessWidget {
  const _TPEarningStrip();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          left: 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C217), Color(0x00426545)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(45)),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          height: 49,
          width: 49,
          child: TPImg(name: '${_tpAsset}avatar.png'),
        ),
        Positioned(
          left: 61,
          top: 0,
          bottom: 0,
          child: Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'I earned '),
                  TextSpan(
                    text: r'$10',
                    style: TextStyle(
                      color: Color(0xFFFFF600),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: ' from 3 quick questions.'),
                ],
              ),
              style: TextStyle(
                fontFamily: TPFonts.family,
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _TPWithdrawalProgress extends StatelessWidget {
  const _TPWithdrawalProgress();

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const Positioned(
        left: 0,
        top: 0,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Withdrawal Progress: '),
              TextSpan(
                text: r'$xx / $xx',
                style: TextStyle(
                  color: Color(0xFF0AA212),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          style: TextStyle(
            fontFamily: TPFonts.family,
            color: Color(0xFF3F4769),
            fontSize: 12,
          ),
        ),
      ),
      Positioned(
        top: 21,
        left: 0,
        width: 215,
        height: 8,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 142 / 215),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
            backgroundColor: const Color(0xFFDCEEFF),
            color: const Color(0xFF01E9FE),
            borderRadius: BorderRadius.circular(42),
            trackGap: 0,
            stopIndicatorRadius: 0,
          ),
        ),
      ),
      const Positioned(
        right: 0,
        top: 16,
        width: 65,
        height: 17,
        child: TPImg(name: '${_tpAsset}paypal.png', fit: BoxFit.contain),
      ),
    ],
  );
}

class _TPNoticeTitle extends StatelessWidget {
  const _TPNoticeTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontFamily: TPFonts.family,
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
  );
}

class _TPEarningsAmount extends StatelessWidget {
  const _TPEarningsAmount({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 500),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 580),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Text(
        '\$${value.round()}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: TPFonts.family,
          color: const Color(0xFF0AA212),
          fontSize: fontSize,
          height: 1.13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TPDashedDivider extends StatelessWidget {
  const _TPDashedDivider();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 1,
    child: CustomPaint(painter: _TPDashesPainter()),
  );
}

class _TPDashesPainter extends CustomPainter {
  const _TPDashesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA7B9C8)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 7) {
      canvas.drawLine(
        Offset(x, 0.5),
        Offset(math.min(x + 4, size.width), 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TPDashesPainter oldDelegate) => false;
}

class _TPBlueButton extends StatelessWidget {
  const _TPBlueButton({super.key, required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _TPTapTarget(
    label: title,
    onTap: onTap,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(75),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF27A3FD), Color(0xFF1772FC), Color(0xFF16BEE6)],
          stops: [0, 0.74, 1],
        ),
        border: Border.all(color: const Color(0xFF82A2FF)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            top: 3,
            left: 5,
            right: 3,
            height: 49,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(47)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE7F1FF), Color(0x00FFFAD5)],
                  stops: [0, 0.41],
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: TPFonts.family,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TPModalEntrance extends StatelessWidget {
  const _TPModalEntrance({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 10 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
    );
  }
}

class _TPTapTarget extends StatelessWidget {
  const _TPTapTarget({
    super.key,
    required this.label,
    required this.onTap,
    this.child,
  });

  final String label;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ExcludeSemantics(child: child ?? const SizedBox.expand()),
    ),
  );
}
