local PARENT = UI

-------------------------------------
-- class UI_SubscriptionPopupNew
-------------------------------------
UI_SubscriptionPopupNew = class(PARENT, {
        m_basicProduct = 'StructProductSubscription',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SubscriptionPopupNew:init()
    local vars = self:load('package_daily_dia_1.ui')
	UIManager:open(self, UIManager.POPUP)

	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SubscriptionPopupNew')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
	self:initButton()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SubscriptionPopupNew:initUI()
    local vars = self.vars

    do -- 월정액 패키지 (basic)
        local struct_product = g_subscriptionData:getBasicSubscriptionProductInfo()
        self.m_basicProduct = struct_product

        -- 가격
	    local price = struct_product:getPriceStr()
        vars['priceLabel1']:setString(price)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SubscriptionPopupNew:initButton()
	local vars = self.vars
    vars['buyBtn1']:registerScriptTapHandler(function() self:click_buyBtn(self.m_basicProduct) end)
    vars['adBtn']:registerScriptTapHandler(function() self:click_adBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    
    vars['contractBtn']:registerScriptTapHandler(function() self:click_contractBtn() end)

    -- 일일 획득량 설명 팝업
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function update
-- @brief
-------------------------------------
function UI_SubscriptionPopupNew:update(dt)
    -- 광고 (자동재화, 선물상자 정보)
    do
        local vars = self.vars
        local msg1, enable1 = g_advertisingData:getCoolTimeStatus(AD_TYPE.AUTO_ITEM_PICK)
        vars['adBtn']:setEnabled(enable1)
    end
end

-------------------------------------
-- function click_contractBtn
-------------------------------------
function UI_SubscriptionPopupNew:click_contractBtn()
    GoToAgreeMentUrl()
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_SubscriptionPopupNew:click_buyBtn(struct_product)
	local function cb_func(ret)
        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)

        local function func()
            g_subscriptionData:setDirty()
            g_subscriptionData:openSubscriptionPopup()
            self:close()
        end
        self:doActionReverse(func, 0.5, false)
	end
	struct_product:buy(cb_func)
end

-------------------------------------
-- function click_adBtn
-------------------------------------
function UI_SubscriptionPopupNew:click_adBtn()
    if (IS_LIVE_SERVER() and getAppVerNum() < 1003008) 
        or (IS_QA_SERVER() and getAppVerNum() < 8008)
        or (IS_QA_SERVER() and getAppVerNum() > 1003000 and getAppVerNum() < 1003008)
        or (CppFunctions:getTargetServer() == 'DEV' and getAppVerNum() < 8009) then       
            local msg = Str('새로운 버전의 게임이 업데이트 되었습니다.\n스토어를 통해 업데이트를 하기바랍니다.')
                MakeNetworkPopup(POPUP_TYPE.YES_NO, msg, function() 
                    SDKManager:goToAppStore()
                    closeApplication() end)            
        return
    end

	-- -- 광고 비활성화 시
	-- if (AdSDKSelector:isAdInactive()) then
	-- 	AdSDKSelector:makePopupAdInactive()
	-- 	return
	-- end

    -- -- 광고 프리로드 요청
    -- AdSDKSelector:adPreload(AD_TYPE['AUTO_ITEM_PICK'])

    -- 광고 안내 팝업
    local function ok_cb()
        local function finish_cb()
            self:close()
        end

        g_advertisingData:showAd(AD_TYPE['AUTO_ITEM_PICK'], finish_cb)
    end

    local msg = Str("동영상 광고를 보시면 자동줍기가 적용됩니다.") .. '\n' .. Str("광고를 보시겠습니까?")
    local submsg = Str("자동줍기는 20분간 유지됩니다.")
    MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_cb)
end

-------------------------------------
-- function click_infoBtn
-- @brief 일일 획득량 설명 팝업
-------------------------------------
function UI_SubscriptionPopupNew:click_infoBtn()
    local ui = UI()
    ui:load('package_daily_dia_info.ui')
    ui.vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)
    UIManager:open(ui, UIManager.POPUP)

    -- backkey 지정
	g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'temp')
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SubscriptionPopupNew:click_closeBtn()
    self:close()
end