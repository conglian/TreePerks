import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../TPTool/TPLogger.dart';

class TPOnboardingManager extends ChangeNotifier {
  TPOnboardingManager({this.repeatAfterCompletion = true});

  static const firstStep = 1;
  static const lastStep = 16;
  static const progressKey = 'tp_onboarding_step';
  static const _finished = lastStep + 1;

  final bool repeatAfterCompletion;
  int? _position;
  bool _advancing = false;
  bool _disposed = false;

  int? get currentStep => isCompleted ? null : _position;
  bool get isCompleted => _position == _finished;

  Future<void> restore() async {
    var position = firstStep;
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getInt(progressKey);
      if (saved != null && saved >= firstStep && saved <= _finished) {
        position = saved;
      }
    } catch (error, stackTrace) {
      ASLogger.instance.error(
        'Unable to restore onboarding progress',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (_disposed) return;
    _position = position == _finished && repeatAfterCompletion
        ? firstStep
        : position;
    notifyListeners();
  }

  Future<bool> advance(int step) async {
    if (_disposed || _advancing || currentStep != step) return false;
    _advancing = true;
    final next = step + 1;

    try {
      final preferences = await SharedPreferences.getInstance();
      if (!await preferences.setInt(progressKey, next)) {
        ASLogger.instance.warning('Unable to save onboarding progress');
      }
    } catch (error, stackTrace) {
      ASLogger.instance.error(
        'Unable to save onboarding progress',
        error: error,
        stackTrace: stackTrace,
      );
    }

    _advancing = false;
    if (_disposed) return false;
    _position = next;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
