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
import org.cocos2dx.lib.Cocos2dxHelper;

//@perplesdk
import com.perplelab.PerpleSDK;
import com.perplelab.dragonvillagem.kr.R;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

public class AppActivity extends Cocos2dxActivity{

    // @perplesdk
    static {
        System.loadLibrary("perplesdk");
    }

    // @obb
    private static APKExpansionDownloader sOBBDownloader;
    private static Activity sActivity;
    
    // @billing
    static final String billingBase64PublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2AOyhy0owSekR+QEpAUb2fV/wBtRmuD8UNEsku6iGM+Qx5o7iBMlGlcb7kjCJ86hMAu6g+1cdGFTQGCGTKrDZS6AfTv8NDB5EFwxvLa8Rn9aUU0nkaLFGNQvEo+gplP1PZQZLd30RMmJy/uYkzA2+vCdGaOQRTckwbczDBQyKWtQ5k5aj/1HQ/X8XxZneaKAM2JyFgFcjSYtlep9/XOQ6K2aR0VLoMse2rGkaFJQAFOBgNlNbvC3cbvaZe1hnZ4ypjadsPzw83ZpQYaMRTUF1k/TpB6CuSIX4L2ykUkEDyWn0RECpO3jR1fJ1Lb2ddYTpb8gORou9mhIK9Nfr8Cn4wIDAQAB";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // @obb
        sActivity = this;
        
        // @perplesdk
        PerpleSDK.createInstance(this);

        // @perplesdk, Lua 콜백을 GL Thread 에서 실행하고자 할 경우 설정한다.
        PerpleSDK.setGLSurfaceView(mGLSurfaceView);

        // 디버그 메시지 출력
        boolean isDebug = true;

        // @perplesdk
        if (PerpleSDK.getInstance().initSDK(getString(R.string.gcm_defaultSenderId), billingBase64PublicKey, isDebug)) {

            // firebase FCM 알림을 포그라운드 상태에서도 받고자 할 경우 true로 설정
            PerpleSDK.getInstance().setReceivePushOnForeground(false);

            // @google
            PerpleSDK.getInstance().initGoogle(getString(R.string.default_web_client_id));

            // @facebook
            PerpleSDK.getInstance().initFacebook(savedInstanceState);
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

        // @obb
        if (sOBBDownloader != null) {
            sOBBDownloader.disconnectDownloaderClient(this);
        }
        
        // @perplesdk
        PerpleSDK.getInstance().onStop();
    }

    @Override
    protected void onResume() {
        super.onResume();

        // @obb
        if (sOBBDownloader != null) {
            sOBBDownloader.connectDownloaderClient(this);
        }
        
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
    
    // @obb
    public static void startAPKExpansionDownloader(final int versionCode, long fileSize, String md5, long crc32) {
        String[] md5s = { md5, "" };
        long[] crc32s = { crc32, 0 };

        if (APKExpansionDownloader.isNeedToDownloadObbFile(sActivity, versionCode, fileSize, md5s, crc32s)) {
            sOBBDownloader = new APKExpansionDownloader(sActivity, 0);
            sOBBDownloader.setDownloaderCallback(new APKExpansionDownloaderCallback() {
                @Override
                public void onInit() {
                    // startAPKExpansionDownloader() 를 onCreate() 이후에 별도로 호출할 경우 아래 코드 주석 해제해야 다운로드 시작됨
                    //sOBBDownloader.connectDownloaderClient(sActivity);

                    // 다운로드 시작
                    // 다운로드 진행 표시 UI 열기
                }
                @Override
                public void onCompleted() {
                    Cocos2dxHelper.setupObbAssetFileInfo(versionCode);

                    // 다운로드 완료
                    // 다운로드 진행 표시 UI 닫기
                }
                @Override
                public void onUpdateStatus(boolean isPaused, boolean isIndeterminate, boolean isInterruptable, String statusText) {
                    // 다운로드 진행 중 오류 상황 처리
                }
                @Override
                public void onUpdateProgress(long current, long total, String progress, String percent) {
                    // 다운로드 진행 중
                    // 다운로드 진행 상황 UI 업데이트
                }
            });
            sOBBDownloader.initExpansionDownloader(sActivity);
        } else {
            // 게임 시작
            Cocos2dxHelper.setupObbAssetFileInfo(versionCode);
        }
    }    
}
