part of hyperpay;

class Hyperpay {
  Future<String?> getPlatformVersion() {
    return HyperpayPlatform.instance.getPlatformVersion();
  }

  Future<void> payTransaction(
      {required CardInfo card,
      required String checkoutID,
      required BrandType brand,
      required PaymentMode mode}) {
    return HyperpayPlatform.instance
        .payTransaction(card, checkoutID, brand.name.toUpperCase(), mode.name);
  }
}
