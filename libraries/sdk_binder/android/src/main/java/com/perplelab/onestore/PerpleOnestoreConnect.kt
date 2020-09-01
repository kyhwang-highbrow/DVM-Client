package com.perplelab.onestore

import com.onestore.iap.api.AppInstaller
import com.perplelab.PerpleSDK
import com.onestore.iap.api.PurchaseClient
import com.perplelab.PerpleLog
import com.onestore.iap.api.IapResult

class PerpleOnestoreConnect(purchaseClient: PurchaseClient) {
    private val LOG_TAG = "PerpleOnestoreConnect"
    private val mPurchaseClient = purchaseClient
    private var mConnectCallBack: ((Boolean)->Unit)? = null

    //@Do 원스토어 업데이트 or 설치
    fun updateOrInstallOneStoreService(callBack: ((Boolean)->Unit)?) {
        PurchaseClient.launchUpdateOrInstallFlow(PerpleSDK.getInstance().mainActivity)
        callBack?.invoke(false)
    }

    //@Do 원스토어 연결 확인 //@When 게임 진입 시
    var mServiceConnectionListener: PurchaseClient.ServiceConnectionListener = object : PurchaseClient.ServiceConnectionListener {
        override fun onConnected() {
            PerpleLog.d(LOG_TAG, "Service connected")
            PerpleSDK.getOnestore().mPerpleOnestoreBilling.checkPurchaseState()
        }

        override fun onDisconnected() {
            PerpleLog.d(LOG_TAG, "Service disconnected")
        }

        override fun onErrorNeedUpdateException() {
            PerpleLog.d(LOG_TAG, "connect onError, 원스토어 서비스앱의 업데이트가 필요합니다")
            //updateOrInstallOneStoreService() // 실패하더라도 게임은 시작하도록 진행되도록 넘어간다
        }
    }

    //@Do 원스토어에 로그인 시작 //@When 상품 구매
    fun loadLoginFlow(callBack: ((Boolean)->Unit)?) {
        mConnectCallBack = callBack
        PerpleLog.d(LOG_TAG, "loadLoginFlow()")
        mPurchaseClient.launchLoginFlowAsync(PerpleSDK.getOnestore().IAP_API_VERSION, PerpleSDK.getInstance().mainActivity, PerpleSDK.RC_ONE_STORE_LOGIN, mLoginFlowListener)
    }

    //@ PurchaseClient의 launchLoginFlowAsync API (로그인) 콜백 리스너
    private var mLoginFlowListener: PurchaseClient.LoginFlowListener = object : PurchaseClient.LoginFlowListener {
        override fun onSuccess() {
            PerpleLog.d(LOG_TAG, "launchLoginFlowAsync onSuccess")
            mConnectCallBack?.invoke(true)
        }

        override fun onError(result: IapResult) {
            PerpleLog.e(LOG_TAG, "launchLoginFlowAsync onError, $result")
            mConnectCallBack?.invoke(false)
        }

        override fun onErrorRemoteException() {
            PerpleLog.e(LOG_TAG, "launchLoginFlowAsync onError, 원스토어 서비스와 연결을 할 수 없습니다")
            mConnectCallBack?.invoke(false)
        }

        override fun onErrorSecurityException() {
            PerpleLog.e(LOG_TAG, "launchLoginFlowAsync onError, 비정상 앱에서 결제가 요청되었습니다")
            mConnectCallBack?.invoke(false)
        }

        override fun onErrorNeedUpdateException() {
            PerpleLog.e(LOG_TAG, "launchLoginFlowAsync onError, 원스토어 서비스앱의 업데이트가 필요합니다")
            updateOrInstallOneStoreService(mConnectCallBack)
        }
    }
}