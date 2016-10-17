package com.tnkfactory.ad.addon;

import com.tnkfactory.ad.A;

import android.content.Context;
import android.util.Log;

/**
 * 기기 식별자 등을 제공한다.
 * @author kimhd
 *
 */
public class Identifier {

	/**
	 * [deviceId, udid] 를 반환한다.
	 * @param context
	 * @return
	 */
	public static String[] id(Context context) {
		String deviceId = di(context); // reflection 으로 가져온다.
		String udid = null;
		
		// Device ID를 가져오지 못한 경우, wifi mac address 를 사용한다.
		if (deviceId == null) {
			// 2013.02.08 mac-address 와 aid 수집
			String macAddress = ma(context);
			
			if (macAddress != null) {
				// wifi 기기이다. Mac-address 를 사용한다.
				deviceId = "wf" + macAddress.replace(":", "");
			}
			
			if (deviceId != null) {
				udid = A.b(deviceId); // Utils.makeUdid();
			}
		}
		else {
			// IMEI 값이 있는 경우이다.
			udid = A.b(deviceId);  // Utils.makeUdid();
			deviceId = deviceId.toLowerCase(); // Lower case the device ID.
		}
		
		return new String[] {deviceId, udid};
	}
	
	/**
	 * IMEI 값을 reflection 으로 가져온다.
	 * @param context
	 * @return
	 */
	private static String di(Context context) {		
		String deviceId = null;
		
		String codeText = A.d();
		String[] codeSplit = codeText.split("\\|");
		
		Object tm = A.m(context, codeSplit[0], new Object[] {codeSplit[2]});
		deviceId = (String) A.m(tm, codeSplit[1], null);
		
		return deviceId;
	}
	
	/**
	 * macaddress 를 reflection 으로 가져온다.
	 * 
	 * WifiManager wfManager = (WifiManager)context.getSystemService(Context.WIFI_SERVICE);
     * WifiInfo wifiInfo = wfManager.getConnectionInfo();
	 * String wifiMacAddress = wifiInfo.getMacAddress().toLowerCase();
	 * 
	 * @param context
	 * @return
	 */
	private static String ma(Context context) {
		String wifiMacAddress = null;
		
		String codeText = A.c();
		String[] codeSplit = codeText.split("\\|");
		
		try {
			Object wm = A.m(context, codeSplit[1], new Object[] {codeSplit[0]});
			Object wi = A.m(wm, codeSplit[2], null);
			wifiMacAddress = (String)A.m(wi, codeSplit[3], null);
			
			if (wifiMacAddress != null) {
				wifiMacAddress = wifiMacAddress.toLowerCase();
			}
		}
		catch(Exception ex) {
			Log.e("tnkad", ex.toString());
		}
		
		return wifiMacAddress;
	}
}
