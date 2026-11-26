import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../TPDialog/TPAccountDialogs.dart';
import '../TPDialog/TPDialogs.dart';
import '../TPTool/TPImg.dart';
import '../TPTool/TPResponsive.dart';
import '../TPTool/TPStrokeText.dart';
import '../TPTool/TPText.dart';
import 'TPHomeTree.dart';

const _tpHomeIntroMilliseconds = 2400;
const _tpHomeBreathingMilliseconds = 2400;

class TPHomePage extends StatefulWidget {
  const TPHomePage({
    super.key,
    this.onDice,
    this.onQuiz,
    this.onCash,
    this.showTree = true,
  });

  final VoidCallback? onDice;
  final VoidCallback? onQuiz;
  final VoidCallback? onCash;
  final bool showTree;

  static const backgroundColor = Color(0xFFF4F5F9);

  @override
  State<TPHomePage> createState() => _TPHomePageState();
}

class _TPHomePageState extends State<TPHomePage> with TickerProviderStateMixin {
  late final _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _tpHomeIntroMilliseconds),
  );
  late final _breathing = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _tpHomeBreathingMilliseconds),
  );
  late final _balanceProgress = _intro.drive(
    CurveTween(
      curve: const Interval(
        240 / _tpHomeIntroMilliseconds,
        1128 / _tpHomeIntroMilliseconds,
        curve: Curves.easeOutCubic,
      ),
    ),
  );
  late final _rewardProgress = _intro.drive(
    CurveTween(
      curve: const Interval(
        300 / _tpHomeIntroMilliseconds,
        1200 / _tpHomeIntroMilliseconds,
        curve: Curves.easeOutCubic,
      ),
    ),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isVisible = TickerMode.valuesOf(context).enabled;
    if (MediaQuery.disableAnimationsOf(context)) {
      _intro.value = 1;
      _breathing.stop();
    } else if (!isVisible) {
      _intro.stop();
      _breathing.stop();
    } else {
      if (!_intro.isCompleted && !_intro.isAnimating) _intro.forward();
      if (!_breathing.isAnimating) _breathing.repeat();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _breathing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TPHomePage.backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          key: const PageStorageKey('tp-home-scroll'),
          child: Center(
            child: SizedBox(
              width: math.min(constraints.maxWidth, 450),
              child: FittedBox(
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 375,
                  child: Column(
                    children: [
                      TPHomeHeader(
                        onCash: widget.onCash,
                        progress: _balanceProgress,
                      ),
                      const SizedBox(height: 7),
                      _TPHomeGarden(
                        onDice: widget.onDice,
                        onQuiz: widget.onQuiz,
                        showTree: widget.showTree,
                        intro: _intro,
                        breathing: _breathing,
                      ),
                      _TPHomeReward(progress: _rewardProgress),
                      const SizedBox(height: 3),
                      const _TPHomePodium(),
                      const SizedBox(height: 5),
                      const _TPHomeRankRow(rank: 4),
                      const SizedBox(height: 5),
                      const _TPHomeRankRow(rank: 5),
                      const SizedBox(height: 5),
                      const _TPHomeRankRow(rank: 6),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _tpHomeAsset(String name) => 'assets/image/home/tp_home_$name.png';

class TPHomeHeader extends StatelessWidget {
  const TPHomeHeader({
    super.key,
    this.onCash,
    this.progress = const AlwaysStoppedAnimation<double>(1),
  });

  final VoidCallback? onCash;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(15, 3, 15, 5),
          child: Align(
            alignment: Alignment.centerRight,
            child: TPHomeSettings(),
          ),
        ),
        _TPHomeBalance(onCash: onCash, progress: progress),
      ],
    );
  }
}

class TPHomeSettings extends StatelessWidget {
  const TPHomeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF818DA3);
    const radius = BorderRadius.all(Radius.circular(47));
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        width: 84,
        height: 25,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE7E9EF)),
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Semantics(
          button: true,
          child: InkWell(
            borderRadius: radius,
            onTap: () =>
                TPDialogs.showAccount(context, TPAccountDialogKind.settings),
            child: Row(
              children: [
                const SizedBox(width: 5),
                TPImg(name: _tpHomeAsset('setting'), size: 14),
                const SizedBox(width: 10),
                const Expanded(
                  child: TPText(
                    text: 'Setting',
                    size: 12,
                    color: color,
                    weight: FontWeight.w500,
                    align: TextAlign.start,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TPHomeBalance extends StatelessWidget {
  const _TPHomeBalance({required this.onCash, required this.progress});

  final VoidCallback? onCash;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(12));
    return SizedBox(
      width: 375,
      height: 101,
      child: Stack(
        children: [
          Positioned(
            left: 15,
            top: 0,
            width: 345,
            height: 101,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  colors: [Color(0xFF286DF9), Color(0xFF0A48B2)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: TPImg(name: _tpHomeAsset('card_pattern')),
              ),
            ),
          ),
          Positioned(
            left: 11,
            top: 49,
            width: 6,
            height: 6,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: const ColoredBox(color: Color(0xFF16438D)),
            ),
          ),
          Positioned(
            left: 10,
            top: 10,
            width: 56,
            height: 42,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 2, 8, 4),
                child: TPImg(name: _tpHomeAsset('paypal')),
              ),
            ),
          ),
          const Positioned(
            left: 76,
            top: 17,
            width: 132,
            height: 34,
            child: TPFitText(
              span: TextSpan(
                style: TextStyle(color: Colors.white, height: 1),
                children: [
                  TextSpan(
                    text: '\$',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: '999.75',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 227,
            top: 16,
            width: 113,
            height: 30,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onCash,
                child: const TPText(
                  text: 'Withdraw',
                  size: 14,
                  color: Color(0xFF1361F7),
                  weight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            top: 60,
            height: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF0038A1),
                border: Border.all(color: const Color(0x40336ED4)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: AnimatedBuilder(
                animation: progress,
                builder: (context, child) {
                  final value = progress.value;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        key: const ValueKey('tp-home-balance-fill'),
                        left: 2,
                        width: 294 * value,
                        top: 2,
                        bottom: 2,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFF28BEF9),
                            borderRadius: BorderRadius.all(Radius.circular(37)),
                          ),
                        ),
                      ),
                      TPStrokeText(
                        text: '${(92 * value).round()}%',
                        size: 14,
                        color: Colors.white,
                        skColor: const Color(0xFF0038A1),
                        skWidth: 1,
                        weight: FontWeight.w500,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const Positioned(
            left: 24,
            top: 81,
            width: 289,
            height: 17,
            child: TPFitText(
              span: TextSpan(
                style: TextStyle(fontSize: 12, color: Color(0xFFF9F9F9)),
                children: [
                  TextSpan(text: 'Only '),
                  TextSpan(
                    text: '\$.025',
                    style: TextStyle(
                      color: Color(0xFFFFF600),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: ' more to withdraw \$1000 !'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TPHomeGarden extends StatelessWidget {
  const _TPHomeGarden({
    required this.onDice,
    required this.onQuiz,
    required this.showTree,
    required this.intro,
    required this.breathing,
  });

  final VoidCallback? onDice;
  final VoidCallback? onQuiz;
  final bool showTree;
  final Animation<double> intro;
  final Animation<double> breathing;

  static const _moneyColor = Color(0xFF0FA669);
  static const _firstBubbleDelay = 180;
  static const _bubbleStagger = 360;
  static const _bubbleEntranceDuration = 320;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final motion = Listenable.merge([intro, breathing]);

    Widget bubble({
      required int order,
      required double left,
      required double top,
      required _TPHomeShortcut child,
    }) {
      final delay = _firstBubbleDelay + order * _bubbleStagger;
      return Positioned(
        key: ValueKey('tp-home-bubble-$order'),
        left: left,
        top: top,
        child: reduceMotion
            ? child
            : AnimatedBuilder(
                animation: motion,
                child: child,
                builder: (context, child) {
                  final reveal =
                      ((intro.value * _tpHomeIntroMilliseconds - delay) /
                              _bubbleEntranceDuration)
                          .clamp(0.0, 1.0);
                  final rise = Curves.easeOutBack.transform(reveal);
                  final phase =
                      breathing.value -
                      (delay + _bubbleEntranceDuration) /
                          _tpHomeBreathingMilliseconds;
                  final breath = reveal == 1
                      ? (1 - math.cos(phase * 2 * math.pi)) / 2
                      : 0.0;

                  return IgnorePointer(
                    ignoring: reveal == 0,
                    child: Opacity(
                      opacity: Curves.easeOutCubic.transform(reveal),
                      child: Transform.translate(
                        offset: Offset(0, 14 * (1 - rise) - 1.8 * breath),
                        child: Transform.scale(
                          scale: 0.74 + 0.26 * rise + 0.075 * breath,
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
              ),
      );
    }

    return SizedBox(
      height: 225,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (showTree) ...const [
            Positioned(
              left: 139,
              top: 211,
              width: 108,
              height: 15,
              child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox.square(
                  dimension: 30,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0x33000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 91,
              top: 30,
              width: 194,
              height: 194,
              child: TPHomeTree(),
            ),
          ],
          bubble(
            order: 0,
            left: 31,
            top: 0,
            child: _TPHomeShortcut(
              icon: 'dice',
              iconSize: Size(30, 32),
              label: 'Lucky Dice',
              labelTop: 41,
              onTap: onDice,
            ),
          ),
          bubble(
            order: 1,
            left: 270,
            top: 0,
            child: _TPHomeShortcut(
              icon: 'quiz',
              iconSize: Size(29, 31),
              label: 'Quiz',
              labelTop: 44,
              onTap: onQuiz,
            ),
          ),
          bubble(
            order: 2,
            left: 6,
            top: 88,
            child: const _TPHomeShortcut(
              icon: 'cash',
              iconSize: Size(35, 34),
              label: '\$10',
              labelColor: _moneyColor,
              labelTop: 43,
              decoration: Positioned(
                left: 44,
                top: -1,
                child: _TPHomeAdBadge(),
              ),
            ),
          ),
          bubble(
            order: 3,
            left: 294,
            top: 79,
            child: const _TPHomeShortcut(
              icon: 'calendar',
              iconSize: Size(29, 30),
              decoration: _TPHomeCalendarDecoration(),
            ),
          ),
          bubble(
            order: 4,
            left: 35.5,
            top: 158,
            child: const _TPHomeShortcut(
              icon: 'cash',
              iconSize: Size(35, 34),
              opacity: 0.30,
              label: '\$50',
              labelColor: _moneyColor,
              labelTop: 42,
              decoration: Positioned(
                top: 24,
                left: 7,
                width: 59,
                child: TPText(
                  text: '12:00:05',
                  size: 10,
                  color: Color(0xFF1D1A32),
                  weight: FontWeight.w500,
                ),
              ),
            ),
          ),
          bubble(
            order: 5,
            left: 269,
            top: 158,
            child: const _TPHomeShortcut(
              icon: 'cash',
              iconSize: Size(35, 34),
              label: '\$80',
              labelColor: _moneyColor,
              labelTop: 44,
            ),
          ),
        ],
      ),
    );
  }
}

class _TPHomeShortcut extends StatelessWidget {
  const _TPHomeShortcut({
    required this.icon,
    required this.iconSize,
    this.label,
    this.labelColor = const Color(0xFF383F38),
    this.labelTop = 42,
    this.opacity = 1.0,
    this.decoration,
    this.onTap,
  });

  final String icon;
  final Size iconSize;
  final String? label;
  final Color labelColor;
  final double labelTop;
  final double opacity;
  final Widget? decoration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final art = SizedBox(
      width: 72,
      height: 68,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 7,
            top: 0,
            width: 58.33,
            height: 58.33,
            child: TPImg(name: _tpHomeAsset('button_back')),
          ),
          Positioned(
            left: (72 - iconSize.width) / 2,
            top: 29 - iconSize.height / 2 + 1,
            child: Opacity(
              opacity: opacity,
              child: TPImg(
                name: _tpHomeAsset(icon),
                width: iconSize.width,
                height: iconSize.height,
              ),
            ),
          ),
          if (label case final label?)
            Positioned(
              left: 0,
              right: 0,
              top: labelTop,
              child: TPText(
                text: label,
                size: 14,
                color: labelColor,
                weight: FontWeight.w500,
              ),
            ),
          ?decoration,
        ],
      ),
    );
    if (onTap == null) return art;

    return Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: art,
        ),
      ),
    );
  }
}

class _TPHomeCalendarDecoration extends StatelessWidget {
  const _TPHomeCalendarDecoration();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            left: 49,
            top: 4,
            child: TPImg(name: _tpHomeAsset('calendar_badge'), size: 20),
          ),
          Positioned(
            left: 7,
            top: 48,
            width: 58,
            height: 18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF1F1F1)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const TPFitText(
                align: TextAlign.center,
                span: TextSpan(
                  style: TextStyle(
                    color: Color(0xFF383F38),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(text: 'Day '),
                    TextSpan(
                      text: '01',
                      style: TextStyle(color: Color(0xFFFD6D28)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TPHomeAdBadge extends StatelessWidget {
  const _TPHomeAdBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 21,
      child: Stack(
        children: [
          TPImg(name: _tpHomeAsset('ad'), width: 22, height: 21),
          Positioned(
            left: 1,
            right: 1,
            bottom: 1,
            height: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 0.6),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(3),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF28B1E3), Color(0xFF00FFE5)],
                ),
              ),
              child: const TPText(
                text: 'AD',
                size: 10,
                color: Color(0xFF153842),
                weight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TPHomeReward extends StatelessWidget {
  const _TPHomeReward({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 59,
      child: Stack(
        children: [
          Positioned(
            left: 22,
            right: 22,
            top: 11,
            height: 47,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                border: Border.all(color: const Color(0xFFF5F6FB)),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 32,
            top: 24,
            width: 209,
            height: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFE3E7EF),
                borderRadius: BorderRadius.circular(39),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 15,
            width: 137,
            height: 21,
            child: AnimatedBuilder(
              animation: progress,
              child: TPImg(name: _tpHomeAsset('bird'), width: 17, height: 21),
              builder: (context, bird) {
                final value = progress.value;
                return Stack(
                  children: [
                    Positioned(
                      key: const ValueKey('tp-home-reward-fill'),
                      left: 9,
                      top: 10,
                      width: 124 * value,
                      height: 5,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFF10CF82),
                          borderRadius: BorderRadius.all(Radius.circular(41)),
                        ),
                      ),
                    ),
                    Positioned(
                      key: const ValueKey('tp-home-reward-bird'),
                      left: 120 * value,
                      top: 0,
                      child: bird!,
                    ),
                  ],
                );
              },
            ),
          ),
          const Positioned(
            left: 32,
            top: 37,
            width: 188,
            height: 17,
            child: TPFitText(
              span: TextSpan(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
                children: [
                  TextSpan(text: 'Collect  '),
                  TextSpan(
                    text: '65%',
                    style: TextStyle(
                      color: Color(0xFF129272),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: '  Golden Bird to claim your reward'),
                ],
              ),
            ),
          ),
          Positioned(
            left: 276,
            top: 0,
            child: TPImg(name: _tpHomeAsset('chest'), width: 56, height: 48),
          ),
          Positioned(
            left: 247,
            top: 40,
            width: 99,
            height: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFEED6FF),
                borderRadius: BorderRadius.circular(43),
              ),
              child: const TPText(
                text: 'Reward ready to claim',
                size: 8,
                color: Color(0xFF574762),
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TPHomePodium extends StatelessWidget {
  const _TPHomePodium();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 142,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 20,
            top: -3,
            child: TPImg(name: _tpHomeAsset('podium'), width: 337, height: 150),
          ),
          const Positioned(
            left: 24,
            top: 10,
            child: _TPHomePodiumPlayer(
              medal: 'silver',
              badgeOffset: 66.2,
              avatarOffset: 29,
              player: 'Player_LISA01',
              earning: '\$10',
              color: Color(0xFF1D5BBA),
              detailColor: Color(0xFF63626D),
            ),
          ),
          const Positioned(
            left: 136,
            top: 0,
            child: _TPHomePodiumPlayer(
              medal: 'gold',
              badgeOffset: 63.2,
              avatarOffset: 26,
              player: 'Player_LISA021',
              earning: '\$1000',
              color: Color(0xFFCF6001),
              detailColor: Color(0xFF8E4D1D),
            ),
          ),
          const Positioned(
            left: 248,
            top: 10,
            child: _TPHomePodiumPlayer(
              medal: 'bronze',
              badgeOffset: 68.2,
              avatarOffset: 29,
              player: 'Player_LISA01',
              earning: '\$10',
              color: Color(0xFFE94818),
              detailColor: Color(0xFF685349),
            ),
          ),
        ],
      ),
    );
  }
}

class _TPHomePodiumPlayer extends StatelessWidget {
  const _TPHomePodiumPlayer({
    required this.medal,
    required this.badgeOffset,
    required this.avatarOffset,
    required this.player,
    required this.earning,
    required this.color,
    required this.detailColor,
  });

  final String medal;
  final double badgeOffset;
  final double avatarOffset;
  final String player;
  final String earning;
  final Color color;
  final Color detailColor;

  @override
  Widget build(BuildContext context) {
    final ringColor = switch (medal) {
      'silver' => const Color(0xFF8EBBE4),
      'gold' => const Color(0xFFF9BB30),
      _ => const Color(0xFFED9A72),
    };
    return SizedBox(
      width: 105,
      height: 132,
      child: Stack(
        children: [
          Positioned(
            left: switch (medal) {
              'silver' => 8,
              'gold' => 7,
              _ => 5,
            },
            top: 5,
            child: TPImg(
              name: _tpHomeAsset('${medal}_medal'),
              width: 18,
              height: 25,
            ),
          ),
          Positioned(
            left: avatarOffset - 2,
            top: 14,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: ringColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: TPImg(name: _tpHomeAsset('${medal}_avatar'), size: 48),
            ),
          ),
          Positioned(
            left: badgeOffset,
            top: 48.2,
            child: TPImg(name: _tpHomeAsset('avatar_badge'), size: 20.6),
          ),
          Positioned(
            left: 3,
            right: 3,
            top: 76,
            height: 16,
            child: TPText(
              text: player,
              size: 12,
              color: color,
              weight: FontWeight.w500,
            ),
          ),
          Positioned(
            left: 3,
            right: 3,
            top: 98,
            height: 12,
            child: _TPHomeRankDetail(
              title: 'Total earning: ',
              value: earning,
              color: detailColor,
              valueColor: color,
              size: 9,
              align: TextAlign.center,
            ),
          ),
          Positioned(
            left: 3,
            right: 3,
            top: 111,
            height: 12,
            child: _TPHomeRankDetail(
              title: 'Ads watched: ',
              value: '50',
              color: detailColor,
              valueColor: color,
              size: 9,
              align: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _TPHomeRankRow extends StatelessWidget {
  const _TPHomeRankRow({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 331,
      height: 49,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFDFE),
        border: Border.all(color: const Color(0xFFF5F6FB)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 5,
            width: 26,
            top: 0,
            bottom: 0,
            child: TPFitText(
              align: TextAlign.center,
              span: TextSpan(
                text: '$rank',
                style: const TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF52505C),
                ),
              ),
            ),
          ),
          Positioned(
            left: 38,
            top: 4,
            child: TPImg(name: _tpHomeAsset('rank_avatar'), size: 40),
          ),
          const Positioned(
            left: 88,
            right: 119,
            top: 4,
            height: 15,
            child: TPText(
              text: 'Player_LISA01',
              size: 12,
              color: Color(0xFF353441),
              weight: FontWeight.w500,
              align: TextAlign.start,
            ),
          ),
          const Positioned(
            left: 88,
            right: 119,
            top: 19,
            height: 11,
            child: _TPHomeRankDetail(title: 'Total earning: ', value: '\$10'),
          ),
          const Positioned(
            left: 88,
            right: 119,
            top: 30,
            height: 11,
            child: _TPHomeRankDetail(title: 'Ads watched: ', value: '50'),
          ),
          Positioned(
            right: 12,
            top: 12,
            width: 99,
            height: 24,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFEBF6EE),
                borderRadius: BorderRadius.circular(45),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TPImg(name: _tpHomeAsset('cash'), size: 16),
                  const SizedBox(width: 7),
                  const SizedBox(
                    width: 40,
                    child: TPText(
                      text: '+\$12.00',
                      size: 10,
                      color: Color(0xFF16B02E),
                      weight: FontWeight.bold,
                      align: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (rank == 4)
            Positioned(
              right: 4,
              top: 23,
              child: TPImg(
                name: _tpHomeAsset('rank_hand'),
                width: 33,
                height: 30,
              ),
            ),
        ],
      ),
    );
  }
}

class _TPHomeRankDetail extends StatelessWidget {
  const _TPHomeRankDetail({
    required this.title,
    required this.value,
    this.color = const Color(0xFF585863),
    this.valueColor = const Color(0xFF54555C),
    this.size = 8,
    this.align = TextAlign.start,
  });

  final String title;
  final String value;
  final Color color;
  final Color valueColor;
  final double size;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return TPFitText(
      align: align,
      span: TextSpan(
        style: TextStyle(color: color, fontSize: size),
        children: [
          TextSpan(text: title),
          TextSpan(
            text: value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
