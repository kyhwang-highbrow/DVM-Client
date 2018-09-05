/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2016 cocos2d-x.org
Copyright (c) 2013-2016 Chukong Technologies Inc.

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import com.google.android.vending.expansion.downloader.Helpers;
import com.google.android.vending.expansion.downloader.IDownloaderClient;
import com.perplelab.dragonvillagem.kr.BuildConfig;
import com.perplelab.dragonvillagem.kr.R;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHelper;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.AlarmManager;
import android.app.AlertDialog;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.Manifest;
import android.content.pm.PackageManager;

//@perplesdk
import com.perplelab.PerpleSDK;

import java.util.Locale;

public class AppActivity extends Cocos2dxActivity{

    // @perplesdk
    static {
        System.loadLibrary("perplesdk");
    }

    // @obb
    private static APKExpansionDownloader sOBBDownloader;

    public static AppActivity sActivity;
    private Handler mAppHandler;

    // @obb
    private static int mVersionCode;
    private static long mFileSize;
    private static String mMd5;
    private static long mCrc32;

    // @local push
    static boolean sIsRun;

    // @billing
    static final String BASE64_PUBLIC_KEY = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2AOyhy0owSekR+QEpAUb2fV/wBtRmuD8UNEsku6iGM+Qx5o7iBMlGlcb7kjCJ86hMAu6g+1cdGFTQGCGTKrDZS6AfTv8NDB5EFwxvLa8Rn9aUU0nkaLFGNQvEo+gplP1PZQZLd30RMmJy/uYkzA2+vCdGaOQRTckwbczDBQyKWtQ5k5aj/1HQ/X8XxZneaKAM2JyFgFcjSYtlep9/XOQ6K2aR0VLoMse2rGkaFJQAFOBgNlNbvC3cbvaZe1hnZ4ypjadsPzw83ZpQYaMRTUF1k/TpB6CuSIX4L2ykUkEDyWn0RECpO3jR1fJ1Lb2ddYTpb8gORou9mhIK9Nfr8Cn4wIDAQAB";

    // @tapjoy
    static final String TAPJOY_SDK_KEY = "MZ5hVosGT1eLIW00UXCPvgEC7RNJdi2ZS0Kjtpd7IgoRLXg6N96edKY8h5cA";

    // @twitter
    static final String TWITTER_CONSUMER_KEY = "VCJ9gb6EjeIQO74rAbUl9B6aj";
    static final String TWITTER_CONSUMER_SECRET = "D0kt613Jye142Efej1DxtvJguItaK5PtgvYyJfY34Pvqs1HCBH";

    // @naver-cafe
    static final String NAVER_CAFE_CLIENT_ID = "nQGxfwLZ1Rf4Lwhozq4G";
    static final String NAVER_CAFE_CLIENT_SECRET = "1yzbWtj_Cu";
    static final int NAVER_CAFE_ID = 29168475;
    static final String NAVER_NEO_ID_CONSUMER_KEY = "_hBggTZAp2IPapvAxwQl";
    static final int NAVER_COMMUNITY_ID = 0;

    // @adjust
    static final String ADJUST_TOKKEN_ID = "esjmkti8vim8";
    static final long[] ADJUST_SECRET_KEY = {1, 562501988, 1877997235, 662395286, 1781468312};

    // @admob
    static final String ADMOB_APP_ID = "ca-app-pub-9497777061019569~9623723983";

    // @xsolla
    static final int XSOLLA_MERCHANT_ID = 60608;
    static final String XSOLLA_API_KEY = "tP3xsMG3ZXasBD52";
    static final int XSOLLA_PROJECT_ID = 35042;
    static final String XSOLLA_SECRET_KEY = "dR0p3BnJAunszS5g";

    // others
    static final int RC_WRITE_STORAGE_PERMISSION    = 100;  // must be 8bit value
    static final int RC_APP_PERMISSION              = 101;  // must be 8bit value

    static final int RC_APP_RESTART                 = 1000;
    static final int RC_LOCAL_PUSH                  = 1001;
    static final int RC_OBB_DOWNLOAD_STATE          = 1002;

    static String hostIPAdress = "0.0.0.0";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // @obb
        sActivity = this;
        mAppHandler = new Handler();

        sIsRun = true;

        //ip
        hostIPAdress = getHostIpAddress();

        // @perplesdk
        PerpleSDK.createInstance(this);

        // @perplesdk, Lua 콜백??GL Thread ?�서 ?�행?�고????경우 ?�정?�다.
        PerpleSDK.setGLSurfaceView(getGLSurfaceView());

        // ?�버�?메시지 출력
        boolean isDebug = BuildConfig.DEBUG;

        // @perplesdk // getString(R.string.gcm_defaultSenderId) GCM is deprecated, use FCM
        if (PerpleSDK.getInstance().initSDK(BASE64_PUBLIC_KEY, isDebug)) {

            // firebase FCM ?�림???�그?�운???�태?�서??받고????경우 true�??�정
            PerpleSDK.getInstance().setReceivePushOnForeground(false);

            // @google
            // default_web_client_id : auto generated from google-services.json
            PerpleSDK.getInstance().initGoogle(getString(R.string.default_web_client_id));

            // @facebook
            PerpleSDK.getInstance().initFacebook();

            // @twitter
            PerpleSDK.getInstance().initTwitter(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET);
        }

        // @adbrix
        PerpleSDK.getInstance().initAdbrix();

        // @tapjoy
        PerpleSDK.getInstance().initTapjoy(TAPJOY_SDK_KEY, "", isDebug);

        // @naver-cafe
        PerpleSDK.getInstance().initNaverCafe(NAVER_CAFE_CLIENT_ID, NAVER_CAFE_CLIENT_SECRET, NAVER_CAFE_ID, NAVER_NEO_ID_CONSUMER_KEY, NAVER_COMMUNITY_ID);

        // @adjust
        PerpleSDK.getInstance().initAdjust(ADJUST_TOKKEN_ID, ADJUST_SECRET_KEY, isDebug);

        // @admob
        PerpleSDK.getInstance().initAdMob(ADMOB_APP_ID, isDebug);

        // @xsolla
        PerpleSDK.getInstance().initXsolla(XSOLLA_MERCHANT_ID, XSOLLA_API_KEY, XSOLLA_PROJECT_ID, XSOLLA_SECRET_KEY, isDebug);
    }

    @Override
    protected void onNewIntent(Intent i) {
        super.onNewIntent(i);
    }

    @Override
    protected void onStart() {
        super.onStart();

        setBadgeCount(this, 0);

        // @perplesdk
        PerpleSDK.getInstance().onStart();
    }

    @Override
    protected void onStop() {
        super.onStop();

        // @obb
        if (sOBBDownloader != null) {
            sOBBDownloader.disconnectDownloaderClient(this);
        }

        // @perplesdk
        PerpleSDK.getInstance().onStop();
    }

    @Override
    protected void onResume() {
        super.onResume();

        setBadgeCount(this, 0);

        sIsRun = true;

        // @obb
        if (sOBBDownloader != null) {
            sOBBDownloader.connectDownloaderClient(this);
        }

        // @perplesdk
        PerpleSDK.getInstance().onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();

        sIsRun = false;

        // @perplesdk
        PerpleSDK.getInstance().onPause();
    }

    @Override
    protected void onDestroy() {
        // @perplesdk
        PerpleSDK.getInstance().onDestroy();

        super.onDestroy();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        // @perplesdk
        PerpleSDK.getInstance().onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {

        if (requestCode == RC_APP_PERMISSION) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                sdkEventResult("app_requestPermission", "granted", "");
            } else {
                sdkEventResult("app_requestPermission", "denied", "");
            }
            return;
        } else if (requestCode == RC_WRITE_STORAGE_PERMISSION) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                AppActivity.startAPKExpansionDownloader(mVersionCode, mFileSize, mMd5, mCrc32);
            } else {
                String info = "";
                try {
                    JSONObject obj = new JSONObject();
                    obj.put("code", IDownloaderClient.STATE_FAILED_WRITE_STORAGE_PERMISSION_DENIED);
                    obj.put("msg", getString(Helpers.getDownloaderStringResourceIDFromState(IDownloaderClient.STATE_FAILED_WRITE_STORAGE_PERMISSION_DENIED)));
                    info = obj.toString();
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                sdkEventResult("apkexp_start", "error", info);
            }
            return;
        }

    }

    // @obb
    private static void startAPKExpansionDownloader(final int versionCode, long fileSize, String md5, long crc32) {
        // for Main, Patch OBB files
        String[] md5s = { md5, "" };
        long[] crc32s = { crc32, 0 };

        if (APKExpansionDownloader.isNeedToDownloadObbFile(sActivity, versionCode, fileSize, md5s, crc32s)) {
            sOBBDownloader = new APKExpansionDownloader(sActivity, 0);
            sOBBDownloader.setDownloaderCallback(new APKExpansionDownloaderCallback() {
                @Override
                public void onInit() {
                    // startAPKExpansionDownloader()�?onCreate()?�서 직접 ?�출??경우 ?�래 코드 주석 처리
                    sOBBDownloader.connectDownloaderClient(sActivity);

                    // ?�운로드 ?�작
                    // ?�운로드 진행 ?�시 UI ?�기
                    sdkEventResult("apkexp_start", "start", "");
                }
                @Override
                public void onCompleted() {
                    Cocos2dxHelper.setupObbAssetFileInfo(versionCode);

                    // ?�운로드 ?�료
                    // ?�운로드 진행 ?�시 UI ?�고 게임 ?�작
                    sdkEventResult("apkexp_start", "complete", "end");
                }
                @Override
                public void onUpdateStatus(boolean isPaused, boolean isIndeterminate, boolean isInterruptable, int code, String statusText) {
                    // ?�운로드 진행 �??�류 ?�황 처리
                    if (!isIndeterminate) {
                        if (isPaused && isInterruptable) {

                            // Error Code
                            // -----------------------------------------------
                            // IDownloaderClient.STATE_PAUSED_NETWORK_UNAVAILABLE (6) : ?�트?�크가 ?�결?�어 ?��? ?��? 경우
                            // IDownloaderClient.STATE_PAUSED_BY_REQUEST (7) : sOBBDownloader.requestPauseDownload() �?강제�??�운로드 중단?�킨 경우
                            // IDownloaderClient.STATE_PAUSED_ROAMING (12) : 로밍 �? 로밍 중이므�??�금???�??경고�??�고 계속 진행/중단 처리?�다.
                            // IDownloaderClient.STATE_FAILED_UNLICENSED (15) : ?�식?�로 ?�을 ?�운로드 받�? ?��? 경우, APK�?별도�??�치?�여 ?�스?�하??개발 버전?�선 ?�패 처리?��? ?�고 그�?�?진행?�킨??
                            // IDownloaderClient.STATE_FAILED_SDCARD_FULL (17) : ?��? ?�???�치???�량??부족한 경우
                            // IDownloaderClient.STATE_FAILED_WRITE_STORAGE_PERMISSION_DENIED (19) : WRITE_EXTERNAL_STORAGE 권한??거�???경우
                            // IDownloaderClient.STATE_FAILED_NO_GOOGLE_ACCOUNT (20) : 로그?�된 구�? 계정???�는 경우
                            // IDownloaderClient.STATE_FAILED (99) : ?????�는 ?�류

                            // 계속 진행?�고???�다�? ?�류 ?�황???�소?�고 sOBBDownloader.requestContinueDownload() �??�출?�야 ?�다.
                            // ?? ?�반?�으로는 STATE_PAUSED_BY_REQUEST 가 ?�닌 모든 경우 그냥 ?�패 처리?�고 ?�을 ?�설치하?�록 ?�도?�는 것이 좋다.

                            // ?�패 처리
                            // sOBBDownloader.disconnectDownloaderClient(sActivity) �??�출?�여 ?�운로드???�전??중단?�키�?
                            // ???�에???�을 ?�설치하?�록 ?�도?�는 메시지�?출력?�고 ??종료처리�??�다.

                            // WiFI 가 ?�결?��? ?��? 경우?�는 ?�이브러�??��??�서 ?�체?�으�?처리가 ?�어 ?�으므�?별도 처리 ?�요 ?�다.

                            String info = "";
                            try {
                                JSONObject obj = new JSONObject();
                                obj.put("code", code);
                                obj.put("msg", statusText);
                                info = obj.toString();
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }

                            sdkEventResult("apkexp_start", "error", info);
                        }
                    }
                }
                @Override
                public void onUpdateProgress(long current, long total, String progress, String percent) {
                    // ?�운로드 진행 �?
                    // ?�운로드 진행 ?�황 UI ?�데?�트

                    String info = "";
                    try {
                        JSONObject obj = new JSONObject();
                        obj.put("current", current);
                        obj.put("total", total);
                        //obj.put("progress", progress);
                        //obj.put("percent", percent);
                        info = obj.toString();
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                    sdkEventResult("apkexp_start", "progress", info);
                }
            });
            sOBBDownloader.initExpansionDownloader(sActivity);
        } else {
            Cocos2dxHelper.setupObbAssetFileInfo(versionCode);

            // 바로 게임 ?�작
            sdkEventResult("apkexp_start", "complete", "pass");
        }
    }

    public static void setBadgeCount(Context context, int count) {
        String packageName = context.getPackageName();
        String className = "org.cocos2dx.lua.AppActivity";

        Intent intent = new Intent("android.intent.action.BADGE_COUNT_UPDATE");
        intent.putExtra("badge_count", count);
        intent.putExtra("badge_count_package_name", packageName);
        intent.putExtra("badge_count_class_name", className);

        context.sendBroadcast(intent);
    }

    private static String getClipText() {
        android.content.ClipboardManager clipboard = (android.content.ClipboardManager) sActivity
                .getSystemService(Context.CLIPBOARD_SERVICE);
        if (clipboard == null) {
            return null;
        }

        android.content.ClipData clipData = clipboard.getPrimaryClip();
        if (clipData == null) {
            return null;
        }

        android.content.ClipData.Item item = clipData.getItemAt(0);
        if (item == null) {
            return null;
        }

        if (item.getText() == null) {
            return null;
        }

        String clipText = item.getText().toString();
        return clipText;
    }

    private static void setClipText(String text) {
        android.content.ClipboardManager clipboard = (android.content.ClipboardManager)sActivity.getSystemService(Context.CLIPBOARD_SERVICE);
        android.content.ClipData clip = android.content.ClipData.newPlainText("DragonVillageM RecoveryCode", text);
        clipboard.setPrimaryClip(clip);
    }

    private static void appRestart() {
        Intent intent = new Intent(sActivity, AppActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(sActivity, RC_APP_RESTART, intent, PendingIntent.FLAG_CANCEL_CURRENT);

        AlarmManager mgr = (AlarmManager)sActivity.getSystemService(Context.ALARM_SERVICE);
        mgr.set(AlarmManager.RTC,  System.currentTimeMillis() + 500, pendingIntent);

        ActivityCompat.finishAffinity(sActivity);
        System.runFinalization();
        System.exit(0);
    }

    private static void appTerminate() {
        android.os.Process.killProcess(android.os.Process.myPid());
    }

    private static void appSendMail(String email, String subject, String text) {
        String[] tos = { email };
        Intent it = new Intent(Intent.ACTION_SEND);
        it.putExtra(Intent.EXTRA_EMAIL, tos);
        it.putExtra(Intent.EXTRA_SUBJECT, subject);
        it.putExtra(Intent.EXTRA_TEXT, text);
        it.setType("text/plain");
        sActivity.startActivity(Intent.createChooser(it, "Choose Email Client"));
    }

    private static void appGotoWeb(String url) {
        Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        sActivity.startActivity(browserIntent);
    }

    private static void appGotoStore(String appId) {
        try {
            sActivity.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + appId)));
        } catch (android.content.ActivityNotFoundException anfe) {
            sActivity.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("http://play.google.com/store/apps/details?id=" + appId)));
        }
    }

    private static void appAlert(String title, String message) {
        new AlertDialog.Builder(sActivity)
            .setTitle(title)
            .setMessage(message)
            .setPositiveButton(android.R.string.ok, null).create()
            .show();
    }

    private static String getDeviceInfo() {
        String info = "";
        try {
            JSONObject obj = new JSONObject();
            obj.put("desc", Build.MANUFACTURER + " " + Build.MODEL + "(Android " + Build.VERSION.RELEASE + ", API " + Build.VERSION.SDK_INT + ")");
            obj.put("OS_VERSION", System.getProperty("os.version"));
            obj.put("VERSION_RELEASE", Build.VERSION.RELEASE);
            obj.put("VERSION_INCREMENTAL", Build.VERSION.INCREMENTAL);
            obj.put("VERSION_SDK_INT", Build.VERSION.SDK_INT);
            obj.put("MANUFACTURER", Build.MANUFACTURER);
            obj.put("DISPLAY", Build.DISPLAY);
            obj.put("BRAND", Build.BRAND);
            obj.put("BOARD", Build.BOARD);
            obj.put("DEVICE", Build.DEVICE);
            obj.put("HARDWARE", Build.HARDWARE);
            obj.put("HOST", Build.HOST);
            obj.put("ID", Build.ID);
            obj.put("MODEL", Build.MODEL);
            obj.put("PRODUCT", Build.PRODUCT);
            obj.put("SERIAL", Build.SERIAL);
            obj.put("TAGS", Build.TAGS);
            obj.put("TIME", Build.TIME);
            obj.put("TYPE", Build.TYPE);
            obj.put("USER", Build.USER);
            info = obj.toString();
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return info;
    }

    public String getHostIpAddress() {
        WifiManager wifiMgr = (WifiManager)getApplicationContext().getSystemService(WIFI_SERVICE);
        WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
        int ip = wifiInfo.getIpAddress();
        return ((ip & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF));
    }

    public static String getLocalIpAddress() {
        return hostIPAdress;
    }

    public static String getDeviceLanguage() {
        Locale loc = Locale.getDefault();
        String lan = loc.getLanguage();
        String language = lan.toLowerCase(loc);

        if (language.equals("zh")) {
            if (loc == Locale.TAIWAN || loc == Locale.TRADITIONAL_CHINESE) {
                language = "zh-tw";
            } else {
                language = "zh-cn";
            }
        }

        return language;
    }

    public static String getLocale() {
        Locale loc = Locale.getDefault();
        return loc.toString();
    }

    // Cpp(Native) -> Java (in UIThread(Main Thread))
    public static void sdkEvent(final String id, final String arg0, final String arg1) {

        sActivity.mAppHandler.post(new Runnable() {
            @Override
            public void run() {

                if (id.equals("apkexp_start")) {
                    String[] array1 = arg0.split(";");
                    mVersionCode = Integer.parseInt(array1[0]);
                    mFileSize = Long.parseLong(array1[1]);
                    mMd5 = arg1;
                    mCrc32 = 0;

                    if (ContextCompat.checkSelfPermission(sActivity, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                        String permissions[] = new String[1];
                        permissions[0] = Manifest.permission.WRITE_EXTERNAL_STORAGE;
                        ActivityCompat.requestPermissions(sActivity, permissions, RC_WRITE_STORAGE_PERMISSION);
                    } else {
                        AppActivity.startAPKExpansionDownloader(mVersionCode, mFileSize, mMd5, mCrc32);
                    }
                } else if (id.equals("apkexp_check")) {
                    String[] array1 = arg0.split(";");
                    int versionCode = Integer.parseInt(array1[0]);
                    long fileSize = Long.parseLong(array1[1]);
                    String[] md5s = { arg1, "" };
                    long[] crc32s = { 0, 0 };

                    boolean result = APKExpansionDownloader.isNeedToDownloadObbFile(sActivity, versionCode, fileSize, md5s, crc32s);
                    if (result) {
                        sdkEventResult(id, "download", "");
                    } else {
                        Cocos2dxHelper.setupObbAssetFileInfo(versionCode);
                        if (Cocos2dxHelper.getObbAssetFile() == null) {
                            sdkEventResult(id, "permission", "");
                        } else {
                            sdkEventResult(id, "pass", "");
                        }
                    }
                } else if (id.equals("apkexp_continue")) {

                    sOBBDownloader.requestContinueDownload();

                } else if (id.equals("apkexp_pause")) {

                    sOBBDownloader.requestPauseDownload();

                } else if (id.equals("apkexp_stop")) {

                    sOBBDownloader.disconnectDownloaderClient(sActivity);

                } else if (id.equals("localpush_register")) {

                    Intent intent = PerpleIntentFactory.makeIntentService(sActivity);
                    sActivity.startService(intent);

                } else if (id.equals("localpush_cancel")) {

                    PerpleIntentFactory.clear();
                    Intent intent = PerpleIntentFactory.makeIntentService(sActivity);
                    sActivity.stopService(intent);

                } else if (id.equals("localpush_add")) {

                    String[] array = arg0.split(";");
                    String type = array[0];
                    int sec = Integer.parseInt(array[1]);
                    String msg = array[2];

                    boolean bAlert = false;
                    if (array.length > 3) {
                        if (array[3].equals("alert")) {
                            bAlert = true;
                        }
                    }

                    PerpleIntentFactory.addNoti(type, sec, msg, bAlert);

                } else if (id.equals("localpush_setColor")) {

                    String[] array = arg0.split(";");
                    String bgColor = array[0];
                    String titleColor = array[1];
                    String messageColor = array[2];

                    PerpleIntentFactory.setColor(bgColor, titleColor, messageColor);

                } else if (id.equals("localpush_setLinkUrl")) {

                    String[] array = arg0.split(";");
                    String linkTitle = array[0];
                    String linkUrl = array[1];
                    String cafeUrl = array[2];

                    PerpleIntentFactory.setLinkUrlInfo(linkTitle, linkUrl, cafeUrl);

                } else if (id.equals("clipboard_setText")) {

                    setClipText(arg0);

                } else if (id.equals("clipboard_getText")) {

                    String clipText = getClipText();
                    if (clipText == null) {
                        sdkEventResult(id, "fail", "");
                    } else {
                        sdkEventResult(id, "success", clipText);
                    }

                } else if (id.equals("app_restart")) {

                    appRestart();

                } else if (id.equals("app_terminate")) {

                    appTerminate();

                } else if (id.equals("app_sendMail")) {

                    String[] array = arg0.split(";");
                    appSendMail(array[0], array[1], array[2]);

                } else if (id.equals("app_gotoWeb")) {

                    appGotoWeb(arg0);

                } else if (id.equals("app_gotoStore")) {

                    appGotoStore(arg0);

                } else if (id.equals("app_alert")) {

                    String[] array = arg0.split(";");
                    appAlert(array[0], array[1]);

                } else if (id.equals("app_deviceInfo")) {

                    String info = getDeviceInfo();
                    sdkEventResult(id, "success", info);

                } else if (id.equals("app_checkPermission")) {

                    // "android.permission.READ_EXTERNAL_STORAGE"
                    String permission = arg0;
                    if (ContextCompat.checkSelfPermission(sActivity, permission) != PackageManager.PERMISSION_GRANTED) {
                        sdkEventResult(id, "denied", "");
                    } else {
                        sdkEventResult(id, "granted", "");
                    }

                } else if (id.equals("app_requestPermission")) {

                    // "android.permission.READ_EXTERNAL_STORAGE"
                    String permissions[] = new String[1];
                    permissions[0] = arg0;
                    ActivityCompat.requestPermissions(sActivity, permissions, RC_APP_PERMISSION);

                }
            }
        });
    }

    // Java -> Cpp(Native) (in GLThread)
    private static void sdkEventResult(final String id, final String ret, final String info) {
        sActivity.runOnGLThread(new Runnable() {
            @Override
            public void run() {
                nativeSDKEventResult(id, ret, info);
            }
        });
    }

    private static native void nativeSDKEventResult(String id, String result, String info);

}
