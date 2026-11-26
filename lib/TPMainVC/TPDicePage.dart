import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spine_flutter/spine_flutter.dart'
    show RawBounds, SpineWidgetController;

import '../TPBase/TPMainTabViewport.dart';
import '../TPTool/TPImg.dart';
import '../TPTool/TPResponsive.dart';
import '../TPTool/TPSpineWidget.dart';
import '../TPTool/TPText.dart';

const _tpDiceAsset = 'assets/image/dice/tp_dice_';
const _tpDiceBrown = Color(0xFF491008);
const _tpDiceGreen = Color(0xFF0FA669);

class TPDicePage extends StatefulWidget {
  const TPDicePage({super.key, this.onHome, this.showGuideDie = false});

  final VoidCallback? onHome;
  final bool showGuideDie;

  @override
  State<TPDicePage> createState() => _TPDicePageState();
}

class _TPDicePageState extends State<TPDicePage>
    with SingleTickerProviderStateMixin {
  final _random = math.Random();
  late final AnimationController _roll = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..addStatusListener(_onRollStatus);
  SpineWidgetController? _spine;
  int _throwsLeft = 3;
  int? _selectedTile;

  void _onRollStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    setState(() {
      _spine?.pause();
      _spine = null;
    });
  }

  void _throwDice() {
    if (_roll.isAnimating) return;
    if (_throwsLeft == 0) {
      widget.onHome?.call();
      return;
    }

    final animate = !MediaQuery.disableAnimationsOf(context);
    setState(() {
      _throwsLeft--;
      _selectedTile = _random.nextInt(_TPDiceBoard.tileCount);
      _spine = animate && !kIsWeb && Platform.isAndroid
          ? SpineWidgetController()
          : null;
    });
    if (animate) _roll.forward(from: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isVisible = TickerMode.valuesOf(context).enabled;
    final spine = _spine;
    if (spine == null || spine.isPlaying == isVisible) return;
    if (isVisible) {
      spine.resume();
    } else {
      spine.pause();
    }
  }

  @override
  void dispose() {
    _spine?.pause();
    _roll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rolling = _roll.isAnimating;
    return TPMainTabViewport(
      scrollKey: const PageStorageKey('tp-dice-scroll'),
      child: SizedBox(
        height: 713,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 9,
              width: 56,
              height: 50,
              child: Semantics(
                label: 'Home',
                button: true,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    key: const ValueKey('tp-dice-home'),
                    onTap: widget.onHome,
                    borderRadius: BorderRadius.circular(14),
                    child: const Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: TPImg(
                          name: '${_tpDiceAsset}home.png',
                          width: 41,
                          height: 38,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 53,
              left: 8,
              width: 359,
              height: 80,
              child: Semantics(
                header: true,
                image: true,
                label: 'Lucky dice',
                child: const TPImg(name: '${_tpDiceAsset}title.png'),
              ),
            ),
            const Positioned(
              top: 141,
              left: 36,
              width: 303,
              height: 37,
              child: _TPDiceOffer(),
            ),
            Positioned(
              top: 136,
              left: 0,
              width: 375,
              height: 432,
              child: _TPDiceBoard(
                highlight: rolling ? null : _selectedTile,
                rollingDie: rolling
                    ? _TPDiceRollingDie(animation: _roll, spine: _spine)
                    : widget.showGuideDie
                    ? const Center(
                        child: TPImg(
                          name: '${_tpDiceAsset}roll_die.png',
                          width: 123,
                          height: 132,
                          fit: BoxFit.contain,
                        ),
                      )
                    : null,
              ),
            ),
            Positioned(
              top: 527,
              left: 133,
              width: 104,
              height: 48,
              child: _TPDiceThrowCount(count: _throwsLeft),
            ),
            Positioned(
              top: 576,
              left: 78,
              width: 219,
              height: 73,
              child: _TPDiceThrowButton(
                onTap: rolling || (_throwsLeft == 0 && widget.onHome == null)
                    ? null
                    : _throwDice,
                title: _throwsLeft == 0 && !rolling ? 'Find it' : 'Throw',
              ),
            ),
            const Positioned(
              top: 654,
              left: 20,
              right: 20,
              height: 30,
              child: TPFitText(
                align: TextAlign.center,
                span: TextSpan(
                  style: TextStyle(
                    color: _tpDiceBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(text: 'Just '),
                    TextSpan(
                      text: '\$0.05',
                      style: TextStyle(color: _tpDiceGreen),
                    ),
                    TextSpan(text: ' To Pagbank Withdrawal'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TPDiceBackdrop extends StatelessWidget {
  const TPDiceBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF473BD6), Color(0xFFFFC7B1), Colors.white],
          stops: [0, .4, .94],
        ),
      ),
      child: TPMainTabBackdrop(
        backgroundColor: Colors.transparent,
        child: _TPDiceBackdropArt(),
      ),
    );
  }
}

class _TPDiceBackdropArt extends StatelessWidget {
  const _TPDiceBackdropArt();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        fit: StackFit.expand,
        children: [
          const TPImg(name: '${_tpDiceAsset}sky.png'),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: constraints.maxWidth * 156 / 375,
            child: const TPImg(name: '${_tpDiceAsset}footer_money.png'),
          ),
        ],
      ),
    );
  }
}

class _TPDiceOffer extends StatelessWidget {
  const _TPDiceOffer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFAEFDC),
        border: Border.all(color: const Color(0xFFFBF6B5), width: 2),
        borderRadius: BorderRadius.circular(70),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: TPFitText(
          align: TextAlign.center,
          span: TextSpan(
            style: TextStyle(
              color: _tpDiceBrown,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: '12.12',
                style: TextStyle(color: Color(0xFFFF6A00)),
              ),
              TextSpan(text: ' Super Easy Withdrawal '),
              TextSpan(
                text: '\$50!',
                style: TextStyle(color: _tpDiceGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TPDiceBoard extends StatelessWidget {
  const _TPDiceBoard({required this.highlight, this.rollingDie});

  static const _tiles = <(int, int)>[
    (0, 0),
    (0, 1),
    (0, 2),
    (0, 3),
    (1, 3),
    (2, 3),
    (3, 3),
    (3, 2),
    (3, 1),
    (3, 0),
    (2, 0),
    (1, 0),
  ];
  static const _tileTop = [110.0, 178.43, 247.8, 317.18];
  static int get tileCount => _tiles.length;

  final int? highlight;
  final Widget? rollingDie;

  @override
  Widget build(BuildContext context) {
    final die = rollingDie;
    return Stack(
      children: [
        const Positioned.fill(child: TPImg(name: '${_tpDiceAsset}board.png')),
        Positioned(
          left: 44,
          top: 104,
          width: 287,
          height: 280,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: const RadialGradient(
                radius: .76,
                colors: [
                  Color(0xFF700D0D),
                  Color(0xFF700D0D),
                  Color(0xFF983316),
                ],
                stops: [0, .78, 1],
              ),
            ),
          ),
        ),
        for (final (index, (row, column)) in _tiles.indexed)
          Positioned(
            top: _tileTop[row],
            left: 53 + 69.38 * column,
            width: 59.87,
            height: 58.92,
            child: _TPDiceTile(highlighted: index == highlight),
          ),
        Positioned(
          top: 171,
          left: 116,
          width: 141,
          height: 143,
          child: die ?? const TPImg(name: '${_tpDiceAsset}wheel.png'),
        ),
        if (die == null)
          const Positioned(
            top: 297,
            left: 126,
            width: 123,
            height: 14,
            child: _TPDiceWheelProgress(),
          ),
      ],
    );
  }
}

class _TPDiceTile extends StatelessWidget {
  const _TPDiceTile({required this.highlighted});

  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFFEEA0) : const Color(0xFFFFF9EB),
        borderRadius: BorderRadius.circular(8),
        border: highlighted
            ? Border.all(color: const Color(0xFFFFB23A), width: 2)
            : null,
        boxShadow: const [
          BoxShadow(color: Color(0xFFAE3226), offset: Offset(0, 1)),
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.only(top: 7, bottom: 5),
        child: Column(
          children: [
            TPImg(name: '${_tpDiceAsset}tile_money.png', size: 26),
            Expanded(
              child: TPText(
                text: '\$80',
                size: 16,
                color: Color(0xFF119560),
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TPDiceWheelProgress extends StatelessWidget {
  const _TPDiceWheelProgress();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF270808),
        border: Border.all(color: const Color(0xFFFCAE03)),
        borderRadius: BorderRadius.circular(84),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 2,
            left: 2,
            width: 77,
            height: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFC2955), Color(0xFFF7FB03)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const Positioned(
            top: 3,
            left: 5,
            width: 71,
            height: 3,
            child: TPImg(name: '${_tpDiceAsset}shine.png'),
          ),
          const Positioned.fill(
            child: TPText(
              text: '2/3',
              size: 12,
              color: Colors.white,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TPDiceThrowCount extends StatelessWidget {
  const _TPDiceThrowCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 4,
          left: 6,
          width: 98,
          height: 32,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFED269),
              border: Border.all(color: const Color(0xFFFFF948), width: 2),
              borderRadius: BorderRadius.circular(56),
            ),
          ),
        ),
        const Positioned(
          top: -3,
          left: 0,
          width: 45,
          height: 48,
          child: TPImg(name: '${_tpDiceAsset}die.png'),
        ),
        Positioned(
          top: 4,
          left: 49,
          width: 26,
          height: 32,
          child: TPText(
            text: '$count',
            size: 20,
            color: const Color(0xFF5B1606),
            weight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TPDiceThrowButton extends StatelessWidget {
  const _TPDiceThrowButton({required this.onTap, required this.title});

  final VoidCallback? onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: const ValueKey('tp-dice-throw'),
        borderRadius: BorderRadius.circular(36),
        onTap: onTap,
        child: Stack(
          children: [
            const Positioned.fill(
              child: TPImg(name: '${_tpDiceAsset}button.png'),
            ),
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              height: 38,
              child: TPFitText(
                align: TextAlign.center,
                span: TextSpan(
                  text: title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TPDiceRollingDie extends StatelessWidget {
  const _TPDiceRollingDie({required this.animation, required this.spine});

  static const _spinePath = 'assets/spine/touz';
  static final _bounds = RawBounds(-355, -355, 725, 802);

  final Animation<double> animation;
  final SpineWidgetController? spine;

  @override
  Widget build(BuildContext context) {
    final placeholder = AnimatedBuilder(
      animation: animation,
      child: const TPImg(
        name: '${_tpDiceAsset}roll_die.png',
        width: 123,
        height: 132,
      ),
      builder: (context, child) => Center(
        child: Transform.rotate(
          angle: math.sin(animation.value * math.pi * 4) * .42,
          child: child,
        ),
      ),
    );
    final controller = spine;
    return controller == null
        ? placeholder
        : TPSpineWidget.fromAsset(
            '$_spinePath/skeleton.atlas.txt',
            '$_spinePath/skeleton.skel.bytes',
            controller,
            boundsProvider: _bounds,
            placeholder: placeholder,
            onLoaded: (drawable) {
              drawable.animationState.setAnimationByName(0, 'animation', false);
              drawable.update(0);
            },
          );
  }
}
