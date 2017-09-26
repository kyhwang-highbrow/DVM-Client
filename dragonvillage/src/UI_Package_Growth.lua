local PARENT = UI

-------------------------------------
-- class UI_Package_Growth
-------------------------------------
UI_Package_Growth = class(PARENT,{
        m_isPopup = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_Growth:init(is_popup)
    local vars = self:load('package_growth.ui')
    self.m_isPopup = is_popup or false

    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_Growth')
    end

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_Growth:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_Growth:initButton()
    local vars = self.vars
    vars['fireBtn']:registerScriptTapHandler(function() self:click_openShop(90023) end)
    vars['waterBtn']:registerScriptTapHandler(function() self:click_openShop(90022) end)
    vars['earthBtn']:registerScriptTapHandler(function() self:click_openShop(90021) end)
    vars['lightBtn']:registerScriptTapHandler(function() self:click_openShop(90024) end)
    vars['darkBtn']:registerScriptTapHandler(function() self:click_openShop(90025) end)

    if (not self.m_isPopup) then
        vars['closeBtn']:setVisible(false)
    end
end

-------------------------------------
-- function click_openShop
-------------------------------------
function UI_Package_Growth:click_openShop(product_id)
    local l_item_list = g_shopDataNew:getProductList('package')
    local struct_product = l_item_list[product_id]

    if (struct_product) then
        local is_popup = true
        PackageManager:getTargetUI(struct_product, is_popup)
    end
end