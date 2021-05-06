local PARENT = UI

-------------------------------------
-- class UI_EventDailyQuest
-- @brief 
-------------------------------------
UI_EventDailyQuest = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventDailyQuest:init(popup_key)
    ui_name = 'event_daily_quest.ui'    
    self:load(ui_name)

    self:doActionReset()
    self:doAction(nil, false)

    self:initButton()
    self:refresh()
    self:initUI()
end

-------------------------------------
-- function initUI
-- @breif 초기화
-------------------------------------
function UI_EventDailyQuest:initUI()
    local vars = self.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventDailyQuest:onEnterTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventDailyQuest:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventDailyQuest:refresh()
end

--@CHECK
UI:checkCompileError(UI_EventDailyQuest)