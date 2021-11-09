local PARENT = TableClass

-------------------------------------
-- class TableStageData
-------------------------------------
TableStageData = class(PARENT, {
    })

local THIS = TableStageData

-------------------------------------
-- function init
-------------------------------------
function TableStageData:init()
    self.m_tableName = 'stage_data'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function get
-------------------------------------
function TableStageData:get(key, skip_error_msg)
    if (key == COLOSSEUM_STAGE_ID) then return end
    if (key == ARENA_NEW_STAGE_ID) then return end
    if (key == FRIEND_MATCH_STAGE_ID) then return end
        
    return PARENT.get(self, key, skip_error_msg)
end



-------------------------------------
-- function parseStageBuffStr
-------------------------------------
function TableStageData:parseStageBuffStr(buff_str)
    if (self == THIS) then
        self = THIS()
    end

    local str = buff_str
    if (str == nil or str == 'x' or str == '') then return end

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
-- function getStageBuff
-------------------------------------
function TableStageData:getStageBuff(stage_id, is_enemy)
    if (self == THIS) then
        self = THIS()
    end

    local key
    if (is_enemy) then
        key = 'enemy'
    else
        key = 'user'
    end

    local str = self:getValue(tonumber(stage_id), 'buff_' .. key)
    if (str == nil or str == 'x' or str == '') then return end

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
-- function getStageAttr
-------------------------------------
function TableStageData:getStageAttr(stage_id)
    if (self == THIS) then
        self = THIS()
    end

    if (self:isClanRaidStage(stage_id)) then
        if (g_clanData) then
            return g_clanData:getCurSeasonBossAttr()
        end
    end
    
    local attr = self:getValue(stage_id, 'attr')
    return attr
end

-------------------------------------
-- function getStageLevel
-------------------------------------
function TableStageData:getStageLevel(stage_id)
    if (self == THIS) then
        self = THIS()
    end

    local level = self:getValue(stage_id, 'level') or 0
    return level + 1
end

-------------------------------------
-- function getRecommendedCombatPower
-- @brief 스테이지 권장 전투력
-------------------------------------
function TableStageData:getRecommendedCombatPower(stage_id, game_mode)
    --[[
    local wave_mgr

    if (game_mode == GAME_MODE_SECRET_DUNGEON) then
        wave_mgr = WaveMgr_SecretRelation(nil, 'stage_' .. stage_id, stage_id)
    else
        wave_mgr = WaveMgr(nil, 'stage_' .. stage_id, stage_id)
    end

    local boss_id, boss_lv = wave_mgr:getFinalBossInfo()
    if (not boss_id) then return 0 end

    boss_lv = boss_lv + 20

    local boss_type = isMonster(boss_id) and 'monster' or 'dragon'
    local status_calc

    if (boss_type == 'dragon') then
        status_calc = StatusCalculator('dragon', boss_id, boss_lv, 1, 3, 0)

    else
        status_calc = StatusCalculator('monster', boss_id, boss_lv, 0, 0, 0)
    
        -- 몬스터의 경우만 rarity별로 hp를 낮춤
        local rarity = TableMonster():getValue(boss_id, 'rarity')

        if (rarity == 'boss') then
            local param = g_constant:get('UI', 'BOSS_COMBAT_POWER_PARAMETER_PER_RARITY')[1]
            status_calc:addBuffMulti('hp', (100 / param) - 100)
        elseif (rarity == 'subboss') then
            local param = g_constant:get('UI', 'BOSS_COMBAT_POWER_PARAMETER_PER_RARITY')[2]
            status_calc:addBuffMulti('hp', (100 / param) - 100)
        elseif (rarity == 'elite') then
            local param = g_constant:get('UI', 'BOSS_COMBAT_POWER_PARAMETER_PER_RARITY')[3]
            status_calc:addBuffMulti('hp', (100 / param) - 100)
        end
    end

    local t_value = g_constant:get('UI', 'BOSS_COMBAT_POWER_VALUE')
    local combat_power = status_calc:getCombatPower()

    combat_power = combat_power + (t_value[1] + ((boss_lv - 1) / t_value[2]) * t_value[3])
    combat_power = combat_power * 5
    
    return math_floor(combat_power)
    ]]--
    local level
    
    if (game_mode == GAME_MODE_SECRET_DUNGEON) then
        level = 320
    else
        level = self:getValue(stage_id, 'level')
    end

    -- 3000 + (레벨*(1+0.0005*레벨))*197
    local combat_power = 3000 + (level * (1 + 0.0005 * level)) * 197

    return combat_power
end

-------------------------------------
-- function verifyTable
-------------------------------------
function TableStageData:verifyTable()
    if (self == THIS) then
        self = THIS()
    end

    local l_stage_id = {}

    local function doTest(stage_id, is_enemy)
        local list = self:getStageBuff(stage_id, is_enemy)
        if (not list) then return end

        for i, data in ipairs(list) do
            for _, key in ipairs({'condition_type', 'condition_value', 'buff_type', 'buff_value'}) do
                if (not data[key]) then
                    table.insert(l_stage_id, stage_id)
                    return
                end
            end
        end
    end

    cclog('TableStageData:verifyTable()')

    for stage_id, v in pairs(self.m_orgTable) do
        -- 아군 버프
        doTest(stage_id)

        -- 적군 버프
        doTest(stage_id, true)
    end

    table.sort(l_stage_id, function(a, b) return a < b end)

    -- log
    for _, stage_id in ipairs(l_stage_id) do
        cclog('invalid buff data stage  : ' .. stage_id)
    end
end

-------------------------------------
-- function isClanRaidStage
-------------------------------------
function TableStageData:isClanRaidStage(stage_id)
    local game_mode = string.sub(tostring(stage_id), 1, 2)

    if (game_mode == '15') then
        return true
    end
    
    return false
end