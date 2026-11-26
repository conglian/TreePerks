import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spine_flutter/spine_flutter.dart' as runtime;
import 'package:spine_flutter/spine_widget.dart' as spine;

import 'TPLogger.dart';

/// 先完成资源加载，再挂载 Spine，页面快速切换时释放迟到的资源。
/// 保留项目原有动画与控制器，避免旧版本 Spine 加载后更新已销毁的页面。
class TPSpineWidget extends StatefulWidget {
  final String atlas;
  final String skeleton;
  final spine.SpineWidgetController controller;
  final BoxFit? fit;
  final Alignment? alignment;
  final spine.BoundsProvider? boundsProvider;
  final Widget placeholder;
  final void Function(runtime.SkeletonDrawable drawable)? onLoaded;

  TPSpineWidget.fromAsset(
    this.atlas,
    this.skeleton,
    this.controller, {
    Key? key,
    this.fit,
    this.alignment,
    this.boundsProvider,
    this.placeholder = const SizedBox.shrink(),
    this.onLoaded,
  }) : super(key: key ?? ValueKey((atlas, skeleton, controller)));

  @override
  State<TPSpineWidget> createState() => _TPSpineWidgetState();
}

class _TPSpineWidgetState extends State<TPSpineWidget> {
  static Future<void>? _androidInitialization;

  runtime.SkeletonDrawable? _drawable;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    runtime.SkeletonDrawable? drawable;
    try {
      if (!kIsWeb && Platform.isAndroid) {
        await (_androidInitialization ??= runtime.initSpineFlutter());
        if (!mounted) return;
      }
      drawable = await runtime.SkeletonDrawable.fromAsset(
        widget.atlas,
        widget.skeleton,
      );
      if (!mounted) {
        drawable.dispose();
        return;
      }
      widget.onLoaded?.call(drawable);
      setState(() => _drawable = drawable);
    } catch (error, stack) {
      drawable?.dispose();
      if (mounted) {
        ASLogger.instance.error(
          'Unable to load Spine animation ${widget.skeleton}',
          error: error,
          stackTrace: stack,
        );
      }
    }
  }

  @override
  void dispose() {
    _drawable?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _drawable == null
      ? widget.placeholder
      : spine.SpineWidget.fromDrawable(
          _drawable!,
          widget.controller,
          fit: widget.fit,
          alignment: widget.alignment,
          boundsProvider: widget.boundsProvider,
        );
}
