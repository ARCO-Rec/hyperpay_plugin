part of '../flutter_hyperpay.dart';

/// Fetches checkout info for [checkoutId] from the server and returns the
/// shopper's saved cards (tokens), if any. Throws a [PlatformException] if
/// the request fails - callers should decide how to surface that (e.g. treat
/// it the same as "no saved cards").
Future<List<SavedCard>> implementGetCheckoutInfo({
  required String checkoutId,
  required String channelName,
  required PaymentMode paymentMode,
  required String lang,
  required String shopperResultUrl,
}) async {
  var platform = MethodChannel(channelName);
  final dynamic result = await platform.invokeMethod(
    PaymentConst.methodCall,
    getCheckoutInfoModel(
      checkoutId: checkoutId,
      shopperResultUrl: shopperResultUrl,
      paymentMode: paymentMode,
      lang: lang,
    ),
  );
  final tokens = result is Map ? result['tokens'] as List<dynamic>? : null;
  if (tokens == null) return [];
  return tokens
      .map((token) => SavedCard.fromMap(Map<dynamic, dynamic>.from(token as Map)))
      .toList();
}

/// Builds the method-channel argument map for a "GetCheckoutInfo" call.
Map<String, dynamic> getCheckoutInfoModel({
  required String checkoutId,
  required String shopperResultUrl,
  required PaymentMode paymentMode,
  required String lang,
}) {
  return {
    "type": PaymentConst.getCheckoutInfo,
    "mode": paymentMode.toString().split('.').last,
    "checkoutid": checkoutId,
    "lang": lang,
    "ShopperResultUrl": shopperResultUrl,
  };
}
