package com.perplelab.admob

import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.InterstitialAd
import com.perplelab.PerpleLog
import com.perplelab.PerpleSDK

/**
 *  @author mskim
 *  @version 1.0
 *  @language Kotlin
 *
 *  PerpleAdMobInterstitialAd is managing class of AdMob Interstitial Ad
 *
 */
class PerpleAdMobInterstitialAd() {
    private val LOG_TAG = "PerpleSDK AdMob Interstitial Ad"
    private val MAX_TRY_COUNT = 10

    private var mTryLoadingCount = 0
    private var mInterstitialAd = InterstitialAd(PerpleSDK.getInstance().mainActivity)
    private var mCallback: PerpleAdMobCallback? = null

    init {
        PerpleLog.d(LOG_TAG, "Initializing AdMob Interstitial Ad")
        setAdListener()
    }

    fun setAdUnitID(adUnitId: String) {
        mInterstitialAd.adUnitId = adUnitId
    }

    fun loadAd() {
        mTryLoadingCount++
        if (mTryLoadingCount > MAX_TRY_COUNT) {
            PerpleLog.w(LOG_TAG, "loading Ad is failed.")
            return
        }

        PerpleSDK.getInstance().mainActivity.runOnUiThread {
            mInterstitialAd.loadAd(AdRequest.Builder().build())
        }
    }

    fun show() {
        mTryLoadingCount = 0

        PerpleSDK.getInstance().mainActivity.runOnUiThread {
            if (mInterstitialAd.isLoaded) {
                mInterstitialAd.show()
            } else {
                loadAd()
                mCallback?.onError(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_ADMOB_NOTLOADEDAD, "Ad is not loaded."))
            }
        }
    }

    fun setResultCallBack(callback: PerpleAdMobCallback) {
        this.mCallback = callback
    }

    private fun setAdListener() {
        mInterstitialAd.adListener = object : AdListener() {
            override fun onAdLoaded() {
                // Code to be executed when an ad finishes loading.
                PerpleLog.d(LOG_TAG, "AdListener - onAdLoaded")
                mCallback?.onReceive("ad loaded")
            }

            override fun onAdFailedToLoad(errorCode: Int) {
                // Code to be executed when an ad request fails.
                PerpleLog.d(LOG_TAG, "AdListener - onAdFailedToLoad")
                mCallback?.onFail("ad failed to load")

                PerpleLog.d(LOG_TAG, "error code : $errorCode")
                loadAd()
            }

            override fun onAdOpened() {
                // Code to be executed when the ad is displayed.
                PerpleLog.d(LOG_TAG, "AdListener - onAdOpened")
                mCallback?.onOpen("open")
            }

            override fun onAdLeftApplication() {
                // Code to be executed when the user has left the app.
                PerpleLog.d(LOG_TAG, "AdListener - onAdLeftApplication")
                mCallback?.onCancel("cancel")
            }

            override fun onAdClosed() {
                // Code to be executed when when the interstitial ad is closed.
                PerpleLog.d(LOG_TAG, "AdListener - onAdClosed")
                mCallback?.onFinish("success")

                loadAd()
            }
        }
    }

}