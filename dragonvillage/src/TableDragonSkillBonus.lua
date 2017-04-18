local PARENT = TableClass

-------------------------------------
-- class TableDragonSkillBonus
-------------------------------------
TableDragonSkillBonus = class(PARENT, {
    })

local THIS = TableDragonSkillBonus

-------------------------------------
-- function init
-------------------------------------
function TableDragonSkillBonus:init()
    self.m_tableName = 'dragon_skill_bonus'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getBaseDid
-- @brief 해당 드래곤의 보너스 단계별 조건값 리스트를 리턴
-------------------------------------
function TableDragonSkillBonus:getLevelCondition(did)
    if (self == THIS) then
        self = THIS()
    end

    local t_info = self.m_orgTable[did]
    if (not t_info) then return end

    local ret = {}
    local idx = 1
    local value = t_info['condition_' .. idx]
    
    while(value) do
        table.insert(ret, value)

        idx = idx + 1
        value = t_info['condition_' .. idx]
    end

    return ret
end