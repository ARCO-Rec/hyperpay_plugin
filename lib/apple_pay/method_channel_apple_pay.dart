part of 'apple_pay.dart';

Future<PaymentResultData> implementApplePay(
    {required ApplePaySettings settings}) async {
  String transactionStatus;
  var platform = const MethodChannel(PaymentConst.methodCall);
  try {
    final String? result = await platform.invokeMethod(
      PaymentConst.methodCall,
      settings.toJson(),
    );
    transactionStatus = '$result';
    return PaymentResultManger.getPaymentResult(transactionStatus);
  } on PlatformException catch (e) {
    transactionStatus = "${e.message}";
    return PaymentResultData(
        errorString: e.message, paymentResult: PaymentResult.error);
  }
}
