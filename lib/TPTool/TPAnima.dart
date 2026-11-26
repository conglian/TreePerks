import 'package:flutter/animation.dart';

class TPAnima {
  late final AnimationController controller;
  late final Animation<double> animation;

  TPAnima({
    required TickerProvider vsync,
    double begin = 0,
    double end = 1,
    Curve curve = Curves.linear,
    Duration? duration,
    Function(double)? valueCall,
    Function()? completedCall,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
    animation = Tween<double>(
      begin: begin,
      end: end,
    ).chain(CurveTween(curve: curve)).animate(controller);

    controller.addListener(() {
      valueCall?.call(getValue());
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        completedCall?.call();
      }
    });
  }

  double getValue() => animation.value;

  void setDuration(Duration duration) {
    controller.duration = duration;
    controller.stop();
  }

  void stop() {
    controller.stop();
  }

  Future<void> forward([double from = 0]) => controller.forward(from: from);

  Future<void> repeat([bool reverse = false]) =>
      controller.repeat(reverse: reverse);

  void reset() => controller.reset();

  void dispose() {
    controller.dispose();
  }
}
