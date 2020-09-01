package com.perplelab;

import android.util.Log;

import org.json.JSONObject;

/**
 *  @author mskim
 *  @version 1.0
 *  @language Java
 *
 *  PerpleLog is wrapping class to manage log.
 *  PerpleSDK make only release build. To control log, we need to use other parameter whether is debug or not.
 */
public class PerpleLog {
    public static void v(final String tag, String msg) {
        if (PerpleSDK.IsDebug) Log.v(tag, msg);
    }

    public static void d(final String tag, String msg) {
        if (PerpleSDK.IsDebug) Log.d(tag, msg);
    }
    public static void d(final String tag, JSONObject json) {
        if (PerpleSDK.IsDebug) Log.d(tag, json.toString());
    }

    public static void w(final String tag, String msg) {
        if (PerpleSDK.IsDebug) Log.w(tag, msg);
    }
    public static void w(final String tag, String msg, Exception e) {
        if (PerpleSDK.IsDebug) Log.w(tag, msg, e);
    }

    // release mode 에서도 출력
    public static void e(final String tag, String msg) {
        Log.e(tag, msg);
    }
    public static void i(final String tag, String msg) {
        Log.i(tag, msg);
    }
}
