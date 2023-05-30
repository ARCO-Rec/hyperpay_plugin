part of 'apple_pay.dart';

Future<PaymentResultData> implementApplePay({
  required ApplePaySettings settings,
  required String channelName,
  required PaymentMode paymentMode,
}) async {
  String transactionStatus;
  final platform = MethodChannel(channelName);
  try {
    final String? result = await platform.invokeMethod(
      PaymentConst.methodCall,
      getApplePayModel(
        amount: settings.amount,
        brands: [PaymentBrands.applePay],
        checkoutId: settings.checkoutId,
        countryCode: settings.countryCode,
        companyName: settings.companyName,
        currencyCode: settings.currencyCode,
        lang: settings.lang,
        merchantId: settings.merchantId,
        setStorePaymentDetailsMode: false,
        shopperResultUrl: '',
        themColorHexIOS: settings.hexColor,
        paymentMode: paymentMode,
      ),
    );
    transactionStatus = '$result';
    return PaymentResultManger.getPaymentResult(transactionStatus);
  } on PlatformException catch (e) {
    transactionStatus = "${e.message}";
    return PaymentResultData(
        errorString: e.message, paymentResult: PaymentResult.error);
  }
}

Map<String, dynamic> getApplePayModel(
    {required List<String> brands,
    required String checkoutId,
    required String shopperResultUrl,
    required String lang,
    required double amount,
    required PaymentMode paymentMode,
    required String merchantId,
    required String countryCode,
    required String currencyCode,
    String? companyName = "",
    String? themColorHexIOS,
    required bool setStorePaymentDetailsMode}) {
  return {
    "amount": amount,
    "type": PaymentConst.applePay,
    "mode": paymentMode.toString().split('.').last,
    "checkoutid": checkoutId,
    "brand": brands,
    "lang": lang,
    "merchantId": merchantId,
    "countryCode": countryCode,
    "currencyCode": currencyCode,
    "companyName": companyName ?? "",
    "themColorHexIOS": themColorHexIOS ?? "",
    "ShopperResultUrl": shopperResultUrl,
    "setStorePaymentDetailsMode": setStorePaymentDetailsMode.toString(),
  };
}
