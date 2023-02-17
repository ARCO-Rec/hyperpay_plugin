part of hyperpay;

class HyperpayPlugin {
  final MethodChannel _channel;
  const HyperpayPlugin() : _channel = const MethodChannel('hyperpay');

  Future<void> pay(CardInfo card, String checkoutID, BrandType brand,
      PaymentMode mode) async {
    await _channel.invokeMethod<String>('start_payment', {
      'checkoutID': checkoutID,
      'brand': brand.name.toUpperCase(),
      'card': card.toMap(),
      'mode': mode.string,
    });
  }
}
