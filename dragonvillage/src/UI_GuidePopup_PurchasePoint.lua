local PARENT = UI

-------------------------------------
-- class UI_GuidePopup_PurchasePoint
-------------------------------------
UI_GuidePopup_PurchasePoint = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_GuidePopup_PurchasePoint:init(ui_res)
    local vars = self:load(ui_res or 'event_purchase_point_popup.ui')
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
    local vars = self.vars

    local l_matrix = g_shopData:getPricingMatrix()

    for i,v in ipairs(l_matrix) do
        local price = v[1]
        local sku = v[2]
        local price_str = g_shopData:getPriceStrBySku(sku)
        vars['purchaseLabel' .. i]:setString(price_str)
    end

    
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
-- function click_closeBtn
-------------------------------------
function UI_GuidePopup_PurchasePoint:click_closeBtn()
    self:close()
end