import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hyperpay_plugin/flutter_hyperpay.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FlutterHyperPay flutterHyperPay;
  List<SavedCard> _savedCards = [];
  @override
  void initState() {
    flutterHyperPay = FlutterHyperPay(
      shopperResultUrl: InAppPaymentSetting.shopperResultUrl,
      paymentMode: PaymentMode.test,
      lang: InAppPaymentSetting.getLang(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "pay with ready ui".toUpperCase(),
              style: const TextStyle(fontSize: 20, color: Colors.red),
            ),
            InkWell(
                onTap: () async {
                  String? checkoutId = await getCheckOut();
                  if (checkoutId != null) {
                    /// Brands Names [ VISA , MASTER , MADA , STC_PAY , APPLEPAY]
                    payRequestNowReadyUI(brandsName: [
                      "VISA",
                      "MASTER",
                      "MADA",
                      // "PAYPAL",
                      // "STC_PAY",
                      // "APPLEPAY"
                    ], checkoutId: checkoutId);
                  }
                },
                child: const Text(
                  "[VISA,MASTER,MADA,STC_PAY,APPLEPAY]",
                  style: TextStyle(fontSize: 20),
                )),
            const Divider(),
            Text(
              "pay with custom ui".toUpperCase(),
              style: const TextStyle(fontSize: 20, color: Colors.red),
            ),
            InkWell(
                onTap: () async {
                  String? checkoutId = await getCheckOut();
                  if (checkoutId != null) {
                    // "VISA" 4111111111111111
                    // "MASTER" 5541805721646120
                    // "MADA" "4464040000000007"
                    payRequestNowCustomUi(
                        brandName: "MADA",
                        checkoutId: checkoutId,
                        cardNumber: "4464040000000007");
                  }
                },
                child: const Text(
                  "CUSTOM_UI",
                  style: TextStyle(fontSize: 20),
                )),
            const Divider(),
            Text(
              "pay with custom ui stc".toUpperCase(),
              style: const TextStyle(fontSize: 20, color: Colors.red),
            ),
            InkWell(
                onTap: () async {
                  String? checkoutId = await getCheckOut();
                  if (checkoutId != null) {
                    payRequestNowCustomUiSTCPAY(
                        checkoutId: checkoutId, phoneNumber: "0588987147");
                  }
                },
                child: const Text(
                  "STC_PAY",
                  style: TextStyle(fontSize: 20),
                )),
            const Divider(),
            Text(
              "save a card (custom ui, tokenization on)".toUpperCase(),
              style: const TextStyle(fontSize: 20, color: Colors.red),
            ),
            InkWell(
                onTap: () async {
                  String? checkoutId = await getCheckOut();
                  if (checkoutId != null) {
                    await payRequestNowSaveCard(checkoutId: checkoutId);
                  }
                },
                child: const Text(
                  "SAVE_CARD",
                  style: TextStyle(fontSize: 20),
                )),
            const Divider(),
            Text(
              "list saved cards".toUpperCase(),
              style: const TextStyle(fontSize: 20, color: Colors.red),
            ),
            InkWell(
                onTap: () async {
                  String? checkoutId = await getCheckOut();
                  if (checkoutId != null) {
                    await loadSavedCards(checkoutId: checkoutId);
                  }
                },
                child: const Text(
                  "LIST_SAVED_CARDS",
                  style: TextStyle(fontSize: 20),
                )),
            for (final card in _savedCards)
              InkWell(
                  onTap: () async {
                    String? checkoutId = await getCheckOut();
                    if (checkoutId != null) {
                      await payRequestNowStoredCard(
                          checkoutId: checkoutId, card: card);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "PAY WITH ${card.paymentBrand} •••• ${card.last4Digits ?? ''}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  /// URL TO GET CHECKOUT ID FOR TEST
  /// http://dev.hyperpay.com/hyperpay-demo/getcheckoutid.php

  Future<String?> getCheckOut() async {
    final url =
        Uri.parse('https://dev.hyperpay.com/hyperpay-demo/getcheckoutid.php');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dev.log(json.decode(response.body)['id'].toString(), name: "checkoutId");
      return json.decode(response.body)['id'];
    } else {
      dev.log(response.body.toString(), name: "STATUS CODE ERROR");
      return null;
    }
  }

  payRequestNowReadyUI(
      {required List<String> brandsName, required String checkoutId}) async {
    PaymentResultData paymentResultData;
    paymentResultData = await flutterHyperPay.readyUICards(
      readyUI: ReadyUI(
          brandsName: brandsName,
          checkoutId: checkoutId,
          merchantIdApplePayIOS: InAppPaymentSetting.merchantId,
          countryCodeApplePayIOS: InAppPaymentSetting.countryCode,
          companyNameApplePayIOS: "Test Co",
          themColorHexIOS: "#000000", // FOR IOS ONLY
          setStorePaymentDetailsMode:
              true // store payment details for future use
          ),
    );

    if (paymentResultData.paymentResult == PaymentResult.sync) {
      // do something
    }
  }

  payRequestNowCustomUi(
      {required String brandName,
      required String checkoutId,
      required String cardNumber}) async {
    PaymentResultData paymentResultData;

    paymentResultData = await flutterHyperPay.customUICards(
      customUI: CustomUI(
        brandName: brandName,
        checkoutId: checkoutId,
        cardNumber: cardNumber,
        holderName: "test name",
        month: '12',
        year: '2023',
        cvv: '123',
        enabledTokenization: false, // default
      ),
    );

    if (paymentResultData.paymentResult == PaymentResult.sync) {
      // do something
    }
  }

  payRequestNowCustomUiSTCPAY(
      {required String phoneNumber, required String checkoutId}) async {
    PaymentResultData paymentResultData;

    paymentResultData = await flutterHyperPay.customUISTC(
      customUISTC:
          CustomUISTC(checkoutId: checkoutId, phoneNumber: phoneNumber),
    );

    if (paymentResultData.paymentResult == PaymentResult.sync) {
      // do something
    }
  }

  /// Pays with `enabledTokenization: true` so the card is saved server-side.
  /// On success, [PaymentResultData.tokenId] carries the new saved-card token.
  payRequestNowSaveCard({required String checkoutId}) async {
    PaymentResultData paymentResultData = await flutterHyperPay.customUICards(
      customUI: CustomUI(
        brandName: "MADA",
        checkoutId: checkoutId,
        cardNumber: "4464040000000007",
        holderName: "test name",
        month: '12',
        year: '2028',
        cvv: '123',
        enabledTokenization: true,
      ),
    );

    dev.log(
        "status=${paymentResultData.paymentResult} tokenId=${paymentResultData.tokenId} brand=${paymentResultData.paymentBrand}",
        name: "SaveCard");
  }

  /// Fetches checkout info for a fresh checkout id and lists the shopper's
  /// saved cards (requires the checkout id to be scoped to a registered
  /// customer server-side; see README).
  loadSavedCards({required String checkoutId}) async {
    final cards =
        await flutterHyperPay.getCheckoutInfo(checkoutId: checkoutId);
    setState(() {
      _savedCards = cards;
    });
  }

  /// Pays with a previously saved card using its token id.
  payRequestNowStoredCard(
      {required String checkoutId, required SavedCard card}) async {
    PaymentResultData paymentResultData =
        await flutterHyperPay.payWithStoredCards(
      storedCards: StoredCards(
        checkoutId: checkoutId,
        tokenId: card.tokenId,
        brandName: card.paymentBrand,
        cvv: '123',
      ),
    );

    if (paymentResultData.paymentResult == PaymentResult.sync) {
      // do something
    }
  }
}

class InAppPaymentSetting {
  static const String shopperResultUrl = "com.testpayment.payment";
  static const String merchantId = "MerchantId";
  static const String countryCode = "SA";
  static getLang() {
    if (Platform.isIOS) {
      return "en"; // ar
    } else {
      return "en_US"; // ar_AR
    }
  }
}
