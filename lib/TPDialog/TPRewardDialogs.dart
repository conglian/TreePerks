import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:spine_flutter/spine_flutter.dart' as spine;

import '../TPTool/TPImg.dart';
import '../TPTool/TPResponsive.dart';
import '../TPTool/TPSpineWidget.dart';
import '../TPTool/TPText.dart';
import 'TPDialogWidgets.dart';

enum TPRewardDialogKind {
  /// 排行榜奖励，显示待打开的宝箱。
  rankClaim,

  /// 排行榜奖励，显示已打开的宝箱。
  rankClaimOpened,

  /// 退出幸运转盘时提示今日还有免费转盘。
  wheelExit,

  /// 广告主奖励，展示 PayPal 卡片和钞票飞入余额。
  moneyAward,

  /// 广告主奖励，展示 Cash App 卡片和钞票飞入余额。
  moneyAwardAlternate,

  /// 领取提现祝福。
  blessing,

  /// 展示高级用户的资格项目。
  premium,

  /// 提现排队顺序提示。
  queueAdvance,

  /// 展示答题玩家及当前高亮条目。
  queuePlayers,

  /// 距离完成还差一个金苹果。
  finalApple,

  /// VIP 权益到期提示。
  vipExpiry,

  /// 待打开的提现卡片。
  flipCard,

  /// 首张提现卡片已揭晓。
  flipCardOpened,
}

/// 奖励弹窗的独立界面。操作回调交给调用方处理。
class TPRewardDialog extends StatelessWidget {
  const TPRewardDialog({
    super.key,
    required this.kind,
    required this.onClose,
    this.onNext,
  });

  final TPRewardDialogKind kind;
  final VoidCallback onClose;
  final ValueChanged<TPRewardDialogKind>? onNext;

  void _advance(TPRewardDialogKind next) {
    final callback = onNext;
    if (callback == null) {
      onClose();
    } else {
      callback(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      TPRewardDialogKind.rankClaim ||
      TPRewardDialogKind.rankClaimOpened => _TPRankChest(
        opened: kind == TPRewardDialogKind.rankClaimOpened,
        onPressed: kind == TPRewardDialogKind.rankClaim
            ? () => _advance(TPRewardDialogKind.rankClaimOpened)
            : onClose,
      ),
      TPRewardDialogKind.wheelExit => _TPWheelExit(onClose: onClose),
      TPRewardDialogKind.moneyAward || TPRewardDialogKind.moneyAwardAlternate =>
        _TPMoneyAward(cashApp: kind == TPRewardDialogKind.moneyAwardAlternate),
      TPRewardDialogKind.blessing => _TPBlessing(onClose: onClose),
      TPRewardDialogKind.premium => _TPPremium(onClose: onClose),
      TPRewardDialogKind.queueAdvance => const _TPQueueAdvance(),
      TPRewardDialogKind.queuePlayers => const _TPQueuePlayers(),
      TPRewardDialogKind.finalApple => _TPFinalApple(
        onContinue: () => _advance(TPRewardDialogKind.flipCard),
        onClose: onClose,
      ),
      TPRewardDialogKind.vipExpiry => const TPDialogStage(
        children: [
          Positioned(
            left: 10,
            top: 73,
            width: 350,
            height: 101,
            child: TPDialogMotion(
              effect: TPDialogEffect.rise,
              child: _TPRewardBalance(cashApp: true, vipExpiry: true),
            ),
          ),
        ],
      ),
      TPRewardDialogKind.flipCard ||
      TPRewardDialogKind.flipCardOpened => _TPFlipCards(
        opened: kind == TPRewardDialogKind.flipCardOpened,
        onPressed: kind == TPRewardDialogKind.flipCard
            ? () => _advance(TPRewardDialogKind.flipCardOpened)
            : onClose,
      ),
    };
  }
}

const _rewardDirectory = 'assets/image/dialog/reward';
const _homeDirectory = 'assets/image/home';

class _TPRankChest extends StatelessWidget {
  const _TPRankChest({required this.opened, required this.onPressed});

  final bool opened;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        const Positioned(
          left: 0,
          top: 248,
          width: 375,
          height: 380,
          child: TPDialogMotion(
            effect: TPDialogEffect.fade,
            child: _TPRewardImage('rank_rays'),
          ),
        ),
        const Positioned(
          left: 49,
          top: 167,
          width: 277,
          height: 117,
          child: TPDialogMotion(
            effect: TPDialogEffect.pop,
            child: _TPRewardImage('rank_header'),
          ),
        ),
        Positioned(
          left: opened ? 87 : 102,
          top: opened ? 351 : 364,
          width: opened ? 207 : 171,
          height: opened ? 180 : 148,
          child: TPDialogMotion(
            key: ValueKey(opened),
            effect: TPDialogEffect.celebration,
            delay: const Duration(milliseconds: 120),
            child: opened
                ? const _TPSpineChest()
                : const _TPRewardImage('rank_chest'),
          ),
        ),
        Positioned(
          left: 94,
          top: 502,
          width: 187,
          height: 49,
          child: TPDialogMotion(
            key: ValueKey('chest-amount-$opened'),
            delay: const Duration(milliseconds: 240),
            child: const _TPRewardLabel(
              r'$12',
              color: Color(0xFFF9FF2F),
              size: 42,
              weight: FontWeight.w900,
              shadows: [Shadow(color: Color(0xFF007B12), blurRadius: 5)],
            ),
          ),
        ),
        Positioned(
          left: 70,
          top: 605,
          width: 235,
          height: 55,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            child: TPDialogButton(label: r'Claim $12', onPressed: onPressed),
          ),
        ),
        const Positioned(
          left: 269,
          top: 589,
          width: 36,
          height: 35,
          child: IgnorePointer(child: _TPRewardAdBadge()),
        ),
      ],
    );
  }
}

class _TPSpineChest extends StatefulWidget {
  const _TPSpineChest();

  @override
  State<_TPSpineChest> createState() => _TPSpineChestState();
}

class _TPSpineChestState extends State<_TPSpineChest> {
  final _controller = spine.SpineWidgetController(
    onInitialized: (controller) {
      controller.animationState.setAnimationByName(0, 'animation', false);
    },
  );

  @override
  Widget build(BuildContext context) {
    const still = _TPRewardImage('rank_chest_open');
    if (!Platform.isAndroid || MediaQuery.disableAnimationsOf(context)) {
      return still;
    }
    return TPSpineWidget.fromAsset(
      'assets/spine/kaibaox/skeleton.atlas.txt',
      'assets/spine/kaibaox/skeleton.skel.bytes',
      _controller,
      fit: BoxFit.contain,
      placeholder: still,
    );
  }
}

class _TPWheelExit extends StatelessWidget {
  const _TPWheelExit({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 391,
          bottom: 0,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  left: 3,
                  right: 8,
                  top: 41,
                  height: 127,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF80F6F4), Color(0xFFFFF393)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(26)),
                    ),
                  ),
                ),
                const Positioned(
                  left: 31,
                  top: 54,
                  width: 190,
                  height: 36,
                  child: _TPRewardLabel(
                    'Wait!',
                    size: 30,
                    color: Color(0xFF001439),
                    weight: FontWeight.w900,
                    align: TextAlign.start,
                  ),
                ),
                const Positioned(
                  left: 31,
                  top: 92,
                  width: 257,
                  height: 26,
                  child: _TPRewardLabel(
                    'You next surprise is almost ready',
                    size: 15,
                    color: Color(0xFF001439),
                    weight: FontWeight.w800,
                    align: TextAlign.start,
                  ),
                ),
                const Positioned(
                  left: 231,
                  top: 0,
                  width: 138,
                  height: 138,
                  child: TPDialogMotion(
                    effect: TPDialogEffect.celebration,
                    delay: Duration(milliseconds: 160),
                    child: _TPRewardImage('wheel_face'),
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 123,
                  bottom: 0,
                  child: _TPRewardPanel(
                    color: Color(0xFFFEFEF3),
                    radius: BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                ),
                const Positioned(
                  left: 58,
                  top: 140,
                  width: 280,
                  height: 128,
                  child: _TPRewardImage('wheel_chest'),
                ),
                const Positioned(
                  left: 26,
                  right: 26,
                  top: 281,
                  height: 47,
                  child: _TPRewardLabel(
                    'Leave now and you’ll miss today’s bonus spin.\nWould you like to stay and check it out?',
                    size: 14,
                    color: Color(0xFF000F34),
                    maxLines: 2,
                  ),
                ),
                Positioned(
                  left: 13,
                  top: 345,
                  width: 137,
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCFD2DB)),
                    ),
                    onPressed: onClose,
                    child: const _TPRewardLabel(
                      'Exit Anyway',
                      size: 16,
                      color: Color(0xFF83889C),
                    ),
                  ),
                ),
                Positioned(
                  left: 158,
                  right: 12,
                  top: 345,
                  height: 56,
                  child: TPDialogButton(
                    label: 'Keep Playing',
                    onPressed: onClose,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TPMoneyAward extends StatelessWidget {
  const _TPMoneyAward({required this.cashApp});

  final bool cashApp;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        Positioned(
          left: 10,
          top: 73,
          width: 350,
          height: 101,
          child: _TPRewardBalance(cashApp: cashApp),
        ),
        const Positioned(
          left: 91,
          top: 211,
          width: 194,
          height: 194,
          child: TPDialogMotion(
            effect: TPDialogEffect.celebration,
            child: _TPRewardImage('queue_tree'),
          ),
        ),
        Positioned(
          left: 105,
          top: 470,
          width: 158,
          height: 105,
          child: TPDialogMotion(
            effect: TPDialogEffect.celebration,
            delay: const Duration(milliseconds: 100),
            child: _TPMoneyCard(cashApp: cashApp),
          ),
        ),
        const Positioned(
          left: 78,
          top: 581,
          width: 223,
          height: 25,
          child: _TPRewardLabel(
            'Invested by Advertisers',
            size: 11,
            shadows: [Shadow(blurRadius: 8, color: Colors.black)],
          ),
        ),
        Positioned.fill(child: _TPRewardBillFlight(key: ValueKey(cashApp))),
      ],
    );
  }
}

class _TPRewardBalance extends StatelessWidget {
  const _TPRewardBalance({required this.cashApp, this.vipExpiry = false});

  final bool cashApp;
  final bool vipExpiry;

  @override
  Widget build(BuildContext context) {
    final shade = cashApp ? const Color(0xFF07792B) : const Color(0xFF0752DD);
    final light = cashApp ? const Color(0xFF37D644) : const Color(0xFF286DF9);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          left: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [light, shade, light]),
              ),
              child: const Opacity(
                opacity: .20,
                child: TPImg(name: '$_homeDirectory/tp_home_card_pattern.png'),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 10,
          width: 56,
          height: 42,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: cashApp
                    ? const TPImg(
                        name: 'assets/image/cash/tp_cash_cashapp_idle.png',
                        fit: BoxFit.contain,
                      )
                    : const TPImg(
                        name: '$_homeDirectory/tp_home_paypal.png',
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),
        ),
        Positioned(
          left: vipExpiry ? 66 : 74,
          top: 13,
          width: vipExpiry ? 223 : 152,
          height: 39,
          child: _TPRewardLabel(
            vipExpiry ? "VIP Benefits Won’t Last Forever!" : r'$999.75',
            size: vipExpiry ? 20 : 27,
            weight: FontWeight.w800,
            align: TextAlign.start,
          ),
        ),
        if (!vipExpiry)
          Positioned(
            left: 217,
            right: 20,
            top: 16,
            height: 30,
            child: _TPRewardPanel(
              radius: BorderRadius.circular(20),
              child: _TPRewardLabel(
                'Withdraw',
                color: shade,
                size: 14,
                weight: FontWeight.w700,
              ),
            ),
          ),
        Positioned(
          left: 15,
          right: 10,
          top: 60,
          height: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LinearProgressIndicator(
              minHeight: 16,
              value: .92,
              color: cashApp
                  ? const Color(0xFF78F595)
                  : const Color(0xFF28BEF9),
              backgroundColor: cashApp
                  ? const Color(0xFF144C36)
                  : const Color(0xFF0038A1),
            ),
          ),
        ),
        const Positioned(
          left: 142,
          top: 59,
          width: 67,
          height: 17,
          child: _TPRewardLabel('92%', size: 13, weight: FontWeight.w800),
        ),
        Positioned(
          left: vipExpiry ? 56 : 21,
          top: 81,
          width: 250,
          height: 18,
          child: TPFitText(
            align: vipExpiry ? TextAlign.center : TextAlign.start,
            span: const TextSpan(
              style: TextStyle(color: Colors.white, fontSize: 12),
              children: [
                TextSpan(text: 'Only '),
                TextSpan(
                  text: r'$.025',
                  style: TextStyle(
                    color: Color(0xFFFFFF22),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(text: r' more to withdraw $1000!'),
              ],
            ),
          ),
        ),
        if (vipExpiry)
          const Positioned(
            right: 27,
            top: 48,
            width: 42,
            height: 44,
            child: TPDialogMotion(
              effect: TPDialogEffect.celebration,
              delay: Duration(milliseconds: 150),
              child: _TPRewardImage('apple_token'),
            ),
          ),
      ],
    );
  }
}

class _TPMoneyCard extends StatelessWidget {
  const _TPMoneyCard({required this.cashApp});

  final bool cashApp;

  @override
  Widget build(BuildContext context) {
    final color = cashApp ? const Color(0xFF25BC47) : const Color(0xFF0051EF);
    return Stack(
      children: [
        Positioned(
          left: 13,
          right: 4,
          top: 9,
          height: 80,
          child: Transform.rotate(
            angle: .19,
            child: _TPRewardPanel(
              color: cashApp
                  ? const Color(0xFF0063E3)
                  : const Color(0xFF0FA65E),
              radius: BorderRadius.circular(12),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 2,
          top: 14,
          bottom: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: DecoratedBox(
              decoration: BoxDecoration(color: color),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: Opacity(
                      opacity: .19,
                      child: TPImg(
                        name: '$_homeDirectory/tp_home_card_pattern.png',
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    width: cashApp ? 121 : 94,
                    height: 27,
                    child: TPImg(
                      name: cashApp
                          ? 'assets/image/cash/tp_cash_cashapp_selected.png'
                          : 'assets/image/cash/tp_cash_paypal_selected.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Positioned(
                    left: 10,
                    top: 43,
                    width: 96,
                    height: 34,
                    child: _TPRewardLabel(
                      r'$100',
                      size: 32,
                      weight: FontWeight.w900,
                      align: TextAlign.start,
                    ),
                  ),
                  Positioned(
                    right: 19,
                    bottom: 11,
                    child: _TPRewardDot(
                      color: cashApp ? const Color(0xFF445EF4) : Colors.red,
                      diameter: 22,
                    ),
                  ),
                  const Positioned(
                    right: 5,
                    bottom: 11,
                    child: _TPRewardDot(color: Color(0xFFFFDA34), diameter: 22),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TPRewardBillFlight extends StatefulWidget {
  const _TPRewardBillFlight({super.key});

  @override
  State<_TPRewardBillFlight> createState() => _TPRewardBillFlightState();
}

class _TPRewardBillFlightState extends State<_TPRewardBillFlight>
    with SingleTickerProviderStateMixin {
  static const _duration = 1500;
  static const _count = 9;
  static const _stagger = 70;
  static const _fadeTime = 70;
  static const _travelTime = _duration - (_count - 1) * _stagger - _fadeTime;
  static const _glintStart = _duration - _fadeTime;
  static const _glintDuration = 180;
  static const _timelineDuration = _glintStart + _glintDuration;
  static const _start = Offset(91, 411);
  static const _end = Offset(58, 144);

  late final _flight = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _timelineDuration),
  );

  bool? _reduceMotion;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _flight.value = 1;
    } else if (!_flight.isCompleted) {
      _flight.forward();
    }
  }

  @override
  void dispose() {
    _flight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion == true) return const SizedBox.expand();

    return IgnorePointer(
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _flight,
          child: const TPImg(
            name:
                'assets/image/onboarding/06_10/tp_onboarding_07_cash_bill.png',
            fit: BoxFit.contain,
          ),
          builder: (context, artwork) {
            final elapsed = _flight.value * _timelineDuration;
            final glint = (elapsed - _glintStart) / _glintDuration;
            final bills = <Widget>[];
            for (var index = 0; index < _count; index++) {
              final age = elapsed - index * _stagger;
              if (age <= 0 || age >= _travelTime + _fadeTime) continue;

              final travel = (age / _travelTime).clamp(0.0, 1.0);
              final eased = Curves.easeInOutSine.transform(travel);
              final direction = index.isEven ? 1.0 : -1.0;
              final sway = math.sin(math.pi * eased) * direction;
              final center = Offset.lerp(
                _start,
                _end,
                eased,
              )!.translate(sway * (12 + 5 * (index % 4)), 0);
              final size = 52 + 6.0 * (index % 3) - 24 * eased;
              final fadeIn = (age / 85).clamp(0.0, 1.0);
              final fadeOut = ((age - _travelTime) / _fadeTime).clamp(0.0, 1.0);

              bills.add(
                Positioned(
                  key: ValueKey('tp-dialog-money-bill-$index'),
                  left: center.dx - size / 2,
                  top: center.dy - size / 2,
                  width: size,
                  height: size,
                  child: Opacity(
                    opacity: fadeIn * (1 - fadeOut),
                    child: Transform.rotate(angle: sway * .24, child: artwork),
                  ),
                ),
              );
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                if (glint > 0 && glint < 1)
                  Positioned(
                    key: const ValueKey('tp-dialog-money-balance-glint'),
                    left: 25,
                    top: 133,
                    width: 122,
                    height: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Positioned(
                            left: -14 + 85 * glint,
                            top: 0,
                            bottom: 0,
                            width: 64,
                            child: Opacity(
                              opacity: .76 * math.sin(math.pi * glint),
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0x00FFE19A),
                                      Color(0xBCFFE19A),
                                      Color(0xFFFFF1C5),
                                      Color(0x00FFE19A),
                                    ],
                                    stops: [0, .38, .56, 1],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ...bills,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TPBlessing extends StatelessWidget {
  const _TPBlessing({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        const Positioned(
          left: 45,
          right: 39,
          top: 270,
          height: 122,
          child: _TPRewardPanel(color: Color(0xFF3555FB)),
        ),
        const Positioned(
          left: 34,
          top: 279,
          width: 308,
          height: 274,
          child: TPDialogMotion(child: _TPRewardPanel()),
        ),
        const Positioned(
          left: 86,
          top: 163,
          width: 214,
          height: 214,
          child: TPDialogMotion(
            effect: TPDialogEffect.celebration,
            delay: Duration(milliseconds: 110),
            child: _TPRewardImage('blessing_chest'),
          ),
        ),
        const Positioned(
          left: 52,
          right: 49,
          top: 367,
          height: 43,
          child: _TPRewardLabel(
            "You're the 6,298th user to request a withdrawal today.",
            size: 15,
            color: Color(0xFF2A2D4A),
            align: TextAlign.start,
            maxLines: 2,
          ),
        ),
        const Positioned(
          left: 45,
          right: 41,
          top: 412,
          height: 40,
          child: TPFitText(
            align: TextAlign.center,
            span: TextSpan(
              style: TextStyle(color: Color(0xFF2A2D4A), fontSize: 15),
              children: [
                TextSpan(text: 'Good luck with your '),
                TextSpan(
                  text: r'$100',
                  style: TextStyle(
                    color: Color(0xFF008B31),
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                TextSpan(text: ' withdrawal!'),
              ],
            ),
          ),
        ),
        Positioned(
          left: 71,
          top: 475,
          width: 235,
          height: 55,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            child: TPDialogButton(
              label: 'Claim Your Blessing!',
              onPressed: onClose,
            ),
          ),
        ),
      ],
    );
  }
}

class _TPPremium extends StatelessWidget {
  const _TPPremium({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        const Positioned(
          left: 9,
          top: 26,
          width: 362,
          height: 362,
          child: TPDialogMotion(
            effect: TPDialogEffect.fade,
            child: _TPRewardImage('premium_rays'),
          ),
        ),
        const Positioned(
          left: 16,
          top: 184,
          width: 344,
          height: 354,
          child: _TPRewardPanel(color: Color(0xFF3554FF)),
        ),
        const Positioned(
          left: 60,
          top: 49,
          width: 256,
          height: 256,
          child: TPDialogMotion(
            effect: TPDialogEffect.celebration,
            delay: Duration(milliseconds: 105),
            child: _TPRewardImage('premium_crown'),
          ),
        ),
        for (final (i, x, y, w, h, angle, name) in [
          (0, 37.0, 117.0, 57.0, 62.0, .68, 'cash_money'),
          (1, 296.0, 119.0, 68.0, 59.0, -.65, 'cash_money'),
          (2, 17.0, 208.0, 75.0, 56.0, -.15, 'cash_money_bent'),
          (3, 75.0, 208.0, 75.0, 56.0, .29, 'cash_money'),
          (4, 231.0, 208.0, 75.0, 56.0, -.18, 'cash_money_bent'),
          (5, 283.0, 200.0, 78.0, 76.0, .2, 'cash_money'),
        ])
          Positioned(
            left: x,
            top: y,
            width: w,
            height: h,
            child: TPDialogMotion(
              effect: TPDialogEffect.rise,
              delay: Duration(milliseconds: 100 + 30 * i),
              child: Transform.rotate(
                angle: angle,
                child: _TPRewardImage(name),
              ),
            ),
          ),
        const Positioned(
          left: 16,
          top: 239,
          width: 344,
          height: 354,
          child: _TPRewardPanel(
            radius: BorderRadius.vertical(bottom: Radius.circular(22)),
          ),
        ),
        const Positioned(
          left: 33,
          top: 245,
          width: 310,
          height: 36,
          child: _TPRewardLabel(
            'Premium User',
            color: Colors.black,
            weight: FontWeight.w700,
            size: 20,
          ),
        ),
        for (final (index, action, asset) in [
          (0, 'Eligible Quiz', 'premium_quiz'),
          (1, 'Eligible Dice', 'premium_dice'),
          (2, 'Eligible Spin', 'premium_spin'),
        ])
          Positioned(
            left: 33,
            top: 293 + index * 69.0,
            width: 310,
            height: 59,
            child: TPDialogMotion(
              effect: TPDialogEffect.rise,
              delay: Duration(milliseconds: 135 + index * 95),
              child: _TPPremiumRow(label: action, asset: asset),
            ),
          ),
        Positioned(
          left: 30,
          top: 509,
          width: 319,
          height: 55,
          child: TPDialogButton(
            label: 'Processed Ahead of Others',
            onPressed: onClose,
          ),
        ),
      ],
    );
  }
}

class _TPPremiumRow extends StatelessWidget {
  const _TPPremiumRow({required this.label, required this.asset});

  final String label;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return _TPRewardPanel(
      color: const Color(0xFFF5F8FC),
      radius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFEEF1FA)),
      child: Row(
        children: [
          const SizedBox(width: 10),
          SizedBox.square(
            dimension: 46,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: _TPRewardImage(asset),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TPRewardLabel(
              label,
              size: 14,
              color: Colors.black,
              weight: FontWeight.w700,
              align: TextAlign.start,
            ),
          ),
          const SizedBox(
            width: 72,
            child: _TPRewardLabel(
              'Xxx',
              size: 14,
              color: Colors.black,
              weight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TPQueueAdvance extends StatelessWidget {
  const _TPQueueAdvance();

  @override
  Widget build(BuildContext context) {
    return const TPDialogStage(
      children: [
        Positioned(
          left: 91,
          top: 211,
          width: 194,
          height: 194,
          child: TPDialogMotion(
            effect: TPDialogEffect.celebration,
            child: _TPRewardImage('queue_tree'),
          ),
        ),
        Positioned(
          left: 8,
          top: 406,
          width: 360,
          height: 178,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            delay: Duration(milliseconds: 120),
            child: Stack(
              children: [
                Positioned.fill(child: _TPRewardImage('queue_card')),
                Positioned(
                  left: 46,
                  right: 46,
                  top: 62,
                  height: 76,
                  child: TPFitText(
                    align: TextAlign.center,
                    maxLines: 3,
                    span: TextSpan(
                      style: TextStyle(
                        color: Color(0xFF03551A),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text:
                              "You've skipped ahead by 123 spots and are now ",
                        ),
                        TextSpan(
                          text: '#1',
                          style: TextStyle(
                            color: Color(0xFFD98600),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' in the queue. Your payout is scheduled for today.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TPQueuePlayers extends StatelessWidget {
  const _TPQueuePlayers();

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        for (var index = 0; index < 5; index++)
          Positioned(
            left: index == 3 ? 23 : 33,
            right: index == 3 ? 22 : 32,
            top: 210 + 85.0 * index,
            height: 65,
            child: TPDialogMotion(
              effect: TPDialogEffect.rise,
              delay: Duration(milliseconds: index * 112),
              child: _TPQueuePlayer(highlight: index == 3),
            ),
          ),
      ],
    );
  }
}

class _TPQueuePlayer extends StatelessWidget {
  const _TPQueuePlayer({required this.highlight});

  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final textColor = highlight
        ? const Color(0xFF583400)
        : const Color(0xFF005372);
    final answerColor = highlight ? Colors.white : const Color(0xFF274D71);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: highlight ? const Color(0xFFFFD013) : const Color(0xFFEFFAFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white54, width: 3),
        ),
        child: Stack(
          children: [
            Positioned(
              left: highlight ? 164 : 153,
              right: 3,
              top: 3,
              bottom: 3,
              child: ClipPath(
                clipper: const _TPQueueAnswerClip(),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: highlight
                          ? const [Color(0xFFFF5852), Color(0xFFFFB800)]
                          : const [Color(0xFFD9F2FF), Color(0xFFEBF7FF)],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 10,
              top: 8,
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: SizedBox.square(
                    dimension: 46,
                    child: _TPRewardImage('queue_avatar'),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 67,
              top: 18,
              width: 96,
              height: 30,
              child: _TPRewardLabel(
                'Player_aK9...',
                size: 13,
                color: textColor,
                weight: FontWeight.w800,
                align: TextAlign.start,
              ),
            ),
            Positioned(
              left: highlight ? 179 : 173,
              right: 8,
              top: 12,
              bottom: 12,
              child: TPFitText(
                align: TextAlign.center,
                span: TextSpan(
                  style: TextStyle(
                    color: answerColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  children: const [
                    TextSpan(text: 'Answer '),
                    TextSpan(
                      text: '10',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 25,
                      ),
                    ),
                    TextSpan(text: ' Right'),
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

class _TPQueueAnswerClip extends CustomClipper<Path> {
  const _TPQueueAnswerClip();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.height * .42, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(covariant _TPQueueAnswerClip oldClipper) => false;
}

class _TPFinalApple extends StatelessWidget {
  const _TPFinalApple({required this.onContinue, required this.onClose});

  final VoidCallback onContinue;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        const Positioned(
          left: 0,
          right: 0,
          top: 148,
          height: 380,
          child: _TPRewardImage('rank_rays'),
        ),
        Positioned(
          left: 29,
          top: 342,
          width: 319,
          height: 323,
          child: _TPRewardPanel(
            color: const Color(0xFFFEFAF0),
            border: Border.all(color: const Color(0xFFFCE496), width: 3),
          ),
        ),
        const Positioned(
          left: 32,
          top: 206,
          width: 313,
          height: 214,
          child: TPDialogMotion(
            effect: TPDialogEffect.celebration,
            child: _TPRewardImage('apple_header'),
          ),
        ),
        const Positioned(
          left: 47,
          right: 47,
          top: 294,
          height: 79,
          child: TPDialogMotion(
            delay: Duration(milliseconds: 120),
            child: _TPRewardLabel(
              'Just One\nlast step!',
              size: 32,
              maxLines: 2,
              color: Color(0xFFFFFF65),
              weight: FontWeight.w900,
              shadows: [Shadow(color: Color(0xFF005518), blurRadius: 7)],
            ),
          ),
        ),
        const Positioned(
          left: 45,
          right: 45,
          top: 410,
          height: 31,
          child: _TPRewardLabel(
            'You’re guaranteed to withdraw today',
            size: 16,
            color: Color(0xFF1F2127),
            weight: FontWeight.w700,
          ),
        ),
        for (var index = 0; index < 5; index++)
          Positioned(
            left: 43 + index * 60.0,
            top: 464,
            width: 50,
            height: 51,
            child: TPDialogMotion(
              effect: TPDialogEffect.celebration,
              delay: Duration(milliseconds: 135 + index * 75),
              child: _TPRewardImage(
                index == 4 ? 'apple_token_missing' : 'apple_token',
              ),
            ),
          ),
        const Positioned(
          left: 41,
          right: 40,
          top: 544,
          child: Divider(height: 1, color: Color(0xFFF4DDB0)),
        ),
        const Positioned(
          left: 45,
          right: 43,
          top: 549,
          height: 32,
          child: TPFitText(
            align: TextAlign.center,
            span: TextSpan(
              style: TextStyle(fontSize: 16, color: Color(0xFF666C79)),
              children: [
                TextSpan(text: 'Just '),
                TextSpan(
                  text: '1',
                  style: TextStyle(color: Color(0xFFF6423D)),
                ),
                TextSpan(text: r' Golden Apple to Cash Out $XX'),
              ],
            ),
          ),
        ),
        const Positioned(
          left: 293,
          top: 496,
          width: 69,
          height: 68,
          child: IgnorePointer(
            child: TPDialogMotion(
              effect: TPDialogEffect.rise,
              delay: Duration(milliseconds: 390),
              child: TPImg(
                name: 'assets/image/onboarding/11_16/hand.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Positioned(
          left: 72,
          top: 590,
          width: 239,
          height: 55,
          child: TPDialogButton(
            label: 'Continue',
            style: TPDialogButtonStyle.green,
            onPressed: onContinue,
          ),
        ),
        Positioned(
          left: 167,
          top: 690,
          child: TPDialogCloseButton(onPressed: onClose),
        ),
      ],
    );
  }
}

class _TPFlipCards extends StatelessWidget {
  const _TPFlipCards({required this.opened, required this.onPressed});

  final bool opened;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        Positioned(
          left: 65,
          top: opened ? 125 : 116,
          width: 240,
          height: opened ? 68 : 77,
          child: const ClipRect(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: 160,
              maxHeight: 160,
              child: TPDialogMotion(
                effect: TPDialogEffect.celebration,
                child: _TPRewardImage('flip_header'),
              ),
            ),
          ),
        ),
        const Positioned(
          left: 7,
          top: 186,
          width: 363,
          height: 83,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0x00872525),
                  Color(0xD8882B26),
                  Color(0x00872525),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TPRewardLabel(
                  'Reveal Your Withdrawal',
                  size: 22,
                  weight: FontWeight.w800,
                ),
                _TPRewardLabel(
                  'Card And Keep Going!',
                  size: 23,
                  weight: FontWeight.w900,
                  color: Color(0xFFFDE931),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          top: 321,
          width: 115,
          height: 161,
          child: TPDialogMotion(
            delay: const Duration(milliseconds: 110),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(13),
                child: _TPFlipCardFace(opened: opened),
              ),
            ),
          ),
        ),
        for (final (i, x) in [(0, 143.0), (1, 252.0)])
          Positioned(
            left: x,
            top: 335,
            width: 93,
            height: 133,
            child: TPDialogMotion(
              effect: TPDialogEffect.rise,
              delay: Duration(milliseconds: 210 + i * 95),
              child: const _TPRewardImage('flip_card'),
            ),
          ),
        Positioned(
          left: 70,
          top: 533,
          width: 235,
          height: 55,
          child: TPDialogButton(label: 'OPEN (3)', onPressed: onPressed),
        ),
      ],
    );
  }
}

class _TPFlipCardFace extends StatelessWidget {
  const _TPFlipCardFace({required this.opened});

  final bool opened;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return _face(opened);

    final target = opened ? 1.0 : 0.0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: target, end: target),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      builder: (context, progress, child) {
        final reveal = progress >= .5;
        final angle = (reveal ? progress - 1 : progress) * math.pi;
        return Transform(
          key: const ValueKey('tp-dialog-flip-rotation'),
          alignment: Alignment.center,
          transformHitTests: false,
          transform: Matrix4.identity()
            ..setEntry(3, 2, .0016)
            ..rotateY(angle),
          child: _face(reveal),
        );
      },
    );
  }

  Widget _face(bool reveal) {
    return Semantics(
      key: ValueKey('tp-dialog-flip-face-${reveal ? 'opened' : 'closed'}'),
      label: reveal ? 'Revealed withdrawal card' : 'Open withdrawal card',
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0xFFFDED5C), blurRadius: 8)],
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(4),
                child: _TPRewardImage('flip_card'),
              ),
            ),
            if (reveal) ...[
              const Positioned(
                left: 8,
                top: 51,
                width: 88,
                height: 96,
                child: _TPRewardImage('flip_art'),
              ),
              const Positioned(
                left: 10,
                top: 14,
                width: 87,
                height: 48,
                child: _TPRewardImage('flip_caption'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TPRewardImage extends StatelessWidget {
  const _TPRewardImage(this.asset);
  final String asset;

  @override
  Widget build(BuildContext context) => TPImg(
    name: '$_rewardDirectory/tp_dialog_$asset.png',
    fit: BoxFit.contain,
  );
}

class _TPRewardLabel extends StatelessWidget {
  const _TPRewardLabel(
    this.text, {
    this.color = Colors.white,
    this.size = 16,
    this.weight = FontWeight.w500,
    this.align = TextAlign.center,
    this.maxLines = 1,
    this.shadows,
  });

  final String text;
  final Color color;
  final double size;
  final FontWeight weight;
  final TextAlign align;
  final int maxLines;
  final List<Shadow>? shadows;

  @override
  Widget build(BuildContext context) => TPFitText(
    align: align,
    maxLines: maxLines,
    span: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: weight,
        shadows: shadows,
        height: 1.12,
      ),
    ),
  );
}

class _TPRewardPanel extends StatelessWidget {
  const _TPRewardPanel({
    this.color = Colors.white,
    this.radius = const BorderRadius.all(Radius.circular(24)),
    this.border,
    this.child,
  });

  final Color color;
  final BorderRadius radius;
  final BoxBorder? border;
  final Widget? child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: radius,
      border: border,
    ),
    child: child,
  );
}

class _TPRewardDot extends StatelessWidget {
  const _TPRewardDot({required this.color, required this.diameter});

  final Color color;
  final double diameter;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: diameter,
    child: DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}

class _TPRewardAdBadge extends StatelessWidget {
  const _TPRewardAdBadge();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: TPImg(
            name: '$_homeDirectory/tp_home_ad.png',
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          left: 3,
          top: 12,
          right: 3,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF28B1E3), Color(0xFF00FFE5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const TPText(
              text: 'AD',
              size: 13,
              color: Color(0xFF153841),
              weight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
