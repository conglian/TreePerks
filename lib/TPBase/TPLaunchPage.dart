import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../TPTool/TPImg.dart';
import '../TPTool/TPInitSdk.dart';
import '../TPTool/TPLogger.dart';
import '../TPTool/TPText.dart';
import 'TPLaunchArtwork.dart';
import 'TPLaunchController.dart';

enum _TPLaunchPhase { restoring, start, progress }

class TPLaunchPage extends StatefulWidget {
  const TPLaunchPage({
    super.key,
    required this.onCompleted,
    this.onPrivacyPolicy,
    this.onUserAgreement,
  });

  final VoidCallback onCompleted;
  final VoidCallback? onPrivacyPolicy;
  final VoidCallback? onUserAgreement;

  @override
  State<TPLaunchPage> createState() => _TPLaunchPageState();
}

class _TPLaunchPageState extends State<TPLaunchPage>
    with SingleTickerProviderStateMixin {
  static const _designWidth = 375.0;
  static const _designHeight = 812.0;
  static const _touchTarget = 48.0;
  static const _legalLabel = 'Privacy Policy & User Agreement';
  static const _legalColor = Color(0xFFC5C5C5);
  static const _startAcceptedKey = 'tp_launch_start_accepted';

  late final TPLaunchController _progress;
  _TPLaunchPhase _phase = _TPLaunchPhase.restoring;
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    _progress = TPLaunchController(vsync: this)
      ..addStatusListener(_onProgressStatus);
    unawaited(_restoreStartChoice());
  }

  Future<void> _restoreStartChoice() async {
    var accepted = false;
    try {
      final preferences = await SharedPreferences.getInstance();
      accepted = preferences.getBool(_startAcceptedKey) ?? false;
    } catch (error, stackTrace) {
      ASLogger.instance.error(
        'Unable to restore the launch start choice',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (!mounted) return;
    if (accepted) {
      _beginProgress();
    } else {
      setState(() => _phase = _TPLaunchPhase.start);
    }
  }

  void _start() {
    if (!_agreed || _phase != _TPLaunchPhase.start) return;
    _beginProgress();
    unawaited(_saveStartChoice());
  }

  void _beginProgress() {
    setState(() => _phase = _TPLaunchPhase.progress);
    _progress.forward();
    unawaited(TPSDKHelpers().initSDK());
  }

  Future<void> _saveStartChoice() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!await preferences.setBool(_startAcceptedKey, true)) {
        ASLogger.instance.warning('Unable to save the launch start choice');
      }
    } catch (error, stackTrace) {
      ASLogger.instance.error(
        'Unable to save the launch start choice',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _onProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) widget.onCompleted();
  }

  void _toggleAgreement() => setState(() => _agreed = !_agreed);

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Scaffold(
      backgroundColor: const Color(0xFF104118),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const TPImg(
            name: 'assets/image/tp_launch_background.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            top: false,
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                final scale = math.min(
                  1.35,
                  math.min(width / _designWidth, height / _designHeight),
                );
                if (scale <= 0) return const SizedBox.shrink();
                final letterbox = (height - _designHeight * scale) / 2;
                final consentBottom = math.max(
                  bottomInset,
                  letterbox + 34 * scale,
                );
                final controlsLift = consentBottom - letterbox - 34 * scale;
                final consentHeight = math.max(_touchTarget, 44 * scale);
                final consentWidth = math.min(
                  width,
                  math.max(258.0, 273 * scale),
                );
                final loadingLabelWidth = math.min(
                  width,
                  math.max(136.0, 120 * scale),
                );

                return Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: _designWidth * scale,
                        height: _designHeight * scale,
                        child: const FittedBox(
                          child: SizedBox(
                            width: _designWidth,
                            height: _designHeight,
                            child: IgnorePointer(child: TPLaunchArtwork()),
                          ),
                        ),
                      ),
                    ),
                    if (_phase == _TPLaunchPhase.progress) ...[
                      Positioned(
                        top: letterbox + 660 * scale - controlsLift,
                        left: (width - 299 * scale) / 2,
                        width: 300 * scale,
                        child: AnimatedBuilder(
                          animation: _progress,
                          builder: (context, child) => LinearProgressIndicator(
                            value: _progress.value,
                            minHeight: math.max(5, 7 * scale),
                            backgroundColor: const Color(0xFF0C300D),
                            color: const Color(0xFF1EFF00),
                            borderRadius: BorderRadius.circular(4),
                            trackGap: 0,
                            stopIndicatorRadius: 0,
                            semanticsLabel: 'Loading',
                          ),
                        ),
                      ),
                      Positioned(
                        top: letterbox + 682 * scale - controlsLift,
                        left: (width - loadingLabelWidth) / 2 + 5 * scale,
                        width: loadingLabelWidth,
                        height: math.max(16, 18 * scale),
                        child: TPText(
                          text: 'Loading...',
                          size: math.max(13, 15 * scale),
                          color: Colors.white,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ] else if (_phase == _TPLaunchPhase.start) ...[
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: math.max(
                          letterbox + 123 * scale + controlsLift,
                          consentBottom + consentHeight + 8,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: math.max(156, 244 * scale),
                            height: math.max(_touchTarget, 59 * scale),
                            child: _TPStartButton(
                              fontSize: math.max(18, 22 * scale),
                              onPressed: _agreed ? _start : null,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: (width - consentWidth) / 2 + 3 * scale,
                        bottom: consentBottom,
                        width: consentWidth,
                        height: consentHeight,
                        child: Row(
                          children: [
                            SizedBox.square(
                              dimension: consentHeight,
                              child: _buildAgreementCheckbox(
                                math.max(22, 22 * scale),
                              ),
                            ),
                            SizedBox(width: 9 * scale),
                            Expanded(
                              child: _buildLegalLinks(math.max(13, 14 * scale)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementCheckbox(double size) {
    return Semantics(
      key: const ValueKey('tp_launch_consent'),
      label: _legalLabel,
      checked: _agreed,
      onTap: _toggleAgreement,
      child: InkWell(
        onTap: _toggleAgreement,
        excludeFromSemantics: true,
        customBorder: const CircleBorder(),
        child: Center(
          child: TPImg(
            name: _agreed
                ? 'assets/image/tp_launch_agree_checked.png'
                : 'assets/image/tp_launch_agree_unchecked.png',
            size: size,
          ),
        ),
      ),
    );
  }

  Widget _buildLegalLinks(double fontSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          flex: 13,
          child: TPUnderlineTextButton(
            text: 'Privacy Policy',
            textColor: _legalColor,
            fontSize: fontSize,
            onPressed: widget.onPrivacyPolicy,
          ),
        ),
        SizedBox(
          width: fontSize + 4,
          child: TPText(
            text: '&',
            size: fontSize,
            color: _legalColor,
            weight: FontWeight.w400,
          ),
        ),
        Flexible(
          flex: 14,
          child: TPUnderlineTextButton(
            text: 'User Agreement',
            textColor: _legalColor,
            fontSize: fontSize,
            onPressed: widget.onUserAgreement,
          ),
        ),
      ],
    );
  }
}

class _TPStartButton extends StatelessWidget {
  const _TPStartButton({required this.onPressed, required this.fontSize});

  final VoidCallback? onPressed;
  final double fontSize;
  static const _radius = BorderRadius.all(Radius.circular(75));

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.72 : 1,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: _radius,
          boxShadow: [
            BoxShadow(
              color: Color(0x80000000),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: _radius,
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: _radius,
              border: Border.all(color: Colors.white, width: 2),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF27A3FD),
                  Color(0xFF1772FC),
                  Color(0xFF27A3FD),
                  Color(0xFF00F2FF),
                ],
                stops: [0, 0.74, 0.91, 1],
              ),
            ),
            child: Semantics(
              button: true,
              enabled: onPressed != null,
              child: InkWell(
                onTap: onPressed,
                borderRadius: _radius,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const Positioned(
                      left: 7,
                      right: 7,
                      top: 5,
                      bottom: 5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(47)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFE7F1FF), Color(0x00FFFAD5)],
                            stops: [0, 0.41],
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: TPText(
                        text: 'Start',
                        size: fontSize,
                        color: Colors.white,
                        weight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
