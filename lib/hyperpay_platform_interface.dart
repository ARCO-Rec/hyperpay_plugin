import 'package:hyperpay/models/card_model.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hyperpay_method_channel.dart';

abstract class HyperpayPlatform extends PlatformInterface {
  /// Constructs a HyperpayPlatform.
  HyperpayPlatform() : super(token: _token);

  static final Object _token = Object();

  static HyperpayPlatform _instance = MethodChannelHyperpay();

  /// The default instance of [HyperpayPlatform] to use.
  ///
  /// Defaults to [MethodChannelHyperpay].
  static HyperpayPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HyperpayPlatform] when
  /// they register themselves.
  static set instance(HyperpayPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> payTransaction(
      CardData card, String checkoutID, String brand, String mode) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
