local PARENT = UI

-------------------------------------
-- class UI_Fevertime
-- @breif 핫타임(개발 코드는 fevertime)
-------------------------------------
UI_Fevertime = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Fevertime:init()
    local ui_name = 'event_fevertime.ui'
    self:load(ui_name)

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Fevertime:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Fevertime:initButton()
    local vars = self.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_Fevertime:onEnterTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Fevertime:refresh()
end

--@CHECK
UI:checkCompileError(UI_Fevertime)
