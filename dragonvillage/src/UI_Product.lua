local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_Product
-------------------------------------
UI_Product = class(PARENT, {
        m_structProduct = 'StructProduct',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Product:init(struct_product)
    local vars = self:load('shop_list_02.ui')

    self.m_structProduct = struct_product
    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Product:initUI()
    local vars = self.vars

    local struct_product = self.m_structProduct

    vars['itemLabel']:setString(Str(struct_product['t_name']))

    vars['dscLabel']:setString(struct_product:getDesc())

    local icon = struct_product:makeProductIcon()
    vars['itemNode']:addChild(icon)

    vars['priceLabel']:setString(struct_product:getPriceStr())
    local icon = struct_product:makePriceIcon()
    vars['priceNode']:addChild(icon)

    do
        local str_width = vars['priceLabel']:getStringWidth()
        local icon_width = 70
        local total_width = str_width + icon_width

        local icon_x = -(total_width/2) + (icon_width/2)
        vars['priceNode']:setPositionX(icon_x)
        local label_x = (icon_width/2)
        vars['priceLabel']:setPositionX(label_x)

        local _, height = vars['priceBg']:getNormalSize()
        vars['priceBg']:setNormalSize(total_width + 10, height)
    end

    vars['buyBtn']:registerScriptTapHandler(function() struct_product:buy() end)
end