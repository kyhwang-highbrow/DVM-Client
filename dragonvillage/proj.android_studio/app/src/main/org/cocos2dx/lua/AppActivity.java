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
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import android.Manifest;
import android.content.pm.PackageManager;
import android.provider.Settings;

// @app configuration
import com.perplelab.PerpleConfig;

//@perplesdk
import com.perplelab.PerpleSDK;

import java.util.Locale;

public class AppActivity extends Cocos2dxActivity{

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

        // @perplesdk, Lua 콜백을 GL Thread 에서 실행하고자 할 경우 설정한다.
        PerpleSDK.setGLSurfaceView(getGLSurfaceView());

        // 디버그 메시지 출력
        boolean isDebug = BuildConfig.DEBUG;

        PerpleSDK perpleSdkInstance = PerpleSDK.getInstance();

        // @perplesdk // getString(R.string.gcm_defaultSenderId) GCM is deprecated, use FCM
        if (perpleSdkInstance.initSDK(PerpleConfig.BASE64_PUBLIC_KEY, isDebug)) {

            // firebase FCM 알림을 포그라운드 상태에서도 받고자 할 경우 true로 설정
            perpleSdkInstance.setReceivePushOnForeground(true);

            // @google
            // default_web_client_id : auto generated from google-services.json
            perpleSdkInstance.initGoogle(getString(R.string.default_web_client_id));

            // @facebook
            perpleSdkInstance.initFacebook();

            // @twitter
            perpleSdkInstance.initTwitter(PerpleConfig.TWITTER_CONSUMER_KEY, PerpleConfig.TWITTER_CONSUMER_SECRET);
        }

        // @tapjoy
        perpleSdkInstance.initTapjoy(PerpleConfig.TAPJOY_SDK_KEY, "", isDebug);

        // @adjust
        perpleSdkInstance.initAdjust(PerpleConfig.ADJUST_TOKKEN_ID, PerpleConfig.ADJUST_SECRET_KEY, isDebug);

        // @admob
        perpleSdkInstance.initAdMob();

        // @xsolla
        if (PerpleConfig.USE_XSOLLA) {
            perpleSdkInstance.initXsolla(PerpleConfig.XSOLLA_MERCHANT_ID, PerpleConfig.XSOLLA_API_KEY, PerpleConfig.XSOLLA_PROJECT_ID, PerpleConfig.XSOLLA_SECRET_KEY, isDebug);
        }

        // @crashlytics
        perpleSdkInstance.initCrashlytics();

        // @onestore
        if (BuildConfig.FLAVOR_platform == "onestore") {
            perpleSdkInstance.initOnestore(PerpleConfig.ONESTORE_PURBLIC_KEY);
        }
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
                    // startAPKExpansionDownloader()를 onCreate()에서 직접 호출할 경우 아래 코드 주석 처리
                    sOBBDownloader.connectDownloaderClient(sActivity);

                    // 다운로드 시작
                    // 다운로드 진행 표시 UI 열기
                    sdkEventResult("apkexp_start", "start", "");
                }
                @Override
                public void onCompleted() {
                    Cocos2dxHelper.setupObbAssetFileInfo(versionCode);

                    // 다운로드 완료
                    // 다운로드 진행 표시 UI 닫고 게임 시작
                    sdkEventResult("apkexp_start", "complete", "end");
                }
                @Override
                public void onUpdateStatus(boolean isPaused, boolean isIndeterminate, boolean isInterruptable, int code, String statusText) {
                    // 다운로드 진행 중 오류 상황 처리
                    if (!isIndeterminate) {
                        if (isPaused && isInterruptable) {

                            // Error Code
                            // -----------------------------------------------
                            // IDownloaderClient.STATE_PAUSED_NETWORK_UNAVAILABLE (6) : 네트워크가 연결되어 있지 않은 경우
                            // IDownloaderClient.STATE_PAUSED_BY_REQUEST (7) : sOBBDownloader.requestPauseDownload() 로 강제로 다운로드 중단시킨 경우
                            // IDownloaderClient.STATE_PAUSED_ROAMING (12) : 로밍 중, 로밍 중이므로 요금에 대한 경고를 하고 계속 진행/중단 처리한다.
                            // IDownloaderClient.STATE_FAILED_UNLICENSED (15) : 정식으로 앱을 다운로드 받지 않은 경우, APK를 별도로 설치하여 테스트하는 개발 버전에선 실패 처리하지 않고 그대로 진행시킨다.
                            // IDownloaderClient.STATE_FAILED_SDCARD_FULL (17) : 외부 저장 장치의 용량이 부족한 경우
                            // IDownloaderClient.STATE_FAILED_WRITE_STORAGE_PERMISSION_DENIED (19) : WRITE_EXTERNAL_STORAGE 권한을 거부한 경우
                            // IDownloaderClient.STATE_FAILED_NO_GOOGLE_ACCOUNT (20) : 로그인된 구글 계정이 없는 경우
                            // IDownloaderClient.STATE_FAILED (99) : 알 수 없는 오류

                            // 계속 진행하고자 한다면, 오류 상황을 해소하고 sOBBDownloader.requestContinueDownload() 를 호출해야 한다.
                            // 단, 일반적으로는 STATE_PAUSED_BY_REQUEST 가 아닌 모든 경우 그냥 실패 처리하고 앱을 재설치하도록 유도하는 것이 좋다.

                            // 실패 처리
                            // sOBBDownloader.disconnectDownloaderClient(sActivity) 를 호출하여 다운로드는 완전히 중단시키고,
                            // 앱 안에서 앱을 재설치하도록 유도하는 메시지를 출력하고 앱 종료처리를 한다.

                            // WiFI 가 연결되지 않은 경우에는 라이브러리 내부에서 자체적으로 처리가 되어 있으므로 별도 처리 필요 없다.

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
                    // 다운로드 진행 중
                    // 다운로드 진행 상황 UI 업데이트

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

            // 바로 게임 시작
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
        int flag;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flag = PendingIntent.FLAG_IMMUTABLE;
        } else {
            flag = PendingIntent.FLAG_CANCEL_CURRENT;
        }

        Intent intent = new Intent(sActivity, AppActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(sActivity, RC_APP_RESTART, intent, flag);

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
        try {
            sActivity.startActivity(browserIntent);
        } catch (ActivityNotFoundException e) {
            sActivity.startActivity(Intent.createChooser(browserIntent, "Choose Web Browser Client"));
        }
    }

    private static void appGotoStore(String appId) {
        try {
            sActivity.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + appId)));
        } catch (android.content.ActivityNotFoundException anfe) {
            if (BuildConfig.FLAVOR_platform == "onestore"){
                // 참고 링크 : https://github.com/ONE-store/inapp-sdk/wiki/Tools-Developer-Guide
                //sActivity.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://www.onestore.co.kr/userpoc/game/view?pid=" + appId)));
                sActivity.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://onesto.re/" + appId)));
            }else{
                sActivity.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("http://play.google.com/store/apps/details?id=" + appId)));
            }
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
    
    private static String getAdvertisingID() {
        return PerpleSDK.getAdid();
        /*String advertising_id = PerpleSDK.getInstance().getAdid();
        return advertising_id;*/
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
					
					// Android 8.0 오레오부터 백그라운드 실행 제한이 적용되어 예외처리 해야함
					// https://developer.android.com/about/versions/oreo/android-8.0-changes#back-all
					if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
						//sActivity.startForegroundService(intent);
						sActivity.startService(intent);
					} else {
						sActivity.startService(intent); 
					}

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
                    
                } else if (id.equals("advertising_id")) {

                    String advertising_id = getAdvertisingID();
                    sdkEventResult(id, "success", advertising_id);

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

                else if (id.equals("app_requestAppSetting")) {
                    try {
                        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                                .setData(Uri.parse("package:" + sActivity.getPackageName()));
                        sActivity.startActivity(intent);
                    } catch (ActivityNotFoundException e) {
                        e.printStackTrace();
                        Intent intent = new Intent(Settings.ACTION_MANAGE_APPLICATIONS_SETTINGS);
                        sActivity.startActivity(intent);
                    }
                }

                else if (id.equals("unityads_initialize")) {
                    boolean isDebug = false;
                    if (arg0.equals("debug"))
                        isDebug = true;
                    
//                    // @UnitAds
//                    PerpleSDK perpleSdkInstance = PerpleSDK.getInstance();
//                    perpleSdkInstance.initUnityAds(PerpleConfig.UNITYADS_GAME_ID, isDebug);
                } else if (id.equals("isInstalled")) {
                    String packageName = arg0;
                    int installStatus = isInstalled(packageName);
                    sdkEventResult(id, String.valueOf(installStatus), "");
                }
            }
        });
    }

    private static int isInstalled(String packageName) {
        try {
            PackageManager pm = PerpleSDK.getInstance().getMainActivity().getPackageManager();
            pm.getPackageInfo(packageName, 0);
            return 1;
        } catch (PackageManager.NameNotFoundException e) {
            return 0;
        }
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
