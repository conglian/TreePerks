import 'package:fl_toast/fl_toast.dart' as fl_toast;
import 'package:flutter/material.dart';

import '../TPTool/TPFonts.dart';
import 'TPAccountDialogs.dart';
import 'TPCashDialogs.dart';
import 'TPDiceDialogs.dart';
import 'TPEventDialogs.dart';
import 'TPQuizDialogs.dart';
import 'TPRewardDialogs.dart';

/// 各组弹窗的展示入口，调用方指定初始状态。
class TPDialogs {
  const TPDialogs._();

  static Future<void> showToast(BuildContext context, String message) =>
      fl_toast.showToast(
        context: context,
        duration: const Duration(milliseconds: 2500),
        animationBuilder: (_, animation, child) => IgnorePointer(
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Semantics(
            liveRegion: true,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: TPFonts.family,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );

  static Future<void> showAccount(
    BuildContext context,
    TPAccountDialogKind kind,
  ) => _show(
    context,
    kind,
    (kind, close, _) => TPAccountDialog(kind: kind, onClose: close),
    scrim: (kind) => kind == TPAccountDialogKind.rankedApple
        ? const Color(0xD9000000)
        : const Color(0xBF000000),
  );

  static Future<void> showDice(BuildContext context, TPDiceDialogKind kind) =>
      _show(
        context,
        kind,
        (kind, close, next) =>
            TPDiceDialog(kind: kind, onClose: close, onNext: next),
        background: (kind) =>
            kind == TPDiceDialogKind.notEnoughDice ? null : _wheelBackdrop,
      );

  static Future<void> showQuiz(BuildContext context, TPQuizDialogKind kind) =>
      _show(
        context,
        kind,
        (kind, close, next) =>
            TPQuizDialog(kind: kind, onClose: close, onNext: next),
        scrim: (kind) => switch (kind) {
          TPQuizDialogKind.continueQuiz => Colors.transparent,
          TPQuizDialogKind.bonusTip => const Color(0xCC000000),
          _ => const Color(0xBF000000),
        },
      );

  static Future<void> showEvent(BuildContext context, TPEventDialogKind kind) =>
      _show(
        context,
        kind,
        (kind, close, next) =>
            TPEventDialog(kind: kind, onClose: close, onNext: next),
        scrim: (kind) => switch (kind) {
          TPEventDialogKind.almostThere ||
          TPEventDialogKind.almostThereAlternate ||
          TPEventDialogKind.redAppleMilestone ||
          TPEventDialogKind.goldenAppleMilestone ||
          TPEventDialogKind.leaderboardEarnings => const Color(0xD9000000),
          _ => const Color(0xBF000000),
        },
      );

  static Future<void> showReward(
    BuildContext context,
    TPRewardDialogKind kind,
  ) => _show(
    context,
    kind,
    (kind, close, next) =>
        TPRewardDialog(kind: kind, onClose: close, onNext: next),
    background: (kind) =>
        kind == TPRewardDialogKind.wheelExit ? _wheelBackdrop : null,
    contentKey: (kind) => kind == TPRewardDialogKind.flipCardOpened
        ? TPRewardDialogKind.flipCard
        : kind,
  );

  static Future<void> showCash(BuildContext context, TPCashDialogKind kind) =>
      _show(
        context,
        kind,
        (kind, close, next) =>
            TPCashDialog(kind: kind, onClose: close, onNext: next),
        scrim: (kind) => switch (kind) {
          TPCashDialogKind.withdrawalReceipt ||
          TPCashDialogKind.payoutAccountVerification => const Color(0xD9000000),
          _ => const Color(0xBF000000),
        },
        contentKey: (kind) => kind == TPCashDialogKind.applicationQueued
            ? TPCashDialogKind.applicationProgress
            : kind,
      );

  static const _wheelBackdrop = IgnorePointer(
    child: ExcludeSemantics(child: TPDiceWheelBackdrop()),
  );

  static Future<void> _show<T extends Enum>(
    BuildContext context,
    T kind,
    _TPDialogBuilder<T> builder, {
    Color Function(T kind)? scrim,
    Widget? Function(T kind)? background,
    T Function(T kind)? contentKey,
  }) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);
    return showGeneralDialog<void>(
      context: context,
      transitionDuration: duration,
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) => _TPDialogFlow<T>(
        initialKind: kind,
        builder: builder,
        scrim: scrim,
        background: background,
        contentKey: contentKey,
      ),
    );
  }
}

typedef _TPDialogBuilder<T extends Enum> =
    Widget Function(T kind, VoidCallback close, ValueChanged<T> next);

class _TPDialogFlow<T extends Enum> extends StatefulWidget {
  const _TPDialogFlow({
    required this.initialKind,
    required this.builder,
    this.scrim,
    this.background,
    this.contentKey,
  });

  final T initialKind;
  final _TPDialogBuilder<T> builder;
  final Color Function(T kind)? scrim;
  final Widget? Function(T kind)? background;
  final T Function(T kind)? contentKey;

  @override
  State<_TPDialogFlow<T>> createState() => _TPDialogFlowState<T>();
}

class _TPDialogFlowState<T extends Enum> extends State<_TPDialogFlow<T>> {
  late T _kind = widget.initialKind;

  void _close() {
    if (ModalRoute.isCurrentOf(context) == true) Navigator.of(context).pop();
  }

  void _next(T kind) {
    if (_kind != kind && ModalRoute.isCurrentOf(context) == true) {
      setState(() => _kind = kind);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ?widget.background?.call(_kind),
          ColoredBox(
            color: widget.scrim?.call(_kind) ?? const Color(0xBF000000),
          ),
          AnimatedSwitcher(
            duration: reducedMotion
                ? Duration.zero
                : const Duration(milliseconds: 210),
            layoutBuilder: (current, previous) => Stack(
              fit: StackFit.expand,
              children: [
                for (final child in previous)
                  IgnorePointer(child: ExcludeSemantics(child: child)),
                ?current,
              ],
            ),
            child: KeyedSubtree(
              key: ValueKey(widget.contentKey?.call(_kind) ?? _kind),
              child: widget.builder(_kind, _close, _next),
            ),
          ),
        ],
      ),
    );
  }
}
