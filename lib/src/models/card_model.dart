part of hyperpay;

class CardData {
  final String holder;
  final String cardNumber;
  final String cvv;
  final String expiryMonth;
  final String expiryYear;

  CardData({
    required this.holder,
    required this.cardNumber,
    required this.cvv,
    required this.expiryMonth,
    required this.expiryYear,
  });

  Map<String, String> toMap() {
    return {
      'holder': holder,
      'number': cardNumber,
      'cvv': cvv,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
    };
  }
}
