local PARENT = TableClass

-------------------------------------
-- class TableDrop
-------------------------------------
TableDrop = class(PARENT, {
    })

local THIS = TableDrop

-------------------------------------
-- function init
-------------------------------------
function TableDrop:init()
    self.m_tableName = 'drop'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getStageMissionList
-------------------------------------
function TableDrop:getStageMissionList(stage_id)
	local t_drop = self:get(stage_id)
    local t_ret = {}

    for i=1, 3 do
        local mission_str = t_drop['mission_0' .. i]
        local trim_execution = true
        local l_list = self:seperate(mission_str, ',', trim_execution)
		table.insert(t_ret, l_list)
		--[[
			local type = l_list[1]
			local value_1 = l_list[2]
			local value_2 = l_list[3]
			local value_3 = l_list[4]
		]]
	end

	return t_ret
end

-------------------------------------
-- function getStageStaminaType
-------------------------------------
function TableDrop:getStageStaminaType(stage_id)
    if (self == THIS) then
        self = THIS()
    end

    if (stage_id == COLOSSEUM_STAGE_ID) then
        return 'pvp', 1
    end

    local stamina_type = self:getValue(stage_id, 'cost_type')
    local req_count = self:getValue(stage_id, 'cost_value')
    return stamina_type, req_count
end

-------------------------------------
-- function getStageBonusGoldInfo
-- @breif 스테이지에서 보너스 골드 획득하는 정보
-------------------------------------
function TableDrop:getStageBonusGoldInfo(stage_id)
    if (self == THIS) then
        self = THIS()
    end

    local gold_per_hit
    local gold_per_damage
    local gold_per_limit

    if (not self:exists(stage_id)) then
        gold_per_hit = 0
        gold_per_damage = 0
        gold_per_limit = 0
    else
        local t_table = self:get(stage_id)
        gold_per_hit = t_table['gph']
        gold_per_damage = t_table['gpd']
        gold_per_limit = t_table['gpl']
    end

    return gold_per_hit, gold_per_damage, gold_per_limit
end

-------------------------------------
-- function getStageAttr
-------------------------------------
function TableDrop:getStageAttr(stage_id)
    if (self == THIS) then
        self = THIS()
    end

    local attr = self:getValue(stage_id, 'attr')
    return attr
end

-------------------------------------
-- function getStageLevel
-------------------------------------
function TableDrop:getStageLevel(stage_id)
    if (self == THIS) then
        self = THIS()
    end

    local level = self:getValue(stage_id, 'level') or 0
    return level + 1
end

-------------------------------------
-- function getStageBuff
-------------------------------------
function TableDrop:getStageBuff(stage_id, key)
    if (self == THIS) then
        self = THIS()
    end

    local str = self:getValue(tonumber(stage_id), 'buff_' .. key)
    if (str == 'x' or str == '') then return end

    local l_ret = {}
    local make_data = function(str)
        local ret = {}
        local l_str = self:seperate(str, ';')

        ret['condition_type'] = l_str[1]
        ret['condition_value'] = l_str[2]
        ret['buff_type'] = l_str[3]
        ret['buff_value'] = tonumber(l_str[4])

        return ret
    end

    if (string.find(str, ',')) then
        local l_str = self:seperate(str, ',')

        for i, str in ipairs(l_str) do
            local data = make_data(str)
            table.insert(l_ret, data)
        end
    else
        local data = make_data(str)
        table.insert(l_ret, data)
    end

    return l_ret
end

-------------------------------------
-- function getStageHeroBuff
-------------------------------------
function TableDrop:getStageHeroBuff(stage_id)
    return self:getStageBuff(stage_id, 'user')
end

-------------------------------------
-- function getStageEnemyBuff
-------------------------------------
function TableDrop:getStageEnemyBuff(stage_id)
    return self:getStageBuff(stage_id, 'enemy')
end