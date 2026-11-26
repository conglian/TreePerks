import 'dart:math' as math;

import 'package:flutter/material.dart';

const _tpTabDesignWidth = 375.0;
const _tpTabMaxWidth = 450.0;

class TPMainTabViewport extends StatelessWidget {
  const TPMainTabViewport({
    super.key,
    required this.child,
    this.backgroundColor,
    this.scrollKey,
  });

  final Widget child;
  final Color? backgroundColor;
  final Key? scrollKey;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          key: scrollKey,
          primary: false,
          child: Center(
            child: SizedBox(
              width: math.min(constraints.maxWidth, _tpTabMaxWidth),
              child: FittedBox(
                alignment: Alignment.topCenter,
                fit: BoxFit.fitWidth,
                child: SizedBox(width: _tpTabDesignWidth, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TPMainTabBackdrop extends StatelessWidget {
  const TPMainTabBackdrop({
    super.key,
    required this.backgroundColor,
    required this.child,
  });

  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: SizedBox(
            width: math.min(constraints.maxWidth, _tpTabMaxWidth),
            height: constraints.maxHeight,
            child: child,
          ),
        ),
      ),
    );
  }
}
