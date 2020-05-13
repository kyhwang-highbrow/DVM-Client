local PARENT = UI_ManagedButton

-------------------------------------
-- class UI_ButtonSupplyDepot
-- @brief 관리되는 버튼 (버튼이 노출되는 여부에 따라 상위 메뉴에서 위치 변경)
-- @used_at 
-------------------------------------
UI_ButtonSupplyDepot = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ButtonSupplyDepot:init()
    self:load('button_supply_depot.ui')

    -- 버튼 설정
    local btn = self.vars['supplyBtn']
    if btn then
        btn:registerScriptTapHandler(function() self:click_btn() end)
    end
end

-------------------------------------
-- function isActive
-------------------------------------
function UI_ButtonSupplyDepot:isActive()
    return true
end

-------------------------------------
-- function click_btn
-- @brief 버튼 클릭
-------------------------------------
function UI_ButtonSupplyDepot:click_btn()
    require('UI_SupplyDepot')
    local ui = UI_SupplyDepot()

end