part of '../flutter_hyperpay.dart';

/// This function is used to implement payment using stored cards.
/// The [brand] should be provided for the payment.
/// The [checkoutId] should be provided for the payment.
/// The [tokenId] should be provided for the payment.
/// The [cvv] should be provided for the payment.
/// The [channelName] should be provided for the payment.
/// The [shopperResultUrl] should be provided for the payment.
/// The [paymentMode] should be provided for the payment.
/// The [lang] should be provided for the payment.
/// It will return a [Future<PaymentResultData>] object that contains the payment result.
Future<PaymentResultData> implementPaymentStoredCards({
  required String? brand,
  required String checkoutId,
  required String tokenId,
  required String cvv,
  required String channelName,
  required String shopperResultUrl,
  required PaymentMode paymentMode,
  required String lang,
}) async {
  var platform = MethodChannel(channelName);
  try {
    // Must stay `dynamic` - a synchronous StoredCards payment has native
    // fetch the checkout info and return a Map (status + token/card fields),
    // not a bare String. Typing this as String? makes the MethodChannel's
    // own internal cast throw immediately on any such result, before
    // PaymentResultManger ever gets a chance to see it - see the identical,
    // already-fixed pattern in implementPaymentCustomUI/implementPayment.
    final dynamic result = await platform.invokeMethod(
      PaymentConst.methodCall,
      getPaymentWithCards(
          tokenId: tokenId,
          brand: brand,
          cvv: cvv,
          checkoutId: checkoutId,
          channelName: channelName,
          shopperResultUrl: shopperResultUrl,
          paymentMode: paymentMode,
          lang: lang),
    );
    return PaymentResultManger.getPaymentResult(result);
  } on PlatformException catch (e) {
    return PaymentResultManger.fromPlatformException(e);
  }
}

/// This function is used to get payment with cards with the required parameters.
/// It takes in an required brand, checkoutId, tokenId, cvv, channelName, shopperResultUrl,
/// paymentMode and lang and returns a map containing the type, mode, checkoutid,
/// brand, lang, ShopperResultUrl, TokenID and cvv.
Map<String, String?> getPaymentWithCards({
  required String? brand,
  required String checkoutId,
  required String tokenId,
  required String cvv,
  required String channelName,
  required String shopperResultUrl,
  required PaymentMode paymentMode,
  required String lang,
}) {
  return {
    "type": PaymentConst.storedCards,
    "mode": paymentMode.toString().split('.').last,
    "checkoutid": checkoutId,
    "brand": brand,
    "lang": lang,
    "ShopperResultUrl": shopperResultUrl,
    "TokenID": tokenId,
    "cvv": cvv,
  };
}
