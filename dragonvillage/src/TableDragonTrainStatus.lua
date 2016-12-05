local PARENT = TableClass

-------------------------------------
-- class TableDragonTrainStatus
-------------------------------------
TableDragonTrainStatus = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableDragonTrainStatus:init()
    self.m_tableName = 'dragon_train_status'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getTrainStatus
-- @breif 드래곤의 수련에 의한 상승된 능력치 리턴
-- @param did number 드래곤 ID (120071)
-- @param t_rain_slot table
--        t_train_slot = {}
--        t_train_slot['01_a'] = 1~10
--        t_train_slot['01_b'] = 1~10
--        ...
--        t_train_slot['06_a'] = 1~10
--        t_train_slot['06_b'] = 1~10          
-------------------------------------
function TableDragonTrainStatus:getTrainStatus(did, t_train_slot)
    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(did)
    local dragon_role = t_dragon['role']

    local atk_rate = 0
    local def_rate = 0
    local hp_rate = 0

    for slot_type,slot_level in pairs(t_train_slot) do
        local _atk_rate, _def_rate, _hp_rate = self:getTrainSlotStatusRate(dragon_role, slot_type, slot_level)
        atk_rate = (atk_rate + _atk_rate)
        def_rate = (def_rate + _def_rate)
        hp_rate = (hp_rate + _hp_rate)
    end

    -- rate는 0~100으로 표현되어 표시하기 때문에 100으로 나누어 준다.
    local atk = (atk_rate / 100) * t_dragon['atk_max']
    local def = (def_rate / 100) * t_dragon['def_max']
    local hp = (hp_rate / 100) * t_dragon['hp_max']

    atk = math_floor(atk)
    def = math_floor(def)
    hp = math_floor(hp)

    local t_ret = {atk=atk, def=def, hp=hp}
    return t_ret
end

-------------------------------------
-- function getTrainSlotStatusRate
-- @brief 수련 슬롯 별 상승될 능력치의 비율 리턴
-------------------------------------
function TableDragonTrainStatus:getTrainSlotStatusRate(dragon_role, slot_type, slot_level)
    local t_dragon_train_status = self:get(slot_type)

    local atk_rate = self:getStatusRate(t_dragon_train_status, dragon_role, 'atk', slot_level)
    local def_rate = self:getStatusRate(t_dragon_train_status, dragon_role, 'def', slot_level)
    local hp_rate = self:getStatusRate(t_dragon_train_status, dragon_role, 'hp', slot_level)

    return atk_rate, def_rate, hp_rate
end

-------------------------------------
-- function getStatusRate
-- @brief 수련 슬롯의 상승될 능력치의 비율 리턴
-------------------------------------
function TableDragonTrainStatus:getStatusRate(t_dragon_train_status, dragon_role, status_type, multiply)
    local key = dragon_role .. '_' .. status_type
    local value = t_dragon_train_status[key]

    if (not value) or (value == '') then
        value = 0
    end

    -- 10번의 레벨업을 했을 때 수치이기 때문에 10으로 나누어 준다.
    value = (value / 10)

    if multiply then
        value = (value * multiply)
    end

    return value
end