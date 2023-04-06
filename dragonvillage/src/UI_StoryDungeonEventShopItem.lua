local PARENT = UI_Product

-------------------------------------
-- class UI_ProductSmall
-------------------------------------
UI_StoryDungeonEventShopItem = class(PARENT, {
    m_structProduct = 'StructProduct',
    m_cbBuy = 'function',
})

-------------------------------------
-- function init
-------------------------------------
function UI_StoryDungeonEventShopItem:init(struct_product)
    local vars = self:load('story_dungeon_shop_item.ui')
    self.m_structProduct = struct_product
    self:initItemNodePos()
    self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_StoryDungeonEventShopItem:refresh()
	local vars = self.vars
	local struct_product = self.m_structProduct

	-- package 예외처리
	if (struct_product:isPackage()) then
		vars['maxBuyTermLabel']:setString('')
		vars['buyBtn']:setEnabled(true)
		return
	end

    do -- 구매 제한 설명 텍스트
        vars['maxBuyTermLabel']:setVisible(false)

        local full_str = ''

        -- 상품 설명
	    local product_desc = struct_product:getDesc()

--[[         -- 기간 한정 텍스트
        local new_line = false
        local simple = true
        local period_str = struct_product:getEndDateStr(new_line, simple)
        if period_str and (period_str ~= '') then
            if full_str == '' then
                full_str = product_desc
            end

            if full_str and (full_str ~= '') then
                full_str = full_str .. '\n'
            end

            -- 기간한정 텍스트 컬러 변경
            local color_key = '{@yellow}'

            full_str = full_str .. color_key .. period_str
        end ]]

        -- 구매 제한 텍스트
        local buy_term_str = struct_product:getMaxBuyTermStr()
        if buy_term_str and (buy_term_str ~= '') then
--[[             if full_str == '' then
                full_str = product_desc
            end

            if full_str and (full_str ~= '') then
                full_str = full_str .. '\n'
            end ]]

            -- 구매 가능/불가능 텍스트 컬러 변경
            local is_buy_all = struct_product:isBuyAll()
            local color_key = is_buy_all and '{@impossible}' or '{@available}'

            full_str = full_str .. color_key .. buy_term_str
        end

--[[         if full_str == '' then
            full_str = product_desc
        end ]]

        vars['dscLabel']:setString(full_str)
    end

    -- 판매 가능 여부
    if (struct_product['lock'] == 1) then
        vars['buyBtn']:setEnabled(false)
    else
        vars['buyBtn']:setEnabled(true)
    end

    -- 돋보기 표시 여부
    local is_need_product_info = struct_product:isNeedProductInfo()
    if vars['infoBtn'] ~= nil then
        vars['infoBtn']:setVisible(is_need_product_info)
    end
end