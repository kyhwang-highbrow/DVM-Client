/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2016 cocos2d-x.org
Copyright (c) 2013-2016 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import org.cocos2dx.lib.Cocos2dxActivity;
import android.os.Handler;
import android.os.Bundle;
import android.util.Log;
import android.content.Intent;
import android.net.Uri;
import android.app.AlertDialog;

public class AppActivity extends Cocos2dxActivity{

    public static boolean mIsRun = false;
    private static AppActivity s_Activity;

    private Handler mAppHandler;

    static final Boolean DEBUG = false;
    static final String TAG = "DV";

    //--------------------------------------------------------------------------------
    // Override Functions
    //--------------------------------------------------------------------------------
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        if (DEBUG) { Log.d(TAG, "onCreate()"); }

        super.onCreate(savedInstanceState);

        s_Activity = this;

        mAppHandler = new Handler();
    }
    
    //--------------------------------------------------------------------------------
    // Static Functions
    //--------------------------------------------------------------------------------

    // Native코드로부터 전달받은 이벤트(lua -> cocos(c++) -> android(java))
    public static void receiveEventFromNative(String param1, String param2) {
        final String _param1 = param1;
        final String _param2 = param2;

        if (DEBUG) { Log.d(TAG, "receiveEventFromNative()" + _param1); }
        if (DEBUG) { Log.d(TAG, "receiveEventFromNative()" + _param2); }

        s_Activity.mAppHandler.post(new Runnable() {
            public void run() {
                if (_param1.equals("app_terminate")) {
                    android.os.Process.killProcess(android.os.Process.myPid());
                } else if (_param1.equals("goto_web")) {
                    Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri
                            .parse(_param2));
                    s_Activity.startActivity(browserIntent);
                } else if (_param1.equals("alert")) {
                    String[] array = _param2.split(";");
                    new AlertDialog.Builder(s_Activity).setTitle(array[0])
                            .setMessage("" + array[1])
                            .setPositiveButton(android.R.string.ok, null)
                            .create().show();
                } else if (_param1.equals("send_email")) {
                    String[] array = _param2.split(";");
                    String[] tos = { array[0] };

                    Intent it = new Intent(Intent.ACTION_SEND);
                    it.putExtra(Intent.EXTRA_EMAIL, tos);
                    it.putExtra(Intent.EXTRA_SUBJECT, array[1]);
                    it.putExtra(Intent.EXTRA_TEXT, array[2]);
                    it.setType("text/plain");
                    s_Activity.startActivity(Intent.createChooser(it,
                            "Choose Email Client"));
                } else if (_param1.equals("goto_store")) {
                    String appName = "com.perplelab.dragonvillage";
                    try {
                        s_Activity.startActivity(new Intent(Intent.ACTION_VIEW,
                                Uri.parse("market://details?id=" + appName)));
                    } catch (android.content.ActivityNotFoundException anfe) {
                        s_Activity.startActivity(new Intent(
                                Intent.ACTION_VIEW,
                                Uri.parse("http://play.google.com/store/apps/details?id="
                                        + appName)));
                    }
                } else if (_param1.equals("local_noti_add")) {
                    try
                    {
                        String[] array = _param2.split(";");
                        String type = array[0];
                        int sec = Integer.parseInt(array[1]);
                        String msg = array[2];

                        boolean bAlert = false;
                        if (array.length > 3) {
                            if (array[3].equals("alert")) {
                                bAlert = true;
                            }
                        }

                        PerplelabIntentFactory.addNoti(type, sec, msg, bAlert);
                    }
                    catch (Exception e)
                    {
                        e.printStackTrace();
                    }
                } else if (_param1.equals("local_noti_setlinkUrl")) {
                    try
                    {
                        String[] array = _param2.split(";");
                        String linkTitle = array[0];
                        String linkUrl = array[1];
                        String cafeUrl = array[2];
                        PerplelabIntentFactory.setLinkUrlInfo(linkTitle, linkUrl, cafeUrl);
                    }
                    catch (Exception e)
                    {
                        e.printStackTrace();
                    }
                } else if (_param1.equals("local_noti_setColor")) {
                    try
                    {
                        String[] array = _param2.split(";");
                        String bgColor = array[0];
                        String titleColor = array[1];
                        String messageColor = array[2];
                        PerplelabIntentFactory.setColor(bgColor, titleColor, messageColor);
                    }
                    catch (Exception e)
                    {
                        e.printStackTrace();
                    }
                } else if (_param1.equals("local_noti_start")) {
                    Intent intent = PerplelabIntentFactory.makeIntentService(s_Activity);
                    s_Activity.startService(intent);

                } else if (_param1.equals("local_noti_cancel")) {
                    PerplelabIntentFactory.clear();
                    Intent intent = PerplelabIntentFactory.makeIntentService(s_Activity);
                    s_Activity.stopService(intent);
                }
            }
        });
    }

    //--------------------------------------------------------------------------------
    // JNI Bridge Functions
    //--------------------------------------------------------------------------------

    private static native boolean nativeIsLandScape();
    private static native boolean nativeIsDebug();
    private static native boolean nativeIsTestMode();
    private static native int nativeLoginPlatform();

    private static native void nativeSDKEventResult(String id, String ret, String info);

}
