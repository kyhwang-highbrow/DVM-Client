package com.perplelab.adcolony;

import com.adcolony.sdk.*;
import com.perplelab.PerpleSDK;

import android.app.Activity;
import org.json.JSONObject;
import java.util.HashMap;

public class PerpleAdColony {
    private static final String LOG_TAG = "PerpleSDK AdColony";

    private String mAppId;
    private HashMap<String, AdColonyInterstitial> mZones;
    private PerpleAdColonyCallback mCallback;

    public PerpleAdColony() {}

    public void init(String appId) {
        mAppId = appId;
        mZones = new HashMap<String, AdColonyInterstitial>();
    }

    public void start(String zoneIds, String userId) {
        String[] zoneIdsArray = zoneIds.split(";");

        Activity mainActvity = PerpleSDK.getInstance().getMainActivity();

        if (userId != null && !userId.isEmpty()) {
            /** Get current AdColonyAppOptions and change user id */
            AdColonyAppOptions appOptions = AdColony.getAppOptions()
                    .setUserID(userId);

            /** Pass options with user id set with configure */
            if (zoneIdsArray.length == 1) {
                AdColony.configure(mainActvity, appOptions, mAppId, zoneIdsArray[0]);
            } else if (zoneIdsArray.length == 2) {
                AdColony.configure(mainActvity, appOptions, mAppId, zoneIdsArray[0], zoneIdsArray[1]);
            } else if (zoneIdsArray.length == 3) {
                AdColony.configure(mainActvity, appOptions, mAppId, zoneIdsArray[0], zoneIdsArray[1], zoneIdsArray[2]);
            } else if (zoneIdsArray.length == 4) {
                AdColony.configure(mainActvity, appOptions, mAppId, zoneIdsArray[0], zoneIdsArray[1], zoneIdsArray[2], zoneIdsArray[3]);
            } else if (zoneIdsArray.length == 5) {
                AdColony.configure(mainActvity, appOptions, mAppId, zoneIdsArray[0], zoneIdsArray[1], zoneIdsArray[2], zoneIdsArray[3], zoneIdsArray[4]);
            }
        } else {
            if (zoneIdsArray.length == 1) {
                AdColony.configure(mainActvity, mAppId, zoneIdsArray[0]);
            } else if (zoneIdsArray.length == 2) {
                AdColony.configure(mainActvity, mAppId, zoneIdsArray[0], zoneIdsArray[1]);
            } else if (zoneIdsArray.length == 3) {
                AdColony.configure(mainActvity, mAppId, zoneIdsArray[0], zoneIdsArray[1], zoneIdsArray[2]);
            } else if (zoneIdsArray.length == 4) {
                AdColony.configure(mainActvity, mAppId, zoneIdsArray[0], zoneIdsArray[1], zoneIdsArray[2], zoneIdsArray[3]);
            } else if (zoneIdsArray.length == 5) {
                AdColony.configure(mainActvity, mAppId, zoneIdsArray[0], zoneIdsArray[1], zoneIdsArray[2], zoneIdsArray[3], zoneIdsArray[4]);
            }
        }

        AdColonyRewardListener listener = new AdColonyRewardListener() {
            @Override
            public void onReward(AdColonyReward reward) {
                /** Query the reward object for information here */
                if (mCallback != null) {
                    try {
                        JSONObject obj = new JSONObject();
                        obj.put("zoneID", reward.getZoneID());
                        obj.put("rewardName", reward.getRewardName());
                        obj.put("rewardAmount", reward.getRewardAmount());
                        mCallback.onReward(obj.toString());
                    } catch (Exception e) {
                        mCallback.onError("JSON_EXCEPTION");
                    }
                }
            }
        };

        /** Set reward listener for your app to be alerted of reward events */
        AdColony.setRewardListener(listener);
    }

    public void setUserId(String userId) {
        /** Get current AdColonyAppOptions and change user id */
        AdColonyAppOptions appOptions = AdColony.getAppOptions()
                .setUserID(userId);

        /** Send new information to AdColony */
        AdColony.setAppOptions(appOptions);
    }

    public void request(String zoneId, PerpleAdColonyCallback callback) {
        mCallback = callback;
        final String _zoneId = zoneId;
        AdColonyInterstitialListener listener = new AdColonyInterstitialListener() {
            @Override
            public void onRequestFilled(AdColonyInterstitial ad) {
                /** Store and use this ad object to show your ad when appropriate */
                mZones.put(_zoneId, ad);
                if (mCallback != null) {
                    mCallback.onReady(_zoneId);
                }
            }
        };

        AdColony.requestInterstitial(zoneId, listener);
    }

    public void show(String zoneId) {
        AdColonyInterstitial ad = mZones.get(zoneId);
        if (ad != null) {
            mZones.remove(zoneId);
            ad.show();
        }
    }
}
