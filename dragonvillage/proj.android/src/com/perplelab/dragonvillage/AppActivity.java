/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.

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
package com.perplelab.dragonvillage;

import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.io.*;

import org.cocos2dx.lib.Cocos2dxActivity;

/*
// @kakao
import com.kakao.cocos2dx.plugin.KakaoAndroid;
import com.kakao.cocos2dx.plugin.KakaoAndroidInterface;
import com.kakao.api.Logger;
*/

import android.annotation.SuppressLint;
import android.app.ActivityManager;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.util.Log;
import android.view.Window;
import android.view.WindowManager;

// @android 6.0 marshmallow runtime permission
import android.support.v4.content.ContextCompat;
import android.support.v4.app.ActivityCompat;
import android.Manifest;
import android.os.Build;
import android.content.DialogInterface;

import org.json.JSONObject;

// @google+
//import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.GoogleApiClient.Builder;
//import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.games.Games;
//import com.google.android.gms.games.Player;
import com.google.android.gms.games.quest.Quest;
import com.google.android.gms.games.quest.Quests;
import com.google.android.gms.games.quest.QuestUpdateListener;
//import com.google.android.gms.games.event.Events;
//import com.google.android.gms.plus.Plus;
//import com.google.example.games.basegameutils.BaseGameUtils;

import com.perplelab.dragonvillage.R;


// @moloco
import com.moloco.android.tracker.Feature;

// @adbrix
import com.igaworks.IgawCommon;
import com.igaworks.adbrix.IgawAdbrix;
import com.igaworks.adbrix.interfaces.ADBrixInterface.CohortVariable;

// @tapjoy
import com.tapjoy.Tapjoy;

// @partytrack
import it.partytrack.sdk.Track;

public class AppActivity extends Cocos2dxActivity implements
        // @kakao
        //KakaoAndroidInterface,
        // @google+, @google login
        //GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener,
        // @google+
        QuestUpdateListener,
        // @android 6.0 marshmallow runtime permission
        ActivityCompat.OnRequestPermissionsResultCallback {

    public static boolean mIsRun = false;

    private static AppActivity s_Activity;

    private Handler mAppHandler;

    // @google+
    // Client used to interact with Google APIs
    private GoogleApiClient mGoogleApiClient;

    // @moloco
    private Feature mTracker;

    /*
    // @google+, @google login
    // Request codes we use when invoking an external activity
    // for sign-in
    private static final int RC_GOOGLE_SIGN_IN = 9001;
    */

    // @google+
    // Request codes we use when invoking an external activity
    // for achievement, leaderboard, quest
    private static final int RC_GOOGLE_ACHIEVEMENTS = 5000;
    private static final int RC_GOOGLE_LEADERBOARDS = 5001;
    private static final int RC_GOOGLE_QUESTS = 5002;

    /*
    // @google+, @google login
    // Automatically start the sign-in flow when the Activity starts
    private boolean mAutoStartSignInFlow = false;
    // Has the user clicked the sign-in button?
    private boolean mSignInClicked = false;
    // Are we currently resolving a connection failure?
    private boolean mResolvingConnectionFailure = false;
    // Has the connection stopped by onStop()?
    private boolean mGoogleConnectionStopped = false;
    */

    /*
    // @google+, @google login
    private boolean mRequestedGoogleLogin = false;
    private boolean mRequestedGoogleLogout = false;
    */

    // @google+
    private boolean mRequestedGoogleShowAchievements = false;
    private boolean mRequestedGoogleShowLeaderboards = false;
    private boolean mRequestedGoogleShowQuests = false;

    // @android 6.0 marshmallow runtime permission
    private static final int REQUEST_CODE_ASK_MULTIPLE_PERMISSIONS = 124;

    static String hostIPAdress = "0.0.0.0";
    static int loginPlatform = 0;

    static final Boolean DEBUG = false;
    static final String TAG = "DV";

    // The name of .so is specified in AndroidMenifest.xml. NativityActivity will load it automatically for you.
    // You can use "System.loadLibrary()" to load other .so files.
    static {
        // @patisdk
        System.loadLibrary("gnustl_shared");
        //System.loadLibrary("patisdk");
    }


    //--------------------------------------------------------------------------------
    // Override Functions
    //--------------------------------------------------------------------------------
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        if (DEBUG) { Log.d(TAG, "onCreate()"); }

        super.onCreate(savedInstanceState);

        s_Activity = this;

        mAppHandler = new Handler();

        if (nativeIsLandScape()) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
        } else {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
        }

        // Check the wifi is opened when the native is debug.
        /*
        if (nativeIsDebug())
        {
            if (!isWifiConnected())
            {
                AlertDialog.Builder builder = new AlertDialog.Builder(this);
                builder.setTitle("Warning");
                builder.setMessage("Open Wifi for debuging...");
                builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        startActivity(new Intent(Settings.ACTION_WIFI_SETTINGS));
                        finish();
                        System.exit(0);
                    }
                });
                builder.setCancelable(false);
                builder.show();
            }
        }
		*/

        hostIPAdress = getHostIpAddress();

        loginPlatform = nativeLoginPlatform();

        // @moloco
        //Feature.setErrorDebug(true);
        //Feature.enableDebug(true);

        // @moloco
        HashMap<String, Object> datamap = new HashMap<String, Object>();
        datamap.put(Feature.INPUTITEMS.PARTNER_NAME, "Moloco");

        // @moloco
        // Default currency is USD. To use a custom currency, uncomment the next line.
        //datamap.put(Feature.INPUTITEMS.CURRENCY, Feature.CURRENCIES.EUR);

        // @moloco
        mTracker = new Feature(this, datamap);

        // @adbrix
        IgawCommon.startApplication(this);

        // @tapjoy
        Tapjoy.connect(this, getString(R.string.tapjoy_sdk_key));

        // @tapjoy
        // Do not set this for apps released to a store!
        //Tapjoy.setDebugEnabled(true);

        // @partytrack
        Track.start(this.getApplicationContext(), Integer.parseInt(getString(R.string.partytrack_app_id)), getString(R.string.partytrack_app_key));

        // @partytrack
        // 디버그 로그 출력
        //Track.setDebugMode(true);

        // @partytrack
        // 임의 파라미터를 서버로 송신하는 방법
        // paramKey:String, paramValue:String
        // paramKey=paramValue의 형식으로 서버로 송신
        //Track.setOptionalParam(paramKey, paramValue);

        // @partytrack
        // 유저 데이터의 facebook 광고 최적화 이용 옵트 아웃
        // 유저에게 유저 데이터를 facebook 광고 최적화에 이용하는 것에 허락받을 경우 호출
        //Track.disableAdvertisementOptimize();

        /*
        // @kakao
        KakaoAndroid.plugin = this;
        KakaoAndroid.uri = getIntent().getData();
        initJNIBridge();
        */

        /*
        // @google+, @google login
        // Create the Google API Client with access to Plus and Games
        mGoogleApiClient = new GoogleApiClient.Builder(this)
            .addConnectionCallbacks(this)
            .addOnConnectionFailedListener(this)
            .addApi(Plus.API).addScope(Plus.SCOPE_PLUS_LOGIN)
            .addApi(Games.API).addScope(Games.SCOPE_GAMES)
            .build();
        */
    }

    @Override
    protected void onDestroy() {
        if (DEBUG) { Log.d(TAG, "onDestroy()"); }
        super.onDestroy();
    }

    @Override
    protected void onStart() {
        if (DEBUG) { Log.d(TAG, "onStart()"); }

        super.onStart();

        setBadgeCount(this, 0);

        // @tapjoy
        Tapjoy.onActivityStart(this);

        /*
        // @google+, @google login
        if (mAutoStartSignInFlow) {
            // Check to see the developer who's running this sample code read the instructions :-)
            // NOTE: this check is here only because this is a sample! Don't include this
            // check in your actual production app.
            //if (!BaseGameUtils.verifySampleSetup(this, R.string.app_id,
            //        R.string.achievement_prime, R.string.leaderboard_easy)) {
            //    Log.w(TAG, "*** Warning: setup problems detected. Sign in may not work!");
            //}

            // Start the sign-in flow
            mGoogleApiClient.connect();
        }
        */
    }

    @Override
    protected void onStop() {
        if (DEBUG) { Log.d(TAG, "onStop()"); }

        // @tapjoy
        Tapjoy.onActivityStop(this);

        /*
        // @google+, @google login
        if (isSignedIn()) {
            mGoogleApiClient.disconnect();
            mGoogleConnectionStopped = true;
        }
        */

        super.onStop();
    }

    @Override
    protected void onPause() {
        if (DEBUG) { Log.d(TAG, "onPause()"); }

        super.onPause();

        // @adbrix
        IgawCommon.endSession();
        mIsRun = false;
    }

    @Override
    protected void onResume() {
        if (DEBUG) { Log.d(TAG, "onResume()"); }

        super.onResume();

        setBadgeCount(this, 0);

        // @adbrix
        IgawCommon.startSession(this);

        // @kakao
        //KakaoAndroid.getInstance().resume(this);

        /*
        // @google+, @google login
        if (mGoogleConnectionStopped) {
            mGoogleConnectionStopped = false;
            if (!isSignedIn()) {
                mGoogleApiClient.connect();
            }
        }
        */
        
        mIsRun = true;
    }

    @Override
    protected void onNewIntent(Intent intent) {
        if (DEBUG) { Log.d(TAG, "onNewIntent()"); }

        super.onNewIntent(intent);
    }

    /*
    // @google+, @google login
    @Override
    public void onConnected(Bundle connectionHint) {
        if (DEBUG) { Log.d(TAG, "onConnected(): connected to Google APIs"); }

        if (mSignInClicked) {
            mSignInClicked = false;
        }

        if (mAutoStartSignInFlow) {
            mAutoStartSignInFlow = false;
        }

        // Get the player information.
        Player p = Games.Players.getCurrentPlayer(mGoogleApiClient);

        JSONObject obj = new JSONObject();
        try {
            obj.put("playerId",  p.getPlayerId());
            obj.put("displayName", p.getDisplayName());
            obj.put("hashCode", p.hashCode());
            obj.put("hasHiResImage", p.hasHiResImage());
            obj.put("hiResImageUrl", p.getHiResImageUrl());
            obj.put("hasIconImage", p.hasIconImage());
            obj.put("iconImageUrl", p.getIconImageUrl());
        } catch (JSONException e) {
            e.printStackTrace();
        }

        String info = obj.toString();

        // The player is signed in.
        if (mRequestedGoogleLogin) {
            mRequestedGoogleLogin = false;
            sdkEventResult("googleplay_login", "success", info);
        }

        Games.Quests.registerQuestUpdateListener(mGoogleApiClient, this);
    }
    */

    /*
    // @google+, @google login
    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {
        if (mResolvingConnectionFailure) {
            // Already resolving
            if (DEBUG) { Log.d(TAG, "onConnectionFailed(): attempting to resolve"); }
            return;
        }

        // If the sign-in button was clicked or if auto sign-in is enabled, launch the sign-in flow
        if (mSignInClicked || mAutoStartSignInFlow) {
            mAutoStartSignInFlow = false;
            mSignInClicked = false;
            mResolvingConnectionFailure = true;

            // Attempt to resolve the connection failure using BaseGameUtils.
            // The R.string.signin_other_error value should reference a generic
            // error string in your strings.xml file, such as "There was
            // an issue with sign-in, please try again later."
            if (DEBUG) { Log.d(TAG, "onConnectionFailed(): attempting to resolve"); }

            if (!BaseGameUtils.resolveConnectionFailure(this, mGoogleApiClient, connectionResult,
                    RC_GOOGLE_SIGN_IN, getString(R.string.signin_other_error))) {
                mResolvingConnectionFailure = false;
                if (DEBUG) { Log.d(TAG, "onConnectionFailed(): resolving fail"); }
            }
            else {
                if (DEBUG) { Log.d(TAG, "onConnectionFailed(): resolving success"); }
                return;
            }
        }

        if (DEBUG) { Log.d(TAG, "onConnectionFailed()"); }

        // Sign-in failed.
        if (mRequestedGoogleLogin) {
            mRequestedGoogleLogin = false;
            sdkEventResult("googleplay_login", "fail", "");
        }
    }
    */

    /*
    // @google+, @google login
    @Override
    public void onConnectionSuspended(int i) {
        if (DEBUG) { Log.d(TAG, "onConnectionSuspended(): attempting to connect"); }

        // Attempt to reconnect
        mGoogleApiClient.connect();
    }
    */

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (DEBUG) { Log.d(TAG, "onActivityResult() - requestCode:" + String.valueOf(requestCode) + ", resultCode:" + String.valueOf(resultCode)); }

        super.onActivityResult(requestCode, resultCode, data);

        // @google+
        if (requestCode == RC_GOOGLE_ACHIEVEMENTS) {
            if (DEBUG) { Log.d(TAG, "onActivityResult(RC_GOOGLE_ACHIEVEMENTS)," + resultCode + ","+ data + ")"); }
            if (resultCode == RESULT_OK || resultCode == RESULT_CANCELED) {
                if (mRequestedGoogleShowAchievements) {
                    mRequestedGoogleShowAchievements = false;
                    sdkEventResult("googleplay_showAchievements", "true", "");
                }
            } else {
                //
                if (mRequestedGoogleShowAchievements) {
                    //mGoogleApiClient = null;
                    mGoogleApiClient.disconnect();
                    mRequestedGoogleShowAchievements = false;
                    sdkEventResult("googleplay_showAchievements", "false", String.valueOf(resultCode));
                }
            }
        // @google+
        } else if (requestCode == RC_GOOGLE_LEADERBOARDS) {
            if (DEBUG) { Log.d(TAG, "onActivityResult(RC_GOOGLE_LEADERBOARDS)," + resultCode + ","+ data + ")"); }
            if (resultCode == RESULT_OK || resultCode == RESULT_CANCELED) {
                if (mRequestedGoogleShowLeaderboards) {
                    mRequestedGoogleShowLeaderboards = false;
                    sdkEventResult("googleplay_showLeaderboards", "true", "");
                }
            } else {
                //
                if (mRequestedGoogleShowLeaderboards) {
                    //mGoogleApiClient = null;
                    mGoogleApiClient.disconnect();
                    mRequestedGoogleShowLeaderboards = false;
                    sdkEventResult("googleplay_showLeaderboards", "false", String.valueOf(resultCode));
                }
            }
        // @google+
        } else if (requestCode == RC_GOOGLE_QUESTS) {
            if (DEBUG) { Log.d(TAG, "onActivityResult(RC_GOOGLE_QUESTS)," + resultCode + ","+ data + ")"); }
            if (resultCode == RESULT_OK || resultCode == RESULT_CANCELED) {
                if (mRequestedGoogleShowQuests) {
                    mRequestedGoogleShowQuests = false;
                    sdkEventResult("googleplay_showQuests", "true", "");
                }
            } else {
                //
                if (mRequestedGoogleShowQuests) {
                    //mGoogleApiClient = null;
                    mGoogleApiClient.disconnect();
                    mRequestedGoogleShowQuests = false;
                    sdkEventResult("googleplay_showQuests", "false", String.valueOf(resultCode));
                }
            }
        /*
        // @google+, @google login
        } else if (requestCode == RC_GOOGLE_SIGN_IN) {
            mSignInClicked = false;
            mResolvingConnectionFailure = false;

            if (resultCode == RESULT_OK) {
                mGoogleApiClient.connect();
            } else if (resultCode == RESULT_CANCELED) {
                // Sign-in canceled.
                if (mRequestedGoogleLogin) {
                    mRequestedGoogleLogin = false;
                    sdkEventResult("googleplay_login", "cancel", "");
                }
            } else {
                // Bring up an error dialog to alert the user that sign-in
                // failed. The R.string.signin_failure should reference an error
                // string in your strings.xml file that tells the user they
                // could not be signed in, such as "Unable to sign in."
                //BaseGameUtils.showActivityResultError(this, requestCode, resultCode, R.string.signin_other_error);
                if (mRequestedGoogleLogin) {
                    mRequestedGoogleLogin = false;
                    sdkEventResult("googleplay_login", "error", String.valueOf(resultCode));
                }
            }
        */
        } else {

            // @kakao
            //KakaoAndroid.getInstance().activityResult(this, requestCode, resultCode, data);
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
    }

    // @android 6.0 marshmallow runtime permission
    @SuppressLint("Override") @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        //Pati.getInstance().onRequestPermissionResult(requestCode, permissions, grantResults);
    }

    // @android 6.0 marshmallow runtime permission
    private void checkPermission() {
        List<String> permissionsNeeded = new ArrayList<String>();

        final List<String> permissionsList = new ArrayList<String>();
        if (!addPermission(permissionsList, Manifest.permission.ACCESS_COARSE_LOCATION))
            permissionsNeeded.add("GPS");
        if (!addPermission(permissionsList, Manifest.permission.READ_PHONE_STATE))
            permissionsNeeded.add("Phone");
        if (!addPermission(permissionsList, Manifest.permission.GET_ACCOUNTS))
            permissionsNeeded.add("Contacts");
        if (!addPermission(permissionsList, Manifest.permission.WRITE_EXTERNAL_STORAGE))
            permissionsNeeded.add("Storage");
        // if (!addPermission(permissionsList, Manifest.permission.READ_EXTERNAL_STORAGE))
        //     permissionsNeeded.add("Storage");

        if (permissionsList.size() > 0) {
            if (permissionsNeeded.size() > 0) {
                String message = "You need to grant access to " + permissionsNeeded.get(0);
                for (int i = 1; i < permissionsNeeded.size(); i++)
                    message = message + ", " + permissionsNeeded.get(i);
                showMessageOKCancel(message,
                    new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            ActivityCompat.requestPermissions(s_Activity, permissionsList.toArray(new String[permissionsList.size()]), REQUEST_CODE_ASK_MULTIPLE_PERMISSIONS);
                        }
                    }
                );
                return;
            }
        }
    }

    // @android 6.0 marshmallow runtime permission
    private boolean addPermission(List<String> permissionsList, String permission) {
        if (ContextCompat.checkSelfPermission(s_Activity, permission) != PackageManager.PERMISSION_GRANTED) {
            permissionsList.add(permission);
            if (!ActivityCompat.shouldShowRequestPermissionRationale(s_Activity, permission))
                return false;
        }
        return true;
    }

    // @android 6.0 marshmallow runtime permission
    private void showMessageOKCancel(String message, DialogInterface.OnClickListener okListener) {
        new AlertDialog.Builder(s_Activity, AlertDialog.THEME_HOLO_LIGHT)
            .setTitle("Notice")
            .setMessage(message)
            .setPositiveButton("OK", okListener)
            .setCancelable(false)
            .create()
            .show();
    }

    // @google+
    @Override
    public void onQuestCompleted(Quest quest) {

        // Claim the quest reward.
        Games.Quests.claim(mGoogleApiClient, quest.getQuestId(), quest.getCurrentMilestone().getMilestoneId());

        // Process the RewardData to provision a specific reward.
        String reward = new String(quest.getCurrentMilestone().getCompletionRewardData(), Charset.forName("UTF-8"));

        // Provision the reward; this is specific to your game. Your game
        // should also let the player know the quest was completed and
        // the reward was claimed; for example, by displaying a toast.
        // ...

        sdkEventResult("googleplay_setEvents", "completed", reward);
    }

    //--------------------------------------------------------------------------------
    // Public Functions
    //--------------------------------------------------------------------------------

    public String getHostIpAddress() {
        WifiManager wifiMgr = (WifiManager)getSystemService(WIFI_SERVICE);
        WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
        int ip = wifiInfo.getIpAddress();
        return ((ip & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF));
    }


    /*
    // @kakao
    public void sendMessage(final String target, final String method, final String params) {
        runOnGLThread(new Runnable() {
            public void run() {
                sendMessageBridge(target, method, params);
            }
        });
    }
    */

    /*
    // @kakao
    public void kakaoCocos2dxExtension(String params) {
        if (DEBUG) { Logger.getInstance().i("kakaoCocos2dxEntension params:" + params); }

        try {
            KakaoAndroid.getInstance().execute(AppActivity.this, params);
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    */


    //--------------------------------------------------------------------------------
    // Private Functions
    //--------------------------------------------------------------------------------

    // @google+
    private boolean isSignedIn() {
        return (mGoogleApiClient != null && mGoogleApiClient.isConnected());
    }

    /*
    // @google+, @google login
    // Call when the sign-in button is clicked
    private void signInClicked() {
        if (DEBUG) { Log.d(TAG, "signInClicked"); }

        if (isSignedIn()) {
            if (mRequestedGoogleLogin) {
                mRequestedGoogleLogin = false;
            }
            return;
        }

        // Check to see the developer who's running this sample code read the instructions :-)
        // NOTE: this check is here only because this is a sample! Don't include this
        // check in your actual production app.
        //if (!BaseGameUtils.verifySampleSetup(this, R.string.app_id,
        //        R.string.achievement_prime, R.string.leaderboard_easy)) {
        //    Log.w(TAG, "*** Warning: setup problems detected. Sign in may not work!");
        //}

        // Start the sign-in flow
        mSignInClicked = true;
        mGoogleApiClient.connect();
    }
    */

    /*
    // @google+, @google login
    // Call when the sign-out button is clicked
    private void signOutclicked() {
        if (DEBUG) { Log.d(TAG, "signOutclicked"); }

        if (!isSignedIn()) {
            if (mRequestedGoogleLogout) {
                mRequestedGoogleLogout = false;
            }
            return;
        }

        mSignInClicked = false;
        Games.signOut(mGoogleApiClient);
        mGoogleApiClient.disconnect();

        if (mRequestedGoogleLogout) {
            mRequestedGoogleLogout = false;
            sdkEventResult("googleplay_logout", "true", "");
        }
    }
    */

    // @google+
    private void showAchievementsRequested() {
        if (isSignedIn()) {
            startActivityForResult(Games.Achievements.getAchievementsIntent(mGoogleApiClient), RC_GOOGLE_ACHIEVEMENTS);
        } else {
            if (mRequestedGoogleShowAchievements) {
                mRequestedGoogleShowAchievements = false;
                sdkEventResult("googleplay_showAchievements", "false", "");
            }
        }
    }

    // @google+
    private void showLeaderboardsRequested() {
        if (isSignedIn()) {
            startActivityForResult(Games.Leaderboards.getAllLeaderboardsIntent(mGoogleApiClient), RC_GOOGLE_LEADERBOARDS);
        } else {
            if (mRequestedGoogleShowLeaderboards) {
                mRequestedGoogleShowLeaderboards = false;
                sdkEventResult("googleplay_showLeaderboards", "false", "");
            }
        }
    }

    // @google+
    private void showQuestsRequested() {
        if (isSignedIn()) {
            startActivityForResult(Games.Quests.getQuestsIntent(mGoogleApiClient, Quests.SELECT_ALL_QUESTS), RC_GOOGLE_QUESTS);
        } else {
            if (mRequestedGoogleShowQuests) {
                mRequestedGoogleShowQuests = false;
                sdkEventResult("googleplay_showQuests", "false", "");
            }
        }
    }

    // @google+
    private void updateAchievement(String achievementId, int numSteps, String fallbackString) {
        if (isSignedIn()) {
            if (numSteps > 0) {
                Games.Achievements.setSteps(mGoogleApiClient, achievementId, numSteps);
                sdkEventResult("googleplay_setAchievements", "true", "setSteps");
            } else if (numSteps == 0) {
                Games.Achievements.unlock(mGoogleApiClient, achievementId);
                sdkEventResult("googleplay_setAchievements", "true", "unlocked");
            }
        } else {
            sdkEventResult("googleplay_setAchievements", "false", "not signedin");
        }
    }

    // @google+
    private void updateLeaderboards(String leaderboardId, int finalScore, String fallbackString) {
        if (isSignedIn()) {
            Games.Leaderboards.submitScore(mGoogleApiClient, leaderboardId, finalScore);
            sdkEventResult("googleplay_setLeaderboards", "true", "");
        } else {
            sdkEventResult("googleplay_setLeaderboards", "false", "not signedin");
        }
    }

    // @google+
    private void updateEvents(String eventId, int incrementCount, String fallbackString) {
        if (isSignedIn()) {
            Games.Events.increment(mGoogleApiClient, eventId, incrementCount);
            sdkEventResult("googleplay_setEvents", "true", "");
        } else {
            sdkEventResult("googleplay_setEvents", "false", "not signedin");
        }
    }


    //--------------------------------------------------------------------------------
    // Static Functions
    //--------------------------------------------------------------------------------

    public static String getLocalIpAddress() {
        return hostIPAdress;
    }

    public static String getSDCardPath() {
        if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            String strSDCardPathString = Environment.getExternalStorageDirectory().getPath();
            return strSDCardPathString;
        }
        return null;
    }

    public static int isInstalled(String packagename) {
        try {
            PackageManager pm = s_Activity.getPackageManager();
            pm.getApplicationInfo(packagename, PackageManager.GET_META_DATA);

            return 1;
        } catch (Exception e) {

            // 패키지가 없을 경우
            e.printStackTrace();
            return 0;
        }
    }

    public static String getRunningApps() {
        JSONObject obj = new JSONObject();
        try {
            ActivityManager am = (ActivityManager)s_Activity.getSystemService(Context.ACTIVITY_SERVICE);
            List<ActivityManager.RunningAppProcessInfo> runningList = am.getRunningAppProcesses();
            for (ActivityManager.RunningAppProcessInfo name : runningList) {
                try {
                    obj.put(name.processName, 1);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            return obj.toString();
        } catch (Exception e) {

            return obj.toString();
        }
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

	public static int isWifiConnected() {
        ConnectivityManager cm = (ConnectivityManager)s_Activity.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (cm != null) {
            NetworkInfo networkInfo = cm.getActiveNetworkInfo();
            if (networkInfo != null && networkInfo.getType() == ConnectivityManager.TYPE_WIFI) {
                return 1;
            }
        }
        return 0;
    }

    public static String getFreeMemory() {
        String freeMemory = "";
        String totalMemory = getTotalMemory();

        ActivityManager am = (ActivityManager) s_Activity.getSystemService(Context.ACTIVITY_SERVICE);
        if (am != null) {
            ActivityManager.MemoryInfo memoryInfo = new ActivityManager.MemoryInfo();
            am.getMemoryInfo(memoryInfo);
            if (memoryInfo != null) {
                freeMemory = String.valueOf(memoryInfo.availMem);
            }
        }

        return freeMemory + ";" + totalMemory;
    }

    public static String getTotalMemory() {
        String str1 = "/proc/meminfo";
        String str2;
        String[] arrayOfString;
        long initial_memory = 0;

        try {
            FileReader localFileReader = new FileReader(str1);
            BufferedReader localBufferedReader = new BufferedReader(localFileReader, 8192);
            //meminfo
            str2 = localBufferedReader.readLine();
            arrayOfString = str2.split("\\s+");

            for (String num : arrayOfString) {
                Log.i(str2, num + "\t");
            }

            //total Memory
            initial_memory = Integer.valueOf(arrayOfString[1]).intValue() * 1024;
            localBufferedReader.close();
            return String.valueOf(initial_memory);
        } catch (IOException e) {
            return "";
        }
    }

    // 안드로이드 아이콘 숫자
    // 어플리케이션에 어떤 알림이 오거나 할때 기기 화면에 앱아이콘 옆에 숫자를 Badge Count라고 한다.
    public static void setBadgeCount(Context context, int count) {
        String packageName = context.getPackageName();
        String className = "com.perplelab.dragonvillage.AppActivity";

        if (DEBUG) { Log.d(TAG, "BadgeCount ## " + "packageName : " + packageName); }
        if (DEBUG) { Log.d(TAG, "BadgeCount ## " + "className : " + className); }
        if (DEBUG) { Log.d(TAG, "BadgeCount ## " + "badgeCount : " + count); }

        Intent intent = new Intent("android.intent.action.BADGE_COUNT_UPDATE");
        intent.putExtra("badge_count", count);
        intent.putExtra("badge_count_package_name", packageName);
        intent.putExtra("badge_count_class_name", className);
        context.sendBroadcast(intent);
    }

    // Native코드로부터 전달받은 이벤트(lua -> cocos(c++) -> android(java))
    public static void receiveEventFromNative(String param1, String param2) {
        final String _param1 = param1;
        final String _param2 = param2;

        if (DEBUG) { Log.d(TAG, "receiveEventFromNative()" + _param1); }
        if (DEBUG) { Log.d(TAG, "receiveEventFromNative()" + _param2); }

        s_Activity.mAppHandler.post(new Runnable() {
            public void run() {
                if (_param1.equals("app_terminate")) {
                    android.os.Process.killProcess(android.os.Process.myPid());
                } else if (_param1.equals("goto_web")) {
                    Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri
                            .parse(_param2));
                    s_Activity.startActivity(browserIntent);
                } else if (_param1.equals("alert")) {
                    String[] array = _param2.split(";");
                    new AlertDialog.Builder(s_Activity).setTitle(array[0])
                            .setMessage("" + array[1])
                            .setPositiveButton(android.R.string.ok, null)
                            .create().show();
                } else if (_param1.equals("send_email")) {
                    String[] array = _param2.split(";");
                    String[] tos = { array[0] };

                    Intent it = new Intent(Intent.ACTION_SEND);
                    it.putExtra(Intent.EXTRA_EMAIL, tos);
                    it.putExtra(Intent.EXTRA_SUBJECT, array[1]);
                    it.putExtra(Intent.EXTRA_TEXT, array[2]);
                    it.setType("text/plain");
                    s_Activity.startActivity(Intent.createChooser(it,
                            "Choose Email Client"));
                } else if (_param1.equals("goto_store")) {
                    String appName = "com.perplelab.dragonvillage";
                    try {
                        s_Activity.startActivity(new Intent(Intent.ACTION_VIEW,
                                Uri.parse("market://details?id=" + appName)));
                    } catch (android.content.ActivityNotFoundException anfe) {
                        s_Activity.startActivity(new Intent(
                                Intent.ACTION_VIEW,
                                Uri.parse("http://play.google.com/store/apps/details?id="
                                        + appName)));
                    }
                } else if (_param1.equals("local_noti_add")) {
                    try
                    {
                        String[] array = _param2.split(";");
                        String type = array[0];
                        int sec = Integer.parseInt(array[1]);
                        String msg = array[2];

                        boolean bAlert = false;
                        if (array.length > 3) {
                            if (array[3].equals("alert")) {
                                bAlert = true;
                            }
                        }

                        PerplelabIntentFactory.addNoti(type, sec, msg, bAlert);
                    }
                    catch (Exception e)
                    {
                        e.printStackTrace();
                    }
                } else if (_param1.equals("local_noti_setlinkUrl")) {
                    try
                    {
                        String[] array = _param2.split(";");
                        String linkTitle = array[0];
                        String linkUrl = array[1];
                        String cafeUrl = array[2];
                        PerplelabIntentFactory.setLinkUrlInfo(linkTitle, linkUrl, cafeUrl);
                    }
                    catch (Exception e)
                    {
                        e.printStackTrace();
                    }
                } else if (_param1.equals("local_noti_setColor")) {
                    try
                    {
                        String[] array = _param2.split(";");
                        String bgColor = array[0];
                        String titleColor = array[1];
                        String messageColor = array[2];
                        PerplelabIntentFactory.setColor(bgColor, titleColor, messageColor);
                    }
                    catch (Exception e)
                    {
                        e.printStackTrace();
                    }
                } else if (_param1.equals("local_noti_start")) {
                    Intent intent = PerplelabIntentFactory.makeIntentService(s_Activity);
                    s_Activity.startService(intent);

                } else if (_param1.equals("local_noti_cancel")) {
                    PerplelabIntentFactory.clear();
                    Intent intent = PerplelabIntentFactory.makeIntentService(s_Activity);
                    s_Activity.stopService(intent);
                }
            }
        });
    }

    // @google+, @adbrix, @tapjoy, @partytrack, @moloco
    public static void sdkEvent(String id, String arg0, String arg1) {
        if (DEBUG) { Log.d(TAG, "sdkEvent: " + id + "," + arg0 + "," + arg1); }

        final String _id = id;
        final String _arg0 = arg0;
        final String _arg1 = arg1;

        s_Activity.mAppHandler.post(new Runnable() {
            public void run() {
                if (_id.equals("clipboard_setText")) {
                    //android.text.ClipboardManager clipboard = (android.text.ClipboardManager)s_Activity.getSystemService(Context.CLIPBOARD_SERVICE);
                    //clipboard.setText(_arg0);
                    android.content.ClipboardManager clipboard = (android.content.ClipboardManager)s_Activity.getSystemService(Context.CLIPBOARD_SERVICE);
                    android.content.ClipData clip = android.content.ClipData.newPlainText("PatiSDK GuestAuthCode",_arg0);
                    clipboard.setPrimaryClip(clip);
                    sdkEventResult(_id, "true", "");
                } else if (_id.equals("clipboard_getText")) {
                    String clipText = getClipText();
                    if (clipText == null) {
                        sdkEventResult(_id, "false", "");
                    } else {
                        sdkEventResult(_id, "true", clipText);
                    }
                }
                /*
                // @google login
                else if (_id.equals("googleplay_login")) {
                    s_Activity.mRequestedGoogleLogin = true;
                    s_Activity.signInClicked();
                } else if (_id.equals("googleplay_logout")) {
                    s_Activity.mRequestedGoogleLogout = true;
                    s_Activity.signOutclicked();
                } else if (_id.equals("googleplay_isSignedIn")) {
                    if (s_Activity.isSignedIn()) {
                        sdkEventResult(_id, "true", "");
                    } else {
                        sdkEventResult(_id, "false", "");
                    }
                }
                */
                else if (_id.equals("googleplay_checkLogin")) {
                    sdkEventResult(_id, "true", "");
                } else if (_id.equals("googleplay_showAchievements")) {
                    s_Activity.mRequestedGoogleShowAchievements = true;
                    s_Activity.showAchievementsRequested();
                } else if (_id.equals("googleplay_showLeaderboards")) {
                    s_Activity.mRequestedGoogleShowLeaderboards = true;
                    s_Activity.showLeaderboardsRequested();
                } else if (_id.equals("googleplay_showQuests")) {
                    s_Activity.mRequestedGoogleShowQuests = true;
                    s_Activity.showQuestsRequested();
                } else if (_id.equals("googleplay_setAchievements")) {
                    String index = _arg0;
                    int count = Integer.parseInt(_arg1);
                    s_Activity.updateAchievement(index, count, "");
                } else if (_id.equals("googleplay_setLeaderboards")) {
                    String index = _arg0;
                    int score = Integer.parseInt(_arg1);
                    s_Activity.updateLeaderboards(index, score, "");
                } else if (_id.equals("googleplay_setEvents")) {
                    String index = _arg0;
                    int count = Integer.parseInt(_arg1);
                    s_Activity.updateEvents(index, count, "");
                } else if (_id.equals("adbrix_userInfo")) {
                    if (!_arg0.equals("")) {
                        String[] array = _arg0.split(";");
                        if (array.length > 0) {
                            IgawAdbrix.setUserId(array[0]);
                        }
                        if (array.length > 1) {
                            IgawAdbrix.setAge(Integer.parseInt(array[1]));
                        }
                        if (array.length > 2) {
                            if (array[2].equals("male")) {
                                IgawAdbrix.setGender(IgawCommon.Gender.MALE);
                            } else if (array[2].equals("female")) {
                                IgawAdbrix.setGender(IgawCommon.Gender.FEMALE);
                            }
                        }
                    }
                } else if (_id.equals("adbrix_firstTimeExperience")) {
                    if (_arg1.equals("")) {
                        IgawAdbrix.firstTimeExperience(_arg0);
                    } else {
                        IgawAdbrix.firstTimeExperience(_arg0, _arg1);
                    }
                } else if (_id.equals("adbrix_retention")) {
                    if (_arg1.equals("")) {
                        IgawAdbrix.retention(_arg0);
                    } else {
                        IgawAdbrix.retention(_arg0, _arg1);
                    }
                } else if (_id.equals("adbrix_buy")) {
                    if (_arg1.equals("")) {
                        IgawAdbrix.buy(_arg0);
                    } else {
                        IgawAdbrix.buy(_arg0, _arg1);
                    }
                } else if (_id.equals("adbrix_customCohort")) {
                    if (_arg0.equals("COHORT_1")) {
                        IgawAdbrix.setCustomCohort(CohortVariable.COHORT_1, _arg1);
                    } else if (_arg0.equals("COHORT_2")) {
                        IgawAdbrix.setCustomCohort(CohortVariable.COHORT_2, _arg1);
                    } else if (_arg0.equals("COHORT_3")) {
                        IgawAdbrix.setCustomCohort(CohortVariable.COHORT_3, _arg1);
                    }
                } else if (_id.equals("5rocks_userInfo")) {
                    if (!_arg0.equals("")) {
                        String[] array = _arg0.split(";");
                        if (array.length > 0) {
                            Tapjoy.setUserID(array[0]);
                        }
                        if (array.length > 1) {
                            Tapjoy.setUserLevel(Integer.parseInt(array[1]));
                        }
                        if (array.length > 2) {
                            Tapjoy.setUserFriendCount(Integer.parseInt(array[2]));
                        }
                    }
                } else if (_id.equals("5rocks_trackEvent")) {
                    if (!_arg0.equals("")) {
                        String[] array = _arg0.split(";");
                        if (array.length == 4) {
                            // category;name;parameter1;parameter2
                            Tapjoy.trackEvent(array[0], array[1], array[2], array[3]);
                        } else if (array.length == 5) {
                            // category;name;parameter1;parameter2;value
                            Tapjoy.trackEvent(array[0], array[1], array[2], array[3], Long.parseLong(array[4]));
                        } else if (array.length == 6) {
                            // category;name;parameter1;parameter2;valueName;value
                            Tapjoy.trackEvent(array[0], array[1], array[2], array[3], array[4], Long.parseLong(array[5]));
                        } else if (array.length == 8) {
                            // category;name;parameter1;parameter2;value1Name;value1;value2Name;value2
                            Tapjoy.trackEvent(array[0], array[1], array[2], array[3], array[4], Long.parseLong(array[5]), array[6], Long.parseLong(array[7]));
                        } else if (array.length == 10) {
                            // category;name;parameter1;parameter2;value1Name;value1;value2Name;value2;value3Name;value3
                            Tapjoy.trackEvent(array[0], array[1], array[2], array[3], array[4], Long.parseLong(array[5]), array[6], Long.parseLong(array[7]), array[8], Long.parseLong(array[9]));
                        }
                    }
                } else if (_id.equals("5rocks_trackPurchase")) {
                    if (!_arg0.equals("")) {
                        String[] array = _arg0.split(";");
                        if (array.length == 3) {
                            // productId;currencyCode;price
                            Tapjoy.trackPurchase(array[0], array[1], Double.parseDouble(array[2]), null);
                        } else if (array.length == 4) {
                            // productId;currencyCode;price;campaignId
                            Tapjoy.trackPurchase(array[0], array[1], Double.parseDouble(array[2]), array[3]);
                        }
                    }
                } else if (_id.equals("5rocks_customCohort")) {
                    Tapjoy.setUserCohortVariable(Integer.parseInt(_arg0), _arg1);
                } else if (_id.equals("5rocks_appDataVersion")) {
                    Tapjoy.setAppDataVersion(_arg0);
                } else if (_id.equals("partytrack_payment")) {
                    if (!_arg0.equals("")) {
                        String[] array = _arg0.split(";");
                        if (array.length == 3) {
                            // itemName, itemPrice, itemPriceCurrency, itemNum
                            Track.payment(array[0], Float.parseFloat(array[1]), array[2], 1);
                        } else if (array.length == 4) {
                            // itemName, itemPrice, itemPriceCurrency, itemNum
                            Track.payment(array[0], Float.parseFloat(array[1]), array[2], Integer.parseInt(array[3]));
                        }
                    }
                } else if (_id.equals("partytrack_event")) {
                    String eventId = _arg0;
                    Track.event(eventId);
                } else if (_id.equals("moloco_event")) {
                    String eventName = _arg0;
                    String eventValue = _arg1;
                    s_Activity.mTracker.event(eventName, eventValue);
                } else if (_id.equals("moloco_eventSpatial")) {
                    String[] arrayList0 = _arg0.split(";");
                    String eventName = arrayList0[0];
                    String eventValue = "";
                    if (arrayList0.length > 1) {
                        eventValue = arrayList0[1];
                    }
                    String[] arrayList1 = _arg1.split(";");
                    double x = Double.parseDouble(arrayList1[0]);
                    double y = Double.parseDouble(arrayList1[1]);
                    double z = Double.parseDouble(arrayList1[2]);
                    s_Activity.mTracker.eventSpatial(eventName, x, y, z, eventValue);
                }
            }
        });
    }

    public static String getClipText() {
        android.content.ClipboardManager clipboard = (android.content.ClipboardManager)s_Activity.getSystemService(Context.CLIPBOARD_SERVICE);
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

    private static void sdkEventResult(final String id, final String ret, final String info) {
        if (DEBUG) { Log.d(TAG, "sdkEventResult: " + id + "," + ret + "," + info); }

        s_Activity.runOnGLThread(new Runnable() {
            public void run() {
                nativeSDKEventResult(id, ret, info);
            }
        });
    }

    //--------------------------------------------------------------------------------
    // JNI Bridge Functions
    //--------------------------------------------------------------------------------

    private static native boolean nativeIsLandScape();
    private static native boolean nativeIsDebug();
    private static native boolean nativeIsTestMode();
    private static native int nativeLoginPlatform();

    // @kakao
    //private native void initJNIBridge();
    //private native void sendMessageBridge(String target, String method, String params);

    private static native void nativeSDKEventResult(String id, String ret, String info);

}
