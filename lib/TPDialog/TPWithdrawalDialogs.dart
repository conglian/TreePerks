import 'package:flutter/material.dart';

import '../TPTool/TPImg.dart';
import '../TPTool/TPResponsive.dart';
import '../TPTool/TPText.dart';
import 'TPDialogWidgets.dart';

const _tpWithdrawalArt = 'assets/image/dialog/cash/tp_dialog_';

/// 提现回执与收款账户核对共用的弹窗容器。
class TPWithdrawalDialog extends StatelessWidget {
  const TPWithdrawalDialog({
    super.key,
    required this.verifyPayoutAccount,
    required this.onClose,
  });

  final bool verifyPayoutAccount;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final verify = verifyPayoutAccount;
    return TPDialogStage(
      children: [
        if (verify) const _TPPayoutVerificationHeading(),
        Positioned(
          key: const ValueKey('tp-withdrawal-dialog-card'),
          left: verify ? 7 : 12,
          right: verify ? 7 : 12,
          top: verify ? 159 : 215,
          height: verify ? 543 : 486,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Stack(
                children: [
                  if (verify)
                    const _TPPayoutVerificationAmount()
                  else ...const [
                    _TPWithdrawalReceiptSummary(),
                    _TPWithdrawalReceiptNotes(),
                  ],
                  Positioned(
                    left: verify ? 10 : 20,
                    right: verify ? 5 : 20,
                    top: verify ? 104 : 90,
                    child: _TPWithdrawalRecordTable(verification: verify),
                  ),
                  Positioned(
                    left: verify ? 63 : 58,
                    top: verify ? 465 : 408,
                    width: 235,
                    height: 55,
                    child: TPDialogButton(
                      key: const ValueKey('tp-withdrawal-dialog-confirm'),
                      label: 'Confirm',
                      labelSize: 22,
                      onPressed: onClose,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!verify) const _TPWithdrawalReceiptHeading(),
        Positioned(
          left: 166,
          top: verify ? 716 : 723,
          child: TPDialogCloseButton(diameter: 32, onPressed: onClose),
        ),
      ],
    );
  }
}

/// 回执金额与插画位于回执卡片上方，插画轻弹后停在卡片边缘。
class _TPWithdrawalReceiptHeading extends StatelessWidget {
  const _TPWithdrawalReceiptHeading();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              left: 27,
              top: 135,
              width: 158,
              height: 54,
              child: TPDialogMotion(
                effect: TPDialogEffect.fade,
                child: TPText(
                  text: r'$100',
                  size: 48,
                  color: Color(0xFF03E155),
                  weight: FontWeight.w900,
                  align: TextAlign.left,
                ),
              ),
            ),
            Positioned(
              left: 27,
              top: 188,
              width: 166,
              height: 20,
              child: TPDialogMotion(
                effect: TPDialogEffect.fade,
                child: TPText(
                  text: 'Withdrawal Receipt',
                  size: 16,
                  color: Color(0xFFEEEEEE),
                  weight: FontWeight.w600,
                  align: TextAlign.left,
                ),
              ),
            ),
            Positioned(
              left: 201,
              top: 125.4,
              width: 153,
              height: 122,
              child: TPDialogMotion(
                effect: TPDialogEffect.celebration,
                delay: Duration(milliseconds: 100),
                child: TPImg(
                  name: '${_tpWithdrawalArt}receipt_hero.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              left: 85,
              right: 85,
              top: 785,
              height: 15,
              child: TPText(
                text: r'Accumulate $100 to withdraw.',
                size: 12,
                color: Color(0x80000000),
                weight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 收款账户核对的蓝色标题区与钱包插画。
class _TPPayoutVerificationHeading extends StatelessWidget {
  const _TPPayoutVerificationHeading();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              left: 7,
              right: 7,
              top: 83,
              height: 160,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2C3EA4), Color(0xFF11173E)],
                    stops: [.214, .867],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 6,
              top: 59,
              width: 130,
              height: 120,
              child: TPDialogMotion(
                effect: TPDialogEffect.rise,
                delay: Duration(milliseconds: 90),
                child: TPImg(
                  name: '${_tpWithdrawalArt}payout_verify_wallet.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              left: 149,
              right: 18,
              top: 100,
              height: 19,
              child: TPText(
                text: 'Please verify your',
                size: 16,
                color: Colors.white,
                weight: FontWeight.w700,
                align: TextAlign.left,
              ),
            ),
            Positioned(
              left: 149,
              right: 18,
              top: 118,
              height: 30,
              child: TPText(
                text: 'payout account!',
                size: 26,
                color: Color(0xFF47EDFF),
                weight: FontWeight.w700,
                align: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TPPayoutVerificationAmount extends StatelessWidget {
  const _TPPayoutVerificationAmount();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      left: 16,
      right: 16,
      top: 19,
      height: 86,
      child: Column(
        children: [
          SizedBox(
            height: 24,
            child: TPText(
              text: 'Withdrawal Amount',
              size: 20,
              color: Color(0xFF1E1F47),
              weight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Expanded(
            child: TPFitText(
              align: TextAlign.center,
              span: TextSpan(
                style: TextStyle(
                  fontSize: 48,
                  color: Color(0xFF00A73E),
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(text: r'$', style: TextStyle(fontSize: 32)),
                  TextSpan(text: '1000'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TPWithdrawalReceiptSummary extends StatelessWidget {
  const _TPWithdrawalReceiptSummary();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      left: 0,
      right: 0,
      top: 27,
      height: 49,
      child: Stack(
        children: [
          Positioned(
            left: 15,
            width: 152,
            top: 3,
            height: 42,
            child: _TPWithdrawalSummaryCell(
              label: 'Request Type',
              value: 'Promotional',
              icon: 'receipt_request_type',
              tint: Color(0xFFE2EDFD),
              gap: 14,
            ),
          ),
          Positioned(
            left: 175,
            top: 0,
            width: 1,
            height: 49,
            child: ColoredBox(color: Color(0xFFC5CBDB)),
          ),
          Positioned(
            left: 196,
            right: 7,
            top: 3,
            height: 42,
            child: _TPWithdrawalSummaryCell(
              label: 'Request Status',
              value: 'Received',
              icon: 'receipt_request_status',
              tint: Color(0xFFD4F6E0),
              gap: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _TPWithdrawalSummaryCell extends StatelessWidget {
  const _TPWithdrawalSummaryCell({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    required this.gap,
  });

  final String label;
  final String value;
  final String icon;
  final Color tint;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
          child: SizedBox.square(
            dimension: 42,
            child: Center(
              child: TPImg(name: '$_tpWithdrawalArt$icon.png', size: 24),
            ),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TPText(
                text: label,
                size: 14,
                color: const Color(0xFF828599),
                weight: FontWeight.w500,
                align: TextAlign.left,
              ),
              TPText(
                text: value,
                size: 16,
                color: Colors.black,
                weight: FontWeight.w700,
                align: TextAlign.left,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 两种提现状态的详情行共用同一套图标、标签和右对齐数值布局。
class _TPWithdrawalRecordTable extends StatelessWidget {
  const _TPWithdrawalRecordTable({required this.verification});

  static const _receiptRows = [
    ('receipt_account', 'Account', 'Player_aK9x2M', Size(15, 18)),
    ('receipt_request_id', 'Request ID', '1234567899', Size(15.3, 18)),
    ('receipt_amount', 'Amount', r'$100', Size(17, 18)),
    ('receipt_method', 'Payment Method', 'Cash App', Size(17, 14)),
  ];
  static const _verificationRows = [
    ('payout_verify_platform', 'Payout Platform', 'TreePerks', Size(18, 16)),
    (
      'payout_verify_instructions',
      'Payout Instructions',
      'Game rewards',
      Size(13.5, 18),
    ),
    ('payout_verify_creation_time', 'Creation time', 'xxx.xx.xx', Size(18, 18)),
    (
      'payout_verify_account',
      'Account information',
      'xxxx...xxxx',
      Size(14, 17),
    ),
    ('payout_verify_frequency', 'Frequency', 'One Time', Size(17.3, 17.3)),
    ('payout_verify_payment', 'Payment method', 'PayPal', Size(18, 14)),
  ];

  final bool verification;

  @override
  Widget build(BuildContext context) {
    final rows = verification ? _verificationRows : _receiptRows;
    final labelColor = verification
        ? const Color(0xFF797F96)
        : const Color(0xFF858A9C);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, (icon, label, value, size)) in rows.indexed)
          SizedBox(
            height: verification ? 59 : 47.5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (index < rows.length - 1)
                  Positioned(
                    left: verification ? 0 : 3,
                    right: 0,
                    bottom: verification ? 4 : 0,
                    height: 1,
                    child: const ColoredBox(color: Color(0xFFF0F3F9)),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    left: verification ? 4 : 0,
                    right: verification ? 24 : 9,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: verification ? 40 : 38,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _TPWithdrawalRowIcon(
                            art: icon,
                            size: size,
                            tinted: verification,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TPText(
                          text: label,
                          size: 16,
                          color: labelColor,
                          weight: FontWeight.w500,
                          align: TextAlign.left,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (index == rows.length - 1)
                        Semantics(
                          image: true,
                          label: value,
                          child: verification
                              ? const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: TPImg(
                                    name:
                                        '${_tpWithdrawalArt}payout_verify_paypal.png',
                                    width: 102,
                                    height: 31,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : const TPImg(
                                  name:
                                      '${_tpWithdrawalArt}receipt_cashapp.png',
                                  width: 59.1,
                                  height: 33.4,
                                  fit: BoxFit.contain,
                                ),
                        )
                      else
                        SizedBox(
                          width: 132,
                          child: TPText(
                            text: value,
                            size: 16,
                            color: Colors.black,
                            weight: FontWeight.w600,
                            align: TextAlign.right,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TPWithdrawalRowIcon extends StatelessWidget {
  const _TPWithdrawalRowIcon({
    required this.art,
    required this.size,
    required this.tinted,
  });

  final String art;
  final Size size;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final glyph = TPImg(
      name: '$_tpWithdrawalArt$art.png',
      width: size.width,
      height: size.height,
      fit: BoxFit.contain,
    );
    if (!tinted) return glyph;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFE3EFFD),
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(dimension: 30, child: Center(child: glyph)),
    );
  }
}

class _TPWithdrawalReceiptNotes extends StatelessWidget {
  const _TPWithdrawalReceiptNotes();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      left: 20,
      right: 20,
      top: 292,
      height: 88,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF4CD), Color(0xFFFFF7DA)],
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
          border: Border.fromBorderSide(
            BorderSide(color: Color(0xFFFFCE0F), width: .5),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 6,
              top: 5,
              width: 45,
              height: 45,
              child: TPImg(name: '${_tpWithdrawalArt}receipt_notes.png'),
            ),
            Positioned(
              left: 59,
              top: 17,
              width: 100,
              height: 20,
              child: TPText(
                text: 'Notes',
                size: 16,
                color: Color(0xFF652A06),
                weight: FontWeight.w700,
                align: TextAlign.left,
              ),
            ),
            Positioned(
              left: 11,
              right: 11,
              top: 46,
              height: 35,
              child: TPFitText(
                maxLines: 2,
                span: TextSpan(
                  style: TextStyle(
                    color: Color(0xFF4C4851),
                    fontSize: 14,
                    height: 1.15,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'Your withdrawal request has been received.\n'
                          'Withdraw directly once you reach ',
                    ),
                    TextSpan(
                      text: r'$100',
                      style: TextStyle(
                        color: Color(0xFF21A645),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: '.'),
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
