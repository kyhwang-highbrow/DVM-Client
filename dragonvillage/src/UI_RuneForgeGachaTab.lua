local PARENT = UI_IndivisualTab

STANDARD_RUNE_PACKAGE_ID = 121401    -- 1+1 상품 id 121401 ~ 121404
SPECIAL_RUNE_PACKAGE_ID = 121405    -- 1+1 상품 id 121405 ~ 121408

-------------------------------------
-- class UI_RuneForgeGachaTab
-------------------------------------
UI_RuneForgeGachaTab = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeGachaTab:init(owner_ui)
    local vars = self:load('rune_forge_gacha.ui')
    
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgeGachaTab:onEnterTab(first)
    self.m_ownerUI:showNpc() -- NPC 등장

    if (first == true) then
        self:initUI()
    end

    self:refresh()

end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_RuneForgeGachaTab:onExitTab()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeGachaTab:initUI()
    local vars = self.vars
    local start_product_id = STANDARD_RUNE_PACKAGE_ID

    -- 상품에서 특별할인상품이 판매기간인지 체크
    --[[
    local special_product = g_shopDataNew:getTargetProduct(SPECIAL_RUNE_PACKAGE_ID)

    if (special_product) then
        remain_time = special_product:getTimeRemainingForEndOfSale() * 1000 -- milliseconds로 변경
        local can_buy = special_product:isItBuyable()

        if (can_buy) then
            start_product_id = SPECIAL_RUNE_PACKAGE_ID
            vars['runeEventMenu']:setVisible(true)
        end
    end

    -- 설정된 프로덕트 아이디도 포함시켜야 함
    start_product_id = start_product_id - 1

    for i = 1, 4 do
        local product_id = start_product_id + i
        vars['buyBtn' .. i]:registerScriptTapHandler(function() self:click_buyBtn(product_id) end)
        
        local struct_product = g_shopDataNew:getTargetProduct(product_id)
        local price = struct_product:getPriceStr()
        vars['priceLabel' .. i]:setString(price)

        --local package_name = struct_product:getProductName()
        --vars['itemLabel' .. i]:setString(package_name)

        local package_desc = struct_product:getProductDesc()
        vars['itemLabel' .. i]:setString(Str(package_desc))

        --local package_desc = struct_product:getProductDesc()
        --vars['dscLabel' .. i]:setString(package_desc)
    end]]
    local is_active 
    local value
    local l_ret 
    is_active, value, l_ret = g_fevertimeData:isActiveFevertime_runeGachaUp()
    if is_active then
        vars['runeFeverMenu']:setVisible(true)
        self.root:scheduleUpdateWithPriorityLua(function(dt) self:updateTimer(dt) end, 0)
    end

    vars['diaBtn']:registerScriptTapHandler(function() self:click_diamondGachaBtn() end)
    vars['gachaBtn']:registerScriptTapHandler(function() self:click_gachaBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function updateTimer
-------------------------------------
function UI_RuneForgeGachaTab:updateTimer(dt)
    local vars = self.vars

    is_active, value, l_ret = g_fevertimeData:isActiveFevertime_runeGachaUp()
    if is_active then
        if #l_ret then l_ret = l_ret[1] end
        
        local start_time = l_ret['start_date']/1000
        local end_time = l_ret['end_date']/1000
        local curr_time = Timer:getServerTime()
  
        if (start_time <= curr_time) and (curr_time <= end_time) then
            local time = (end_time - curr_time)
            str = Str('{1} 남음', datetime.makeTimeDesc(time, true))
            vars['timeLabel']:setString(str)
        end
    else
        vars['runeFeverMenu']:setVisible(false)
        --UINavigator:goto('lobby')
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_RuneForgeGachaTab:click_buyBtn(product_id)
    local product_id = product_id 
    local struct_product = g_shopDataNew:getTargetProduct(product_id)

    if (not struct_product) then
        return
    end

    local function close_cb()
        -- 갱신
        self:refresh()
    end

	local function cb_func(ret)
        -- 아이템 획득 우편함
        ItemObtainResult_ShowMailBox(ret, MAIL_SELECT_TYPE.RUNE_BOX, close_cb)
	end

	struct_product:buy(cb_func)
end

-------------------------------------
-- function click_gachaBtn
-------------------------------------
function UI_RuneForgeGachaTab:click_gachaBtn()
    self:request_runeGacha()
end

-------------------------------------
-- function click_diamondGachaBtn
-------------------------------------
function UI_RuneForgeGachaTab:click_diamondGachaBtn()
    self:request_runeGacha(true)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_RuneForgeGachaTab:click_infoBtn()
    MakePopup('rune_forge_gacha_info.ui', nil)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeGachaTab:request_runeGacha(is_cash)
    -- 조건 체크
    local rune_box_count = g_userData:get('rune_box') or 0
    if (rune_box_count <= 0) then
        UIManager:toastNotificationRed(Str('룬 상자가 부족합니다.'))
        return
    end
    
    -- 룬 최대 보유 수량 체크
    if (not g_runesData:checkRuneGachaMaximum(10)) then
        return
    end

    local function close_cb()
        self.m_ownerUI:refresh_highlight()
        self:refresh()
    end

    local function finish_cb(ret)
		local gacha_type = 'rune_box'
        local l_rune_list = ret['runes']

        local ui = UI_GachaResult_Rune(gacha_type, l_rune_list)
        
        ui:setCloseCB(close_cb)
    end
    
    local is_bundle = true
    g_runesData:request_runeGacha(is_bundle, is_cash, finish_cb, nil) -- param: is_bundle, finish_cb, fail_cb
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeGachaTab:refresh()
    local vars = self.vars
    --[[
    local rune_box_count = g_userData:get('rune_box') or 0
    vars['itemLabel']:setString(rune_box_count)]]
end

