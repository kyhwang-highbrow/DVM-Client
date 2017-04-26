local PARENT = TableClass

-------------------------------------
-- class TableMonsterHitPos
-------------------------------------
TableMonsterHitPos = class(PARENT, {
    })

local THIS = TableMonsterHitPos

-------------------------------------
-- function init
-------------------------------------
function TableMonsterHitPos:init()
    self.m_tableName = 'monster_hit_pos'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getBodyList
-- @brief
-------------------------------------
function TableMonsterHitPos:getBodyList(mid)
    if (self == THIS) then
        self = THIS()
    end

    local t_table = self.m_orgTable[mid]
    if (not t_table) then return end

    local ret = {}
    local idx = 1
    local str = t_table['body_' .. idx]

    while (str) do
        if (str == 'x' or str == '') then break end

        local l_str = self:seperate(str, ';')
        local x = tonumber(l_str[1]) or 0
        local y = tonumber(l_str[2]) or 0
        local size = tonumber(l_str[3]) or 0
        local bone_name = l_str[4]

        local body = {}
        body[1] = x
        body[2] = y
        body[3] = size
        body[4] = bone_name

        table.insert(ret, body)

        idx = idx + 1
        str = t_table['body_' .. idx]
    end

    return ret
end
