package com.perplelab.firebase

import android.content.Context
import io.fabric.sdk.android.Fabric
import com.crashlytics.android.Crashlytics
import com.crashlytics.android.ndk.CrashlyticsNdk


/**
 *  @author mskim
 *  @version 1.0
 *  @language Kotlin
 *
 */
class PerpleCrashlytics() {
    companion object {
        fun init(activity: Context) {
            Fabric.Builder(activity)
                .kits(Crashlytics(), CrashlyticsNdk())
                .build()
                .let { fabric ->
                    Fabric.with(fabric)
                }
        }

        fun setUid(uid : String) {
            Crashlytics.setUserIdentifier(uid)
        }

        fun forceCrash() {
            Crashlytics.getInstance().crash()
        }

        fun setLog(message : String) {
            Crashlytics.log(message)
        }

        fun setKeyString(key : String, value : String) {
            Crashlytics.setString(key, value)
        }

        fun setKeyInt(key : String, value : Int) {
            Crashlytics.setInt(key, value)
        }

        fun setKeyBool(key : String, value : Boolean) {
            Crashlytics.setBool(key, value)
        }

        fun setKeyFloat(key : String, value : Float) {
            Crashlytics.setFloat(key, value)
        }

        fun setKeyDouble(key : String, value : Double) {
            Crashlytics.setDouble(key, value)
        }
    }
}