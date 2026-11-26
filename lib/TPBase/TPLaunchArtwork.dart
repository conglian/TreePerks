import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../TPTool/TPImg.dart';

part 'TPLaunchArtworkLayers.dart';

enum _TPLaunchMotion { glow, tree, wordmark, apple, leaf, star }

class _TPLaunchLayer {
  const _TPLaunchLayer({
    required this.name,
    required this.rect,
    required this.motion,
    this.phase = 0,
  });

  final String name;
  final Rect rect;
  final _TPLaunchMotion motion;
  final double phase;
}

/// The individual Figma layers share a single clock across both launch states.
class TPLaunchArtwork extends StatefulWidget {
  const TPLaunchArtwork({super.key});

  @override
  State<TPLaunchArtwork> createState() => _TPLaunchArtworkState();
}

class _TPLaunchArtworkState extends State<TPLaunchArtwork>
    with SingleTickerProviderStateMixin {
  final _elapsed = ValueNotifier<Duration>(Duration.zero);
  late final Ticker _ticker;
  Duration _elapsedBeforeResume = Duration.zero;
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(
      (elapsed) => _elapsed.value = _elapsedBeforeResume + elapsed,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animate =
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        !MediaQuery.disableAnimationsOf(context);
    final routeIsCurrent = ModalRoute.isCurrentOf(context) ?? true;
    if (_animate && routeIsCurrent) {
      if (!_ticker.isActive) {
        _elapsedBeforeResume = _elapsed.value;
        _ticker.start();
      }
    } else if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          for (final layer in _tpLaunchArtworkLayers)
            Positioned.fromRect(rect: layer.rect, child: _buildLayer(layer)),
        ],
      ),
    );
  }

  Widget _buildLayer(_TPLaunchLayer layer) {
    final image = TPImg(name: layer.name);
    if (!_animate) return image;

    return ValueListenableBuilder<Duration>(
      valueListenable: _elapsed,
      child: image,
      builder: (context, elapsed, child) {
        final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
        final pose = _TPLaunchPose.at(layer, seconds);
        final transformed = Transform(
          alignment: pose.anchor,
          transform: Matrix4.identity()
            ..translateByDouble(pose.x, pose.y, 0, 1)
            ..rotateZ(pose.angle)
            ..scaleByDouble(pose.scaleX, pose.scaleY, 1, 1),
          child: child,
        );
        return pose.opacity == 1
            ? transformed
            : Opacity(opacity: pose.opacity, child: transformed);
      },
    );
  }
}

class _TPLaunchPose {
  const _TPLaunchPose({
    this.x = 0,
    this.y = 0,
    this.angle = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    this.opacity = 1,
    this.anchor = Alignment.center,
  });

  final double x;
  final double y;
  final double angle;
  final double scaleX;
  final double scaleY;
  final double opacity;
  final Alignment anchor;

  static _TPLaunchPose at(_TPLaunchLayer layer, double seconds) {
    // Fade the idle movement in so each layer begins at its design position.
    final idle = Curves.easeOut.transform((seconds / 0.7).clamp(0.0, 1.0));

    double wave(double period, [double offset = 0]) {
      return math.sin(seconds * 2 * math.pi / period + layer.phase + offset);
    }

    switch (layer.motion) {
      case _TPLaunchMotion.glow:
        final light = (1 + wave(4.8)) / 2 * idle;
        return _TPLaunchPose(
          scaleX: 1 + 0.012 * light,
          scaleY: 1 + 0.024 * light,
          opacity: 1 - 0.18 * light,
          anchor: Alignment.bottomCenter,
        );
      case _TPLaunchMotion.tree:
        final sway = wave(4.1) * idle;
        return _TPLaunchPose(
          angle: 0.029 * sway,
          scaleX: 1 + 0.009 * wave(3.3) * idle,
          scaleY: 1 + 0.022 * wave(3.3, 1.1) * idle,
          anchor: Alignment.bottomCenter,
        );
      case _TPLaunchMotion.wordmark:
        final entrance = Curves.easeOutBack.transform(
          (seconds / 0.8).clamp(0.0, 1.0),
        );
        final breath = wave(3.5) * idle;
        return _TPLaunchPose(
          y: 16 * (1 - entrance) - 2 * breath,
          scaleX: 0.81 + 0.19 * entrance + 0.014 * breath,
          scaleY: 0.81 + 0.19 * entrance + 0.025 * breath,
          anchor: Alignment.bottomCenter,
        );
      case _TPLaunchMotion.apple:
        final bob = wave(3.2) * idle;
        return _TPLaunchPose(
          x: 5 * wave(4.4) * idle,
          y: 12 * bob,
          angle: 0.09 * wave(3.2, 0.9) * idle,
        );
      case _TPLaunchMotion.leaf:
        return _TPLaunchPose(
          x: 7 * wave(4.6, 1.3) * idle,
          y: 6 * wave(3.8) * idle,
          angle: 0.24 * wave(3.1, 0.5) * idle,
        );
      case _TPLaunchMotion.star:
        final twinkle = wave(2.2) * idle;
        return _TPLaunchPose(
          scaleX: 1 + 0.21 * twinkle,
          scaleY: 1 + 0.21 * twinkle,
          opacity: 1 - 0.57 * (1 - wave(2.2)) / 2 * idle,
        );
    }
  }
}
