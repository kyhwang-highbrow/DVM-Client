local PARENT = UI

-------------------------------------
-- class UI_FevertimeInfoPopup
-------------------------------------
UI_FevertimeInfoPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FevertimeInfoPopup:init(focus_category)
    local vars = self:load('event_fevertime_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_FevertimeInfoPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FevertimeInfoPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FevertimeInfoPopup:initButton()
    self.vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FevertimeInfoPopup:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_FevertimeInfoPopup:click_closeBtn()
    self:close()
end