package com.perplelab;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.opengl.GLSurfaceView;
import androidx.core.app.ActivityCompat;

import android.os.Build;
import android.widget.Toast;
import android.os.AsyncTask;

import com.google.android.gms.ads.identifier.AdvertisingIdClient;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;

import com.perplelab.admob.SdkBinderAdMob;
import com.perplelab.billing.PerpleBilling;
import com.perplelab.facebook.PerpleFacebook;
import com.perplelab.firebase.PerpleCrashlytics;
import com.perplelab.firebase.PerpleFirebase;
import com.perplelab.google.PerpleGoogle;
import com.perplelab.google.HbrwCMP;
import com.perplelab.onestore.PerpleOnestore;

//import com.perplelab.tapjoy.PerpleTapjoy;
import com.perplelab.twitter.PerpleTwitter;
import com.perplelab.adjust.PerpleAdjust;
import com.perplelab.xsolla.PerpleXsolla;


import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;
import java.util.Locale;
import java.util.Scanner;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.jetbrains.annotations.NotNull;
import org.json.JSONException;
import org.json.JSONObject;

public class PerpleSDK {
    private static final String LOG_TAG = "PerpleSDK";

    public static final String ERROR_UNKNOWN                            = "-999";
    public static final String ERROR_IOEXCEPTION                        = "-998";
    public static final String ERROR_JSONEXCEPTION                      = "-997";
    public static final String ERROR_USERRECOVERABLEAUTHEXCEPTION       = "-996";
    public static final String ERROR_GOOGLEAUTHEXCEPTION                = "-995";

    public static final String ERROR_FIREBASE_NOTINITIALIZED            = "-1000";
    public static final String ERROR_FIREBASE_SENDPUSHMESSAGE           = "-1001";
    public static final String ERROR_FIREBASE_LOGIN                     = "-1002";
    public static final String ERROR_FIREBASE_FCMTOKENNOTREADY          = "-1003";
    public static final String ERROR_FIREBASE_GOOGLENOTLINKED           = "-1004";
    public static final String ERROR_FIREBASE_FACEBOOKNOTLINKED         = "-1005";

    public static final String ERROR_GOOGLE_NOTINITIALIZED              = "-1200";
    public static final String ERROR_GOOGLE_LOGIN                       = "-1201";
    public static final String ERROR_GOOGLE_NOTSIGNEDIN                 = "-1202";
    public static final String ERROR_GOOGLE_ACHIEVEMENTS                = "-1203";
    public static final String ERROR_GOOGLE_LEADERBOARDS                = "-1204";
    public static final String ERROR_GOOGLE_LOGOUT                      = "-1205";
    public static final String ERROR_GOOGLE_SILENTLOGIN                 = "-1206";
    public static final String ERROR_GOOGLE_PLAYSERVICESLOGIN           = "-1207";

    public static final String ERROR_FACEBOOK_NOTINITIALIZED            = "-1300";
    public static final String ERROR_FACEBOOK_FACEBOOKEXCEPTION         = "-1301";
    public static final String ERROR_FACEBOOK_AUTHORIZATIONEXCEPTION    = "-1302";
    public static final String ERROR_FACEBOOK_DIALOGEXCEPTION           = "-1303";
    public static final String ERROR_FACEBOOK_GRAPHRESPONSEEXCEPTION    = "-1304";
    public static final String ERROR_FACEBOOK_OPERATIONCANCELEDEXCEPTION= "-1305";
    public static final String ERROR_FACEBOOK_SDKNOTINITIALIZEDEXCEPTION= "-1306";
    public static final String ERROR_FACEBOOK_SERVICEEXCEPTION          = "-1307";
    public static final String ERROR_FACEBOOK_GRAPHAPI                  = "-1308";
    public static final String ERROR_FACEBOOK_REQUEST                   = "-1309";
    public static final String ERROR_FACEBOOK_SHARE                     = "-1310";

    public static final String ERROR_BILLING_NOTINITIALIZED             = "-1500";
    public static final String ERROR_BILLING_SETUP                      = "-1501";
    public static final String ERROR_BILLING_QUARYINVECTORY             = "-1502";
    public static final String ERROR_BILLING_CHECKRECEIPT               = "-1503";
    public static final String ERROR_BILLING_PURCHASEFINISH             = "-1504";
    public static final String ERROR_BILLING_PURCHASE                   = "-1505";
    public static final String ERROR_BILLING_QUARY_PRODUCT_DETAIL       = "-1506";
    public static final String ERROR_BILLING_INVALIDPRODUCT             = "-1507";

    public static final String ERROR_TAPJOY_NOTINITIALIZED              = "-1600";
    public static final String ERROR_TAPJOY_NOTSETPLACEMENT             = "-1601";
    public static final String ERROR_TAPJOY_GETCURRENCY                 = "-1602";
    public static final String ERROR_TAPJOY_SPENDCURRENCY               = "-1603";
    public static final String ERROR_TAPJOY_AWARDCURRENCY               = "-1604";
    public static final String ERROR_TAPJOY_ONEARNEDCURRENCY            = "-1605";
    public static final String ERROR_TAPJOY_SETPLACEMENT                = "-1606";
    public static final String ERROR_TAPJOY_SHOWPLACEMENT               = "-1607";

    // -1700

    public static final String ERROR_UNITYADS_NOTINITIALIZED            = "-1800";

    public static final String ERROR_ADJUST_NOTINITIALIZED              = "-1900";

    public static final String ERROR_TWITTER_NOTINITIALIZED             = "-2000";
    public static final String ERROR_TWITTER_LOGIN                      = "-2001";
    public static final String ERROR_TWITTER_TWEET                      = "-2002";

    public static final String ERROR_ADMOB_NOTINITIALIZED               = "-2100";
    public static final String ERROR_ADMOB_START                        = "-2101";
    public static final String ERROR_ADMOB_INVALIDADUNITID              = "-2102";
    public static final String ERROR_ADMOB_NOTLOADEDAD                  = "-2103";
    public static final String ERROR_ADMOB_FAILLOAD                     = "-2104";

    public static final String ERROR_XSOLLA_NOTINITIALIZED              = "-2200";

    public static final String ERROR_ONESTORE_NOTINITIALIZED              = "-2300";

    public static final int RC_GOOGLE_SIGN_IN                   = 9001;
    public static final int RC_GOOGLE_ACHIEVEMENTS              = 9002;
    public static final int RC_GOOGLE_LEADERBOARDS              = 9003;
    public static final int RC_GOOGLE_PURCHASE_REQUEST          = 9004;
    public static final int RC_GOOGLE_SUBSCRIPTION_REQUEST      = 9005;
    public static final int RC_GOOGLE_PLAYSERVICES_SIGN_IN      = 9006;
    public static final int RC_ONE_STORE_PURCHASE               = 9101;
    public static final int RC_ONE_STORE_LOGIN                  = 9102;

    public static final int RC_GOOGLE_PERMISSIONS               = 99;

    public static final int RC_FIREBASE_MESSAGING               = 999;



    private Activity MainActivity;

    public static boolean IsDebug;
    public static boolean IsReceivePushOnForeground;
    public static int ProcessId;
    public static String PlatformServerEncryptSecretKey;
    public static String PlatformServerEncryptAlgorithm;

    private PerpleFirebase mFirebase;
    private PerpleBilling mBilling;
    private PerpleGoogle mGoogle;
    private PerpleFacebook mFacebook;
    private PerpleTwitter mTwitter;
    //private PerpleTapjoy mTapjoy;
    private PerpleAdjust mAdjust;
    private SdkBinderAdMob mAdMob;
    private PerpleXsolla mXsolla;
    private PerpleOnestore mOnestore;

    // advertising id
    private static String mAdid = "";
    public static void setAdid(String adid) { mAdid = adid; }
    public static String getAdid() { return mAdid; }
    
    //--------------------------------------------------------------------------------
    // PerpleSDK is a singleton class
    //--------------------------------------------------------------------------------

    private static PerpleSDK sMyInstance;

    public static void createInstance(Activity activity) {
        sMyInstance = new PerpleSDK(activity);
    };

    public static PerpleSDK getInstance() {
        if (sMyInstance == null) {
            PerpleLog.e(LOG_TAG, "PerpleSDK.createInstance() must be called first.");
        }
        return sMyInstance;
    }

    private PerpleSDK(Activity activity) {
        MainActivity = activity;
        nativeInitJNI(activity);
    }

    //--------------------------------------------------------------------------------
    // PerpleSDK initializing functions
    //--------------------------------------------------------------------------------

    public boolean initSDK(String base64EncodedPublicKey, boolean isDebug) {
        IsDebug = isDebug;
        PerpleLog.d(LOG_TAG, "PerpleSDK, Enabled debug mode");

        // @firebase
        initFirebase();

        // @billing
        initBilling(base64EncodedPublicKey, isDebug);
        
        // @advertising_id
        initAdid();

        int ret = nativeInitSDK();
        if (ret < 0) {
            PerpleLog.e(LOG_TAG, "PerpleSDK initialization failed.(code:" + String.valueOf(ret) + ")");

            mFirebase = null;
            mBilling = null;

            return false;
        }

        String version = nativeGetSDKVersionString();
        String logText = "PerpleSDK initialization was successful.(Ver:" + version + ")";
        PerpleLog.d(LOG_TAG, logText);

        if (isDebug) {
            Toast.makeText(getMainActivity(), logText, Toast.LENGTH_LONG).show();
        }

        return true;
    }
    
    // @advertising_id
    public void initAdid() {
		PerpleLog.d(LOG_TAG, "PerpleSDK initAdid");
        AsyncTask.execute(new Runnable() {
            @Override
            public void run() {
                try {
					PerpleLog.d(LOG_TAG, "PerpleSDK initAdid try");
                    AdvertisingIdClient.Info advertisingIdInfo = AdvertisingIdClient.getAdvertisingIdInfo(MainActivity.getApplicationContext());
                    if (!advertisingIdInfo.isLimitAdTrackingEnabled()) {
                        PerpleSDK.setAdid(advertisingIdInfo.getId());
						PerpleLog.d(LOG_TAG, "PerpleSDK initAdid success");
					}
                } catch (IOException | GooglePlayServicesNotAvailableException | GooglePlayServicesRepairableException e) {
					PerpleLog.d(LOG_TAG, "PerpleSDK initAdid catch");
                    e.printStackTrace();
                }
            }
        });
    }

    // @firebase
    public void initFirebase() {
        if (mFirebase == null) {
            mFirebase = new PerpleFirebase();
            mFirebase.init();
        }
    }

    // @billing
    public void initBilling(String base64EncodedPublicKey, boolean isDebug) {
        if (mBilling == null) {
            mBilling = new PerpleBilling();
            mBilling.init();
        }
    }

    // @google
    public boolean initGoogle(String webClientId) {
        mGoogle = new PerpleGoogle();
        if (mGoogle.init(webClientId)) {
            return true;
        } else {
            mGoogle = null;
        }

        return false;
    }

    // @facebook
    public void initFacebook() {
        mFacebook = new PerpleFacebook();
        mFacebook.init();
    }

    // @twitter
    public void initTwitter(String consumerKey, String consumerSecret) {
        mTwitter = new PerpleTwitter();
        mTwitter.init(consumerKey, consumerSecret);
    }

    // @tapjoy
    public void initTapjoy(String appKey, String senderId, boolean isDebug) {
        //mTapjoy = new PerpleTapjoy();
        //mTapjoy.init(appKey, senderId, isDebug);
    }

    // @Adjust
    public void initAdjust(String appToken, long[] secretKeyArray, boolean isDebug ) {
        mAdjust = new PerpleAdjust();
        mAdjust.init(appToken, secretKeyArray, isDebug);
    }

    // @AdMob
    public void initAdMob() {
        mAdMob = new SdkBinderAdMob();
    }

    // @xsolla
    public void initXsolla(int merchantId, String apiKey, int projectId, String secretKey, boolean isSandbox) {
        mXsolla = new PerpleXsolla(merchantId, apiKey, projectId, secretKey, isSandbox);
    }

    // @crashlytics
    public void initCrashlytics() {
        PerpleCrashlytics.Companion.init(getMainActivity());
    }


    // @Onestore
    public void initOnestore(String publicKey) {
        mOnestore = new PerpleOnestore(publicKey);
        mOnestore.initOnestore();
    }

    public void onStart() {
        // @firebase
        if (mFirebase != null) {
            mFirebase.onStart();
        }
    }

    public void onStop() {
        // @firebase
        if (mFirebase != null) {
            mFirebase.onStop();
        }
    }

    public void onResume() {
        // @facebook
        if (mFacebook != null) {
            mFacebook.onResume();
        }

        // @Adjust
        if(mAdjust != null) {
            mAdjust.onResume();
        }

        // @adMob
        if (mAdMob != null) {
            mAdMob.onResume();
        }
    }

    public void onPause() {
        // @facebook
        if (mFacebook != null) {
            mFacebook.onPause();
        }

        // @Adjust
        if(mAdjust != null) {
            mAdjust.onPause();
        }

        // @adMob
        if (mAdMob != null) {
            mAdMob.onPause();
        }
    }

    public void onDestroy() {
        // @billing
        if (mBilling != null) {
            mBilling.onDestroy();
        }

        // @adMob
        if (mAdMob != null) {
            mAdMob.onDestroy();
        }

        // @onestore
        if (mOnestore != null) {
            mOnestore.onDestroy();
        }
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        PerpleLog.v(LOG_TAG, "onActivityResult - request:" + String.valueOf(requestCode) + ", result:" + String.valueOf(resultCode));


        // @billing
        if (mBilling != null) {
            mBilling.onActivityResult(requestCode, resultCode, data);
        }

        // @google
        if (mGoogle != null) {
            mGoogle.onActivityResult(requestCode, resultCode, data);
        }

        // @facebook
        if (mFacebook != null) {
            mFacebook.onActivityResult(requestCode, resultCode, data);
        }

        // @twitter
        if (mTwitter != null) {
            mTwitter.onActivityResult(requestCode, resultCode, data);
        }

        // @onestore
        if (mOnestore != null){
            mOnestore.onActivityResult(requestCode, resultCode, data);
        }
    }

    public void setReceivePushOnForeground(boolean isReceive) {
        IsReceivePushOnForeground = isReceive;
    }

    //--------------------------------------------------------------------------------
    // External public static functions
    //--------------------------------------------------------------------------------

    // @firebase
    public static PerpleFirebase getFirebase() {
        return getInstance().mFirebase;
    }

    // @billing
    public static PerpleBilling getBilling() {
        return getInstance().mBilling;
    }

    /*
    // @billing
    public static IInAppBillingService getBillingService() {
        PerpleBilling billing = getInstance().mBilling;
        if (billing != null) {
            return billing.getBillingService();
        } else {
            return null;
        }
    }*/

    // @google
    public static PerpleGoogle getGoogle() {
        return getInstance().mGoogle;
    }

    // @facebook
    public static PerpleFacebook getFacebook() {
        return getInstance().mFacebook;
    }

    // @twitter
    public static PerpleTwitter getTwitter() {
        return getInstance().mTwitter;
    }

    // @Adjust
    public static PerpleAdjust getAdjust() {
        return  getInstance().mAdjust;
    }

    // @AdMob
    public static SdkBinderAdMob getAdMob() {
        return getInstance().mAdMob;
    }

    // @Xsolla
    public static PerpleXsolla getXsolla() {
        return getInstance().mXsolla;
    }

    // @Onestore
    public static PerpleOnestore getOnestore() { return getInstance().mOnestore; }

    //--------------------------------------------------------------------------------
    // Internal utility functions
    //--------------------------------------------------------------------------------

    // @firebase fcm
    private static PerpleSDKCallback sTokenRefreshCallback;
    public static void setFCMTokenRefreshCallback(PerpleSDKCallback callback) {
        if (getInstance().mFirebase == null) {
            callback.onFail(PerpleSDK.getErrorInfo(ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        sTokenRefreshCallback = callback;

        getInstance().mFirebase.getPushToken(callback);
    }

    // @firebase fcm, callback from PerpleFirebaseMessagingService
    public static void onFCMTokenRefresh(String pushToken) {
        if (sTokenRefreshCallback != null) {
            sTokenRefreshCallback.onSuccess(pushToken);
        }
    }

    // @firebase fcm
    private static PerpleSDKCallback sSendPushMessageCallback;
    public static void setSendPushMessageCallback(PerpleSDKCallback callback) {
        if (getInstance().mFirebase == null) {
            callback.onFail(PerpleSDK.getErrorInfo(ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        sSendPushMessageCallback = callback;
    }

    // @firebase fcm, callback from PerpleFirebaseMessagingService
    public static void onMessageSent(String msgId) {
        if (sSendPushMessageCallback != null) {
            sSendPushMessageCallback.onSuccess(msgId);
        }
    }

    // @firebase fcm, callback from PerpleFirebaseMessagingService
    public static void onSendError(String msgId, Exception exception) {
        if (sSendPushMessageCallback != null) {
            sSendPushMessageCallback.onFail(getErrorInfo(ERROR_FIREBASE_SENDPUSHMESSAGE, msgId, exception.toString()));
        }
    }

    public static String getHmacEncrypt(String privateKey, String algorithm, String input) throws Exception {
        byte[] keyBytes = privateKey.getBytes();
        //byte[] keyBytes = hexToByteArray(privateKey);
        SecretKeySpec keySpec = new SecretKeySpec(keyBytes, algorithm);
        Mac mac = Mac.getInstance(algorithm);
        mac.init(keySpec);

        return byteArrayToHex(mac.doFinal(input.getBytes("UTF-8")));
    }

    public static String byteArrayToHex(byte[] a) {
        final String hexDigitChars = "0123456789abcdef";
        StringBuffer buf = new StringBuffer(a.length * 2);
        int hn, ln;
        for (byte anA : a) {
            hn = ((int) (anA) & 0x00ff) / 16;
            ln = ((int) (anA) & 0x000f);
            buf.append(hexDigitChars.charAt(hn));
            buf.append(hexDigitChars.charAt(ln));
        }
        return buf.toString();
    }

    public static byte[] hexToByteArray(String s) {
        int len = s.length();
        byte[] data = new byte[len/2];
        for (int i=0; i<len; i+=2) {
            data[i/2] = (byte)((Character.digit(s.charAt(i), 16) << 4) + Character.digit(s.charAt(i+1), 16));
        }
        return data;
    }

    public static String httpRequest(String strUrl, String data) throws IOException {
        URL url = new URL(strUrl);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setDoOutput(true);
        con.setDoInput(true);
        con.setConnectTimeout(10000);
        con.setReadTimeout(15000);

        // HTTP request header
        con.setRequestProperty("Cache-Control", "no-cache");    //optional
        con.setRequestProperty("Content-Type", "application/json");

        // Encrypt
        if (PlatformServerEncryptSecretKey != null && !PlatformServerEncryptSecretKey.isEmpty()) {
            try {
                String encryptData = getHmacEncrypt(PlatformServerEncryptSecretKey, PlatformServerEncryptAlgorithm, data);
                con.setRequestProperty("HMAC", encryptData);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        con.setRequestMethod("POST");
        con.connect();

        // HTTP request body
        OutputStream os = con.getOutputStream();
        os.write(data.getBytes("UTF-8"));
        os.close();

        // Read the response into a string
        InputStream is = con.getInputStream();
        @SuppressWarnings("resource")
        String responseString = new Scanner(is, "UTF-8").useDelimiter("\\A").next();
        is.close();

        con.disconnect();

        return responseString;
    }

    public static String getItemFromInfo(String info, String item) {
        try {
            JSONObject obj = new JSONObject(info);
            return obj.getString(item);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return "";
    }

    public static String getErrorInfo(String code, String msg) {
        return getErrorInfo(code, "0", msg);
    }

    public static String getErrorInfo(String code, String subcode, String msg) {
        try {
            JSONObject obj = new JSONObject();
            obj.put("code", code);
            obj.put("subcode", subcode);
            obj.put("msg", msg);
            return obj.toString();
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return "";
    }

    private static GLSurfaceView sGLSurfaceView;
    public static void setGLSurfaceView(GLSurfaceView view) {
        sGLSurfaceView = view;
    }
    public Activity getMainActivity() {
        return MainActivity;
    }

    public static void callSDKResult(final int pId, final int id, final String result, final String info) {
        if (pId != ProcessId) {
            PerpleLog.e(LOG_TAG, "callSDKResult, process id mismatch! - calling id:" + String.valueOf(pId) + ", current id:" + String.valueOf(ProcessId) + ", funcID:" + String.valueOf(id) + ", ret:" + result + ", info:" + info);
            return;
        }

        PerpleLog.d(LOG_TAG, "callSDKResult - " + "funcID:" + String.valueOf(id) + ", ret:" + result + ",info:" + info);

        if (sGLSurfaceView != null) {
            sGLSurfaceView.queueEvent(new Runnable() {
                @Override
                public void run() {
                    nativeSDKResult(id, result, info);
                }
            });
        } else {
            nativeSDKResult(id, result, info);
        }
    }

    public static String getDeviceLocale() {
        String loc = Locale.getDefault().toString();
        String ret = loc.toLowerCase(Locale.ENGLISH).replace("_", "-");
        PerpleLog.d(LOG_TAG, "local : " + ret);
        return ret;
    }

    public static void appRestart() {
        Activity mainActivity = getInstance().getMainActivity();

        int flag;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flag = PendingIntent.FLAG_IMMUTABLE;
        } else {
            flag = PendingIntent.FLAG_CANCEL_CURRENT;
        }

        Intent intent = new Intent(mainActivity, mainActivity.getClass());
        PendingIntent pendingIntent = PendingIntent.getActivity(mainActivity, 123456, intent, flag);

        AlarmManager mgr = (AlarmManager)mainActivity.getSystemService(Context.ALARM_SERVICE);
        mgr.set(AlarmManager.RTC,  System.currentTimeMillis() + 500, pendingIntent);

        ActivityCompat.finishAffinity(mainActivity);
        System.runFinalization();
        System.exit(0);

    }

    public static void appTerminate() {
        android.os.Process.killProcess(android.os.Process.myPid());

    }

    public static boolean isAppOnForeground() {
        Activity mainActivity = getInstance().getMainActivity();

        if( mainActivity == null )
            return false;
        if( mainActivity.getApplicationContext() == null )
            return false;

        ActivityManager activityManager = (ActivityManager)(mainActivity.getApplicationContext().getSystemService(Context.ACTIVITY_SERVICE));
        List<ActivityManager.RunningAppProcessInfo> appProcesses = activityManager.getRunningAppProcesses();
        if( appProcesses == null)
            return false;

        final String packagename = mainActivity.getPackageName();
        PerpleLog.d(LOG_TAG, "packageName : " + packagename );

        for( ActivityManager.RunningAppProcessInfo appProcess : appProcesses) {
            if( appProcess.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND && appProcess.processName.equals(packagename)) {
                return true;
            }
        }

        return false;
    }

    private static native int nativeInitJNI(Activity activity);
    private static native int nativeInitSDK();
    private static native int nativeGetSDKVersion();
    private static native String nativeGetSDKVersionString();
    private static native int nativeSDKResult(int id, String result, String info);
}
