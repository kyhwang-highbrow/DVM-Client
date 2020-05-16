local PARENT = UI_ManagedButton

-------------------------------------
-- class UI_ButtonNewcomerShop
-- @brief 관리되는 버튼 (버튼이 노출되는 여부에 따라 상위 메뉴에서 위치 변경)
-- @used_at 
-------------------------------------
UI_ButtonNewcomerShop = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ButtonNewcomerShop:init()
    self:load('button_newcomer_shop.ui')

    -- 버튼 설정
    local btn = self.vars['btn']
    if btn then
        btn:registerScriptTapHandler(function() self:click_btn() end)
    end
end

-------------------------------------
-- function isActive
-------------------------------------
function UI_ButtonNewcomerShop:isActive()
    return true
end

-------------------------------------
-- function click_btn
-- @brief 버튼 클릭
-------------------------------------
function UI_ButtonNewcomerShop:click_btn()
    require('UI_NewcomerShop')
    local ui = UI_NewcomerShop()

    local function close_cb()
        -- 초보자 선물 팝업 내에서 변동이 일어날 경우 갱신을 위해 호출
        self:callDirtyStatusCB()
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function updateButtonStatus
-------------------------------------
function UI_ButtonNewcomerShop:updateButtonStatus()
    local vars = self.vars
end