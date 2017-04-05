local PARENT = TableDragonSkill

-------------------------------------
-- class TableMonsterSkill
-------------------------------------
TableMonsterSkill = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableMonsterSkill:init()
    self.m_tableName = 'monster_skill'
    self.m_orgTable = TABLE:get(self.m_tableName)
end