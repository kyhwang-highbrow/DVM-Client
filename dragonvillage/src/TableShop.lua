local PARENT = TableClass

-------------------------------------
-- class TableShop
-------------------------------------
TableShop = class(PARENT, {
		
		------------Shop type-----------------------
		CASH = 'cash',
		GOLD = 'gold',
		STAMINA = 'stamina',
		RECOMMEND = 'recommend',
		LIMIT = 'limit',
		HONOR = 'honor'
    })

-------------------------------------
-- function init
-------------------------------------
function TableShop:init(product_table)
    self.m_tableName = 'shop'
    self.m_orgTable = product_table
end

-------------------------------------
-- function makeProductName
-- @breif 상품명
-- @return str string
-------------------------------------
function TableShop:makeProductName(l_product)
    local ret_str = ''
    local l_product = l_product or {}

    for product_type, product_value in pairs(l_product) do
        local item_id = TableItem:getItemIDFromItemType(product_type) or tonumber(product_type)
        ret_str = TableItem:getItemName(item_id)
    end

    return ret_str
end

-------------------------------------
-- function makeProductDesc
-- @breif 상품 설명 생성 = 상품 종류 + 상품 갯수 + 추가 상품 설명
-- @return str string
-------------------------------------
function TableShop:makeProductDesc(l_product)
	local l_product = l_product or {}
	local ret_str = ''
	

	for product_type, product_value in pairs(l_product) do
		local value_str = comma_value(product_value)
		local str = ''

		if (product_type == 'cash') then
			str = Str('다이아몬드 {1}개', value_str)

        elseif (product_type == 'amethyst') then
			str = Str('자수정 {1}개', value_str)

		elseif (product_type == 'gold') then
			str = Str('골드 {1}개', value_str)

		elseif (product_type == 'staminas_st') then
			str = Str('날개 {1}개', value_str)

		else
			cclog('product_type : ' .. product_type)
		end

		ret_str = ret_str .. str .. '\n'
	end
	
    return ret_str
end

-------------------------------------
-- function makePriceDesc
-- @breif 가격 설명 생성 = 가격 종류 + 가격 갯수
-- @return str string
-------------------------------------
function TableShop:makePriceDesc(price_type, price_value)
    local price_str = comma_value(price_value)
    local str = ''

    if (price_type == 'money') then
        str = Str('\\{1}', price_str)

    else
        str = Str('{1}개', price_str)
    end

    return str
end

-------------------------------------
-- function makePriceIconRes
-- @brief 지불 재화 아이콘 생성
-------------------------------------
function TableShop:makePriceIconRes(price_type)
    local price_type = price_type or 'x'

    local res = nil

    if (price_type == 'x') then

    elseif (price_type == 'cash') then
        res = 'res/ui/icon/inbox/inbox_cash.png'

    elseif (price_type == 'gold') then
        res = 'res/ui/icon/inbox/inbox_gold.png'

    elseif (price_type == 'stamina') then
        res = 'res/ui/icon/inbox/inbox_staminas_st.png'

    elseif (price_type == 'amethyst') then
        res = 'res/ui/icon/inbox/inbox_amethyst.png'

    else
        --cclog('price_type : ' .. price_type)
    end

    return res
end

-------------------------------------
-- function makeBillName
-- @brief 지불 재화 아이콘 생성
-------------------------------------
function TableShop:makeBillName(price_type)
    local price_type = price_type or 'x'

    if (price_type == 'money') then
		if (Translate.phoneLang == 'kr') then
			return 'KRW'
		elseif (Translate.phoneLang == 'en') then
			return 'USD'
		elseif (Translate.phoneLang == 'jp') then
			return 'JPY'
		elseif (Translate.phoneLang == 'cn') then
			return 'CNY'
		end

    else
		return Str('구매')
    end
end

-------------------------------------
-- function makeProductList
-- @brief 상품 리스트 생성
-------------------------------------
function TableShop:makeProductList(product_str)
    local product_str = product_str or nil

    local l_product_list = {}
	local l_product_bundle = self:seperate(product_str, ',', true)
	for i, bundle in pairs(l_product_bundle) do
		local l_product = self:seperate(bundle, ';', true)
		local product_type = l_product[1]
		local product_value = l_product[2]

		l_product_list[product_type] = product_value
	end

    return l_product_list
end
