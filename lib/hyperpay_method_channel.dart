import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hyperpay/models/card_model.dart';

import 'hyperpay_platform_interface.dart';

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
      CardData card, String checkoutID, String brand) async {
    await methodChannel.invokeMethod<String>('start_payment', {
      'checkoutID': checkoutID,
      'brand': brand,
      'card': card.toMap(),
    });
  }
}
