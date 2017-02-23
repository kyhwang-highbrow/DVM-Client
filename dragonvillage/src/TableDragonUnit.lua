local PARENT = TableClass

-------------------------------------
-- class TableDragonUnit
-------------------------------------
TableDragonUnit = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableDragonUnit:init()
    self.m_tableName = 'dragon_unit'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getUnitDragonList
-------------------------------------
function TableDragonUnit:getUnitDragonList(unit_id)
    local t_table = self:get(unit_id)

    local l_ret = {}

    local trim_execution = true
    local l_unit_type = self:getCommaSeparatedValues(unit_id, 'unit_type', trim_execution)
    for i,v in ipairs(l_unit_type) do
        table.insert(l_ret, {type='category', value=v})
    end

    local l_unit_did = self:getCommaSeparatedValues(unit_id, 'unit_did', trim_execution)
    for i,v in ipairs(l_unit_did) do
        table.insert(l_ret, {type='dragon', value=tonumber(v)})
    end

    return l_ret
end