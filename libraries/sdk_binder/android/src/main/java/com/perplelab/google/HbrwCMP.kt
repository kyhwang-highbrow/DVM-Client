package com.perplelab.google

import android.os.Handler
import android.os.Looper
import com.google.android.ump.ConsentDebugSettings
import com.google.android.ump.ConsentInformation
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform
import com.perplelab.PerpleSDK
import com.perplelab.PerpleSDKCallback


/**
 * Consent Management Platform by Google
 * object singleton 으로 구현
 *
 * https://developers.google.com/admob/android/privacy
 *
 * @author : kms
 * @since : 23.12.28
 */
object HbrwCMP {
    private var consentInformation: ConsentInformation

    init {
        val activity = PerpleSDK.getInstance().mainActivity
        consentInformation = UserMessagingPlatform.getConsentInformation(activity)
    }

    /**
     * Consent관리에 필요한 정보를 설정하고 필요한 경우 동의 화면도 출력한다.
     * 먼저 호출 되어야 다른 기능들을 사용할 수 있어 앱 구동 후 적절한 시점에 빠르게 호출하도록 한다.
     */
    fun loadConsentIfNeeded(callback: PerpleSDKCallback) {
        val activity = PerpleSDK.getInstance().mainActivity
        val params = getConsentRequestParam()
        consentInformation.requestConsentInfoUpdate(activity, params, {
            UserMessagingPlatform.loadAndShowConsentFormIfRequired(activity) { loadAndShowError ->
                when (loadAndShowError) {
                    // Consent has been gathered.
                    null -> callback.onSuccess("success")
                    // Consent gathering failed.
                    else -> callback.onFail("fail")
                }
            }
        }, { requestConsentError -> callback.onFail(requestConsentError.message) })
    }

    /**
     * 유저가 원하는 시점에 개인 정보 제공 동의 내용을 변경할 수 있도록 UI를 다시 출력한다.
     * [ConsentInformation.requestConsentInfoUpdate]가 먼저 호출되어 consent 관련 정보가 설정되어 있어야 사용 가능한 것에 주의
     */
    fun presentPrivacyOptionForm(callback: PerpleSDKCallback) {
        val activity = PerpleSDK.getInstance().mainActivity
        Handler(Looper.getMainLooper()).post {
            UserMessagingPlatform.showPrivacyOptionsForm(activity) { formError ->
                when (formError) {
                    // Consent has been gathered.
                    null -> callback.onSuccess("success")
                    // Consent gathering failed.
                    else -> callback.onFail("fail")
                }
            }
        }
    }

    /**
     * 광고 호출 가능 여부,
     * 단 어떤 특별한 동의 여부를 확인하는 것이 아니라 [UserMessagingPlatform.loadAndShowConsentFormIfRequired]가 호출되었는지로 판별한다.
     * @return Boolean
     */
    fun canRequestAds(): Boolean {
        return consentInformation.canRequestAds()
    }

    /**
     * [presentPrivacyOptionForm]가 호출 가능한지 여부
     * @return Boolean
     */
    fun requirePrivacyOption(): Boolean {
        return consentInformation.privacyOptionsRequirementStatus == ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED
    }

    /**
     * If you need to test CMP, find test id first.
     * search text below on logcat
     * - Use new ConsentDebugSettings.Builder().addTestDeviceHashedId
     *
     * Test ID Samples:
     * - Pixel 6 : FF577E69D6088CFBB1BA2CA1BAE66539(owned by 기영)
     */
    private fun getConsentRequestParam(): ConsentRequestParameters {
        val activity = PerpleSDK.getInstance().mainActivity
        return when (PerpleSDK.IsDebug) {
            false -> ConsentRequestParameters.Builder().build()
            true -> {
                val debugSettings = ConsentDebugSettings.Builder(activity)
                    .setDebugGeography(ConsentDebugSettings.DebugGeography.DEBUG_GEOGRAPHY_EEA)
                    .addTestDeviceHashedId("FF577E69D6088CFBB1BA2CA1BAE66539").build()
                ConsentRequestParameters.Builder().setConsentDebugSettings(debugSettings).build()
            }
        }
    }

    /**
     * Caution: This method is intended to be used for testing purposes only. You shouldn't call reset() in production code.
     */
    private fun reset() {
        consentInformation.reset()
    }
}