import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spine_flutter/spine_flutter.dart';

import '../TPTool/TPImg.dart';
import '../TPTool/TPSpineWidget.dart';

class TPHomeTree extends StatefulWidget {
  const TPHomeTree({super.key});

  @override
  State<TPHomeTree> createState() => _TPHomeTreeState();
}

class _TPHomeTreeState extends State<TPHomeTree> {
  static const _treePath = 'assets/spine/app tree';
  static const _poster = TPImg(
    name: 'assets/image/home/tp_home_tree.png',
    fit: BoxFit.contain,
  );

  // Bounds of the full loop in Flutter's y-down coordinates.
  static final _bounds = RawBounds(-335, -362, 660, 722);

  final _controller = SpineWidgetController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final playing = TickerMode.valuesOf(context).enabled;
    if (playing == _controller.isPlaying) return;
    if (playing) {
      _controller.resume();
    } else {
      _controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb ||
        !Platform.isAndroid ||
        MediaQuery.disableAnimationsOf(context)) {
      return _poster;
    }

    return IgnorePointer(
      child: TPSpineWidget.fromAsset(
        '$_treePath/skeleton.atlas.txt',
        '$_treePath/skeleton.skel.bytes',
        _controller,
        boundsProvider: _bounds,
        placeholder: _poster,
        onLoaded: (drawable) {
          drawable.animationState.setAnimationByName(0, 'animation', true);
          drawable.update(0);
          if (drawable.render().isEmpty) {
            throw StateError('Home tree animation has no visible attachments');
          }
        },
      ),
    );
  }
}
