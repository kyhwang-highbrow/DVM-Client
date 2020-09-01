@file:JvmName("PerpleUtil")

package com.perplelab.util

import android.os.Build
import android.util.Base64

/**
 *  @author mskim
 *  @version 1.0
 *  @language Kotlin
 *
 *  PerpleUtil is helper class composed of static utility method.
 *  The goal is that AppActivity.java do not have any utility method and PerpleUtil provide it.
 *  and we can practice Kotlin, the new public language of Android. It is so easy and fun.
 */

class PerpleUtil {
    companion object {
        fun getSdkVersion() : Int = Build.VERSION.SDK_INT

        // ABI architecture
        fun getABI() : String? = if (Build.VERSION.SDK_INT >= 21) Build.SUPPORTED_ABIS[0] else "none"

        // base 64
        fun encodeBase64(str: String): String = Base64.encodeToString(str.toByteArray(), Base64.DEFAULT)
        fun decodeBase64(base64: Base64): String = String(Base64.decode(base64.toString(), Base64.DEFAULT))
    }
}
