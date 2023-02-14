package sa.arco.hyperpay

import java.util.*
import android.app.Activity
import android.content.*
import android.os.*
import android.net.Uri
import android.util.Log

import androidx.annotation.NonNull
import androidx.browser.customtabs.*
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference
import com.oppwa.mobile.connect.provider.ThreeDSWorkflowListener

import com.oppwa.mobile.connect.checkout.meta.CheckoutActivityResult
import com.oppwa.mobile.connect.checkout.meta.CheckoutActivityResultContract
import com.oppwa.mobile.connect.checkout.meta.CheckoutSettings
import com.oppwa.mobile.connect.checkout.meta.CheckoutSkipCVVMode

import com.oppwa.mobile.connect.exception.*
import com.oppwa.mobile.connect.payment.*
import com.oppwa.mobile.connect.payment.card.*
import com.oppwa.mobile.connect.provider.*

import sa.arco.hyperpay.R
import androidx.appcompat.app.AppCompatActivity
import kotlinx.coroutines.ExperimentalCoroutinesApi
import com.oppwa.mobile.connect.provider.ITransactionListener


import android.content.Context



import io.flutter.plugin.common.PluginRegistry.Registrar

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




class HyperpayPlugin : FlutterPlugin, MethodCallHandler {
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
   // paymentProvider?.submitTransaction(transaction, this)
    if (transaction != null) {
     
      println("transaction result  ${transaction}")
      if (transaction.transactionType === TransactionType.SYNC) {
          // request payment status
      } else {
          // wait for the asynchronous transaction callback in the onNewIntent()
      }
  }
   //paymentProvider?.submitTransaction(transaction, this)
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

}
