local PARENT = UI

-------------------------------------
-- class UI_EventArenaPlay
-- @brief 
-------------------------------------
UI_EventArenaPlay = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventArenaPlay:init(popup_key)
    ui_name = 'event_update_reward.ui'    
    self:load(ui_name)

    --self:initButton()
    --self:refresh()
    --self:initUI()
end

-------------------------------------
-- function initUI
-- @breif 초기화
-------------------------------------
function UI_EventArenaPlay:initUI()
    local vars = self.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventArenaPlay:onEnterTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventArenaPlay:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventArenaPlay:refresh()
end

--@CHECK
UI:checkCompileError(UI_EventArenaPlay)