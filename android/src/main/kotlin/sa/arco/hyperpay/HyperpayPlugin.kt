package sa.arco.hyperpay
import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.*
import android.util.Log
import androidx.annotation.NonNull
import androidx.browser.customtabs.CustomTabsCallback
import androidx.browser.customtabs.CustomTabsClient
import androidx.browser.customtabs.CustomTabsIntent
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.oppwa.mobile.connect.exception.*
import com.oppwa.mobile.connect.payment.*
import com.oppwa.mobile.connect.payment.card.*
import com.oppwa.mobile.connect.provider.*
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference


class HyperpayPlugin : FlutterPlugin, MethodCallHandler, ITransactionListener, ActivityAware, ThreeDSWorkflowListener {
    private val TAG = "HyperpayPlugin"
   
    private lateinit var channel: MethodChannel
    private var channelResult: MethodChannel.Result? = null

    private var mActivity: Activity? = null

    private var paymentProvider: OppPaymentProvider? = null
   
    private var checkoutID = ""

    private var paymentMode = ""

    
    private var brand = ""
    private var cardHolder: String = ""
    private var cardNumber: String = ""
    private var expiryMonth: String = ""
    private var expiryYear: String = ""
    private var cvv: String = ""

    val PAYMENT_BRANDS = hashSetOf("VISA", "MASTER", "MADA")

    private var shopperResultUrl: String = ""
    private var redirectData = ""
    private var mCustomTabsClient: CustomTabsClient? = null;
    private var mCustomTabsIntent: CustomTabsIntent? = null;
    private var hiddenLifecycleReference: HiddenLifecycleReference? = null;

    private val lifecycleObserver = LifecycleEventObserver { _, event ->
        if(event == Lifecycle.Event.ON_RESUME && (redirectData.isEmpty() )) {
            Log.d(TAG, "Cancelling.")

            success("canceled")
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "hyperpay")
        channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mActivity = binding.activity;

        shopperResultUrl = mActivity!!.packageName.replace("_", "")
        shopperResultUrl += ".payments"

       
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
       
    }

    override fun onDetachedFromActivity() {
   
        mActivity = null
    }

    
    private val handler: Handler = Handler(Looper.getMainLooper())

    private fun success(result: Any?) {
        handler.post { channelResult!!.success(result) }
    }

    private fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        handler.post { channelResult!!.error(errorCode, errorMessage, errorDetails) }
    }

   

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
      
          if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
          }
       else if (call.method == "start_payment") {
                channelResult = result

                val args: Map<String, Any> = call.arguments as Map<String, Any>
                checkoutID = (args["checkoutID"] as String?)!!
                brand = (args["brand"] as String?)!!

                val card: Map<String, Any> = args["card"] as Map<String, Any>
                cardHolder = (card["holder"] as String?)!!
                cardNumber = (card["number"] as String?)!!
                expiryMonth = (card["expiryMonth"] as String?)!!
                expiryYear = (card["expiryYear"] as String?)!!
                cvv = (card["cvv"] as String?)!!
                paymentProvider = OppPaymentProvider(mActivity!!.application, Connect.ProviderMode.TEST);

                paymentProvider!!.setThreeDSWorkflowListener{mActivity}

    //                val checkoutSettings = CheckoutSettings(
    //           checkoutID,
    //     PAYMENT_BRANDS, Connect.ProviderMode.TEST
    //   ). setShopperResultUrl("$shopperResultUrl://arco.sa")
              println("test  ${brand}")
             println("test  ${cardHolder}")
             println("test  ${checkoutID}")
              
                   
                  
                        checkCreditCardValid(result)

                        val paymentParams: PaymentParams = CardPaymentParams(
                                checkoutID,
                                brand,
                                cardNumber,
                                cardHolder,
                                expiryMonth,
                                expiryYear,
                                cvv
                        )

                       
                        paymentParams.shopperResultUrl = "$shopperResultUrl://arco.sa"

                        try {
                            val transaction = Transaction(paymentParams)
                            paymentProvider?.submitTransaction(transaction, this)
                        } catch (e: PaymentException) {
                            result.error(
                                    "0.2",
                                    e.localizedMessage,
                                    ""
                            )
                        }
                    
                
            }
            else {
                result.notImplemented()
            }
        
    }


   
    private fun checkCreditCardValid(result: Result) {
        if (!CardPaymentParams.isNumberValid(cardNumber)) {
            result.error(
                    "1.1",
                    "Card number is not valid for brand $brand",
                    ""
            )
        } else if (!CardPaymentParams.isHolderValid(cardHolder)) {
            result.error(
                    "1.2",
                    "Holder name is not valid",
                    ""
            )
        } else if (!CardPaymentParams.isExpiryMonthValid(expiryMonth)) {
            result.error(
                    "1.3",
                    "Expiry month is not valid",
                    ""
            )
        } else if (!CardPaymentParams.isExpiryYearValid(expiryYear)) {
            result.error(
                    "1.4",
                    "Expiry year is not valid",
                    ""
            )
        } else if (!CardPaymentParams.isCvvValid(cvv)) {
            result.error(
                    "1.5",
                    "CVV is not valid",
                    ""
            )
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun transactionCompleted(transaction: Transaction) {
      Log.d(TAG, "transaction completed")

        try {
            if (transaction.transactionType == TransactionType.SYNC) {
              Log.d(TAG, "success sync")

                // Send request to your server to obtain transaction status
                success("synchronous")
            } else {
      
                Log.d(TAG, " async")
                val uri = Uri.parse(transaction.redirectUrl)
                redirectData = ""

                val session = mCustomTabsClient?.newSession(object : CustomTabsCallback() {
                    override fun onNavigationEvent(navigationEvent: Int, extras: Bundle?) {
                        Log.w(TAG, "onNavigationEvent: Code = $navigationEvent")
                        when (navigationEvent) {
                            TAB_HIDDEN -> {
                                if (redirectData.isEmpty()) {
                                    mCustomTabsIntent = null
                                    success("canceled")
                                }
                            }
                        }
                    }
                })

                val builder = CustomTabsIntent.Builder(session)
                mCustomTabsIntent = builder.build()
                mActivity?.intent?.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
                mCustomTabsIntent?.intent?.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
                mCustomTabsIntent?.launchUrl(mActivity!!, uri)
            }
        } catch (e: Exception) {
            e.printStackTrace()

            
            error("${e.message}️")
        }
    }

    override fun transactionFailed(transaction: Transaction, error: PaymentError) {
        error(
                "${error.errorCode}",
                error.errorMessage,
                "${error.errorInfo}"
        )
    }

    override fun onThreeDSChallengeRequired(): Activity {
        return mActivity!!
    }
}
