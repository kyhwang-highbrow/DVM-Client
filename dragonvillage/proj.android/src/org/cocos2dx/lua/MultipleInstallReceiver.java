package org.cocos2dx.lua;


import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.google.android.gms.measurement.AppMeasurementInstallReferrerReceiver;
import com.igaworks.IgawReceiver;

public class MultipleInstallReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        // @firebase analytics
        AppMeasurementInstallReferrerReceiver firebaseAnalyticsReceiver = new AppMeasurementInstallReferrerReceiver();
        firebaseAnalyticsReceiver.onReceive(context, intent);

        // @adbrix
        IgawReceiver igawReceiver = new IgawReceiver();
        igawReceiver.onReceive(context, intent);
   }
}