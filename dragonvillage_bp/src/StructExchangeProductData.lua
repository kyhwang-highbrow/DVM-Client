-------------------------------------
-- class StructExchangeProductData
-- @breif 출석 정보를 관리하는 클래스
--        일반 출석, 이벤트 출석 모두 이 클래스를 사용
-------------------------------------
StructExchangeProductData = class({
        m_pid = '',						-- 상품의 아이디
		m_productRes = '',				-- 상품의 아이콘

		m_gruopType = 'str',			-- 상품 그룹 = 탭위치

        m_priceType1 = 'str',			-- 상품 가격의 종류
		m_priceValue1 = 'num',			-- 상품의 가격
        m_priceType2 = 'str',
		m_priceValue2 = 'num',
        m_priceType3 = 'str',
		m_priceValue3 = 'num',

        m_lProductList = '',			-- 지급 상품 리스트

        m_buyCount = '',				-- 현재 구매 횟수
        m_maxBuyCount = '',				-- 최대 구매 횟수
    })

-------------------------------------
-- function init
-------------------------------------
function StructExchangeProductData:init(data)
    self.m_pid = 0
	self.m_productRes = false
	self.m_gruopType = false
	self.m_priceType1 = 0
	self.m_priceValue1 = false
    self.m_priceType2 = 0
	self.m_priceValue2 = false
    self.m_priceType3 = 0
	self.m_priceValue3 = false
	self.m_lProductList = false
	self.m_buyCount = 0
	self.m_maxBuyCount = 0

    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-------------------------------------
function StructExchangeProductData:applyTableData(t_product)
    local t_product = t_product or {}

    local l_price = TableExchange:makePriceList(t_product['price_content']) or {}
    
    self.m_pid = t_product['product_id']
	self.m_productRes = t_product['icon']
	self.m_gruopType = t_product['group_type']

    for i, v in ipairs(l_price) do
        self['m_priceType' .. i] = v['type']
        self['m_priceValue' .. i] = v['value']
    end

	self.m_lProductList = TableExchange:makeProductList(t_product['product_content'])
	self.m_buyCount = 0
	self.m_maxBuyCount = t_product['max_buy_count']
end
