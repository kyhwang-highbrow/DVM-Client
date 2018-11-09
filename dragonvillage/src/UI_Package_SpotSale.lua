local PARENT = UI

-------------------------------------
-- class UI_Package_SpotSale
-------------------------------------
UI_Package_SpotSale = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_SpotSale:init()
    self.m_uiName = 'UI_Package_SpotSale'
    local vars = self:load('package_spot_sale.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Package_SpotSale')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_SpotSale:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_SpotSale:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end

    vars['buyBtn1']:registerScriptTapHandler(function() self:click_buyBtn1() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_SpotSale:refresh()
end

-------------------------------------
-- function click_buyBtn1
-------------------------------------
function UI_Package_SpotSale:click_buyBtn1()
    local spot_sale_id, endtime = g_spotSaleData:getSpotSaleInfo_activeProduct()
    UIManager:toastNotificationRed(Str('활성화 상품') .. spot_sale_id)

    local product_id = TableSpotSale:getProductID(spot_sale_id)

    local struct_product = g_shopDataNew:getTargetProduct(tonumber(product_id))
    local cb_func = nil
    local sub_msg = nil
    struct_product:buy(cb_func, sub_msg)
end

--@CHECK
UI:checkCompileError(UI_Package_SpotSale)
