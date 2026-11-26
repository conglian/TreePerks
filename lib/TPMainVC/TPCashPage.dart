import 'package:flutter/material.dart';

import '../TPBase/TPMainTabViewport.dart';
import '../TPTool/TPImg.dart';
import '../TPTool/TPPaymentConfig.dart';
import '../TPTool/TPResponsive.dart';
import '../TPTool/TPText.dart';
import 'TPHomePage.dart';

class TPCashPage extends StatefulWidget {
  const TPCashPage({super.key});

  static const backgroundColor = Color(0xFFF4F5F9);

  @override
  State<TPCashPage> createState() => _TPCashPageState();
}

class _TPCashPageState extends State<TPCashPage> {
  final _selectedOptions = List<int>.filled(TPPaymentConfig.methods.length, 0);

  void _requestWithdrawal() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Withdrawal is currently unavailable.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return TPMainTabViewport(
      backgroundColor: TPCashPage.backgroundColor,
      scrollKey: const ValueKey('tp-cash-scroll'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 3, 15, 5),
            child: Align(
              alignment: Alignment.centerRight,
              child: TPHomeSettings(),
            ),
          ),
          const _TPCashBalanceCard(),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 19,
                  child: TPText(
                    text: 'Select Withdrawal Method',
                    size: 16,
                    color: Color(0xFF070707),
                    weight: FontWeight.w600,
                    align: TextAlign.start,
                  ),
                ),
                const SizedBox(height: 20),
                for (
                  var method = 0;
                  method < TPPaymentConfig.methods.length;
                  method++
                ) ...[
                  Row(
                    children: [
                      for (var option = 0; option < 2; option++) ...[
                        if (option != 0) const SizedBox(width: 20),
                        Expanded(
                          child: _TPCashMethodCard(
                            key: ValueKey('tp-cash-method-$method-$option'),
                            method: method,
                            option: option,
                            selected: _selectedOptions[method] == option,
                            onTap: () => setState(
                              () => _selectedOptions[method] = option,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                const _TPCashInstructions(),
                const SizedBox(height: 36),
                SizedBox(
                  height: 56,
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      key: const ValueKey('tp-cash-withdraw'),
                      borderRadius: BorderRadius.circular(42),
                      onTap: _requestWithdrawal,
                      child: Center(
                        child: Ink(
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1759D3),
                            borderRadius: BorderRadius.all(Radius.circular(42)),
                          ),
                          child: const Center(
                            child: TPText(
                              text: 'Withdraw',
                              size: 20,
                              color: Colors.white,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}

String _tpCashAsset(String name) => 'assets/image/cash/tp_cash_$name.png';

class _TPCashBalanceCard extends StatelessWidget {
  const _TPCashBalanceCard();

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(12));
    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          Positioned.fill(
            left: 15,
            right: 15,
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
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TPImg(
                    name: _tpCashAsset('paypal_watermark'),
                    width: 157,
                    height: 140,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 11,
            top: 51,
            child: TPImg(name: _tpCashAsset('header_tab_fold'), size: 4),
          ),
          const Positioned(
            left: 10,
            top: 10,
            width: 56,
            height: 42,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Center(
                child: TPImg(
                  name: 'assets/image/home/tp_home_paypal.png',
                  width: 38,
                  height: 36,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const Positioned(
            top: 67,
            left: 27,
            right: 15,
            height: 48,
            child: TPFitText(
              span: TextSpan(
                style: TextStyle(fontSize: 36, color: Colors.white, height: 1),
                children: [
                  TextSpan(
                    text: r'$',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: '999.75',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 115,
            left: 29,
            right: 15,
            height: 14,
            child: TPText(
              text: 'ID : 6666666666666666',
              size: 12,
              color: Color(0xFFF9F9F9),
              weight: FontWeight.w400,
              align: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}

class _TPCashMethodCard extends StatelessWidget {
  const _TPCashMethodCard({
    super.key,
    required this.method,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final int method;
  final int option;
  final bool selected;
  final VoidCallback onTap;

  static final _amount = TPPaymentConfig.money(800, decimals: 0);

  @override
  Widget build(BuildContext context) {
    final isPayPal = method == 0;
    final brand = isPayPal ? 'paypal' : 'cashapp';
    final accent = isPayPal ? const Color(0xFF1F62E3) : const Color(0xFF10A624);
    final track = isPayPal ? const Color(0x33244C85) : const Color(0x330C5011);
    final logoSize = isPayPal
        ? (selected ? const Size(76, 22) : const Size(75, 20))
        : (selected ? const Size(74, 18.33) : const Size(73, 16.33));
    return Semantics(
      button: true,
      selected: selected,
      label:
          '${TPPaymentConfig.payment(method)} option ${option + 1}, $_amount',
      child: SizedBox(
        height: 95,
        child: Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isPayPal && selected ? accent : const Color(0xFFC2CBD7),
              width: 0.7,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 31,
                  child: Ink(
                    color: selected ? accent : const Color(0xFFF1F1F5),
                    child: Center(
                      child: TPImg(
                        name: _tpCashAsset(
                          '${brand}_${selected ? 'selected' : 'idle'}',
                        ),
                        width: logoSize.width,
                        height: logoSize.height,
                      ),
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: TPImg(
                      name: _tpCashAsset('${brand}_check'),
                      size: 21,
                    ),
                  ),
                Positioned(
                  top: 38,
                  left: 8,
                  right: 8,
                  height: 33,
                  child: TPText(
                    text: _amount,
                    size: 26.325,
                    color: const Color(0xFF010101),
                    weight: FontWeight.w700,
                  ),
                ),
                Positioned(
                  left: 10.5,
                  right: 15.5,
                  top: 77,
                  height: 6,
                  child: _TPCashProgressTrack(
                    value: option == 0 ? 1 / 3 : 1,
                    active: accent,
                    inactive: track,
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

class _TPCashInstructions extends StatelessWidget {
  const _TPCashInstructions();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 13),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        gradient: LinearGradient(
          begin: Alignment(-0.698, -1.864),
          end: Alignment(0.698, 1.864),
          stops: [0.33046, 1],
          colors: [Color(0xFF0084D0), Color(0xFF49D1F1)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 19,
            child: TPText(
              text: 'Withdrawal Instructions',
              size: 16,
              color: Colors.white,
              weight: FontWeight.w500,
              align: TextAlign.start,
            ),
          ),
          const SizedBox(height: 4),
          const SizedBox(
            height: 14,
            child: TPText(
              text: 'For Security, The Minimum Withdrawal Is XX.',
              size: 12,
              color: Color(0xFFC8FF00),
              weight: FontWeight.w400,
              align: TextAlign.start,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 54,
            padding: const EdgeInsets.fromLTRB(9, 12, 9, 10),
            decoration: const BoxDecoration(
              color: Color(0x40212D31),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 16,
                  child: TPFitText(
                    span: TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(text: r'$20 More Needed To Withdraw '),
                        TextSpan(
                          text: r'$100',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 7),
                Padding(
                  padding: EdgeInsets.only(left: 2),
                  child: SizedBox(
                    height: 9,
                    child: _TPCashProgressTrack(
                      value: 0.61,
                      active: Colors.white,
                      inactive: Color(0x80FFFFFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TPCashProgressTrack extends StatelessWidget {
  const _TPCashProgressTrack({
    required this.value,
    required this.active,
    required this.inactive,
  });

  final double value;
  final Color active;
  final Color inactive;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(36));
    return DecoratedBox(
      decoration: BoxDecoration(color: inactive, borderRadius: radius),
      child: FractionallySizedBox(
        widthFactor: value,
        heightFactor: 1,
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(color: active, borderRadius: radius),
        ),
      ),
    );
  }
}
