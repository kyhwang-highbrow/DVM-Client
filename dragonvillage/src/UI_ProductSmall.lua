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

            -- 상점에서 번역텍스트가 매우 길 때 두줄로 나올 때가 있는데
            -- 비율로 맞추기만 하면 기한 텏스트랑 겹쳐서
            -- 0.6 싸이즈로 했더니 딱 맞아서 일단 급해서 이렇게 함...
            if (g_localData:getLang() == 'es') then
                scale = 0.6
            end

            vars['itemLabel']:setScale(scale)
        end
    end
end