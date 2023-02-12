
import 'hyperpay_platform_interface.dart';

class Hyperpay {
  Future<String?> getPlatformVersion() {
    return HyperpayPlatform.instance.getPlatformVersion();
  }
}
