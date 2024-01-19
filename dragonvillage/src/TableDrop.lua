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
-- function get
-------------------------------------
function TableDrop:get(key, skip_error_msg)
    if (key == COLOSSEUM_STAGE_ID) then return end
    if (key == ARENA_STAGE_ID) then return end
    if (key == ARENA_NEW_STAGE_ID) then return end
    if (key == CHALLENGE_MODE_STAGE_ID) then return end

    return PARENT.get(self, key, skip_error_msg)
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

    elseif (stage_id == ARENA_STAGE_ID) then
        return 'arena', 1

    elseif (stage_id == ARENA_NEW_STAGE_ID) then
        return 'arena_new', 1

    elseif (stage_id == FRIEND_MATCH_STAGE_ID) then
        return 'fpvp', 1

    elseif (g_clanRaidData:isClanRaidStageID(stage_id)) then
        return 'cldg', 1

    elseif (stage_id == CHALLENGE_MODE_STAGE_ID) then
        return 'st', 1

    -- 그랜드 콜로세움 (이벤트 PvP 10대10)
    elseif (stage_id == GRAND_ARENA_STAGE_ID) then
        return 'grand_arena', 1

	-- 클랜전 임시
    elseif (stage_id == CLAN_WAR_STAGE_ID) then
        return 'arena', 1

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
        gold_per_hit = tonumber(t_table['gph']) or 0
        gold_per_damage = tonumber(t_table['gpd']) or 0
        gold_per_limit = tonumber(t_table['gpl']) or 0
    end

    return gold_per_hit, gold_per_damage, gold_per_limit
end

-------------------------------------
-- function getStageListBySeasonID
-------------------------------------
function TableDrop:getStageListBySeasonID(season_id)
    if (self == THIS) then
        self = THIS()
    end
    
    local list = self:filterColumnList('season_id', season_id, 'stage')
    return list
end