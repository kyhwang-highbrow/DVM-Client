package com.tnkfactory.tnkadvertiser;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class TestReceiver extends BroadcastReceiver {
	
	public static final String ACTION_INSTALL_REFERRER = "com.android.vending.INSTALL_REFERRER";
	
	@Override
	public void onReceive(Context context, Intent intent) {
		String action = intent.getAction();

		Log.d("tnkad", "TNK TEST receiver " + action);
		
//		for(StackTraceElement ste:Thread.currentThread().getStackTrace()) {
//			Log.d("tnkad", "## " + ste.getLineNumber() + "," + ste.getClassName() + " " + ste.getMethodName());
//		}
		
		if (ACTION_INSTALL_REFERRER.equals(action)) {
			Bundle parameter = intent.getExtras();
			String referrer = null;
			if (parameter != null && parameter.containsKey("referrer")) {
				referrer = parameter.getString("referrer");
				
				Log.d("tnkad", "TNK TEST receiver referrer = " + referrer);
			}
		}
	}
}