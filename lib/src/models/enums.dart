// ignore_for_file: unnecessary_this, no_leading_underscores_for_local_identifiers

part of hyperpay;

enum PaymentMode {
  /// Use the test mode in your development environment.
  test,

  /// Use the test mode in your production environment.
  live,

  none,
}

enum BrandType {
  visa,

  master,

  mada,

  applepay,

  /// If no brand is chosen, use none to avoid
  /// any unnecessary errors.
  none,
}

enum ApplePayButtonStyle {
  white,
  whiteOutline,
  black,
  automatic,
}

enum ApplePayButtonType {
  plain,
  buy,
  setUp,
  checkout,
  book,
  subscribe,
  reload,
  addMoney,
  topUp,
  order,
  rent,
  support,
  contribute,
  tip
}

class ApplePaySettings {
  final String appleMerchantId;
  final double amount;
  final String currencyCode;
  final String countryCode;

  const ApplePaySettings({
    required this.appleMerchantId,
    required this.amount,
    required this.currencyCode,
    required this.countryCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'appleMerchantId': appleMerchantId,
      'amount': amount,
      'currencyCode': currencyCode,
      'countryCode': countryCode,
    };
  }
}

/// A button widget that follows the Apple Pay button styles and design
/// guidelines. This widget will draw the native Apply Pay button from PassKit
class ApplePayButton extends StatelessWidget {
  /// The default width for the Apple Pay Button.
  static const double minimumButtonWidth = 100;

  /// The default height for the Apple Pay Button.
  static const double minimumButtonHeight = 30;

  /// The constraints used to limit the size of the button.
  final BoxConstraints constraints;

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// The style of the Apple Pay button, to be adjusted based on the color
  /// scheme of the application.
  final ApplePayButtonStyle style;

  /// The tyoe of button depending on the activity initiated with the payment
  /// transaction.
  final ApplePayButtonType type;

  /// Creates an Apple Pay button widget with the parameters specified.
  ApplePayButton({
    Key? key,
    this.onPressed,
    this.style = ApplePayButtonStyle.black,
    this.type = ApplePayButtonType.plain,
  })  : constraints = BoxConstraints.tightFor(
          width: type.minimumWidth,
          height: minimumButtonHeight,
        ),
        super(key: key) {
    assert(constraints.debugAssertIsValid());
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: constraints,
      child: _platformButton,
    );
  }

  /// Wrapper method to deliver the button only to applitcations running on iOS.
  Widget get _platformButton {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return _UiKitApplePayButton(
          onPressed: onPressed,
          style: style,
          type: type,
        );
      default:
        throw UnsupportedError(
            'Platform $defaultTargetPlatform does not support Apple Pay');
    }
  }

  static bool get supported => defaultTargetPlatform == TargetPlatform.iOS;
}

/// Draw the Apple Pay button through a [PlatforView].
class _UiKitApplePayButton extends StatelessWidget {
  static const buttonId = 'hyperpay/apple_pay_button';
  late final MethodChannel? methodChannel;

  final VoidCallback? onPressed;
  final ApplePayButtonStyle style;
  final ApplePayButtonType type;

  // ignore: prefer_const_constructors_in_immutables
  _UiKitApplePayButton({
    Key? key,
    this.onPressed,
    this.style = ApplePayButtonStyle.black,
    this.type = ApplePayButtonType.plain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: buttonId,
      creationParamsCodec: const StandardMessageCodec(),
      creationParams: {'style': style.name, 'type': type.name},
      onPlatformViewCreated: (viewId) {
        methodChannel = MethodChannel('$buttonId/$viewId');
        methodChannel?.setMethodCallHandler((call) async {
          if (call.method == 'onPressed') onPressed?.call();
          return;
        });
      },
    );
  }
}

extension ApplePayButtonTypeExt on ApplePayButtonType {
  /// The minimum width for this button type according to
  /// [Apple Pay's Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/apple-pay/overview/buttons-and-marks/)
  /// for the button.
  double get minimumWidth => this == ApplePayButtonType.plain ? 100 : 140;
}

extension PaymentModeExtension on PaymentMode {
  String get string {
    switch (this) {
      case PaymentMode.live:
        return 'LIVE';
      case PaymentMode.test:
        return 'TEST';
      default:
        return '';
    }
  }
}

// Regular experessions for each brand
// These expressions were chosen according to this article.
// https://uxplanet.org/streamlining-the-checkout-experience-4-4-6793dad81360

RegExp _visaRegExp = RegExp(r'^4[0-9]{12}(?:[0-9]{3})?$');
RegExp _mastercardRegExp = RegExp(r'^5[1-5][0-9]{5,}$');
RegExp _madaRegExpV = RegExp(
    r'4(0(0861|1757|7(197|395)|9201)|1(0685|7633|9593)|2(281(7|8|9)|8(331|67(1|2|3)))|3(1361|2328|4107|9954)|4(0(533|647|795)|5564|6(393|404|672))|5(5(036|708)|7865|8456)|6(2220|854(0|1|2|3))|8(301(0|1|2)|4783|609(4|5|6)|931(7|8|9))|93428)');
RegExp _madaRegExpM = RegExp(
    r'5(0(4300|8160)|13213|2(1076|4(130|514)|9(415|741))|3(0906|1095|2013|5(825|989)|6023|7767|9931)|4(3(085|357)|9760)|5(4180|7606|8848)|8(5265|8(8(4(5|6|7|8|9)|5(0|1))|98(2|3))|9(005|206)))|6(0(4906|5141)|36120)|9682(0(1|2|3|4|5|6|7|8|9)|1(0|1))');

extension DetectBrand on String {
  /// Detects a card brand from its number.
  ///
  /// Supports VISA, MasterCard, Mada
  BrandType get detectBrand {
    final cleanNumber = this.replaceAll(' ', '');

    bool _isMADA = _madaRegExpM.hasMatch(cleanNumber) ||
        _madaRegExpV.hasMatch(cleanNumber);
    bool _isVISA = _visaRegExp.hasMatch(cleanNumber);
    bool _isMASTERCARD = _mastercardRegExp.hasMatch(cleanNumber);

    if (_isMADA) {
      return BrandType.mada;
    } else if (_isVISA) {
      return BrandType.visa;
    } else if (_isMASTERCARD) {
      return BrandType.master;
    } else {
      return BrandType.none;
    }
  }
}

extension BrandTypeExtension on BrandType {
  // /// Get the entity ID of this brand based on merchant configuration.
  // String? entityID(HyperpayConfig config) {
  //   String? _entityID = '';
  //   switch (this) {
  //     case BrandType.visa:
  //       _entityID = config.creditcardEntityID;
  //       break;
  //     case BrandType.master:
  //       _entityID = config.creditcardEntityID;
  //       break;
  //     case BrandType.mada:
  //       _entityID = config.madaEntityID;
  //       break;
  //     case BrandType.applepay:
  //       _entityID = config.applePayEntityID;
  //       break;

  //     default:
  //       _entityID = null;
  //   }
  //   return _entityID;
  // }

  /// Match the string entered by user against RegExp rules
  /// for each card type.
  ///
  /// TODO: localize the messages.
  String? validateNumber(String number) {
    // Remove the white spaces inserted by formatters
    final cleanNumber = number.replaceAll(' ', '');

    switch (this) {
      case BrandType.visa:
        if (_visaRegExp.hasMatch(cleanNumber)) {
          return null;
        } else if (cleanNumber.isEmpty) {
          return "Required";
        } else {
          return "Inavlid VISA number";
        }
      case BrandType.master:
        if (_mastercardRegExp.hasMatch(cleanNumber)) {
          return null;
        } else if (cleanNumber.isEmpty) {
          return "Required";
        } else {
          return "Inavlid MASTER CARD number";
        }
      case BrandType.mada:
        if (_madaRegExpV.hasMatch(cleanNumber) ||
            _madaRegExpM.hasMatch(cleanNumber)) {
          return null;
        } else if (cleanNumber.isEmpty) {
          return "Required";
        } else {
          return "Inavlid MADA number";
        }
      default:
        return "No brand provided";
    }
  }

  /// Maximum length of this card number
  ///
  /// https://wordpresshyperpay.docs.oppwa.com/reference/parameters
  int get maxLength {
    switch (this) {
      case BrandType.visa:
        return 16;
      case BrandType.master:
        return 16;
      case BrandType.mada:
        return 16;
      default:
        return 19;
    }
  }
}
