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