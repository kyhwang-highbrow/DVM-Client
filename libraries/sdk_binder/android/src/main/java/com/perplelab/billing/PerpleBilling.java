package com.perplelab.billing;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.android.billingclient.api.AcknowledgePurchaseParams;
import com.android.billingclient.api.AcknowledgePurchaseResponseListener;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.ConsumeParams;
import com.android.billingclient.api.ConsumeResponseListener;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesResponseListener;
import com.android.billingclient.api.PurchasesUpdatedListener;
import com.android.billingclient.api.SkuDetails;
import com.android.billingclient.api.SkuDetailsParams;
import com.android.billingclient.api.SkuDetailsResponseListener;

import com.perplelab.PerpleSDK;
import com.perplelab.PerpleSDKCallback;
import com.perplelab.PerpleLog;

import android.app.Activity;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.MutableLiveData;


public class PerpleBilling implements PurchasesUpdatedListener {
    private static final String LOG_TAG = "PerpleSDK_Billing";

    private Handler mAppHandler;
    private String mUri;    // 영수증 검사용 uri
    // 결제 시도 시 사용되는 변수
    private String mPurchaseSku; // 결제를 시도 중인 상품의  sku
    private PerpleSDKCallback mPurchaseCallback;

    private BillingClient billingClient;

    /**
     * SkuDetails for all known SKUs.
     */
    public MutableLiveData<Map<String, SkuDetails>> skusWithSkuDetails = new MutableLiveData<>();

    /**
     * Purchases are observable. This list will be updated when the Billing Library
     * detects new or existing purchases. All observers will be notified.
     */
    public MutableLiveData<List<Purchase>> mPurchases = new MutableLiveData<>();

    public PerpleBilling() {}

    public void init() {
        PerpleLog.d(LOG_TAG, "PerpleBilling init!");

        // mAppHandler를 통해 메인 쓰레드에서 함수를 호출하기 위해 사용
        mAppHandler = new Handler(Looper.getMainLooper());

        // BillingClient 초기화
        Activity activity = PerpleSDK.getInstance().getMainActivity();
        PurchasesUpdatedListener purchasesUpdatedListener = this; // PurchasesUpdatedListener 상속
        billingClient = BillingClient.newBuilder(activity)
                .setListener(purchasesUpdatedListener)
                .enablePendingPurchases()
                .build();
    }

    /**
     *
     * @param url 드빌M의 함수 구조를 유지하기 위해 남겨짐 (영수증 검증을 위한 플랫폼 서버 url)
     * @param unusedUrl 드빌M의 함수 구조를 유지하기 위해 남겨짐 (payload 정보를 저장할 때 사용했던 플랫폼 서버 url)
     * @param callback lua 콜백
     */
    public void startSetup(String url, String unusedUrl, final PerpleSDKCallback callback) {
        PerpleLog.d(LOG_TAG, "Starting in-app billing setup.");

        this.mUri = url;

        // 이미 초기화가 된 경우 success로 리턴
        if (isReady()) {
            PerpleLog.d(LOG_TAG, "In-app billing setup is already completed.");
            callback.onSuccess("In-app billing setup is already completed.");
            return;
        }

        // Main Thread(UI Thread)에서 동작
        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                PerpleLog.d(LOG_TAG, "BillingClient: Start connection...");
                billingClient.startConnection(new BillingClientStateListener() {
                    @Override
                    public void onBillingSetupFinished(BillingResult billingResult) {
                        PerpleLog.d(LOG_TAG, "In-app billing setup finished - result:" + billingResult);

                        // success
                        if (billingResult.getResponseCode() ==  BillingClient.BillingResponseCode.OK) {
                            // The BillingClient is ready. You can query purchases here.
                            queryPurchases(BillingClient.SkuType.INAPP);
                            callback.onSuccess("In-app billing setup finished.");
                        }
                        // fail
                        else {
                            String code = PerpleSDK.ERROR_BILLING_SETUP;
                            String subcode =  String.valueOf(billingResult.getResponseCode());
                            String msg = billingResult.getDebugMessage();
                            String info = PerpleSDK.getErrorInfo(code, subcode, msg);
                            callback.onFail(info);
                        }
                    }
                    @Override
                    public void onBillingServiceDisconnected() {
                        // Try to restart the connection on the next request to
                        // Google Play by calling the startConnection() method.
                    }
                });
            }
        });
    }

    public void onDestroy() {
        PerpleLog.d(LOG_TAG, "Destroying helper.");
        billingClient.endConnection();
    }

    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        PerpleLog.d(LOG_TAG, "onActivityResult(" + requestCode + "," + resultCode + "," + data + ")");
        return false;
    }
    
    /*
    public IInAppBillingService getBillingService() {
        return mHelper.getService();
    }
    */

    /**
     * @param sku
     * @param payload
     * @param callback
     */
    public void purchase(final String sku, final String payload, final PerpleSDKCallback callback) {
        PerpleLog.d(LOG_TAG, "Purchasing requested - sku: " + sku + ", payload:" + payload);

        // 초기화가 되지 않은 경우
        if (!isReady()) {
            PerpleLog.d(LOG_TAG, "In-app billing setup is not completed.");
            String code = PerpleSDK.ERROR_BILLING_PURCHASE;
            String msg = "In-app billing setup is not completed.";
            String info = PerpleSDK.getErrorInfo(code, msg);
            callback.onFail(info); // fail 콜백
            return;
        }

        mPurchaseSku = sku;
        mPurchaseCallback = callback;

        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                SkuDetails skuDetails = getSkuDetails(sku);
                if (skuDetails == null) {
                    String code = PerpleSDK.ERROR_BILLING_INVALIDPRODUCT; // -1507
                    String msg = "Purchasing requested fail. skuDetails is null. sku: " + sku;
                    String info = PerpleSDK.getErrorInfo(code, msg);
                    PerpleLog.d(LOG_TAG, msg);
                    mPurchaseCallback.onFail(info); // fail 콜백
                    return;
                }

                // An activity reference from which the billing flow will be launched.
                Activity activity = PerpleSDK.getInstance().getMainActivity();

                // Retrieve a value for "skuDetails" by calling querySkuDetailsAsync().
                BillingFlowParams billingFlowParams = BillingFlowParams.newBuilder()
                        .setSkuDetails(skuDetails)
                        .build();
                BillingResult billingResult = billingClient.launchBillingFlow(activity, billingFlowParams);
                int responseCode = billingResult.getResponseCode();
                String debugMessage = billingResult.getDebugMessage();

                // launchBillingFlow 실패
                if (responseCode != BillingClient.BillingResponseCode.OK) {
                    String code = PerpleSDK.ERROR_BILLING_PURCHASE;
                    String subcode = String.valueOf(responseCode);
                    String msg = debugMessage;
                    String info = PerpleSDK.getErrorInfo(code, subcode, msg);
                    PerpleLog.d(LOG_TAG, msg);
                    mPurchaseCallback.onFail(info); // fail 콜백
                }
            }
        });
    }

    /**
     * @param sku
     * @return SkuDetails
     */
    public SkuDetails getSkuDetails(final String sku) {
        if (skusWithSkuDetails.getValue() == null) {
            return null;
        }

        SkuDetails skuDetails = skusWithSkuDetails.getValue().get(sku);
        return skuDetails;
    }

    public void consume(final String orderId) {

        if (!isReady()) {
            return;
        }

        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                Purchase purchase = getPurchasesByOrderId(orderId);

                if (purchase == null) {
                    return;
                }

                ConsumeParams consumeParams =
                        ConsumeParams.newBuilder()
                                .setPurchaseToken(purchase.getPurchaseToken())
                                .build();

                ConsumeResponseListener listener = new ConsumeResponseListener() {
                    @Override
                    public void onConsumeResponse(BillingResult billingResult, String purchaseToken) {
                        if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                            // Handle the success of the consume operation.
                        }
                    }
                };

                billingClient.consumeAsync(consumeParams, listener);
            }
        });
    }

    /**
     * @param skuListStr "dvnew_default_1.1k;dvnew_default_3.3k;dvnew_default_5.5k"형태로 sku가 ;로 구분되어있는 문자열
     * @param callback
     */
    public void getItemList(final String skuListStr, final PerpleSDKCallback callback ) {
        // 빌링 초기화가 되지 않아 fail
        if (!isReady()) {
            PerpleLog.d(LOG_TAG, "In-app billing setup is not completed.");
            String code = PerpleSDK.ERROR_BILLING_NOTINITIALIZED;
            String msg = "In-app billing setup is not completed.";
            String info = PerpleSDK.getErrorInfo(code, msg);
            callback.onFail(info); // fail 콜백
            return;
        }

        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                PerpleLog.d(LOG_TAG, "Starting in-app getItemList.");

                // sku가 ;로 연결되어있는 문자열을 분리
                // e.g. "dvnew_default_1.1k;dvnew_default_3.3k;dvnew_default_5.5k"
                List<String> skuList = new ArrayList<> ();
                StringTokenizer tempList = new StringTokenizer(skuListStr, ";");
                while( tempList.hasMoreTokens())
                {
                    skuList.add( tempList.nextToken() );
                }

                // query
                SkuDetailsParams.Builder params = SkuDetailsParams.newBuilder();
                params.setSkusList(skuList).setType(BillingClient.SkuType.INAPP);

                // Important : Async를 사용했을 때 콜백이 런타임에 여러번 호출이 될 수 있다.
                billingClient.querySkuDetailsAsync(params.build(),
                        new SkuDetailsResponseListener() {
                            @Override
                            public void onSkuDetailsResponse(@NonNull BillingResult billingResult, @Nullable List<SkuDetails> skuDetailsList) {

                                // billingResult이 null일 경우 fail
                                if (billingResult == null) {
                                    PerpleLog.d(LOG_TAG, "onSkuDetailsResponse: null BillingResult");
                                    String code = PerpleSDK.ERROR_BILLING_QUARY_SKU_DETAIL;
                                    String msg = "onSkuDetailsResponse: null BillingResult";
                                    String info = PerpleSDK.getErrorInfo(code, msg);
                                    callback.onFail(info); // fail 콜백
                                    return;
                                }

                                int responseCode = billingResult.getResponseCode();
                                String debugMessage = billingResult.getDebugMessage();
                                String info = "";
                                PerpleLog.d(LOG_TAG, "onSkuDetailsResponse: " + responseCode + " " + debugMessage);

                                switch (responseCode) {
                                    // 성공의 경우
                                    case BillingClient.BillingResponseCode.OK:
                                        PerpleLog.d(LOG_TAG,
                                                "onSkuDetailsResponse - received list size : "
                                                        + skuDetailsList.size());

                                        // skuDetail을 저장
                                        Map<String, SkuDetails> newSkusDetailList = new HashMap<>();

                                        for (SkuDetails skuDetails : skuDetailsList) {
                                            PerpleLog.d(LOG_TAG,
                                                    "onSkuDetailsResponse - adding sku : "
                                                            + skuDetails.getSku());
                                            newSkusDetailList.put(skuDetails.getSku(), skuDetails);
                                        }

                                        // 기존에 추가된 sku들도 함께 추가
                                        if (skusWithSkuDetails.getValue() != null) {
                                            for (SkuDetails curDetails : skusWithSkuDetails.getValue().values()) {
                                                if (!newSkusDetailList.containsKey(curDetails.getSku())) {
                                                    PerpleLog.d(LOG_TAG,
                                                            "onSkuDetailsResponse - adding exsist sku : "
                                                                    + curDetails.getSku());
                                                    newSkusDetailList.put(curDetails.getSku(), curDetails);
                                                }
                                            }
                                        }

                                        skusWithSkuDetails.postValue(newSkusDetailList);

                                        PerpleLog.d(LOG_TAG,
                                                "onSkuDetailsResponse - current skuDetailsList size : "
                                                        + newSkusDetailList.size());

                                        // skuDetails를 json리스트로 변환
                                        JSONArray skuDetailsJsonArray = new JSONArray();
                                        for (SkuDetails skuDetails : skuDetailsList) {
                                            String itemInfo = skuDetails.getOriginalJson();
                                            try {
                                                JSONObject jitem = new JSONObject(itemInfo);
                                                skuDetailsJsonArray.put(jitem);
                                            } catch (JSONException e) {
                                                e.printStackTrace();
                                            }
                                        }

                                        // json 문자열로 info를 전달
                                        // 100개에 해당하는 정보까지 정상동작함을 테스트함 @sgkim 2021.03.17
                                        info = skuDetailsJsonArray.toString();
                                        // e.g. [{"productId":"dvnew_default_1.1k","type":"inapp","price":"₩1,100","price_amount_micros":1100000000,"price_currency_code":"KRW","title":"1100원 상품 (Bubbly Operator)","description":"1100원 상품","skuDetailsToken":"AEuhp4IPSGPiSWeSqp5ik7wMKL5jDf-Dz6G9r8J8r9DrmfF5dOyqfR0QjKfORd5n2QY="},
                                        // {"productId":"dvnew_default_3.3k","type":"inapp","price":"₩3,300","price_amount_micros":3300000000,"price_currency_code":"KRW","title":"3300원 상품 (Bubbly Operator)","description":"3300원 상품","skuDetailsToken":"AEuhp4JTWyaUFQKsx-DLo25w6nrywVBYepk7gaG9p5NDCbWk721CUajyfu-p4hX7PgY="}]
                                        callback.onSuccess(info); // success 콜백

                                        break;
                                    // 실패의 경우
                                    default:
                                        String code = PerpleSDK.ERROR_BILLING_QUARY_SKU_DETAIL;
                                        String subcode = String.valueOf(responseCode);
                                        String msg = debugMessage;
                                        info = PerpleSDK.getErrorInfo(code, subcode, msg);
                                        callback.onFail(info); // fail 콜백
                                        break;
                                }
                            }
                        });
            }
         });

    }

    public void getIncompletePurchaseList(final PerpleSDKCallback callback) {
        PerpleLog.d(LOG_TAG, "getIncompletePurchaseList: start");

        if (!isReady()) {
            String code = PerpleSDK.ERROR_BILLING_NOTINITIALIZED;
            String msg = "getIncompletePurchaseList: In-app billing module is not initialized.";
            String info = PerpleSDK.getErrorInfo(code, msg);
            PerpleLog.d(LOG_TAG, msg);
            callback.onFail(info);
            return;
        }

        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                queryPurchases(BillingClient.SkuType.INAPP);
                List<Purchase> purchaseList = mPurchases.getValue();

                // skuDetails를 json리스트로 변환
                JSONArray purchaseJsonArray = new JSONArray();
                if (purchaseList != null) {
                    for (Purchase purchase : purchaseList) {
                        String purchaseOritinJson = purchase.getOriginalJson();
                        try {
                            JSONObject jsonObject = new JSONObject(purchaseOritinJson);
                            purchaseJsonArray.put(jsonObject);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                }

                // json 문자열로 info를 전달
                String info = purchaseJsonArray.toString();
                String msg = "getIncompletePurchaseList: info - " + info;
                callback.onSuccess(info);
            }
        });
    }

    /**
     * PurchasesUpdatedListener
     * Called by the Billing Library when new purchases are detected.
     */
    @Override
    public void onPurchasesUpdated(@NonNull BillingResult billingResult, @Nullable List<Purchase> purchases) {
        if (billingResult == null) {
            PerpleLog.d(LOG_TAG, "onPurchasesUpdated: null BillingResult");
            return;
        }
        int responseCode = billingResult.getResponseCode();
        String debugMessage = billingResult.getDebugMessage();
        PerpleLog.d(LOG_TAG, "onPurchasesUpdated: $responseCode $debugMessage");
        switch (responseCode) {
            case BillingClient.BillingResponseCode.OK:
                if (purchases == null) {
                    PerpleLog.d(LOG_TAG, "onPurchasesUpdated: null purchase list");
                    processPurchases(null);
                    mPurchaseCallback.onFail("null purchase list"); // fail 콜백

                } else {
                    processPurchases(purchases);

                    Purchase purchase = null;
                    for (final Purchase p : purchases) {
                        ArrayList<String> sku_list = p.getSkus();

                        for (final String sku : sku_list)
                        {
                            if (mPurchaseSku.equals(sku)) {
                                purchase = p;
                                break;
                            }
                        }
                    }

                    if (purchase == null) {
                        PerpleLog.d(LOG_TAG, "onPurchasesUpdated: null purchase");
                        mPurchaseCallback.onFail("null purchase"); // fail 콜백
                    } else {
                        String info = purchase.getOriginalJson();
                        mPurchaseCallback.onSuccess(info);

                        // 구매 확인 acknowledge
                        acknowledgePurchase(purchase.getPurchaseToken());
                    }
                }
                break;
            case BillingClient.BillingResponseCode.USER_CANCELED:
                PerpleLog.d(LOG_TAG, "onPurchasesUpdated: User canceled the purchase");
                mPurchaseCallback.onFail("cancel"); // fail 콜백
                break;
            case BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED:
                PerpleLog.d(LOG_TAG, "onPurchasesUpdated: The user already owns this item");
                mPurchaseCallback.onFail("item_already_owned"); // fail 콜백
                break;
            case BillingClient.BillingResponseCode.DEVELOPER_ERROR:
                PerpleLog.d(LOG_TAG, "onPurchasesUpdated: Developer error means that Google Play " +
                        "does not recognize the configuration. If you are just getting started, " +
                        "make sure you have configured the application correctly in the " +
                        "Google Play Console. The SKU product ID must match and the APK you " +
                        "are using must be signed with release keys."
                );
            default:
                String code = PerpleSDK.ERROR_BILLING_PURCHASE;
                String subcode = String.valueOf(responseCode);
                String msg = debugMessage;
                String info = PerpleSDK.getErrorInfo(code, subcode, msg);
                PerpleLog.d(LOG_TAG, "onPurchasesUpdated: " + msg);
                mPurchaseCallback.onFail(info); // fail 콜백
                break;
        }
    }

    /**
     * Query Google Play Billing for existing purchases.
     * <p>
     * New purchases will be provided to the PurchasesUpdatedListener.
     * You still need to check the Google Play Billing API to know when purchase tokens are removed.
     */
    public void queryPurchases(@NonNull String skuType) {
        if (!billingClient.isReady()) {
            PerpleLog.d(LOG_TAG, "queryPurchases: BillingClient is not ready");
        }

        PerpleLog.d(LOG_TAG, "queryPurchases: INAPP");
        // BillingClient.SkuType  SUBS INAPP
        String finalSkuType = skuType;

        billingClient.queryPurchasesAsync(finalSkuType, new PurchasesResponseListener() {
            @Override
            public void onQueryPurchasesResponse(@NonNull BillingResult billingResult, @NonNull List<Purchase> list) {
                if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                    if (list.isEmpty()) {
                        PerpleLog.d(LOG_TAG, "queryPurchases: null purchase list");
                        processPurchases(null);
                    } else {
                        processPurchases(list);
                    }
                }
                else {
                    PerpleLog.d(LOG_TAG, "onQueryPurchasesResponse - : empty purchase list");
                    processPurchases(null);
                }
            }
        });
    }

    /**
     * Send purchase SingleLiveEvent and update purchases LiveData.
     * <p>
     * The SingleLiveEvent will trigger network call to verify the subscriptions on the sever.
     * The LiveData will allow Google Play settings UI to update based on the latest purchase data.
     */
    private void processPurchases(List<Purchase> purchasesList) {
        if (purchasesList != null) {
            PerpleLog.d(LOG_TAG, "processPurchases: " + purchasesList.size() + " purchase(s)");
        } else {
            PerpleLog.d(LOG_TAG, "processPurchases: with no purchases");
        }
        mPurchases.postValue(purchasesList);
    }

    public Purchase getPurchasesByOrderId(String orderId) {
        if (mPurchases.getValue() == null) {
            return null;
        }
        for (Purchase p : mPurchases.getValue()) {
            if (orderId.equals(p.getOrderId())) {
                return p;
            }
        }
        return null;
    }

    /**
     *
     * @return 결제 준비가 되었는지 여부
     */
    public boolean isReady() {
        if (billingClient == null) {
            PerpleLog.d(LOG_TAG, "isReady: billingClient is null. returns false.");
            return false;
        }

        if (!billingClient.isReady()) {
            PerpleLog.d(LOG_TAG, "isReady: billingClient is not ready. returns false.");
            return false;
        }

        PerpleLog.d(LOG_TAG, "isReady: returns true.");
        return true;
    }

    public void acknowledgePurchase(String purchaseToken) {
        PerpleLog.d(LOG_TAG, "acknowledgePurchase: start. purchaseToken: " + purchaseToken);
        AcknowledgePurchaseParams acknowledgePurchaseParams =
                AcknowledgePurchaseParams.newBuilder()
                        .setPurchaseToken(purchaseToken)
                        .build();

        billingClient.acknowledgePurchase(acknowledgePurchaseParams, new AcknowledgePurchaseResponseListener() {
                    @Override
                    public void onAcknowledgePurchaseResponse(@NonNull BillingResult billingResult) {
                        int responseCode = billingResult.getResponseCode();
                        String debugMessage = billingResult.getDebugMessage();
                        PerpleLog.d(LOG_TAG, "acknowledgePurchase: responseCode: " + responseCode);
                        PerpleLog.d(LOG_TAG, "acknowledgePurchase: debugMessage: " + debugMessage);
                        PerpleLog.d(LOG_TAG, "acknowledgePurchase: finished.");
                    }
                }
        );
    }

    public void subscription(final String sku, final String payload, final PerpleSDKCallback callback) {
        PerpleLog.d(LOG_TAG, "Subscription requested - sku: " + sku + ", payload:" + payload);

        // 초기화가 되지 않은 경우
        if (!isReady()) {
            PerpleLog.d(LOG_TAG, "In-app billing setup is not completed.");
            String code = PerpleSDK.ERROR_BILLING_PURCHASE;
            String msg = "In-app billing setup is not completed.";
            String info = PerpleSDK.getErrorInfo(code, msg);
            callback.onFail(info); // fail 콜백
            return;
        }

        mPurchaseSku = sku;
        mPurchaseCallback = callback;

        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                try {
                    SkuDetails skuDetails = getSkuDetails(sku);
                    if (skuDetails == null) {
                        String code = PerpleSDK.ERROR_BILLING_INVALIDPRODUCT; // -1507
                        String msg = "Purchasing requested fail. skuDetails is null. sku: " + sku;
                        String info = PerpleSDK.getErrorInfo(code, msg);
                        PerpleLog.d(LOG_TAG, msg);
                        mPurchaseCallback.onFail(info); // fail 콜백
                        return;
                    }

                    // An activity reference from which the billing flow will be launched.
                    Activity activity = PerpleSDK.getInstance().getMainActivity();

                    // Retrieve a value for "skuDetails" by calling querySkuDetailsAsync().
                    BillingFlowParams billingFlowParams = BillingFlowParams.newBuilder()
                            .setSkuDetails(skuDetails)
                            .build();
                    BillingResult billingResult = billingClient.launchBillingFlow(activity, billingFlowParams);
                    int responseCode = billingResult.getResponseCode();
                    String debugMessage = billingResult.getDebugMessage();

                    // launchBillingFlow 실패
                    if (responseCode != BillingClient.BillingResponseCode.OK) {
                        String code = PerpleSDK.ERROR_BILLING_PURCHASE;
                        String subcode = String.valueOf(responseCode);
                        String msg = debugMessage;
                        String info = PerpleSDK.getErrorInfo(code, subcode, msg);
                        PerpleLog.d(LOG_TAG, msg);
                        mPurchaseCallback.onFail(info); // fail 콜백
                    }

                } catch (Exception e) {
                    mPurchaseCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_PURCHASE, ""));
                }
            }
        });
    }

    public String getPurchaseCheckReceiptUri() { return mUri; }
}
