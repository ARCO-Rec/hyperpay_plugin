package sa.arco.hyperpay
import android.app.Activity
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.oppwa.mobile.connect.exception.*
import com.oppwa.mobile.connect.payment.*
import com.oppwa.mobile.connect.payment.card.*
import com.oppwa.mobile.connect.provider.*
import android.content.Context

/** HyperpayPlugin */

private var checkoutID = ""
private var paymentProvider: OppPaymentProvider? = null
private var brand = ""
private var cardHolder: String = ""
private var cardNumber: String = ""
private var expiryMonth: String = ""
private var expiryYear: String = ""
private var cvv: String = ""
val PAYMENT_BRANDS = hashSetOf("VISA", "MASTER", "MADA")


class HyperpayPlugin : FlutterPlugin, MethodCallHandler,ITransactionListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity

    private lateinit var channel: MethodChannel
    private var channelResult: MethodChannel.Result? = null

    private var mActivity: Activity? = null
    private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "hyperpay")
    channel.setMethodCallHandler(this)
  }




  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {

      result.success("Android ${android.os.Build.VERSION.RELEASE}")


    }
    else if (call.method =="start_payment"){

      val args: Map<String, Any> = call.arguments as Map<String, Any>
      checkoutID = (args["checkoutID"] as String?)!!
      brand = args["brand"].toString()

      val card: Map<String, Any> = args["card"] as Map<String, Any>
      cardHolder = (card["holder"] as String?)!!
      cardNumber = (card["number"] as String?)!!
      expiryMonth = (card["expiryMonth"] as String?)!!
      expiryYear = (card["expiryYear"] as String?)!!
      cvv = (card["cvv"] as String?)!!


      val paymentParams: PaymentParams = CardPaymentParams(
        checkoutID,
        brand,
        cardNumber,
        cardHolder,
        expiryMonth,
        expiryYear,
        cvv
)
  //  val checkoutSettings = CheckoutSettings(
  //    checkoutID,
  //    PAYMENT_BRANDS, Connect.ProviderMode.TEST
  // )
  println("test  ${cardHolder}")

   try {
     val transaction = Transaction(paymentParams)
    paymentProvider?.submitTransaction(transaction, this)
     if (transaction != null) {

       println("transaction result  ${transaction}")

   }
 } catch (e: PaymentException) {
     result.error(
             "",
             e as String? ,
             ""
     )
 }


}
    else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

    override fun transactionCompleted(transaction: Transaction) {
        try {
            if (transaction.transactionType == TransactionType.SYNC) {

                //success("synchronous")
            } else {



            }
        } catch (e: Exception) {
            e.printStackTrace()
            error("${e.message}️")
        }
    }
  override fun transactionFailed(transaction: Transaction, error: PaymentError) {
      error(
          "${error.errorCode}"


      )

  }

}

