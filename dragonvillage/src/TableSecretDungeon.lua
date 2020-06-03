local PARENT = TableClass

-------------------------------------
-- class TableSecretDungeon
-------------------------------------
TableSecretDungeon = class(PARENT, {
    })

local t_obtain_dragon_list = nil

-------------------------------------
-- function init
-------------------------------------
function TableSecretDungeon:init()
    self.m_tableName = 'secret_dungeon'
    self.m_orgTable = TABLE:get(self.m_tableName)

	if (not t_obtain_dragon_list) then
		self:init_obtainable_dragon()
	end
end

-------------------------------------
-- function init_obtainable_dragon
-- @brief 인연 던전에서 획득 가능한 드래곤 테이블 생성
-------------------------------------
function TableSecretDungeon:init_obtainable_dragon()
	t_obtain_dragon_list = {}
	local l_dragon
	for stage_id, t_dungeon in pairs(self.m_orgTable) do
		l_dragon = seperate(t_dungeon['obtain_dragon'], ',')
    
		for _, did in pairs(l_dragon) do
			t_obtain_dragon_list[did] = true
		end
	end
end

-------------------------------------
-- function getGoldInfo
-------------------------------------
function TableSecretDungeon:getGoldInfo(stage_id)
     local stage_id = stage_id or 32101 -- 임시

    local t_dungeon = self.m_orgTable[stage_id]
    if (not t_dungeon) then return end

    local base_gold = t_dungeon['base_gold'] or 0
    local gold_per_damage = t_dungeon['gold_per_damage'] or 0

    return base_gold, gold_per_damage
end

-------------------------------------
-- function getRandomDragonList
-- 파라미터(차후 작업되어야함)에 따라 등장 가능한 드래곤 리스트를 얻음
-------------------------------------
function TableSecretDungeon:getRandomDragonList(stage_id)
    local stage_id = stage_id or 32101 -- 임시

    local t_dungeon = self.m_orgTable[stage_id]
    if (not t_dungeon) then return end

    local ret = {}
    local l_data = seperate(t_dungeon['obtain_dragon'], ',')
    
    for _, v in pairs(l_data) do
        table.insert(ret, v)
    end

    return ret
end

-------------------------------------
-- function getObtainableDragonList
-------------------------------------
function TableSecretDungeon:getObtainableDragonList()
    if (self == THIS) then
        self = THIS()
    end

	return t_obtain_dragon_list
end