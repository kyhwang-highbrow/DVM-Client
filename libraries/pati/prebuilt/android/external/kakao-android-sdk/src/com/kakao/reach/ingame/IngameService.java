package com.kakao.reach.ingame;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.kakao.auth.Session;
import com.kakao.network.callback.ResponseCallback;
import com.kakao.network.tasks.KakaoResultTask;
import com.kakao.network.tasks.KakaoTaskQueue;
import com.kakao.reach.ingame.api.IngameApi;
import com.kakao.reach.ingame.callback.IngameStatusResponseCallback;
import com.kakao.reach.ingame.response.model.IngameStatus;
import com.kakao.reach.ingame.response.model.WithGame;
import com.kakao.util.helper.CommonProtocol;
import com.kakao.util.helper.SharedPreferencesCache;

/**
 * 카카오 SDK 리치의 Ingame 서비스를 담당한다.
 * Created by seed on 15. 9. 15..
 */
public class IngameService {
    public static final int REQUEST_CODE_WEBVIEW = 10000;

    public interface ActivityResultCallback {
        void onClose();
    }

    /**
     * 카카오 SDK 리치의 Ingame 서비스 상태 요청
     *
     * @param callback
     */
    public static final void requestIngameStatus(final IngameStatusResponseCallback callback) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<IngameStatus>(callback) {

            @Override
            public IngameStatus call() throws Exception {
                return IngameApi.requestIngameStatus();
            }
        });
    }

    /**
     * 인게임웹뷰 버튼을 노출한다.
     *
     * @param callback
     * @return
     */
    public static final void showIngameWebViewButton(final ResponseCallback<Integer> callback) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Integer>(callback) {

            @Override
            public Integer call() throws Exception {
                return IngameApi.showIngameWebViewButton();
            }
        });
    }

    /**
     * 인게임웹뷰 버튼을 제거한다.
     *
     * @param callback
     */
    public static final void hideIngameWebViewButton(final ResponseCallback<Integer> callback) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Integer>(callback) {

            @Override
            public Integer call() throws Exception {
                return IngameApi.hideIngameWebViewButton();
            }
        });
    }

    /**
     * 인게임웹뷰를 노출한다.
     *
     * @param callback
     */
    public static final void showIngameWebView(final ResponseCallback<Integer> callback) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Integer>(callback) {

            @Override
            public Integer call() throws Exception {
                return IngameApi.showIngameWebView();
            }
        });
    }

    /**
     * 카카오 보드게임 플러스친구 가입페이지를 노출한다.
     * 본인인증이 완료된 후 호출하길 권장한다.
     * 인증 후 노출된 이력이 확인되면 요청해도 노출되지 않는다.
     *
     * @param callback
     * @return
     */
    public static final void showPlusFriendView(final ResponseCallback<Integer> callback) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Integer>(callback) {

            @Override
            public Integer call() throws Exception {
                return IngameApi.showPlusFriendView();
            }
        });
    }

    /**
     * 인게임웹뷰 버튼 뉴뱃지의 활성화 상태 요청
     *
     * @param callback
     * @return
     */
    public static final void isEnableNewBadge(final ResponseCallback<Boolean> callback) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Boolean>(callback) {

            @Override
            public Boolean call() throws Exception {
                return IngameApi.isEnableNewBadge();
            }
        });
    }

    public static boolean onActivityResult(int requestCode, int resultCode, Intent data, ActivityResultCallback callback) {
        if (requestCode != REQUEST_CODE_WEBVIEW)
            return false;

        if (callback == null)
            return true;

        switch (resultCode) {
            case Activity.RESULT_OK:
            case Activity.RESULT_CANCELED:
                callback.onClose();
                break;
            default:
                break;
        }

        return true;
    }
}
