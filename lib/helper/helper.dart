part of '../flutter_hyperpay.dart';

/// PaymentResultManger is a class used to generate a PaymentResultData
/// object based on the paymentResult passed. It will return the respective paymentResult
/// with the errorString depending on the paymentResult passed.
class PaymentResultManger {
  /// [paymentResult] is either the plain status [String] native has always
  /// returned ("success"/"Sync"/"Cancelled"/...), or - when tokenization was
  /// enabled and the native SDK managed to capture the resulting token - a
  /// `Map` carrying a "status" entry plus the token/card fields.
  static PaymentResultData getPaymentResult(dynamic paymentResult) {
    if (paymentResult is Map) {
      final status = paymentResult['status']?.toString() ?? '';
      final data = _resultForStatus(status);
      data.tokenId = paymentResult['tokenId'] as String?;
      data.paymentBrand = paymentResult['paymentBrand'] as String?;
      data.last4Digits = paymentResult['last4Digits'] as String?;
      data.expiryMonth = paymentResult['expiryMonth']?.toString();
      data.expiryYear = paymentResult['expiryYear']?.toString();
      return data;
    }
    return _resultForStatus('$paymentResult');
  }

  static PaymentResultData _resultForStatus(String status) {
    if (status == PaymentConst.success) {
      return PaymentResultData(
          errorString: '', paymentResult: PaymentResult.success);
    } else if (status == PaymentConst.sync) {
      return PaymentResultData(
          errorString: '', paymentResult: PaymentResult.sync);
    } else if (status == PaymentConst.cancelled) {
      return PaymentResultData(
          errorString: '', paymentResult: PaymentResult.cancelled);
    } else {
      return PaymentResultData(
          errorString: '', paymentResult: PaymentResult.noResult);
    }
  }

  /// Builds a [PaymentResultData] from a [PlatformException] thrown by the
  /// native side (a real payment/validation failure, on either platform -
  /// `FlutterError`/`result.error(...)` both surface as this on the Dart
  /// side). Unlike [getPaymentResult]/[_resultForStatus] - which only ever
  /// recognize the plain success-path status strings and otherwise return
  /// an empty [PaymentResultData.errorString] no matter what was passed in
  /// - this preserves the real reason: [PlatformException.details] is where
  /// native puts the underlying SDK/server error description (see
  /// `SwiftPaymentPlugin.openCustomUI`'s `error?.localizedDescription`, and
  /// Android's `PaymentError.getErrorInfo()`), with [PlatformException.code]
  /// falling back for it when `details` is absent.
  static PaymentResultData fromPlatformException(PlatformException e) {
    final parts = [
      e.message,
      if (e.details != null) e.details.toString(),
    ].where((s) => s != null && s.isNotEmpty).toSet().join(': ');
    return PaymentResultData(
      errorString: parts.isEmpty ? e.code : parts,
      paymentResult: PaymentResult.error,
    );
  }
}
