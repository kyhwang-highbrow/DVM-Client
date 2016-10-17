package com.kakao.reach.ingame.ui.component;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.net.Uri;
import android.net.http.SslError;
import android.text.TextUtils;
import android.view.View;
import android.webkit.SslErrorHandler;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ProgressBar;

import com.kakao.util.helper.CommonProtocol;
import com.kakao.util.helper.log.Logger;

import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.List;

/**
 * Created by seed on 2015. 10. 1..
 */
public class CommonWebViewClient extends WebViewClient {
    public interface OnReceiveErrorListener {
        void onReceivedError(WebView view, int errorCode, String description, String failingUrl);

        void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error);
    }

    public interface OnLoadUrlListener {
        void onLoadUrl(WebView view, String url);
    }

    public interface UrlSchemeProcessor {
        String getScheme();

        String getAuthority();

        String getPath();

        boolean process(WebView webView, String url);
    }

    protected final ProgressBar progressBar;

    protected OnReceiveErrorListener onReceiveErrorListener;
    protected OnLoadUrlListener onLoadUrlListener;
    protected HashMap<String, UrlSchemeProcessor> processors;

    public CommonWebViewClient(ProgressBar progressBar) {
        this.progressBar = progressBar;
    }

    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
        if (isWebUrl(url)) {
            onLoadWebUrlScheme(view, url);
            return false;
        } else {
            onLoadAppUrlScheme(view, url);
            return true;
        }
    }

    @Override
    public void onPageStarted(WebView view, String url, Bitmap favicon) {
        super.onPageStarted(view, url, favicon);
        if (progressBar != null)
            progressBar.setVisibility(View.VISIBLE);
    }

    @Override
    public void onPageFinished(WebView view, String url) {
        super.onPageFinished(view, url);
        if (progressBar != null)
            progressBar.setVisibility(View.GONE);
    }

    @Override
    public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
        Logger.e("onReceivedError " + errorCode + " " + description);

        super.onReceivedError(view, errorCode, description, failingUrl);
        view.loadUrl("about:blank");
        if (onReceiveErrorListener != null)
            onReceiveErrorListener.onReceivedError(view, errorCode, description, failingUrl);
    }

    @Override
    public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
        Logger.e("onReceivedError " + error.getPrimaryError());

        super.onReceivedSslError(view, handler, error);
        if (onReceiveErrorListener != null)
            onReceiveErrorListener.onReceivedSslError(view, handler, error);
    }

    public void setOnReceiveErrorListener(OnReceiveErrorListener listener) {
        this.onReceiveErrorListener = listener;
    }

    public void setOnLoadUrlListener(OnLoadUrlListener listener) {
        this.onLoadUrlListener = listener;
    }

    public UrlSchemeProcessor getProcessor(String url) {
        if (processors == null)
            return null;

        Uri uri = Uri.parse(url);
        String scheme = uri.getScheme();
        String authority = uri.getAuthority();
        String path = uri.getPath();
        String key = buildKey(scheme, authority, path);

        return processors.get(key);
    }

    public void registerProcessor(UrlSchemeProcessor processor) {
        String scheme = processor.getScheme();
        String authority = processor.getAuthority();
        String path = processor.getPath();
        String key = buildKey(scheme, authority, path);

        if (processors == null)
            processors = new HashMap<String, UrlSchemeProcessor>();

        processors.put(key, processor);
    }

    protected boolean onLoadWebUrlScheme(WebView view, String url) {
        if (onLoadUrlListener != null)
            onLoadUrlListener.onLoadUrl(view, url);
        return false;
    }

    protected boolean onLoadAppUrlScheme(WebView view, String url) {
        Context context = view.getContext();

        UrlSchemeProcessor processor = getProcessor(url);
        Intent intent = getIntent(url);

        if (processor != null) {
            processor.process(view, url);
        } else if (intent != null && isAvailable(intent, context)) {
            try {
                context.startActivity(intent);
            } catch (ActivityNotFoundException e) {
                Logger.e(e.getMessage());
            }
        }

        return true;
    }

    protected static boolean isWebUrl(String url) {
        if (url.startsWith("http") || url.startsWith(CommonProtocol.URL_SCHEME))
            return true;
        else
            return false;
    }

    protected static String buildKey(String scheme, String authority, String path) {
        Uri.Builder builder = new Uri.Builder();
        builder.scheme(scheme).authority(authority);
        if (!TextUtils.isEmpty(path))
            builder.path(path);

        return builder.build().toString();
    }

    protected static boolean isAvailable(Intent intent, Context context) {
        List<ResolveInfo> infos = context.getPackageManager().queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);
        if (infos.size() > 0)
            return true;
        else
            return false;
    }

    protected static Intent getIntent(String url) {
        Intent intent = null;

        try {
            intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME);
        } catch (URISyntaxException e) {
            Logger.e(e.getMessage());
        } finally {
            return intent;
        }
    }
}
