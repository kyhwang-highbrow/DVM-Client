local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_RuneForgeReinforceTab
-------------------------------------
UI_RuneForgeReinforceTab = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeReinforceTab:init(owner_ui)
    local vars = self:load('rune_forge_reinforce.ui')
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgeReinforceTab:onEnterTab(first)
    self.m_ownerUI:showNpc() -- NPC 등장

    if (first == true) then
        self:initUI()
        self:initButton()
    end

    self:refresh()
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_RuneForgeReinforceTab:onExitTab()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeReinforceTab:initUI()
    local vars = self.vars

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneForgeReinforceTab:initButton()
    local vars = self.vars

    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeReinforceTab:refresh()
    local vars = self.vars

    -- 룬 춘복서 아이템 보유 수량
    do
        local cur_rune_bless_cnt = g_userData:get('rune_bless')
        vars['itemLabel']:setString(comma_value(cur_rune_bless_cnt))
    end

    -- 룬 축복서 아이템 구매 제한 횟수
    do
        -- 룬 축복서 product ID : 220017
        local product_struct = g_shopData:getProduct('amethyst', 220017)
        -- 구매제한 설명 문구 
        local buy_count_desc = product_struct:getBuyCountDesc()
        vars['buyLabel']:setString(buy_count_desc)
    end
end

-------------------------------------
-- function click_buyBtn
-- @brief 룬 축복서 구매 팝업을 띄움
-------------------------------------
function UI_RuneForgeReinforceTab:click_buyBtn()
    local vars = self.vars
    
    -- 룬 축복서 product ID : 220017
    local product_struct = g_shopData:getProduct('amethyst', 220017)
    product_struct:buy(function(ret)
        ItemObtainResult_Shop(ret) 
        self:refresh()
    end)
end