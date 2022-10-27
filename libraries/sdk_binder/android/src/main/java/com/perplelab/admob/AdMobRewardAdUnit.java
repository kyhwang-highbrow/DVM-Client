package com.perplelab.admob;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.OnUserEarnedRewardListener;
import com.google.android.gms.ads.rewarded.RewardItem;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;
import com.perplelab.PerpleSDK;
import com.perplelab.SdkBinderCallback;

public class AdMobRewardAdUnit {
    private String mAdUnitId = "";
    private RewardedAd mRewardedAd = null;
    private RewardItem mRewardItem = null;
    private boolean isLoading = false;
    private final String TAG = "AdMobRewardAdUnit";
    private final Handler mAppHandler;

    AdMobRewardAdUnit(String adUnitId) {
        mAdUnitId = adUnitId;

        // mAppHandler를 통해 메인 쓰레드에서 함수를 호출하기 위해 사용
        mAppHandler = new Handler(Looper.getMainLooper());
    }

    public void loadRewardedAd(final SdkBinderCallback sdkBinderCallback) {
        // 이미 로드되어 있는 경우
        if ((!isLoading) && (mRewardedAd != null)) {
            sdkBinderCallback.onFinish("success", "");
            return;
        }

        // 이전 호출로 로딩 중인 경우
        if (isLoading) {
            sdkBinderCallback.onFinish("loading", "Ad is loading.");
            return;
        }

        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                Context context = PerpleSDK.getInstance().getMainActivity();
                AdRequest adRequest = new AdRequest.Builder().build();
                RewardedAdLoadCallback callback = new RewardedAdLoadCallback(){
                    @Override
                    public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
                        // Handle the error.
                        Log.d(TAG, "onAdFailedToLoad : " + loadAdError.getMessage());
                        Log.d(TAG, "AdapterClassName : " + loadAdError.getResponseInfo().getMediationAdapterClassName());
                        mRewardedAd = null;
                        isLoading = false;

                        String info = PerpleSDK.getErrorInfo(String.valueOf(loadAdError.getCode()), loadAdError.getMessage());
                        sdkBinderCallback.onFinish("fail", info);
                    }

                    @Override
                    public void onAdLoaded(@NonNull RewardedAd rewardedAd) {
                        Log.d(TAG, "Ad was loaded. : " + rewardedAd.getResponseInfo().getMediationAdapterClassName());
                        mRewardedAd = rewardedAd;
                        isLoading = false;
                        sdkBinderCallback.onFinish("success", "");
                    }
                };

                isLoading = true;
                RewardedAd.load(context, mAdUnitId, adRequest, callback);
            }
        });
    }

    public void showRewardAd(final SdkBinderCallback sdkBinderCallback) {
        if (mRewardedAd == null) {
            sdkBinderCallback.onFinish("fail", "Ads are not loading.");
            return;
        }

        mAppHandler.post(new Runnable() {
            @Override
            public void run() {
                mRewardedAd.setFullScreenContentCallback(new FullScreenContentCallback() {
                    @Override
                    public void onAdShowedFullScreenContent() {
                        // Called when ad is shown.
                        Log.d(TAG, "Ad was shown.");
                    }

                    @Override
                    public void onAdFailedToShowFullScreenContent(AdError adError) {
                        // Called when ad fails to show.
                        Log.d(TAG, "Ad failed to show.");

                        String info = PerpleSDK.getErrorInfo(String.valueOf(adError.getCode()), adError.getMessage());
                        sdkBinderCallback.onFinish("fail", info);

                        mRewardedAd = null;
                        isLoading = false;
                        mRewardItem = null;
                    }

                    @Override
                    public void onAdDismissedFullScreenContent() {
                        // Called when ad is dismissed.
                        // Don't forget to set the ad reference to null so you
                        // don't show the ad a second time.
                        Log.d(TAG, "Ad was dismissed.");

                        // mRewardItem이 null이 아니면 보상 수령
                        if (mRewardItem != null) {
                            sdkBinderCallback.onFinish("success", "");
                        } else {
                            sdkBinderCallback.onFinish("cancel", "");
                        }

                        mRewardedAd = null;
                        isLoading = false;
                        mRewardItem = null;
                    }
                });

                Activity activityContext = PerpleSDK.getInstance().getMainActivity();
                mRewardItem = null;
                mRewardedAd.show(activityContext, new OnUserEarnedRewardListener() {
                    @Override
                    public void onUserEarnedReward(@NonNull RewardItem rewardItem) {
                        // Handle the reward.
                        Log.d(TAG, "The user earned the reward.");
                        int rewardAmount = rewardItem.getAmount();
                        String rewardType = rewardItem.getType();

                        // 보상 정보
                        mRewardItem = rewardItem;
                    }
                });
            }
        });
    }
}
