--@inherit UI
local PARENT = UI

-------------------------------------
---@class UI_AdsRouletteInfoPopup
-------------------------------------
UI_AdsRouletteInfoPopup = class(PARENT, {
})

-------------------------------------
-- function init
-------------------------------------
function UI_AdsRouletteInfoPopup:init()
    self.m_uiName = 'UI_AdsRouletteInfoPopup'
    self:load('ad_roulette_popup_info.ui')
    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, self.m_uiName)

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AdsRouletteInfoPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AdsRouletteInfoPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AdsRouletteInfoPopup:refresh()
    local vars = self.vars

end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_AdsRouletteInfoPopup:click_closeBtn()
    self:close()
end