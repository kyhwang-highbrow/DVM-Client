package com.perplelab.admob;

import android.content.Context;

import androidx.annotation.NonNull;

import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.initialization.InitializationStatus;
import com.google.android.gms.ads.initialization.OnInitializationCompleteListener;
import com.perplelab.PerpleSDK;
import com.perplelab.SdkBinderCallback;

import java.util.HashMap;

public class SdkBinderAdMob {

    private final String TEST_AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917";
    private final String TAG = "SdkBinderAdMob";
    HashMap<String, AdMobRewardAdUnit> mAdMobRewardAdUnits = new HashMap<String, AdMobRewardAdUnit>();

    public SdkBinderAdMob() {
    }

    public void initialize(final SdkBinderCallback sdkBinderCallback) {
        Context context = PerpleSDK.getInstance().getMainActivity();
        MobileAds.initialize(context, new OnInitializationCompleteListener() {
            @Override
            public void onInitializationComplete(@NonNull InitializationStatus initializationStatus) {
                //Context context = PerpleSDK.getInstance().getMainActivity();
                //Toast.makeText(context,"광고 초기화 완료" + initializationStatus.toString(), Toast.LENGTH_SHORT).show();
                sdkBinderCallback.onFinish("success", initializationStatus.toString());
            }
        });

        /*
        // 테스트 기기 등록 (김성구 폴더2)
        List<String> testDeviceIds = Arrays.asList("2E9DAFC5B80C57E4F0E530DC0D16DC45");
        RequestConfiguration configuration =
                new RequestConfiguration.Builder().setTestDeviceIds(testDeviceIds).build();
        MobileAds.setRequestConfiguration(configuration);
         */
    }

    // 보상형 광고 로드
    public void loadRewardedAd(String adUnitId, SdkBinderCallback sdkBinderCallback) {
        AdMobRewardAdUnit adUnit = getRewardAdUnit(adUnitId);
        adUnit.loadRewardedAd(sdkBinderCallback);
    }

    // 보상형 광고 재생
    public void showRewardedAd(String adUnitId, SdkBinderCallback sdkBinderCallback) {
        AdMobRewardAdUnit adUnit = getRewardAdUnit(adUnitId);
        adUnit.showRewardAd(sdkBinderCallback);
    }

    // 보상형 광고 유닛
    private AdMobRewardAdUnit getRewardAdUnit(String adUnitId) {
        AdMobRewardAdUnit adUnit = mAdMobRewardAdUnits.get(adUnitId);
        if (adUnit == null) {
            adUnit = new AdMobRewardAdUnit(adUnitId);
            mAdMobRewardAdUnits.put(adUnitId, adUnit);
        }
        return adUnit;
    }

    public void onResume() {
    }

    public void onPause() {
    }

    public void onDestroy() {
    }
}
