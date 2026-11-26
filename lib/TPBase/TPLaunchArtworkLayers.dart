part of 'TPLaunchArtwork.dart';

// Bounds and stacking order from the loading02 illustration in Figma.
const _tpLaunchArtworkLayers = <_TPLaunchLayer>[
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_glow.png',
    rect: Rect.fromLTWH(0.00, 115.50, 375.00, 430.00),
    motion: _TPLaunchMotion.glow,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_tree.png',
    rect: Rect.fromLTWH(56.70, 199.70, 250.60, 254.70),
    motion: _TPLaunchMotion.tree,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_wordmark.png',
    rect: Rect.fromLTWH(57.00, 383.00, 260.00, 87.00),
    motion: _TPLaunchMotion.wordmark,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_apple_1.png',
    rect: Rect.fromLTWH(283.00, 237.00, 43.00, 44.00),
    motion: _TPLaunchMotion.apple,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_apple_2.png',
    rect: Rect.fromLTWH(285.00, 349.75, 38.86, 39.36),
    motion: _TPLaunchMotion.apple,
    phase: 0.70,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_apple_3.png',
    rect: Rect.fromLTWH(39.00, 197.00, 73.59, 73.68),
    motion: _TPLaunchMotion.apple,
    phase: 1.40,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_apple_4.png',
    rect: Rect.fromLTWH(37.00, 301.00, 38.86, 38.91),
    motion: _TPLaunchMotion.apple,
    phase: 2.10,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_apple_5.png',
    rect: Rect.fromLTWH(70.00, 334.00, 48.33, 49.41),
    motion: _TPLaunchMotion.apple,
    phase: 2.80,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_leaf_1.png',
    rect: Rect.fromLTWH(316.31, 270.40, 26.38, 29.20),
    motion: _TPLaunchMotion.leaf,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_leaf_2.png',
    rect: Rect.fromLTWH(281.34, 327.45, 23.77, 26.27),
    motion: _TPLaunchMotion.leaf,
    phase: 0.86,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_leaf_3.png',
    rect: Rect.fromLTWH(42.00, 341.00, 24.69, 20.23),
    motion: _TPLaunchMotion.leaf,
    phase: 1.72,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_leaf_4.png',
    rect: Rect.fromLTWH(103.00, 192.00, 21.18, 25.20),
    motion: _TPLaunchMotion.leaf,
    phase: 2.58,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_star_1.png',
    rect: Rect.fromLTWH(249.00, 198.00, 35.00, 35.00),
    motion: _TPLaunchMotion.star,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_star_2.png',
    rect: Rect.fromLTWH(293.00, 299.00, 35.00, 35.00),
    motion: _TPLaunchMotion.star,
    phase: 1.23,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_star_3.png',
    rect: Rect.fromLTWH(42.00, 267.00, 29.00, 29.00),
    motion: _TPLaunchMotion.star,
    phase: 2.46,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_star_4.png',
    rect: Rect.fromLTWH(115.00, 370.00, 27.00, 27.00),
    motion: _TPLaunchMotion.star,
    phase: 3.69,
  ),
  _TPLaunchLayer(
    name: 'assets/image/launch/tp_launch_star_5.png',
    rect: Rect.fromLTWH(254.00, 377.00, 25.00, 25.00),
    motion: _TPLaunchMotion.star,
    phase: 4.92,
  ),
];
