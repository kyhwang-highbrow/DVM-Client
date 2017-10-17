local PARENT = TableClass

-------------------------------------
-- class TableDragonType
-- @brief 드래곤 원종별로 정리된 테이블 (table_dragon에서 type이 같은 기준)
--        key값은 type ('powerdragon', 'taildragon')
-------------------------------------
TableDragonType = class(PARENT, {
    })

local THIS = TableDragonType

-------------------------------------
-- function init
-------------------------------------
function TableDragonType:init()
    self.m_tableName = 'dragon_type'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getBaseDid
-- @brief 드래곤 원종의 진짜 원종 did 리턴
-------------------------------------
function TableDragonType:getBaseDid(dragon_type)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(dragon_type, 'base_did')
end

-------------------------------------
-- function containsDid
-- @brief
-------------------------------------
function TableDragonType:containsDid(dragon_type, did)
    if (self == THIS) then
        self = THIS()
    end

    local l_did = self:getCommaSeparatedValues(dragon_type, 'did', true)

    local idx = table.find(l_did, tostring(did))
    return (nil ~= idx)
end

