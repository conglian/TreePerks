import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treeperks/TPBase/TPLaunchController.dart';

void main() {
  for (final isDebug in [true, false]) {
    final seconds = isDebug ? 3 : 12;
    testWidgets('launch progress completes after $seconds seconds', (
      tester,
    ) async {
      final controller = TPLaunchController(vsync: tester, isDebug: isDebug);
      addTearDown(controller.dispose);
      controller.forward();
      await tester.pump();

      final halfway = Duration(milliseconds: seconds * 500);
      await tester.pump(halfway);
      expect(controller.value, closeTo(0.5, 0.001));
      expect(controller.status, AnimationStatus.forward);

      await tester.pump(halfway - const Duration(milliseconds: 1));
      expect(controller.isCompleted, isFalse);

      await tester.pump(const Duration(milliseconds: 1));
      expect(controller.value, 1);

      // Animation completion is reported on the following rendered frame.
      await tester.pump(const Duration(milliseconds: 16));
      expect(controller.status, AnimationStatus.completed);
    });
  }
}
