package com.perplelab.unityads;

import com.perplelab.PerpleSDK;
import com.perplelab.PerpleLog;

import com.unity3d.ads.IUnityAdsListener;
import com.unity3d.ads.UnityAds;
import com.unity3d.ads.UnityAds.FinishState;
import com.unity3d.ads.UnityAds.UnityAdsError;
import com.unity3d.ads.metadata.MediationMetaData;
import com.unity3d.ads.metadata.PlayerMetaData;

import android.app.Activity;
import android.os.Handler;

import org.json.JSONException;
import org.json.JSONObject;

public class PerpleUnityAds implements IUnityAdsListener {
    private static final String LOG_TAG = "PerpleSDK UnityAds";

    private Handler mAppHandler;
    private PerpleUnityAdsCallback mCallback;
    private boolean mIsDebug;
    private String mGameId;

    public PerpleUnityAds() {}

    public void init(String gameId, boolean isDebug) {
        mGameId = gameId;
        mIsDebug = isDebug;
        mAppHandler = new Handler();
    }

    public void start(boolean isTestMode, String metaData, PerpleUnityAdsCallback callback) {
        mCallback = callback;

        if (UnityAds.isInitialized()) {
            if (mCallback != null) {
                mCallback.onError("ALREADY_INITIALIZED", "");
            }
            return;
        }

        if (!metaData.isEmpty()) {
            String name = "";
            String version = "";
            try {
                JSONObject jsonObj = new JSONObject(metaData);
                name = (String)jsonObj.get("name");
                version = (String)jsonObj.get("version");
            } catch (JSONException e) {
                e.printStackTrace();
            }

            MediationMetaData mediationMetaData = new MediationMetaData(PerpleSDK.getInstance().getMainActivity());
            mediationMetaData.setName(name);
            mediationMetaData.setVersion(version);
            mediationMetaData.commit();
        }

        UnityAds.initialize(PerpleSDK.getInstance().getMainActivity(), mGameId, this, isTestMode);
        UnityAds.setDebugMode(mIsDebug);
    }

    public void show(String placementId, String metaData) {
        if (!UnityAds.isInitialized()) {
            PerpleLog.e(LOG_TAG, "UnityAds is not initialized.");
            if (mCallback != null) {
                mCallback.onError("NOT_INITIALIZED", "");
            }
            return;
        }

        String serverId = "";
        String ordinalId = "";
        if (!metaData.isEmpty()) {
            try {
                JSONObject jsonObj = new JSONObject(metaData);
                serverId = (String)jsonObj.get("serverId");
                ordinalId = (String)jsonObj.get("ordinalId");
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        Activity showActivity = PerpleSDK.getInstance().getMainActivity();
        if (placementId.isEmpty()) {
            if (UnityAds.isReady()) {

                if (serverId != null && !serverId.isEmpty()) {
                    PlayerMetaData playerMetaData = new PlayerMetaData(showActivity);
                    playerMetaData.setServerId(serverId);
                    playerMetaData.commit();
                }

                if (ordinalId != null && !ordinalId.isEmpty()) {
                    MediationMetaData mediationMetaData = new MediationMetaData(showActivity);
                    mediationMetaData.setOrdinal(Integer.parseInt(ordinalId));
                    mediationMetaData.commit();
                }

                UnityAds.show(showActivity);
            } else {
                if (mCallback != null) {
                    mCallback.onError("NOT_READY", "");
                }
            }
        } else {
            if (UnityAds.isReady(placementId)) {

                if (serverId != null && !serverId.isEmpty()) {
                    PlayerMetaData playerMetaData = new PlayerMetaData(showActivity);
                    playerMetaData.setServerId(serverId);
                    playerMetaData.commit();
                }

                if (ordinalId != null && !ordinalId.isEmpty()) {
                    MediationMetaData mediationMetaData = new MediationMetaData(showActivity);
                    mediationMetaData.setOrdinal(Integer.parseInt(ordinalId));
                    mediationMetaData.commit();
                }

                UnityAds.show(showActivity, placementId);
            } else {
                if (mCallback != null) {
                    mCallback.onError("NOT_READY", "");
                }
            }
        }
    }

    @Override
    public void onUnityAdsError(final UnityAdsError error, final String message) {
        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mCallback != null) {
                    mCallback.onError(error.toString(), message);
                }
            }
        });
    }

    @Override
    public void onUnityAdsFinish(final String placementId, final FinishState result) {
        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mCallback != null) {
                    mCallback.onFinish(placementId, result.toString());
                }
            }
        });
    }

    @Override
    public void onUnityAdsReady(final String placementId) {
        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mCallback != null) {
                    mCallback.onReady(placementId);
                }
            }
        });
    }

    @Override
    public void onUnityAdsStart(final String placementId) {
        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mCallback != null) {
                    mCallback.onStart(placementId);
                }
            }
        });
    }
}
