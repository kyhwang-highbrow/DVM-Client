package com.perplelab.util

import com.perplelab.PerpleLog
import com.perplelab.PerpleSDKCallback
import com.perplelab.R

import android.os.Build
import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.util.DisplayMetrics
import androidx.annotation.RequiresApi
import android.annotation.SuppressLint
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import android.view.View
import android.view.Gravity
import android.view.KeyEvent
import android.view.ViewGroup
import android.widget.*


/**
 *  @author mskim
 *  @version 1.0
 *  @language Kotlin
 *
 *  PerpleWebView is custom webView wrapper.
 *
 */
class PerpleWebView(context: Context) : FrameLayout(context) {
    private val LOG_TAG = "PerpleWebView"
    private var mCallback: PerpleSDKCallback? = null

    private lateinit var mWebView: WebView
    private lateinit var mProgressBar: ProgressBar
    private lateinit var mActivity: Activity

    // secondary constructor
    constructor(activity: Activity) : this(activity.applicationContext) {
        setActivity(activity)
        initView()
        initWebView()
    }
    constructor(activity: Activity, widthPercent: Int, heightPercent: Int) : this(activity.applicationContext) {
        setActivity(activity)
        initView()
        initWebView()
        setWebViewLayoutPercentage(widthPercent, heightPercent)
    }

    // public ----------------------------------------------------------------------
    // set close callback function
    fun setCloseCallback(callback: PerpleSDKCallback?) {
        mCallback = callback
    }

    fun setActivity(activity: Activity) {
        mActivity = activity
        mActivity.addContentView(this, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
    }

    fun loadUrl(url: String) {
        mWebView.loadUrl(url)
    }

    // calculate size by percentage and set size
    fun setWebViewLayoutPercentage(widthPercent: Int, heightPercent: Int) {
        // check natural number (1 to 100)
        when {
            (widthPercent in 1..100) -> {} // ok
            (heightPercent in 1..100) -> {} // ok
            else -> {
                PerpleLog.e(LOG_TAG, "WebView Layout size percentage is invalidate. must use natural number ranged 1 to 100")
                return
            }
        }

        // get display size
        val metrics = DisplayMetrics()
        mActivity.windowManager.defaultDisplay.getMetrics(metrics)
        val width = metrics.widthPixels
        val height = metrics.heightPixels

        // set
        val adjustWidth = width * widthPercent / 100
        val adjustHeight = height * heightPercent / 100
        mWebView.layoutParams = FrameLayout.LayoutParams(adjustWidth, adjustHeight).apply {
            gravity = Gravity.CENTER
        }
    }

    // private ----------------------------------------------------------------------

    private fun initView() {
        // layout inflate
        mActivity.layoutInflater.inflate(R.layout.perple_webview, this, true)

        // 사용해야 할 view instance
        mProgressBar = findViewById(R.id.webview_progressBar)
        mWebView = findViewById(R.id.webview)

        // close btn
        findViewById<Button>(R.id.close_btn).setOnClickListener {
            forceClose()
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun initWebView() {
        mWebView.settings.apply {
            javaScriptEnabled = true
            loadsImagesAutomatically = true
            useWideViewPort = true // horizontal scroll
        }
        setCustomWebViewClient()

        // webview key event
        mWebView.setOnKeyListener { _, keyCode, event ->
            if (event.action == KeyEvent.ACTION_DOWN)
                when(keyCode) {
                    KeyEvent.KEYCODE_BACK -> {
                        clickBackKey()
                        true
                    }
                    else -> false
                }
            else
                false
        }
    }

    // set customWebClient : control event
    private fun setCustomWebViewClient() {
        mWebView.webViewClient = object : WebViewClient() {

            val PREFIX_INTENT = "intent://"
            val PREFIX_GOOGLE_PLAY_STORE = "market://details?id="
            val PREFIX_SUCCESS = "http://exit"

            // local function
            fun commonShouldOverrideLoadingUrl(view: WebView?, url: String?): Boolean {
                val urlStr = url.toString()
                when {
                    urlStr.startsWith(PREFIX_SUCCESS) -> {
                        closeWebView()
                        mCallback?.onSuccess("")
                        return true
                    }
                    urlStr.startsWith(PREFIX_GOOGLE_PLAY_STORE) -> {
                        val intent = Intent.parseUri(urlStr, Intent.URI_INTENT_SCHEME)
                        try {
                            view?.context?.startActivity(intent)
                        } catch (exception: ActivityNotFoundException) {
                            val uri = Uri.parse(urlStr)
                            view?.loadUrl("https://play.google.com/store/apps/" + uri.host + "?" + uri.query)
                        }
                        return true
                    }
                    urlStr.startsWith(PREFIX_INTENT) -> {
                        val intent = Intent.parseUri(urlStr, Intent.URI_INTENT_SCHEME)
                        try {
                            view?.context?.startActivity(intent)
                        } catch (exception: ActivityNotFoundException) {
                            val marketUrl = PREFIX_GOOGLE_PLAY_STORE + intent.getPackage()
                            val marketIntent = Intent.parseUri(marketUrl, Intent.URI_INTENT_SCHEME)
                            view?.context?.startActivity(marketIntent)
                        }
                        return true
                    }
                }
                return false
            }

            @SuppressWarnings("deprecation") // for api level below 24
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                return commonShouldOverrideLoadingUrl(view, url)
            }

            @RequiresApi(Build.VERSION_CODES.N) // api level 24
            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                return commonShouldOverrideLoadingUrl(view, request?.url.toString())
            }

            override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
                mProgressBar.visibility = View.VISIBLE
            }

            override fun onPageFinished(view: WebView?, url: String?) {
                mProgressBar.visibility = View.GONE
            }
        }
    }

    // go back or close
    private fun clickBackKey() {
        if (mWebView.canGoBack())
            mWebView.goBack()
        else
            forceClose()
    }

    // close web view and cache clear
    private fun closeWebView() {
        PerpleLog.d(LOG_TAG, "WebView is closed")
        mWebView.clearCache(true)
        if (this.parent != null)
            (this.parent as ViewGroup).removeView(this)
    }

    // forced close
    private fun forceClose() {
        // delivery cancel param because it is forced close
        mCallback?.onFail("cancel")
        closeWebView()
    }
}