local PARENT = UI

-------------------------------------
-- class UI_SupplyProductInfoPopup_AutoPickup
-------------------------------------
UI_SupplyProductInfoPopup_AutoPickup = class(PARENT,{
        m_buyCb = 'function',
        m_structProduct = 'StructProduct',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SupplyProductInfoPopup_AutoPickup:init(cb_func, hide_ad)
    local vars = self:load('supply_product_info_popup_auto_pickup.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_SupplyProductInfoPopup_AutoPickup'
    self.m_buyCb = cb_func

    local t_supply = TableSupply:getSupplyData_autoPickup()
    local product_id = t_supply['product_id']
    self.m_structProduct = g_shopData:getTargetProduct(product_id) -- StructProduct

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_SupplyProductInfoPopup_AutoPickup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(hide_ad)
    self:initButton()
    self:refresh()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SupplyProductInfoPopup_AutoPickup:initUI(hide_ad)
    local vars = self.vars

    -- 광고 시청 버튼을 숨김설정이거나 자동 줍기가 활성화인 경우
    if (hide_ad == true) or (g_supply:isActiveSupply_autoPickup() == true) then
        vars['productMenu']:setPositionX(0)
        vars['adMenu']:setVisible(false)
    end
    
    if vars['priceLabel'] then
        vars['priceLabel']:setString(self.m_structProduct:getPriceStr())
    end

    do -- 다이아 즉시 획득량
        local t_supply = TableSupply:getSupplyData_autoPickup()
        local package_item_str = t_supply['product_content']
        local count = ServerData_Item:getItemCountFromPackageItemString(package_item_str, ITEM_ID_CASH)
        local str = Str('즉시 획득') .. ' ' .. comma_value(count)
        vars['obtainLabel']:setString(str)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SupplyProductInfoPopup_AutoPickup:initButton()
    local vars = self.vars
    vars['adBtn']:registerScriptTapHandler(function() self:click_adBtn() end)
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)

    -- 일일 획득량 설명 팝업
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SupplyProductInfoPopup_AutoPickup:refresh()
    local vars = self.vars
    local ingame_drop_info = g_subscriptionData:getIngameDropInfo()
    local play_cnt = ingame_drop_info['play_cnt'] or 0
    local cash_cnt = ingame_drop_info['cash'] or 0
    local gold_cnt = ingame_drop_info['gold'] or 0
    local amethyst_cnt = ingame_drop_info['amethyst'] or 0
    
    -- 플레이 횟수
    vars['playLabel']:setString(Str('{1}회', comma_value(play_cnt)))

    -- 다이아
    vars['itemLabel1']:setString(Str('{1}개', comma_value(cash_cnt)))

    -- 골드
    vars['itemLabel2']:setString(Str('{1}개', comma_value(gold_cnt)))

    -- 자수정
    vars['itemLabel3']:setString(Str('{1}개', comma_value(amethyst_cnt)))


    -- 오해하지 마세요, 다른 작업 때문에 1초가 아쉬워서 부득이하게 이렇게 했습니다.
    local daily_ingame_drop_info = g_subscriptionData:getDailyIngameDropInfo()
    local daily_play_cnt = daily_ingame_drop_info['play_cnt'] or 0
    local daily_cash_cnt = daily_ingame_drop_info['cash'] or 0
    local daily_gold_cnt = daily_ingame_drop_info['gold'] or 0
    local daily_amethyst_cnt = daily_ingame_drop_info['amethyst'] or 0

    -- 1일 플레이 횟수
    vars['dailyPlayLabel']:setString(Str('{1}회', comma_value(daily_play_cnt)))

    -- 1일 다이아
    vars['dailyItemLabel1']:setString(Str('{1}개', comma_value(daily_cash_cnt)))

    -- 1일 골드
    vars['dailyItemLabel2']:setString(Str('{1}개', comma_value(daily_gold_cnt)))

    -- 1일 자수정
    vars['dailyItemLabel3']:setString(Str('{1}개', comma_value(daily_amethyst_cnt)))

end

-------------------------------------
-- function click_adBtn
-------------------------------------
function UI_SupplyProductInfoPopup_AutoPickup:click_adBtn()
	-- 광고 비활성화 시
	if (AdSDKSelector:isAdInactive()) then
		AdSDKSelector:makePopupAdInactive()
		return
	end

    -- 광고 프리로드 요청
    AdSDKSelector:adPreload(AD_TYPE['AUTO_ITEM_PICK'])

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
-- function click_buyBtn
-------------------------------------
function UI_SupplyProductInfoPopup_AutoPickup:click_buyBtn()
	self.m_structProduct:buy(self.m_buyCb)
    self:close()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SupplyProductInfoPopup_AutoPickup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_infoBtn
-- @brief 일일 획득량 설명 팝업
-------------------------------------
function UI_SupplyProductInfoPopup_AutoPickup:click_infoBtn()
    local ui = UI()
    ui:load('package_daily_dia_info.ui')
    ui.vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)
    UIManager:open(ui, UIManager.POPUP)

    -- backkey 지정
	g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'temp')
end

-------------------------------------
-- function update
-- @brief 매 프레임 호출됨
-------------------------------------
function UI_SupplyProductInfoPopup_AutoPickup:update(dt)
    local vars = self.vars

    local str = g_supply:getSupplyTimeRemainingString_autoPickup()
    if (str == '') then
        str = Str('남은 시간 : {1}', '0')
    end
    vars['dayLabel']:setString(str)
end

--@CHECK
UI:checkCompileError(UI_SupplyProductInfoPopup_AutoPickup)
