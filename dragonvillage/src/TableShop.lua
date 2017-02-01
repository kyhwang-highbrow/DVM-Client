local PARENT = TableClass

-------------------------------------
-- class TableShop
-------------------------------------
TableShop = class(PARENT, {
		
		------------Shop type-----------------------
		GACHA = 'draw',
		CASH = 'cash',
		GOLD = 'gold',
		STAMINA = 'stamina'
    })

-------------------------------------
-- function init
-------------------------------------
function TableShop:init()
    self.m_tableName = 'shop'
    self.m_orgTable = TABLE:get(self.m_tableName)

	self:makeShopData()
end

-------------------------------------
-- function makeShopData
-- @brief 데이터를 UI에서 사용하기 쉽게 가공한다
-------------------------------------
function TableShop:makeShopData()
	for _, t_shop in pairs(self.m_orgTable) do
		local t_ui = {}

		t_ui['product_name'] = self:makeProductName(t_shop)
		t_ui['price_name'] = self:makePriceName(t_shop)
		t_ui['price_icon_res'] = self:makePriceIconRes(t_shop)

		t_shop['t_ui_info'] = t_ui
	end
end

-------------------------------------
-- function makeProductName
-- @breif 상품 이름 생성
-- @param t_shop table
-- @return str string
-------------------------------------
function TableShop:makeProductName(t_shop)
    local value_type = t_shop['value_type']
    local value = t_shop['value']
    local value_str = comma_value(value)
    local str = ''

    if (value_type == 'x') then

    elseif (value_type == 'cash') then
        str = Str('{1} 자수정', value_str)

    elseif (value_type == 'gold') then
        str = Str('{1} 골드', value_str)

    elseif (value_type == 'stamina') then
        str = Str('날개 {1}개', value_str)

    elseif (value_type == 'card') then
        str = Str('드래곤 카드 {1}팩', value_str)

    else
        error('value_type : ' .. value_type)
    end

    return str
end

-------------------------------------
-- function makePriceName
-- @breif 지불 재화 이름 생성
-- @param t_shop table
-- @return str string
-------------------------------------
function TableShop:makePriceName(t_shop)
    local price_type = t_shop['price_type']
    local price = t_shop['price']
    local price_str = comma_value(price)
    local str = ''

    if (price_type == 'x') then
        str = Str('[무료]')

    elseif (price_type == 'cash') then
        str = Str('{1} 자수정', price_str)

    elseif (price_type == 'gold') then
        str = Str('{1} 골드', price_str)

    elseif (price_type == 'stamina') then
        str = Str('날개 {1}개', price_str)

    elseif (price_type == 'card') then
        str = Str('드래곤카드 {1}팩', price_str)

    else
        error('price_str : ' .. price_str)
    end

    return str
end

-------------------------------------
-- function makePriceIconRes
-- @brief 지불 재화 아이콘 생성
-------------------------------------
function TableShop:makePriceIconRes(t_shop)
    local price_type = t_shop['price_type']

    local res = nil

    if (price_type == 'x') then

    elseif (price_type == 'cash') then
        res = 'res/ui/icon_ruby.png'

    elseif (price_type == 'gold') then
        res = 'res/ui/icon_gold.png'

    elseif (price_type == 'stamina') then
        res = 'res/ui/icon_actingpower.png'

    elseif (price_type == 'card') then

    else
        error('price_type : ' .. price_type)
    end

    return res
end

