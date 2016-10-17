package com.kakao.reach.ingame.ui;

import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.ProgressBar;

import com.kakao.gameutil.helper.GameServerProtocol;
import com.kakao.android.sdk.R;
import com.kakao.reach.ingame.ui.component.BaseWebViewActivity;
import com.kakao.reach.ingame.ui.component.CommonWebViewClient;
import com.kakao.util.helper.CommonProtocol;

/**
 * Created by seed on 15. 10. 2..
 */
public class PlusFriendActivity extends BaseWebViewActivity {
    protected ProgressBar progressBar;
    protected Button closeButton;

    protected CommonWebViewClient webViewClient;

    private String errorUrl;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.kakao_reach_ingame_plusfriend_activity);

        this.errorUrl = new Uri.Builder().scheme(CommonProtocol.URL_SCHEME)
                .authority(GameServerProtocol.REACH_AUTHORITY)
                .path(GameServerProtocol.PUBLIC_ERROR)
                .build()
                .toString();

        webView = (WebView) findViewById(R.id.kakao_reach_ingame_webview);
        progressBar = (ProgressBar) findViewById(R.id.kakao_reach_ingame_progreesbar);
        closeButton = (Button) findViewById(R.id.kakao_reach_ingame_close);

        webViewClient = new CommonWebViewClient(progressBar);
        webViewClient.registerProcessor(new EventClick());
        webViewClient.setOnLoadUrlListener(new CommonWebViewClient.OnLoadUrlListener() {

            @Override
            public void onLoadUrl(WebView view, String url) {
                if (url.startsWith(errorUrl))
                    closeButton.setVisibility(View.VISIBLE);
            }
        });

        webView.setWebViewClient(webViewClient);
        webView.setWebChromeClient(new WebChromeClient());

        closeButton.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                setResult(RESULT_OK);
                finish();
            }
        });
        closeButton.setVisibility(View.GONE);

        requestGoHome();
    }

    @Override
    public void onBackPressed() {
        // Can not go back or finish activity
    }

    @Override
    public String getHomeUrl() {
        return requestUrl;
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
}
