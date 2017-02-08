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
-- �Ķ����(���� �۾��Ǿ����)�� ���� ���� ������ �巡�� ����Ʈ�� ����
-------------------------------------
function TableSecretDungeon:getRandomDragonList(type)
    local type = type or 'relation_sun' -- �ӽ�

    local t_dungeon = self.m_orgTable[type]
    if (not t_dungeon) then return end

    local ret = {}
    local l_data = seperate(t_dungeon['obtain_dragon'], ';')
    
    for _, v in pairs(l_data) do
        table.insert(ret, v)
    end

    return ret
end