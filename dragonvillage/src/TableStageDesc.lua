local PARENT = TableClass

-------------------------------------
-- class TableStageDesc
-------------------------------------
TableStageDesc = class(PARENT, {
    })

local THIS = TableStageDesc

-------------------------------------
-- function init
-------------------------------------
function TableStageDesc:init()
    self.m_tableName = 'stage_desc'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function get
-------------------------------------
function TableStageDesc:get(key, skip_error_msg)
    if (key == COLOSSEUM_STAGE_ID) then return end
    if (key == ARENA_STAGE_ID) then return end
    if (key == ARENA_NEW_STAGE_ID) then return end
    if (key == CHALLENGE_MODE_STAGE_ID) then return end

    return PARENT.get(self, key, skip_error_msg)
end

-------------------------------------
-- function getStageDesc
-- @brief 스테이지 설명을 리턴
-------------------------------------
function TableStageDesc:getStageDesc(stage_id)
    local t_table = self:get(stage_id)
    local desc = t_table['t_desc']
    return Str(desc)
end

-------------------------------------
-- function getMonsterIconList
-- @brief 스테이지에 등장하는 몬스터 아이콘 리턴
-------------------------------------
function TableStageDesc:getMonsterIconList(stage_id)
    local l_moster_id = self:getMonsterIDList(stage_id)

    local l_icon_list = {}
    for i,v in ipairs(l_moster_id) do
        local icon = UI_MonsterCard(v)
        icon:setStageID(stage_id)
        table.insert(l_icon_list, icon)
    end
    
    return l_icon_list
end

-------------------------------------
-- function getLastMonsterIcon
-- @brief 스테이지에 등장하는 마지막 몬스터 아이콘 리턴
-------------------------------------
function TableStageDesc:getLastMonsterIcon(stage_id)
    local l_moster_id = self:getMonsterIDList(stage_id)

    local monster_id = l_moster_id[#l_moster_id]
    if (not monster_id) then
        return nil
    end

    local icon = UI_MonsterCard(monster_id)
    icon:setStageID(stage_id)
    return icon
end

-------------------------------------
-- function getMonsterIDList
-- @brief 스테이지에 등장하는 몬스터 ID 리스트를 리턴
-------------------------------------
function TableStageDesc:getMonsterIDList(stage_id)

    -- @jhakim 20190208 시즌별로 클랜던전 속성 정보를 받음 (table_stage_desc 테이블을 따르지 않음)
    if (TableStageData:isClanRaidStage(stage_id)) then
        local cur_clan_boss_attr = g_clanData:getCurSeasonBossAttr()
        stage_id = self:getStageIdByClanBossAttr(cur_clan_boss_attr)
    end
    
    local t_table = self:get(stage_id)

    if (not t_table) then return {} end

    local str = tostring(t_table['monster_id']) or ''
    local l_moster_id = plSplit(str, ';')

    for i,v in ipairs(l_moster_id) do
        l_moster_id[i] = tonumber(trim(v))
    end

    return l_moster_id or {}
end

-------------------------------------
-- function getMonsterIDList_ClanMonster
-- @brief 클랜 보스 애니 소스를 속성별로 가져옴
-------------------------------------
function TableStageDesc:getMonsterIDList_ClanMonster(attr)  
    local stage_id = self:getStageIdByClanBossAttr(attr)
   
    local t_table = self:get(stage_id)
    local str = tostring(t_table['monster_id']) or ''
    local l_moster_id = plSplit(str, ';')

    for i,v in ipairs(l_moster_id) do
        l_moster_id[i] = tonumber(trim(v))
    end

    return l_moster_id or {}
end

-------------------------------------
-- function getStageIdByClanBossAttr
-- @brief 스테이지에 등장하는 몬스터 ID 리스트를 리턴
-------------------------------------
function TableStageDesc:getStageIdByClanBossAttr(cur_clan_boss_attr)
    local stage_id = 1500001 -- 디폴트 값
    if (cur_clan_boss_attr == 'earth') then stage_id = 1500001
        elseif (cur_clan_boss_attr == 'water') then stage_id = 1500002
        elseif (cur_clan_boss_attr == 'fire') then stage_id = 1500003
        elseif (cur_clan_boss_attr == 'light') then stage_id = 1500004
        elseif (cur_clan_boss_attr == 'dark') then stage_id = 1500005
    end
    return stage_id
end

-------------------------------------
-- function isBossStage
-- @brief 보스 스테이지인지 여부
-------------------------------------
function TableStageDesc:isBossStage(stage_id)
    if (self == THIS) then
        self = THIS()
    end

    local l_moster_id = self:getMonsterIDList(stage_id)

    local monster_id = l_moster_id[#l_moster_id]
    if (not monster_id) then
        return false
    end

    local is_boss_monster = TableMonster:isBossMonster(monster_id)
	return is_boss_monster, monster_id
end

-------------------------------------
-- function getScenarioName
-- @brief
-------------------------------------
function TableStageDesc:getScenarioName(stage_id, trriger)
    if (self == THIS) then
        self = THIS()
    end
    
    local t_table = self:get(stage_id)
    if (not t_table) then
        return
    end
    
    local scenario_name = t_table[trriger]
    scenario_name = self:checkStartTamerScenario(scenario_name)

    if (scenario_name == '') then
        return nil
    end

    return scenario_name
end

-------------------------------------
-- function checkStartTamerScenario
-- @brief snro_start, snro_finish 최초 선택한 테이머 정보에 따라 시나리오 진행 
-- @brief _nuri, _goni .. 로 구분
-- @brief ex) scenario_01_01_start_nuri;scenario_01_01_start_goni
-------------------------------------
function TableStageDesc:checkStartTamerScenario(scenario_name)
    if (not string.find(scenario_name, ';')) then return scenario_name end

    -- 기존에 만들어진 계정일 경우 선택한 테이머 정보 없을 수 있음 - defualt : goni
    local tid           = g_userData:get('start_tamer')
    local tamer_name    = TableTamer():getTamerType(tid) or 'goni'

    local l_str = seperate(scenario_name, ';')
    for _, str in ipairs(l_str) do
        if (string.find(str, tamer_name)) then
            return str
        end
    end

    return l_str[1]
end


-------------------------------------
-- function getPreloadStageList
-- @brief preload용 스테이지 리스트 만들어서 반환
-------------------------------------
function TableStageDesc:getPreloadStageList()
    if (self == THIS) then
        self = THIS()
    end

    local t_stage_data = TableStageData()
    local l_stage = {}
    
    for stage_id, _ in pairs(self.m_orgTable) do       
        -- @jhakim 20190208 클랜던전은 preload리스트에서 제외
        if (not t_stage_data:isClanRaidStage(stage_id)) then
            table.insert(l_stage, stage_id)    
        end
    end

    return l_stage
end

-------------------------------------
--- @function getRecommendedCombatPower
--- @brief 스테이지 권장 전투력
-------------------------------------
function TableStageDesc:getRecommendedCombatPower(stage_id)
    local combat_power = self:getValue(stage_id, 'recomm_power')
    return combat_power
end
