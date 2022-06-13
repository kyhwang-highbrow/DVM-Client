
-------------------------------------
-- class UI_ServerTimePopup
-------------------------------------
UI_ServerTimePopup = class(UI, {
    m_endTimestampSec = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_ServerTimePopup:init(end_timestamp_sec)
    local vars = self:load('server_time_popup.ui')

    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end)

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self.m_endTimestampSec = end_timestamp_sec

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ServerTimePopup:initUI()

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ServerTimePopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ServerTimePopup:refresh()

end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_ServerTimePopup:click_closeBtn()
    self:close()
end
