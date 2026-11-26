import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../TPTool/TPImg.dart';

const _tpOnboardingDesignSize = Size(375, 812);

class TPOnboardingStage extends StatelessWidget {
  const TPOnboardingStage({
    super.key,
    required this.backgroundColor,
    required this.child,
    this.backdrop,
    this.edgeOverlay,
  });

  final Color backgroundColor;
  final Widget child;
  final Widget? backdrop;
  final Widget? edgeOverlay;

  @override
  Widget build(BuildContext context) {
    final statusBar = MediaQuery.viewPaddingOf(context).top;
    final stage = Stack(
      fit: StackFit.expand,
      children: [
        if (backdrop case final artwork?)
          IgnorePointer(child: ExcludeSemantics(child: artwork)),
        SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const maximumScale = 1.2;
              final designScale = math.min(
                maximumScale,
                math.min(
                  constraints.maxWidth / _tpOnboardingDesignSize.width,
                  constraints.maxHeight / _tpOnboardingDesignSize.height,
                ),
              );
              final inset = math.max(0.0, statusBar - 40 * designScale);
              final availableHeight = constraints.maxHeight - inset;
              final scale = math.min(
                designScale,
                availableHeight / _tpOnboardingDesignSize.height,
              );
              if (scale <= 0) return const SizedBox.shrink();

              final width = _tpOnboardingDesignSize.width * scale;
              final height = _tpOnboardingDesignSize.height * scale;
              final top = inset + (availableHeight - height) / 2;

              Widget scaleCanvas(double designWidth, Widget content) =>
                  FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox(
                      width: designWidth,
                      height: _tpOnboardingDesignSize.height,
                      child: ClipRect(child: content),
                    ),
                  );

              return Stack(
                children: [
                  Positioned(
                    left: (constraints.maxWidth - width) / 2,
                    top: top,
                    width: width,
                    height: height,
                    child: scaleCanvas(_tpOnboardingDesignSize.width, child),
                  ),
                  if (edgeOverlay case final overlay?)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: top,
                      height: height,
                      child: IgnorePointer(
                        child: scaleCanvas(
                          constraints.maxWidth / scale,
                          overlay,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
    return backgroundColor.a == 0
        ? stage
        : ColoredBox(color: backgroundColor, child: stage);
  }
}

class TPOnboardingGuideMask extends StatelessWidget {
  const TPOnboardingGuideMask({
    super.key,
    required this.step,
    required this.onNext,
  });

  final int step;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    const balance = Rect.fromLTWH(10, 73, 350, 102);
    const tree = Rect.fromLTWH(89, 208, 198, 201);
    const bonus = Rect.fromLTWH(10, 265, 66, 63);
    const quizBoard = Rect.fromLTWH(8, 263, 360, 462);
    const milestones = Rect.fromLTWH(13, 197, 349, 54);
    const firstMilestone = Rect.fromLTWH(44, 195, 74, 77);
    const die = Rect.fromLTWH(119, 351, 136, 136);
    const quiz = Rect.fromLTWH(274, 179, 66, 65);
    final (Rect, String)? action = switch (step) {
      6 => (bonus, 'First bonus'),
      12 => (firstMilestone, 'Quiz milestone'),
      13 => (die, 'Dice bonus'),
      16 => (quiz.inflate(5), 'Open Quiz'),
      _ => null,
    };
    final (Rect, String)? pointer = switch (step) {
      6 => (
        const Rect.fromLTWH(37, 309, 57.37, 51.04),
        'assets/image/onboarding/06_10/tp_onboarding_06_tap_hand.png',
      ),
      12 => (
        const Rect.fromLTWH(61, 227, 57.37, 51.04),
        'assets/image/onboarding/11_16/hand.png',
      ),
      16 => (
        const Rect.fromLTWH(302, 217, 57.37, 51.04),
        'assets/image/onboarding/11_16/hand.png',
      ),
      _ => null,
    };
    final cutouts = switch (step) {
      5 => [(tree, 46.0)],
      6 => [(bonus, 29.0)],
      7 => [(balance, 12.0), (tree, 46.0)],
      8 => [(balance, 12.0)],
      9 => [(quizBoard, 24.0)],
      12 => [(milestones, 22.0)],
      13 => [(die, 68.0)],
      16 => [(balance, 12.0), (quiz, 28.0)],
      _ => <(Rect, double)>[],
    };
    final padding = MediaQuery.paddingOf(context);
    final portrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    return LayoutBuilder(
      builder: (context, constraints) {
        const designWidth = 375.0;
        final safeWidth = constraints.maxWidth - padding.horizontal;
        final scale = math.min(safeWidth, 450.0) / designWidth;
        final left = padding.left + (safeWidth - designWidth * scale) / 2;
        final top = math.max(padding.top, portrait ? 40.0 : 0.0) - 40 * scale;

        Rect map(Rect rect) => Rect.fromLTWH(
          left + rect.left * scale,
          top + rect.top * scale,
          rect.width * scale,
          rect.height * scale,
        );

        final viewport = Offset.zero & constraints.biggest;
        final interactive = step == 9
            ? map(quizBoard).intersect(
                Rect.fromLTRB(
                  viewport.left,
                  viewport.top,
                  viewport.right,
                  viewport.bottom - padding.bottom - 59,
                ),
              )
            : null;
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _TPOnboardingMaskPainter(
                holes: [
                  for (final (rect, radius) in cutouts)
                    RRect.fromRectAndRadius(
                      map(rect),
                      Radius.circular(radius * scale),
                    ),
                ],
                interactive: interactive,
              ),
            ),
            if (step == 16)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  onTap: onNext,
                ),
              ),
            if (action case (final rect, final label))
              Positioned.fromRect(
                rect: map(rect),
                child: Semantics(
                  label: label,
                  button: true,
                  child: GestureDetector(
                    key: ValueKey('tp-onboarding-next-$step'),
                    behavior: HitTestBehavior.opaque,
                    onTap: onNext,
                  ),
                ),
              ),
            if (pointer case (final rect, final asset))
              Positioned.fromRect(
                rect: map(rect),
                child: IgnorePointer(
                  child: TPOnboardingArtMotion(
                    distance: 5 * scale,
                    rotation: .08,
                    child: TPImg(name: asset, fit: BoxFit.contain),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TPOnboardingMaskPainter extends CustomPainter {
  const _TPOnboardingMaskPainter({required this.holes, this.interactive});

  final List<RRect> holes;
  final Rect? interactive;

  @override
  void paint(Canvas canvas, Size size) {
    final mask = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    for (final hole in holes) {
      mask.addRRect(hole);
    }
    canvas.drawPath(mask, Paint()..color = const Color(0xBF000000));
  }

  @override
  bool hitTest(Offset position) => !(interactive?.contains(position) ?? false);

  @override
  bool shouldRepaint(_TPOnboardingMaskPainter oldDelegate) =>
      oldDelegate.holes != holes;
}

class TPOnboardingArtMotion extends StatefulWidget {
  const TPOnboardingArtMotion({
    super.key,
    required this.child,
    this.distance = 5,
    this.scale = 0.04,
    this.rotation = 0,
    this.period = const Duration(milliseconds: 1700),
  });

  final Widget child;
  final double distance;
  final double scale;
  final double rotation;
  final Duration period;

  @override
  State<TPOnboardingArtMotion> createState() => _TPOnboardingArtMotionState();
}

class _TPOnboardingArtMotionState extends State<TPOnboardingArtMotion>
    with SingleTickerProviderStateMixin {
  late final _motion = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.stop();
      _motion.value = 0;
    } else if (!_motion.isAnimating) {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _motion,
    child: widget.child,
    builder: (context, child) {
      final angle = _motion.value * 2 * math.pi;
      final breath = (1 - math.cos(angle)) / 2;
      return Transform.translate(
        offset: Offset(0, -widget.distance * breath),
        child: Transform.rotate(
          angle: widget.rotation * math.sin(angle),
          child: Transform.scale(
            scale: 1 + widget.scale * breath,
            child: child,
          ),
        ),
      );
    },
  );
}
