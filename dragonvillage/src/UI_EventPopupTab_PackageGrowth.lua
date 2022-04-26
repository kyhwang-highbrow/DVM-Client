local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_PackageGrowth
-------------------------------------
UI_EventPopupTab_PackageGrowth = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_PackageGrowth:init()
    local vars = self:load('package_growth.ui')

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTab_PackageGrowth:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_PackageGrowth:initButton()
    local vars = self.vars
    vars['fireBtn']:registerScriptTapHandler(function() self:click_openShop(90003) end)
    vars['waterBtn']:registerScriptTapHandler(function() self:click_openShop(90002) end)
    vars['earthBtn']:registerScriptTapHandler(function() self:click_openShop(90001) end)
    vars['lightBtn']:registerScriptTapHandler(function() self:click_openShop(90004) end)
    vars['darkBtn']:registerScriptTapHandler(function() self:click_openShop(90005) end)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_PackageGrowth:onEnterTab()
end

-------------------------------------
-- function click_openShop
-------------------------------------
function UI_EventPopupTab_PackageGrowth:click_openShop(product_id)
    local l_item_list = g_shopDataNew:getProductList('package')
    local struct_product = l_item_list[product_id]

    if (struct_product) then
        local is_popup = true
        PackageManager:getTargetUI(struct_product, is_popup)
    end
end
