part of hyperpay;

/// An implementation of [HyperpayPlatform] that uses method channels.
class MethodChannelHyperpay extends HyperpayPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hyperpay');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> payTransaction(
      CardInfo card, String checkoutID, String brand, String mode) async {
    await methodChannel.invokeMethod<String>('start_payment', {
      'checkoutID': checkoutID,
      'brand': brand,
      'card': card.toMap(),
    });
  }
}
