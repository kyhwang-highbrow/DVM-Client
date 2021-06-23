package com.perplelab.admob

import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.initialization.OnInitializationCompleteListener
import com.perplelab.PerpleLog
import com.perplelab.PerpleSDK

/**
 *  @author mskim
 *  @version 1.0
 *  @language Kotlin
 *
 *  PerpleAdMob is master class
 *
 */
class PerpleAdMob(appId: String) {
    private val LOG_TAG = "PerpleAdMob"
    private var mPerpleRewardedVideoAd: PerpleAdMobRewardedVideoAd? = null
    private var mPerpleInterstitialAd: PerpleAdMobInterstitialAd? = null

    init {
        PerpleLog.d(LOG_TAG, "Initializing AdMob")

        MobileAds.initialize(PerpleSDK.getInstance().mainActivity)
    }

    fun initRewardedVideoAd() {
        mPerpleRewardedVideoAd = PerpleAdMobRewardedVideoAd()
    }

    fun initInterstitialAd() {
        mPerpleInterstitialAd = PerpleAdMobInterstitialAd()
    }

    fun getPerpleRewardedVideoAd() = mPerpleRewardedVideoAd
    fun getPerpleInterstitialAd() = mPerpleInterstitialAd

    fun onResume() {
        mPerpleRewardedVideoAd?.onResume()
    }

    fun onPause() {
        mPerpleRewardedVideoAd?.onPause()
    }

    fun onDestroy() {
        mPerpleRewardedVideoAd?.onDestroy()
    }

}