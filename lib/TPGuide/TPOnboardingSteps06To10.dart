import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../TPTool/TPImg.dart';
import '../TPTool/TPResponsive.dart';
import '../TPTool/TPText.dart';
import 'TPOnboardingWidgets.dart';

const _tpMidAssets = 'assets/image/onboarding/06_10';
const _tpHomeAssets = 'assets/image/home';

class TPOnboardingSteps06To10 extends StatelessWidget {
  const TPOnboardingSteps06To10({
    super.key,
    required this.step,
    required this.onNext,
  });

  final int step;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return switch (step) {
      6 => const _TPOnboardingBonusGuide(),
      7 => _TPOnboardingSponsorReward(onNext: onNext),
      8 => _TPOnboardingFirstReward(onNext: onNext),
      9 => const _TPOnboardingWithdrawalQuiz(),
      10 => _TPOnboardingScanPreview(onNext: onNext),
      _ => throw ArgumentError.value(step, 'step', 'Expected steps 06–10'),
    };
  }
}

class _TPOnboardingMidAction extends StatelessWidget {
  const _TPOnboardingMidAction({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class _TPOnboardingGuideCard extends StatelessWidget {
  const _TPOnboardingGuideCard({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 20,
          left: 0,
          right: 0,
          height: 53,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF3414D4),
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
          ),
        ),
        Positioned(
          top: 29,
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xFFF2F3F8),
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 49, 26, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TPText(
                    text: title,
                    size: 16,
                    color: Colors.black,
                    weight: FontWeight.w500,
                    align: TextAlign.left,
                  ),
                  const SizedBox(height: 14),
                  for (final (index, paragraph) in paragraphs.indexed) ...[
                    if (index > 0) const SizedBox(height: 5),
                    TPText(
                      text: paragraph,
                      size: 14,
                      color: Colors.black,
                      weight: FontWeight.w400,
                      maxLines: 2,
                      align: TextAlign.left,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const Positioned(
          top: 0,
          left: 132,
          width: 67,
          height: 67,
          child: TPImg(name: '$_tpMidAssets/tp_onboarding_06_guide_avatar.png'),
        ),
      ],
    );
  }
}

class _TPOnboardingBonusGuide extends StatelessWidget {
  const _TPOnboardingBonusGuide();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 22,
            right: 23,
            top: 369,
            height: 172,
            child: _TPOnboardingGuideCard(
              title: 'Claim Your First Bonus',
              paragraphs: [
                'Your first reward from advertisers is here.\nTap to claim it now!',
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _tpRewardFlightMilliseconds = 1500;

class _TPOnboardingSponsorReward extends StatefulWidget {
  const _TPOnboardingSponsorReward({required this.onNext});

  final VoidCallback onNext;

  @override
  State<_TPOnboardingSponsorReward> createState() =>
      _TPOnboardingSponsorRewardState();
}

class _TPOnboardingSponsorRewardState extends State<_TPOnboardingSponsorReward>
    with SingleTickerProviderStateMixin {
  static const _cardLeft = 22.0;
  static const _cardTop = 431.0;
  static const _cashBounds = Rect.fromLTWH(132, 28, 65, 64);

  late final AnimationController _flight;

  @override
  void initState() {
    super.initState();
    _flight = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _tpRewardFlightMilliseconds),
      animationBehavior: AnimationBehavior.preserve,
    );
    _flight
      ..addListener(_onFlightTick)
      ..forward();
  }

  void _onFlightTick() {
    if (_flight.value < _flight.upperBound) return;
    _flight.removeListener(_onFlightTick);
    widget.onNext();
  }

  @override
  void dispose() {
    _flight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: _cardLeft,
            right: 23,
            top: _cardTop,
            height: 203,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xFFF2F3F8),
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Stack(
                children: [
                  Positioned.fromRect(
                    rect: _cashBounds,
                    child: const TPImg(name: '$_tpHomeAssets/tp_home_cash.png'),
                  ),
                  const Positioned(
                    left: 102,
                    top: 102,
                    width: 126,
                    height: 49,
                    child: TPFitText(
                      span: TextSpan(
                        style: TextStyle(
                          color: Color(0xFF1D9C04),
                          fontWeight: FontWeight.w900,
                          fontSize: 40,
                        ),
                        children: [
                          TextSpan(text: r'$', style: TextStyle(fontSize: 24)),
                          TextSpan(text: ' 500'),
                        ],
                      ),
                      align: TextAlign.center,
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 157,
                    height: 20,
                    child: TPText(
                      text: 'Invested by advertisers',
                      size: 14,
                      color: Color(0xFF3A3C39),
                      weight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: _TPOnboardingRewardFlight(
              key: const ValueKey('tp-onboarding-reward-flight-7'),
              origin: _cashBounds.center.translate(_cardLeft, _cardTop),
              progress: _flight,
            ),
          ),
        ],
      ),
    );
  }
}

class _TPOnboardingRewardFlight extends StatelessWidget {
  const _TPOnboardingRewardFlight({
    super.key,
    required this.origin,
    required this.progress,
  });

  static const _billCount = 9;
  static const _stagger = 70;
  static const _fadeDuration = 70;
  static const _travelDuration =
      _tpRewardFlightMilliseconds - (_billCount - 1) * _stagger - _fadeDuration;
  static const _target = Offset(58, 145);

  final Offset origin;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return const SizedBox.expand();

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: progress,
        child: const TPImg(
          name: '$_tpMidAssets/tp_onboarding_07_cash_bill.png',
          fit: BoxFit.contain,
        ),
        builder: (context, artwork) {
          final elapsed = progress.value * _tpRewardFlightMilliseconds;
          final bills = <Widget>[];
          for (var index = 0; index < _billCount; index++) {
            final age = elapsed - index * _stagger;
            if (age <= 0 || age >= _travelDuration + _fadeDuration) continue;

            final flight = (age / _travelDuration).clamp(0.0, 1.0);
            final easedFlight = Curves.easeInOutSine.transform(flight);
            final direction = index.isEven ? 1.0 : -1.0;
            final sway = math.sin(math.pi * easedFlight) * direction;
            final center = Offset.lerp(
              origin,
              _target,
              easedFlight,
            )!.translate(sway * (12 + 5 * (index % 4)), 0);
            final size = 52 + 6.0 * (index % 3) - 24 * easedFlight;
            final entrance = (age / 85).clamp(0.0, 1.0);
            final exit = ((age - _travelDuration) / _fadeDuration).clamp(
              0.0,
              1.0,
            );

            bills.add(
              Positioned(
                key: ValueKey('tp-onboarding-reward-bill-$index'),
                left: center.dx - size / 2,
                top: center.dy - size / 2,
                width: size,
                height: size,
                child: Opacity(
                  opacity: entrance * (1 - exit),
                  child: Transform.rotate(angle: sway * .24, child: artwork),
                ),
              ),
            );
          }
          return Stack(fit: StackFit.expand, children: bills);
        },
      ),
    );
  }
}

class _TPOnboardingFirstReward extends StatelessWidget {
  const _TPOnboardingFirstReward({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned(
          left: 19,
          top: 170,
          width: 340,
          height: 340,
          child: TPOnboardingArtMotion(
            distance: 0,
            scale: .05,
            rotation: .04,
            period: Duration(milliseconds: 3000),
            child: TPImg(
              name: '$_tpMidAssets/tp_onboarding_08_reward_rays.png',
            ),
          ),
        ),
        const Positioned(
          left: 2,
          top: 306,
          width: 371,
          height: 337,
          child: TPImg(name: '$_tpMidAssets/tp_onboarding_08_reward_panel.png'),
        ),
        const Positioned(
          left: 98,
          top: 233.5,
          width: 166,
          height: 115.8,
          child: TPOnboardingArtMotion(
            distance: 4,
            scale: .025,
            child: TPImg(
              name: '$_tpMidAssets/tp_onboarding_08_reward_plant.png',
            ),
          ),
        ),
        const Positioned(
          left: 252,
          top: 242,
          width: 27.3,
          height: 30.4,
          child: TPOnboardingArtMotion(
            distance: 3,
            scale: .15,
            period: Duration(milliseconds: 1240),
            child: TPImg(
              name: '$_tpMidAssets/tp_onboarding_08_reward_star.png',
            ),
          ),
        ),
        const Positioned(
          left: 89.9,
          top: 290.6,
          width: 16.4,
          height: 18.7,
          child: TPOnboardingArtMotion(
            distance: 2,
            scale: .15,
            period: Duration(milliseconds: 1520),
            child: TPImg(
              name: '$_tpMidAssets/tp_onboarding_08_reward_star_small.png',
            ),
          ),
        ),
        const Positioned(
          left: 80.57,
          top: 248,
          width: 43.5,
          height: 41.9,
          child: TPOnboardingArtMotion(
            distance: 5,
            rotation: .12,
            child: TPImg(
              name: '$_tpMidAssets/tp_onboarding_08_reward_bill_left.png',
            ),
          ),
        ),
        const Positioned(
          left: 254,
          top: 274,
          width: 46,
          height: 31,
          child: TPOnboardingArtMotion(
            distance: 6,
            rotation: .10,
            period: Duration(milliseconds: 2100),
            child: TPImg(
              name: '$_tpMidAssets/tp_onboarding_08_reward_bill_right.png',
            ),
          ),
        ),
        const Positioned(
          left: 36,
          right: 36,
          top: 374,
          height: 28,
          child: TPText(
            text: 'Your First Reward Is In!',
            size: 22,
            color: Color(0xFF023D21),
            weight: FontWeight.w600,
          ),
        ),
        const Positioned(
          left: 37,
          right: 37,
          top: 412,
          height: 62,
          child: TPText(
            text: r'+ $500',
            size: 48,
            color: Color(0xFF08944E),
            weight: FontWeight.w900,
          ),
        ),
        const Positioned(
          left: 37,
          top: 491,
          width: 301,
          height: 53,
          child: _TPOnboardingRewardEstimate(),
        ),
        Positioned(
          left: 68,
          top: 564,
          width: 240,
          height: 55,
          child: _TPOnboardingMidAction(
            key: const ValueKey('tp-onboarding-next-8'),
            label: 'Click To Redeem',
            onTap: onNext,
            child: const TPOnboardingArtMotion(
              distance: 0,
              scale: .02,
              child: _TPOnboardingRedeemButton(),
            ),
          ),
        ),
      ],
    );
  }
}

class _TPOnboardingRewardEstimate extends StatelessWidget {
  const _TPOnboardingRewardEstimate();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEBFBE2),
        border: Border.all(color: const Color(0xFFD5EBCA)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          const Positioned(
            left: 10,
            top: 7,
            width: 184,
            height: 39,
            child: TPFitText(
              maxLines: 2,
              span: TextSpan(
                style: TextStyle(color: Color(0xFF265E44), fontSize: 14),
                children: [
                  TextSpan(text: 'Estimated '),
                  TextSpan(
                    text: r'$100',
                    style: TextStyle(
                      color: Color(0xFF0D673B),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(text: ' withdrawal\nwithin'),
                ],
              ),
            ),
          ),
          Positioned(
            left: 196,
            top: 14,
            width: 99,
            height: 26,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF03592D),
                border: Border.all(color: const Color(0xFF0FAE5E)),
                borderRadius: BorderRadius.circular(48),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TPImg(
                    name: '$_tpMidAssets/tp_onboarding_08_reward_clock.png',
                    size: 14,
                  ),
                  SizedBox(width: 5),
                  SizedBox(
                    width: 57,
                    child: TPText(
                      text: '24:36:56',
                      size: 14,
                      color: Colors.white,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TPOnboardingRedeemButton extends StatelessWidget {
  const _TPOnboardingRedeemButton();

  @override
  Widget build(BuildContext context) {
    const shape = BorderRadius.all(Radius.circular(75));
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        border: Border.all(color: const Color(0xFF0B8C4D)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7AD54C), Color(0xFF22A03F), Color(0xFF7AD54C)],
          stops: [0, .74, 1],
        ),
      ),
      child: const ClipRRect(
        borderRadius: shape,
        child: Stack(
          children: [
            Positioned(
              left: 5,
              right: 3,
              top: 3,
              height: 49,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(47)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF9FFE7), Color(0x00FFFAD5)],
                    stops: [0, .41],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 2,
              right: 2,
              bottom: 1,
              height: 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x0044FF00), Color(0xFF44FF00)],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: TPText(
                text: 'Click To Redeem',
                size: 22,
                color: Colors.white,
                weight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TPOnboardingRewardCallouts extends StatelessWidget {
  const TPOnboardingRewardCallouts({super.key});

  static const _leftWidth = 236.0;
  static const _rightWidth = 301.0;

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 0,
              top: 669,
              width: _leftWidth,
              height: 44,
              child: _TPOnboardingRewardCallout(
                panelKey: ValueKey('tp-onboarding-callout-left-8'),
                backgroundColor: Color(0xFFFCFCF5),
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(58),
                ),
                delay: Duration(milliseconds: 350),
                offset: Offset(-_leftWidth, 0),
                padding: EdgeInsets.only(left: 34, right: 8),
                span: TextSpan(
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  children: [
                    TextSpan(
                      text: "You're ",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: 'amazing!',
                      style: TextStyle(color: Color(0xFF05963F)),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 713,
              width: _rightWidth,
              height: 44,
              child: _TPOnboardingRewardCallout(
                panelKey: ValueKey('tp-onboarding-callout-right-8'),
                backgroundColor: Color(0xFF007830),
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(58),
                ),
                delay: Duration(milliseconds: 1100),
                offset: Offset(_rightWidth, 0),
                padding: EdgeInsets.only(left: 41, right: 16),
                span: TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(text: 'Earn '),
                    TextSpan(
                      text: r'$100',
                      style: TextStyle(
                        color: Color(0xFFFAE020),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' today for sure!'),
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

class _TPOnboardingRewardCallout extends StatelessWidget {
  const _TPOnboardingRewardCallout({
    required this.panelKey,
    required this.backgroundColor,
    required this.borderRadius,
    required this.delay,
    required this.offset,
    required this.padding,
    required this.span,
  });

  final Key panelKey;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final Duration delay;
  final Offset offset;
  final EdgeInsets padding;
  final TextSpan span;

  @override
  Widget build(BuildContext context) {
    return _TPOnboardingTimedReveal(
      delay: delay,
      offset: offset,
      child: DecoratedBox(
        key: panelKey,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: Padding(
          padding: padding,
          child: TPFitText(span: span),
        ),
      ),
    );
  }
}

class _TPOnboardingTimedReveal extends StatelessWidget {
  const _TPOnboardingTimedReveal({
    required this.delay,
    required this.offset,
    required this.child,
  });

  final Duration delay;
  final Offset offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    const revealDuration = Duration(milliseconds: 550);
    final duration = delay + revealDuration;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Interval(
        delay.inMilliseconds / duration.inMilliseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: offset * (1 - value), child: child),
      ),
    );
  }
}

class _TPOnboardingWithdrawalQuiz extends StatelessWidget {
  const _TPOnboardingWithdrawalQuiz();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 22,
            right: 23,
            top: 43,
            height: 204,
            child: _TPOnboardingGuideCard(
              title: 'Unlock Withdrawal Access',
              paragraphs: [
                "Advertisers need a quick check to confirm you're real.",
                'Pass 3 easy questions and move closer to cashing out!',
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TPOnboardingScanPreview extends StatelessWidget {
  const _TPOnboardingScanPreview({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _TPOnboardingInterlude(
      duration: const Duration(seconds: 4),
      onNext: onNext,
      builder: (context, advance) => Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 68,
            top: 191,
            width: 238,
            height: 238.5,
            child: _TPOnboardingMidAction(
              key: const ValueKey('tp-onboarding-next-10'),
              label: 'Continue verification preview',
              onTap: advance,
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: _TPOnboardingRotateAsset(
                      period: Duration(milliseconds: 2100),
                      child: TPImg(
                        name: '$_tpMidAssets/tp_onboarding_10_scan_rings.png',
                      ),
                    ),
                  ),
                  Positioned(
                    top: 44,
                    left: 74,
                    width: 90,
                    height: 150,
                    child: TPOnboardingArtMotion(
                      distance: 2,
                      scale: .02,
                      child: TPImg(
                        name: '$_tpMidAssets/tp_onboarding_10_scan_phone.png',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final (index, (label, iconOffset, icon)) in const [
            ('No high-risk VPN detected', Offset.zero, _TPOnboardingScanTick()),
            ('No root access detected', Offset(2, 3), _TPOnboardingScanTick()),
            (
              'Not using an emulator',
              Offset(3, 6),
              _TPOnboardingRotateAsset(
                period: Duration(milliseconds: 1050),
                child: TPImg(
                  name: '$_tpMidAssets/tp_onboarding_10_scan_spinner.png',
                ),
              ),
            ),
          ].indexed)
            Positioned(
              left: 60,
              right: 12,
              top: 466 + index * 49,
              height: 38,
              child: _TPOnboardingTimedReveal(
                delay: Duration(milliseconds: 350 + index * 750),
                offset: const Offset(0, 8),
                child: Stack(
                  children: [
                    Positioned(
                      left: iconOffset.dx,
                      top: iconOffset.dy,
                      width: 30,
                      height: 30,
                      child: icon,
                    ),
                    Positioned(
                      left: 54,
                      right: 0,
                      top: 5,
                      height: 23,
                      child: TPText(
                        text: label,
                        size: 16,
                        color: Colors.white,
                        weight: FontWeight.w400,
                        align: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TPOnboardingScanTick extends StatelessWidget {
  const _TPOnboardingScanTick();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF17BB00),
      ),
      child: Center(
        child: SizedBox(
          width: 16.85,
          height: 12,
          child: TPImg(name: '$_tpMidAssets/tp_onboarding_10_scan_tick.png'),
        ),
      ),
    );
  }
}

class _TPOnboardingRotateAsset extends StatefulWidget {
  const _TPOnboardingRotateAsset({required this.period, required this.child});

  final Duration period;
  final Widget child;

  @override
  State<_TPOnboardingRotateAsset> createState() =>
      _TPOnboardingRotateAssetState();
}

class _TPOnboardingRotateAssetState extends State<_TPOnboardingRotateAsset>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turns = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _turns.stop();
      _turns.value = 0;
    } else if (!_turns.isAnimating) {
      _turns.repeat();
    }
  }

  @override
  void dispose() {
    _turns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(turns: _turns, child: widget.child);
  }
}

class _TPOnboardingInterlude extends StatefulWidget {
  const _TPOnboardingInterlude({
    required this.duration,
    required this.onNext,
    required this.builder,
  });

  final Duration duration;
  final VoidCallback onNext;
  final Widget Function(BuildContext context, VoidCallback advance) builder;

  @override
  State<_TPOnboardingInterlude> createState() => _TPOnboardingInterludeState();
}

class _TPOnboardingInterludeState extends State<_TPOnboardingInterlude> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, _advance);
  }

  void _advance() {
    final timer = _timer;
    if (timer == null) return;
    timer.cancel();
    _timer = null;
    widget.onNext();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _advance);
}
