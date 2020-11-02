package com.perplelab.billing;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.android.vending.billing.IInAppBillingService;
import com.perplelab.PerpleSDK;
import com.perplelab.PerpleSDKCallback;
import com.perplelab.PerpleLog;
import com.perplelab.billing.util.IabHelper;
import com.perplelab.billing.util.IabHelper.OnConsumeFinishedListener;
import com.perplelab.billing.util.IabHelper.OnConsumeMultiFinishedListener;
import com.perplelab.billing.util.IabResult;
import com.perplelab.billing.util.Inventory;
import com.perplelab.billing.util.Purchase;
import com.perplelab.billing.util.SkuDetails;

import android.content.Intent;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;

import static com.perplelab.billing.util.IabHelper.IABHELPER_USER_CANCELLED;

public class PerpleBilling {
    private static final String LOG_TAG = "PerpleSDK Billing";

    private Handler mAppHandler;
    private IabHelper mHelper;
    private String mUri;
    private PerpleSDKCallback mSetupCallback;
    private PerpleSDKCallback mIncompletePurchaseCallback;
    private PerpleSDKCallback mPurchaseCallback;
    private PerpleSDKCallback mItemListCallback;
    private IabHelper.QueryInventoryFinishedListener mGotInventoryListener;
    private IabHelper.OnIabPurchaseFinishedListener mPurchaseFinishedListener;
    private IabHelper.QueryInventoryFinishedListener mGetItemListInventoryListener;

    private boolean mIsSetupCompleted;

    private int mIncompletePurchasesCount;
    private Map<Purchase, Boolean> mIncompletePurchases;

    private Map<String, Purchase> mPurchases;

    private List<String> mRequestItemAllList;
    private JSONArray mJArrayItemDetail;

    public PerpleBilling() {}

    /* base64EncodedPublicKey should be YOUR APPLICATION'S PUBLIC KEY
     * (that you got from the Google Play developer console). This is not your
     * developer public key, it's the *app-specific* public key.
     *
     * Instead of just storing the entire literal string here embedded in the
     * program,  construct the key at runtime from pieces or
     * use bit manipulation (for example, XOR with some other string) to hide
     * the actual key.  The key itself is not secret information, but we don't
     * want to make it easy for an attacker to replace the public key with one
     * of their own and then fake messages from the server.
     */
    public void init(String base64EncodedPublicKey, boolean isDebug) {

        mAppHandler = new Handler(Looper.getMainLooper());

        mIncompletePurchases = new HashMap<Purchase, Boolean>();
        mPurchases = new HashMap<String, Purchase>();

        // Create the helper, passing it our context and the public key to verify signatures with
        PerpleLog.d(LOG_TAG, "Creating IAB helper.");
        mHelper = new IabHelper(PerpleSDK.getInstance().getMainActivity(), base64EncodedPublicKey);

        // enable debug logging (for a production application, you should set this to false).
        mHelper.enableDebugLogging(isDebug);
    }

    public void startSetup(String url, String unusedUrl, PerpleSDKCallback callback) {
        // 영수증 검증 플랫폼 서버 API 주소
        // ex) http://platform.perplelab.com/@gameId/payment/receiptValidation
        mUri = url;

        mSetupCallback = callback;

        if (mIsSetupCompleted) {
            PerpleLog.d(LOG_TAG, "In-app billing setup is already completed.");
            mSetupCallback.onSuccess("");
            return;
        }

        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                // Start setup. This is asynchronous and the specified listener
                // will be called once setup completes.
                PerpleLog.d(LOG_TAG, "Starting in-app billing setup.");
                mHelper.startSetup(new IabHelper.OnIabSetupFinishedListener() {
                    public void onIabSetupFinished(IabResult result) {
                        PerpleLog.d(LOG_TAG, "In-app billing setup finished - result:" + result);

                        if (result.isSuccess()) {
                            setPurchaseFinishedListener();
                            setQueryInventoryFinishedListener();
                            mIsSetupCompleted = true;
                            mSetupCallback.onSuccess("");
                        } else {
                            // Oh no, there was a problem.
                            mSetupCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_SETUP, String.valueOf(result.getResponse()), result.getMessage()));
                        }
                    }
                });
            }
        });
    }

    public void onDestroy() {
        mIsSetupCompleted = false;

        // very important:
        PerpleLog.d(LOG_TAG, "Destroying helper.");
        if (mHelper != null) {
            try {
                mHelper.dispose();
            } catch (Exception e) {
                // IllegalArgumentException
                e.printStackTrace();
            }
            mHelper = null;
        }
    }

    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        PerpleLog.d(LOG_TAG, "onActivityResult(" + requestCode + "," + resultCode + "," + data + ")");

        if (mHelper == null) return false;

        // Pass on the activity result to the helper for handling
        if (!mHelper.handleActivityResult(requestCode, resultCode, data)) {
            // not handled, so handle it ourselves (here's where you'd
            // perform any handling of activity results not related to in-app
            // billing...
            return false;
        }
        else {
            PerpleLog.d(LOG_TAG, "onActivityResult handled by IABUtil.");
            return true;
        }
    }

    public IInAppBillingService getBillingService() {
        return mHelper.getService();
    }

    public void purchase(final String sku, final String payload, final PerpleSDKCallback callback) {
        PerpleLog.d(LOG_TAG, "Purchasing requested - sku: " + sku + ", payload:" + payload);
        if (mHelper == null || !mIsSetupCompleted) {
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_NOTINITIALIZED, "In-app billing module is not initialized."));
            return;
        }

        mPurchaseCallback = callback;

        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                try {
                    mHelper.launchPurchaseFlow(PerpleSDK.getInstance().getMainActivity(), sku, PerpleSDK.RC_GOOGLE_PURCHASE_REQUEST,
                            mPurchaseFinishedListener, payload);
                } catch (Exception e) {
                    mPurchaseCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_PURCHASE, ""));
                }
            }
        });
    }

    public void subscription(final String sku, final String payload, final PerpleSDKCallback callback) {
        PerpleLog.d(LOG_TAG, "Subscription requested - sku: " + sku + ", payload:" + payload);
        if (mHelper == null || !mIsSetupCompleted) {
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_NOTINITIALIZED, "In-app billing module is not initialized."));
            return;
        }

        mPurchaseCallback = callback;

        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                try {
                    mHelper.launchSubscriptionPurchaseFlow(PerpleSDK.getInstance().getMainActivity(), sku, PerpleSDK.RC_GOOGLE_SUBSCRIPTION_REQUEST,
                            mPurchaseFinishedListener, payload);
                } catch (Exception e) {
                    mPurchaseCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_PURCHASE, ""));
                }
            }
        });
    }

    public void consume(final String orderId) {
        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                Purchase p = mPurchases.get(orderId);
                if (p != null) {
                    mHelper.consumeAsync(p, new OnConsumeFinishedListener() {
                        @Override
                        public void onConsumeFinished(Purchase purchase, IabResult result) {
                            mPurchases.remove(purchase.getOrderId());
                        }
                    });
                }
            }
        });
    }

    public void getItemList(final String skuList, PerpleSDKCallback callback ) {
        mItemListCallback = callback;

        if (!mIsSetupCompleted) {
            PerpleLog.d(LOG_TAG, "In-app billing setup is not completed.");
            mItemListCallback.onFail("");
            return;
        }

        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                PerpleLog.d(LOG_TAG, "Starting in-app getItemList.");

                setQueryGetItemListInventoryFinishedListener();

                // Have we been disposed of in the meantime? If so, quit.
                if (mHelper == null) return;

                // IAB is fully set up. Now, let's get an inventory of stuff we own.
                PerpleLog.d(LOG_TAG, "Querying inventory.");

                StringTokenizer tempList = new StringTokenizer(skuList, ";");
                mRequestItemAllList = new ArrayList<String>();
                mJArrayItemDetail = new JSONArray();
                while( tempList.hasMoreTokens())
                {
                    mRequestItemAllList.add( tempList.nextToken() );
                }

                PerpleLog.d(LOG_TAG, "skuList : " + skuList);
                PerpleLog.d(LOG_TAG, "retSkuList : " + mRequestItemAllList.toString());

                //20개 이상 보내면 에러가 나서 순차적으로 보내야한다.
                List<String> retSkuList = new ArrayList<String>();
                if( mRequestItemAllList.size() > 10 )
                {
                    int i;
                    for( i = 0; i < 10; ++i )
                    {
                        retSkuList.add( mRequestItemAllList.remove(0) );
                    }
                }
                else
                {
                    retSkuList.addAll(mRequestItemAllList);
                    mRequestItemAllList.clear();
                }

                mHelper.queryInventoryAsync(true, retSkuList,  mGetItemListInventoryListener);
            }
        });
    }

    public void getIncompletePurchaseList(final PerpleSDKCallback callback) {
        if (mHelper == null || !mIsSetupCompleted) {
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_NOTINITIALIZED, "In-app billing module is not initialized."));
            return;
        }

        mIncompletePurchaseCallback = callback;

        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                // IAB is fully set up. Now, let's get an inventory of stuff we own.
                PerpleLog.d(LOG_TAG, "Querying inventory.");
                mHelper.queryInventoryAsync(mGotInventoryListener);
            }
        });
    }

    /** Verifies the developer payload of a purchase.
     * @throws IOException, JSONException */
    private JSONObject verifyDeveloperPayload(Purchase p) throws IOException, JSONException {
        /*
         * TODO: verify that the developer payload of the purchase is correct. It will be
         * the same one that you sent when initiating the purchase.
         *
         * WARNING: Locally generating a random string when starting a purchase and
         * verifying it here might seem like a good approach, but this will fail in the
         * case where the user purchases an item on one device and then uses your app on
         * a different device, because on the other device you will not have access to the
         * random string you originally generated.
         *
         * So a good developer payload has these characteristics:
         *
         * 1. If two different users purchase an item, the payload is different between them,
         *    so that one user's purchase can't be replayed to another user.
         *
         * 2. The payload must be such that you can verify it even when the app wasn't the
         *    one who initiated the purchase flow (so that items purchased by the user on
         *    one device work on other devices owned by the user).
         *
         * Using your own server to store and verify developer payloads across app
         * installations is recommended.
         */

        JSONObject data = new JSONObject();
        data.put("platform", "google");
        data.put("receipt", p.getOriginalJson());
        data.put("signature", p.getSignature());

        String responseString = PerpleSDK.httpRequest(mUri, data.toString());

        if (PerpleSDK.IsDebug)
        {
            PerpleLog.d(LOG_TAG, "request : " + data.toString());
            PerpleLog.d(LOG_TAG, "response : " + responseString);
        }

        // Parse the JSON string and return it.
        return new JSONObject(responseString);
    }

    private class CheckReceiptTask extends AsyncTask<Purchase, Void, Integer> {
        private Purchase mPurchase;
        private String mMsg;
        private final PerpleSDKCallback mCallback;

        public CheckReceiptTask(PerpleSDKCallback callback) {
            mCallback = callback;
        }

        @Override
        protected Integer doInBackground(Purchase... params) {
            int ret;
            try {
                mPurchase = params[0];
                JSONObject response = verifyDeveloperPayload(mPurchase);
                // ret
                // 0 : success
                // -100 : invalid receipt
                ret = new JSONObject(response.getString("status")).getInt("retcode");
                mMsg = response.getString("status");
            } catch (IOException e) {
                e.printStackTrace();
                ret = Integer.parseInt(PerpleSDK.ERROR_IOEXCEPTION);
                mMsg = e.toString();
            } catch (JSONException e) {
                ret = Integer.parseInt(PerpleSDK.ERROR_JSONEXCEPTION);
                e.printStackTrace();
                mMsg = e.toString();
            }
            return ret;
        }

        @Override
        protected void onPostExecute(Integer ret) {
            PerpleLog.d(LOG_TAG, "Check receipt finished - code:" + String.valueOf(ret) +
                    ", message:" + mMsg +
                    ", purchase:" + mPurchase);

            if (mCallback != null) {
                if (ret == 0) {
                    mCallback.onSuccess(mMsg);
                } else {
                    mCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_CHECKRECEIPT, String.valueOf(ret), mMsg));
                }
            } else {
                PerpleLog.e(LOG_TAG, "CheckReceiptTask error, callback isn't set.");
            }
        }
    }

    private void checkReceipt(Purchase p, PerpleSDKCallback callback) {
        new CheckReceiptTask(callback).execute(p);
    }

    private void setQueryInventoryFinishedListener() {
        // Listener that's called when we finish querying the items and subscriptions we own
        mGotInventoryListener = new IabHelper.QueryInventoryFinishedListener() {
            public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
                PerpleLog.d(LOG_TAG, "Query inventory finished - result:" + result);

                // Have we been disposed of in the meantime? If so, quit.
                if (mHelper == null) return;

                // Is it a failure?
                if (result.isFailure()) {
                    mIncompletePurchaseCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_QUARYINVECTORY, String.valueOf(result.getResponse()), result.getMessage()));
                    return;
                }

                List<Purchase> purchases = inventory.getAllPurchases();

                mIncompletePurchases.clear();
                mIncompletePurchasesCount = purchases.size();

                PerpleLog.d(LOG_TAG, "inventory item count : " + mIncompletePurchasesCount);

                if (mIncompletePurchasesCount > 0) {
                    for (final Purchase p : purchases) {
                        PerpleLog.d(LOG_TAG, "inventory item  : " + p.toString());

                        checkReceipt(p, new PerpleSDKCallback() {
                            @Override
                            public void onSuccess(String info) {
                                processCheckReceiptResultIncompletePurchases(p, info, true);
                            }
                            @Override
                            public void onFail(String info) {
                                processCheckReceiptResultIncompletePurchases(p, info, false);
                            }
                        });
                    }
                } else {
                    mIncompletePurchaseCallback.onSuccess("");
                }
            }
        };
    }

    private void setPurchaseFinishedListener() {
        mPurchaseFinishedListener = new IabHelper.OnIabPurchaseFinishedListener() {
            public void onIabPurchaseFinished(IabResult result, final Purchase purchase) {
                PerpleLog.d(LOG_TAG, "Purchasing finished - result:" + result + ", purchase: " + purchase);

                // if we were disposed of in the meantime, quit.
                if (mHelper == null) return;

                if (result.isFailure()) {
                    if (result.getResponse() == IABHELPER_USER_CANCELLED) {
                        mPurchaseCallback.onFail("cancel");
                    } else {
                        mPurchaseCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_PURCHASEFINISH, String.valueOf(result.getResponse()), result.getMessage()));
                    }
                    return;
                }

                checkReceipt(purchase, new PerpleSDKCallback() {
                    @Override
                    public void onSuccess(String info) {
                        processCheckReceiptResult(purchase, info, true);
                    }
                    @Override
                    public void onFail(String info) {
                        processCheckReceiptResult(purchase, info, false);
                    }
                });
            }
        };
    }

    private void setQueryGetItemListInventoryFinishedListener() {
        // Listener that's called when we finish querying the items and subscriptions we own
        mGetItemListInventoryListener = new IabHelper.QueryInventoryFinishedListener() {
            public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
                PerpleLog.d(LOG_TAG, "Query inventory finished - result:" + result);

                // Have we been disposed of in the meantime? If so, quit.
                if (mHelper == null) return;

                // Is it a failure?
                if (result.isFailure()) {
                    mItemListCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_QUARYINVECTORY, String.valueOf(result.getResponse()), result.getMessage()));
                    return;
                }

                List<SkuDetails> sku = inventory.getAllSkuDetails();

                PerpleLog.d(LOG_TAG, "inventory SkuDetails count : " + sku.size());

                for (final SkuDetails item : sku) {
                    PerpleLog.d(LOG_TAG, "SkuDetails item  : " + item.getJson());

                    String itemInfo = item.getJson();
                    try {
                        JSONObject jitem = new JSONObject(itemInfo);
                        mJArrayItemDetail.put(jitem);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }

                //다 비운건지 체크
                if (mRequestItemAllList.size() <= 0) {
                    mItemListCallback.onSuccess(mJArrayItemDetail.toString());
                } else {
                    //20개 이상 보내면 에러가 나서 순차적으로 보내야한다.
                    List<String> retSkuList = new ArrayList<String>();
                    if (mRequestItemAllList.size() > 10) {
                        int i;
                        for (i = 0; i < 10; ++i) {
                            retSkuList.add(mRequestItemAllList.remove(0));
                        }
                    } else {
                        retSkuList.addAll(mRequestItemAllList);
                        mRequestItemAllList.clear();
                    }

                    mHelper.queryInventoryAsync(true, retSkuList, mGetItemListInventoryListener);
                }
            }
        };
    }

    private void processCheckReceiptResult(Purchase p, String info, boolean isCheckReceiptSuccess) {
        if (isCheckReceiptSuccess) {
            if (getRetcode(info) == 0) {
                mPurchases.put(p.getOrderId(), p);
                mPurchaseCallback.onSuccess(getPurchaseResult(p).toString());
            } else {
                mPurchaseCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_CHECKRECEIPT, String.valueOf(getRetcode(info)), getRetMsg(info)));
                mHelper.consumeAsync(p, new OnConsumeFinishedListener() {
                    @Override
                    public void onConsumeFinished(Purchase purchase, IabResult result) {
                        // Do noting
                    }
                });
            }
        } else {
            mPurchaseCallback.onFail(info);
        }
    }

    private void processCheckReceiptResultIncompletePurchases(Purchase p, String info, boolean isCheckReceiptSuccess) {
        // 영수증 검증된 미지급 결제 상품 처리
        if (isCheckReceiptSuccess) {
            // getRetcode(info) == 0
            mPurchases.put(p.getOrderId(), p);
            mIncompletePurchases.put(p, true);
        } else {
            mIncompletePurchases.put(p, false);
        }

        // 미완료 purchase가 전부 검증되었는지 체크
        mIncompletePurchasesCount--;
        if (mIncompletePurchasesCount > 0) {
            return;
        }

        // 상품 리스트 json 전달
        List<Purchase> validList = getPurchasesList(mIncompletePurchases, true);
        for (int i = 0; i < validList.size(); i++) {
            mIncompletePurchaseCallback.onSuccess(getPurchaseResult(validList.get(i)).toString());
        }

        // 검증 실패한 purchase consume
        List<Purchase> invalidList = getPurchasesList(mIncompletePurchases, false);
        if (invalidList.size() > 0) {
            mHelper.consumeAsync(invalidList, new OnConsumeMultiFinishedListener() {
                @Override
                public void onConsumeMultiFinished(List<Purchase> purchases, List<IabResult> results) {
                    // Do nothing
                }
            });
        }
    }

    private int getRetcode(String info) {
        try {
            JSONObject obj = new JSONObject(info);
            int retcode = Integer.parseInt(obj.getString("retcode"));
            return retcode;
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return -1;
    }

    private String getRetMsg(String info) {
        try {
            JSONObject obj = new JSONObject(info);
            String retMsg = obj.getString("message");
            return retMsg;
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return "";
    }

    private List<Purchase> getPurchasesList(Map<Purchase, Boolean> purchasesMap, boolean valid) {
        List<Purchase> list = new ArrayList<Purchase>();
        for (Map.Entry<Purchase, Boolean> entry : purchasesMap.entrySet()) {
            if (entry.getValue() == valid) {
                list.add(entry.getKey());
            }
        }
        return list;
    }

    /*
    private String getPurchaseResultArray(List<Purchase> purchases) {
        JSONArray array = new JSONArray();
        for (int i = 0; i < purchases.size(); i++) {
            array.put(getPurchaseResult(purchases.get(i)));
        }

        if (array.length() > 0) {
            return array.toString();
        }
        return "";
    }
    */

    private JSONObject getPurchaseResult(Purchase p) {
        JSONObject obj = new JSONObject();
        try {
            obj.put("orderId", p.getOrderId());
            obj.put("payload", p.getDeveloperPayload());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return obj;
    }


    public String getPurchaseCheckReceiptUri() { return mUri; }
}
