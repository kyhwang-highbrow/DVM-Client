local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_PurchasePoint
-------------------------------------
UI_EventPopupTab_PurchasePoint = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_PurchasePoint:init()
    self:load('event_purchase_point.ui')

    self:doActionReset()
    self:doAction(nil, false)

    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-- @breif
-------------------------------------
function UI_EventPopupTab_PurchasePoint:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_PurchasePoint:initButton()
    local vars = self.vars
    vars['helpBtn']:registerScriptTapHandler(function() self:click_helpBtn() end)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_PurchasePoint:onEnterTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_PurchasePoint:refresh()
end

-------------------------------------
-- function click_helpBtn
-- @brief 도움말
-------------------------------------
function UI_EventPopupTab_PurchasePoint:click_helpBtn()
    UI_GuidePopup_PurchasePoint()
end

--@CHECK
UI:checkCompileError(UI_EventPopupTab_PurchasePoint)
