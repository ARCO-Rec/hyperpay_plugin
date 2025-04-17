part of  '../flutter_hyperpay.dart';

class ApplePaySettings {
  final String paymentType;
  final String checkoutId;
  final String merchantId;
  final String countryCode;
  final String currencyCode;
  final double amount;
  final String companyName;
  final String lang;
  final String hexColor;

  const ApplePaySettings({
    required this.checkoutId,
    required this.merchantId,
    required this.countryCode,
    required this.amount,
    required this.currencyCode,
    required this.companyName,
    required this.lang,
    required this.hexColor,
  }) : paymentType = PaymentConst.applePay;

  Map<String, dynamic> toJson() {
    return {
      "type": paymentType,
      "checkoutid": checkoutId,
      "merchantId": merchantId,
      "countryCode": countryCode,
      "currencyCode": currencyCode,
      "companyName": companyName,
      "lang": lang,
      "amount": amount,
      "themColorHexIOS": hexColor,
    };
  }
}
