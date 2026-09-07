part of '../flutter_hyperpay.dart';

/// implementPaymentCustomUISTC is a method used to make online payments.
/// It requires the paymentMode, checkoutId, channelName, shopperResultUrl,
/// phoneNumber and lang to be passed as arguments for successful implementation.
/// It returns a PaymentResultData object with the paymentResult and errorString.
Future<PaymentResultData> implementPaymentCustomUISTC({
  required PaymentMode paymentMode,
  required String checkoutId,
  required String channelName,
  required String shopperResultUrl,
  required String phoneNumber,
  required String lang,
}) async {
  var platform = MethodChannel(channelName);
  try {
    // Must stay `dynamic` - see the identical comment in
    // implementPaymentStoredCards; a Map-shaped native result must reach
    // PaymentResultManger, not crash the MethodChannel's own internal cast.
    final dynamic result = await platform.invokeMethod(
      PaymentConst.methodCall,
      getCustomUiSTCModelCards(
          checkoutId: checkoutId,
          shopperResultUrl: shopperResultUrl,
          paymentMode: paymentMode,
          phoneNumber: phoneNumber,
          lang: lang),
    );
    return PaymentResultManger.getPaymentResult(result);
  } on PlatformException catch (e) {
    return PaymentResultManger.fromPlatformException(e);
  }
}

/// This method creates a map of parameters to be used for a custom UI STC (STC Pay) payment.
/// It requires the payment mode, phone number, checkout ID, language,
/// and shopper result URL as parameters. It returns a map containing data for the payment type,
/// mode, checkout id, phone number, language, and shopper result URL.
Map<String, String?> getCustomUiSTCModelCards({
  required PaymentMode paymentMode,
  required String phoneNumber,
  required String checkoutId,
  required String lang,
  required String shopperResultUrl,
}) {
  return {
    "type": PaymentConst.customUiSTC,
    "mode": paymentMode.toString().split('.').last,
    "checkoutid": checkoutId,
    "phone_number": phoneNumber,
    "lang": lang,
    "ShopperResultUrl": shopperResultUrl,
  };
}
