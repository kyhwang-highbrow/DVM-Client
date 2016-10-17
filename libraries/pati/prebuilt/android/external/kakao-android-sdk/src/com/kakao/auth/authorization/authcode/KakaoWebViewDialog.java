/**
 * Copyright 2014 Daum Kakao Corp.
 *
 * Redistribution and modification in source or binary forms are not permitted without specific prior written permission. 
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.kakao.auth.authorization.authcode;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.net.http.SslError;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.webkit.ConsoleMessage;
import android.webkit.JsResult;
import android.webkit.SslErrorHandler;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.Toast;

import com.kakao.auth.KakaoSDK;
import com.kakao.android.sdk.R;
import com.kakao.auth.Session;
import com.kakao.auth.exception.KakaoWebviewException;
import com.kakao.auth.receiver.SmsReceiver;
import com.kakao.auth.receiver.SmsReceiver.ISmsReceiver;
import com.kakao.network.ServerProtocol;
import com.kakao.util.exception.KakaoException;
import com.kakao.util.exception.KakaoException.ErrorType;
import com.kakao.util.helper.CommonProtocol;
import com.kakao.util.helper.SystemInfo;
import com.kakao.util.helper.log.Logger;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * @author MJ
 */
public class KakaoWebViewDialog extends Dialog {
    private static SmsReceiver smsReceiver;

    public interface OnWebViewCompleteListener {
        void onComplete(String redirectURL, KakaoException error);
    }

    private static final int DEFAULT_THEME = android.R.style.Theme_NoTitleBar;

    private final String url;
    private final OnWebViewCompleteListener onCompleteListener;
    private final boolean isUsingTimer;
    private WebView webView;
    private ProgressDialog spinner;
    private ImageView crossImageView;
    private FrameLayout contentFrameLayout;
    private volatile AtomicBoolean listenerCalled = new AtomicBoolean(false);
    private boolean isDetached = true;
    private boolean useSmsReceiver;
    private Map<String, String> headers = new HashMap<String, String>();

    // 연령인증을 위한 dialog시 sms정보를 자동입력해줄때 사용될 수 있다.
    public KakaoWebViewDialog(final Context context, final String url, final boolean isUsingTimer, boolean useSmsReceiver, final OnWebViewCompleteListener listener) {
        this(context, url, null, isUsingTimer, listener);
        this.useSmsReceiver = useSmsReceiver;
    }

    public KakaoWebViewDialog(final Context context, final String url, Bundle extras, final boolean isUsingTimer, final OnWebViewCompleteListener listener) {
        super(context, DEFAULT_THEME);
        this.url = url;
        this.isUsingTimer = isUsingTimer;
        this.onCompleteListener = listener;
        this.headers.put(CommonProtocol.KA_HEADER_KEY, SystemInfo.getKAHeader());
        if (extras != null && extras.size() > 0) {
            for(String key : extras.keySet()) {
                headers.put(key, extras.getString(key));
            }
        }
    }

    @Override
    public void dismiss() {
        if (webView != null) {
            webView.stopLoading();
        }
        if (!isDetached) {
            if (spinner.isShowing()) {
                spinner.dismiss();
            }
            super.dismiss();
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK) && webView.canGoBack()) {
            webView.goBack();
            return true;
        }

        return super.onKeyDown(keyCode, event);
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();

        isDetached = true;

        // 화면회전등의 이유로 dismiss가 아닌 강제로 종료되는 경우가 있다.
        // 이경우는 기본적으로 cancel callback을 불러 주도록 한다.
        sendCancelToListenerIfNeeded();
        unRegisterSmsReceiverIfNeeded();
    }

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();

        isDetached = false;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setBackgroundDrawable(new ColorDrawable(android.graphics.Color.argb(128, 0, 0, 0)));

        setOnCancelListener(new OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialogInterface) {
                sendCancelToListenerIfNeeded();
            }
        });

        spinner = new ProgressDialog(getContext());
        spinner.requestWindowFeature(Window.FEATURE_NO_TITLE);
        spinner.setMessage(getContext().getString(R.string.core_com_kakao_sdk_loading));
        spinner.setOnCancelListener(new OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialogInterface) {
                sendCancelToListenerIfNeeded();
                KakaoWebViewDialog.this.dismiss();
            }
        });

        contentFrameLayout = new FrameLayout(getContext());

        createCrossImage();
        int crossWidth = crossImageView.getDrawable().getIntrinsicWidth();
        setUpWebView(crossWidth / 2);

        contentFrameLayout.addView(crossImageView, new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
        addContentView(contentFrameLayout, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));

        registerSmsReceiverIfNeeded();
    }

    private void sendSuccessToListener(String redirectURL) {
        if (onCompleteListener != null && !listenerCalled.getAndSet(true)) {
            onCompleteListener.onComplete(redirectURL, null);
        }
    }

    private void sendErrorToListener(Throwable error) {
        if (onCompleteListener != null && !listenerCalled.getAndSet(true)) {
            KakaoException kakaoException;
            if (error instanceof KakaoException) {
                kakaoException = (KakaoException) error;
            } else {
                kakaoException = new KakaoException(error);
            }
            onCompleteListener.onComplete(null, kakaoException);
        }
    }

    private void sendCancelToListenerIfNeeded() {
        sendErrorToListener(new KakaoException(ErrorType.CANCELED_OPERATION, "pressed back button or cancel button during requesting auth code."));
    }

    private void createCrossImage() {
        crossImageView = new ImageView(getContext());
        crossImageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                sendCancelToListenerIfNeeded();
                KakaoWebViewDialog.this.dismiss();
            }
        });
        Drawable crossDrawable = getContext().getResources().getDrawable(R.drawable.kakao_close_button);
        crossImageView.setImageDrawable(crossDrawable);
        crossImageView.setVisibility(View.INVISIBLE);
    }

    @SuppressLint("SetJavaScriptEnabled")
    private void setUpWebView(int margin) {
        // TODO xml 설정으로 대체가 안되나?
        FrameLayout webViewContainer = new FrameLayout(getContext());
        webView = new WebView(getContext());
        webView.setVerticalScrollBarEnabled(false);
        webView.setHorizontalScrollBarEnabled(false);
        webView.setWebViewClient(new DialogWebViewClient());
        webView.setWebChromeClient(new KakaoWebChromeClient());
        webView.getSettings().setJavaScriptEnabled(true);
        webView.loadUrl(url, headers);
        webView.canGoBack();
        webView.setLayoutParams(new FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
        webView.setVisibility(View.INVISIBLE);
        webView.getSettings().setSaveFormData(KakaoSDK.getAdapter().getSessionConfig().isSaveFormData());
        webView.getSettings().setSavePassword(false);
        webViewContainer.setPadding(margin, margin, margin, margin);
        webViewContainer.addView(webView);
        contentFrameLayout.addView(webViewContainer);
    }

    private class DialogWebViewClient extends WebViewClient {
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            Logger.d("Redirect URL: " + url);

            // redirect uri
            if(url.startsWith(Session.REDIRECT_URL_PREFIX) && (url.contains(Session.REDIRECT_URL_POSTFIX) || url.contains(Session.AGEAUTH_REDIRECT_URL_POSTFIX))){
                sendSuccessToListener(url);
                dismiss();
            } else if(url.contains(ServerProtocol.AUTH_AUTHORITY) || url.contains(ServerProtocol.API_AUTHORITY) || url.contains(ServerProtocol.AGE_AUTH_AUTHORITY)) {
                // 로그인창, 동의창
                webView.loadUrl(url, headers);
            } else {
                //full browser!!!
                final Context context = getContext();
                try {
                    context.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
                } catch (ActivityNotFoundException e) {
                    Toast.makeText(context, e.getLocalizedMessage(), Toast.LENGTH_SHORT).show();
                }
            }
            return true;
        }

        @Override
        public void onReceivedError(WebView view, int errorCode,
                                    String description, String failingUrl) {
            super.onReceivedError(view, errorCode, description, failingUrl);
            sendErrorToListener(new KakaoWebviewException(errorCode, description, failingUrl));
            dismiss();
        }

        @Override
        public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
            super.onReceivedSslError(view, handler, error);

            sendErrorToListener(new KakaoWebviewException(ERROR_FAILED_SSL_HANDSHAKE, null, null));
            handler.cancel();
            dismiss();
        }

        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            Logger.d("Webview loading URL: " + url);
            super.onPageStarted(view, url, favicon);
            if (!isDetached) {
                spinner.show();
            }
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            if (!isDetached) {
                spinner.dismiss();
            }
            contentFrameLayout.setBackgroundColor(Color.TRANSPARENT);
            webView.setVisibility(View.VISIBLE);
            crossImageView.setVisibility(View.VISIBLE);
        }
    }

    /**
     * KakaoWebChromeClient
     */
    private class KakaoWebChromeClient extends WebChromeClient {
        @Override
        public boolean onJsAlert(WebView view, String url, String message, final JsResult result) {
            new AlertDialog.Builder(getContext()).setMessage(message).setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {

                @Override
                public void onClick(DialogInterface dialog, int which) {
                    result.confirm();
                }
            }).setCancelable(false).create().show();
            return true;
        }

        @Override
        public boolean onJsConfirm(WebView view, String url, String message, final JsResult result) {

            String msg = null;
            String positive = null;
            String negative = null;

            try {
                JSONObject object = new JSONObject(message);

                msg = object.optString("message");
                positive = object.optString("positive");
                negative = object.optString("negative");

            } catch (JSONException e) {
                Logger.e("JSONException: " + e.getMessage());
            } finally {

                msg = TextUtils.isEmpty(msg) ? message : msg;
                positive = TextUtils.isEmpty(positive) ? getContext().getString(android.R.string.ok) : positive;
                negative = TextUtils.isEmpty(negative) ? getContext().getString(android.R.string.cancel) : negative;

                new AlertDialog.Builder(getContext())
                        .setMessage(msg)
                        .setPositiveButton(positive, new DialogInterface.OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                result.confirm();
                            }
                        }).setNegativeButton(negative, new DialogInterface.OnClickListener() {

                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        result.cancel();
                    }
                }).setCancelable(false).create().show();
            }

            return true;
        }

        @TargetApi(Build.VERSION_CODES.FROYO)
        @Override
        public boolean onConsoleMessage(ConsoleMessage consoleMessage) {
            Logger.d("KakaoAccountWebView", consoleMessage.message()
                    + " -- (" + consoleMessage.lineNumber() + "/" + consoleMessage.sourceId() + ")");
            return true;
        }

        @Override
        @Deprecated
        public void onConsoleMessage(String message, int lineNumber, String sourceID) {
            Logger.d("KakaoAccountWebView", message
                    + " -- (" + lineNumber + "/" + sourceID + ")");
        }
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);

        if (isUsingTimer && !spinner.isShowing()) {
            if (hasFocus) {
                webView.resumeTimers();
            } else {
                webView.pauseTimers();
            }
        }
    }

    private void registerSmsReceiverIfNeeded() {
        if (!useSmsReceiver) {
            return;
        }

        if (smsReceiver != null) {
            return;
        }
        Logger.d("registerSmsReceiver");

        smsReceiver = new SmsReceiver(new ISmsReceiver() {
            @Override
            public void onCompleteSms(String code) {
                Logger.d("++ onCompleteSms(%s)", code);
                if (!TextUtils.isEmpty(code)) {
                    final String url = String.format(Locale.US, "javascript:insertSms('%s')", code);
                    Logger.d("++ command : " + url);
                    webView.loadUrl(url);
                }
            }
        });

        IntentFilter filter = new IntentFilter();
        filter.addAction(SmsReceiver.ACTION);
        filter.setPriority(999);  // 행아웃에서 SMS수신 가능한 경우에도 SMS를 받으려면 priority를 3보다 높아야 한다.
        getContext().getApplicationContext().registerReceiver(smsReceiver, filter);
    }

    private void unRegisterSmsReceiverIfNeeded() {
        if (smsReceiver != null) {
            try {
                Logger.d("unregisterSmsReceiver");
                getContext().getApplicationContext().unregisterReceiver(smsReceiver);
            } catch (Exception ignore) {
            }
            smsReceiver = null;
        }
    }
}
