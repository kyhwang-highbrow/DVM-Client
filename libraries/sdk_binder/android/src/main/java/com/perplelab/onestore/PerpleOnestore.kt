package com.perplelab.onestore

import android.app.Activity
import android.content.Intent
import com.perplelab.*
import com.onestore.iap.api.PurchaseClient
import com.perplelab.PerpleSDK

class PerpleOnestore(publicKey: String){
    val LOG_TAG = "PerpleOnestore"
    val IAP_API_VERSION = 5

    private var mPurchaseClient: PurchaseClient = PurchaseClient(PerpleSDK.getInstance().mainActivity, publicKey)
    var mPerpleOnestoreConnect: PerpleOnestoreConnect = PerpleOnestoreConnect(mPurchaseClient)
    var mPerpleOnestoreBilling: PerpleOnestoreBilling = PerpleOnestoreBilling(mPurchaseClient)

    fun initOnestore(){
        // 원스토어 서비스와 연결 확인
        mPurchaseClient.connect(mPerpleOnestoreConnect.mServiceConnectionListener)
    }

    fun onDestroy(){
        PerpleLog.d(LOG_TAG, "onDestroy()");
        mPurchaseClient.terminate()
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent) {
        PerpleLog.e(LOG_TAG, "onActivityResult resultCode $resultCode")

        when (requestCode) {
            PerpleSDK.RC_ONE_STORE_LOGIN ->
                 //@ launchLoginFlowAsync API 호출 시 전달받은 intent 데이터를 handleLoginData를 통하여 응답값을 파싱
                 //@ 파싱 이후 응답 결과를 launchLoginFlowAsync 호출 시 넘겨준 LoginFlowListener 를 통하여 전달
                if (resultCode == Activity.RESULT_OK) {
                    if (mPurchaseClient.handleLoginData(data) == false) {
                        // listener is null
                    }
                } else {
                    // user canceled , do nothing..
                }

            PerpleSDK.RC_ONE_STORE_PURCHASE ->
                //@ launchPurchaseFlowAsync API 호출 시 전달받은 intent 데이터를 handlePurchaseData를 통하여 응답값을 파싱
                //@ 파싱 이후 응답 결과를 launchPurchaseFlowAsync 호출 시 넘겨준 PurchaseFlowListener 를 통하여 전달
                if (resultCode == Activity.RESULT_OK) {
                    if (mPurchaseClient.handlePurchaseData(data) == false) {
                        // listener is null
                    }
                } else {
                    // user canceled , do nothing..
                }
            else -> PerpleLog.e(LOG_TAG, "Else PerleLog")
        }
    }
}
