local PARENT = UI

-------------------------------------
-- class UI_SettingPopup
-------------------------------------
UI_SettingPopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SettingPopup:init()
    local vars = self:load('setting_popup.ui')
    UIManager:open(self, UIManager.POPUP, false, Z_ORDER_POPUP_TOP_USER_INFO + 1)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SettingPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

--[[
-------------------------------------
-- function close
-------------------------------------
function UI_SettingPopup:close()
    if (not self.enable) then
        return
    end

    local function finish_cb()
        UI.close(self)
    end

    -- @ui_actions
    self:doActionReverse(finish_cb, 0.5, false)
end
--]]

-------------------------------------
-- function initUI
-------------------------------------
function UI_SettingPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SettingPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SettingPopup:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SettingPopup:click_closeBtn()
    self:close()
end

--@CHECK