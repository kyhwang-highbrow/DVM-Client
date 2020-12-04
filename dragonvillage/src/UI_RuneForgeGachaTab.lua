local PARENT = UI_IndivisualTab

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

    for i = 1, 4 do
        local product_id = 121400 + i
        vars['buyBtn' .. i]:registerScriptTapHandler(function() self:click_buyBtn(product_id) end)
        
        local struct_product = g_shopDataNew:getTargetProduct(product_id)
        local price = struct_product:getPriceStr()
        vars['priceLabel' .. i]:setString(price)
    end

    vars['gachaBtn']:registerScriptTapHandler(function() self:click_gachaBtn() end)
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_RuneForgeGachaTab:click_buyBtn(product_id)
    local product_id = product_id -- 테스트용이니까 일단 하드코딩
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
        ItemObtainResult_ShowMailBox(ret, MAIL_SELECT_TYPE.RUNE_STONE, close_cb)
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
-- function refresh
-------------------------------------
function UI_RuneForgeGachaTab:request_runeGacha()
    -- 조건 체크
    local rune_stone_count = g_userData:get('rune_stone') or 0
    if (rune_stone_count <= 0) then
        UIManager:toastNotificationRed(Str('룬 원석이 부족합니다.'))
        return
    end
    
    local function close_cb()
        self:refresh()
    end

    local function finish_cb(ret)
        require('UI_GachaResult_Rune')
        
		local gacha_type = 'ticket'
        local l_rune_list = ret['runes']

        local ui = UI_GachaResult_Rune(gacha_type, l_rune_list)
        
        -- 다시하기 버튼 등록
        ui.vars['againBtn']:registerScriptTapHandler(function()
            self:request_runeGacha() -- is_again
            ui:close()
        end)
        
        ui:setCloseCB(close_cb)
    end

    local function fail_cb()
        UIManager:toastNotificationRed(Str('통신 에러'))
        self:refresh()
    end

    local is_bundle = true
    g_runesData:request_runeGacha(is_bundle, finish_cb, fail_cb) -- param: is_bundle, finish_cb, fail_cb
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeGachaTab:refresh()
    local vars = self.vars

    local rune_stone_count = g_userData:get('rune_stone') or 0
    vars['itemLabel']:setString(rune_stone_count)
end

