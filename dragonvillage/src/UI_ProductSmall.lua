local PARENT = UI_Product

-------------------------------------
-- class UI_ProductSmall
-------------------------------------
UI_ProductSmall = class(PARENT, {
        m_structProduct = 'StructProduct',
        m_cbBuy = 'function',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ProductSmall:init(struct_product)
    local vars = self:load('shop_list_02.ui')

    self.m_structProduct = struct_product
    
    self:initItemNodePos()

    self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function adjustLayout
-- @brief 상품명, 설명 등의 위치와 크기 조정
-------------------------------------
function UI_ProductSmall:adjustLayout()
    local vars = self.vars

    do -- 상품 이름 (시스템 폰트)
        local width = 244
        local str_width = vars['itemLabel']:getStringWidth()
        if (width < str_width) then
            local scale = (width / str_width)
            vars['itemLabel']:setScale(scale)
        end
    end
end