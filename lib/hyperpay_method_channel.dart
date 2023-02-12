import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hyperpay_platform_interface.dart';

/// An implementation of [HyperpayPlatform] that uses method channels.
class MethodChannelHyperpay extends HyperpayPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hyperpay');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
