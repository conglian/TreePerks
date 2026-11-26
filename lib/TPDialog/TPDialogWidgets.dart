import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../TPTool/TPText.dart';

/// 弹窗与设计稿使用同一坐标系，按可用空间等比缩放。
class TPDialogStage extends StatelessWidget {
  const TPDialogStage({
    super.key,
    required this.children,
    this.alignment = Alignment.center,
  });

  static const designSize = Size(375, 812);

  final List<Widget> children;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        media.viewPadding.left,
        0,
        media.viewPadding.right,
        math.max(0, media.viewInsets.bottom - media.viewPadding.bottom),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = math.min(
            1.2,
            math.min(
              constraints.maxWidth / designSize.width,
              constraints.maxHeight / designSize.height,
            ),
          );
          if (scale <= 0) return const SizedBox.shrink();

          return Align(
            alignment: alignment,
            child: SizedBox(
              width: designSize.width * scale,
              height: designSize.height * scale,
              child: FittedBox(
                child: SizedBox.fromSize(
                  size: designSize,
                  child: Stack(fit: StackFit.expand, children: children),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum TPDialogEffect { pop, rise, fade, celebration }

/// 弹层入场动画，在系统要求减少动态效果时直接显示内容。
class TPDialogMotion extends StatefulWidget {
  const TPDialogMotion({
    super.key,
    required this.child,
    this.effect = TPDialogEffect.pop,
    this.delay = Duration.zero,
  });

  final Widget child;
  final TPDialogEffect effect;
  final Duration delay;

  @override
  State<TPDialogMotion> createState() => _TPDialogMotionState();
}

class _TPDialogMotionState extends State<TPDialogMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  bool? _reducedMotion;

  static const _motionDuration = Duration(milliseconds: 450);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (reducedMotion == _reducedMotion) return;
    _reducedMotion = reducedMotion;
    if (reducedMotion) {
      _controller.value = 1;
    } else if (!_controller.isCompleted) {
      _controller.duration = _motionDuration + widget.delay;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reducedMotion == true) return widget.child;
    final start =
        widget.delay.inMicroseconds /
        (_motionDuration + widget.delay).inMicroseconds;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final progress = ((_controller.value - start) / (1 - start)).clamp(
          0.0,
          1.0,
        );
        final eased = Curves.easeOutCubic.transform(progress);
        final scale = switch (widget.effect) {
          TPDialogEffect.pop =>
            .88 + .12 * Curves.easeOutBack.transform(progress),
          TPDialogEffect.celebration =>
            .72 + .28 * Curves.easeOutBack.transform(progress),
          _ => 1.0,
        };
        final startingOffset = switch (widget.effect) {
          TPDialogEffect.rise => 24.0,
          TPDialogEffect.celebration => 16.0,
          _ => 0.0,
        };
        return IgnorePointer(
          ignoring: progress == 0,
          child: Opacity(
            opacity: math.min(1, progress * 2.5),
            child: Transform.translate(
              offset: Offset(0, startingOffset * (1 - eased)),
              child: Transform.scale(scale: scale, child: child),
            ),
          ),
        );
      },
    );
  }
}

/// 入场后提示两次轻点。按压值在静止时为 0，触碰时为 1。
class TPDialogTapHint extends StatelessWidget {
  const TPDialogTapHint({
    super.key,
    required this.builder,
    this.delay = const Duration(milliseconds: 550),
  });

  static const _cycle = Duration(milliseconds: 650);
  static const _approach = Interval(0, .44, curve: Curves.easeInOutSine);
  static const _release = Interval(.5, 1, curve: Curves.easeOutCubic);

  final Widget Function(BuildContext context, double pressure) builder;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return builder(context, 0);

    const tapCount = 2;
    final cycleMicros = _cycle.inMicroseconds;
    final totalMicros = cycleMicros * tapCount.toDouble();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -delay.inMicroseconds.toDouble(), end: totalMicros),
      duration: delay + _cycle * tapCount,
      builder: (context, elapsed, _) {
        final phase =
            (elapsed.clamp(0.0, totalMicros) % cycleMicros) / cycleMicros;
        final pressure = _approach.transform(phase) - _release.transform(phase);
        return builder(context, pressure);
      },
    );
  }
}

enum TPDialogButtonStyle { blue, green, orange }

/// 弹窗确认按钮。具体视觉由所属画板的主题色决定。
class TPDialogButton extends StatelessWidget {
  const TPDialogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = TPDialogButtonStyle.blue,
    this.labelSize = 20,
  });

  final String label;
  final VoidCallback onPressed;
  final TPDialogButtonStyle style;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    final (top, middle, bottom, edge) = switch (style) {
      TPDialogButtonStyle.blue => (
        const Color(0xFF88DDFF),
        const Color(0xFF247CF5),
        const Color(0xFF015CF4),
        const Color(0xFF45DFFF),
      ),
      TPDialogButtonStyle.green => (
        const Color(0xFF9AEF35),
        const Color(0xFF299E0A),
        const Color(0xFF247415),
        const Color(0xFF99F02A),
      ),
      TPDialogButtonStyle.orange => (
        const Color(0xFFFFF28A),
        const Color(0xFFFFAA23),
        const Color(0xFFED610B),
        const Color(0xFFFFDB53),
      ),
    };
    final radius = BorderRadius.circular(32);
    return Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [top, middle, bottom],
              stops: const [0, .46, 1],
            ),
            borderRadius: radius,
            border: Border.all(color: edge, width: 2),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: Center(
                child: TPText(
                  text: label,
                  size: labelSize,
                  color: Colors.white,
                  weight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 带独立触摸区域的圆形关闭控件。
class TPDialogCloseButton extends StatelessWidget {
  const TPDialogCloseButton({
    super.key,
    required this.onPressed,
    this.color = Colors.white,
    this.diameter = 26,
  });

  final VoidCallback onPressed;
  final Color color;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        onPressed: onPressed,
        color: color,
        padding: EdgeInsets.zero,
        icon: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.4),
          ),
          child: SizedBox.square(
            dimension: diameter,
            child: Icon(Icons.close_rounded, size: diameter * 18 / 26),
          ),
        ),
      ),
    );
  }
}
