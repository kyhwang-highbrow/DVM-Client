package com.kakao.reach.ingame.ui.component;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.webkit.WebView;

import com.kakao.auth.Session;
import com.kakao.gameutil.helper.GameServerProtocol;
import com.kakao.network.ServerProtocol;
import com.kakao.usermgmt.response.model.UserProfile;
import com.kakao.util.helper.CommonProtocol;
import com.kakao.util.helper.MethodInvoker;
import com.kakao.util.helper.SystemInfo;
import com.kakao.util.helper.log.Logger;

import java.util.HashMap;

/**
 * Created by seed on 15. 9. 30..
 */
public abstract class BaseWebViewActivity extends Activity {
    public static final String EXTRA_KEY_REQUEST_URL = "KEY_REQUEST_URL";

    protected WebView webView;
    protected String requestUrl;
    protected UserProfile userProfile;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestUrl = handleIntent();
        userProfile = UserProfile.loadFromCache();
    }

    @Override
    protected void onPause() {
        try {
            MethodInvoker.invoke(webView, "onPause");
        } catch (Exception e) {
            Logger.e(e.getMessage());
        }

        super.onPause();
    }

    @Override
    protected void onResume() {
        try {
            MethodInvoker.invoke(webView, "onResume");
        } catch (Exception e) {
            Logger.e(e.getMessage());
        }

        super.onResume();
    }

    public boolean requestGoBack() {
        if (!webView.canGoBack())
            return false;

        webView.goBack();
        return true;
    }

    public void requestGoForward() {
        if (webView.canGoForward())
            webView.goForward();
    }

    public void requestRefresh() {
        String url = webView.getUrl();
        requestLoadUrl(url);
    }

    public void requestLoadUrl(String url) {
        webView.loadUrl(url, getHeader());
    }

    public void requestGoHome() {
        String homeUrl = getHomeUrl();
        requestLoadUrl(homeUrl);
    }

    public abstract String getHomeUrl();


    protected String handleIntent() {
        Intent intent = getIntent();

        if (intent == null) {
            Logger.e("Can not found intent");
            setResult(RESULT_CANCELED);
            finish();
        }

        if (!intent.hasExtra(EXTRA_KEY_REQUEST_URL)) {
            Logger.e("Can not found url in intent");
            setResult(RESULT_CANCELED);
            finish();
        }

        return intent.getStringExtra(EXTRA_KEY_REQUEST_URL);
    }

    protected HashMap<String, String> getHeader() {
        HashMap<String, String> header = new HashMap<String, String>();
        header.put(CommonProtocol.KA_HEADER_KEY, SystemInfo.getKAHeader());
        header.put(ServerProtocol.AUTHORIZATION_HEADER_KEY, getTokenAuthHeaderValue());
        header.put(GameServerProtocol.KGA_HEADER_KEY, getKGAHeaderValue());

        return header;
    }

    protected void showErrorAlert(String message) {
        try {
            new AlertDialog.Builder(this)
                    .setMessage(message)
                    .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {

                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            setResult(RESULT_CANCELED);
                            finish();
                        }
                    })
                    .create().show();
        } catch (Exception e) {
            Logger.e(e.getMessage());
        }
    }

    private String getTokenAuthHeaderValue() {
        return new StringBuilder().append(ServerProtocol.AUTHORIZATION_BEARER)
                .append(ServerProtocol.AUTHORIZATION_HEADER_DELIMITER)
                .append(Session.getCurrentSession().getAccessToken())
                .toString();
    }

    private String getKGAHeaderValue() {
        String appKey = Session.getCurrentSession().getAppKey();
        long userId = userProfile.getId();

        return new StringBuilder().append(GameServerProtocol.KGA_APP_KEY).append(appKey).append(" ")
                .append(GameServerProtocol.KGA_USER_ID).append(userId)
                .toString();
    }
}
