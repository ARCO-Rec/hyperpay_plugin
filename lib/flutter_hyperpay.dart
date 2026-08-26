import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'apple_pay/apple_pay.dart';
part 'apple_pay/apple_pay_ui.dart';
part 'apple_pay/method_channel_apple_pay.dart';
part 'hyper_pay_const.dart';
part 'helper/helper.dart';
part 'ready_ui/method_channel_ready_ui.dart';
part 'ready_ui/ready_ui.dart';
part 'custom_ui/custom_ui.dart';
part 'custom_ui/custom_ui_stc.dart';
part 'custom_ui/method_channel_custom_ui.dart';
part 'custom_ui/method_channel_custom_ui_stc.dart';
part 'store_cards/stored_cards.dart';
part 'store_cards/method_channel_store_cards.dart';
part 'checkout_info/saved_card.dart';
part 'checkout_info/method_channel_checkout_info.dart';
part 'enum.dart';

class FlutterHyperPay {
  String channelName = "Hyperpay.demo.fultter/channel";
  String shopperResultUrl = "";
  String lang;
  PaymentMode paymentMode;

  FlutterHyperPay({
    required this.shopperResultUrl,
    required this.paymentMode,
    required this.lang,
  });

  Future<PaymentResultData> applePay(
      {required ApplePaySettings settings}) async {
    return await implementApplePay(
      settings: settings,
      channelName: channelName,
      paymentMode: paymentMode,
    );
  }

  /// This async function takes a ReadyUI object as input and returns a Future object of type PaymentResultData.
  /// It implements a payment operation by passing the Brand name, Checkout ID, Shopper Result URL,
  /// Payment Channel name, Payment mode, Language, Theme color in HEX (iOS),
  /// and a flag to set the store payment details mode.
  /// The function waits for the payment operation to complete and returns the resulting PaymentResultData.
  Future<PaymentResultData> readyUICards({required ReadyUI readyUI}) async {
    return await implementPayment(
      brands: readyUI.brandsName,
      checkoutId: readyUI.checkoutId,
      shopperResultUrl: shopperResultUrl,
      channelName: channelName,
      paymentMode: paymentMode,
      merchantId: readyUI.merchantIdApplePayIOS,
      countryCode: readyUI.countryCodeApplePayIOS,
      companyName: readyUI.companyNameApplePayIOS,
      lang: lang,
      themColorHexIOS: readyUI.themColorHexIOS,
      setStorePaymentDetailsMode: readyUI.setStorePaymentDetailsMode,
    );
  }

  /// This method is used for making custom UI payments with cards.
  /// It takes in the required CustomUI input and returns a PaymentResultData object.
  Future<PaymentResultData> customUICards({required CustomUI customUI}) async {
    return await implementPaymentCustomUI(
      brand: customUI.brandName,
      checkoutId: customUI.checkoutId,
      shopperResultUrl: shopperResultUrl,
      channelName: channelName,
      paymentMode: paymentMode,
      cardNumber: customUI.cardNumber,
      holderName: customUI.holderName,
      month: customUI.month,
      year: customUI.year,
      cvv: customUI.cvv,
      lang: lang,
      enabledTokenization: customUI.enabledTokenization,
    );
  }

  /// This function is used to do payment using custom UI. It takes "CustomUI" as an argument,
  /// which consists of the brand name, checkout id, card number, holder name, month, year and cvv.
  /// The function returns a Future of PaymentResultData.
  Future<PaymentResultData> customUISTC(
      {required CustomUISTC customUISTC}) async {
    return await implementPaymentCustomUISTC(
      checkoutId: customUISTC.checkoutId,
      shopperResultUrl: shopperResultUrl,
      channelName: channelName,
      paymentMode: paymentMode,
      lang: lang,
      phoneNumber: customUISTC.phoneNumber,
    );
  }

  /// This function allows the user to make payments using their stored cards.
  /// It accepts an argument of type StoredCards and makes a call to the implementPaymentStoredCards
  /// function with the values required for the payment.
  /// It returns a Future<PaymentResultData> which is the outcome of the payment.
  @Deprecated('Use payWithStoredCards instead (same behavior, correct spelling)')
  Future<PaymentResultData> payWithSoredCards(
      {required StoredCards storedCards}) async {
    return await implementPaymentStoredCards(
      brand: storedCards.brandName,
      checkoutId: storedCards.checkoutId,
      tokenId: storedCards.tokenId,
      cvv: storedCards.cvv,
      shopperResultUrl: shopperResultUrl,
      channelName: channelName,
      paymentMode: paymentMode,
      lang: lang,
    );
  }

  /// Pays with a previously saved/tokenized card. Correctly-spelled alias of
  /// [payWithSoredCards] - use this for all new call sites.
  // ignore: deprecated_member_use_from_same_package
  Future<PaymentResultData> payWithStoredCards(
          {required StoredCards storedCards}) =>
      payWithSoredCards(storedCards: storedCards);

  /// Fetches checkout info for [checkoutId] and returns the shopper's saved
  /// cards (tokens), so they can be presented as a "pay with a saved card"
  /// list before calling [payWithStoredCards].
  Future<List<SavedCard>> getCheckoutInfo({required String checkoutId}) async {
    return await implementGetCheckoutInfo(
      checkoutId: checkoutId,
      channelName: channelName,
      paymentMode: paymentMode,
      lang: lang,
      shopperResultUrl: shopperResultUrl,
    );
  }
}
