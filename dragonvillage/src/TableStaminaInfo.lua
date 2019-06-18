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
    charge_price = charge_price + (charge_cnt * charge_add_price)

    local cnt = self:getValue(stamina_type, 'basic_count')
    

    return charge_price, cnt
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