local PARENT = Structure

-------------------------------------
-- class StructMarketProduct
-------------------------------------
StructMarketProduct = class(PARENT, {
        m_rowData = 'table',
        m_market = 'string', -- 'google', 'apple', 'onestore'...
    })

local THIS = StructMarketProduct

-------------------------------------
-- function init
-------------------------------------
function StructMarketProduct:init(data)
    self.m_rowData = data or {}

    local market, os = GetMarketAndOS()
    self.m_market = market
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructMarketProduct:getClassName()
    return 'StructMarketProduct'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructMarketProduct:getThis()
    return THIS
end

-------------------------------------
-- function getCurrencyPrice
-- @return price (number)
-------------------------------------
function StructMarketProduct:getCurrencyPrice()
    local price = nil
    if (self.m_market == 'google') then
        price = (self.m_rowData['price_amount_micros'] / 1000000)

    elseif (self.m_market == 'apple') then
        -- PerpleSDK에서 apple의 경우 price가 '₩37000', '¥3680'형태로 넘어온다.
        local work_str = self.m_rowData['price']

        -- 1000단위 구분자 콤마(,) 제거
        work_str = string.gsub(work_str, ',', '')

        -- 숫자만 추출
        -- 소수점을 포함한 실수 형태 고려
        -- 문자열 내에 숫자가 여러개 있을 경우 마지막 숫자를 가져옴
        local last_number = nil
        for v in string.gmatch(work_str, '[0-9]+.[0-9]+') do
            local v_number = tonumber(v)
            if v_number then
                last_number = v_number
            end
        end

        price =  last_number
    end

    return tonumber(price)
end

-------------------------------------
-- function getCurrencyCode
-- @return currency_code (string) 'KRW', 'USD', 'JPY' ...
-------------------------------------
function StructMarketProduct:getCurrencyCode()
    local currency_code = nil
    if (self.m_market == 'google') then
        currency_code = self.m_rowData['price_currency_code']

    elseif (self.m_market == 'apple') then
        currency_code = self.m_rowData['price_currency_code']
    end

    return currency_code
end