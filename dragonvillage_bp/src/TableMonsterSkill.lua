local PARENT = TableDragonSkill

-------------------------------------
-- class TableMonsterSkill
-------------------------------------
TableMonsterSkill = class(PARENT, {
    })

local THIS = TableMonsterSkill

-------------------------------------
-- function init
-------------------------------------
function TableMonsterSkill:init()
    self.m_tableName = 'monster_skill'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function initGlobal
-------------------------------------
function TableMonsterSkill:initGlobal()
    if (self == THIS) then
        self = THIS()
    end
    
    self:makeFunctions()
end