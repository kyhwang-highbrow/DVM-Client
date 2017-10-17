local PARENT = StructProduct

-------------------------------------
-- class StructProductSubscription
-- @brief 구독 상품 데이터
-------------------------------------
StructProductSubscription = class(PARENT, {
        -- subscription (구독 상품)
        subscription = 'string',
        daily_term = 'number', -- 구독 기간 (day)
        login_content = 'string', -- 해당 날짜에 실제 로그인 시에 보상 제공 ex : "cash;100,staminas_st;100"
        daily_content = 'string', -- 해당 날짜에 실제 로그인하지 않아도 보상 제공 ex : "cash;100,staminas_st;100"

        m_subscriptionCategory = 'string',
        m_nextDiscountProductID = 'number',
    })

local THIS = StructProductSubscription

-------------------------------------
-- function init
-------------------------------------
function StructProductSubscription:init(data)
end

-------------------------------------
-- function create
-------------------------------------
function StructProductSubscription:create(data, sub_data)
    local struct = StructProductSubscription(data)

    struct:setStartDate(sub_data['start_date']) -- 판매 시작 시간
    struct:setEndDate(sub_data['end_date']) -- 판매 종료 시간
    struct:setUIPriority(tonumber(sub_data['ui_priority']) or 0) -- UI정렬 순선 (높으면 앞쪽에 노출)

    -- 구독상품에만 있는 데이터 설정
    struct.daily_term = sub_data['daily_term']
    struct.login_content = sub_data['login_content']
    struct.daily_content = sub_data['daily_content']
    struct:setSubscriptionCategory(sub_data['category'])
    struct:setNextDiscountProductID(sub_data['next'])

    return struct
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructProductSubscription:getClassName()
    return 'StructProductSubscription'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructProductSubscription:getThis()
    return THIS
end













-- get & set

-------------------------------------
-- function setSubscriptionCategory
-------------------------------------
function StructProductSubscription:setSubscriptionCategory(category_str)
    self.m_subscriptionCategory = category_str
end

-------------------------------------
-- function getSubscriptionCategory
-------------------------------------
function StructProductSubscription:getSubscriptionCategory()
    return self.m_subscriptionCategory
end

-------------------------------------
-- function setNextDiscountProductID
-------------------------------------
function StructProductSubscription:setNextDiscountProductID(product_id)
    self.m_nextDiscountProductID = product_id
end

-------------------------------------
-- function getNextDiscountProductID
-------------------------------------
function StructProductSubscription:getNextDiscountProductID()
    return self.m_nextDiscountProductID
end