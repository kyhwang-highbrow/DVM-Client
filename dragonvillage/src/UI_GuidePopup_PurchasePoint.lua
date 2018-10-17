local PARENT = UI

-------------------------------------
-- class UI_GuidePopup_PurchasePoint
-------------------------------------
UI_GuidePopup_PurchasePoint = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_GuidePopup_PurchasePoint:init(focus_category)
    local vars = self:load('event_purchase_point_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_GuidePopup_PurchasePoint')

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
function UI_GuidePopup_PurchasePoint:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GuidePopup_PurchasePoint:initButton()
    self.vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GuidePopup_PurchasePoint:refresh()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GuidePopup_PurchasePoint:click_closeBtn()
    self:close()
end