import 'package:hyperpay/models/card_model.dart';
import 'package:hyperpay/models/enums.dart';

import 'hyperpay_platform_interface.dart';

class Hyperpay {
  Future<String?> getPlatformVersion() {
    return HyperpayPlatform.instance.getPlatformVersion();
  }

  Future<void> payTransaction(
      {required CardData card,
      required String checkoutID,
      required BrandType brand,
      required PaymentMode mode}) {
    return HyperpayPlatform.instance
        .payTransaction(card, checkoutID, brand.name.toUpperCase(), mode.name);
  }
}
