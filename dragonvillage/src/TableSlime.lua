local PARENT = TableClass

-------------------------------------
-- class TableSlime
-------------------------------------
TableSlime = class(PARENT, {
    })

local THIS = TableSlime

-------------------------------------
-- function init
-------------------------------------
function TableSlime:init()
    self.m_tableName = 'table_slime'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getValue
-------------------------------------
function TableSlime:getValue(primary, column)
    if (self == THIS) then
        self = THIS()
    end

    return PARENT.getValue(self, primary, column)
end

-------------------------------------
-- function getDesc
-------------------------------------
function TableSlime:getDesc(slime_id)
    local desc = self:getValue(slime_id, 't_desc')
    return Str(desc)
end


-------------------------------------
-- function isSlimeID
-------------------------------------
function TableSlime:isSlimeID(id)
    local code = getDigit(id, 1000, 3)
    --129113
    if (code == 129) then
        return true
    end
    return false
end