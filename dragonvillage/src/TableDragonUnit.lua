local PARENT = TableClass

-------------------------------------
-- class TableDragonUnit
-------------------------------------
TableDragonUnit = class(PARENT, {
    })

local THIS = TableDragonUnit

-------------------------------------
-- function init
-------------------------------------
function TableDragonUnit:init()
    self.m_tableName = 'dragon_unit'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getStoryScene
-------------------------------------
function TableDragonUnit:getStoryScene(unit_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(unit_id, 'scene_id')
end

-------------------------------------
-- function getUnitConditionStr
-------------------------------------
function TableDragonUnit:getUnitConditionStr(unit_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(unit_id, 'condition')
end

-------------------------------------
-- function getUnitRewardStr
-------------------------------------
function TableDragonUnit:getUnitRewardStr(unit_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(unit_id, 'reward')
end

-------------------------------------
-- function getUnitBuff
-------------------------------------
function TableDragonUnit:getUnitBuff(unit_id)
    if (self == THIS) then
        self = THIS()
    end

    local l_str = self:getSemicolonSeparatedValues(unit_id, 'buff', true)
    local option_str = l_str[1]
    local value = l_str[2]

    local status, action = TableOption:parseOptionKey(option_str)

    return status, action, value
end