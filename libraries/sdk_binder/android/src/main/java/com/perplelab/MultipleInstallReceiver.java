package com.perplelab;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

//import com.google.android.gms.measurement.AppMeasurementInstallReferrerReceiver;
//import com.tapjoy.InstallReferrerReceiver;

public class MultipleInstallReceiver extends BroadcastReceiver {
    private static final String LOG_TAG = "PerpleSDK MultipleInstallReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        PerpleLog.d(LOG_TAG, "onReceive()");

        // @tapjoy
        // @sgkim 2021.04.06 현재 사용하고자 하는 com.tapjoy:tapjoy-android-sdk:12.8.0 버전에는 com.tapjoy.InstallReferrerReceiver이 제거되었다.
        // 참고 링크: https://dev.tapjoy.com/kr/android-sdk/Changelog // 12.7.1 (2020-11-02) InstallReferrer API 마이그레이션
//        InstallReferrerReceiver tapjoyReceiver = new InstallReferrerReceiver();
//        tapjoyReceiver.onReceive(context, intent);
   }
}