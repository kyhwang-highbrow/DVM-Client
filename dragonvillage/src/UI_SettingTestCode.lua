local PARENT = UI

-------------------------------------
-- class UI_SettingTestCode
-- @brief UI_SettingDevTab은 본래 개발 및 테스트 상의 편의를 위한 기능 (모든 드래곤 추가 등..)을 구현한 곳으로 앱이 고도화 됨에 따라
-- 다양한 테스트 코드가 필요해져 감당하기 힘들어졌다.
-- 따라서 새로운 UI를 추가하여 조금은 편하게 테스트 코드를 추가 할 수 있도록 한다.
-------------------------------------
UI_SettingTestCode = class(PARENT, {
        m_menu = 'cc.Menu',
        m_buttonForCopy = 'cc.Button',
        m_buttonIdx = 'number',

        -- 버튼 정보
        m_btnInfoTable = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SettingTestCode:init()
    local vars = self:load('setting_code_test.ui')
    UIManager:open(self, UIManager.POPUP)
	
    self.m_uiName = 'UI_SettingTestCode'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SettingTestCode')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    -- self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SettingTestCode:initUI()
    m_buttonForCopy = self.vars['testCodeBtn']
    m_menu = m_buttonForCopy:getParent()
    m_buttonIdx = 0

    local width, height = m_buttonForCopy:getNormalSize()
    m_btnInfoTable = {
        ['width'] = width,
        ['height'] = height,
        ['img01'] = 'res/ui/buttons/64_base_btn_0101.png', 
        ['img02'] = 'res/ui/buttons/64_base_btn_0102.png',
    }
    m_buttonForCopy:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SettingTestCode:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    
    self:makeButtonAutomatic('testCode01', self.click_testCodeBtn)
    self:makeButtonAutomatic('testCode02', self.click_testCodeBtn2)

    self:makeButtonAutomatic('unityAdsTest00', self.unityAdsTest00)
    self:makeButtonAutomatic('unityAdsTest01', self.unityAdsTest01)
    self:makeButtonAutomatic('unityAdsTest02', self.unityAdsTest02)

    self:makeButtonAutomatic('admob init', self.admob_init)
    self:makeButtonAutomatic('admob preload', self.admob_preload)
    self:makeButtonAutomatic('admob showAd', self.admob_showAd)

    self:makeButtonAutomatic('show Personalpack', self.showPersonalpack)

    self:makeButtonAutomatic('Make Incomplete Purchase', self.makeIncompletePurchase)
    self:makeButtonAutomatic('Resotre Purchase', self.restorePurchase)

    self:makeButtonAutomatic('normal Rune Gacha', self.runeGacha)
    self:makeButtonAutomatic('normal Rune Gacha-11', self.runeGacha11)

    self:makeButtonAutomatic('앱설치확인', self.checkInstalled)

    self:makeButtonAutomatic('드래곤 획득 패키지 : 탈릿사', function() self:click_GetDragonPackage(121643) end)
    self:makeButtonAutomatic('드래곤 획득 패키지 : 세에레', function() self:click_GetDragonPackage(121735) end)
    self:makeButtonAutomatic('드래곤 획득 패키지 : 데스락', function() self:click_GetDragonPackage(121752) end)
    self:makeButtonAutomatic('드래곤 획득 패키지 : 마카라', function() self:click_GetDragonPackage(121765) end)
    self:makeButtonAutomatic('드래곤 획득 패키지 : 헤네스', function() self:click_GetDragonPackage(121771) end)
    self:makeButtonAutomatic('드래곤 획득 패키지 : 템페렌티나', function() self:click_GetDragonPackage(121784) end)
    self:makeButtonAutomatic('드래곤 획득 패키지 : 카스티타스', function() self:click_GetDragonPackage(121792) end)
    self:makeButtonAutomatic('드래곤 획득 패키지 : 밀라타스', function() self:click_GetDragonPackage(121804) end)
    self:makeButtonAutomatic('드래곤 획득 패키지 : 러스트', function() self:click_GetDragonPackage(121813) end)
    self:makeButtonAutomatic('드래곤 획득 패키지 : 글루토니', function() self:click_GetDragonPackage(121821) end)

    self:makeButtonAutomatic('드래곤 획득 패키지 등록 드래곤', function() self:click_GetDragonPackageList() end)    
end

-------------------------------------
-- function makeButtonAutomatic
-------------------------------------
function UI_SettingTestCode:makeButtonAutomatic(label_str, click_func)
    -- cc.MenuItemImage
    local menu_item = cc.MenuItemImage:create(m_btnInfoTable['img01'], m_btnInfoTable['img02'], 1)
    menu_item:setAnchorPoint(TOP_LEFT)
    menu_item:setDockPoint(TOP_LEFT)
    menu_item:setContentSize(m_btnInfoTable['width'], m_btnInfoTable['height'])
    
    -- 좌표 계산 (열 우선 정렬)
    local column_idx = math_floor(m_buttonIdx / 9)
    menu_item:setPosition(cc.p(
        column_idx * (m_btnInfoTable['width'] + 5), 
        - (m_buttonIdx - (column_idx * 9)) * (m_btnInfoTable['height'] + 5)))

    -- UIC_Button
    local uic_button = UIC_Button(menu_item)
    uic_button:registerScriptTapHandler(function()
        click_func()
    end)
    m_menu:addChild(menu_item)

    -- cc.Label
    do 
        local label = cc.Label:createWithTTF(label_str, Translate:getFontPath(), 16, 2, cc.size(m_btnInfoTable['width'], m_btnInfoTable['height']), 1, 1)
        label:setDockPoint(CENTER_POINT)
        label:setAnchorPoint(CENTER_POINT)
        label:setPosition(ZERO_POINT)
        menu_item:addChild(label)
    end

    m_buttonIdx = m_buttonIdx + 1
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_SettingTestCode:refresh()
end




-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SettingTestCode:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_testCodeBtn
-- @brief 테스트 코드
-------------------------------------
function UI_SettingTestCode:click_testCodeBtn()

    -- @sgkim 2020.03.24
    -- 원스토어 구매하고 컴슘되지 않은 상품 리스트 받아오기 테스트
    if true then
        local function callback(ret, info)
            cclog('## PerpleSDK:onestoreRequestPurchases(callback) call!! ')
            cclog('## ret : ' .. tostring(ret))
            cclog('## info : ' .. info)

            local info_json = dkjson.decode(info)
            for order_id, t_data in pairs(info_json) do
                ccdump(t_data)
            end

            local function finish_cb()
                cclog('## PaymentHelper.handlingMissingPayments_onestore 종료!!!')
            end
            local l_payload = table.MapToList(info_json)
            PaymentHelper.handlingMissingPayments_onestore(l_payload, nil, finish_cb)
        end

        PerpleSDK:onestoreRequestPurchases(callback)
        cclog('## PerpleSDK:onestoreRequestPurchases(callback) call!! ')
        return
    end

    -- @sgkim 2020.03.18
    -- 원스토어 마켓으로 이동 테스트
    if true then
        MakeSimplePopup(POPUP_TYPE.OK, 'goToWeb으로 테스트')
        --SDKManager:goToWeb(URL['DVM_ONESTORE_DOWNLOAD'])
        -- 드빌M이 아직 출시 전이라서 드빌1으로 테스트 https://onesto.re/0000285367
        local url = 'https://onesto.re/0000285367'
        SDKManager:goToWeb(url)
        return
    end

    -- @sgkim 2020.03.11
    if true then
        --MakeSimplePopup()
        local sample_sku = nil
        for sku, struct_market_product in pairs(g_shopDataNew.m_dicStructMarketProduct) do
            cclog('### sku ' .. sku)
            local currency_code = struct_market_product:getCurrencyCode()
            cclog('@ currency code : ' .. tostring(currency_code), type(currency_code ))
            local currency_price = struct_market_product:getCurrencyPrice()
            cclog('@ currency price : ' .. tostring(currency_price), type(currency_price))
            ccdump(struct_market_product.m_rowData)

            sample_sku = sku
        end
        
        local currency_code = 'KRW'
        local currency_price = 999999

        -- StructMarketProduct
        local struct_market_product = g_shopDataNew:getStructMarketProduct(sample_sku)
        if struct_market_product then
            local _currency_code = struct_market_product:getCurrencyCode()
            local _currency_price = struct_market_product:getCurrencyPrice()
            
            -- currency_code, currency_price의 변수 타입이나 적절치 않은 값일 경우 무시
            if (type(_currency_code) ~= 'string') then
            elseif (_currency_code == '') then
            elseif (type(_currency_price) ~= 'number') then
            elseif (_currency_price <= 0) then
            else
                -- 타입과 값이 온전할 경우에만 사용
                currency_code = _currency_code
                currency_price = _currency_price
            end
        end
        cclog('##########!!')
        cclog('# currency_code : ' .. tostring(currency_code))
        cclog('# currency_price : ' .. tostring(currency_price))

        return
    end
    
    -- @sgkim 2019.09.24
    if true then
        self:testFunction_cafebazaarFontTest()
        return
    end

    -- 20190819 sgkim adid (광고 식별자 얻어오는 테스트)
    if true then
        local function cb_func(ret, advertising_id)
            ccdisplay('# ret : ' .. ret)
            ccdisplay('# advertising_id : ' .. advertising_id)
        end
        SDKManager:getAdvertisingID(cb_func)
        return
    end

    -- 20190703 sgkim UIC_ListExpansion 구현 확인용
    if true then
        UI_HelpDragonGuidePopup()
        return
    end

    if true then
        self:unityAdsTest01()
        return
    end


	ccdisplay('adMob interstitial ad test')
    if (CppFunctions:isAndroid() == true) then

        local loading = nil

        -- 광고를 재생하는 동안 로딩창으로 블럭 처리
        local loading = UI_Loading()
        loading:setLoadingMsg(Str('네트워크 통신 중...'))

        -- 일정 시간 후 닫기
        local node = loading.root
        local duration = 5
        local function func()
            loading:close()
            loading = nil
        end
        cca.reserveFunc(node, duration, func)

        -- 콜백에서 로딩창 닫기
        local function one_time_callback(ret, info)
            ccdisplay(tostring(ret) .. tostring(info))

            if loading then
                loading:close()
                loading = nil
            end
        end

        -- 광고 재생
        AdMobManager:getInterstitialAd():setOneTimeCallback(one_time_callback)
	    AdMobManager:getInterstitialAd():show()

    -- 윈도우 테스트 코드
    elseif (CppFunctions:isWin32() == true) then
        local loading = UI_Loading()
        loading:setLoadingMsg(Str('네트워크 통신 중...'))

        -- 일정 시간 후 닫기
        local node = loading.root
        local duration = 3
        local function func()
            loading:close()
            loading = nil
        end
        cca.reserveFunc(node, duration, func)
    end
end

-------------------------------------
-- function unityAdsTest00
-- @brief Unity Ads 광고 테스트 00
-------------------------------------
function UI_SettingTestCode:unityAdsTest00()
    -- UnityAds 초기화
    cclog('##UnityAds## unityads_init')
    SDKManager:sendEvent('unityads_initialize', 'debug')
end

-------------------------------------
-- function unityAdsTest01
-- @brief Unity Ads 광고 테스트 01
-------------------------------------
function UI_SettingTestCode:unityAdsTest01()    
    -- 리스너
    local function unityads_listener(ret, info)
        cclog('##UnityAds## unityads_listener') 
        cclog('##UnityAds## ret : ' .. tostring(ret))
        cclog('##UnityAds## info : ' .. tostring(info))

        if ret == 'ready' then

        elseif ret == 'start' then

        elseif ret == 'finish' then

        elseif ret == 'error' then

            if info == 'NOT_READY' then

            elseif info == 'NOT_INITIALIZED' then

            end
        end
    end

    -- UnityAds start
    cclog('##UnityAds## unityads_start')
    local mode = 'test' -- 'test' or ''
    local meta_data = ''
    PerpleSDK:unityAdsStart(mode, meta_data, unityads_listener)
end

-------------------------------------
-- function unityAdsTest02
-- @brief Unity Ads 광고 테스트 02
-------------------------------------
function UI_SettingTestCode:unityAdsTest02()
    -- @metaData : json format string,  '{"serverId":"@serverId", "ordinalId":"@ordinalId"}'
    local placement_id = 'lobbyGiftBox'
    local meda_data = ''
    cclog('##UnityAds## unityAdsShow ' .. placement_id) 
    PerpleSDK:unityAdsShow(placement_id, meda_data)
end

-------------------------------------
-- function click_testCodeBtn2
-- @brief 테스트 코드
-------------------------------------
function UI_SettingTestCode:click_testCodeBtn2()
    
    -- @sgkim 2020.03.18
    -- 원스토어 마켓으로 이동 테스트
    if true then
        MakeSimplePopup(POPUP_TYPE.OK, 'sendEvent, app_gotoStore로 테스트')
        -- 드빌M이 아직 출시 전이라서 드빌1으로 테스트 https://onesto.re/0000285367
        local pid = '0000285367'
        SDKManager:sendEvent('app_gotoStore', pid)
        return
    end

    -- @sgkim 2019.10.08
    if true then
        self:testFunction_AdmobMediation()
        return
    end

    -- @sgkim 2019.09.24
    if true then
        self:testFunction_cafebazaarFontTest_TTF()
        return
    end

    if true then
        self:unityAdsTest02()
        return
    end

	local function success_cb()
		ccdisplay('success success success') 
	end
	local function fail_cb()
		ccdisplay('failure failure failure')
	end
	local function cancel_cb()
		ccdisplay('cancel cancel cancel ##')
	end
	PerpleSdkManager:twitterComposeTweet(success_cb, fail_cb, cancel_cb)
end

-------------------------------------
-- @brief Admob Test Code
-------------------------------------
function UI_SettingTestCode:admob_init()
    FacebookAudienceNetworkManager:initRewardedVideoAd()
    ccdisplay('admob_init')
end
function UI_SettingTestCode:admob_preload()
    FacebookAudienceNetworkManager:getRewardedVideoAd():adPreload(AD_TYPE.RANDOM_BOX_LOBBY)
    ccdisplay('admob_preload')
end
function UI_SettingTestCode:admob_showAd()
    FacebookAudienceNetworkManager:getRewardedVideoAd():showByAdType(AD_TYPE.RANDOM_BOX_LOBBY)
    ccdisplay('admob_showAd')
end


-------------------------------------
-- @brief 특별 제안 패키지
-------------------------------------
function UI_SettingTestCode:showPersonalpack()
    require('UI_Package_Personalpack')
    -- @mskim editbox 넣어서 ppid 바꿀 수 있도록 하자
    UI_Package_Personalpack(101001)
end

-------------------------------------
-- function makeIncompletePurchase
-------------------------------------
function UI_SettingTestCode:makeIncompletePurchase()
    local struct_product = g_shopDataNew.m_dicProduct['cash'][1]

    local function coroutine_function(dt)
        local co = CoroutineHelper()

        -- 중간에 에러가 발생했을 경우 처리 (코루틴이 종료되는 시점에 무조건 호출되는 함수)
        local error_msg, error_info = nil
        local function coroutine_finidh_cb()
			-- error msg가 있으면 단순 팝업 출력
            if error_msg then
                MakeSimplePopup(POPUP_TYPE.OK, error_msg)
			-- error info가 있으면 공용 오류처리 팝업 출력
			elseif (error_info) then
				PerpleSdkManager:makeErrorPopup(error_info)
            end
        end
        co:setCloseCB(coroutine_finidh_cb)

        local market, os = GetMarketAndOS()
        local sku = struct_product['sku']
        local product_id = struct_product['product_id']
        local price = struct_product['price'] -- struct_product:getPrice()
        local validation_key = nil
        local orderId = nil

        --------------------------------------------------------
        cclog('#1. validation_key 발행')
        do -- purchase token(validation_key) 발행
            co:work()
            local function cb_func(ret)
                validation_key = ret['validation_key']
                co.NEXT()
            end
            local function fail_cb(ret)
                error_msg = Str('결제를 준비하는 과정에서 알수없는 오류가 발생하였습니다.')
                co.ESCAPE()
            end
            g_shopDataNew:request_purchaseToken(market, product_id, cb_func, fail_cb)
            if co:waitWork() then return end
        end
        --------------------------------------------------------

        --------------------------------------------------------
        cclog('#2. 결제 실행')
        do -- 일반형 상품 구매
            co:work()

            -- 페이로드 생성
            local payload_table = {}
            payload_table['uid'] = g_userData:get('uid')
            payload_table['validation_key'] = validation_key
            payload_table['product_id'] = product_id
            payload_table['price'] = price
            payload_table['sku'] = sku
            local payload = dkjson.encode(payload_table)

            cclog('## sku : ' .. sku)
            cclog('## payload : ' .. payload)

            -- @sku : 상품 아이디
            -- @payload : 영수증 검증에 필요한 부가 정보
            local function result_func(ret, info)
                cclog('#### ret : ')
                ccdump(ret)

                -- {"orderId":"GPA.3373-5309-9610-83371","payload":"{\"validation_key\":\"22e088cd-53df-435e-a263-0540ae5c3870\",\"price\":55000,\"uid\":\"8ZxuT9Mt9OebL6gQ22gzjVu8d1g2\",\"product_id\":81005}"}
                cclog('#### info : ')
                ccdump(info)

                if (ret == 'success') then
                    cclog('## 결제 성공')                    
					local info_json = dkjson.decode(info)
                    orderId = info_json and info_json['orderId']
                    co.NEXT()

                elseif (ret == 'fail') then
                    cclog('## 결제 실패')
                    error_info = info
                    co.ESCAPE()

                elseif (ret == 'cancel') then
                    cclog('## 결제 취소')
                    error_msg = Str('결제를 취소하였습니다.')
                    co.ESCAPE()

                else
                    cclog('## 결제 결과 (예외) : ' .. ret)
                    error_info = info
                    co.ESCAPE()
                end
            end

            PerpleSDK:billingPurchase(sku, payload, result_func)
            if co:waitWork() then return end
        end
        --------------------------------------------------------
        co:close()
    end


    Coroutine(coroutine_function, '#PAYMENT 코루틴')
end

-------------------------------------
-- function restorePurchase
-------------------------------------
function UI_SettingTestCode:restorePurchase()
    local function show_handle_result_cb(ret)
        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
    end

    local function call_back(ret, info)
        cclog('# restorePurchase() result : ' .. tostring(ret))
        if (ret == 'success') then
            -- info : [{"orderId":"@orderId","payload":"@payload"},...]
            cclog('#### restorePurchase success - info : ')
            cclog(info)

            local info_json = dkjson.decode(info)
            if info_json ~= nil then
                StructProduct:handlingMissingPayments(info_json, show_handle_result_cb)
            end
            
        elseif (ret == 'fail') then
            cclog('#### getIncompletePurchaseList failed - info : ')
            ccdump(info)

            local info_json = dkjson.decode(info)
            local msg = Str(info_json.msg)
            MakeSimplePopup(POPUP_TYPE.OK, msg)
        end
    end

    PerpleSDK:billingGetIncompletePurchaseList(call_back)
end

-------------------------------------
-- function runeGacha
-------------------------------------
function UI_SettingTestCode:runeGacha()
    UIManager:toastNotificationRed('룬 가챠 1회')
    UI_SettingTestCode.click_runeGacha(false)
end

-------------------------------------
-- function runeGacha11
-------------------------------------
function UI_SettingTestCode:runeGacha11()
    UIManager:toastNotificationRed('룬 가챠 10 + 1회')
    UI_SettingTestCode.click_runeGacha(true)
end

-------------------------------------
-- function checkInstalled
-------------------------------------
function UI_SettingTestCode:checkInstalled()
    local edit_box = UI_SimpleEditBoxPopup()
    edit_box:setPopupTitle(Str(''))
    edit_box:setPopupDsc(Str('앱 깔려있는지 확인'))
    edit_box:setPlaceHolder(Str('패키지 명을 입력하시오.'))
    edit_box:setMaxLength(100)

    local function confirm_cb(str)
        local function confirm_function(result)
            local package = isNullOrEmpty(str) and 'com.bigstack.rise' or str
            local is_installed = 1 == tonumber(result)
            local msg = is_installed and ' : 설치됐음' or ' : 설치안됨'
            msg = package .. msg .. ' | 코드 : ' .. tostring(result)

            MakeSimplePopup(POPUP_TYPE.OK, msg)
        end

        PerpSocial:SDKEvent('isInstalled', str, str, confirm_function)

        return true
    end

    edit_box:setConfirmCB(confirm_cb)

    local function close_cb()
        if (edit_box.m_retType == 'ok') then
            local bundle_str = edit_box.m_str
            --if (confirm_cb(buff_str) == false) then return end
        end
    end

    edit_box:setCloseCB(close_cb)

end

-------------------------------------
-- function click_eventSummonBtn
-- @brief 확률업
-------------------------------------
function UI_SettingTestCode.click_runeGacha(is_bundle)
    -- 룬 최대치 보유가 넘었는지 체크
    --local summon_cnt = 1
    --if (is_bundle == true) then
        --summon_cnt = 11
    --end
--
    --if (not g_dragonsData:checkDragonSummonMaximum(summon_cnt)) then
        --return
    --end
    local function finish_cb(ret)
		local gacha_type = 'cash'
        local l_rune_list = ret['runes']

        local ui = UI_GachaResult_Rune(gacha_type, l_rune_list)

        ui:setCloseCB(close_cb)
    end

    local function fail_cb()
    end
    --일반 룬 뽑기
    g_runesData:request_runeGacha(is_bundle, false, '1', finish_cb, fail_cb)
end

-------------------------------------
-- function click_GetDragonPackage
-- @brief 드래곤 획득 패키지 UI 출력
-------------------------------------
function UI_SettingTestCode:click_GetDragonPackage(did)
    local serverTime = Timer:getServerTime()
    local package = StructDragonPkgData(did, serverTime)
    if( package:isPossibleProduct() == false) then
        UI_ToastPopup('패키지를 모두 구매하셨습니다. 패키지 구매내역을 초기화 해주세요.')
        return
    end

    UI_GetDragonPackage(package, nil)
end

-------------------------------------
-- function click_GetDragonPackageList
-- @brief 드래곤 획득 패키지 UI 출력
-------------------------------------
function UI_SettingTestCode:click_GetDragonPackageList()
    local packageList = table.merge(g_getDragonPackage:getPopUpList())
    local function PopupPackage()
        local package = table.pop(packageList)
        if not package then
            return
        end

        if (package:isPossibleProduct() == false) then
            PopupPackage()
            return
        end
        UI_GetDragonPackage(package, PopupPackage)
    end
    PopupPackage()
end