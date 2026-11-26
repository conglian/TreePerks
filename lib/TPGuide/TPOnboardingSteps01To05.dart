import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../TPTool/TPFonts.dart';
import '../TPTool/TPImg.dart';
import '../TPTool/TPResponsive.dart';
import '../TPTool/TPText.dart';
import 'TPOnboardingWidgets.dart';

const _tpIntroAssets = 'assets/image/onboarding/01_05/tp_intro_';
const _tpIntroBlue = Color(0xFF0B49B5);
const _tpIntroInk = Color(0xFF000000);
const _tpIntroGreen = Color(0xFF1D9C04);
const _tpIntroRevealStagger = 650;

class TPOnboardingSteps01To05 extends StatelessWidget {
  const TPOnboardingSteps01To05({
    super.key,
    required this.step,
    required this.onNext,
  });

  static const backdropAsset = '${_tpIntroAssets}backdrop.png';

  final int step;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (step == 5) {
      return _TPIntroCoach(onNext: onNext);
    }

    final title = switch (step) {
      1 => 'Where Does The Money Come\nFrom?',
      2 => 'Where Do Advertising Funds\nGo?',
      3 => 'Your Participation Creates\nValue',
      4 => 'You Can Withdraw',
      _ => throw ArgumentError.value(step, 'step'),
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 42,
          right: 42,
          top: 141,
          height: step == 4 ? 28 : 53,
          child: TPText(
            text: title,
            size: 20,
            color: _tpIntroInk,
            weight: FontWeight.w700,
            maxLines: 2,
          ),
        ),
        switch (step) {
          1 => const _TPIntroPartners(),
          2 => const _TPIntroComparison(),
          3 => const _TPIntroTasks(),
          _ => const _TPIntroEarnings(),
        },
        Positioned(
          left: 33,
          top: 720,
          width: 308,
          height: 52,
          child: _TPIntroAction(
            key: ValueKey('tp-onboarding-next-$step'),
            label: step == 4 ? 'Let’s Start Earning' : 'Continue',
            onPressed: onNext,
            size: step == 4 ? 18 : 20,
          ),
        ),
      ],
    );
  }
}

class _TPIntroImage extends StatelessWidget {
  const _TPIntroImage(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) =>
      TPImg(name: '$_tpIntroAssets$asset.png', fit: BoxFit.fill);
}

class _TPIntroAction extends StatelessWidget {
  const _TPIntroAction({
    super.key,
    required this.label,
    required this.onPressed,
    required this.size,
    this.gloss = false,
  });

  final String label;
  final VoidCallback onPressed;
  final double size;
  final bool gloss;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(56);
    return Material(
      borderRadius: radius,
      color: gloss ? Colors.transparent : _tpIntroBlue,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: gloss
            ? BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: const Color(0xFF82A2FF)),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF27A3FD),
                    Color(0xFF1772FC),
                    Color(0xFF238BFB),
                    Color(0xFF00E8FF),
                  ],
                  stops: [0, .64, .90, 1],
                ),
              )
            : null,
        child: InkWell(
          onTap: onPressed,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (gloss)
                Positioned(
                  left: 5,
                  right: 5,
                  top: 3,
                  height: 24,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFE7F1FF), Color(0x00FFFAD5)],
                      ),
                    ),
                  ),
                ),
              TPText(
                text: label,
                size: size,
                color: Colors.white,
                weight: gloss ? FontWeight.w800 : FontWeight.w500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TPIntroEntrance extends StatelessWidget {
  const _TPIntroEntrance({
    required this.child,
    this.delay = 0,
    this.revealMilliseconds = 520,
    this.opacityKey,
  });

  final Widget child;
  final int delay;
  final int revealMilliseconds;
  final Key? opacityKey;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Opacity(key: opacityKey, opacity: 1, child: child);
    }

    final duration = delay + revealMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: duration),
      curve: Interval(delay / duration, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, value, child) => Opacity(
        key: opacityKey,
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 9 * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}

class _TPIntroPartners extends StatelessWidget {
  const _TPIntroPartners();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 25,
          right: 0,
          top: 227,
          height: 45,
          child: _TPIntroBrandMarquee(
            key: ValueKey('tp-onboarding-brand-row-1'),
            asset: 'brands_a',
            artworkWidth: 374,
            duration: Duration(seconds: 11),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 282,
          height: 45,
          child: _TPIntroBrandMarquee(
            key: ValueKey('tp-onboarding-brand-row-2'),
            asset: 'brands_b',
            artworkWidth: 470,
            initialOffset: -18,
            scrollRight: true,
            duration: Duration(milliseconds: 12500),
          ),
        ),
        Positioned(
          left: 9,
          right: 0,
          top: 337,
          height: 45,
          child: _TPIntroBrandMarquee(
            key: ValueKey('tp-onboarding-brand-row-3'),
            asset: 'brands_c',
            artworkWidth: 374,
            duration: Duration(milliseconds: 9500),
          ),
        ),
        Positioned(
          left: 10,
          top: 432,
          width: 324,
          height: 78,
          child: _TPIntroEntrance(
            delay: 180,
            opacityKey: ValueKey('tp-onboarding-dialogue-1'),
            child: _TPIntroPartnerMessage(
              text:
                  'We have built deep partnerships\nwith many well-known brands and\nadvertisers.',
              asset: 'portrait_a',
              bubble: 'message_a',
              onRight: false,
            ),
          ),
        ),
        Positioned(
          left: 45,
          top: 535,
          width: 324,
          height: 78,
          child: _TPIntroEntrance(
            delay: 960,
            opacityKey: ValueKey('tp-onboarding-dialogue-2'),
            child: _TPIntroPartnerMessage(
              text:
                  'As a platform, we bring in a large\nvolume of high-quality\ncommercial content.',
              asset: 'portrait_b',
              bubble: 'message_b',
              onRight: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _TPIntroBrandMarquee extends StatefulWidget {
  const _TPIntroBrandMarquee({
    super.key,
    required this.asset,
    required this.artworkWidth,
    required this.duration,
    this.initialOffset = 0,
    this.scrollRight = false,
  });

  final String asset;
  final double artworkWidth;
  final Duration duration;
  final double initialOffset;
  final bool scrollRight;

  @override
  State<_TPIntroBrandMarquee> createState() => _TPIntroBrandMarqueeState();
}

class _TPIntroBrandMarqueeState extends State<_TPIntroBrandMarquee>
    with SingleTickerProviderStateMixin {
  static const _gap = 10.0;
  late final _animation = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.stop();
      _animation.value = 0;
    } else if (!_animation.isAnimating) {
      _animation.repeat();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cycleWidth = widget.artworkWidth + _gap;
    return ClipRect(
      child: AnimatedBuilder(
        animation: _animation,
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          maxWidth: cycleWidth * 2,
          child: RepaintBoundary(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var copy = 0; copy < 2; copy++) ...[
                  SizedBox(
                    width: widget.artworkWidth,
                    child: _TPIntroImage(widget.asset),
                  ),
                  const SizedBox(width: _gap),
                ],
              ],
            ),
          ),
        ),
        builder: (context, child) {
          final direction = widget.scrollRight ? 1 : -1;
          final phase =
              (widget.initialOffset +
                  direction * _animation.value * cycleWidth) %
              cycleWidth;
          final offset = phase == 0 ? 0.0 : phase - cycleWidth;
          return Transform.translate(offset: Offset(offset, 0), child: child);
        },
      ),
    );
  }
}

class _TPIntroPartnerMessage extends StatelessWidget {
  const _TPIntroPartnerMessage({
    required this.text,
    required this.asset,
    required this.bubble,
    required this.onRight,
  });

  final String text;
  final String asset;
  final String bubble;
  final bool onRight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: onRight ? 0 : 70,
          width: 254,
          height: 78,
          child: _TPIntroImage(bubble),
        ),
        Positioned(
          left: onRight ? 20 : 100,
          top: 12,
          width: 214,
          height: 54,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: TPFonts.family,
                fontSize: 14,
                color: _tpIntroInk,
                fontWeight: FontWeight.w400,
                height: 1.14,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        Positioned(
          left: onRight ? 264 : 0,
          top: 11,
          width: 60,
          height: 60,
          child: _TPIntroImage(asset),
        ),
      ],
    );
  }
}

class _TPIntroComparison extends StatelessWidget {
  const _TPIntroComparison();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 12,
          top: 228,
          width: 350,
          height: 140,
          child: _TPIntroEntrance(child: _TPIntroBalance()),
        ),
        Positioned(
          left: 25,
          top: 449,
          width: 162,
          height: 210,
          child: _TPIntroEntrance(
            opacityKey: ValueKey('tp-onboarding-comparison-left'),
            delay: 550,
            child: _TPIntroOtherCard(),
          ),
        ),
        Positioned(
          left: 187,
          top: 387,
          width: 162,
          height: 277,
          child: _TPIntroEntrance(
            opacityKey: ValueKey('tp-onboarding-comparison-right'),
            delay: 1450,
            child: _TPIntroOurCard(),
          ),
        ),
      ],
    );
  }
}

class _TPIntroBalance extends StatelessWidget {
  const _TPIntroBalance();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 5,
          top: 0,
          width: 345,
          height: 140,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF286DF9), Color(0xFF0A48B2)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: const Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 157,
                height: 140,
                child: TPImg(
                  name: 'assets/image/cash/tp_cash_paypal_watermark.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          left: 0,
          top: 10,
          width: 56,
          height: 42,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 38,
                height: 35.5,
                child: TPImg(
                  name: 'assets/image/home/tp_home_paypal.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          left: 1,
          top: 51,
          width: 4,
          height: 4,
          child: TPImg(
            name: 'assets/image/cash/tp_cash_header_tab_fold.png',
            fit: BoxFit.fill,
          ),
        ),
        const Positioned(
          left: 17,
          top: 69,
          width: 178,
          height: 42,
          child: TPText(
            text: r'$999.75',
            size: 36,
            color: Colors.white,
            weight: FontWeight.w700,
            align: TextAlign.start,
          ),
        ),
        const Positioned(
          left: 19,
          top: 111,
          width: 167,
          height: 21,
          child: TPText(
            text: 'ID：6666666666666666',
            size: 12,
            color: Color(0xFFF9F9F9),
            weight: FontWeight.w400,
            align: TextAlign.start,
          ),
        ),
      ],
    );
  }
}

class _TPIntroOtherCard extends StatelessWidget {
  const _TPIntroOtherCard();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 28,
          left: 0,
          right: 0,
          height: 181,
          child: _TPIntroImage('other_card_background'),
        ),
        Positioned(
          left: 11,
          top: 81,
          width: 141,
          height: 118,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0x00FFFFFF)],
              ),
            ),
          ),
        ),
        const Positioned(
          left: 56,
          top: 0,
          width: 50,
          height: 50,
          child: Stack(
            children: [
              Positioned.fill(child: _TPIntroImage('other_badge')),
              Positioned(
                left: 13,
                top: 13,
                width: 23.48,
                height: 23.125,
                child: _TPIntroImage('other_badge_sign'),
              ),
            ],
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          top: 52,
          height: 24,
          child: TPText(
            text: 'Other App',
            size: 16,
            color: Colors.white,
            weight: FontWeight.w700,
          ),
        ),
        const Positioned(
          left: 25,
          top: 89,
          width: 88,
          height: 23,
          child: _TPIntroImage('other_card_logo'),
        ),
        const Positioned(
          left: 25,
          top: 116,
          width: 90,
          height: 23,
          child: TPText(
            text: r'$*****',
            size: 16,
            color: Color(0xFFB9C9E0),
            weight: FontWeight.w500,
            align: TextAlign.start,
          ),
        ),
        const Positioned(
          left: 25,
          top: 141,
          width: 125,
          height: 46,
          child: TPText(
            text: 'Fake endless tasks\nunreachable\ncashout targets',
            size: 12,
            color: Color(0xFF7590B7),
            weight: FontWeight.w400,
            align: TextAlign.start,
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}

class _TPIntroOurCard extends StatelessWidget {
  const _TPIntroOurCard();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 25,
          height: 251,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 3),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF2FF35), Colors.white],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  offset: Offset(0, 4),
                  blurRadius: 10.6,
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          left: 56,
          top: 0,
          width: 50,
          height: 50,
          child: Stack(
            children: [
              Positioned.fill(child: _TPIntroImage('our_badge')),
              Positioned(
                left: 11,
                top: 17,
                width: 27.39,
                height: 19.51,
                child: _TPIntroImage('our_badge_sign'),
              ),
            ],
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          top: 56,
          height: 24,
          child: TPText(
            text: 'Our App',
            size: 16,
            color: _tpIntroInk,
            weight: FontWeight.w700,
          ),
        ),
        const Positioned(
          left: 28,
          top: 98,
          width: 116.5,
          height: 78,
          child: TPOnboardingArtMotion(
            distance: 3,
            scale: .025,
            rotation: .035,
            child: _TPIntroImage('our_card'),
          ),
        ),
        const Positioned(
          left: 12,
          right: 5,
          top: 202,
          height: 48,
          child: TPText(
            text:
                'Share real ad revenue.\nClear targets, guaranteed\nwithdrawable earnings.',
            size: 12,
            color: _tpIntroInk,
            weight: FontWeight.w400,
            align: TextAlign.start,
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}

class _TPIntroTasks extends StatelessWidget {
  const _TPIntroTasks();

  static const _reveal = 320;
  static const _taskStagger = 380;

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 18,
          top: 225,
          width: 339,
          height: 83,
          child: _TPIntroEntrance(
            revealMilliseconds: _reveal,
            child: _TPIntroTaskCard(
              kind: 0,
              title: 'Watch Short Videos',
              message: 'Browse Engaging Content,\nBoost Real Exposure.',
            ),
          ),
        ),
        Positioned(
          left: 22,
          top: 328,
          width: 339,
          height: 83,
          child: _TPIntroEntrance(
            delay: _taskStagger,
            revealMilliseconds: _reveal,
            child: _TPIntroTaskCard(
              kind: 1,
              title: 'Try New Games',
              message: 'Experience The Latest Titles,\nProvide Active Data.',
            ),
          ),
        ),
        Positioned(
          left: 22,
          top: 431,
          width: 339,
          height: 83,
          child: _TPIntroEntrance(
            delay: 2 * _taskStagger,
            revealMilliseconds: _reveal,
            child: _TPIntroTaskCard(
              kind: 2,
              title: 'More...',
              message: 'Waiting To Be Explored.',
            ),
          ),
        ),
        Positioned(
          left: 25,
          top: 542,
          width: 325,
          height: 115,
          child: _TPIntroEntrance(
            delay: 3 * _taskStagger,
            revealMilliseconds: _reveal,
            child: _TPIntroComment(
              asset: 'tasks_comment',
              text:
                  'Every task you complete in the app helps brands get more exposure and pays you rewards.',
            ),
          ),
        ),
      ],
    );
  }
}

class _TPIntroTaskCard extends StatelessWidget {
  const _TPIntroTaskCard({
    required this.kind,
    required this.title,
    required this.message,
  });

  final int kind;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final art = switch (kind) {
      0 => const _TPIntroImage('watch'),
      1 => const DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFDBD4FA),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(3, 4, 6, 6),
          child: _TPIntroImage('game'),
        ),
      ),
      _ => const _TPIntroImage('more'),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0F9DB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            left: switch (kind) {
              0 => 10,
              1 => 11,
              _ => 1,
            },
            top: switch (kind) {
              0 => 11,
              1 => 13,
              _ => 3,
            },
            width: switch (kind) {
              0 => 61.4,
              1 => 57.6,
              _ => 78.1,
            },
            height: switch (kind) {
              0 => 61.4,
              1 => 57.6,
              _ => 78.1,
            },
            child: art,
          ),
          Positioned(
            left: kind == 0 ? 86 : 82,
            right: 60,
            top: kind == 2 ? 21 : 12,
            height: 22,
            child: TPText(
              text: title,
              size: 16,
              color: _tpIntroInk,
              weight: FontWeight.w600,
              align: TextAlign.start,
            ),
          ),
          Positioned(
            left: kind == 0 ? 86 : 82,
            right: 61,
            top: kind == 2 ? 45 : 34,
            height: kind == 2 ? 17 : 33,
            child: TPText(
              text: message,
              size: 12,
              color: _tpIntroInk,
              weight: FontWeight.w400,
              align: TextAlign.start,
              maxLines: 2,
            ),
          ),
          Positioned(
            right: kind == 0 ? 16 : 20,
            top: 27,
            width: 30,
            height: 30,
            child: const _TPIntroImage('check'),
          ),
        ],
      ),
    );
  }
}

class _TPIntroComment extends StatelessWidget {
  const _TPIntroComment({required this.asset, required this.text});

  final String asset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _TPIntroImage(asset),
        Positioned(
          left: 17,
          right: 17,
          top: 13,
          bottom: 0,
          child: TPText(
            text: text,
            size: 16,
            color: _tpIntroInk,
            weight: FontWeight.w400,
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}

class _TPIntroEarnings extends StatelessWidget {
  const _TPIntroEarnings();

  static const _reveal = 340;

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 125,
          top: 189,
          width: 115,
          height: 44,
          child: _TPIntroWithdrawalAmount(),
        ),
        Positioned(
          left: 140,
          top: 414,
          width: 97,
          height: 18,
          child: _TPIntroImage('tree_shadow'),
        ),
        Positioned(
          left: 100,
          top: 259,
          width: 168,
          height: 168,
          child: TPOnboardingArtMotion(
            distance: 3.5,
            scale: .025,
            child: _TPIntroImage('gold_tree'),
          ),
        ),
        Positioned(
          left: 38,
          top: 376,
          width: 88,
          height: 88,
          child: TPOnboardingArtMotion(
            distance: 5,
            scale: .025,
            rotation: .06,
            child: _TPIntroImage('arrow_up'),
          ),
        ),
        Positioned(
          left: 238,
          top: 360,
          width: 120.9,
          height: 120.9,
          child: TPOnboardingArtMotion(
            distance: 5,
            scale: .025,
            rotation: .06,
            period: Duration(milliseconds: 2030),
            child: _TPIntroImage('arrow_down'),
          ),
        ),
        Positioned(
          left: 27,
          top: 466,
          width: 135.5,
          height: 84,
          child: _TPIntroEntrance(
            delay: 270,
            revealMilliseconds: _reveal,
            child: _TPIntroImage('video_reward'),
          ),
        ),
        Positioned(
          left: 211.6,
          top: 452,
          width: 143.1,
          height: 110.1,
          child: _TPIntroEntrance(
            delay: 650,
            revealMilliseconds: _reveal,
            child: _TPIntroImage('cash_reward'),
          ),
        ),
        Positioned(
          left: 25,
          top: 602,
          width: 325,
          height: 54.6,
          child: _TPIntroEntrance(
            delay: 1090,
            revealMilliseconds: _reveal,
            child: _TPIntroComment(
              asset: 'earnings_comment',
              text: 'Every click helps you earn cash.',
            ),
          ),
        ),
      ],
    );
  }
}

class _TPIntroWithdrawalAmount extends StatelessWidget {
  const _TPIntroWithdrawalAmount();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: 500),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 580),
      curve: Curves.easeOutCubic,
      builder: (context, amount, child) => TPFitText(
        align: TextAlign.center,
        span: TextSpan(
          style: const TextStyle(
            color: _tpIntroGreen,
            fontSize: 40,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
          children: [
            const TextSpan(text: r'$', style: TextStyle(fontSize: 24)),
            TextSpan(text: ' $amount'),
          ],
        ),
      ),
    );
  }
}

class _TPIntroCoach extends StatelessWidget {
  const _TPIntroCoach({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned(
          left: 0,
          right: 0,
          top: 70,
          height: 23,
          child: _TPIntroBulletinLane(
            key: ValueKey('tp-onboarding-bulletin-1'),
            textKey: ValueKey('tp-onboarding-bulletin-text-1'),
            initialLeft: 148,
            duration: Duration(milliseconds: 7200),
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          top: 133,
          height: 23,
          child: _TPIntroBulletinLane(
            key: ValueKey('tp-onboarding-bulletin-2'),
            textKey: ValueKey('tp-onboarding-bulletin-text-2'),
            initialLeft: -21,
            duration: Duration(milliseconds: 8400),
          ),
        ),
        Positioned(
          left: 22,
          top: 458,
          width: 330,
          height: 232,
          child: _TPIntroEntrance(
            delay: _tpIntroRevealStagger,
            child: _TPIntroCoachCard(onNext: onNext),
          ),
        ),
      ],
    );
  }
}

typedef _TPIntroBulletinData = ({String player, int amount});

class _TPIntroBulletinLane extends StatefulWidget {
  const _TPIntroBulletinLane({
    super.key,
    required this.textKey,
    required this.initialLeft,
    required this.duration,
  });

  final Key textKey;
  final double initialLeft;
  final Duration duration;

  @override
  State<_TPIntroBulletinLane> createState() => _TPIntroBulletinLaneState();
}

class _TPIntroBulletinLaneState extends State<_TPIntroBulletinLane>
    with SingleTickerProviderStateMixin {
  static const _pillWidth = 311.0;
  static const _travel = 480.0;
  static const _amounts = [100, 120, 150, 200];
  static const _characters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  static final _random = math.Random();

  late final _animation = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..addListener(_updateLap);
  _TPIntroBulletinData _current = _newBulletin();
  _TPIntroBulletinData _next = _newBulletin();
  int _lap = 0;

  static _TPIntroBulletinData _newBulletin() {
    final suffix = List.generate(
      6,
      (_) => _characters[_random.nextInt(_characters.length)],
    ).join();
    return (
      player: 'Player_$suffix',
      amount: _amounts[_random.nextInt(_amounts.length)],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.stop();
      _lap = 0;
      _animation.value = 0;
    } else if (!_animation.isAnimating) {
      _animation.repeat();
    }
  }

  void _updateLap() {
    final elapsed = _animation.lastElapsedDuration;
    if (elapsed == null) return;

    final lap = elapsed.inMicroseconds ~/ widget.duration.inMicroseconds;
    if (lap <= _lap) return;

    setState(() {
      // Keep the pill already entering the viewport as the leading message.
      _current = lap == _lap + 1 ? _next : _newBulletin();
      _next = _newBulletin();
      _lap = lap;
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return ClipRect(
      child: AnimatedBuilder(
        animation: _animation,
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          maxWidth: _travel + _pillWidth,
          child: RepaintBoundary(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: _pillWidth,
                  child: _TPIntroBulletinPill(
                    textKey: widget.textKey,
                    data: _current,
                  ),
                ),
                if (!reduceMotion) ...[
                  const SizedBox(width: _travel - _pillWidth),
                  SizedBox(
                    width: _pillWidth,
                    child: _TPIntroBulletinPill(data: _next),
                  ),
                ],
              ],
            ),
          ),
        ),
        builder: (context, child) => Transform.translate(
          offset: Offset(widget.initialLeft - _travel * _animation.value, 0),
          child: child,
        ),
      ),
    );
  }
}

class _TPIntroBulletinPill extends StatelessWidget {
  const _TPIntroBulletinPill({required this.data, this.textKey});

  final _TPIntroBulletinData data;
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(34),
        color: const Color(0xE6FFFFFF),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17),
        child: TPFitText(
          key: textKey,
          align: TextAlign.start,
          span: TextSpan(
            style: const TextStyle(fontSize: 12, color: Color(0xFF001500)),
            children: [
              TextSpan(
                text: data.player,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const TextSpan(text: '  got 10 right and earned '),
              TextSpan(
                text: '\$${data.amount}!',
                style: const TextStyle(
                  color: _tpIntroGreen,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TPIntroCoachCard extends StatelessWidget {
  const _TPIntroCoachCard({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 19,
          height: 53,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: const Color(0xFF3300CB),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 29,
          height: 203,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: const Color(0xFFF3F4F9),
            ),
          ),
        ),
        const Positioned(
          left: 133,
          top: 0,
          width: 67,
          height: 67,
          child: _TPIntroImage('coach'),
        ),
        const Positioned(
          left: 25,
          top: 65,
          width: 278,
          height: 24,
          child: TPText(
            text: "Hi, I'm Tom",
            size: 16,
            color: _tpIntroInk,
            weight: FontWeight.w500,
            align: TextAlign.start,
          ),
        ),
        const Positioned(
          left: 27,
          top: 100,
          width: 277,
          height: 45,
          child: TPFitText(
            maxLines: 2,
            span: TextSpan(
              style: TextStyle(color: _tpIntroInk, fontSize: 14, height: 1.12),
              children: [
                TextSpan(text: 'I earned '),
                TextSpan(
                  text: r'$200',
                  style: TextStyle(
                    color: _tpIntroGreen,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text:
                      ' from Advertisers this week.\nWant to know how I did it? Follow me!',
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 50,
          top: 158,
          width: 235,
          height: 55,
          child: _TPIntroAction(
            key: const ValueKey('tp-onboarding-next-5'),
            label: "Let's Go",
            onPressed: onNext,
            size: 22,
            gloss: true,
          ),
        ),
      ],
    );
  }
}
