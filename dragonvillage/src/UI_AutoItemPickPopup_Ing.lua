local PARENT = UI

-------------------------------------
-- class UI_AutoItemPickPopup_Ing
-------------------------------------
UI_AutoItemPickPopup_Ing = class(PARENT, {
        m_basicProduct = 'StructProductSubscription',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_AutoItemPickPopup_Ing:init()
    local vars = self:load('package_daily_dia_reward_2.ui')
	UIManager:open(self, UIManager.POPUP)

	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_AutoItemPickPopup_Ing')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AutoItemPickPopup_Ing:initUI()
    local vars = self.vars

    -- 남은 시간
    local msg = g_advertisingData:getCoolTimeStatus(AD_TYPE.AUTO_ITEM_PICK)
    vars['dayLabel']:setString(msg)

    local ingame_drop_info = g_subscriptionData:getIngameDropInfo()
    local play_cnt = ingame_drop_info['play_cnt']
    local cash_cnt = ingame_drop_info['cash']
    local gold_cnt = ingame_drop_info['gold']
    local amethyst_cnt = ingame_drop_info['amethyst']
    
    -- 플레이 횟수
    if (play_cnt) then
        vars['playLabel']:setString(Str('{1}회', comma_value(play_cnt)))
    end

    -- 캐시
    if (cash_cnt) then
        vars['itemLabel1']:setString(Str('{1}개', comma_value(cash_cnt)))
    end

    -- 골드
    if (gold_cnt) then
        vars['itemLabel2']:setString(Str('{1}개', comma_value(gold_cnt)))
    end

    -- 자수정
    if (amethyst_cnt) then
        vars['itemLabel3']:setString(Str('{1}개', comma_value(amethyst_cnt)))
    end

    -- 자동줍기 24시간 이용권 있는 경우 보유량 보여줌
    local auto_pick_item = g_userData:get('auto_root')
    if (auto_pick_item) and (auto_pick_item > 0) then
        local cnt = math_floor(auto_pick_item/24)
        vars['marbleLabel']:setString(Str('x{1}', cnt))
        vars['marbleBtn']:setVisible(true)
    end

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
function UI_AutoItemPickPopup_Ing:initButton()
	local vars = self.vars
    vars['buyBtn1']:registerScriptTapHandler(function() self:click_buyBtn(self.m_basicProduct) end)
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['marbleBtn']:registerScriptTapHandler(function() self:click_marbleBtn() end)
    vars['contractBtn']:registerScriptTapHandler(function() self:click_contractBtn() end)

    -- 일일 획득량 설명 팝업
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function click_marbleBtn
-------------------------------------
function UI_AutoItemPickPopup_Ing:click_marbleBtn()
    local auto_pick_item = g_userData:get('auto_root')
    if (auto_pick_item) and (auto_pick_item > 0) then
        local cnt = math_floor(auto_pick_item/24)

        local msg = Str('24시간 자동줍기 사용권 {1}개 보유중입니다.\n현재 적용중인 자동줍기 종료 후 사용할 수 있습니다.', cnt)
        local tool_tip = UI_Tooltip_Skill(70, -145, msg)

        -- 자동 위치 지정
        tool_tip:autoPositioning(self.vars['marbleBtn'])
    end
end

-------------------------------------
-- function click_contractBtn
-------------------------------------
function UI_AutoItemPickPopup_Ing:click_contractBtn()
    GoToAgreeMentUrl()
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_AutoItemPickPopup_Ing:click_buyBtn(struct_product)
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

    local remain_time = g_advertisingData:getCoolTimeStatus(AD_TYPE.AUTO_ITEM_PICK)
    local toast_msg = Str('현재 적용중인 무료 자동줍기 시간\n{@available}({1}){@default}이 즉시 종료되고,\n{@item_name}14일 자동줍기{@default}로 새롭게 적용됩니다.\n\n구매하시겠습니까?', remain_time)

    local function ok_btn_cb()
        struct_product:buy(cb_func)
    end
    MakeSimplePopup(POPUP_TYPE.YES_NO, toast_msg, ok_btn_cb)
end

-------------------------------------
-- function click_infoBtn
-- @brief 일일 획득량 설명 팝업
-------------------------------------
function UI_AutoItemPickPopup_Ing:click_infoBtn()
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
function UI_AutoItemPickPopup_Ing:click_closeBtn()
    self:close()
end