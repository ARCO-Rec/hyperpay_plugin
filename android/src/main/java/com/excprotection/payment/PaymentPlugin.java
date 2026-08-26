package com.excprotection.payment;

import com.oppwa.mobile.connect.checkout.dialog.CheckoutActivity;
import com.oppwa.mobile.connect.checkout.meta.CheckoutCardBrandsDisplayMode;
import com.oppwa.mobile.connect.payment.PaymentParams;
import com.oppwa.mobile.connect.payment.card.CardPaymentParams;
import com.oppwa.mobile.connect.payment.stcpay.STCPayPaymentParams;
import com.oppwa.mobile.connect.payment.stcpay.STCPayVerificationOption;
import com.oppwa.mobile.connect.provider.OppPaymentProvider;

import androidx.annotation.NonNull;
import androidx.browser.customtabs.CustomTabColorSchemeParams;
import androidx.browser.customtabs.CustomTabsIntent;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;

import com.oppwa.mobile.connect.checkout.meta.CheckoutSettings;
import com.oppwa.mobile.connect.checkout.meta.CheckoutStorePaymentDetailsMode;
import com.oppwa.mobile.connect.exception.PaymentError;
import com.oppwa.mobile.connect.exception.PaymentException;
import com.oppwa.mobile.connect.payment.BrandsValidation;
import com.oppwa.mobile.connect.payment.CheckoutInfo;
import com.oppwa.mobile.connect.payment.ImagesRequest;
import com.oppwa.mobile.connect.payment.token.Card;
import com.oppwa.mobile.connect.payment.token.Token;
import com.oppwa.mobile.connect.payment.token.TokenPaymentParams;
import com.oppwa.mobile.connect.provider.Connect;
import com.oppwa.mobile.connect.provider.ITransactionListener;
import com.oppwa.mobile.connect.provider.ThreeDSWorkflowListener;
import com.oppwa.mobile.connect.provider.Transaction;
import com.oppwa.mobile.connect.provider.TransactionType;

import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class PaymentPlugin implements
        PluginRegistry.ActivityResultListener, ActivityAware, ITransactionListener, ThreeDSWorkflowListener, FlutterPlugin, MethodCallHandler, PluginRegistry.NewIntentListener {

    private MethodChannel.Result Result;
    private String mode = "";
    private List<String> brandsReadyUi;
    private String brands = "";
    private String Lang = "";
    private String EnabledTokenization = "";
    private String ShopperResultUrl = "";
    private String setStorePaymentDetailsMode = "";
    private String number, holder, cvv, year, month;
    private String TokenID = "";
    private String Type = "";
    private String CheckoutId = "";
    private String checkoutInfoPurpose = "";
    private String captureSuccessStatus = "";
    private OppPaymentProvider paymentProvider = null;
    private Activity activity;
    private Context context;


    private final Handler handler = new Handler(Looper.getMainLooper());

    /// The MethodChannel that will the communication between Flutter and native Android
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    private MethodChannel channel;
    String CHANNEL = "Hyperpay.demo.fultter/channel";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

        Result = result;
        if (call.method.equals("gethyperpayresponse")) {

            String checkoutId = call.argument("checkoutid");
            String type = call.argument("type");
            mode = call.argument("mode");
            Lang = call.argument("lang");
            ShopperResultUrl = call.argument("ShopperResultUrl");
            CheckoutId = checkoutId;
            Type = type;

            switch (type != null ? type : "NullType") {
                case "ReadyUI":
                    brandsReadyUi = call.argument("brand");
                    setStorePaymentDetailsMode = call.argument("setStorePaymentDetailsMode");
                    openCheckoutUI(checkoutId);
                    break;
                case "StoredCards":
                    cvv = call.argument("cvv");
                    TokenID = call.argument("TokenID");
                    storedCardPayment(checkoutId);
                    break;

                case "CustomUI":
                    brands = call.argument("brand");
                    number = call.argument("card_number");
                    holder = call.argument("holder_name");
                    year = call.argument("year");
                    month = call.argument("month");
                    cvv = call.argument("cvv");
                    EnabledTokenization = call.argument("EnabledTokenization");
                    openCustomUI(checkoutId);
                    break;

                case "CustomUISTC":
                    number = call.argument("phone_number");
                    openCustomUISTC(checkoutId);
                    break;

                case "GetCheckoutInfo":
                    requestCheckoutInfo(checkoutId, "GetCheckoutInfo", "");
                    break;

                default:
                    error("1", "THIS TYPE NO IMPLEMENT" + type, "");
            }

        } else {
            notImplemented();
        }

    }

    private void openCheckoutUI(String checkoutId) {

        Set<String> paymentBrands = new LinkedHashSet<>(brandsReadyUi);
        // CHECK PAYMENT MODE
        CheckoutSettings checkoutSettings;
        if (mode.equals("live")) {
            //LIVE MODE
            checkoutSettings = new CheckoutSettings(checkoutId, paymentBrands,
                    Connect.ProviderMode.LIVE);

        } else {
            // TEST MODE
            checkoutSettings = new CheckoutSettings(checkoutId, paymentBrands,
                    Connect.ProviderMode.TEST);
        }

        // SET LANG
        checkoutSettings.setLocale(Lang);

        checkoutSettings.setPaymentFormListener(new CustomFormListener());

        // SHOW TOTAL PAYMENT AMOUNT IN BUTTON
        // checkoutSettings.setTotalAmountRequired(true);

        //SAVE PAYMENT CARDS FOR NEXT
        if (setStorePaymentDetailsMode.equals("true")) {
            checkoutSettings.setStorePaymentDetailsMode(CheckoutStorePaymentDetailsMode.PROMPT);
        }
        //CHANGE THEME
        checkoutSettings.setThemeResId(R.style.NewCheckoutTheme);
        checkoutSettings.setCardBrandsDisplayMode(CheckoutCardBrandsDisplayMode.SEPARATE);

        ComponentName componentName = new ComponentName(context.getPackageName(), CheckoutBroadcastReceiver.class.getName());

        Intent intent = new Intent(context.getApplicationContext(), CheckoutActivity.class);
        intent.putExtra(CheckoutActivity.CHECKOUT_SETTINGS, checkoutSettings);
        intent.putExtra(CheckoutActivity.CHECKOUT_RECEIVER, componentName);

        // START ACTIVITY
        activity.startActivityForResult(intent, 242);
    }

    private void storedCardPayment(String checkoutId) {

        try {

            TokenPaymentParams paymentParams = new TokenPaymentParams(checkoutId, TokenID, brands, cvv);

            paymentParams.setShopperResultUrl(ShopperResultUrl + "://result");

            Transaction transaction = new Transaction(paymentParams);

            //Set Mode;
            boolean resultMode = mode.equals("test");
            Connect.ProviderMode providerMode;

            if (resultMode) {
                providerMode = Connect.ProviderMode.TEST;
            } else {
                providerMode = Connect.ProviderMode.LIVE;
            }

            paymentProvider = new OppPaymentProvider(activity.getBaseContext(), providerMode);
            paymentProvider.setThreeDSWorkflowListener(this);

            //Submit Transaction
            //Listen for transaction Completed - transaction Failed
            paymentProvider.submitTransaction(transaction, this);

        } catch (PaymentException e) {
            e.printStackTrace();
            error("3", e.getLocalizedMessage(), "");
        }
    }

    /**
     * Requests checkout info from the server, either to list a shopper's saved cards
     * ("GetCheckoutInfo") or to capture the token created by a just-completed
     * tokenization-enabled payment ("CaptureToken"). Result is delivered asynchronously
     * via {@link #paymentConfigRequestSucceeded} / {@link #paymentConfigRequestFailed}.
     */
    private void requestCheckoutInfo(String checkoutId, String purpose, String captureStatus) {
        checkoutInfoPurpose = purpose;
        captureSuccessStatus = captureStatus;

        boolean resultMode = mode.equals("test");
        Connect.ProviderMode providerMode = resultMode ? Connect.ProviderMode.TEST : Connect.ProviderMode.LIVE;

        paymentProvider = new OppPaymentProvider(activity.getBaseContext(), providerMode);
        paymentProvider.requestCheckoutInfo(checkoutId, this);
    }

    private Map<String, Object> tokenToMap(Token token) {
        Map<String, Object> map = new HashMap<>();
        map.put("tokenId", token.getTokenId());
        map.put("paymentBrand", token.getPaymentBrand());
        Card card = token.getCard();
        if (card != null) {
            map.put("last4Digits", card.getLast4Digits());
            map.put("expiryMonth", card.getExpiryMonth());
            map.put("expiryYear", card.getExpiryYear());
            map.put("holder", card.getHolder());
        }
        return map;
    }

    private List<Map<String, Object>> tokensToList(CheckoutInfo checkoutInfo) {
        List<Map<String, Object>> list = new ArrayList<>();
        Token[] tokens = checkoutInfo.getTokens();
        if (tokens != null) {
            for (Token token : tokens) {
                list.add(tokenToMap(token));
            }
        }
        return list;
    }

    private void openCustomUI(String checkoutId) {

        Toast.makeText(activity.getApplicationContext(), Lang.equals("en_US")
                ? "Please Wait.."
                : "برجاء الانتظار..", Toast.LENGTH_SHORT).show();

        if (!CardPaymentParams.isNumberValid(number, true)) {
            Toast.makeText(activity.getApplicationContext(), Lang.equals("en_US")
                            ? "Card number is invalid for brand"
                            : "رقم البطاقة غير صالح",
                    Toast.LENGTH_SHORT).show();
        } else if (!CardPaymentParams.isHolderValid(holder)) {
            Toast.makeText(activity.getApplicationContext(), Lang.equals("en_US")
                            ? "Holder name is invalid"
                            : "اسم المالك غير صالح"
                    , Toast.LENGTH_SHORT).show();
        } else if (!CardPaymentParams.isExpiryYearValid(year)) {
            Toast.makeText(activity.getApplicationContext(), Lang.equals("en_US")
                            ? "Expiry year is invalid"
                            : "سنة انتهاء الصلاحية غير صالحة",
                    Toast.LENGTH_SHORT).show();
        } else if (!CardPaymentParams.isExpiryMonthValid(month)) {
            Toast.makeText(activity.getApplicationContext(), Lang.equals("en_US")
                            ? "Expiry month is invalid"
                            : "شهر انتهاء الصلاحية غير صالح"
                    , Toast.LENGTH_SHORT).show();
        } else if (!CardPaymentParams.isCvvValid(cvv)) {
            Toast.makeText(activity.getApplicationContext(), Lang.equals("en_US")
                            ? "CVV is invalid"
                            : "CVV غير صالح"
                    , Toast.LENGTH_SHORT).show();
        } else {

            boolean EnabledTokenizationTemp = EnabledTokenization.equals("true");
            try {
                PaymentParams paymentParams = new CardPaymentParams(
                        checkoutId, brands, number, holder, month, year, cvv
                ).setTokenizationEnabled(EnabledTokenizationTemp);//Set Enabled TokenizationTemp

                paymentParams.setShopperResultUrl(ShopperResultUrl + "://result");

                Transaction transaction = new Transaction(paymentParams);

                //Set Mode;
                boolean resultMode = mode.equals("test");
                Connect.ProviderMode providerMode;

                if (resultMode) {
                    providerMode = Connect.ProviderMode.TEST;
                } else {
                    providerMode = Connect.ProviderMode.LIVE;
                }

                paymentProvider = new OppPaymentProvider(activity.getBaseContext(), providerMode);
                paymentProvider.setThreeDSWorkflowListener(this);

                //Submit Transaction
                //Listen for transaction Completed - transaction Failed
                paymentProvider.submitTransaction(transaction, this);

            } catch (PaymentException e) {
                error("0.1", e.getLocalizedMessage(), "");
            }
        }
    }

    private void openCustomUISTC(String checkoutId) {

        Toast.makeText(activity.getApplicationContext(), Lang.equals("en_US")
                ? "Please Wait.."
                : "برجاء الانتظار..", Toast.LENGTH_SHORT).show();
        try {
            //Set Mode
            boolean resultMode = mode.equals("test");
            Connect.ProviderMode providerMode;

            if (resultMode) {
                providerMode = Connect.ProviderMode.TEST;
            } else {
                providerMode = Connect.ProviderMode.LIVE;
            }

            STCPayPaymentParams stcPayPaymentParams = new STCPayPaymentParams(checkoutId, STCPayVerificationOption.MOBILE_PHONE);

            stcPayPaymentParams.setMobilePhoneNumber(number);

            stcPayPaymentParams.setShopperResultUrl(ShopperResultUrl + "://result");

            Transaction transaction = new Transaction(stcPayPaymentParams);

            paymentProvider = new OppPaymentProvider(activity.getBaseContext(), providerMode);
            paymentProvider.setThreeDSWorkflowListener(this);

            //Submit Transaction
            //Listen for transaction Completed - transaction Failed
            paymentProvider.submitTransaction(transaction, this);

        } catch (PaymentException e) {
            e.printStackTrace();
            error("3", e.getLocalizedMessage(), "");
        }

    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (resultCode) {
            case CheckoutActivity.RESULT_OK:
                /* transaction completed */
                Transaction transaction = data.getParcelableExtra(CheckoutActivity.CHECKOUT_RESULT_TRANSACTION);
                /* resource path if needed */
                // String resourcePath = data.getStringExtra(CheckoutActivity.CHECKOUT_RESULT_RESOURCE_PATH);
                if (transaction.getTransactionType() == TransactionType.SYNC) {
                    /* check the result of synchronous transaction */
                    if (setStorePaymentDetailsMode.equals("true")) {
                        requestCheckoutInfo(CheckoutId, "CaptureToken", "Sync");
                    } else {
                        success("Sync");
                    }
                }

                break;
            case CheckoutActivity.RESULT_CANCELED:
                /* shopper canceled the checkout process */
                error("2", "Cancelled", "");
                break;

            case CheckoutActivity.RESULT_ERROR:
                /* shopper error the checkout process */
                error("3", "Checkout result error", "");
                break;

            default:
                break;

        }

        return true;
    }

    public void success(final Object result) {
        handler.post(
                () -> Result.success(result));
    }

    public void error(
            @NonNull final String errorCode, final String errorMessage, final Object errorDetails) {
        handler.post(
                () -> Result.error(errorCode, errorMessage, errorDetails));
    }

    public void notImplemented() {
        handler.post(
                () -> Result.notImplemented());
    }

    @Override
    public boolean onNewIntent(@NonNull Intent intent) {
        // TO BACK TO VIEW
        if (intent.getScheme() != null && intent.getScheme().equals(ShopperResultUrl)) {
            success("Success");
            return true;
        }
        return false;
    }

    @Override
    public void transactionCompleted(@NonNull Transaction transaction) {

        if (transaction.getTransactionType() == TransactionType.SYNC) {
            if ("CustomUI".equals(Type) && EnabledTokenization.equals("true")) {
                requestCheckoutInfo(CheckoutId, "CaptureToken", "Sync");
            } else {
                success("Sync");
            }
        } else {
            /* wait for the callback in the s */
            Uri uri = Uri.parse(transaction.getRedirectUrl());

            launchCustomTabs(uri);
        }
    }

    private void launchCustomTabs(Uri uri) {
        CustomTabColorSchemeParams colorParams = new CustomTabColorSchemeParams.Builder()
                .setToolbarColor(ContextCompat.getColor(context, R.color.headerBackground))
                .build();

        CustomTabsIntent customTabsIntent = new CustomTabsIntent.Builder()
                .setShowTitle(true)
                .setDefaultColorSchemeParams(colorParams)
                .setShareState(CustomTabsIntent.SHARE_STATE_OFF)
                .build();

        customTabsIntent.intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
        customTabsIntent.launchUrl(activity, uri);

    }

    @Override
    public void transactionFailed(@NonNull Transaction transaction, @NonNull PaymentError paymentError) {
        error("Transaction failed", paymentError.getErrorMessage(), paymentError.getErrorInfo()
        );
    }

    /**
     * Without this, the SDK has no Activity to present the native 3-D Secure
     * challenge screen in, so any card that requires a challenge (as opposed to a
     * frictionless transaction) fails or hangs on the CustomUI/StoredCards/CustomUISTC
     * paths - ReadyUI is unaffected because it uses the SDK's own CheckoutActivity,
     * which wires this up internally.
     */
    @Override
    public Activity onThreeDSChallengeRequired() {
        return activity;
    }

    @Override
    public void brandsValidationRequestSucceeded(@NonNull BrandsValidation brandsValidation) {
        ITransactionListener.super.brandsValidationRequestSucceeded(brandsValidation);
    }

    @Override
    public void brandsValidationRequestFailed(@NonNull PaymentError paymentError) {
        ITransactionListener.super.brandsValidationRequestFailed(paymentError);
    }

    @Override
    public void imagesRequestSucceeded(@NonNull ImagesRequest imagesRequest) {
        ITransactionListener.super.imagesRequestSucceeded(imagesRequest);
    }

    @Override
    public void imagesRequestFailed() {
        ITransactionListener.super.imagesRequestFailed();
    }

    @Override
    public void paymentConfigRequestSucceeded(@NonNull CheckoutInfo checkoutInfo) {
        if ("GetCheckoutInfo".equals(checkoutInfoPurpose)) {
            success(Collections.singletonMap("tokens", tokensToList(checkoutInfo)));
        } else if ("CaptureToken".equals(checkoutInfoPurpose)) {
            // Never fail the payment result just because token capture failed.
            Token[] tokens = checkoutInfo.getTokens();
            if (tokens != null && tokens.length > 0) {
                Map<String, Object> resultMap = tokenToMap(tokens[tokens.length - 1]);
                resultMap.put("status", captureSuccessStatus);
                success(resultMap);
            } else {
                success(captureSuccessStatus);
            }
        } else {
            ITransactionListener.super.paymentConfigRequestSucceeded(checkoutInfo);
        }
    }

    @Override
    public void paymentConfigRequestFailed(@NonNull PaymentError paymentError) {
        if ("GetCheckoutInfo".equals(checkoutInfoPurpose)) {
            error("1", paymentError.getErrorMessage(), paymentError.getErrorInfo());
        } else if ("CaptureToken".equals(checkoutInfoPurpose)) {
            success(captureSuccessStatus);
        } else {
            ITransactionListener.super.paymentConfigRequestFailed(paymentError);
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        binding.addActivityResultListener(this);
        binding.addOnNewIntentListener(this); // TO LISTEN ON NEW INTENT OPEN
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    }

    @Override
    public void onDetachedFromActivity() {
    }

    @Override
    public void binRequestSucceeded(@NonNull String[] brands) {
        ITransactionListener.super.binRequestSucceeded(brands);
    }

    @Override
    public void binRequestFailed() {
        ITransactionListener.super.binRequestFailed();
    }
}
