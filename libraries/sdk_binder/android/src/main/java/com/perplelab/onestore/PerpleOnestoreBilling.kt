package com.perplelab.onestore

import android.os.AsyncTask
import com.onestore.iap.api.*
import com.perplelab.PerpleSDK
import com.perplelab.PerpleLog

import com.perplelab.PerpleSDKCallback
import org.json.JSONObject
import java.io.FileNotFoundException
import java.util.*
import kotlin.collections.ArrayList
import java.util.StringTokenizer
import com.onestore.iap.api.PurchaseData
import com.onestore.iap.api.IapEnum
import com.onestore.iap.api.IapResult
import com.onestore.iap.api.PurchaseClient
import com.perplelab.billing.util.Purchase
import org.json.JSONException


class PerpleOnestoreBilling(purchaseClient: PurchaseClient) {
    private val LOG_TAG = "PerpleOnestoreBilling"
    private val mPurchaseClient: PurchaseClient = purchaseClient
    private val mPurchases: HashMap<String, PurchaseData> = HashMap<String, PurchaseData>() // 영수증 검사까지 끝나고 consume이 되기 전의 상품들 관리

    private var mPurchaseCallBack: PerpleSDKCallback? = null // 구매 통신 후 콜백
    private var mGetItemCallBack: PerpleSDKCallback? = null // 상품 목록 불러오기 후 콜백
    private var mCancelSubscriptionCallBack: PerpleSDKCallback? = null // 구독 취소 후 콜맥
    private var mDeveloperPayload: JSONObject? = null
    private var mUid: String = ""

    // @Do uid 저장
    // @When 게임 내에서 uid가 확정되었을 경우
    fun setUid(uid: String) {
        mUid = uid
    }

    // @Do 구매 가능한 상태인지 확인
    fun isOnestorePurchaseAvailable(callBack: PerpleSDKCallback?) {
        checkBillingSupportedAndTryToConnect(fun(isSuccess: Boolean){
            if (isSuccess){
                callBack?.onSuccess("")
            }else{
                callBack?.onFail("")
            }
        })
    }

    // @Do 원스토어와 연결 시도
    fun checkBillingSupportedAndTryToConnect(isReadyForBuyCallBack: ((Boolean)->Unit)?){

        // @return 연결 여부
        // @return 연결되어 있지 않다면 연결 시도(로그인 or 앱 설치)한 후 연결 성공 여부
        val checkConnectConditionListener: PurchaseClient.BillingSupportedListener = object : PurchaseClient.BillingSupportedListener {
            override fun onSuccess() {isReadyForBuyCallBack?.invoke(true)}
            override fun onErrorRemoteException() {onPerpleErrorRemoteException(null); PerpleSDK.getOnestore().mPerpleOnestoreConnect.updateOrInstallOneStoreService(isReadyForBuyCallBack)}
            override fun onErrorSecurityException() {onPerpleErrorSecurityException(null);isReadyForBuyCallBack?.invoke(false)}

            // 원스토어가 깔려있지 않은 경우 앱 설치로 이동
            override fun onErrorNeedUpdateException(){
                PerpleLog.e("Onestore", "onErrorNeedUpdateException 원스토어 서비스와 연결을 할 수 없습니다")
                PerpleSDK.getOnestore().mPerpleOnestoreConnect.updateOrInstallOneStoreService(isReadyForBuyCallBack)
            }

            // 로그인 되어 있지 않은 경우 로그인 요청
            // return 로그인 성공 or 실패
            override fun onError(result: IapResult){
                if (IapResult.RESULT_NEED_LOGIN == result) {
                    PerpleLog.e("Onestore", "원스토어 서비스앱에 로그인이 필요합니다")
                    PerpleSDK.getOnestore().mPerpleOnestoreConnect.loadLoginFlow(isReadyForBuyCallBack)
                }
                else{
                    isReadyForBuyCallBack?.invoke(false)
                }
            }
        }

        // 연결 상태 확인
        PerpleSDK.getInstance().getMainActivity().runOnUiThread(object : Runnable {
            @Override
            override fun run() {
                mPurchaseClient.isBillingSupportedAsync(PerpleSDK.getOnestore().IAP_API_VERSION, checkConnectConditionListener)
            }
        })
    }

    // @Do '관리형 상품' 구매
    fun buyProduct(sku: String, devPayload: String, callback : PerpleSDKCallback) {
        val productType = IapEnum.ProductType.IN_APP
        mPurchaseCallBack = callback

        // 원스토어 결제 통신에 보낼 devPayLoad를 가공
        makeDevPayLoad(devPayload, false)

        PerpleSDK.getInstance().getMainActivity().runOnUiThread(object : Runnable {
            @Override
            override fun run() {
                // 상품명을 공백("")으로 요청할 경우 개발자센터에 등록된 상품명을 결제화면에 노출
                if (!mPurchaseClient.launchPurchaseFlowAsync(PerpleSDK.getOnestore().IAP_API_VERSION, PerpleSDK.getInstance().mainActivity, PerpleSDK.RC_ONE_STORE_PURCHASE, sku, "", productType.type, mDeveloperPayload.toString(), mUid, false, mPurchaseFlowListener)) {
                    // mPurchaseFlowListener가 없을 경우
                    mPurchaseCallBack?.onFail("")
                }
            }
        })
    }

    // @Do '구독형 상품' 구매
    fun buySubscriptionProduct(sku: String, devPayload: String, callback : PerpleSDKCallback) {
        val productType = IapEnum.ProductType.AUTO
        mPurchaseCallBack = callback

        // 원스토어 결제 통신에 보낼 devPayLoad를 가공
        makeDevPayLoad(devPayload, true)

        PerpleSDK.getInstance().mainActivity.runOnUiThread(object : Runnable {
            @Override
            override fun run() {
                // 상품명을 공백("")으로 요청할 경우 개발자센터에 등록된 상품명을 결제화면에 노출
                if (!mPurchaseClient.launchPurchaseFlowAsync(PerpleSDK.getOnestore().IAP_API_VERSION, PerpleSDK.getInstance().mainActivity, PerpleSDK.RC_ONE_STORE_PURCHASE, sku, "", productType.type, mDeveloperPayload.toString(), mUid, false, mPurchaseFlowListener)) {
                    // mPurchaseFlowListener가 없을 경우
                    mPurchaseCallBack?.onFail("")
                }
            }
        })
    }

    // @Do 원스토어 결제 통신에 보낼 devPayLoad를 가공
    // @Detail payload 는 100byte 까지만 전송 가능, payload 전체가 아닌 validation_key, 상품 종류만 붙여서 devPayLoad를 생성
    private fun makeDevPayLoad(payload: String, isSubscription: Boolean){

        // payload 예시 : {"validation_key":"2f6c1cee-e342-4111-922e-cba414b61ac9","price":3300,"uid":"vYajsn96lsMa8PxvFP4VQBlexWi2","product_id":82001,"sku":"dvm_cash2_3k"}
        val payLoad = JSONObject(payload)
        mUid = payLoad.get("uid").toString() ?: ""

        // 100byte의 제한때문에 필수로 필요한 validation_key, product_id만 사용한다.
        val payloadDev = JSONObject()
        val validation_key = payLoad.get("validation_key")
        val product_id = payLoad.get("product_id")
        payloadDev.put("validation_key", validation_key)
        payloadDev.put("product_id", product_id)

        if (isSubscription) {
            payloadDev.put("is_subscription", isSubscription)
        }

        mDeveloperPayload = payloadDev
    }

    // @ buyProduct/buySubscriptionProduct 함수 리스너
    private var mPurchaseFlowListener: PurchaseClient.PurchaseFlowListener = object : PurchaseClient.PurchaseFlowListener {
        override fun onSuccess(purchaseData: PurchaseData) {
            // 페이로드 검증
            if (purchaseData.developerPayload != mDeveloperPayload.toString()){
                PerpleLog.e(LOG_TAG, "isNotValidPayload : " + purchaseData.developerPayload + mDeveloperPayload)
                mPurchaseCallBack?.onFail("fail")
                return
            }
            // 플랫폼 서버에게 전자 영수증 검증 요청
            checkReceipt(purchaseData, object: PerpleSDKCallback{
                override fun onSuccess(info: String?) {
                    mPurchases.set(purchaseData.orderId, purchaseData)
                    mPurchaseCallBack?.onSuccess(getPurchaseResult(purchaseData).toString())
                }

                override fun onFail(info: String?) {
                    mPurchaseCallBack?.onFail("fail")
                }

            })
        }

        override fun onErrorRemoteException() = onPerpleErrorRemoteException(mPurchaseCallBack)
        override fun onErrorSecurityException() = onPerpleErrorSecurityException(mPurchaseCallBack)
        override fun onErrorNeedUpdateException() = onPerpleErrorNeedUpdateException(mPurchaseCallBack)
        override fun onError(result: IapResult) = onPerpleError(result, mPurchaseCallBack)
    }

    // @Do 플랫폼 서버에게 전자 영수증 검증 요청 @When 구매 후
    private fun checkReceipt(purchaseData : PurchaseData, callBack: PerpleSDKCallback?){
        run {
            val sendPaymentInfoTask: HttpRequestTask?

            sendPaymentInfoTask = HttpRequestTask(object: HttpRequestCallback {
                override fun doRequest(): String? = requestSendPaymentInfo(purchaseData)
                // 영수증 요청 성공 시
                override fun onSuccess(info: String?) {
                    PerpleLog.d(LOG_TAG, "requestCheckReceipt onSuccess info : " + info);
                    // info 예시 : {"retcode":-100,"message":"Invalid receipt"}
                    if (getRetcode(info) == 0) {
                        callBack?.onSuccess(info)
                    }
                    else {
                        callBack?.onFail(info)
                    }
                }
                override fun onFail(info: String?) {callBack?.onFail("")}
            })

            sendPaymentInfoTask.execute()
        }
    }

    private fun getPurchaseResult(p: PurchaseData): JSONObject {
        val obj = JSONObject()
        try {
            obj.put("orderId", p.orderId)
            obj.put("payload", p.developerPayload)
        } catch (e: JSONException) {
            e.printStackTrace()
        }

        return obj
    }

	// @Do 플랫폼 서버에서 리턴받은 status에서 retcode를 리턴
    private fun getRetcode(info: String?): Int {
		// info ex ) {"retcode":-100,"message":"Invalid receipt"}
        try {
            val obj = JSONObject(info)
            return Integer.parseInt(obj.getString("retcode"))
        } catch (e: JSONException) {
            e.printStackTrace()
        }

        return -1
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

    // @Do 플랫폼 전자 영수증 통신
    private fun requestSendPaymentInfo(purchaseData: PurchaseData): String? {
        // 플랫폼 전자 영수증 통신에 보낼 param 값 생성
        val data = JSONObject()
        data.put("platform", "onestore")
        data.put("uid", mUid)
        data.put("signature", purchaseData.signature)
        data.put("receipt", purchaseData.getPurchaseData())
        PerpleLog.d(LOG_TAG, "check receipt validation param" + data.toString())

        //val responseString = PerpleSDK.httpRequest(PerpleSDK.getBilling().getPurchaseCheckReceiptUri() , data.toString())
        val responseString = PerpleSDK.httpRequest("" , data.toString())
        PerpleLog.d(LOG_TAG, "check receipt validation return" + responseString)
        return JSONObject(responseString).get("status").toString()
    }


    //@Do 원스토어 마켓에서 상품 정보 가져옴 @When 게임 진입 후
    fun getItemList(skuList: String, callback: PerpleSDKCallback){
        mGetItemCallBack = callback

        // skuList = 'diamond300;cash300...'
        val tempList = StringTokenizer(skuList, ";")
        val inappList  = ArrayList<String>()
        while (tempList.hasMoreTokens()) {
            inappList.add(tempList.nextToken())
        }

        loadProducts(IapEnum.ProductType.IN_APP, inappList)
    }

    // @Do 상품 정보 로드
    private fun loadProducts(productType: IapEnum.ProductType, products: ArrayList<String>) {
        PerpleSDK.getInstance().getMainActivity().runOnUiThread(object : Runnable {
            @Override
            override fun run() {
                mPurchaseClient.queryProductsAsync(PerpleSDK.getOnestore().IAP_API_VERSION, products, productType.type, mQueryProductsListener)
            }
        })
    }

   // @ PurchaseClient의 queryProductsAsync API (상품정보조회) 콜백 리스너
   private var mQueryProductsListener: PurchaseClient.QueryProductsListener = object : PurchaseClient.QueryProductsListener {
        override fun onSuccess(productDetails: List<ProductDetail>) {
            val itemMap = HashMap<String, String>()
            for (data in productDetails) {
                itemMap.put(data.productId, data.price)
            }
            mGetItemCallBack?.onSuccess(JSONObject(itemMap as Map<*, *>).toString())
        }

        override fun onErrorRemoteException() = onPerpleErrorRemoteException(mGetItemCallBack)
        override fun onErrorSecurityException() = onPerpleErrorSecurityException(mGetItemCallBack)
        override fun onErrorNeedUpdateException() = onPerpleErrorNeedUpdateException(mGetItemCallBack)
        override fun onError(result: IapResult) = onPerpleError(result, mGetItemCallBack)
    }

    // @요청한 상품 구독 취소
    fun cancelSubscriptPurchaseForOnestore(sku: String, callBack: PerpleSDKCallback) {
        val tempList  = ArrayList<String>()
        tempList.add(sku)
        mCancelSubscriptionCallBack = callBack

        loadSubscriptionProductsForCancel(sku)
    }

    // @Do 구매내역 조회 후 구독취소
    private fun loadSubscriptionProductsForCancel(sku: String){
        // @PurchaseClient의 queryPurchasesAsync API (구매내역조회) 콜백 리스너
        val cancelScription: PurchaseClient.QueryPurchaseListener = object : PurchaseClient.QueryPurchaseListener {
            override fun onSuccess(purchaseDataList: List<PurchaseData>, productType: String) {
                for (purchase in purchaseDataList) {
                    if (purchase.productId == sku) {
                        cancelSubscriptPurchaseForOnestore(purchase)
                        //@Warning 구독 취소 후 consumeItem 처리를 해야 재구매 가능
						//@Warning 구독 취소(=다음달 구독 취소 예약)이기 때문에 언제부터 재구매 가능하게 해줄지 고려하고 consumeItem 처리 해야함
                        return
                    }
                }
            }

            override fun onErrorRemoteException() = onPerpleErrorRemoteException(mCancelSubscriptionCallBack)
            override fun onErrorSecurityException() = onPerpleErrorSecurityException(mCancelSubscriptionCallBack)
            override fun onErrorNeedUpdateException() = onPerpleErrorNeedUpdateException(mCancelSubscriptionCallBack)
            override fun onError(result: IapResult) = onPerpleError(result, mCancelSubscriptionCallBack)
        }
        mPurchaseClient.queryPurchasesAsync(PerpleSDK.getOnestore().IAP_API_VERSION, IapEnum.ProductType.IN_APP.type, cancelScription)
    }

    // @Do 구독 취소
    fun cancelSubscriptPurchaseForOnestore(data: PurchaseData) {
        setSubscriptPurchaseForOnestore(data, false)
    }

    // @Do 구독 시작
    fun startSubscriptPurchaseForOnestore(purchaseData: PurchaseData) {
        setSubscriptPurchaseForOnestore(purchaseData,  true)
    }

    //@Do 구독 시작/구독 취소 요청
    private fun setSubscriptPurchaseForOnestore(data: PurchaseData, active: Boolean) {
        val action = if (active){
            IapEnum.RecurringAction.REACTIVATE.type
        } else {
            IapEnum.RecurringAction.CANCEL.type
        }

        // 구독 시작/취소 콜백
        val callback = if (active){
            mPurchaseCallBack
        } else {
            mCancelSubscriptionCallBack
        }

        //@ PurchaseClient의 manageRecurringProductAsync API (월정액상품 상태변경) 콜백 리스너
        val mManageRecurringProductListener: PurchaseClient.ManageRecurringProductListener = object : PurchaseClient.ManageRecurringProductListener {
            override fun onSuccess(purchaseData: PurchaseData, manageAction: String) {callback?.onSuccess("")}
            override fun onErrorRemoteException() = onPerpleErrorRemoteException(callback)
            override fun onErrorSecurityException() = onPerpleErrorSecurityException(callback)
            override fun onErrorNeedUpdateException() = onPerpleErrorNeedUpdateException(callback)
            override fun onError(result: IapResult) = onPerpleError(result, callback)
        }

        PerpleSDK.getInstance().mainActivity.runOnUiThread(object : Runnable {
            @Override
            override fun run() {
                mPurchaseClient.manageRecurringProductAsync(PerpleSDK.getOnestore().IAP_API_VERSION, data, action, mManageRecurringProductListener)
            }
        })
    }

    // @Do 구매내역조회 후 소비되지 않은 상품이 있다면 소비 // @When 게임 입장
    fun checkPurchaseState(){
        val billingSupportedListener: PurchaseClient.BillingSupportedListener = object : PurchaseClient.BillingSupportedListener {
            override fun onSuccess() = loadPurchaseAll()
            override fun onErrorRemoteException() = onPerpleErrorRemoteException(null)
            override fun onErrorSecurityException() = onPerpleErrorSecurityException(null)
            override fun onErrorNeedUpdateException() = onPerpleErrorNeedUpdateException(null)
            override fun onError(result: IapResult) = onPerpleError(result, null)
        }

        // @Do 소비할 수 있는 상태인지 확인(=원스토어에 연결된 상태인지)
        // @return onSuccess : 상품 소비/ onFail : 그냥 패스
        PerpleSDK.getInstance().mainActivity.runOnUiThread(object : Runnable {
            @Override
            override fun run() {
                mPurchaseClient.isBillingSupportedAsync(PerpleSDK.getOnestore().IAP_API_VERSION, billingSupportedListener)
            }
        })
    }

    // @Do 구매 내역 조회 (관리, 구독)
     private fun loadPurchaseAll() {
        PerpleLog.d(LOG_TAG, "loadPurchases()")

        //loadPurchase(IapEnum.ProductType.IN_APP)
        //loadPurchase(IapEnum.ProductType.AUTO)
    }

    // @Do
    fun requestPurchases(callBack: PerpleSDKCallback?) {
        PerpleLog.i(LOG_TAG, "requestPurchases(callBack: PerpleSDKCallback?)" )

        // 연결 상태 확인
        PerpleSDK.getInstance().getMainActivity().runOnUiThread(object : Runnable {
            @Override
            override fun run() {
                val queryPurchaseListener: PurchaseClient.QueryPurchaseListener = object: PurchaseClient.QueryPurchaseListener {
                    override fun onSuccess(purchaseDataList: List<PurchaseData>, productType: String) {

                        PerpleLog.i(LOG_TAG, "requestPurchases - onSuccess - count : " +  purchaseDataList.count().toString())

                        mPurchases.clear()

                        var purchase_count = purchaseDataList.count()

                        // 결제건이 하나도 없을 경우 즉시 종료
                        if (purchase_count <= 0)
                        {
                            val info : String = getPurchases(null)
                            PerpleLog.i(LOG_TAG, "requestPurchases - onSuccess - return : " +  info)
                            callBack?.onSuccess(info)
                            return
                        }

                        val finish_callback :PerpleSDKCallback = object : PerpleSDKCallback
                        {
                            override fun onSuccess(info: String?) {
                                purchase_count -= 1
                                if (purchase_count <=0) {
                                    val info : String = getPurchases(null)
                                    PerpleLog.i(LOG_TAG, "requestPurchases - onSuccess - return : " +  info)
                                    callBack?.onSuccess(info)
                                }
                            }

                            override fun onFail(info: String?) { }
                        }


                        // 상품들을 돌면서 영수증 검사, 리스트에 추가
                        for (purchaseData in purchaseDataList) {
                            PerpleLog.i(LOG_TAG, "requestPurchases - onSuccess - checkReceipt start : " +  purchaseData.orderId)
                            checkReceipt(purchaseData,object: PerpleSDKCallback{
                                override fun onSuccess(info: String?) {
                                    // 관리 상품에 추가
                                    mPurchases.set(purchaseData.orderId, purchaseData)
                                    PerpleLog.i(LOG_TAG, "requestPurchases - onSuccess - checkReceipt end : " +  purchaseData.orderId)

                                    finish_callback.onSuccess("")
                                }

                                override fun onFail(info: String?) {
                                    // 컨슘
                                    PerpleLog.i(LOG_TAG, "requestPurchases - consume : " +  purchaseData.orderId)
                                    consumeItem(purchaseData)

                                    finish_callback.onSuccess("")
                                }
                            })
                        }
                    }

                    override fun onErrorRemoteException() {callBack?.onFail("onErrorRemoteException")}
                    override fun onErrorSecurityException() {callBack?.onFail("onErrorSecurityException")}
                    override fun onErrorNeedUpdateException() {callBack?.onFail("onErrorNeedUpdateException")}
                    override fun onError(result: IapResult) {callBack?.onFail("onError")}
                }

                // @Do 구매 내역 조회
                mPurchaseClient.queryPurchasesAsync(PerpleSDK.getOnestore().IAP_API_VERSION, IapEnum.ProductType.IN_APP.type, queryPurchaseListener)
            }
        })
    }

    // @Do
    fun getPurchases(callBack: PerpleSDKCallback?): String {
        val retobj = JSONObject()
        for (data in mPurchases) {
            val purchaseData : PurchaseData = data.value
            val obj = JSONObject()
            obj.put("orderId", purchaseData.orderId)
            obj.put("payload", purchaseData.developerPayload)
            obj.put("productId", purchaseData.productId) // In-App ID (Google의 SKU에 해당함)
            obj.put("purchaseId", purchaseData.purchaseId)
            //obj.put("packageName", purchaseData.packageName) // 패키지명 com.perplelab.dragonvillagem.onestore
            //obj.put("purchaseData", purchaseData.purchaseData) // 전체 데이터

            retobj.put(purchaseData.orderId, obj)
        }

        val info : String = retobj.toString()
        callBack?.onSuccess(info)
        return info
    }

    // @Do 상품 소비
    // @When 결제 후 영수증 검사, 상품 지급까지 완료된 시점
    fun consumeByOrderid(orderid: String, callBack: PerpleSDKCallback?) {
        val purchaseData: PurchaseData? = mPurchases.get(orderid)

        if (purchaseData == null)
        {
            callBack?.onFail("")
            return
        }

        // 연결 상태 확인
        PerpleSDK.getInstance().getMainActivity().runOnUiThread(object : Runnable {
            @Override
            override fun run() {
                mPurchaseClient.consumeAsync(PerpleSDK.getOnestore().IAP_API_VERSION, purchaseData, object : PurchaseClient.ConsumeListener{
                    override fun onSuccess(p0: PurchaseData?) {
                        mPurchases.remove(purchaseData.orderId)
                        callBack?.onSuccess("")
                    }
                    override fun onErrorNeedUpdateException() { callBack?.onFail("onErrorNeedUpdateException")}
                    override fun onErrorRemoteException() { callBack?.onFail("onErrorRemoteException")}
                    override fun onError(p0: IapResult?) { callBack?.onFail("onError")}
                    override fun onErrorSecurityException() { callBack?.onFail("onErrorSecurityException")}
                })
            }
        })
    }

    // @Do 상품 소비
    // @When 게임 진입 후 (mPurchaseCallBack == nil)
    // @When 상품 구매 시 (mPurchaseCallBack != nil)
    private fun consumeItem(purchaseData: PurchaseData) {
        mPurchaseClient.consumeAsync(PerpleSDK.getOnestore().IAP_API_VERSION, purchaseData, object : PurchaseClient.ConsumeListener{
            override fun onErrorNeedUpdateException() { }
            override fun onSuccess(p0: PurchaseData?) { }
            override fun onErrorRemoteException() { }
            override fun onError(p0: IapResult?) { }
            override fun onErrorSecurityException() { }
        })
    }

    // @error 함수 관리
    private fun onPerpleErrorRemoteException(callBack: PerpleSDKCallback?){PerpleLog.e("Onestore", "onErrorRemoteException 원스토어 서비스와 연결을 할 수 없습니다"); callBack?.onFail("fail");}
    private fun onPerpleErrorSecurityException(callBack: PerpleSDKCallback?){PerpleLog.e("Onestore", "onErrorSecurityException 비정상 앱에서 결제가 요청되었습니다"); callBack?.onFail("fail");}
    private fun onPerpleErrorNeedUpdateException(callBack: PerpleSDKCallback?){PerpleLog.e("Onestore", "onPerpleErrorNeedUpdateException 원스토어 업데이트가 필요합니다."); callBack?.onFail("fail") }
    private fun onPerpleError(result: IapResult, callBack: PerpleSDKCallback?){PerpleLog.e("Onestore", "onPerpleError 원스토어 로그인이 필요합니다. 에러코드 : " + result); callBack?.onFail("fail") }
}