part of hyperpay;

class HyperpaySetupResult {
  final bool success;
  final String msg;

  const HyperpaySetupResult(this.success, this.msg);
}

class HyperpayPlugin {
  final MethodChannel _channel;
  final PaymentMode mode;
  const HyperpayPlugin({required this.mode})
      : _channel = const MethodChannel('hyperpay');

  Future<HyperpaySetupResult> setup() async {
    try {
      await _channel.invokeMethod(
        'setup_service',
        {
          'mode': mode.string,
        },
      );
      return const HyperpaySetupResult(true, 'Hyperpay setup completed');
    } catch (e) {
      return HyperpaySetupResult(false, 'Hyperpay setup faile: $e');
    }
  }

  Future<void> pay(CardInfo card, String checkoutID, BrandType brand) async {
    await _channel.invokeMethod<String>('start_payment', {
      'checkoutID': checkoutID,
      'brand': brand.name.toUpperCase(),
      'card': card.toMap(),
    });
  }
}
