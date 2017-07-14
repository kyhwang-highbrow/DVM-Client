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

//@perplesdk
import com.perplelab.PerpleSDK;
import com.perplelab.dragonvillagem.kr.R;
import com.perplelab.google.PerpleBuildGoogleApiClient;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.google.android.gms.games.Games;
import com.google.android.gms.common.api.GoogleApiClient.Builder;

public class AppActivity extends Cocos2dxActivity{

    // @perplesdk
    static {
        System.loadLibrary("perplesdk");
    }

    static final String TAG = "DragonVillageM";

    // @billing
    static final String gameId = "1003";
    static final String billingBase64PublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2AOyhy0owSekR+QEpAUb2fV/wBtRmuD8UNEsku6iGM+Qx5o7iBMlGlcb7kjCJ86hMAu6g+1cdGFTQGCGTKrDZS6AfTv8NDB5EFwxvLa8Rn9aUU0nkaLFGNQvEo+gplP1PZQZLd30RMmJy/uYkzA2+vCdGaOQRTckwbczDBQyKWtQ5k5aj/1HQ/X8XxZneaKAM2JyFgFcjSYtlep9/XOQ6K2aR0VLoMse2rGkaFJQAFOBgNlNbvC3cbvaZe1hnZ4ypjadsPzw83ZpQYaMRTUF1k/TpB6CuSIX4L2ykUkEDyWn0RECpO3jR1fJ1Lb2ddYTpb8gORou9mhIK9Nfr8Cn4wIDAQAB";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // @perplesdk
        PerpleSDK.createInstance(this);

        // @perplesdk, Lua 콜백을 GL Thread 에서 실행하고자 할 경우 설정한다.
        PerpleSDK.setGLSurfaceView(mGLSurfaceView);

        // 디버그 메시지 출력
        boolean isDebug = true;

        // @perplesdk
        if (PerpleSDK.getInstance().initSDK(gameId, getString(R.string.gcm_defaultSenderId), billingBase64PublicKey, isDebug)) {

            //String logText = "PerpleSDK initialization was successful.";
            //Log.d(TAG, logText);
            //Toast.makeText(this, logText, Toast.LENGTH_SHORT).show();

            // firebase FCM 알림을 포그라운드 상태에서도 받고자 할 경우 true로 설정
            PerpleSDK.getInstance().setReceivePushOnForeground(false);

            // @google, Google Play Services 기능(업적, 리더보드, 퀘스트)을 사용하고자 할 경우
            PerpleSDK.getInstance().initGoogle(getString(R.string.default_web_client_id), new PerpleBuildGoogleApiClient() {
                @Override
                public void onBuild(Builder builder) {
                    builder.addApi(Games.API).addScope(Games.SCOPE_GAMES);
                }
            });

            // @facebook
            PerpleSDK.getInstance().initFacebook(savedInstanceState);
        } else {
            String logText = "PerpleSDK initialization failed.";
            Log.e(TAG, logText);
            Toast.makeText(this, logText, Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    protected void onStart() {
        super.onStart();

        // @perplesdk
        PerpleSDK.getInstance().onStart();
    }

    @Override
    protected void onStop() {
        super.onStop();

        // @perplesdk
        PerpleSDK.getInstance().onStop();
    }

    @Override
    protected void onResume() {
        super.onResume();

        // @perplesdk
        PerpleSDK.getInstance().onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();

        // @perplesdk
        PerpleSDK.getInstance().onPause();
    }

    @Override
    protected void onDestroy() {
        // @perplesdk
        PerpleSDK.getInstance().onDestroy();

        super.onDestroy();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        // @perplesdk
        PerpleSDK.getInstance().onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        // @perplesdk
        PerpleSDK.getInstance().onActivityResult(requestCode, resultCode, data);
    }
}
