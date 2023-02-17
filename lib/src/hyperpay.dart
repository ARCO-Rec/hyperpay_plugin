part of hyperpay;

class HyperpayPlugin {
  HyperpayPlugin._();

  static const MethodChannel _channel = MethodChannel('hyperpay');

  static Future<void> pay(CardInfo card, String checkoutID, BrandType brand,
      PaymentMode mode) async {
    await _channel.invokeMethod<String>('start_payment', {
      'checkoutID': checkoutID,
      'brand': brand.name.toUpperCase(),
      'card': card.toMap(),
      'mode': mode.string,
    });
  }
}
