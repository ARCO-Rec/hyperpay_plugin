import Flutter
import UIKit
import SafariServices

public class SwiftPaymentPlugin: NSObject,FlutterPlugin ,SFSafariViewControllerDelegate, OPPCheckoutProviderDelegate,PKPaymentAuthorizationViewControllerDelegate  {
    var type:String = "";
    var mode:String = "";
    var checkoutid:String = "";
    var brand:String = "";
    var brandsReadyUi:[String] = [];
    var STCPAY:String = "";
    var number:String = "";
    var holder:String = "";
    var year:String = "";
    var month:String = "";
    var cvv:String = "";
    var pMadaVExp:String = "";
    var prMadaMExp:String = "";
    var brands:String = "";
    var shopperResultURL:String = "";
    var tokenID:String = "";
    var payTypeSotredCard:String = "";
    var applePaybundel:String = ""; // deprecated use merchantId instead
    var merchantId:String="";
    var countryCode:String = "";
    var currencyCode:String = "";
    var setStorePaymentDetailsMode:String = "";
    var lang:String = "";
    var amount:Double = 1;
    var themColorHex:String = "";
    var companyName:String = "";
    var safariVC: SFSafariViewController?
    var transaction: OPPTransaction?
    var provider = OPPPaymentProvider(mode: OPPProviderMode.test)
    var checkoutProvider: OPPCheckoutProvider?
    var Presult:FlutterResult?

  public static func register(with registrar: FlutterPluginRegistrar) {
      let buttonFactory = ApplePayButtonViewFactory(messenger:registrar.messenger())
    let flutterChannel:String = "Hyperpay.demo.fultter/channel";
    let channel = FlutterMethodChannel(name: flutterChannel, binaryMessenger: registrar.messenger())
    let instance = SwiftPaymentPlugin()
      registrar.register(buttonFactory, withId: "hyperpay/apple_pay_button")
    registrar.addApplicationDelegate(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)

  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.Presult = result
        
        
       
        if call.method == "gethyperpayresponse"{
            let args = call.arguments as? Dictionary<String,Any>
            self.type = (args!["type"] as? String)!
            self.mode = (args!["mode"] as? String)!
            self.checkoutid = (args!["checkoutid"] as? String)!
            self.shopperResultURL = (args!["ShopperResultUrl"] as? String)!
            self.lang=(args!["lang"] as? String)!
            self.amount = (args!["amount"] as? Double)!
            if self.mode == "live" {
                self.provider = OPPPaymentProvider(mode: OPPProviderMode.live)
            }else{
                self.provider = OPPPaymentProvider(mode: OPPProviderMode.test)
            }
            switch self.type{
                case"ReadyUI" :
                    self.applePaybundel=(args!["merchantId"] as? String)!
                    self.countryCode=(args!["CountryCode"] as? String)!
                    self.companyName=(args!["companyName"] as? String)!
                    self.brandsReadyUi = (args!["brand"]) as! [String]
                    self.themColorHex=(args!["themColorHexIOS"] as? String)!

                    self.setStorePaymentDetailsMode=(args!["setStorePaymentDetailsMode"] as? String )!
                    DispatchQueue.main.async {
                        self.openCheckoutUI(checkoutId: self.checkoutid, result1: result)
                    }
                case "APPLEPAY":
                    self.merchantId=(args!["merchantId"] as? String)!
                    self.countryCode=(args!["countryCode"] as? String)!
                    self.companyName=(args!["companyName"] as? String)!
                    self.currencyCode=(args!["currencyCode"] as? String)!
                    DispatchQueue.main.async {
                    self.showApplePay(checkoutId: self.checkoutid,result1:result)
                }
                default:
                    result(FlutterError(code: "1", message: "Method name is not found", details: ""))
            }
       
        

        } else {
                result(FlutterError(code: "1", message: "Method name is not found", details: ""))
            }
        }

    private func showApplePay(checkoutId: String,result1:@escaping FlutterResult){
        DispatchQueue.main.async {
            let paymentRequest = OPPPaymentProvider.paymentRequest(withMerchantIdentifier: self.merchantId, countryCode: self.countryCode)
            paymentRequest.currencyCode = self.currencyCode
            paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: self.companyName, amount: NSDecimalNumber(value: self.amount))]

            if #available(iOS 12.1.1, *) {
                paymentRequest.supportedNetworks = [ PKPaymentNetwork.mada,PKPaymentNetwork.visa, PKPaymentNetwork.masterCard ]
            }
            else {
                // Fallback on earlier versions
                paymentRequest.supportedNetworks = [ PKPaymentNetwork.visa, PKPaymentNetwork.masterCard ]
            }
            let checkoutSettings = OPPCheckoutSettings()
            checkoutSettings.applePayPaymentRequest = paymentRequest
            checkoutSettings.language = self.lang
            
           
        let canSubmit = OPPPaymentProvider.canSubmitPaymentRequest(paymentRequest)
            if(canSubmit){
                if let vc = PKPaymentAuthorizationViewController( paymentRequest:paymentRequest ) as PKPaymentAuthorizationViewController?{
                    vc.delegate = self
                    UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true,completion:nil)
//                    DispatchQueue.main.async {
//                                             result1("SYNC")
//                                         }
                    
                }else{
                    result1(FlutterError.init(code: "1",message:"Error : operation cancel",details: nil))
                    
                }
            }
               
            
    }
        
        
       // checkoutSettings.paymentBrands = ["APPLEPAY"]
    }
    private func openCheckoutUI(checkoutId: String,result1: @escaping FlutterResult) {

//         if self.mode == "live" {
//             self.provider = OPPPaymentProvider(mode: OPPProviderMode.live)
//         }else{
//             self.provider = OPPPaymentProvider(mode: OPPProviderMode.test)
//         }
         DispatchQueue.main.async{

             let checkoutSettings = OPPCheckoutSettings()
             checkoutSettings.paymentBrands = self.brandsReadyUi;
             if(self.brandsReadyUi.contains("APPLEPAY")){

                     let paymentRequest = OPPPaymentProvider.paymentRequest(withMerchantIdentifier: self.applePaybundel, countryCode: self.countryCode)
                     paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: self.companyName, amount: NSDecimalNumber(value: self.amount))]

                     if #available(iOS 12.1.1, *) {
                         paymentRequest.supportedNetworks = [ PKPaymentNetwork.mada,PKPaymentNetwork.visa, PKPaymentNetwork.masterCard ]
                     }
                     else {
                         // Fallback on earlier versions
                         paymentRequest.supportedNetworks = [ PKPaymentNetwork.visa, PKPaymentNetwork.masterCard ]
                     }
                     checkoutSettings.applePayPaymentRequest = paymentRequest
                    // checkoutSettings.paymentBrands = ["APPLEPAY"]
             }
             checkoutSettings.language = self.lang
             // Set available payment brands for your shop
             checkoutSettings.shopperResultURL = self.shopperResultURL+"://result"
             if self.setStorePaymentDetailsMode=="true"{
                 checkoutSettings.storePaymentDetails = OPPCheckoutStorePaymentDetailsMode.prompt;
             }
             self.setThem(checkoutSettings: checkoutSettings, hexColorString: self.themColorHex)
             self.checkoutProvider = OPPCheckoutProvider(paymentProvider: self.provider, checkoutID: checkoutId, settings: checkoutSettings)!
             self.checkoutProvider?.delegate = self
             self.checkoutProvider?.presentCheckout(withPaymentBrand: "CARD",
                loadingHandler: { (inProgress) in
                 // Executed whenever SDK sends request to the server or receives the answer.
                 // You can start or stop loading animation based on inProgress parameter.
             }, completionHandler: { (transaction, error) in
                 if error != nil {
                     // See code attribute (OPPErrorCode) and NSLocalizedDescription to identify the reason of failure.
                 } else {
                     if transaction?.redirectURL != nil {
                         // Shopper was redirected to the issuer web page.
                         // Request payment status when shopper returns to the app using transaction.resourcePath or just checkout id.
                     } else {
                         // Request payment status for the synchronous transaction from your server using transactionPath.resourcePath or just checkout id.
                     }
                 }
             }, cancelHandler: {
                 // Executed if the shopper closes the payment page prematurely.
             })
//             self.checkoutProvider?.presentCheckout(forSubmittingTransactionCompletionHandler: {
//                 (transaction, error) in
//                 guard let transaction = transaction else {
//                     // Handle invalid transaction, check error
//                     // result1("error")
//                     result1(FlutterError.init(code: "1",message: "Error: " + self.transaction.debugDescription,details: nil))
//                     return
//                 }
//                 self.transaction = transaction
//                 if transaction.type == .synchronous {
//                     // If a transaction is synchronous, just request the payment status
//                     // You can use transaction.resourcePath or just checkout ID to do it
//                     DispatchQueue.main.async {
//                         result1("SYNC")
//                     }
//                 }
//                 else if transaction.type == .asynchronous {
//                     NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveAsynchronousPaymentCallback), name: Notification.Name(rawValue: "AsyncPaymentCompletedNotificationKey"), object: nil)
//                 }
//                 else {
//                     // result1("error")
//                     result1(FlutterError.init(code: "1",message:"Error : operation cancel",details: nil))
//                     // Executed in case of failure of the transaction for any reason
//                     print(self.transaction.debugDescription)
//                 }
//             }
//                                                    , cancelHandler: {
//                                                    // result1("error")
//                                                     result1(FlutterError.init(code: "1",message: "Error : operation cancel",details: nil))
//                                                        // Executed if the shopper closes the payment page prematurely
//                                                        print(self.transaction.debugDescription)
//                                                    })
         }

     }


       private func openCustomUI(checkoutId: String,result1: @escaping FlutterResult) {}


       @objc func didReceiveAsynchronousPaymentCallback(result: @escaping FlutterResult) {
           NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "AsyncPaymentCompletedNotificationKey"), object: nil)
           if self.type == "ReadyUI" || self.type=="APPLEPAY"||self.type=="StoredCards"{
               self.checkoutProvider?.dismissCheckout(animated: true) {
                   DispatchQueue.main.async {
                       result("success")
                   }
               }
           }

           else {
               self.safariVC?.dismiss(animated: true) {
                   DispatchQueue.main.async {
                       result("success")
                   }
               }
           }

       }
     public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
           var handler:Bool = false
           if url.scheme?.caseInsensitiveCompare( self.shopperResultURL) == .orderedSame {
               didReceiveAsynchronousPaymentCallback(result: self.Presult!)
               handler = true
           }

           return handler
       }

       func createalart(titletext:String,msgtext:String){
           DispatchQueue.main.async {
               let alertController = UIAlertController(title: titletext, message:
                                                       msgtext, preferredStyle: .alert)
               alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default,handler: {
                   (action) in alertController.dismiss(animated: true, completion: nil)
               }))
               //  alertController.view.tintColor = UIColor.orange
               UIApplication.shared.delegate?.window??.rootViewController?.present(alertController, animated: true, completion: nil)
           }

       }
       public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
           controller.dismiss(animated: true, completion: nil)
           self.Presult!("canceled from paymentAuthorizationViewControllerDidFinish")
       }
       public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
           if let params = try? OPPApplePayPaymentParams(checkoutID: self.checkoutid, tokenData: payment.token.paymentData) as OPPApplePayPaymentParams? {
               self.transaction  = OPPTransaction(paymentParams: params)
               self.provider.submitTransaction(OPPTransaction(paymentParams: params), completionHandler: {
                   (transaction, error) in
                   if (error != nil) {
                       // see code attribute (OPPErrorCode) and NSLocalizedDescription to identify the reason of failure.
                       self.Presult?(error?.localizedDescription)
                   }
                   else {
                       // send request to your server to obtain transaction status.
                       completion(.success)
                       self.Presult!("success")
                   }
               })
           }

       }
       func decimal(with string: String) -> NSDecimalNumber {
           //  let formatter = NumberFormatter()
           let formatter = NumberFormatter()
           formatter.minimumFractionDigits = 2
           return formatter.number(from: string) as? NSDecimalNumber ?? 0
       }

    func setThem( checkoutSettings :OPPCheckoutSettings,hexColorString :String){
         // General colors of the checkout UI
         checkoutSettings.theme.confirmationButtonColor = UIColor(hexString:hexColorString);
         checkoutSettings.theme.navigationBarBackgroundColor = UIColor(hexString:hexColorString);
         checkoutSettings.theme.cellHighlightedBackgroundColor = UIColor(hexString:hexColorString);
         checkoutSettings.theme.accentColor = UIColor(hexString:hexColorString);
     }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
