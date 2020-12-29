local PARENT = UI

-------------------------------------
-- class UI_InventoryBtn
-------------------------------------
UI_InventoryBtn = class(PARENT,{

    })


-------------------------------------
-- function init
-------------------------------------
function UI_InventoryBtn:init()
    local vars = self:load('ui_item_inventory.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_InventoryBtn:initUI()
    local vars = self.vars
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_InventoryBtn:initButton()
    local vars = self.vars
    -- 팝업 닫을 때 정보 갱신
    local cb_refresh = function()
        self:refresh()
    end

    self.vars['moveBtn']:registerScriptTapHandler(function() 
        --ui_inven = UI_Inventory() 
        --ui_inven:setCloseCB(cb_refresh)
        -- 이제 룬 가방을 클릭하면 룬 관리창으로 보내준다
        --UINavigator:goTo('rune_forge', 'manage')
        UI_RuneForge('manage')
    end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_InventoryBtn:refresh()
    -- 보유 룬 수량
    local inven_count = g_inventoryData:getCount('rune')
    local max_count = g_inventoryData:getMaxCount('rune')

    cclog(inven_count)
    cclog(max_count)

    self.vars['NumberLabel']:setString(Str('{1}/{2}', inven_count, max_count))
end

-------------------------------------
-- function setInGame
-------------------------------------
function UI_InventoryBtn:setInGame(is_ingame)
    -- 인게임일 경우 이동 버튼 보이지 않음
    self.vars['moveBtn']:setVisible(not is_ingame)
end