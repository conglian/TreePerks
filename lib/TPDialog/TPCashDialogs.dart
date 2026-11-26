import 'package:flutter/material.dart';

import '../TPTool/TPImg.dart';
import '../TPTool/TPResponsive.dart';
import '../TPTool/TPText.dart';
import 'TPDialogWidgets.dart';
import 'TPWithdrawalDialogs.dart';

enum TPCashDialogKind {
  /// 广告主审核中的金额与进度。
  advertiserReview,

  /// 提现前需要核验地区的提示。
  regionVerification,

  /// 展示提现处理的三个环节。
  withdrawalSteps,

  /// 选择并确认收款平台。
  paymentConfirmation,

  /// 提现申请正在处理中。
  applicationProgress,

  /// 提现申请已进入等待队列。
  applicationQueued,

  /// 提现前进行人工验证。
  humanVerification,

  /// 提现申请已成功提交。
  applicationSuccess,

  /// 提醒用户达到可提现里程碑。
  withdrawalReminder,

  /// 展示已收到的提现请求及回执详情。
  withdrawalReceipt,

  /// 展示待确认的收款账户及提现信息。
  payoutAccountVerification,
}

/// 提现弹窗的独立界面。状态由调用方提供，操作通过回调返回。
class TPCashDialog extends StatelessWidget {
  const TPCashDialog({
    super.key,
    required this.kind,
    required this.onClose,
    this.onNext,
    this.onPaymentSelected,
  });

  final TPCashDialogKind kind;
  final VoidCallback onClose;
  final ValueChanged<TPCashDialogKind>? onNext;
  final ValueChanged<int>? onPaymentSelected;

  void _advance(TPCashDialogKind next) {
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
      TPCashDialogKind.advertiserReview ||
      TPCashDialogKind.regionVerification ||
      TPCashDialogKind.withdrawalSteps => _TPCashReview(
        kind: kind,
        onPressed: kind == TPCashDialogKind.regionVerification
            ? () => _advance(TPCashDialogKind.withdrawalSteps)
            : () => _advance(TPCashDialogKind.paymentConfirmation),
      ),
      TPCashDialogKind.paymentConfirmation => _TPCashPayment(
        onClose: onClose,
        onPaymentSelected: onPaymentSelected,
      ),
      TPCashDialogKind.applicationProgress ||
      TPCashDialogKind.applicationQueued => _TPCashApplication(
        queued: kind == TPCashDialogKind.applicationQueued,
        onPressed: kind == TPCashDialogKind.applicationProgress
            ? () => _advance(TPCashDialogKind.applicationQueued)
            : onClose,
      ),
      TPCashDialogKind.humanVerification ||
      TPCashDialogKind.applicationSuccess => _TPCashTask(
        success: kind == TPCashDialogKind.applicationSuccess,
        onClose: onClose,
      ),
      TPCashDialogKind.withdrawalReminder => _TPCashMilestone(
        onClaim: () => _advance(TPCashDialogKind.paymentConfirmation),
        onClose: onClose,
      ),
      TPCashDialogKind.withdrawalReceipt ||
      TPCashDialogKind.payoutAccountVerification => TPWithdrawalDialog(
        verifyPayoutAccount: kind == TPCashDialogKind.payoutAccountVerification,
        onClose: onClose,
      ),
    };
  }
}

const _cashDialogDirectory = 'assets/image/dialog/cash';
const _rewardDialogDirectory = 'assets/image/dialog/reward';
const _cashGreen = Color(0xFF129944);

class _TPCashReview extends StatelessWidget {
  const _TPCashReview({required this.kind, required this.onPressed});

  final TPCashDialogKind kind;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final (title, top, height, buttonTop, label, detail) = switch (kind) {
      TPCashDialogKind.regionVerification => (
        'Oops! Just One More Step!',
        241.0,
        330.0,
        610.0,
        'Verify Now',
        const _TPCashRegionDetails(),
      ),
      TPCashDialogKind.withdrawalSteps => (
        'Amount Awaiting Withdrawal',
        211.0,
        380.0,
        630.0,
        'The Final Step',
        const _TPCashWithdrawalDetails(),
      ),
      _ => (
        'Advertiser Under Review…',
        261.0,
        290.0,
        null,
        '',
        const _TPCashAdvertiserDetails(),
      ),
    };

    return TPDialogStage(
      children: [
        Positioned(
          left: 31,
          top: top,
          width: 313,
          height: height,
          child: TPDialogMotion(
            key: ValueKey(kind),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Transform.rotate(
                    angle: -.03,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF23B140),
                            Color(0xFF0C8427),
                            Color(0xFF21B640),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4D002E11),
                            blurRadius: 15,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 13,
                  top: 56,
                  right: 12,
                  bottom: 17,
                  child: _TPCashPanel(
                    radius: const BorderRadius.all(Radius.circular(17)),
                    child: detail,
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  top: 16,
                  height: 35,
                  child: _TPCashText(
                    title,
                    size: 21,
                    color: Colors.white,
                    weight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (buttonTop != null)
          Positioned(
            left: 70,
            top: buttonTop,
            width: 235,
            height: 55,
            child: TPDialogMotion(
              effect: TPDialogEffect.rise,
              delay: const Duration(milliseconds: 175),
              child: TPDialogButton(label: label, onPressed: onPressed),
            ),
          ),
        if (kind == TPCashDialogKind.withdrawalSteps)
          Positioned(
            left: 237,
            top: 615,
            width: 80,
            height: 24,
            child: TPDialogMotion(
              delay: const Duration(milliseconds: 235),
              child: _TPCashPanel(
                color: const Color(0xFFFF6C15),
                radius: BorderRadius.circular(13),
                child: const _TPCashText(
                  'In Progress',
                  size: 12,
                  color: Color(0xFFFFFF91),
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TPCashAdvertiserDetails extends StatelessWidget {
  const _TPCashAdvertiserDetails();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 96,
          top: 20,
          width: 91,
          height: 27,
          child: TPImg(
            name: 'assets/image/cash/tp_cash_paypal_idle.png',
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          left: 38,
          right: 38,
          top: 64,
          height: 70,
          child: _TPCashAmount(r'$ 500'),
        ),
        Positioned(left: 27, right: 27, top: 156, child: _TPCashDivider()),
        Positioned(
          left: 28,
          right: 27,
          top: 168,
          child: _TPCashProgress(value: .74, height: 8),
        ),
        Positioned(
          left: 22,
          right: 22,
          top: 183,
          height: 27,
          child: _TPCashText('Under Review…', size: 14),
        ),
      ],
    );
  }
}

class _TPCashRegionDetails extends StatelessWidget {
  const _TPCashRegionDetails();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 16,
          right: 16,
          top: 16,
          height: 29,
          child: _TPCashText(
            'Advertiser Review Isn’t Complete.',
            size: 14,
            weight: FontWeight.w600,
          ),
        ),
        Positioned(
          left: 46,
          top: 40,
          width: 188,
          height: 136,
          child: TPDialogMotion(
            effect: TPDialogEffect.celebration,
            delay: Duration(milliseconds: 160),
            child: _TPCashImage('region_pin'),
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          top: 170,
          height: 69,
          child: _TPCashText(
            'We detected that your current IP region [XXX] may be linked to higher withdrawal risk.',
            size: 14,
            color: Color(0xFF595A67),
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}

class _TPCashWithdrawalDetails extends StatelessWidget {
  const _TPCashWithdrawalDetails();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          left: 15,
          right: 15,
          top: 15,
          height: 28,
          child: _TPCashText(
            'Withdrawal Amount',
            size: 14,
            weight: FontWeight.w700,
          ),
        ),
        const Positioned(
          left: 33,
          right: 33,
          top: 44,
          height: 66,
          child: _TPCashAmount(r'$ 500'),
        ),
        const Positioned(
          left: 25,
          right: 25,
          top: 121,
          child: _TPCashDivider(),
        ),
        for (final (i, step, description) in [
          (0, 'Step 1', 'Payment Preparation'),
          (1, 'Step 2', 'Payment Acceptance'),
          (2, 'Final', 'Amount Received'),
        ])
          Positioned(
            left: 13,
            right: 13,
            top: 134 + i * 54.0,
            height: 46,
            child: TPDialogMotion(
              effect: TPDialogEffect.rise,
              delay: Duration(milliseconds: 100 + i * 100),
              child: _TPCashStepRow(
                heading: step,
                description: description,
                finished: i != 2,
              ),
            ),
          ),
      ],
    );
  }
}

class _TPCashStepRow extends StatelessWidget {
  const _TPCashStepRow({
    required this.heading,
    required this.description,
    required this.finished,
  });

  final String heading;
  final String description;
  final bool finished;

  @override
  Widget build(BuildContext context) {
    return _TPCashPanel(
      color: finished ? const Color(0xFFEFFFEA) : const Color(0xFFF6F6F6),
      radius: BorderRadius.circular(8),
      child: Stack(
        children: [
          if (!finished)
            const Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 209,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  gradient: LinearGradient(
                    colors: [Color(0xFF96FF93), Color(0xFFD8FF9D)],
                  ),
                ),
              ),
            ),
          Positioned(
            left: 14,
            right: 52,
            top: 7,
            height: 16,
            child: _TPCashText(
              heading,
              size: 13,
              align: TextAlign.start,
              weight: FontWeight.w700,
            ),
          ),
          Positioned(
            left: 14,
            right: 52,
            top: 24,
            height: 14,
            child: _TPCashText(description, size: 11, align: TextAlign.start),
          ),
          if (finished) ...[
            const Positioned(
              right: 14,
              top: 4,
              child: Icon(
                Icons.check_circle_outline,
                color: _cashGreen,
                size: 25,
              ),
            ),
            const Positioned(
              right: 8,
              top: 30,
              width: 40,
              height: 10,
              child: _TPCashText('Completed', size: 7, color: _cashGreen),
            ),
          ],
        ],
      ),
    );
  }
}

class _TPCashPayment extends StatefulWidget {
  const _TPCashPayment({
    required this.onClose,
    required this.onPaymentSelected,
  });

  final VoidCallback onClose;
  final ValueChanged<int>? onPaymentSelected;

  @override
  State<_TPCashPayment> createState() => _TPCashPaymentState();
}

class _TPCashPaymentState extends State<_TPCashPayment> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 311,
          bottom: 0,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            child: Stack(
              children: [
                const Positioned(
                  left: 6,
                  top: 0,
                  width: 362,
                  height: 362,
                  child: TPImg(
                    name: '$_rewardDialogDirectory/tp_dialog_premium_rays.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const _TPCashBillDecoration(top: 46, wide: true),
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 93,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF0C8426), Color(0xFF22D63D)],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(26),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 20,
                  right: 20,
                  top: 111,
                  height: 29,
                  child: _TPCashText(
                    'Please Confirm Your Payment Method',
                    size: 16,
                    color: Colors.white,
                    weight: FontWeight.w800,
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  top: 139,
                  height: 18,
                  child: _TPCashText(
                    'After you reach \$100, we’ll send your payment via '
                    '${_selected == 0 ? 'PayPal' : 'Cash App'}.',
                    size: 12,
                    color: Colors.white,
                    weight: FontWeight.w700,
                  ),
                ),
                const Positioned(
                  left: 7,
                  right: 7,
                  top: 167,
                  bottom: 0,
                  child: _TPCashPanel(
                    radius: BorderRadius.vertical(top: Radius.circular(23)),
                  ),
                ),
                const Positioned(
                  left: 16,
                  right: 16,
                  top: 181,
                  height: 36,
                  child: _TPCashText(
                    'Current Cash-Out Platform',
                    size: 20,
                    weight: FontWeight.w700,
                  ),
                ),
                const Positioned(
                  left: 18,
                  right: 18,
                  top: 227,
                  child: _TPCashDivider(),
                ),
                for (var method = 0; method < 2; method++)
                  Positioned(
                    left: 12,
                    right: 11,
                    top: 244 + 70.0 * method,
                    height: 60,
                    child: _TPCashMethod(
                      cashApp: method == 1,
                      selected: _selected == method,
                      onTap: () => setState(() => _selected = method),
                    ),
                  ),
                Positioned(
                  left: 70,
                  top: 397,
                  width: 235,
                  height: 55,
                  child: TPDialogButton(
                    label: 'Click To Confirm',
                    onPressed: () {
                      widget.onPaymentSelected?.call(_selected);
                      widget.onClose();
                    },
                  ),
                ),
                const Positioned(
                  left: 17,
                  right: 17,
                  top: 460,
                  height: 27,
                  child: _TPCashText(
                    r'Accumulate $100 To Withdraw.',
                    size: 14,
                    color: Color(0xFFA3A3A3),
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

class _TPCashMethod extends StatelessWidget {
  const _TPCashMethod({
    required this.cashApp,
    required this.selected,
    required this.onTap,
  });

  final bool cashApp;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = cashApp ? 'Cash App' : 'PayPal';
    final radius = BorderRadius.circular(12);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 170);
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: AnimatedContainer(
            duration: duration,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFEDF5FE) : Colors.white,
              borderRadius: radius,
              border: Border.all(
                color: selected
                    ? const Color(0xFFC8DDFD)
                    : const Color(0xFFF2F3F5),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: cashApp ? 134 : 113,
                      height: 30,
                      child: TPImg(
                        name: cashApp
                            ? 'assets/image/cash/tp_cash_cashapp_idle.png'
                            : 'assets/image/cash/tp_cash_paypal_idle.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected
                      ? const Color(0xFF0B9C35)
                      : const Color(0xFFE4E8EC),
                  size: 31,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TPCashApplication extends StatelessWidget {
  const _TPCashApplication({required this.queued, required this.onPressed});

  final bool queued;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        Positioned(
          left: 66,
          top: 242,
          width: 244,
          height: 134,
          child: TPDialogMotion(
            effect: TPDialogEffect.celebration,
            child: _TPCashApplicationArtwork(queued: queued),
          ),
        ),
        if (!queued)
          const Positioned(
            left: 36,
            right: 35,
            top: 374,
            child: _TPCashProgress(
              value: .6,
              height: 6,
              fill: Color(0xFF26FFCC),
              track: Color(0x80D9D9D9),
              showPercentage: true,
            ),
          ),
        Positioned(
          left: 21,
          right: 21,
          top: queued ? 399 : 447,
          height: 51,
          child: const _TPCashText(
            'Due to a high number of requests, processing may take a bit longer.',
            size: 16,
            maxLines: 2,
            color: Color(0xFFB7B7B7),
          ),
        ),
        Positioned(
          left: 70,
          top: queued ? 493 : 533,
          width: 235,
          height: 55,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            delay: const Duration(milliseconds: 185),
            child: TPDialogButton(label: 'Skip Now', onPressed: onPressed),
          ),
        ),
        Positioned(
          left: 269,
          top: queued ? 478 : 518,
          width: 36,
          height: 35,
          child: const IgnorePointer(child: _TPCashAdBadge()),
        ),
      ],
    );
  }
}

class _TPCashApplicationArtwork extends StatelessWidget {
  const _TPCashApplicationArtwork({required this.queued});

  static const _hourglassEnd = .4;
  final bool queued;

  @override
  Widget build(BuildContext context) {
    final target = queued ? 1.0 : 0.0;
    if (MediaQuery.disableAnimationsOf(context)) return _artwork(target);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: target, end: target),
      duration: const Duration(milliseconds: 340),
      builder: (context, progress, child) => _artwork(progress),
    );
  }

  Widget _artwork(double progress) {
    if (progress < _hourglassEnd) {
      final fade = Curves.easeIn.transform(progress / _hourglassEnd);
      return Opacity(
        key: const ValueKey('tp-cash-application-hourglass'),
        opacity: 1 - fade,
        child: const _TPCashImage('application_hourglass'),
      );
    }

    final reveal = (progress - _hourglassEnd) / (1 - _hourglassEnd);
    return Stack(
      children: [
        Positioned(
          left: 63,
          top: 9,
          width: 118,
          height: 119,
          child: Opacity(
            key: const ValueKey('tp-cash-application-check'),
            opacity: Curves.easeOut.transform(reveal),
            child: Transform.scale(
              scale: .84 + .16 * Curves.easeOutBack.transform(reveal),
              child: const _TPCashImage('application_check'),
            ),
          ),
        ),
      ],
    );
  }
}

class _TPCashTask extends StatelessWidget {
  const _TPCashTask({required this.success, required this.onClose});

  final bool success;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final panelTop = success ? 302.0 : 272.0;
    return TPDialogStage(
      children: [
        Positioned(
          left: 45,
          right: 44,
          top: panelTop - 20,
          height: 86,
          child: const _TPCashPanel(color: Color(0xFF3756F9)),
        ),
        _TPCashBillDecoration(top: panelTop - 57),
        Positioned(
          left: success ? 174 : 168,
          top: success ? 195 : 157,
          width: success ? 166 : 162,
          height: success ? 166 : 162,
          child: TPDialogMotion(
            key: ValueKey(success),
            effect: TPDialogEffect.celebration,
            delay: const Duration(milliseconds: 95),
            child: _TPCashImage(success ? 'success_art' : 'verification_art'),
          ),
        ),
        Positioned(
          left: 34,
          top: panelTop,
          width: 308,
          height: success ? 294 : 314,
          child: const TPDialogMotion(
            effect: TPDialogEffect.rise,
            child: _TPCashPanel(),
          ),
        ),
        Positioned(
          left: 47,
          right: 47,
          top: panelTop + 39,
          height: 34,
          child: _TPCashText(
            success ? 'Application Successful' : 'Human Verification',
            weight: FontWeight.w800,
            size: 20,
          ),
        ),
        if (success)
          const Positioned(
            left: 56,
            right: 52,
            top: 400,
            height: 108,
            child: _TPCashText(
              '•  7-14 Working Days After Application.\n'
              '•  A 1% Fee Applies Per Withdrawal.\n'
              '•  Keep Growing Your Wealth While You Wait.',
              size: 14,
              maxLines: 5,
              align: TextAlign.start,
              lineHeight: 1.55,
            ),
          )
        else ...[
          const Positioned(
            left: 55,
            top: 372,
            width: 265,
            height: 59,
            child: _TPCashVerificationRow(),
          ),
          const Positioned(
            left: 53,
            right: 50,
            top: 450,
            height: 48,
            child: _TPCashText(
              'Please Complete Human Verification Before Withdrawing.',
              size: 16,
              maxLines: 2,
            ),
          ),
        ],
        Positioned(
          left: 70,
          top: success ? 522 : 510,
          width: 235,
          height: 55,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            delay: const Duration(milliseconds: 160),
            child: TPDialogButton(label: 'Confirm', onPressed: onClose),
          ),
        ),
        Positioned(
          left: 166,
          top: success ? 631 : 610,
          child: TPDialogCloseButton(onPressed: onClose),
        ),
      ],
    );
  }
}

class _TPCashVerificationRow extends StatelessWidget {
  const _TPCashVerificationRow();

  @override
  Widget build(BuildContext context) {
    return const _TPCashPanel(
      color: Color(0xFFF5F8FC),
      radius: BorderRadius.all(Radius.circular(12)),
      child: Row(
        children: [
          SizedBox(width: 10),
          SizedBox.square(
            dimension: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(5),
                child: TPImg(
                  name: '$_rewardDialogDirectory/tp_dialog_premium_dice.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          _TPCashText('xxx 3/10 xxx', size: 14, weight: FontWeight.w700),
        ],
      ),
    );
  }
}

class _TPCashBillDecoration extends StatelessWidget {
  const _TPCashBillDecoration({required this.top, this.wide = false});

  final double top;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: wide ? 6 : 44,
      right: wide ? 6 : 33,
      top: top,
      height: 100,
      child: IgnorePointer(
        child: Stack(
          children: [
            for (final (index, left, y, angle, bent) in [
              (0, 0.0, 22.0, -.27, false),
              (1, 39.0, 30.0, .21, true),
              (2, 72.0, 8.0, -.48, false),
              (3, 108.0, 32.0, .23, true),
              (4, 146.0, 7.0, .43, false),
              (5, 191.0, 31.0, .53, true),
              (6, 228.0, 12.0, -.53, false),
              if (wide) (7, 294.0, 7.0, -.33, false),
            ])
              Positioned(
                left: left,
                top: y,
                width: wide ? 76 : 67,
                height: 65,
                child: TPDialogMotion(
                  effect: TPDialogEffect.rise,
                  delay: Duration(milliseconds: index * 24),
                  child: Transform.rotate(
                    angle: angle,
                    child: TPImg(
                      name: bent
                          ? '$_rewardDialogDirectory/tp_dialog_cash_money_bent.png'
                          : '$_rewardDialogDirectory/tp_dialog_cash_money.png',
                      fit: BoxFit.contain,
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

class _TPCashMilestone extends StatelessWidget {
  const _TPCashMilestone({required this.onClaim, required this.onClose});

  final VoidCallback onClaim;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return TPDialogStage(
      children: [
        Positioned(
          left: 35,
          top: 278,
          width: 305,
          height: 347,
          child: TPDialogMotion(
            child: ClipPath(
              clipper: const _TPCashTicketClip(),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, .53],
                    colors: [Color(0xFFC9EAFA), Colors.white],
                  ),
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          left: 73,
          top: 153,
          width: 229,
          height: 202,
          child: TPDialogMotion(
            effect: TPDialogEffect.celebration,
            delay: Duration(milliseconds: 110),
            child: _TPCashImage('milestone_gift'),
          ),
        ),
        const Positioned(
          left: 93,
          top: 298,
          width: 188,
          height: 75,
          child: TPDialogMotion(
            effect: TPDialogEffect.rise,
            delay: Duration(milliseconds: 220),
            child: _TPCashImage('milestone_header'),
          ),
        ),
        const Positioned(
          left: 294,
          top: 368,
          width: 52,
          height: 50,
          child: _TPCashImage('milestone_money_a'),
        ),
        const Positioned(
          left: 2,
          top: 304,
          width: 96,
          height: 86,
          child: _TPCashImage('milestone_money_b'),
        ),
        const Positioned(
          left: 90,
          right: 90,
          top: 375,
          height: 67,
          child: _TPCashAmount(r'$100', size: 49),
        ),
        const Positioned(
          left: 52,
          right: 51,
          top: 446,
          height: 48,
          child: TPFitText(
            align: TextAlign.center,
            maxLines: 2,
            span: TextSpan(
              style: TextStyle(color: Color(0xFF52586E), fontSize: 16),
              children: [
                TextSpan(text: "Your effort has paid off! You've earned "),
                TextSpan(
                  text: r'$100',
                  style: TextStyle(
                    color: Color(0xFF008D36),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(text: ' and are ready to withdraw.'),
              ],
            ),
          ),
        ),
        const Positioned(
          left: 51,
          right: 50,
          top: 500,
          child: _TPCashDivider(),
        ),
        Positioned(
          left: 70,
          top: 520,
          width: 235,
          height: 55,
          child: TPDialogButton(label: 'Claim My Reward', onPressed: onClaim),
        ),
        Positioned(
          left: 145,
          right: 145,
          top: 581,
          height: 37,
          child: TPUnderlineTextButton(
            text: 'Later',
            onPressed: onClose,
            textColor: const Color(0xFF797979),
            fontSize: 14,
          ),
        ),
        Positioned(
          left: 166,
          top: 649,
          child: TPDialogCloseButton(onPressed: onClose),
        ),
      ],
    );
  }
}

class _TPCashTicketClip extends CustomClipper<Path> {
  const _TPCashTicketClip();

  @override
  Path getClip(Size size) {
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
      );
    final punch = Path()
      ..addOval(Rect.fromCircle(center: const Offset(0, 261), radius: 6))
      ..addOval(Rect.fromCircle(center: Offset(size.width, 261), radius: 6));
    return Path.combine(PathOperation.difference, outline, punch);
  }

  @override
  bool shouldReclip(covariant _TPCashTicketClip oldClipper) => false;
}

class _TPCashImage extends StatelessWidget {
  const _TPCashImage(this.asset);
  final String asset;

  @override
  Widget build(BuildContext context) => TPImg(
    name: '$_cashDialogDirectory/tp_dialog_$asset.png',
    fit: BoxFit.contain,
  );
}

class _TPCashText extends StatelessWidget {
  const _TPCashText(
    this.text, {
    this.color = const Color(0xFF101216),
    this.size = 16,
    this.weight = FontWeight.w500,
    this.maxLines = 1,
    this.align = TextAlign.center,
    this.lineHeight = 1.15,
  });

  final String text;
  final Color color;
  final double size;
  final FontWeight weight;
  final int maxLines;
  final TextAlign align;
  final double lineHeight;

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
        height: lineHeight,
      ),
    ),
  );
}

class _TPCashAmount extends StatelessWidget {
  const _TPCashAmount(this.amount, {this.size = 64});
  final String amount;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TPFitText(
      align: TextAlign.center,
      span: TextSpan(
        style: TextStyle(
          fontSize: size,
          color: _cashGreen,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
        children: [
          TextSpan(
            text: r'$',
            style: TextStyle(fontSize: size * .58),
          ),
          TextSpan(text: amount.substring(1)),
        ],
      ),
    );
  }
}

class _TPCashProgress extends StatelessWidget {
  const _TPCashProgress({
    required this.value,
    required this.height,
    this.fill = _cashGreen,
    this.track = const Color(0xFFD1DDE2),
    this.showPercentage = false,
  });

  final double value;
  final double height;
  final Color fill;
  final Color track;
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return _content(value);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 775),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) => _content(progress),
    );
  }

  Widget _content(double progress) {
    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          minHeight: height,
          value: progress,
          color: fill,
          backgroundColor: track,
        ),
      ),
    );
    if (!showPercentage) return bar;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          key: const ValueKey('tp-cash-application-percentage'),
          width: 73,
          height: 24,
          child: ExcludeSemantics(
            child: _TPCashText(
              '${(progress * 100).round()}%',
              color: Colors.white,
              size: 15,
              weight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        bar,
      ],
    );
  }
}

class _TPCashDivider extends StatelessWidget {
  const _TPCashDivider();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 1,
    child: CustomPaint(painter: _TPCashDividerPainter()),
  );
}

class _TPCashDividerPainter extends CustomPainter {
  const _TPCashDividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFDDE4E8);
    for (var x = 0.0; x < size.width; x += 6) {
      canvas.drawLine(Offset(x, .5), Offset(x + 3, .5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TPCashDividerPainter oldDelegate) => false;
}

class _TPCashPanel extends StatelessWidget {
  const _TPCashPanel({
    this.color = Colors.white,
    this.radius = const BorderRadius.all(Radius.circular(24)),
    this.child,
  });

  final Color color;
  final BorderRadius radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: color, borderRadius: radius),
    child: child,
  );
}

class _TPCashAdBadge extends StatelessWidget {
  const _TPCashAdBadge();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned.fill(
          child: TPImg(
            name: 'assets/image/home/tp_home_ad.png',
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          left: 3,
          top: 12,
          right: 3,
          bottom: 0,
          child: _TPCashPanel(
            color: Color(0xFF28E8DF),
            radius: BorderRadius.all(Radius.circular(4)),
            child: _TPCashText(
              'AD',
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
