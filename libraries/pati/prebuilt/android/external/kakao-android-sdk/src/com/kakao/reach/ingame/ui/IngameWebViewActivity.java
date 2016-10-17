package com.kakao.reach.ingame.ui;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.net.Uri;
import android.net.http.SslError;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.SslErrorHandler;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.ProgressBar;

import com.kakao.gameutil.helper.GameServerProtocol;
import com.kakao.android.sdk.R;
import com.kakao.reach.ingame.ui.component.BaseWebViewActivity;
import com.kakao.reach.ingame.ui.component.CommonWebViewClient;
import com.kakao.util.helper.log.Logger;

import java.util.HashMap;

/**
 * Created by seed on 15. 9. 9..
 */
public class IngameWebViewActivity extends BaseWebViewActivity {
    protected ProgressBar progressBar;
    protected NavigationBar naviBar;

    protected CommonWebViewClient webViewClient;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.kakao_reach_ingame_webview_activity);

        webView = (WebView) findViewById(R.id.kakao_reach_ingame_webview);
        progressBar = (ProgressBar) findViewById(R.id.kakao_reach_ingame_progreesbar);
        View navigationBar = findViewById(R.id.kakao_reach_ingame_navigation_bar);

        naviBar = new NavigationBar(navigationBar);

        webViewClient = new CommonWebViewClient(progressBar);
        webViewClient.registerProcessor(new EventClick());
        webViewClient.registerProcessor(new Outlink());
        webViewClient.setOnReceiveErrorListener(new CommonWebViewClient.OnReceiveErrorListener() {
            @Override
            public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
                String message;
                switch (errorCode) {
                    case WebViewClient.ERROR_TIMEOUT:
                        message = "네트워크 사정이 좋지 않습니다.\n잠시 후 다시 시도해 주십시오.";
                        break;
                    default:
                        message = "알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해 주십시오.";
                        break;
                }
                showErrorAlert(message);
            }

            @Override
            public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
            }
        });

        webView.setWebViewClient(webViewClient);
        webView.setWebChromeClient(new WebChromeClient());

        requestGoHome();
    }

    @Override
    public void onBackPressed() {
        if (!super.requestGoBack())
            super.onBackPressed();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);

        naviBar.onConfigurationChanged(newConfig);
    }

    @Override
    public String getHomeUrl() {
        HashMap<String, String> queryParams = new HashMap<String, String>();

        String ori = getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT ? "p" : "l";
        queryParams.put("ori", ori);

        Uri.Builder builder = Uri.parse(requestUrl).buildUpon();
        for (String key: queryParams.keySet())
            builder.appendQueryParameter(key, queryParams.get(key));

        return builder.build().toString();
    }

    private void requestScrollTop() {
        webView.scrollTo(0, 0);
    }

    class EventClick implements CommonWebViewClient.UrlSchemeProcessor {

        @Override
        public String getScheme() {
            return GameServerProtocol.REACH_WEB_APP_URL_SCHEME;
        }

        @Override
        public String getAuthority() {
            return "ingame";
        }

        @Override
        public String getPath() {
            return "event";
        }

        @Override
        public boolean process(WebView webView, String url) {
            Uri uri = Uri.parse(url);
            String onClick = uri.getQueryParameter("onClick");

            if (onClick.equalsIgnoreCase("close")) {
                setResult(RESULT_OK);
                finish();
            }

            return true;
        }
    }

    class Outlink implements CommonWebViewClient.UrlSchemeProcessor {

        @Override
        public String getScheme() {
            return GameServerProtocol.REACH_WEB_APP_URL_SCHEME;
        }

        @Override
        public String getAuthority() {
            return "ingame";
        }

        @Override
        public String getPath() {
            return "outlink";
        }

        @Override
        public boolean process(WebView webView, String url) {
            Uri uri = Uri.parse(url);
            String outlinkUrl = uri.getQueryParameter("url");

            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(outlinkUrl));
            try {
                startActivity(intent);
            } catch (ActivityNotFoundException e) {
                Logger.e(e.getMessage());
            }

            return true;
        }
    }

    class NavigationBar implements View.OnClickListener {
        private View rootView;
        private Button homeButton;
        private Button backButton;
        private Button forwardButton;
        private Button refreshButton;
        private Button topButton;
        private Button closeButton;

        NavigationBar(View v) {
            rootView = v;

            homeButton = (Button) rootView.findViewById(R.id.kakao_reach_ingame_home);
            homeButton.setOnClickListener(this);

            backButton = (Button) rootView.findViewById(R.id.kakao_reach_ingame_back);
            backButton.setOnClickListener(this);

            forwardButton = (Button) rootView.findViewById(R.id.kakao_reach_ingame_forward);
            forwardButton.setOnClickListener(this);

            refreshButton = (Button) rootView.findViewById(R.id.kakao_reach_ingame_refresh);
            refreshButton.setOnClickListener(this);

            topButton = (Button) rootView.findViewById(R.id.kakao_reach_ingame_top);
            topButton.setOnClickListener(this);

            closeButton = (Button) rootView.findViewById(R.id.kakao_reach_ingame_close);
            closeButton.setOnClickListener(this);

            onOrientationChanged(getResources().getConfiguration().orientation);
        }

        @Override
        public void onClick(View v) {
            int id = v.getId();

            if (id == R.id.kakao_reach_ingame_home) {
                onClickHome();
            } else if (id == R.id.kakao_reach_ingame_back) {
                onClickBack();
            } else if (id == R.id.kakao_reach_ingame_forward) {
                onClickForward();
            } else if (id == R.id.kakao_reach_ingame_refresh) {
                onClickRefresh();
            } else if (id == R.id.kakao_reach_ingame_top) {
                onClickScrollTop();
            } else if (id == R.id.kakao_reach_ingame_close) {
                onClickClose();
            }
        }

        public void onConfigurationChanged(Configuration newConfig) {
            onOrientationChanged(newConfig.orientation);
        }

        public void onOrientationChanged(int orientation) {
            Resources res = getResources();
            int margin1;
            int margin2;
            int width;

            if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
                width = res.getDimensionPixelSize(R.dimen.kakao_reach_ingame_navigation_bar_button_width_landscape);
                margin1 = res.getDimensionPixelSize(R.dimen.kakao_reach_ingame_navigation_bar_button_margin1_landscape);
                margin2 = res.getDimensionPixelSize(R.dimen.kakao_reach_ingame_navigation_bar_button_margin2_landscape);
            } else /*if (orientation == Configuration.ORIENTATION_PORTRAIT)*/ {
                width = res.getDimensionPixelSize(R.dimen.kakao_reach_ingame_navigation_bar_button_width_portrait);
                margin1 = res.getDimensionPixelSize(R.dimen.kakao_reach_ingame_navigation_bar_button_margin1_portrait);
                margin2 = res.getDimensionPixelSize(R.dimen.kakao_reach_ingame_navigation_bar_button_margin2_portrait);
            }

            View[] buttons = new View[] {
                    homeButton, backButton, forwardButton, refreshButton, topButton, closeButton
            };

            for (int i = 0; i < buttons.length; i++) {
                View button = buttons[i];

                ViewGroup.MarginLayoutParams params = (ViewGroup.MarginLayoutParams) button.getLayoutParams();
                if (i == 0)
                    params.setMargins(margin1, 0, 0, 0);
                else if (i == buttons.length - 1)
                    params.setMargins(margin2, 0, margin1, 0);
                else
                    params.setMargins(margin2, 0, 0, 0);

                button.setLayoutParams(params);
            }
        }

        private void onClickHome() {
            requestGoHome();
        }

        private void onClickBack() {
            requestGoBack();
        }

        private void onClickForward() {
            requestGoForward();
        }

        private void onClickRefresh() {
            requestRefresh();
        }

        private void onClickScrollTop() {
            requestScrollTop();
        }

        private void onClickClose() {
            setResult(RESULT_OK);
            finish();
        }
    }
}