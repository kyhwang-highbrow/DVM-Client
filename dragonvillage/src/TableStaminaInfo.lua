local PARENT = TableClass

-------------------------------------
-- class TableStaminaInfo
-------------------------------------
TableStaminaInfo = class(PARENT, {
    })

local THIS = TableStaminaInfo

-------------------------------------
-- function init
-------------------------------------
function TableStaminaInfo:init()
    self.m_tableName = 'table_stamina_info'
    self.m_orgTable = TABLE:get(self.m_tableName)
end


-------------------------------------
-- function getChargingTime
-------------------------------------
function TableStaminaInfo:getChargingTime(stamina_type)
    if (self == THIS) then
        self = THIS()
    end

    local charging_time = self:getValue(stamina_type, 'charging_time')
    return charging_time
end

-------------------------------------
-- function getDailyChargeLimit
-- @breif 일일 충전 횟수
-------------------------------------
function TableStaminaInfo:getDailyChargeLimit(stamina_type)
    if (self == THIS) then
        self = THIS()
    end

    local charge_limit = self:getValue(stamina_type, 'charge_limit')
    
    if (charge_limit == '') or (charge_limit == 0) then
        return nil
    end

    return charge_limit
end

-------------------------------------
-- function getDailyChargeInfo
-- @breif
-------------------------------------
function TableStaminaInfo:getDailyChargeInfo(stamina_type, charge_cnt)
    if (self == THIS) then
        self = THIS()
    end

    charge_cnt = (charge_cnt or 0)

    local charge_price = self:getValue(stamina_type, 'charge_price')
    local charge_add_price = self:getValue(stamina_type, 'charge_add_price')

    -- charge_add_price_count 비용 증가가 발생하는 충전 횟수
    -- charge_add_price_interval 비용 증가가 발생하는 간격
    local charge_add_price_count = self:getValue(stamina_type, 'charge_add_price_count')
    local charge_add_price_interval = self:getValue(stamina_type, 'charge_add_price_interval')

    -- 비용 증가가 발생하는 횟수를 넘었을 경우 비용 증가 처리
    if (not self:isNullOrEmpty(charge_add_price_count) and 
        not self:isNullOrEmpty(charge_add_price_interval) and 
        tonumber(charge_add_price_count) > 0) then

        -- 비용 증가가 시작되는 횟수를 초과했을 경우 비용 증가 처리
        if (charge_cnt >= tonumber(charge_add_price_count)) then
            local overflowCount = charge_cnt - tonumber(charge_add_price_count)
            local invervalCount = math.ceil(overflowCount / tonumber(charge_add_price_interval))

            charge_price = charge_price + invervalCount * charge_add_price
        end
    else
        charge_price = charge_price + (charge_cnt * charge_add_price)
    end

    local cnt = self:getValue(stamina_type, 'basic_count')
    

    return charge_price, cnt
end

-------------------------------------
-- function isNullOrEmpty
-- 널이나 빈 스트링인지?
-------------------------------------
function TableStaminaInfo:isNullOrEmpty(str)
    if (not str or str == '') then
        return true
    end

    return false
end

-------------------------------------
-- function getChargingCount
-- @jhakim 190618 고대의 탑이 max인 10개가 아니라 5개씩 충전되어, 충전값 칼럼을 새로 팜
-------------------------------------
function TableStaminaInfo:getChargingCount(stamina_type)
    if (self == THIS) then
        self = THIS()
    end

    local charging_count = self:getValue(stamina_type, 'charging_count')

    if (charging_count == '') then
        charging_count = nil
    end
    
    return charging_count
end