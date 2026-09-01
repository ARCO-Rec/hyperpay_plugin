part of '../flutter_hyperpay.dart';

/// This is an asynchronous function that implements a custom UI payment.
/// It takes parameters such as paymentMode, brand, checkoutId, channelName,
/// shopperResultUrl, lang, cardNumber, holderName, month, year, cvv and enabledTokenization.
/// It uses the MethodChannel class to invoke a payment method call with a custom UI payment model.
/// The function returns a PaymentResultData object with information on the payment transaction status.
/// If successful, it returns the payment result. If unsuccessful,
/// it returns the error string and payment result.
Future<PaymentResultData> implementPaymentCustomUI({
  required PaymentMode paymentMode,
  required String brand,
  required String checkoutId,
  required String channelName,
  required String shopperResultUrl,
  required String lang,
  required String cardNumber,
  required String holderName,
  required String month,
  required String year,
  required String cvv,
  required bool enabledTokenization,
}) async {
  var platform = MethodChannel(channelName);
  try {
    final dynamic result = await platform.invokeMethod(
      PaymentConst.methodCall,
      getCustomUiModelCards(
        brand: brand,
        checkoutId: checkoutId,
        shopperResultUrl: shopperResultUrl,
        paymentMode: paymentMode,
        cardNumber: cardNumber,
        holderName: holderName,
        month: month,
        year: year,
        cvv: cvv,
        lang: lang,
        enabledTokenization: enabledTokenization,
      ),
    );
    return PaymentResultManger.getPaymentResult(result);
  } on PlatformException catch (e) {
    return PaymentResultManger.fromPlatformException(e);
  }
}

/// This function is used to get the required customUi model cards for payment processing.
/// It takes all the essential information needed for the process,
/// like payment mode, brand, checkoutId, shopperResultUrl, lang, cardNumber,
/// holderName, month, year, cvv, and enabledTokenization.
/// It then generates and returns a map containing each of the data fields.
Map<String, String?> getCustomUiModelCards({
  required PaymentMode paymentMode,
  required String brand,
  required String checkoutId,
  required String shopperResultUrl,
  required String lang,
  required String cardNumber,
  required String holderName,
  required String month,
  required String year,
  required String cvv,
  required bool enabledTokenization,
}) {
  return {
    "type": PaymentConst.customUi,
    "mode": paymentMode.toString().split('.').last,
    "checkoutid": checkoutId,
    "brand": brand,
    "lang": lang,
    "card_number": cardNumber,
    "holder_name": holderName,
    "month": month.toString(),
    "year": year.toString(),
    "cvv": cvv.toString(),
    "EnabledTokenization": enabledTokenization.toString(),
    "ShopperResultUrl": shopperResultUrl,
  };
}
