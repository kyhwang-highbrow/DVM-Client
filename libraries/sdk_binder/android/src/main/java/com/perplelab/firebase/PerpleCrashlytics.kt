package com.perplelab.firebase

import android.content.Context
import com.google.firebase.crashlytics.FirebaseCrashlytics

import com.perplelab.PerpleLog
import com.perplelab.PerpleSDK


/**
 *  @author mskim
 *  @version 1.0
 *  @language Kotlin
 *
 */
class PerpleCrashlytics() {
    companion object {
        private val LOG_TAG = "PerpleSDK Crashlytics"
        private var isCheckedUnsentRecord = false

        fun init(activity: Context) {
            // Enable crashlytics - disabled by default
            FirebaseCrashlytics.getInstance().setCrashlyticsCollectionEnabled(true)

            // check if has unsent report
            // it should only be called once per execution.
            if (isCheckedUnsentRecord) {
                PerpleLog.d(LOG_TAG, "checkForUnsentReports should only be called once per execution.")
                return;
            }

            isCheckedUnsentRecord = true;

            FirebaseCrashlytics.getInstance().checkForUnsentReports().addOnCompleteListener(PerpleSDK.getInstance().mainActivity)
            { task ->
                if (task.isSuccessful) {
                    val hasUnsentReports = task.result

                    if (hasUnsentReports) {
                        FirebaseCrashlytics.getInstance().sendUnsentReports()
                    }

                    PerpleLog.d(LOG_TAG, "Activity :: ${activity.packageName}")
                    PerpleLog.d(LOG_TAG, "Has unsent reports :: $hasUnsentReports")
                }
            }
        }

        fun setUid(uid: String) {
            FirebaseCrashlytics.getInstance().setUserId(uid)
        }

        fun forceCrash() {
            // firebase로 이전하면서 없는 것 같아 일단 제외
            throw java.lang.RuntimeException("Force crash by PerpleCrashlytics")
        }

        fun setLog(message: String) {
            FirebaseCrashlytics.getInstance().log(message)
        }

        fun setExceptionLog(message: String) {
            FirebaseCrashlytics.getInstance().recordException(RuntimeException(message))
        }

        fun setKeyString(key: String, value: String) {
            FirebaseCrashlytics.getInstance().setCustomKey(key, value)
        }

        fun setKeyInt(key: String, value: Int) {
            FirebaseCrashlytics.getInstance().setCustomKey(key, value)
        }

        fun setKeyBool(key: String, value: Boolean) {
            FirebaseCrashlytics.getInstance().setCustomKey(key, value)
        }

        fun setKeyFloat(key: String, value: Float) {
            FirebaseCrashlytics.getInstance().setCustomKey(key, value)
        }

        fun setKeyDouble(key: String, value: Double) {
            FirebaseCrashlytics.getInstance().setCustomKey(key, value)
        }
    }
}
