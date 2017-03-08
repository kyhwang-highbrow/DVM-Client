-------------------------------------
-- class StructProduct
-------------------------------------
StructProduct = class({
		m_pid = '',						-- 상품의 아이디
		m_productRes = '',				-- 상품의 아이콘

		m_gruopType = 'str',			-- 상품 그룹 = 탭위치
		m_slotType = '',				-- 사용할 UI 종류
		
		m_priceType = 'str',			-- 상품 가격의 종류
		m_priceValue = 'num',			-- 상품의 가격
		
		m_lProductList = '',			-- 지급 상품 리스트

		m_maxBuyCount = '',				-- 최대 구매 횟수
		m_maxBuyDue = '',				-- 최대 구매 갱신 날짜?

		m_eventType = '',				-- 이벤트 종류
		m_eventForm = '',				-- 이벤트 적용 횟수?
		m_eventStartDate = '',			-- 이벤트 시작 시간
		m_eventEndDate = '',			-- 이벤트 종료 시간
		m_eventPriceValue = '',			-- 이벤트로 변경될 상품의 가격
		m_lEventProductList = '',		-- 이벤트로 변경될 지급 상품 리스트
    })

-------------------------------------
-- function init
-------------------------------------
function StructProduct:init(data)
    self.m_pid = 0
	self.m_productRes = false
	self.m_gruopType = false
	self.m_slotType = false
	self.m_priceType = 0
	self.m_priceValue = false
	self.m_lProductList = false
	self.m_maxBuyCount = false
	self.m_maxBuyDue = 0

    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-------------------------------------
function StructProduct:applyTableData(t_product)
	local t_product = t_product or {}

	self.m_pid = t_product['product_id']
	self.m_productRes = t_product['icon']
	self.m_gruopType = t_product['group_type']
	self.m_slotType = t_product['slot_type']
	self.m_priceType = t_product['price_type']
	self.m_priceValue = t_product['price_value']
	self.m_lProductList = TableShop:makeProductList(t_product['product_content'])
	self.m_maxBuyCount = t_product['mbuy_count']
	self.m_maxBuyDue = t_product['mbuy_due']
	--[[
	self.m_eventType = t_product['event_type']
	self.m_eventForm = t_product['event_form']
	self.m_eventStartDate = t_product['event_start_date']
	self.m_eventEndDate = t_product['event_end_date']
	self.m_eventPriceValue = t_product['event_price']
	self.m_lEventProductList = t_product['event_product_content']
	]]
end