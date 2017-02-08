local PARENT = TableClass

-------------------------------------
-- class TableSecretDungeon
-------------------------------------
TableSecretDungeon = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableSecretDungeon:init()
    self.m_tableName = 'secret_dungeon'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getRandomDragonList
-- 파라미터(차후 작업되어야함)에 따라 등장 가능한 드래곤 리스트를 얻음
-------------------------------------
function TableSecretDungeon:getRandomDragonList(type)
    local type = type or 'relation_sun' -- 임시

    local t_dungeon = self.m_orgTable[type]
    if (not t_dungeon) then return end

    local ret = {}
    local l_data = seperate(t_dungeon['obtain_dragon'], ';')
    
    for _, v in pairs(l_data) do
        table.insert(ret, v)
    end

    return ret
end