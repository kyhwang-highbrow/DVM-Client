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
    local special_product = g_shopDataNew:getTargetProduct(SPECIAL_RUNE_PACKAGE_ID)

    if (special_product) then
        remain_time = special_product:getTimeRemainingForEndOfSale() * 1000 -- milliseconds로 변경
        local can_buy = special_product:isItBuyable()

        if (can_buy) then
            start_product_id = SPECIAL_RUNE_PACKAGE_ID
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
--
        --local package_desc = struct_product:getProductDesc()
        --vars['dscLabel' .. i]:setString(package_desc)
    end

    if g_fevertimeData:isActiveFevertimeByType(FEVERTIME_SALE_EVENT.RUNE_GACHA_UP) then
        vars['runeEventMenu']:setVisible(true)
    end

    vars['gachaBtn']:registerScriptTapHandler(function() self:click_gachaBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
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
-- function click_infoBtn
-------------------------------------
function UI_RuneForgeGachaTab:click_infoBtn()
    MakePopup('rune_forge_gacha_info.ui', nil)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeGachaTab:request_runeGacha()
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
    g_runesData:request_runeGacha(is_bundle, finish_cb, nil) -- param: is_bundle, finish_cb, fail_cb
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeGachaTab:refresh()
    local vars = self.vars

    local rune_box_count = g_userData:get('rune_box') or 0
    vars['itemLabel']:setString(rune_box_count)
end

