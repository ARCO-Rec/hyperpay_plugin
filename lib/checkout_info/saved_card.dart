part of '../flutter_hyperpay.dart';

/// A shopper's previously saved/tokenized card, as returned by
/// [FlutterHyperPay.getCheckoutInfo]. [tokenId] is what you pass back into
/// [StoredCards]/[FlutterHyperPay.payWithStoredCards] to charge this card again.
class SavedCard {
  final String tokenId;
  final String paymentBrand;
  final String? holder;
  final String? last4Digits;
  final String? expiryMonth;
  final String? expiryYear;

  SavedCard({
    required this.tokenId,
    required this.paymentBrand,
    this.holder,
    this.last4Digits,
    this.expiryMonth,
    this.expiryYear,
  });

  factory SavedCard.fromMap(Map<dynamic, dynamic> map) => SavedCard(
        tokenId: map['tokenId'] as String,
        paymentBrand: map['paymentBrand'] as String,
        holder: map['holder'] as String?,
        last4Digits: map['last4Digits'] as String?,
        expiryMonth: map['expiryMonth']?.toString(),
        expiryYear: map['expiryYear']?.toString(),
      );
}
