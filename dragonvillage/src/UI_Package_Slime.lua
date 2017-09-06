local PARENT = UI

-------------------------------------
-- class UI_Package_Slime
-------------------------------------
UI_Package_Slime = class(PARENT,{
        m_isPopup = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_Slime:init(is_popup)
    local vars = self:load('package_slime.ui')
    self.m_isPopup = is_popup or false

    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_Slime')
    end

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_Slime:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_Slime:initButton()
    local vars = self.vars
    vars['fireBtn']:registerScriptTapHandler(function() self:click_openShop(90017) end)
    vars['waterBtn']:registerScriptTapHandler(function() self:click_openShop(90016) end)
    vars['earthBtn']:registerScriptTapHandler(function() self:click_openShop(90015) end)
    vars['lightBtn']:registerScriptTapHandler(function() self:click_openShop(90018) end)
    vars['darkBtn']:registerScriptTapHandler(function() self:click_openShop(90019) end)

    if (not self.m_isPopup) then
        vars['closeBtn']:setVisible(false)
    end
end

-------------------------------------
-- function click_openShop
-------------------------------------
function UI_Package_Slime:click_openShop(product_id)
    local l_item_list = g_shopDataNew:getProductList('package')
    local struct_product = l_item_list[product_id]

    if (struct_product) then
        local is_popup = true
        PackageManager:getTargetUI(struct_product, is_popup)
    end
end