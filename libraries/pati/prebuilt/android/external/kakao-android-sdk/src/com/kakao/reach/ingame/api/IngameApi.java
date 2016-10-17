package com.kakao.reach.ingame.api;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.kakao.auth.KakaoSDK;
import com.kakao.auth.Session;
import com.kakao.auth.SingleNetworkTask;
import com.kakao.gameutil.helper.GameServerProtocol;
import com.kakao.network.response.ResponseData;
import com.kakao.reach.ingame.IngameService;
import com.kakao.android.sdk.R;
import com.kakao.reach.ingame.response.model.WithGame;
import com.kakao.reach.ingame.ui.PlusFriendActivity;
import com.kakao.reach.ingame.reqeust.IngameStatusRequest;
import com.kakao.reach.ingame.response.IngameStatusResponse;
import com.kakao.reach.ingame.response.model.IngameStatus;
import com.kakao.reach.ingame.ui.IngameWebViewActivity;
import com.kakao.reach.ingame.ui.component.BaseWebViewActivity;
import com.kakao.util.helper.CommonProtocol;
import com.kakao.util.helper.SharedPreferencesCache;
import com.kakao.util.helper.Utility;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Created by seed on 15. 9. 15..
 */
public class IngameApi {
    private static final String CACHE_PLUS_FRIEND_VIEW_EXPOSED_AT = "com.kakao.reach.plusfriendview.exposedat";
    private static final String CACHE_INGAME_WEBVIEW_EXPOSED_AT = "com.kakao.reach.ingamewebview.exposedat";
    private static final String CACHE_INGAME_STATUS_REQUESTED_AT = "com.kakao.reach.ingamestats.requestedat";
    private static final long CACHED_TIME = 12l * 60l * 60l * 1000l;

    /**
     * 카카오 SDK 리치의 Ingame 서비스 상태
     *
     * @return
     * @throws Exception
     */
    public static IngameStatus requestIngameStatus() throws Exception {
        long requestedAt = loadActionTime(CACHE_INGAME_STATUS_REQUESTED_AT);
        long now = System.currentTimeMillis();

        if (now - requestedAt > CACHED_TIME) {
            saveActionTime(CACHE_INGAME_STATUS_REQUESTED_AT);

            SingleNetworkTask networkTask = new SingleNetworkTask();
            ResponseData result = networkTask.requestApi(new IngameStatusRequest());
            IngameStatus ingameStatus = new IngameStatusResponse(result).getIngameStatus();
            ingameStatus.saveToCache();
            return ingameStatus;
        } else {
            return IngameStatus.loadFromCache();
        }
    }

    /**
     * 인게임웹뷰 버튼을 노출한다.
     *
     * @return
     */
    public static int showIngameWebViewButton() throws Exception {
        final Activity topActivity = KakaoSDK.getAdapter().getApplicationConfig().getTopActivity();

        final View target = topActivity.findViewById(R.id.kakao_reach_ingame_webview_button_container);
        if (target != null)
            throw new IllegalStateException("IngameWebViewButton is already shown");

        final AtomicInteger result = new AtomicInteger();
        final CountDownLatch lock = new CountDownLatch(1);

        new Handler(Looper.getMainLooper()).post(new Runnable() {

            @Override
            public void run() {
                LayoutInflater inflater = topActivity.getLayoutInflater();

                View view = inflater.inflate(R.layout.kakao_reach_ingame_webview_layout, null);
                ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

                topActivity.addContentView(view, params);

                result.set(0);
                lock.countDown();
            }
        });

        try {
            lock.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        return result.get();
    }

    /**
     * 인게임웹뷰 버튼을 제거한다.
     *
     * @return
     */
    public static int hideIngameWebViewButton() {
        final Activity topActivity = KakaoSDK.getAdapter().getApplicationConfig().getTopActivity();

        final View target = topActivity.findViewById(R.id.kakao_reach_ingame_webview_button_container);
        if (target == null)
            throw new IllegalStateException("IngameWebViewButton can not be found");

        final AtomicInteger result = new AtomicInteger();
        final CountDownLatch lock = new CountDownLatch(1);

        new Handler(Looper.getMainLooper()).post(new Runnable() {

            @Override
            public void run() {
                ViewGroup group = (ViewGroup) target.getParent();
                group.removeView(target);

                result.set(0);
                lock.countDown();
            }
        });

        try {
            lock.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        return result.get();
    }

    public static int showIngameWebView() throws Exception {
        final Activity topActivity = KakaoSDK.getAdapter().getApplicationConfig().getTopActivity();
        final IngameStatus ingameStatus = requestIngameStatus();
        final String url = CommonProtocol.URL_SCHEME + "://" + ingameStatus.getWithGame().getHomeUrl();

        saveActionTime(CACHE_INGAME_WEBVIEW_EXPOSED_AT);

        Intent intent = new Intent(topActivity, IngameWebViewActivity.class);
        intent.putExtra(BaseWebViewActivity.EXTRA_KEY_REQUEST_URL, url);

        topActivity.startActivityForResult(intent, IngameService.REQUEST_CODE_WEBVIEW);

        return 0;
    }

    /**
     * 카카오 보드게임 플러스친구 가입페이지를 노출한다.
     * 인증 후 노출된 이력이 확인되면 요청해도 노출되지 않는다.
     *
     * @return
     */
    public static int showPlusFriendView() throws Exception {
        final Activity topActivity = KakaoSDK.getAdapter().getApplicationConfig().getTopActivity();
        final IngameStatus ingameStatus = requestIngameStatus();

        if (!canShowPlusFriendView(topActivity, ingameStatus))
            throw new IllegalStateException("PlusFriendView cannot be shown");

        saveActionTime(CACHE_PLUS_FRIEND_VIEW_EXPOSED_AT);

        String plusFriendUrl = Utility.buildUri(GameServerProtocol.REACH_AUTHORITY, GameServerProtocol.PLUS_FRIEND_ADD).toString();

        Intent intent = new Intent(topActivity, PlusFriendActivity.class);
        intent.putExtra(BaseWebViewActivity.EXTRA_KEY_REQUEST_URL, plusFriendUrl);
        topActivity.startActivityForResult(intent, IngameService.REQUEST_CODE_WEBVIEW);

        return 0;
    }

    public static Boolean isEnableNewBadge() throws Exception {
        final IngameStatus ingameStatus = requestIngameStatus();
        final WithGame withGame = ingameStatus.getWithGame();

        if (withGame.isShowNewBadge()) {
            long lastModifiedAt = withGame.getLastModifiedAt();
            long lastClickedAt = loadActionTime(CACHE_INGAME_WEBVIEW_EXPOSED_AT);

            return lastClickedAt < lastModifiedAt;
        } else {
            return false;
        }

    }

    private static boolean canShowPlusFriendView(Activity activity, IngameStatus ingameStatus) {
        final int maxVersion = Integer.parseInt(ingameStatus.getNewAgreementTalkVersion());

        if (ingameStatus.isEnablePlusFriendPage()) {
            if (isNewAgreeTalk(activity, maxVersion))
                return false;
            else
                return isShownPlusFriendView();
        } else {
            return false;
        }
    }

    private static boolean isNewAgreeTalk(Activity activity, int maxVersion) {
        final PackageInfo pi = getPackageInfo(activity, "com.kakao.talk");
        if (pi == null)
            return true;

        final int talkVersion = pi.versionCode % 1400000;

        if (talkVersion >= maxVersion)
            return true;
        else
            return false;
    }

    private static PackageInfo getPackageInfo(Activity activity, String packageName) {
        PackageManager pm = activity.getPackageManager();
        try {
            return pm.getPackageInfo(packageName, 0);
        } catch (PackageManager.NameNotFoundException e) {
            return null;
        }
    }

    private static boolean isShownPlusFriendView() {
        long exposedAt = loadActionTime(CACHE_PLUS_FRIEND_VIEW_EXPOSED_AT);

        if (exposedAt > 0) {
            return false;
        } else {
            return true;
        }
    }

    private static long loadActionTime(String key) {
        SharedPreferencesCache cache = Session.getAppCache();

        if (cache == null)
            return 0L;
        else
            return cache.getLong(key);
    }

    private static void saveActionTime(String key) {
        SharedPreferencesCache cache = Session.getAppCache();
        if (cache == null)
            return;

        Bundle bundle = new Bundle();
        bundle.putLong(key, System.currentTimeMillis());

        cache.save(bundle);

    }
}
