package com.perplelab.firebase

import android.content.Context
import com.google.firebase.crashlytics.FirebaseCrashlytics


/**
 *  @author mskim
 *  @version 1.0
 *  @language Kotlin
 *
 */
class PerpleCrashlytics() {
    companion object {
        fun init(activity: Context) {
            // Enable crashlytics - disabled by default
            FirebaseCrashlytics.getInstance().setCrashlyticsCollectionEnabled(true)
        }

        fun setUid(uid : String) {
            FirebaseCrashlytics.getInstance().setUserId(uid)
        }

        fun forceCrash() {
            // firebase로 이전하면서 없는 것 같아 일단 제외
        }

        fun setLog(message : String) {
            FirebaseCrashlytics.getInstance().log(message)
        }

        fun setKeyString(key : String, value : String) {
            FirebaseCrashlytics.getInstance().setCustomKey(key, value)
        }

        fun setKeyInt(key : String, value : Int) {
            FirebaseCrashlytics.getInstance().setCustomKey(key, value)
        }

        fun setKeyBool(key : String, value : Boolean) {
            FirebaseCrashlytics.getInstance().setCustomKey(key, value)
        }

        fun setKeyFloat(key : String, value : Float) {
            FirebaseCrashlytics.getInstance().setCustomKey(key, value)
        }

        fun setKeyDouble(key : String, value : Double) {
            FirebaseCrashlytics.getInstance().setCustomKey(key, value)
        }
    }
}