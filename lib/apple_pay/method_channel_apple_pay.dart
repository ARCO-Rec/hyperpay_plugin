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
        settings: settings,
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

Map<String, dynamic> getApplePayModel({
  required ApplePaySettings settings,
  required PaymentMode paymentMode,
}) {
  final map = settings.toJson();
  map["mode"] = paymentMode.toString().split('.').last;
  return map;
}
