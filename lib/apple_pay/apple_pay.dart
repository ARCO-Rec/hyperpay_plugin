import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../flutter_hyperpay.dart';

part 'apple_pay_ui.dart';
part 'method_channel_apple_pay.dart';

class ApplePaySettings {
  final String paymentType;
  final String checkoutId;
  final String merchantId;
  final String countryCode;
  final String currencyCode;
  final String companyName;
  final String lang;
  final String hexColor;

  const ApplePaySettings({
    required this.checkoutId,
    required this.merchantId,
    required this.countryCode,
    required this.currencyCode,
    required this.companyName,
    required this.lang,
    required this.hexColor,
  }) : paymentType = PaymentConst.applePay;

  Map<String, dynamic> toJson() {
    return {
      "type": paymentType,
      "checkoutId": checkoutId,
      "merchantId": merchantId,
      "countryCode": countryCode,
      "currencyCode": currencyCode,
      "companyName": companyName,
      "lang": lang,
      "hexColor": hexColor,
    };
  }
}
