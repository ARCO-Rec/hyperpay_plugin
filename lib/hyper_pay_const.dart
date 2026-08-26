part of 'flutter_hyperpay.dart';

/// This class contains different constants used in Payment APIs including
/// Apple Pay, Ready UI, Custom UI, Custom UI STC, Stored Cards, Method Call,
/// Success, Error, and Sync.
class PaymentConst {
  static const String applePay = "APPLEPAY";
  static const String readyUi = "ReadyUI";
  static const String customUi = "CustomUI";
  static const String customUiSTC = "CustomUISTC";
  static const String storedCards = "StoredCards";
  static const String getCheckoutInfo = "GetCheckoutInfo";
  static const String methodCall = "gethyperpayresponse";
  static const String success = "success";
  static const String error = "error";
  static const String sync = "Sync";
  static const String cancelled = "Cancelled";
}

/// This class contains constants representing various payment brands,
/// such as mada, applePay, credit, stcPay, masterCard, and visa.
class PaymentBrands {
  static const String mada = "MADA";
  static const String applePay = "APPLEPAY";
  static const String credit = "credit";
  static const String stcPay = "STC_PAY";
  static const String masterCard = "MASTERCARD";
  static const String visa = "VISA";
}

/// This class holds the data for a payment result,
/// containing an errorString (nullable) and a paymentResult object.
///
/// When the payment was made with tokenization enabled (a "save this card"
/// checkout), [tokenId] and the related card fields are populated with the
/// newly created saved-card token, if the native SDK was able to capture it.
class PaymentResultData {
  String? errorString;
  PaymentResult paymentResult;
  String? tokenId;
  String? paymentBrand;
  String? last4Digits;
  String? expiryMonth;
  String? expiryYear;

  PaymentResultData({
    this.errorString,
    required this.paymentResult,
    this.tokenId,
    this.paymentBrand,
    this.last4Digits,
    this.expiryMonth,
    this.expiryYear,
  });
}

/// This class is used to store the language constants used for Payment.
/// Constants include iOS's Arabic (ar) and English (en)
/// and Android's English (en_US) and Arabic (ar_AR).
class PaymentLang {
  static const String iosARLang = "ar";
  static const String iosENLang = "en";
  static const String androidENLang = "en_US";
  static const String androidARLang = "ar_AR";
}
