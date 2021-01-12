package com.perplelab.facebook;

import android.app.Activity;
import com.facebook.ads.*;

public class FBRewardedVideoAd {
    private static final String LOG_TAG = "FB_REWARDED_VIDEO_AD";
    private static final Integer MAX_TRY_COUNT = 10;

    private boolean mIsAdProcessing;
    private boolean mHasReward;
    private Integer mTryLoadingCount;
    private String mCurPlacementID;
    private AdCallback mCallback;

    private com.facebook.ads.RewardedVideoAd mRewardedVideoAd;
    private RewardedVideoAdListener mRewardedVideoListener;

    private final Activity curActivity;

    private OnLogMessageListener onLogMessageListener;

    public interface OnLogMessageListener {
        void onLogMessage(String tag, String msg);
    }

    // constructor
    public FBRewardedVideoAd(Activity activity)   {
        logMessage(LOG_TAG, "Initializing Rewarded Video Ad");
        curActivity = activity;
        mHasReward = false;
        mTryLoadingCount = 0;

        InitVideoListener();
    }

    // 게임에 보낼 콜백
    public void setResultCallBack(AdCallback callback) {
        this.mCallback = callback;
    }

    public void addLogListener(OnLogMessageListener listener)
    {
        // 로그를 기록할 콜백 등록
        this.onLogMessageListener = listener;
    }

    private void logMessage(String tag, String msg)
    {
        if (onLogMessageListener == null)
            return;

        onLogMessageListener.onLogMessage(tag, msg);
    }
    
    private void InitVideoListener()
    {
        if (mRewardedVideoListener != null)
            return;

        mRewardedVideoListener = new RewardedVideoAdListener() {
            @Override
            public void onError(Ad ad, AdError error) {
                // Rewarded video ad failed to load
                logMessage(LOG_TAG, "Rewarded video ad failed to load: " + error.getErrorMessage());

                if (mCallback != null) {
                    mCallback.onFail("fail to load.");
                }

                logMessage(LOG_TAG, "error code : " + error.getErrorCode());
                onLoadFail(error.getErrorCode());

                logMessage(LOG_TAG, "Reward based video ad retry to load.");
                loadRewardedVideoAd(mCurPlacementID);

                mIsAdProcessing = false;
            }

            @Override
            public void onAdLoaded(Ad ad) {
                // Rewarded video ad is loaded and ready to be displayed
                logMessage(LOG_TAG, "Rewarded video ad is loaded and ready to be displayed!");

                if (mCallback != null) {
                    mCallback.onReceive("Reward based video ad is received.");
                }

                mIsAdProcessing = true;
            }

            @Override
            public void onAdClicked(Ad ad) {
                // Rewarded video ad clicked
                logMessage(LOG_TAG, "Rewarded video ad clicked!");
            }

            @Override
            public void onLoggingImpression(Ad ad) {
                // Rewarded Video ad impression - the event will fire when the
                // video starts playing
                logMessage(LOG_TAG, "Rewarded video ad impression logged!");
            }

            @Override
            public void onRewardedVideoCompleted() {
                // Rewarded Video View Complete - the video has been played to the end.
                // You can use this event to initialize your reward
                logMessage(LOG_TAG, "Rewarded video completed!");

                // Call method to give reward
                mHasReward = true;
                mIsAdProcessing = false;
            }

            @Override
            public void onRewardedVideoClosed() {
                // The Rewarded Video ad was closed - this can occur during the video
                // by closing the app, or closing the end card.
                logMessage(LOG_TAG, "Rewarded video ad closed!");

                // work callback
                if (mCallback != null) {
                    if (mHasReward) {
                        mCallback.onFinish("reward based video ad is successfully finished.");
                    } else {
                        mCallback.onCancel("reward based video ad is canceled.");
                    }
                }

                mHasReward = false;
                mIsAdProcessing = false;
            }
        };
    }


    public void loadRewardedVideoAd(final String placementID)
    {
        mTryLoadingCount++;

        if (mTryLoadingCount > MAX_TRY_COUNT) {
            logMessage(LOG_TAG, "loadRewardedVideoAd :: Repeated retries failed.");
            return;
        }

        if (placementID == null || placementID.isEmpty()) {
            logMessage(LOG_TAG, "loadRewardedVideoAd :: placementID is null or empty.");
            return;
        }
        
        if (mIsAdProcessing)
        {
            // 로드된 광고가 있으면 차분히 기다리기
            logMessage(LOG_TAG, "loadRewardedVideoAd :: Already loaded.");
            return;
        }
            
        curActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mCurPlacementID = placementID;

                final RewardedVideoAd rewardedAd = CreateRewardedVideoAd(mCurPlacementID);

                if (rewardedAd != null)
                {
                    mIsAdProcessing = true;

                    logMessage(LOG_TAG, "Start loading rewarded ad...");
                    rewardedAd.loadAd(rewardedAd.buildLoadAdConfig().withAdListener(mRewardedVideoListener).build());
                }
            }
        });
    }

    public void show(final String placementID)
    {
        if (placementID == null || placementID.isEmpty()) {
            mCallback.onError(
                    PerpleFacebookAudienceNetwork.getErrorInfo(PerpleFacebookAudienceNetwork.ERROR_INVALIDPLACEMENTID,
                    PerpleFacebookAudienceNetwork.ERROR_NONE, "Placement ID is null or empty...."));
            return;
        }

        mTryLoadingCount = 0;

        curActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                // 들어온 순간 성공이든 실패든 show들어오면 본걸로 처리.
                // 불안정한 객체는 바로 버리고 새로 만드는것이 낫다.
                mIsAdProcessing = false;
                mCurPlacementID = placementID;
                final RewardedVideoAd rewardedAd = mRewardedVideoAd;


                if (rewardedAd == null) {
                    logMessage(LOG_TAG, "show ad rewardedAd Detected");
                    if (mCallback != null) {
                        mCallback.onError(
                                PerpleFacebookAudienceNetwork.getErrorInfo(PerpleFacebookAudienceNetwork.ERROR_INVALIDPLACEMENTID,
                                        PerpleFacebookAudienceNetwork.ERROR_NONE,
                                        "Invalid placement ID... : " + placementID));

                    }
                    return;
                }

                if (rewardedAd.isAdLoaded()) {
                    logMessage(LOG_TAG, "show : " + placementID);
                    rewardedAd.show();
                }
                else {
                    logMessage(LOG_TAG, "The rewarded ad wasn't loaded yet.");
                    if (mCallback != null) {
                        mCallback.onError(
                                PerpleFacebookAudienceNetwork.getErrorInfo(PerpleFacebookAudienceNetwork.ERROR_NOTLOADEDAD,
                                        PerpleFacebookAudienceNetwork.ERROR_NONE,
                                        "Ad is not loaded."));
                    }
                }
            }}
        );
    }


    // Create a new rewarded video ad instance.
    private RewardedVideoAd CreateRewardedVideoAd(String placementID)
    {
        if (mRewardedVideoAd != null)
        {
            mRewardedVideoAd.destroy();
            mRewardedVideoAd = null;
        }

        mRewardedVideoAd = new RewardedVideoAd(curActivity, placementID);

        return mRewardedVideoAd;
    }

    private void onLoadFail(int errorCode) {
        logMessage(LOG_TAG, "load error, code : " + errorCode);

        switch (errorCode){
            case (PerpleFacebookAudienceNetwork.ERROR_CODE_SERVER_ERROR):
                // 잘못된 요청이므로 더이상 요청하지 않도록 함
                mTryLoadingCount += MAX_TRY_COUNT;
                break;
            case (PerpleFacebookAudienceNetwork.ERROR_CODE_INTERNAL_ERROR) :
            case (PerpleFacebookAudienceNetwork.ERROR_CODE_NETWORK_ERROR) :
            case (PerpleFacebookAudienceNetwork.ERROR_CODE_NO_FILL) :
            default:
                break;
        }

        if (mCallback != null) {
            mCallback.onFail(
                    PerpleFacebookAudienceNetwork.getErrorInfo(PerpleFacebookAudienceNetwork.ERROR_FAILLOAD,
                    String.valueOf(errorCode),""));
        }
    }


    // ..method
    public void onResume() {

    }

    public void onPause() {

    }

    public void onDestroy() {

    }
    
    
    
}
