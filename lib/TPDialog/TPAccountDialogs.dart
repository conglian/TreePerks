import 'package:flutter/material.dart';

import '../TPTool/TPFonts.dart';
import '../TPTool/TPText.dart';
import 'TPDialogWidgets.dart';

enum TPAccountDialogKind {
  insufficientWithdrawal,
  notifications,
  adLimit,
  network,
  adUnavailable,
  settings,
  rankedApple,
}

/// 提现、通知、网络和设置相关弹窗。
class TPAccountDialog extends StatelessWidget {
  const TPAccountDialog({
    super.key,
    required this.kind,
    required this.onClose,
    this.onPrimary,
    this.onSoundEffectsChanged,
    this.onVolumeChanged,
    this.onTerms,
    this.onPrivacy,
  });

  final TPAccountDialogKind kind;
  final VoidCallback onClose;
  final VoidCallback? onPrimary;
  final ValueChanged<bool>? onSoundEffectsChanged;
  final ValueChanged<bool>? onVolumeChanged;
  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;

  @override
  Widget build(BuildContext context) {
    if (kind == TPAccountDialogKind.settings) {
      return _TPAccountSettings(
        onClose: onClose,
        onSoundEffectsChanged: onSoundEffectsChanged,
        onVolumeChanged: onVolumeChanged,
        onTerms: onTerms,
        onPrivacy: onPrivacy,
      );
    }
    if (kind == TPAccountDialogKind.rankedApple) {
      return _TPAccountRankedApple(onPressed: onPrimary ?? onClose);
    }
    final notice = switch (kind) {
      // 提现余额不足。
      TPAccountDialogKind.insufficientWithdrawal => const _TPAccountNoticeData(
        title: 'Not Enough To Withdraw Yet',
        copy: 'Keep earning rewards to reach the withdrawal amount.',
        action: 'Spin Now',
        illustration: 'worried',
        artRect: Rect.fromLTWH(176, 194, 158, 158),
        closeY: 639,
      ),
      // 引导开启收益通知。
      TPAccountDialogKind.notifications => const _TPAccountNoticeData(
        title: 'Stay On Top Of Your Earnings',
        copy:
            'Receive cash-out reminders, reward alerts, and important account updates.',
        action: 'Allow',
        illustration: 'bell',
        artRect: Rect.fromLTWH(181, 199, 148, 148),
        closeY: 639,
        secondaryAction: 'Not Now',
      ),
      // 达到当日广告观看上限。
      TPAccountDialogKind.adLimit => const _TPAccountNoticeData(
        title: 'Ad Limit Reached',
        copy: "You've watched all available ads for today. Try again tomorrow",
        action: 'Spin Now',
        illustration: 'ad_limit',
        artRect: Rect.fromLTWH(181, 188, 148, 148),
      ),
      // 网络中断。
      TPAccountDialogKind.network => const _TPAccountNoticeData(
        title: 'No Network Currently',
        copy: 'Large rewards were interrupted',
        action: 'Try Again',
        illustration: 'network',
        artRect: Rect.fromLTWH(169, 180, 172, 172),
      ),
      // 广告暂时不可用。
      TPAccountDialogKind.adUnavailable => const _TPAccountNoticeData(
        title: 'Quick Break—Back Soon !',
        copy: 'more cash coming !',
        action: 'Try Again',
        illustration: 'ad_limit',
        artRect: Rect.fromLTWH(181, 188, 148, 148),
      ),
      _ => throw StateError('Unsupported account notice'),
    };
    return _TPAccountNotice(
      data: notice,
      onPressed: onPrimary ?? onClose,
      onClose: onClose,
    );
  }
}

class _TPAccountNoticeData {
  const _TPAccountNoticeData({
    required this.title,
    required this.copy,
    required this.action,
    required this.illustration,
    required this.artRect,
    this.closeY = 603,
    this.secondaryAction,
  });

  final String title;
  final String copy;
  final String action;
  final String illustration;
  final Rect artRect;
  final double closeY;
  final String? secondaryAction;
}

class _TPAccountNotice extends StatelessWidget {
  const _TPAccountNotice({
    required this.data,
    required this.onPressed,
    required this.onClose,
  });

  final _TPAccountNoticeData data;
  final VoidCallback onPressed;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final secondaryAction = data.secondaryAction;
    return TPDialogStage(
      children: [
        _TPAccountHeader(
          artRect: data.artRect,
          illustration: data.illustration,
        ),
        Positioned(
          left: 34,
          top: 303,
          width: 308,
          height: secondaryAction == null ? 264 : 296,
          child: TPDialogMotion(
            child: _TPAccountCard(
              children: [
                Positioned(
                  top: 61,
                  left: 12,
                  right: 12,
                  child: TPText(
                    text: data.title,
                    size: 20,
                    color: Colors.black,
                    weight: FontWeight.w700,
                  ),
                ),
                Positioned(
                  top: 106,
                  left: 28,
                  right: 28,
                  child: TPText(
                    text: data.copy,
                    size: 15,
                    color: const Color(0xFF151515),
                    weight: FontWeight.w400,
                    maxLines: 3,
                  ),
                ),
                Positioned(
                  top: 189,
                  left: 36,
                  right: 36,
                  height: 55,
                  child: TPDialogButton(
                    label: data.action,
                    onPressed: onPressed,
                  ),
                ),
                if (secondaryAction != null)
                  Positioned(
                    bottom: 1,
                    left: 60,
                    right: 60,
                    height: 44,
                    child: TPUnderlineTextButton(
                      text: secondaryAction,
                      textColor: const Color(0xFF797979),
                      onPressed: onClose,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 166,
          top: data.closeY - 22,
          child: TPDialogCloseButton(onPressed: onClose),
        ),
      ],
    );
  }
}

class _TPAccountHeader extends StatelessWidget {
  const _TPAccountHeader({
    required this.artRect,
    required this.illustration,
    this.moneyOffsetY = 0,
  });

  final Rect artRect;
  final String illustration;
  final double moneyOffsetY;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 47,
          top: 274 + moneyOffsetY,
          width: 282,
          height: 82,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF465DFF),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
        ),
        Positioned.fromRect(
          rect: artRect,
          child: TPDialogMotion(
            effect: TPDialogEffect.celebration,
            delay: const Duration(milliseconds: 90),
            child: _TPAccountArt(illustration),
          ),
        ),
        for (final (left, top, size, angle) in const [
          (36.0, 263.0, 75.0, -.28),
          (90.0, 275.0, 73.0, .16),
          (145.0, 285.0, 60.0, -.35),
          (293.0, 284.0, 64.0, .26),
        ])
          Positioned(
            left: left,
            top: top + moneyOffsetY,
            width: size,
            height: size,
            child: TPDialogMotion(
              effect: TPDialogEffect.rise,
              child: Transform.rotate(
                angle: angle,
                child: const _TPAccountBills(),
              ),
            ),
          ),
      ],
    );
  }
}

class _TPAccountCard extends StatelessWidget {
  const _TPAccountCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFFFFEFE)],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(children: children),
    );
  }
}

/// 设置弹窗的音效与音量开关。
class _TPAccountSettings extends StatefulWidget {
  const _TPAccountSettings({
    required this.onClose,
    this.onSoundEffectsChanged,
    this.onVolumeChanged,
    this.onTerms,
    this.onPrivacy,
  });

  final VoidCallback onClose;
  final ValueChanged<bool>? onSoundEffectsChanged;
  final ValueChanged<bool>? onVolumeChanged;
  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;

  @override
  State<_TPAccountSettings> createState() => _TPAccountSettingsState();
}

class _TPAccountSettingsState extends State<_TPAccountSettings> {
  bool _soundEffects = false;
  bool _volume = true;

  void _setSoundEffects(bool value) {
    setState(() => _soundEffects = value);
    widget.onSoundEffectsChanged?.call(value);
  }

  void _setVolume(bool value) {
    setState(() => _volume = value);
    widget.onVolumeChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        const _TPAccountHeader(
          illustration: 'gear',
          artRect: Rect.fromLTWH(188, 187, 132, 132),
          moneyOffsetY: -24,
        ),
        Positioned(
          left: 37,
          top: 275,
          width: 308,
          height: 345,
          child: TPDialogMotion(
            child: _TPAccountCard(
              children: [
                const Positioned(
                  left: 20,
                  right: 20,
                  top: 40,
                  child: TPText(
                    text: 'Setting',
                    size: 20,
                    color: Colors.black,
                    weight: FontWeight.w700,
                  ),
                ),
                const Positioned(
                  left: 14,
                  right: 28,
                  top: 81,
                  child: Divider(height: 1, color: Color(0xFFF4F4F4)),
                ),
                Positioned(
                  left: 17,
                  right: 23,
                  top: 96,
                  height: 44,
                  child: _TPAccountSettingSwitch(
                    label: 'Sound Effects',
                    icon: Icons.music_note_rounded,
                    value: _soundEffects,
                    onChanged: _setSoundEffects,
                  ),
                ),
                Positioned(
                  left: 17,
                  right: 23,
                  top: 162,
                  height: 44,
                  child: _TPAccountSettingSwitch(
                    label: 'Volume',
                    icon: Icons.volume_up_rounded,
                    value: _volume,
                    onChanged: _setVolume,
                  ),
                ),
                const Positioned(
                  left: 14,
                  right: 28,
                  top: 216,
                  child: Divider(height: 1, color: Color(0xFFF4F4F4)),
                ),
                Positioned(
                  left: 15,
                  right: 24,
                  top: 231,
                  height: 42,
                  child: _TPAccountLegalButton(
                    label: 'Terms of Service',
                    onPressed: widget.onTerms,
                  ),
                ),
                Positioned(
                  left: 15,
                  right: 24,
                  top: 288,
                  height: 42,
                  child: _TPAccountLegalButton(
                    label: 'Privacy Policy',
                    onPressed: widget.onPrivacy,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 166,
          top: 633,
          child: TPDialogCloseButton(onPressed: widget.onClose),
        ),
      ],
    );
  }
}

class _TPAccountSettingSwitch extends StatelessWidget {
  const _TPAccountSettingSwitch({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = value
        ? const [Color(0xFF3342FF), Color(0xFF7A91FF)]
        : const [Color(0xFF514A77), Color(0xFF33416A)];
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 170);
    return Semantics(
      label: label,
      toggled: value,
      button: true,
      onTap: () => onChanged(!value),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF5F5F5),
              ),
              child: SizedBox.square(
                dimension: 35,
                child: Icon(icon, color: const Color(0xFF404148), size: 23),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TPText(
                text: label,
                size: 15,
                color: const Color(0xFF404148),
                weight: FontWeight.w500,
                align: TextAlign.left,
              ),
            ),
            AnimatedContainer(
              duration: duration,
              width: 79,
              height: 28,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(colors: colors),
              ),
              child: AnimatedAlign(
                duration: duration,
                curve: Curves.easeInOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: SizedBox.square(dimension: 26),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TPAccountLegalButton extends StatelessWidget {
  const _TPAccountLegalButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(26);
    return Material(
      color: const Color(0xFFF4F4F4),
      borderRadius: radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF626262),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: TPFonts.family,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}

/// 排行榜红苹果奖励信息与现金提示。
class _TPAccountRankedApple extends StatelessWidget {
  const _TPAccountRankedApple({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        const Positioned(
          left: 0,
          right: 0,
          top: 92,
          height: 141,
          child: _TPAccountEarningsBulletins(),
        ),
        const Positioned(
          left: 69,
          top: 286,
          width: 218,
          height: 218,
          child: TPDialogMotion(
            effect: TPDialogEffect.celebration,
            child: _TPAccountArt('apple_tree'),
          ),
        ),
        const Positioned(left: 22, top: 307, child: _TPAccountMoneyBadge()),
        const Positioned(left: 308, top: 411, child: _TPAccountMoneyBadge()),
        const Positioned(
          left: 119,
          top: 526,
          width: 213,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            delay: Duration(milliseconds: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TPAccountStats(label: 'Earn Method', value: 'Quiz'),
                SizedBox(height: 4),
                _TPAccountStats(label: 'Ads Watched', value: '20'),
                SizedBox(height: 4),
                _TPAccountStats(label: 'Total Earnings', value: '50'),
              ],
            ),
          ),
        ),
        Positioned(
          left: 70,
          top: 655,
          width: 235,
          height: 55,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            delay: const Duration(milliseconds: 160),
            child: TPDialogButton(label: 'Swipe Cash', onPressed: onPressed),
          ),
        ),
        Positioned(
          left: 267,
          top: 642,
          width: 36,
          height: 36,
          child: IgnorePointer(
            child: TPDialogMotion(
              effect: TPDialogEffect.pop,
              delay: const Duration(milliseconds: 175),
              child: Image.asset(
                'assets/image/home/tp_home_ad.png',
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 榜单消息按从上到下的顺序滑入，停稳后保持可读。
class _TPAccountEarningsBulletins extends StatelessWidget {
  const _TPAccountEarningsBulletins();

  static const _positions = [(96.0, 0.0), (-13.0, 63.0), (86.0, 118.0)];
  static const _rowDuration = 280;
  static const _rowInterval = 100;

  @override
  Widget build(BuildContext context) {
    final duration = _rowDuration + _rowInterval * (_positions.length - 1);
    return IgnorePointer(
      child: ClipRect(
        child: MediaQuery.disableAnimationsOf(context)
            ? _buildRows(duration.toDouble())
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: duration.toDouble()),
                duration: Duration(milliseconds: duration),
                builder: (context, elapsed, child) => _buildRows(elapsed),
              ),
      ),
    );
  }

  Widget _buildRows(double elapsed) {
    return Stack(
      clipBehavior: Clip.none,
      children: _positions.indexed.map((position) {
        final (index, (left, top)) = position;
        final progress = ((elapsed - _rowInterval * index) / _rowDuration)
            .clamp(0.0, 1.0);
        final distance = TPDialogStage.designSize.width - left;
        final remaining = 1 - Curves.easeOutCubic.transform(progress);
        return Positioned(
          left: left,
          top: top,
          width: 311,
          height: 23,
          child: Transform.translate(
            key: ValueKey('tp-ranked-apple-bulletin-${index + 1}'),
            offset: Offset(distance * remaining, 0),
            child: const _TPAccountEarningsTicker(),
          ),
        );
      }).toList(),
    );
  }
}

class _TPAccountEarningsTicker extends StatelessWidget {
  const _TPAccountEarningsTicker();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFDAE28D).withValues(alpha: .88),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 19),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text.rich(
            const TextSpan(
              children: [
                TextSpan(text: 'Player_aK9x2M  got 10 right and earned '),
                TextSpan(
                  text: r'$10!',
                  style: TextStyle(
                    color: Color(0xFF008500),
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            style: const TextStyle(
              color: Color(0xFF001500),
              fontSize: 12,
              fontFamily: TPFonts.family,
            ),
          ),
        ),
      ),
    );
  }
}

class _TPAccountMoneyBadge extends StatelessWidget {
  const _TPAccountMoneyBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 60,
      child: TPDialogMotion(
        effect: TPDialogEffect.pop,
        delay: const Duration(milliseconds: 175),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(.35, .55),
                  colors: [Color(0xFF849D73), Color(0xFF283841)],
                ),
                border: Border.all(color: const Color(0xFFE0F9FF), width: 3),
              ),
              child: const SizedBox.square(
                dimension: 50,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: _TPAccountBills(),
                ),
              ),
            ),
            const Positioned(
              top: 42,
              child: TPText(
                text: r'$50',
                size: 14,
                color: Color(0xFFCAFFE6),
                weight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TPAccountStats extends StatelessWidget {
  const _TPAccountStats({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '$label : ',
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Color(0xFFEBFA11),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      style: const TextStyle(
        fontFamily: TPFonts.family,
        fontSize: 14,
        color: Colors.white,
        height: 24 / 14,
        letterSpacing: .4,
      ),
    );
  }
}

class _TPAccountArt extends StatelessWidget {
  const _TPAccountArt(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/image/dialog/account/tp_dialog_account_$name.png',
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}

class _TPAccountBills extends StatelessWidget {
  const _TPAccountBills();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/image/home/tp_home_cash.png',
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}
