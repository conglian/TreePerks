import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Shared launch timing; accessibility animation settings must not shorten it.
class TPLaunchController extends AnimationController {
  static const debugDuration = Duration(seconds: 3);
  static const releaseDuration = Duration(seconds: 12);

  TPLaunchController({required super.vsync, bool isDebug = kDebugMode})
    : super(
        duration: isDebug ? debugDuration : releaseDuration,
        animationBehavior: AnimationBehavior.preserve,
      );
}
