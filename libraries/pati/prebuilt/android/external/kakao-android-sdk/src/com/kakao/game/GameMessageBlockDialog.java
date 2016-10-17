package com.kakao.game;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Message;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;

import com.kakao.auth.Session;
import com.kakao.network.ErrorResult;
import com.kakao.network.callback.ResponseCallback;
import com.kakao.util.helper.CommonProtocol;
import com.kakao.util.helper.SystemInfo;
import com.kakao.util.helper.log.Logger;

import org.apache.http.HttpStatus;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.InputStream;
import java.util.HashMap;
import java.util.Locale;

/**
 * Created by house.dr on 15. 11. 10..
 */
public class GameMessageBlockDialog extends Dialog {
    static private String SETTING_URL =  "https://apps.kakao.com/feedblock";

    private WebView webView;
    private ProgressDialog progressDialog;
    private String url;
    private ResponseCallback callback = null;

    public GameMessageBlockDialog(Context context, ResponseCallback callback) {
        super(context, android.R.style.Theme_Black);

        this.callback = callback;

        Locale locale = context.getResources().getConfiguration().locale;
        url = String.format("%s?lang=%s", SETTING_URL, locale.getLanguage());
    }

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTitle("KAKAO");

        webView = new WebView(getContext());
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                super.onPageStarted(view, url, favicon);
                showProgressDialog();
                callback.onDidStart();
            }

            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                hideProgressDialog();
//				responseHandler.sendMessage(Message.obtain(responseHandler, KakaoTask.COMPLETE, HttpStatus.SC_OK, Kakao.STATUS_SUCCESS, null));
            }

            @Override
            public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
                super.onReceivedError(view, errorCode, description, failingUrl);
                hideProgressDialog();
                callback.onFailureForUiThread(new ErrorResult(new Exception("game message block dialog error")));
                dismiss();
            }
        });

        HashMap<String, String> header = new HashMap<String, String>();
        header.put("Authorization", "Bearer " + Session.getCurrentSession().getAccessToken());
        header.put(CommonProtocol.KA_HEADER_KEY, SystemInfo.getKAHeader());
        webView.loadUrl(url, header);
        webView.getSettings().setJavaScriptEnabled(true);
        webView.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        addContentView(webView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            if (webView.canGoBack()) {
                webView.goBack();
                return true;
            } else {
                callback.onSuccessForUiThread(true);
                dismiss();
            }
        }
        return super.onKeyDown(keyCode, event);
    }

    private void showProgressDialog() {
        hideProgressDialog();
        progressDialog = ProgressDialog.show(getContext(), null, "Loading...");
    }

    private void hideProgressDialog() {
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
    }
}
