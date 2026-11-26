import 'package:intl/intl.dart';

/// Default payment methods and USD formatting, independent of device language.
class TPPaymentConfig {
  static const methods = ['PayPal', 'Cash App'];
  static const _assets = ['paypal', 'cashapp'];

  static int paymentIndex(int index) =>
      index >= 0 && index < methods.length ? index : 0;

  static String payment(int index) => methods[paymentIndex(index)];

  static String paymentAsset(int index, {String variant = 'normal'}) =>
      'tp_payment_${_assets[paymentIndex(index)]}_$variant';

  static String money(num value, {int decimals = 2}) {
    final format = NumberFormat('#,##0', 'en_US')
      ..minimumFractionDigits = decimals
      ..maximumFractionDigits = decimals;
    return '\$${format.format(value)}';
  }
}
