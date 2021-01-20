package com.perplelab.facebook;

import android.app.Activity
import com.facebook.ads.AudienceNetworkAds
import com.facebook.ads.AudienceNetworkAds.InitResult
import org.json.JSONException
import org.json.JSONObject
import android.util.Log

/**
 *  @author ochoi
 *  @version 1.0
 *  @language Kotlin
 *
 */
open class PerpleFacebookAudienceNetwork() {
    companion object
    {
        const val ERROR_NONE : String = "0"
        const val ERROR_INVALIDPLACEMENTID : String = "-2102"
        const val ERROR_NOTLOADEDAD : String = "-2103"
        const val ERROR_FAILLOAD : String = "-2104"
        const val ERROR_MAX_RETRY : String = "-2105"

        const val ERROR_CODE_NETWORK_ERROR : Int = 1000
        const val ERROR_CODE_NO_FILL : Int = 1001
        const val ERROR_CODE_INTERNAL_ERROR : Int = 1002

        const val ERROR_CODE_SERVER_ERROR : Int = 2000


        @JvmStatic fun getErrorInfo(code: String?, subcode: String?, msg: String?): String? {
            try
            {
                val obj = JSONObject()
                obj.put("code", code)
                obj.put("subcode", subcode)
                obj.put("msg", msg)
                return obj.toString()
            }
            catch (e: JSONException)
            {
                e.printStackTrace()
            }

            return ""
        }
    }

    private val LOG_TAG = "FacebookAudienceNetwork"
    private var mRewardedVideoAd: FBRewardedVideoAd? = null
    private var onLogMessage = fun(_: String, _: String): Unit = null!!
    private var curActivity : Activity? = null

    fun initialize(activity: Activity) {
        curActivity = activity
        showLog(LOG_TAG, "Initializing AudienceNetworkAds...")

        AudienceNetworkAds
                .buildInitSettings(activity)
                .withInitListener { result: InitResult ->

                    if (result.isSuccess)
                    {
                        showLog(LOG_TAG, "Initialize success!!!")
                    }
                    else
                    {
                        showLog(LOG_TAG, "Initialize failed!!! msg: " + result.message)
                    }
                }
            .initialize()
    }

    fun initRewardedVideoAd() {
        mRewardedVideoAd = FBRewardedVideoAd(curActivity)
        mRewardedVideoAd!!.addLogListener { tag, msg -> run { showLog(tag, msg) } }
    }

    fun getRewardedVideoAd() = mRewardedVideoAd

    open fun showLog(logTag: String, msg: String)
    {
        Log.d(logTag, msg)
    }

    fun onResume() {
        mRewardedVideoAd?.onResume()
    }

    fun onPause() {
        mRewardedVideoAd?.onPause()
    }

    fun onDestroy() {
        mRewardedVideoAd?.onDestroy()
    }



}