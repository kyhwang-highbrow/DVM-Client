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
-- function getGoldInfo
-------------------------------------
function TableSecretDungeon:getGoldInfo(stage_id)
     local stage_id = stage_id or 32007 -- �ӽ�

    local t_dungeon = self.m_orgTable[stage_id]
    if (not t_dungeon) then return end

    local base_gold = t_dungeon['base_gold'] or 0
    local gold_per_damage = t_dungeon['gold_per_damage'] or 0

    return base_gold, gold_per_damage
end

-------------------------------------
-- function getRandomDragonList
-- �Ķ����(���� �۾��Ǿ����)�� ���� ���� ������ �巡�� ����Ʈ�� ����
-------------------------------------
function TableSecretDungeon:getRandomDragonList(stage_id)
    local stage_id = stage_id or 32007 -- �ӽ�

    local t_dungeon = self.m_orgTable[stage_id]
    if (not t_dungeon) then return end

    local ret = {}
    local l_data = seperate(t_dungeon['obtain_dragon'], ';')
    
    for _, v in pairs(l_data) do
        table.insert(ret, v)
    end

    return ret
end