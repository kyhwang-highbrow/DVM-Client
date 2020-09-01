package com.perplelab.admob;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.reward.RewardItem;
import com.google.android.gms.ads.reward.RewardedVideoAd;
import com.google.android.gms.ads.reward.RewardedVideoAdListener;
import com.perplelab.PerpleSDK;
import com.perplelab.PerpleLog;

import static com.google.android.gms.ads.AdRequest.ERROR_CODE_INTERNAL_ERROR;
import static com.google.android.gms.ads.AdRequest.ERROR_CODE_INVALID_REQUEST;
import static com.google.android.gms.ads.AdRequest.ERROR_CODE_NETWORK_ERROR;
import static com.google.android.gms.ads.AdRequest.ERROR_CODE_NO_FILL;

public class PerpleAdMobRewardedVideoAd {
    private static final String LOG_TAG = "PerpleSDK AdMob Rewarded Video Ad";
    private static final Integer MAX_TRY_COUNT = 10;

    private boolean mHasReward;
    private Integer mTryLoadingCount;
    private String mCurrAdUnitId;
    private PerpleAdMobCallback mCallback;

    private RewardedVideoAd mRewardedVideoAd;

    // constructor
    public PerpleAdMobRewardedVideoAd() {
        PerpleLog.d(LOG_TAG, "Initializing AdMob Rewarded Video Ad");

        mHasReward = false;
        mTryLoadingCount = 0;

        PerpleSDK.getInstance().getMainActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                // Use an activity context to get the rewarded video instance.
                mRewardedVideoAd = MobileAds.getRewardedVideoAdInstance(PerpleSDK.getInstance().getMainActivity());
                setRewardedVideoAdListener();
            }}
        );
    }

    // APIs
    public void loadRewardedVideoAd() {
        PerpleSDK.getInstance().getMainActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                PerpleLog.d(LOG_TAG, "loadRewardedVideoAd");
                mTryLoadingCount++;
                if (mTryLoadingCount > MAX_TRY_COUNT) {
                    PerpleLog.w(LOG_TAG, "loadRewardedVideoAd is Failed. Check ad unit ids");
                    return;
                }
                if (mCurrAdUnitId == null || mCurrAdUnitId.equals("")) {
                    PerpleLog.w(LOG_TAG, "loadRewardedVideoAd is Failed. Ad unit id is null");
                    return;
                }

                if (!mRewardedVideoAd.isLoaded()) {
                    PerpleLog.d(LOG_TAG, "loadRewardedVideoAd id : " + mCurrAdUnitId);
                    loadRewardedVideoAdUnit(mCurrAdUnitId);
                }
        }});
    }

    public void loadRewardedVideoAd(final String adUnitId) {
        PerpleSDK.getInstance().getMainActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                loadRewardedVideoAdUnit(adUnitId);
            }
        });
    }

    private void loadRewardedVideoAdUnit(final String adUnitId) {
        mRewardedVideoAd.loadAd(adUnitId, new AdRequest.Builder().build());
    }

    public void setResultCallBack(PerpleAdMobCallback callback) {
        this.mCallback = callback;
    }

    public void show(final String adUnitId) {
        mTryLoadingCount = 0;
        PerpleSDK.getInstance().getMainActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (adUnitId == null || adUnitId.equals("")) {
                    mCallback.onError(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_ADMOB_INVALIDADUNITID, "There is no ad unit id to show."));
                    return;
                }
                mCurrAdUnitId = adUnitId;
                RewardedVideoAd rewardedVideoAd = mRewardedVideoAd;

                if (rewardedVideoAd == null) {
                    if (mCallback != null) {
                        mCallback.onError(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_ADMOB_INVALIDADUNITID, "Invalid ad unit id : " + adUnitId));
                    }
                    return;
                }

                if (rewardedVideoAd.isLoaded()) {
                    PerpleLog.d(LOG_TAG, "show : " + adUnitId);
                    mRewardedVideoAd.show();
                } else {
                    loadRewardedVideoAd();
                    if (mCallback != null) {
                        mCallback.onError(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_ADMOB_NOTLOADEDAD, "Ad is not loaded."));
                    }
                }
            }}
        );
    }

    private void onLoadFail(int errorCode) {
        PerpleLog.w(LOG_TAG, "load error, code : " + errorCode);

        switch (errorCode){
            case (ERROR_CODE_INVALID_REQUEST):
                // 잘못된 요청이므로 더이상 요청하지 않도록 함
                mTryLoadingCount += MAX_TRY_COUNT;
                break;
            case (ERROR_CODE_INTERNAL_ERROR) :
                break;
            case (ERROR_CODE_NETWORK_ERROR) :
                break;
            case (ERROR_CODE_NO_FILL) :
                break;
            default:
                break;
        }

        if (mCallback != null) {
            mCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_ADMOB_FAILLOAD, String.valueOf(errorCode),""));
        }
    }

    // ..method
    public void onResume() {
        if (mRewardedVideoAd != null) {
            mRewardedVideoAd.resume(PerpleSDK.getInstance().getMainActivity());
        }
    }

    public void onPause() {
        if (mRewardedVideoAd != null) {
            mRewardedVideoAd.pause(PerpleSDK.getInstance().getMainActivity());
        }
    }

    public void onDestroy() {
        if (mRewardedVideoAd != null) {
            mRewardedVideoAd.destroy(PerpleSDK.getInstance().getMainActivity());
        }
    }


    private void setRewardedVideoAdListener() {
        mRewardedVideoAd.setRewardedVideoAdListener(new RewardedVideoAdListener() {
            @Override
            public void onRewardedVideoAdLoaded() {
                PerpleLog.v(LOG_TAG, "onRewardedVideoAdLoaded");
                if (mCallback != null) {
                    mCallback.onReceive("Reward based video ad is received.");
                }
                mCurrAdUnitId = null;
            }

            @Override
            public void onRewardedVideoAdOpened() {
                PerpleLog.v(LOG_TAG, "onRewardedVideoAdOpened");
                if (mCallback != null) {
                    mCallback.onOpen("Reward based video ad open.");
                }
            }

            @Override
            public void onRewardedVideoStarted() {
                PerpleLog.v(LOG_TAG, "onRewardedVideoStarted");
                if (mCallback != null) {
                    mCallback.onStart("Reward based video ad start.");
                }
            }

            @Override
            public void onRewardedVideoAdClosed() {
                PerpleLog.v(LOG_TAG, "onRewardedVideoAdClosed");

                // work callback
                if (mCallback != null) {
                    if (mHasReward) {
                        mCallback.onFinish("reward based video ad is successfully finished.");
                    } else {
                        mCallback.onCancel("reward based video ad is canceled.");
                    }
                }
                mHasReward = false;
            }

            @Override
            public void onRewarded(RewardItem rewardItem) {
                PerpleLog.d(LOG_TAG, "onRewarded - currency: " + rewardItem.getType() + "  amount: " + rewardItem.getAmount());
                // Reward the user.
                mHasReward = true;
            }

            @Override
            public void onRewardedVideoAdLeftApplication() {
                PerpleLog.v(LOG_TAG, "onRewardedVideoAdLeftApplication");
            }

            @Override
            public void onRewardedVideoAdFailedToLoad(int errorCode) {
                PerpleLog.v(LOG_TAG, "onRewardedVideoAdFailedToLoad");

                if (mCallback != null) {
                    mCallback.onFail("fail to load.");
                }

                PerpleLog.d(LOG_TAG, "error code : " + errorCode);
                onLoadFail(errorCode);

                PerpleLog.d(LOG_TAG, "Reward based video ad retry to load.");
                loadRewardedVideoAd();
            }

            @Override
            public void onRewardedVideoCompleted() {
                PerpleLog.v(LOG_TAG, "onRewardedVideoCompleted");
            }
        });
    }

}
