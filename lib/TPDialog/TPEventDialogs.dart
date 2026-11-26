import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../TPTool/TPFonts.dart';
import '../TPTool/TPImg.dart';
import '../TPTool/TPText.dart';
import 'TPDialogWidgets.dart';

const _tpEventArt = 'assets/image/dialog/event';
const _tpInk = Color(0xFF04062F);
const _tpGreen = Color(0xFF00A73E);
const _tpBlue = Color(0xFF1361F7);

/// 第三排运营弹层及奖励状态。
enum TPEventDialogKind {
  /// 运营 01 首次提现横幅。
  firstWithdrawal,

  /// 运营 02 完善收款信息邀请。
  secureWinnings,

  /// 运营 03 选择平台并填写收款信息。
  paymentInformation,

  /// 运营 04 收益与提现进度。
  withdrawalProgress,

  /// 运营 05 VIP 苹果树升级横幅。
  vipUpgrade,

  /// 运营 06 VIP 苹果树展示。
  vipTree,

  /// 运营 07 VIP 权益说明。
  vipAccess,

  /// 运营 08 点击苹果气泡。
  appleBubble,

  /// 运营 09 苹果兑换预览。
  redeemApple,

  /// 新首页 04 苹果收集进度。
  almostThere,

  /// 新首页 04 备用画板，和普通状态共用内容。
  almostThereAlternate,

  /// 获得 普通苹果里程碑。
  redAppleMilestone,

  /// 获得 金苹果里程碑。
  goldenAppleMilestone,

  /// 榜单额外收益横幅。
  leaderboardEarnings,
}

/// 收款弹层展示的支付平台。
enum TPEventPaymentMethod { paypal, cashApp }

/// 运营活动的独立视图，金额仅用于画板展示，操作交给调用方。
class TPEventDialog extends StatelessWidget {
  const TPEventDialog({
    super.key,
    required this.kind,
    required this.onClose,
    this.onNext,
    this.onPaymentSubmit,
    this.onRedeem,
    this.onCashOut,
  });

  final TPEventDialogKind kind;
  final VoidCallback onClose;
  final ValueChanged<TPEventDialogKind>? onNext;
  final void Function(TPEventPaymentMethod method, String account)?
  onPaymentSubmit;
  final VoidCallback? onRedeem;
  final VoidCallback? onCashOut;

  VoidCallback _next(TPEventDialogKind next) {
    final callback = onNext;
    return callback == null ? onClose : () => callback(next);
  }

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      key: ValueKey(kind),
      children: switch (kind) {
        TPEventDialogKind.firstWithdrawal || TPEventDialogKind.vipUpgrade => [
          _tpEventAt(
            -24,
            234,
            423,
            314,
            _TPEventBanner(
              kind: kind,
              onPressed: _next(
                kind == TPEventDialogKind.firstWithdrawal
                    ? TPEventDialogKind.secureWinnings
                    : TPEventDialogKind.vipTree,
              ),
            ),
            effect: TPDialogEffect.rise,
          ),
        ],
        TPEventDialogKind.secureWinnings => [
          _tpEventAt(
            8,
            164,
            360,
            496,
            _TPSecureWinnings(
              onPrimary: _next(TPEventDialogKind.paymentInformation),
              onClose: onClose,
            ),
            effect: TPDialogEffect.rise,
          ),
          _tpEventClose(684, onClose),
        ],
        TPEventDialogKind.paymentInformation => [
          _tpEventAt(
            35,
            176,
            305,
            408,
            _TPPaymentInformation(
              onSubmit:
                  onPaymentSubmit ??
                  (_, _) => _next(TPEventDialogKind.withdrawalProgress)(),
            ),
            effect: TPDialogEffect.pop,
          ),
          _tpEventClose(598, onClose),
        ],
        TPEventDialogKind.withdrawalProgress => [
          const Positioned(
            left: 101,
            top: 35,
            width: 311,
            height: 23,
            child: _TPProgressBulletin(
              mark: 'progress_paypal_mark',
              entryOffset: 42,
              startDelay: Duration(milliseconds: 100),
            ),
          ),
          const Positioned(
            left: 5,
            top: 83,
            width: 311,
            height: 23,
            child: _TPProgressBulletin(
              mark: 'progress_cashapp_mark',
              entryOffset: -42,
              startDelay: Duration(milliseconds: 320),
            ),
          ),
          _tpEventAt(
            14,
            134,
            361,
            496,
            _TPWithdrawalProgress(onPlay: onClose),
            effect: TPDialogEffect.rise,
          ),
          _tpEventAt(
            18,
            680,
            345,
            101,
            _TPWithdrawalProgressFooter(
              onCashOut:
                  onCashOut ?? _next(TPEventDialogKind.paymentInformation),
            ),
            effect: TPDialogEffect.rise,
            delay: const Duration(milliseconds: 160),
          ),
        ],
        TPEventDialogKind.vipTree => [
          _tpEventAt(
            44,
            263,
            286,
            286,
            _TPEventTap(
              label: 'Continue',
              onTap: _next(TPEventDialogKind.vipAccess),
              child: const _TPEventImage('vip_tree'),
            ),
            effect: TPDialogEffect.celebration,
          ),
        ],
        TPEventDialogKind.vipAccess => [
          _tpEventAt(
            85,
            208,
            207,
            205,
            const _TPEventImage('vip_tree_small'),
            effect: TPDialogEffect.celebration,
          ),
          _tpEventAt(
            8,
            406,
            360,
            178,
            _TPEventTap(
              label: 'Continue',
              onTap: _next(TPEventDialogKind.appleBubble),
              child: const _TPVipAccessTip(),
            ),
            effect: TPDialogEffect.rise,
            delay: const Duration(milliseconds: 180),
          ),
        ],
        TPEventDialogKind.appleBubble => [
          _tpEventAt(
            273,
            339,
            94,
            96,
            _TPEventTap(
              label: 'Collect apple',
              onTap: _next(TPEventDialogKind.redeemApple),
              child: const _TPAppleBubble(),
            ),
            effect: TPDialogEffect.celebration,
          ),
        ],
        TPEventDialogKind.redeemApple => [
          _tpEventAt(
            16,
            221,
            343,
            425,
            _TPRedeemApple(onRedeem: onRedeem ?? onClose),
            effect: TPDialogEffect.celebration,
          ),
          _tpEventClose(670, onClose),
        ],
        TPEventDialogKind.almostThere ||
        TPEventDialogKind.almostThereAlternate => [
          _tpEventAt(
            0,
            80,
            375,
            594,
            _TPAlmostThere(onContinue: onClose),
            effect: TPDialogEffect.pop,
          ),
          _tpEventClose(690, onClose),
        ],
        TPEventDialogKind.redAppleMilestone ||
        TPEventDialogKind.goldenAppleMilestone => [
          _tpEventAt(
            0,
            143,
            375,
            568,
            _TPAppleMilestone(
              isGolden: kind == TPEventDialogKind.goldenAppleMilestone,
              onContinue: onClose,
            ),
            effect: TPDialogEffect.pop,
          ),
        ],
        TPEventDialogKind.leaderboardEarnings => [
          _tpEventAt(
            -26,
            283,
            458,
            248,
            _TPEventBanner(kind: kind, onPressed: onClose),
            effect: TPDialogEffect.rise,
          ),
        ],
      },
    );
  }
}

class _TPEventBanner extends StatelessWidget {
  const _TPEventBanner({required this.kind, required this.onPressed});

  final TPEventDialogKind kind;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final first = kind == TPEventDialogKind.firstWithdrawal;
    final rank = kind == TPEventDialogKind.leaderboardEarnings;
    const shadow = Shadow(
      color: Color(0xFF325205),
      blurRadius: 2,
      offset: Offset(0, 1),
    );
    final (title, detail) = rank
        ? (r"You've earned $13.04", r'Only $86.96 to reach $100!')
        : first
        ? ('As your first withdrawal', 'it can be processed directly today.')
        : ('Upgrade your regular\ntree to a VIP Apple Tree', 'for free.');

    return _TPEventTap(
      label: '$title $detail',
      onTap: onPressed,
      child: Stack(
        children: [
          if (rank) ...[
            _tpEventAt(
              0,
              18,
              261,
              40,
              _TPBannerStripe(color: const Color(0xFF61BA0D)),
              rotation: -.133,
            ),
            _tpEventAt(
              294,
              25,
              167,
              25,
              const _TPBannerStripe(color: Color(0xFFBEFF77)),
              rotation: -.122,
            ),
            _tpEventAt(
              175,
              200,
              282,
              28,
              const _TPBannerStripe(color: Color(0xFFDFFF83)),
              rotation: -.122,
            ),
          ] else ...[
            _tpEventAt(
              0,
              70,
              423,
              15,
              const ColoredBox(color: Color(0x618F9C4C)),
              rotation: -.168,
            ),
            _tpEventAt(
              0,
              264,
              423,
              15,
              const ColoredBox(color: Color(0x618F9C4C)),
              rotation: -.168,
            ),
          ],
          _tpEventAt(
            rank ? 47 : 0,
            rank ? 70 : 96,
            rank ? 414 : 423,
            rank ? 126 : 164,
            DecoratedBox(
              decoration: BoxDecoration(
                color: rank
                    ? null
                    : first
                    ? const Color(0xFF7CCD00)
                    : const Color(0xFF579E08),
                gradient: rank
                    ? const LinearGradient(
                        colors: [Color(0xFF0BDB2A), Color(0xFF159E89)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(rank ? 30 : 4),
                border: Border.all(
                  color: const Color(0xFFDDFF9D),
                  width: rank ? 3 : 7,
                ),
              ),
              child: first
                  ? Center(
                      child: Text(
                        'first withdrawal\nfirst withdrawal',
                        textAlign: TextAlign.center,
                        style: _tpEventTextStyle(
                          50,
                          const Color(0x20FFFFFF),
                          FontWeight.w900,
                        ),
                      ),
                    )
                  : null,
            ),
            rotation: rank ? -.122 : -.085,
          ),
          if (first)
            _tpEventAt(
              108,
              0,
              211,
              180,
              const _TPEventImage('withdrawal_cash'),
              effect: TPDialogEffect.celebration,
              delay: const Duration(milliseconds: 180),
            ),
          if (!first && !rank)
            _tpEventAt(36, 69, 70, 70, const _TPVIPBadge(), rotation: -.15),
          _tpEventAt(
            rank ? 75 : 36,
            rank
                ? 91
                : first
                ? 148
                : 117,
            rank ? 349 : 351,
            rank
                ? 85
                : first
                ? 76
                : 124,
            Transform.rotate(
              angle: rank ? -.122 : -.07,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: rank
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  if (!rank && !first)
                    const _TPEventText(
                      'Boost your account level!',
                      16,
                      Colors.white,
                      weight: FontWeight.bold,
                    ),
                  _TPEventText(
                    title,
                    rank || first ? 32 : 28,
                    first ? const Color(0xFFFFFFCD) : Colors.white,
                    weight: FontWeight.w900,
                    italic: !first && !rank,
                    align: rank ? TextAlign.left : TextAlign.center,
                    shadow: rank ? null : shadow,
                  ),
                  _TPEventText(
                    detail,
                    first || rank ? 20 : 40,
                    first
                        ? const Color(0xFFFFFFCD)
                        : rank
                        ? Colors.white
                        : const Color(0xFFFEF556),
                    weight: FontWeight.w900,
                    italic: !first && !rank,
                    align: rank ? TextAlign.left : TextAlign.center,
                    shadow: first ? shadow : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TPVIPBadge extends StatelessWidget {
  const _TPVIPBadge();

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF3D6500);
    return ClipPath(
      clipper: const _TPStarClipper(),
      child: const ColoredBox(
        color: Color(0xFFFFF663),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.workspace_premium_rounded, color: ink, size: 22),
            _TPEventText('VIP', 24, ink, weight: FontWeight.w900),
          ],
        ),
      ),
    );
  }
}

class _TPStarClipper extends CustomClipper<Path> {
  const _TPStarClipper();

  @override
  Path getClip(Size size) {
    final center = size.center(Offset.zero);
    final path = Path();
    for (var index = 0; index < 24; index++) {
      final angle = index * math.pi / 12;
      final radius = size.width * (index.isEven ? .5 : .38);
      final dot = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (index == 0) {
        path.moveTo(dot.dx, dot.dy);
      } else {
        path.lineTo(dot.dx, dot.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldReclip(covariant _TPStarClipper oldClipper) => false;
}

class _TPBannerStripe extends StatelessWidget {
  const _TPBannerStripe({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [color.withAlpha(0), color]),
      borderRadius: BorderRadius.circular(60),
    ),
  );
}

class _TPSecureWinnings extends StatelessWidget {
  const _TPSecureWinnings({required this.onPrimary, required this.onClose});

  final VoidCallback onPrimary;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _tpEventAt(
          0,
          230,
          360,
          179,
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF17184F),
              borderRadius: BorderRadius.circular(36),
            ),
          ),
        ),
        _tpEventAt(
          14,
          0,
          331,
          378,
          const _TPEventPanel(topColor: Color(0xFFD3EDFD)),
        ),
        _tpEventAt(
          24,
          25,
          312,
          26,
          const _TPEventText(
            "Don't Leave Your Money Behind!",
            20,
            _tpInk,
            weight: FontWeight.w700,
          ),
        ),
        _tpEventAt(
          22,
          56,
          316,
          24,
          const _TPEventText(
            'Secure Your Earnings In One Quick Step',
            16,
            Color(0xFF515C85),
          ),
        ),
        _tpEventAt(
          35,
          91,
          290,
          213,
          const _TPEventImage('secure_cash'),
          effect: TPDialogEffect.celebration,
          delay: const Duration(milliseconds: 130),
        ),
        _tpEventAt(
          211,
          102,
          134,
          44,
          const _TPSecureBadge(),
          rotation: .16,
          effect: TPDialogEffect.pop,
          delay: const Duration(milliseconds: 260),
        ),
        _tpEventAt(
          25,
          309,
          310,
          36,
          const _TPEventRichText(
            color: Color(0xFF24243C),
            children: [
              TextSpan(text: 'Your Game Was A Success! To Send Your '),
              TextSpan(
                text: r'$626',
                style: TextStyle(
                  color: Color(0xFF29A413),
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(text: '\nIn Earnings, We Just Need Your Payout Info.'),
            ],
          ),
        ),
        _tpEventAt(
          0,
          360,
          360,
          136,
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment.bottomCenter,
                radius: 1.15,
                colors: [
                  Color(0xFF16A0E5),
                  Color(0xFF243FD4),
                  Color(0xFF3726CC),
                ],
                stops: [0, .58, 1],
              ),
              border: Border.all(color: const Color(0xFF4768EE)),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
          ),
        ),
        _tpEventAt(
          147,
          359,
          66,
          10,
          const CustomPaint(painter: _TPPanelNotch()),
        ),
        _tpEventAt(
          29,
          386,
          300,
          57,
          TPDialogButton(
            key: const ValueKey('tp-event-secure-winnings'),
            label: 'Secure My Winnings',
            onPressed: onPrimary,
          ),
        ),
        _tpEventAt(
          126,
          452,
          108,
          38,
          TPUnderlineTextButton(
            text: 'Later On',
            textColor: const Color(0xFFDEDEDE),
            onPressed: onClose,
          ),
        ),
      ],
    );
  }
}

class _TPSecureBadge extends StatelessWidget {
  const _TPSecureBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4584FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x773376DA),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, color: Color(0xFF005AFF), size: 18),
                _TPEventText(
                  'Only 1 Minute',
                  12,
                  Color(0xFF005AFF),
                  weight: FontWeight.w700,
                ),
              ],
            ),
          ),
          _TPEventText('Secure Your Winnings Now', 10, Colors.black),
        ],
      ),
    );
  }
}

class _TPPanelNotch extends CustomPainter {
  const _TPPanelNotch();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _TPPanelNotch oldDelegate) => false;
}

class _TPPaymentInformation extends StatefulWidget {
  const _TPPaymentInformation({required this.onSubmit});

  final void Function(TPEventPaymentMethod method, String account) onSubmit;

  @override
  State<_TPPaymentInformation> createState() => _TPPaymentInformationState();
}

class _TPPaymentInformationState extends State<_TPPaymentInformation> {
  final _controller = TextEditingController();
  var _method = TPEventPaymentMethod.paypal;
  bool _showError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final account = _controller.text.trim();
    if (account.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    FocusScope.of(context).unfocus();
    widget.onSubmit(_method, account);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: _TPEventPanel(topColor: Color(0xFFD3EDFD), notch: 312),
        ),
        _tpEventAt(
          12,
          31,
          281,
          28,
          const _TPEventText(
            'Payment Information',
            20,
            _tpInk,
            weight: FontWeight.w700,
          ),
        ),
        for (final (index, method) in TPEventPaymentMethod.values.indexed)
          _tpEventAt(
            12 + 146.0 * index,
            77,
            136,
            72,
            _TPPaymentChoice(
              method: method,
              selected: method == _method,
              onSelected: () => setState(() => _method = method),
            ),
          ),
        _tpEventAt(
          12,
          166,
          280,
          25,
          const _TPEventText(
            'Account/Phone',
            16,
            Colors.black,
            weight: FontWeight.w600,
            align: TextAlign.left,
          ),
        ),
        _tpEventAt(
          13,
          195,
          281,
          42,
          Material(
            color: const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(8),
            child: TextField(
              key: const ValueKey('tp-event-payment-account'),
              controller: _controller,
              style: _tpEventTextStyle(16, Colors.black),
              textAlign: TextAlign.center,
              keyboardType: _method == TPEventPaymentMethod.cashApp
                  ? TextInputType.phone
                  : TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              onChanged: (_) {
                if (_showError) setState(() => _showError = false);
              },
              decoration: InputDecoration(
                isDense: true,
                hintText: _method == TPEventPaymentMethod.cashApp
                    ? 'E.G. 1234567890'
                    : 'E.G. 123456789@Abc.Com',
                hintStyle: _tpEventTextStyle(16, const Color(0xFFAEAEAE)),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        _tpEventAt(
          14,
          245,
          277,
          46,
          _TPEventText(
            _showError
                ? 'Enter your account or phone number.'
                : 'Direct to Your paypal  Instant Payment\nDirect to Your cash app Instant Payment',
            12,
            _showError ? const Color(0xFFBD261B) : const Color(0xFF777777),
            maxLines: 2,
          ),
        ),
        _tpEventAt(16, 311, 274, 1, const _TPEventDivider()),
        _tpEventAt(
          31,
          332,
          241,
          57,
          TPDialogButton(
            key: const ValueKey('tp-event-payment-submit'),
            label: 'Submit',
            onPressed: _submit,
          ),
        ),
      ],
    );
  }
}

class _TPPaymentChoice extends StatelessWidget {
  const _TPPaymentChoice({
    required this.method,
    required this.selected,
    required this.onSelected,
  });

  final TPEventPaymentMethod method;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final paypal = method == TPEventPaymentMethod.paypal;
    final radius = BorderRadius.circular(12);
    return Semantics(
      label: paypal ? 'PayPal' : 'Cash App',
      selected: selected,
      button: true,
      child: Material(
        color: Colors.white,
        borderRadius: radius,
        child: InkWell(
          key: ValueKey('tp-event-payment-${method.name}'),
          borderRadius: radius,
          onTap: onSelected,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected
                    ? const Color(0xFF00B3FF)
                    : const Color(0xFFD8E4FF),
                width: selected ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: TPImg(
                    name:
                        'assets/image/cash/tp_cash_${paypal ? 'paypal' : 'cashapp'}_idle.png',
                    width: 100,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                ),
                if (selected)
                  const Positioned(
                    right: 1,
                    top: 1,
                    child: SizedBox(
                      width: 30,
                      height: 18,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFF00B3FF),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 展示提现进度画板中的两条通知，入场后保留完整内容。
class _TPProgressBulletin extends StatelessWidget {
  const _TPProgressBulletin({
    required this.mark,
    required this.entryOffset,
    required this.startDelay,
  });

  final String mark;
  final double entryOffset;
  final Duration startDelay;

  @override
  Widget build(BuildContext context) {
    final bulletin = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x99FFFFFF),
        border: Border.all(color: const Color(0xCCFFFFFF)),
        borderRadius: BorderRadius.circular(34),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 19,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: SizedBox(
                    width: 13,
                    height: 13.2,
                    child: _TPEventImage(mark),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Player_aK9x2M',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      TextSpan(text: '  got 10 right and earned '),
                      TextSpan(
                        text: r'$10!',
                        style: TextStyle(
                          color: Color(0xFF008B05),
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  style: _tpEventTextStyle(12, const Color(0xFF001500)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (MediaQuery.disableAnimationsOf(context)) return bulletin;

    final duration = startDelay + const Duration(milliseconds: 420);
    final entry = Interval(
      startDelay.inMilliseconds / duration.inMilliseconds,
      1,
      curve: Curves.easeOutCubic,
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      child: bulletin,
      builder: (context, value, child) {
        final progress = entry.transform(value);
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(entryOffset * (1 - progress), 0),
            child: child,
          ),
        );
      },
    );
  }
}

class _TPWithdrawalProgress extends StatelessWidget {
  const _TPWithdrawalProgress({required this.onPlay});

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _tpEventAt(
          4,
          88,
          348,
          108,
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4621D2), Color(0xFF291490)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
        _tpEventAt(
          169,
          0,
          192,
          192,
          const _TPEventImage('progress_gift'),
          effect: TPDialogEffect.celebration,
          delay: const Duration(milliseconds: 150),
        ),
        _tpEventAt(
          156,
          92,
          87,
          40,
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xB52D1757), Color(0x002D1757)],
                radius: .69,
              ),
            ),
          ),
        ),
        _tpEventAt(
          18,
          92,
          208,
          40,
          const _TPEventText(
            'Almost there!',
            32,
            Color(0xFFFFFFA9),
            weight: FontWeight.w700,
            align: TextAlign.left,
            shadow: Shadow(color: Color(0xFF301750), blurRadius: 4),
          ),
        ),
        const Positioned(
          left: 0,
          right: 14,
          top: 148,
          bottom: 1,
          child: _TPEventPanel(topColor: Color(0xFFE2FFEA), notch: 251),
        ),
        _tpEventAt(
          13,
          137,
          321,
          31,
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF4612DF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const _TPEventRichText(
              color: Colors.white,
              weight: FontWeight.w700,
              children: [
                TextSpan(text: 'Your withdrawal progress beats '),
                TextSpan(
                  text: '92%',
                  style: TextStyle(
                    color: Color(0xFFFFFA06),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(text: ' of users'),
              ],
            ),
          ),
        ),
        _tpEventAt(
          24,
          174,
          299,
          25,
          const _TPEventText(
            'Current earnings',
            16,
            Color(0xFF4B566C),
            weight: FontWeight.w600,
          ),
        ),
        _tpEventAt(
          30,
          202,
          286,
          48,
          const _TPEventText(
            r'$ 500',
            40,
            Color(0xFF00CE4D),
            weight: FontWeight.w900,
          ),
        ),
        _tpEventAt(36, 258, 30, 126, const _TPProgressMilestones()),
        _tpEventAt(
          80,
          254,
          252,
          34,
          const _TPEventText(
            'Submit payment information',
            15,
            Colors.black,
            weight: FontWeight.w700,
            align: TextAlign.left,
          ),
        ),
        _tpEventAt(
          80,
          304,
          249,
          35,
          const _TPEventText(
            r'Just $xxx away from payout!',
            18,
            Color(0xFFFD6025),
            weight: FontWeight.w700,
            align: TextAlign.left,
          ),
        ),
        _tpEventAt(
          80,
          355,
          244,
          35,
          const _TPEventText(
            'Revenue received',
            15,
            Color(0xFF8C8C8C),
            weight: FontWeight.w600,
            align: TextAlign.left,
          ),
        ),
        _tpEventAt(26, 398, 296, 1, const _TPEventDivider()),
        _tpEventAt(
          51,
          419,
          242,
          57,
          TPDialogButton(
            key: const ValueKey('tp-event-play-game'),
            label: 'Play Game',
            onPressed: onPlay,
          ),
        ),
      ],
    );
  }
}

class _TPProgressMilestones extends StatelessWidget {
  const _TPProgressMilestones();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 10,
          top: 14,
          width: 4,
          height: 47,
          child: ColoredBox(color: Color(0xFF00CE4D)),
        ),
        Positioned(
          left: 10,
          top: 61,
          width: 4,
          height: 48,
          child: ColoredBox(color: Color(0xFF939393)),
        ),
        Positioned(
          top: 0,
          child: _TPProgressDot(color: Color(0xFF00CE4D), done: true),
        ),
        Positioned(top: 50, child: _TPCurrentProgressDot()),
        Positioned(top: 101, child: _TPProgressDot(color: Color(0xFFD8D8D8))),
      ],
    );
  }
}

/// 仅强调当前节点，已完成和待完成节点保留各自状态。
class _TPCurrentProgressDot extends StatelessWidget {
  const _TPCurrentProgressDot();

  @override
  Widget build(BuildContext context) {
    const dot = _TPProgressDot(
      key: ValueKey('tp-event-withdrawal-current-stage'),
      color: Color(0xFFFFAA0E),
    );
    if (MediaQuery.disableAnimationsOf(context)) return dot;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: const Interval(.42, 1),
      child: dot,
      builder: (context, value, child) {
        return Transform.scale(
          key: const ValueKey('tp-event-withdrawal-current-stage-pulse'),
          scale: 1 + .18 * math.sin(value * math.pi),
          transformHitTests: false,
          child: child,
        );
      },
    );
  }
}

class _TPProgressDot extends StatelessWidget {
  const _TPProgressDot({super.key, required this.color, this.done = false});

  final Color color;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 25,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.3),
        ),
        child: done
            ? const Icon(Icons.check, size: 17, color: Colors.white)
            : null,
      ),
    );
  }
}

class _TPWithdrawalProgressFooter extends StatelessWidget {
  const _TPWithdrawalProgressFooter({required this.onCashOut});

  final VoidCallback onCashOut;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2365F4), Color(0xFF0146AE)],
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Stack(
        children: [
          _tpEventAt(
            0,
            9,
            51,
            43,
            const DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(4),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.all(4),
                child: TPImg(
                  name: 'assets/image/home/tp_home_paypal.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          _tpEventAt(
            212,
            16,
            113,
            30,
            Material(
              color: Colors.white,
              shape: const StadiumBorder(),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: onCashOut,
                child: const _TPEventText(
                  'Cash Out',
                  14,
                  _tpBlue,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ),
          _tpEventAt(
            9,
            55,
            190,
            17,
            const _TPEventText(
              r'Accumulate $1000 to cash out.',
              12,
              Colors.white,
              align: TextAlign.left,
            ),
          ),
          _tpEventAt(9, 76, 327, 16, const _TPWithdrawalFooterMeter()),
        ],
      ),
    );
  }
}

/// 进度条和可见百分比共享同一个显示值。
class _TPWithdrawalFooterMeter extends StatelessWidget {
  const _TPWithdrawalFooterMeter();

  static const _target = .92;

  Widget _meter(double value) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF06286F)),
        Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            key: const ValueKey('tp-event-withdrawal-progress-fill'),
            widthFactor: value,
            heightFactor: .78,
            child: const ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: ColoredBox(color: Color(0xFF29C5F7)),
            ),
          ),
        ),
        _TPEventText(
          '${(value * 100).round()}%',
          14,
          Colors.white,
          weight: FontWeight.w600,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Withdrawal progress',
      value: '${(_target * 100).round()}%',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MediaQuery.disableAnimationsOf(context)
            ? _meter(_target)
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _target),
                duration: const Duration(milliseconds: 1150),
                curve: const Interval(
                  450 / 1150,
                  1,
                  curve: Curves.easeOutCubic,
                ),
                builder: (context, value, child) => _meter(value),
              ),
      ),
    );
  }
}

class _TPVipAccessTip extends StatelessWidget {
  const _TPVipAccessTip();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned.fill(child: _TPEventImage('vip_tip')),
        Positioned(
          left: 46,
          right: 46,
          top: 68,
          height: 67,
          child: _TPEventRichText(
            size: 16,
            color: Color(0xFF03551A),
            weight: FontWeight.w600,
            height: 1.5,
            children: [
              TextSpan(text: 'High withdrawal demand right now.\n'),
              TextSpan(
                text: 'VIP',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFA000),
                ),
              ),
              TextSpan(text: ' access is enabled to help you cash out faster.'),
            ],
          ),
        ),
      ],
    );
  }
}

class _TPAppleBubble extends StatelessWidget {
  const _TPAppleBubble();

  @override
  Widget build(BuildContext context) {
    return TPDialogTapHint(
      delay: const Duration(milliseconds: 650),
      builder: (context, contact) {
        return Stack(
          children: [
            _tpEventAt(
              3,
              0,
              58.263,
              58.263,
              Transform.scale(
                key: const ValueKey('tp-event-apple-bubble-art'),
                scale: 1 - contact * .05,
                transformHitTests: false,
                child: const Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      left: 11,
                      top: 11,
                      width: 35,
                      height: 35,
                      child: _TPEventImage('red_apple'),
                    ),
                    ExcludeSemantics(
                      child: TPImg(
                        name: 'assets/image/home/tp_home_button_back.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _tpEventAt(
              0,
              44,
              65,
              17,
              const _TPEventText(
                '+100.00',
                14,
                Color(0xFFA60F0F),
                weight: FontWeight.w700,
                shadow: Shadow(color: Colors.white, blurRadius: 2),
              ),
            ),
            _tpEventAt(
              31,
              40,
              62.853,
              55.923,
              Transform.translate(
                key: const ValueKey('tp-event-apple-bubble-hand'),
                offset: Offset(-4 * contact, -5 * contact),
                transformHitTests: false,
                child: const _TPEventImage('apple_hand'),
              ),
              effect: TPDialogEffect.rise,
              delay: const Duration(milliseconds: 180),
            ),
          ],
        );
      },
    );
  }
}

class _TPRedeemApple extends StatelessWidget {
  const _TPRedeemApple({required this.onRedeem});

  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Semantics(
            label: 'Congratulations in advance!',
            child: const _TPEventImage('redeem_frame'),
          ),
        ),
        _tpEventAt(
          50,
          91,
          243,
          22,
          const _TPEventText(
            'Current earnings',
            16,
            Color(0xFF4B566C),
            weight: FontWeight.w600,
          ),
        ),
        _tpEventAt(
          50,
          116,
          243,
          51,
          const _TPEventText(r'$ 500', 48, _tpGreen, weight: FontWeight.w900),
        ),
        _tpEventAt(
          24,
          176,
          122,
          139,
          const _TPRedemptionTile(
            image: 'redeem_apple',
            label: 'x1',
            color: Color(0xFF950A01),
          ),
          effect: TPDialogEffect.celebration,
          delay: const Duration(milliseconds: 115),
        ),
        _tpEventAt(
          146,
          221,
          47,
          46,
          const _TPEventImage('redeem_arrow'),
          effect: TPDialogEffect.rise,
          delay: const Duration(milliseconds: 195),
        ),
        _tpEventAt(
          197,
          176,
          122,
          139,
          const _TPRedemptionTile(
            image: 'redeem_cash',
            label: r'$0.5',
            color: _tpGreen,
          ),
          effect: TPDialogEffect.celebration,
          delay: const Duration(milliseconds: 260),
        ),
        _tpEventAt(14, 329, 315, 1, const _TPEventDivider()),
        _tpEventAt(
          50,
          344,
          242,
          57,
          TPDialogButton(
            key: const ValueKey('tp-event-redeem'),
            label: 'Click To Redeem',
            style: TPDialogButtonStyle.green,
            onPressed: onRedeem,
          ),
        ),
      ],
    );
  }
}

class _TPRedemptionTile extends StatelessWidget {
  const _TPRedemptionTile({
    required this.image,
    required this.label,
    required this.color,
  });

  final String image;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _tpEventAt(
          0,
          0,
          122,
          122,
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _TPEventImage(image),
          ),
        ),
        _tpEventAt(
          18,
          110,
          82,
          29,
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(30),
            ),
            child: _TPEventText(
              label,
              24,
              Colors.white,
              weight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _TPAlmostThere extends StatelessWidget {
  const _TPAlmostThere({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _tpEventAt(
          0,
          0,
          375,
          380,
          const _TPEventImage('apple_rays'),
          effect: TPDialogEffect.fade,
        ),
        _tpEventAt(
          29,
          187,
          319,
          407,
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFAF1), Color(0xFFFDF3E4)],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFFFC235), width: 3),
            ),
          ),
        ),
        _tpEventAt(
          32,
          58,
          313,
          214,
          const _TPEventImage('almost_banner'),
          effect: TPDialogEffect.celebration,
          delay: const Duration(milliseconds: 115),
        ),
        _tpEventAt(
          44,
          252,
          288,
          53,
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFCEEE1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TPEventText(
                    '10',
                    18,
                    Color(0xFFFF7700),
                    weight: FontWeight.bold,
                  ),
                  _TPEventText(
                    ' More ',
                    18,
                    Colors.black,
                    weight: FontWeight.bold,
                  ),
                  SizedBox(
                    width: 30,
                    height: 31,
                    child: _TPEventImage('red_apple'),
                  ),
                  _TPEventText(
                    ' to Cash Out ',
                    18,
                    Colors.black,
                    weight: FontWeight.bold,
                  ),
                  _TPEventText(
                    r'$19.00',
                    18,
                    _tpGreen,
                    weight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          ),
        ),
        for (var index = 0; index < 10; index++)
          _tpEventAt(
            43 + (index % 5) * 60.0,
            325 + (index ~/ 5) * 61.0,
            49,
            49,
            _TPAppleToken(
              art: index < 7 ? 'red_apple' : 'grey_apple',
              circle: true,
            ),
            effect: TPDialogEffect.pop,
            delay: Duration(milliseconds: 100 + index * 42),
          ),
        _tpEventAt(40, 466, 296, 1, const _TPEventDivider()),
        _tpEventAt(
          44,
          471,
          286,
          31,
          const _TPEventText(
            'Collect as soon as possible',
            15,
            Color(0xFF52565E),
            weight: FontWeight.w600,
          ),
        ),
        _tpEventAt(
          70,
          513,
          242,
          57,
          TPDialogButton(
            key: const ValueKey('tp-event-almost-there-continue'),
            label: 'Continue',
            style: TPDialogButtonStyle.green,
            onPressed: onContinue,
          ),
        ),
      ],
    );
  }
}

class _TPAppleMilestone extends StatelessWidget {
  const _TPAppleMilestone({required this.isGolden, required this.onContinue});

  final bool isGolden;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final art = isGolden ? 'gold_apple' : 'red_apple';
    const gold = Color(0xFFFFCC00);
    const outline = Shadow(
      color: Color(0xFF822000),
      offset: Offset(1, 2),
      blurRadius: 2,
    );
    return Stack(
      children: [
        _tpEventAt(
          53,
          84,
          272,
          272,
          const Opacity(opacity: .78, child: _TPEventImage('apple_rays')),
          effect: TPDialogEffect.fade,
        ),
        _tpEventAt(
          isGolden ? 128 : 140,
          isGolden ? 155 : 172,
          isGolden ? 125 : 96,
          isGolden ? 123 : 98,
          _TPEventImage(art),
          effect: TPDialogEffect.celebration,
          delay: const Duration(milliseconds: 130),
        ),
        if (isGolden) ...[
          _tpEventAt(
            20,
            15,
            335,
            42,
            const _TPEventText(
              'Just One Last Step!',
              32,
              gold,
              weight: FontWeight.w900,
              italic: true,
              shadow: outline,
            ),
          ),
          _tpEventAt(
            25,
            57,
            325,
            24,
            const _TPEventText(
              "You're Guaranteed To Withdraw Today",
              18,
              Color(0xFFFFFDD3),
              weight: FontWeight.w600,
            ),
          ),
        ] else ...[
          _tpEventAt(
            22,
            0,
            331,
            44,
            const _TPEventText(
              'congratulations',
              40,
              gold,
              weight: FontWeight.w900,
              italic: true,
              shadow: outline,
            ),
          ),
          _tpEventAt(
            22,
            48,
            331,
            44,
            const _TPEventText(
              'in advance',
              34,
              gold,
              weight: FontWeight.w900,
              italic: true,
              shadow: outline,
            ),
          ),
        ],
        _tpEventAt(
          109,
          281,
          157,
          53,
          const _TPEventText(
            'x3',
            48,
            Color(0xFFEEFF00),
            weight: FontWeight.w900,
          ),
        ),
        _tpEventAt(
          0,
          344,
          375,
          190,
          CustomPaint(painter: _TPAppleMilestoneTray(isGolden)),
        ),
        for (var index = 0; index < 5; index++)
          _tpEventAt(
            24 + index * 69,
            387,
            53,
            53,
            _TPAppleToken(art: index < 3 ? art : 'grey_apple'),
            effect: TPDialogEffect.pop,
            delay: Duration(milliseconds: 200 + index * 75),
          ),
        if (isGolden)
          _tpEventAt(
            26,
            461,
            323,
            29,
            const _TPEventRichText(
              color: Color(0xFFFFFDD3),
              weight: FontWeight.w600,
              children: [
                TextSpan(text: 'Just '),
                TextSpan(
                  text: '2',
                  style: TextStyle(
                    color: Color(0xFFFF4221),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: ' Golden Apple To Cash Out '),
                TextSpan(
                  text: r'$XX',
                  style: TextStyle(color: Color(0xFF3FFF3C)),
                ),
              ],
            ),
          ),
        _tpEventAt(
          69,
          511,
          237,
          57,
          TPDialogButton(
            key: const ValueKey('tp-event-milestone-continue'),
            label: 'Continue',
            onPressed: onContinue,
          ),
        ),
      ],
    );
  }
}

class _TPAppleToken extends StatelessWidget {
  const _TPAppleToken({required this.art, this.circle = false});

  final String art;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final image = _TPEventImage(art);
    if (!circle) return image;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.4),
        gradient: RadialGradient(
          colors: art == 'grey_apple'
              ? const [Color(0xFFF5F4F2), Color(0xFFDAD1CD)]
              : const [Color(0xFFFFFBD1), Color(0xFFFFE149)],
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(6), child: image),
    );
  }
}

class _TPAppleMilestoneTray extends CustomPainter {
  const _TPAppleMilestoneTray(this.isGolden);

  final bool isGolden;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final boundary = Path()
      ..moveTo(0, 10)
      ..lineTo(center - 11, 10)
      ..lineTo(center - 2, 1)
      ..quadraticBezierTo(center, -1, center + 2, 1)
      ..lineTo(center + 11, 10)
      ..lineTo(size.width, 10);
    final fill = Path.from(boundary)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isGolden ? const Color(0x5094993A) : const Color(0x5086321A),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      boundary,
      Paint()
        ..color = const Color(0xA6FFF3AD)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
    canvas.save();
    canvas.clipPath(fill);
    final dots = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x37FFFFFF), Colors.transparent],
      ).createShader(Offset.zero & size);
    for (var y = 8.0; y < size.height; y += 6) {
      for (var x = (y ~/ 6).isEven ? 2.0 : 5.0; x < size.width; x += 6) {
        canvas.drawCircle(Offset(x, y), 1.2, dots);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TPAppleMilestoneTray oldDelegate) =>
      isGolden != oldDelegate.isGolden;
}

class _TPEventTap extends StatelessWidget {
  const _TPEventTap({
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        key: const ValueKey('tp-event-art-action'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class _TPEventPanel extends StatelessWidget {
  const _TPEventPanel({required this.topColor, this.notch});

  final Color topColor;
  final double? notch;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _TPEventPanelPainter(topColor, notch));
  }
}

class _TPEventPanelPainter extends CustomPainter {
  const _TPEventPanelPainter(this.topColor, this.notch);

  final Color topColor;
  final double? notch;

  @override
  void paint(Canvas canvas, Size size) {
    final panel = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
      );
    final notchPosition = notch;
    final shape = notchPosition == null
        ? panel
        : Path.combine(
            PathOperation.difference,
            panel,
            Path()
              ..addOval(
                Rect.fromCircle(center: Offset(0, notchPosition), radius: 9),
              )
              ..addOval(
                Rect.fromCircle(
                  center: Offset(size.width, notchPosition),
                  radius: 9,
                ),
              ),
          );
    canvas.drawPath(
      shape,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, Colors.white, Colors.white],
          stops: const [0, .38, 1],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _TPEventPanelPainter oldDelegate) =>
      topColor != oldDelegate.topColor || notch != oldDelegate.notch;
}

class _TPEventDivider extends StatelessWidget {
  const _TPEventDivider();

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(painter: _TPEventDividerPainter());
}

class _TPEventDividerPainter extends CustomPainter {
  const _TPEventDividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFC5BDB0);
    for (var x = 0.0; x < size.width; x += 12) {
      canvas.drawLine(
        Offset(x, .5),
        Offset(math.min(x + 6, size.width), .5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TPEventDividerPainter oldDelegate) => false;
}

class _TPEventImage extends StatelessWidget {
  const _TPEventImage(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: TPImg(name: '$_tpEventArt/$asset.png', fit: BoxFit.contain),
  );
}

class _TPEventText extends StatelessWidget {
  const _TPEventText(
    this.text,
    this.size,
    this.color, {
    this.weight = FontWeight.normal,
    this.align = TextAlign.center,
    this.italic = false,
    this.shadow,
    this.maxLines = 2,
  });

  final String text;
  final double size;
  final Color color;
  final FontWeight weight;
  final TextAlign align;
  final bool italic;
  final Shadow? shadow;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      style: _tpEventTextStyle(size, color, weight).copyWith(
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        shadows: shadow == null ? null : [shadow!],
      ),
    );
    final alignment = align == TextAlign.left
        ? Alignment.centerLeft
        : Alignment.center;
    return Align(
      alignment: alignment,
      child: FittedBox(
        alignment: alignment,
        fit: BoxFit.scaleDown,
        child: label,
      ),
    );
  }
}

class _TPEventRichText extends StatelessWidget {
  const _TPEventRichText({
    required this.color,
    required this.children,
    this.size = 14,
    this.height = 1.13,
    this.weight = FontWeight.normal,
  });

  final Color color;
  final List<InlineSpan> children;
  final double size;
  final double height;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) => Center(
    child: Text.rich(
      TextSpan(children: children),
      textAlign: TextAlign.center,
      style: _tpEventTextStyle(size, color, weight).copyWith(height: height),
    ),
  );
}

TextStyle _tpEventTextStyle(
  double size,
  Color color, [
  FontWeight weight = FontWeight.normal,
]) => TextStyle(
  fontFamily: TPFonts.family,
  color: color,
  fontSize: size,
  fontWeight: weight,
  height: 1.08,
  decoration: TextDecoration.none,
);

Widget _tpEventAt(
  double left,
  double top,
  double width,
  double height,
  Widget child, {
  TPDialogEffect? effect,
  Duration delay = Duration.zero,
  double rotation = 0,
}) {
  final oriented = rotation == 0
      ? child
      : Transform.rotate(angle: rotation, child: child);
  return Positioned(
    left: left,
    top: top,
    width: width,
    height: height,
    child: effect == null
        ? oriented
        : TPDialogMotion(effect: effect, delay: delay, child: oriented),
  );
}

Widget _tpEventClose(double top, VoidCallback onPressed) => _tpEventAt(
  165.5,
  top,
  44,
  44,
  TPDialogCloseButton(onPressed: onPressed),
  effect: TPDialogEffect.fade,
);
