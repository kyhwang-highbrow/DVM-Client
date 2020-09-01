package com.perplelab.xsolla

import com.perplelab.*
import com.perplelab.util.PerpleUtil
import com.perplelab.util.PerpleWebView

import android.os.AsyncTask
import org.json.JSONArray
import org.json.JSONObject
import java.io.FileNotFoundException
import java.net.HttpURLConnection
import java.net.URL
import java.util.*


/**
 *  @author mskim
 *  @version 1.0
 *  @language Kotlin
 *
 *  PerpleXsolla is helper class for using xsolla.
 *
 */
// prime constructor
class PerpleXsolla(merchantId: Int, apiKey: String, projectId: Int, secretKey: String, isSandbox: Boolean) {
    private val LOG_TAG = "PerpleXsolla"

    private val mMerchantId: Int = merchantId
    private val mAPIKey: String = apiKey
    private val mProjectId: Int = projectId
    private val mSecretKey: String = secretKey // use only webhook server
    private val mIsSandbox = isSandbox

    init {
        PerpleLog.v(LOG_TAG, "Initializing Xsolla")
        PerpleLog.d(LOG_TAG, "Merchant ID : $mMerchantId API Key : $mAPIKey Project ID : $mProjectId Secret Key : $mSecretKey")
    }

    private var mPayload: JSONObject? = null
    private var mPaymentCallback: PerpleSDKCallback? = null
    private var mPaymentInfoUrl: String? = null
    private lateinit var mToken: String
    // private lateinit var mWebView: PerpleWebView // cause memory leak after close webView

    init {
        if (mIsSandbox) PerpleLog.d(LOG_TAG, "Initializing Xsolla : SANDBOX_MODE ON!")
    }


    // public ----------------------------------------------------------------------

    fun setPaymentInfoUrl(paymentInfoUrl: String) {
        PerpleLog.d(LOG_TAG, "payment info url : $paymentInfoUrl")
        mPaymentInfoUrl = paymentInfoUrl
    }

    // @ex https://sandbox-secure.xsolla.com/paystation2/?access_token=eipnkZp58p75ncqzKOD7kWKpdHN6CiBU
    fun openPaymentUI(payloadString: String, callback: PerpleSDKCallback) {
        // check data
        try {
            mPayload = JSONObject(payloadString)
            mPaymentCallback = callback
        }
        catch (ex: Exception) {
            PerpleLog.d(LOG_TAG, payloadString)
            callback.onFail("Invalid Payment Info.")
            return
        }

        // send payment info -> get payment ui token
        run {
            val getTokenTask: HttpRequestTask?
            val sendPaymentInfoTask: HttpRequestTask?

            getTokenTask = HttpRequestTask(object: HttpRequestCallback{
                override fun doRequest(): String? = requestGetTokenForPaymentUI()
                override fun onSuccess(info: String?) {
                    mToken = info.toString()
                    val url: String = if (mIsSandbox)
                        "https://sandbox-secure.xsolla.com/paystation3/?access_token=$info"
                    else
                        "https://secure.xsolla.com/paystation3/?access_token=$info"
                    openWebView(url)
                }
                override fun onFail(info: String?) = callback.onFail(info)
            })
            sendPaymentInfoTask = HttpRequestTask(object: HttpRequestCallback{
                override fun doRequest(): String? = requestSendPaymentInfo()
                override fun onSuccess(info: String?) { getTokenTask.execute() }
                override fun onFail(info: String?) = callback.onFail(info)
            })

            sendPaymentInfoTask.execute()
        }
    }


    // private ----------------------------------------------------------------------

    private fun requestSendPaymentInfo(): String? {
        PerpleLog.d(LOG_TAG, "private fun requestSendPaymentInfo(): String?")
        mPaymentInfoUrl?.let { url ->
            val data = JSONObject().apply {
                val copyPayload = JSONObject(mPayload.toString())
                copyPayload.remove("nick")

                put("platform", "xsolla")
                put("payload", copyPayload)
            }
            PerpleLog.d(LOG_TAG, "payment data : $data")

            val responseString = PerpleSDK.httpRequest(url, data.toString())
            PerpleLog.d(LOG_TAG, "payment response : $responseString")

            return JSONObject(responseString).get("status").toString()
        }

        throw Exception("fail")
    }

    private fun requestGetTokenForPaymentUI(): String? {
        PerpleLog.d(LOG_TAG, "private fun requestGetTokenForPaymentUI(): String?")

        val data = makePaymentUIRequestData() ?: return null
        PerpleLog.d(LOG_TAG, data)

        val url = "https://api.xsolla.com/merchant/v2/merchants/$mMerchantId/token"
        val responseString = httpRequestBasicAuth(url, data.toString())
        PerpleLog.d(LOG_TAG, responseString)

        val response = JSONObject(responseString)
        return response.get("token").toString()
    }

    // belong to requestGetTokenForPaymentUI
    private fun makePaymentUIRequestData(): JSONObject? {
        // if mPayload is not null
        mPayload?.let { payload ->

            // return json object
            return JSONObject().also { data->
                // user
                val user = JSONObject().also { user->
                    val userId = JSONObject()
                    userId.put("value", payload.get("uid"))
                    userId.put("hidden", true)

                    val userName = JSONObject()
                    userName.put("value", payload.get("nick"))
                    userName.put("hidden", false)

                    user.put("id", userId)
                    user.put("name", userName)
                }

                // settings
                val settings = JSONObject().also { settings ->
                    val ui = JSONObject()
                    ui.put("theme", "default")
                    ui.put("size", "medium")
                    ui.put("version", "mobile")

                    settings.put("ui", ui)
                    settings.put("project_id", mProjectId)
                    settings.put("external_id", payload.get("validation_key"))
                    if (mIsSandbox)
                        settings.put("mode", "sandbox")
                }

                // purchase
                val purchase = JSONObject().apply {
                    val checkout = JSONObject()
                    checkout.put("currency", payload.get("currency"))
                    checkout.put("amount", payload.get("price"))
                    this.put("checkout", checkout)
                }

                // custom parameters
                val customParams = JSONObject().apply {
                    put("product_id", payload.get("product_id"))
                    put("price", payload.get("price"))
                }

                // *** end ***
                data.put("user", user)
                data.put("settings", settings)
                data.put("purchase", purchase)
                data.put("custom_parameters", customParams)
            }
        }

        return null
    }

    // belong to requestGetTokenForPaymentUI
    private fun httpRequestBasicAuth(urlStr: String, data: String): String {
        var con: HttpURLConnection? = null
        var responseString = ""

        try {
            val url = URL(urlStr)
            val apiKeyEnc = PerpleUtil.encodeBase64("$mMerchantId:$mAPIKey") // username:password

            con = (url.openConnection() as HttpURLConnection).apply{
                doOutput = true
                doInput = true
                connectTimeout = 10000
                readTimeout = 10000
                requestMethod = "POST"

                // HTTP request header
                setRequestProperty("Authorization", "Basic $apiKeyEnc")
                setRequestProperty("Content-Type", "application/json")
                setRequestProperty("Accept", "application/json")
                setRequestProperty("Cache-Control", "no-cache") //optional
            }
            con.connect()

            // HTTP request
            val os = con.outputStream
            os.write(data.toByteArray(charset("UTF-8")))
            os.close()

            // Read the response into a string
            val inputStream = con.inputStream
            responseString = Scanner(inputStream, "UTF-8").useDelimiter("\\A").next()
            inputStream.close()

        } catch (ex: Exception) {
            PerpleLog.d(LOG_TAG, ex.toString())

        } finally {
            con?.disconnect()
            return responseString
        }
    }


    private fun openWebView(url: String) {
        PerpleLog.d(LOG_TAG, "open webView : $url")
        // webView init
        PerpleWebView(PerpleSDK.getInstance().mainActivity, 60, 90).apply {
            setCloseCallback(mPaymentCallback)
            loadUrl(url)
        }
    }
}




private interface HttpRequestCallback {
    fun doRequest(): String?
    fun onSuccess(info: String?)
    fun onFail(info: String?)
}

private class HttpRequestTask(callback : HttpRequestCallback) : AsyncTask<Void, Void, Int>() {
    private val LOG_TAG = "HttpRequestTask"
    private var mCallback = callback
    private var msg: String? = null

    override fun doInBackground(vararg params: Void?): Int {
        var ret = 1

        try {
            msg = mCallback.doRequest()
        } catch (ex: FileNotFoundException) {
            PerpleLog.d(LOG_TAG, ex.toString())
            ret = 0
            msg = "Attempt to invalidate payment."
        } catch (ex: Exception) {
            PerpleLog.d(LOG_TAG, ex.toString())
            ret = 0
            msg = ex.toString()
        }

        return ret
    }

    override fun onPostExecute(result: Int?) {
        PerpleLog.d(LOG_TAG, "(result = $result // msg = $msg )")

        if (result == 1) {
            mCallback.onSuccess(msg)
        } else
            mCallback.onFail(msg)
    }
}