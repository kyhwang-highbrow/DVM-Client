package com.perplelab.google

import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerClient.InstallReferrerResponse
import com.android.installreferrer.api.InstallReferrerStateListener
import com.android.installreferrer.api.ReferrerDetails
import com.perplelab.PerpleLog
import com.perplelab.PerpleSDK

/**
 *  @author mskim
 *  @version 1.0
 *  @language Kotlin
 *
 *  HBGoogleInstallReferrer
 *  For Google Play Install Referrer.
 */
class HBGoogleInstallReferrer {
    private val LOG_TAG = "HBGoogleInstallReferrer"
    private lateinit var referrerClient: InstallReferrerClient

    init {
        PerpleLog.d(LOG_TAG, "Initializing InstallReferrer")
    }

    fun setup()
    {
        referrerClient = InstallReferrerClient.newBuilder(PerpleSDK.getInstance().mainActivity).build()
        referrerClient.startConnection(object : InstallReferrerStateListener {

            override fun onInstallReferrerSetupFinished(responseCode: Int) {
                PerpleLog.d(LOG_TAG, "setup finished - Response Code : $responseCode")
                when (responseCode) {
                    InstallReferrerResponse.OK -> {
                        // Connection established.
                        printReferrer();
                        disconnect();
                    }
                    InstallReferrerResponse.FEATURE_NOT_SUPPORTED -> {
                        // API not available on the current Play Store app.
                    }
                    InstallReferrerResponse.SERVICE_UNAVAILABLE -> {
                        // Connection couldn't be established.
                    }
                }
            }

            override fun onInstallReferrerServiceDisconnected() {
                // Try to restart the connection on the next request to
                // Google Play by calling the startConnection() method.
            }
        })
    }

    fun printReferrer()
    {
        val response: ReferrerDetails = referrerClient.installReferrer
        val referrerUrl: String = response.installReferrer
        val referrerClickTime: Long = response.referrerClickTimestampSeconds
        val appInstallTime: Long = response.installBeginTimestampSeconds
//        val instantExperienceLaunched: Boolean = response.googlePlayInstantParam

        PerpleLog.d(LOG_TAG, referrerUrl);
        PerpleLog.d(LOG_TAG, "Click Time : $referrerClickTime");
        PerpleLog.d(LOG_TAG, "Install Time : $appInstallTime");
    }

    fun disconnect() = referrerClient.endConnection()
}