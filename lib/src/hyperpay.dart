part of hyperpay;

class HyperpaySetupResult {
  final bool success;
  final String msg;

  const HyperpaySetupResult(this.success, this.msg);
}

class HyperpayPayResult {
  final bool success;
  final String msg;

  const HyperpayPayResult(this.success, this.msg);
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
      log(e.toString());
      return HyperpaySetupResult(false, 'Hyperpay setup failed:\n $e');
    }
  }

  Future<HyperpayPayResult> pay(
      CardInfo card, String checkoutID, BrandType brand) async {
    try {
      await _channel.invokeMethod<String>('start_payment', {
        'checkoutID': checkoutID,
        'brand': brand.name.toUpperCase(),
        'card': card.toMap(),
      });
      return const HyperpayPayResult(true, 'Payment submitted');
    } catch (e) {
      log(e.toString());
      return HyperpayPayResult(false, 'Payment could not be submitted:\n $e');
    }
  }
}
