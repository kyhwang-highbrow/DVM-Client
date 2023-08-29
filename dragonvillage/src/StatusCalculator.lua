L_BASIC_STATUS_TYPE = {
        'atk',          -- 공격력
        'def',          -- 방어력
        'hp',           -- 생명력

        'aspd',         -- 공격속도
        'cri_chance',   -- 치명확률
        'cri_dmg',      -- 치명피해

        'cri_avoid',    -- 치명방어
        'hit_rate',     -- 적중률
        'avoid',        -- 회피

        'accuracy',     -- 효과 적중 +{1}%
        'resistance',   -- 효과 저항 +{1}%
    }

L_SPECIAL_STATUS_TYPE_ONLY_ADD = {
    'dmg_adj_rate', -- 받는 데미지 조정 계수
	'attr_adj_rate',-- 속성 조정 계수
    'attr_weak_adj_rate',-- 역속성 조정 계수
    'atk_dmg_adj_rate',-- 공격 데미지 조정 계수
    'cri_dmg_adj_rate',-- 치명시 데미지 조정 계수

    -- 룬 세트가 추가되면서 추가된 능력치
    'accuracy',     -- 효과 적중 +{1}%
    'resistance',   -- 효과 저항 +{1}%
    'cool_actu',    -- 패시브 쿨타임 시간 +{1}% 감소
    'drag_cool',    -- 드래그 쿨타임 시간 +{1}% 감소
    'guard_rear',   -- 자신보다 후방에 있는 아군의 피해를 대신 받아줄 확률 +{1}%

    -- 스테이지 버프로 추가된 능력치
    'hp_drain',         -- 공격 명중시 피해량의 +{1}% 만큼 HP회복
    'drag_dmg',         -- 드래그 스킬 데미지 +{1}% 만큼 증가
    'heal_power',       -- 회복 스킬 효과 +{1}% 증가
    'debuff_time',      -- 해로운 효과 지속 시간 +{1}% 증가(자신이 걸릴때)
    'target_debuff_time',-- 대상의 해로운 효과 지속 시간 +{1}% 증가(자신이 부여할때)

    -- 전투 로직 개편의 추가 옵션을 위해 추가된 능력치
    'recovery_power',   -- 받는 치유 효과 +{1}% 증가
    'reflex_normal',    -- 일반 데미지 +{1}% 반사
    'reflex_skill',     -- 스킬 데미지 +{2}% 반사
    'pierce',           -- 방어력 관통 +{1}% 만큼 적의 방어력의 옵션 수치 %를 삭감.

    -- 특성이 추가되면서 추가된 능력치
    'basic_dmg',        -- 일반 공격 데미지 +{1}% 만큼 증가
}

L_SPECIAL_STATUS_TYPE_ONLY_MULTI = {
    'final_dmg_rate',   -- 최종 피해량(기본 값 1)
    'final_heal_rate',  -- 최종 치유량(기본 값 1)
}

-- 스텟 타입 체크를 위한 맵 생성
M_SPECIAL_STATUS_TYPE_ONLY_ADD = {
    aspd = true,
    cri_chance = true,
    cri_dmg = true,
    cri_avoid = true,
    hit_rate = true,
    avoid = true,
    guard_rear = true
}

M_SPECIAL_STATUS_TYPE_ONLY_MULTI = {}

for i, v in ipairs(L_SPECIAL_STATUS_TYPE_ONLY_ADD) do
    M_SPECIAL_STATUS_TYPE_ONLY_ADD[v] = true
end

for i, v in ipairs(L_SPECIAL_STATUS_TYPE_ONLY_MULTI) do
    M_SPECIAL_STATUS_TYPE_ONLY_MULTI[v] = true
end

local function merge_without_duplicate(lhs, rhs)
    local key_table = {}
    for i, key in ipairs(lhs) do
        key_table[key] = true
    end
    for i, key in ipairs(rhs) do
        key_table[key] = true
    end

    local result = {}
    for key, _ in pairs(key_table) do
        table.insert(result, key)
    end
    
    return result
end

L_STATUS_TYPE = merge_without_duplicate(L_BASIC_STATUS_TYPE, L_SPECIAL_STATUS_TYPE_ONLY_ADD)
L_STATUS_TYPE = merge_without_duplicate(L_STATUS_TYPE, L_SPECIAL_STATUS_TYPE_ONLY_MULTI)

-------------------------------------
-- class StatusCalculator
-------------------------------------
StatusCalculator = class({
        m_lStatusList = 'list',

        -- 세부 능력치 적용
        m_attackTick = 'number',
        
        m_charType = 'string',
        m_chapterID = 'number',

        m_charTable = '',
        m_evolutionTable = '',
        m_gradeTable = '',

        m_masteryLv = '',

        m_tHiddenInfo = 'table',   -- 스테이터스 관련된 추가 정보를 저장하기 위한 테이블
    })

-------------------------------------
-- function init
-------------------------------------
function StatusCalculator:init(char_type, cid, lv, grade, evolution, eclv)
    self.m_charType = char_type
    self.m_chapterID = cid
    eclv = (eclv or 0)
    self.m_charTable = TABLE:get(char_type)
    if (char_type == 'dragon') then
        self.m_evolutionTable = TableEvolutionInfo()
        self.m_gradeTable = TableGradeInfo()
    end
    self.m_lStatusList = self:calcStatusList(char_type, cid, lv, grade, evolution, eclv)

    -- # 세부 능력치 적용
    self.m_attackTick = self:getAttackTick()
    
    self.m_tHiddenInfo = {}

    self.m_masteryLv = 0
end

-------------------------------------
-- function calcStatusList
-------------------------------------
function StatusCalculator:calcStatusList(char_type, cid, lv, grade, evolution, eclv)
    local l_status = {}

    -- 기본 능력치들 계산
    for _, status_name in pairs(L_BASIC_STATUS_TYPE) do
        -- accuracy / resistance 드래곤일 때만 추가
        if (char_type ~= 'dragon' and isExistValue(status_name, 'accuracy', 'resistance')) then
            -- do nothing
        else
            local basic_stat, base_stat, lv_stat, grade_stat, evolution_stat, eclv_stat = self:calcStat(char_type, cid, status_name, lv, grade, evolution, eclv)

            local indivisual_status = StructIndividualStatus(status_name)
            indivisual_status:setBasicStat(base_stat, lv_stat, grade_stat, evolution_stat, eclv_stat)

            -- 능력치별 최대 버프 수치값 설정
            local t_info = g_constant:get('INGAME', 'BUFF_MULTI_MIN_MAX')[status_name]
            if (t_info) then
                indivisual_status:setMinMaxForBuffMulti(t_info[1], t_info[2])
            end

            l_status[status_name] = indivisual_status--t_status
        end
    end
    
    -- 확장 능력치들 구조 생성
    for _,status_name in pairs(L_STATUS_TYPE) do
        if (not l_status[status_name]) then
            l_status[status_name] = StructIndividualStatus(status_name)
        end
    end

    -- 곱연산만 가능한 능력치의 기본값을 1로 설정
    for _,status_name in pairs(L_SPECIAL_STATUS_TYPE_ONLY_MULTI) do
        if (not l_status[status_name]) then
            l_status[status_name] = StructIndividualStatus(status_name)
        end

        l_status[status_name].m_baseStat = 1
    end

    -- 직군별(방어형, 공격형, 회복형, 지원형) 보너스
    do
        local t_char = self.m_charTable[cid]
        if (t_char) then
            local role = t_char['role']
            local t_info = g_constant:get('INGAME', 'STAT_BONUS_BY_ROLE')
            if (t_info and t_info[role]) then
                for status_name, role_stat in pairs(t_info[role]) do
                    if (l_status[status_name]) then
                        l_status[status_name]:setRoleStat(role_stat)
                    end
                end
            end
        end
    end

    -- 몬스터의 경우 특정 스텟을 몬스터 테이블로부터 가져옴
    if (char_type == 'monster') then
        local t_char = self.m_charTable[cid]
        if (t_char) then
            for _, status_name in pairs(L_SPECIAL_STATUS_TYPE_ONLY_ADD) do
                if (l_status[status_name] and t_char[status_name]) then
                    l_status[status_name].m_baseStat = t_char[status_name]
                end
            end
        end
    end

    return l_status
end

-------------------------------------
-- function getBasicStat
-- @brief 기본 + 레벨 + 등급 + 진화 + 친밀도 + 강화
-------------------------------------
function StatusCalculator:getBasicStat(stat_type)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    local basic_stat = indivisual_status:getBasicStat()
    return basic_stat
end

-------------------------------------
-- function getLevelStat
-- @brief 기본 + 레벨 + 등급 + 진화 + 친밀도 + 강화
-------------------------------------
function StatusCalculator:getLevelStat(stat_type)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    local basic_stat = indivisual_status:getLevelStat()
    return basic_stat
end

-------------------------------------
-- function getDeltaStatDisplay
-------------------------------------
function StatusCalculator:getDeltaStatDisplay(stat_type, use_percent)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    local basic_stat = indivisual_status:getBasicStat()
    local final_stat = indivisual_status:getFinalStat()
    local dt_stat = comma_value(math_floor(final_stat - basic_stat))

    if (use_percent) then
        return string.format('(+ %s%%)', dt_stat)
    else
        return string.format('(+ %s)', dt_stat)
    end
end

-------------------------------------
-- function getFinalStat
-------------------------------------
function StatusCalculator:getFinalStat(stat_type, is_power) 
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    local is_new_power = is_power == true and USE_NEW_COMBAT_POWER_CALC or false
    local final_stat = is_new_power == true and indivisual_status:getFinalStat_ExcludeMastery() or indivisual_status:getFinalStat()

    -- 공속(aspd)값은 최소값을 50으로 고정
    if (stat_type == 'aspd') then
        final_stat = math_max(final_stat, 50)
    elseif (stat_type == 'dmg_adj_rate') then
        final_stat = math_max(final_stat, -80)
    elseif (stat_type == 'guard_rear') then
        final_stat = math_clamp(final_stat, 0, 100)

    -- 특정 타입의 스텟들은 제외한 나머지는 최소값을 0으로 처리
    elseif (not M_SPECIAL_STATUS_TYPE_ONLY_ADD[stat_type]) then
        final_stat = math_max(final_stat, 0)
    end

    if (is_new_power) then final_stat = math.max(final_stat, 0) end

    return final_stat
end

-------------------------------------
-- function getFinalStatDisplay
-------------------------------------
function StatusCalculator:getFinalStatDisplay(stat_type, use_percent)
    local stat_value = self:getFinalStat(stat_type)
    local stat_str = comma_value(math_floor(stat_value))
    if (use_percent) then
        return string.format('%s%%', stat_str)
    else
        return stat_str
    end
end

-------------------------------------
-- function makePrettyPercentage
-- @brief 능력치 퍼센트를 예쁘게 계산한 프로그레스 액션 생성
-------------------------------------
function StatusCalculator:makePrettyPercentage(key)
	local src = self:getFinalStat(key)
	local half = g_constant:get('UI', 'HALF_STAT', key)
	local max = g_constant:get('UI', 'MAX_STAT', key)
	
	local percent
	if (src <= half) then
		percent = 0.5 * (src / half)

	else
		percent = 0.5 + (0.5 * (((src - half) / (max - half))))
		
	end

    --[[
	if (IS_TEST_MODE()) then
		cclog('================================')
		cclog(' key : ' .. key)
		cclog(' src : ' .. src)
		cclog(' half : ' .. half)
		cclog(' max : ' .. max)
		cclog(string.format(' percnet : %d%%', percent * 100))
	end
    ]]--

	return percent
end

-------------------------------------
-- function getAdjustRate
-------------------------------------
function StatusCalculator:getAdjustRate(stat_type)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    local adj_rate = indivisual_status.m_buffMulti
    return adj_rate
end

-------------------------------------
-- function getAttackTick
-------------------------------------
function StatusCalculator:getAttackTick()
    return CalcAttackTick(self:getFinalStat('aspd'))
end

-------------------------------------
-- function getHiddenInfo
-------------------------------------
function StatusCalculator:getHiddenInfo(key)
    return self.m_tHiddenInfo[key]
end

-------------------------------------
-- function applyFormationBonus
-- @brief 진형 버프 적용 (다른 status effect처럼 패시브 형태로 동작함)
-------------------------------------
function StatusCalculator:applyFormationBonus(formation, formation_lv, slot_idx)
    local l_buff = TableFormation:getBuffList(formation, formation_lv, slot_idx)

    for i,v in ipairs(l_buff) do
        local action = v['action']
        local status = v['status']
        local value = v['value']

        if (action == 'multi') then
            self:addFormationMulti(status, value)
        elseif (action == 'add') then
            self:addFormationAdd(status, value)
        end
        
    end
end

-------------------------------------
-- function applyArenaFormationBonus
-- @brief 아레나 진형 버프 적용 (다른 status effect처럼 패시브 형태로 동작함)
-------------------------------------
function StatusCalculator:applyArenaFormationBonus(formation, formation_lv, slot_idx)
    local l_buff = TableFormationArena:getBuffList(formation, formation_lv, slot_idx)

    for i,v in ipairs(l_buff) do
        local action = v['action']
        local status = v['status']
        local value = v['value']

        if (action == 'multi') then
            self:addFormationMulti(status, value)
        elseif (action == 'add') then
            self:addFormationAdd(status, value)
        end
        
    end
end

-------------------------------------
-- function applyFriendBuff
-- @brief 친구 버프 적용
-------------------------------------
function StatusCalculator:applyFriendBuff(t_friend_buff)
    if (not t_friend_buff) then
        return
    end

    -- 절대값으로 상승하는 보너스
    local t_add_bonus = t_friend_buff['add_status']
    if (t_add_bonus) then
        for key, value in pairs(t_add_bonus) do
            self:addBuffAdd(key, value)
        end
    end

    -- 비율로 상승하는 보너스
    local t_multiply_bonus = t_friend_buff['multiply_status']
    if (t_multiply_bonus) then
        for key, value in pairs(t_multiply_bonus) do
            self:addBuffMulti(key, value)
        end
    end
end

-------------------------------------
-- function applyStageBonus
-- @brief 스테이지 보너스 적용
-------------------------------------
function StatusCalculator:applyStageBonus(stage_id, is_enemy)
    local t_info

    if (stage_id == COLOSSEUM_STAGE_ID) then
    --elseif (stage_id == ARENA_STAGE_ID) then
    else
        local t_info = TableStageData():getStageBuff(stage_id, is_enemy)
        if (not t_info) then return end
    
        local t_char = self.m_charTable[self.m_chapterID]

        for i, v in ipairs(t_info) do
            local condition_type = v['condition_type']
            local condition_value = v['condition_value']

            if (condition_type == 'did' or condition_type == 'mid') then
                condition_value = tonumber(condition_value)
            end

            if (v['condition_type'] == 'all' or condition_value == t_char[condition_type]) then
                local buff_type = v['buff_type']
                local buff_value = v['buff_value']

                local t_option = TableOption():get(buff_type)
                if (t_option) then
                    local status_type = t_option['status']
                    if (status_type) then
                        if (t_option['action'] == 'multi') then
                            self:addStageMulti(status_type, buff_value)
                        elseif (t_option['action'] == 'add') then
                            self:addStageAdd(status_type, buff_value)
                        end

                        --cclog('applyStageBonus ' .. Str(t_option['t_desc'], math_abs(buff_value)))
                    end
                end
            end
        end
    end
end

-------------------------------------
-- function applyAdditionalOptions
-- @brief 스테이지 보너스 적용
-------------------------------------
function StatusCalculator:applyAdditionalOptions(buff_str)
    local t_info
    local buff_list = TableStageData:parseStageBuffStr(buff_str)
    if (not buff_list) then return end
    
    local t_char = self.m_charTable[self.m_chapterID]

    for i, v in ipairs(buff_list) do
        local condition_type = v['condition_type']
        local condition_value = v['condition_value']

        if (condition_type == 'did' or condition_type == 'mid') then
            condition_value = tonumber(condition_value)
        end

        if (v['condition_type'] == 'all' or condition_value == t_char[condition_type]) then
            local buff_type = v['buff_type']
            local buff_value = v['buff_value']

            local t_option = TableOption():get(buff_type)
            if (t_option) then
                local status_type = t_option['status']
                if (status_type) then
                    if (t_option['action'] == 'multi') then
                        self:addStageMulti(status_type, buff_value)
                    elseif (t_option['action'] == 'add') then
                        self:addStageAdd(status_type, buff_value)
                    end

                    --if (IS_DEV_SERVER()) then cclog('applyAdditionalOptions ' .. Str(t_option['t_desc'], math_abs(buff_value))) end
                end
            end
        end
    end
end

-------------------------------------
-- function applyLairStats
-- @brief 축복 보너스 적용
-------------------------------------
function StatusCalculator:applyLairStats(_l_lair_status_ids)
   local l_lair_status_ids = {}

    if _l_lair_status_ids ~= nil then
        l_lair_status_ids = _l_lair_status_ids
    end

    local l_buffs = TableLairBuffStatus:getInstance():getLairStatsByIdList(l_lair_status_ids)
    for _, v in ipairs(l_buffs) do
        local buff_type = v['buff_type']
        local buff_value = v['buff_value']
        local t_option = TableOption():get(buff_type)
    
        if (t_option) then
            local status_type = t_option['status']
            if (status_type) then
                if (t_option['action'] == 'multi') then
                    self:addStageMulti(status_type, buff_value)
                elseif (t_option['action'] == 'add') then
                    self:addStageAdd(status_type, buff_value)
                end
            end
        end
    end
end

-------------------------------------
-- function getCombatPower
-- @brief 드래곤의 최종 전투력을 얻어옴
--        UI에서 사용되는 함수이므로 패시브 발동은 제외
-------------------------------------
function StatusCalculator:getCombatPower()
    local total_combat_power = 0
    local table_status = TableStatus()

    if (USE_NEW_COMBAT_POWER_CALC == true) then return self:getNewCombatPower() end

    -- 능력치별 전투력 계수를 곱해서 전투력 합산
    for _,stat_name in pairs(L_BASIC_STATUS_TYPE) do
        -- 모든 연산이 끝난 후의 능력치 얻어옴
        local final_stat = self:getFinalStat(stat_name)

        -- 능력치별 계수(coef)를 얻어옴
        local coef = table_status:getValue(stat_name, 'combat_power_coef') or 0

        -- 능력치별 전투력 계산
        local combat_power = (final_stat * coef)
        total_combat_power = (total_combat_power + combat_power)
    end

    return math_floor(total_combat_power)
end


-------------------------------------
-- function getCombatPower
-- @brief 드래곤의 최종 전투력을 얻어옴
-- UI에서 사용되는 함수이므로 패시브 발동은 제외
-------------------------------------
function StatusCalculator:getNewCombatPower()
    local total_combat_power = 0
    local table_status = TableStatus()
    local table_stat = {}

    -- 능력치별 전투력 계수를 곱해서 전투력 합산
    for _,stat_name in pairs(L_BASIC_STATUS_TYPE) do
        -- 모든 연산이 끝난 후의 능력치 얻어옴
        local final_stat = self:getFinalStat(stat_name, true)
        table_stat[stat_name] = final_stat
    end

    local rune_type
    local t_char = self.m_charTable[self.m_chapterID]
    if (t_char) then rune_type = t_char['rune'] end

    local attack_point

    if (rune_type == 'pink') then
        -- 치명 피해 드래곤 공격 점수 = 공격력*(1+(치확+40)*(치피-40))*(4+공격속도)/5*(4+적중)/5
        attack_point = table_stat['atk'] * (1 + (table_stat['cri_chance'] + 40) * 0.01 * (table_stat['cri_dmg'] - 40) * 0.01) * (4 + table_stat['aspd'] * 0.01) / 5 * (4 + table_stat['hit_rate'] * 0.01) / 5

    elseif (rune_type == 'blue') then
        -- 공속 드래곤 공격 점수 = 공격력*(1+치확*치피)*(0.5+공격속도)/1.5*(4+적중)/5
        attack_point = table_stat['atk'] * (1 + table_stat['cri_chance'] * 0.01 * table_stat['cri_dmg'] * 0.01) * (0.5 + table_stat['aspd'] * 0.01) / 1.5 * (4 + table_stat['hit_rate'] * 0.01) / 5

    else
        -- 태초의 고대 신룡이라면 공격 포인트에 1.5배를 더해준다(하드코딩)
        if (self.m_chapterID == 121954) then
            attack_point = (math_pow(table_stat['atk'], 1.06)) * (1 + table_stat['cri_chance'] * 0.01 * table_stat['cri_dmg'] * 0.01) * (4 + table_stat['aspd'] * 0.01) / 5 * (4 + table_stat['hit_rate'] * 0.01) / 5
        else
            -- 일반 공격 점수 = 공격력*(1+치확*치피)*(4+공격속도)/5*(4+적중)/5
            attack_point = table_stat['atk'] * (1 + table_stat['cri_chance'] * 0.01 * table_stat['cri_dmg'] * 0.01) * (4 + table_stat['aspd'] * 0.01) / 5 * (4 + table_stat['hit_rate'] * 0.01) / 5
        end
    end

    -- 피해 감소 비율 = 1/(1-방어력/(1200+방어력))
    local dmg_avoid_rate = 1 / (1 - table_stat['def'] / (1200 + table_stat['def']))

    -- 방어 점수 = (생명력 + 125000) * 피해감소비율계수 * (3 + 회피)/3 * (3 + 치명회피) / 3  / 180
    local defence_point = (table_stat['hp'] + 125000) * dmg_avoid_rate * (3 + table_stat['avoid'] * 0.01) / 3 * (3 + table_stat['cri_avoid'] * 0.01) / 3 / 180

    total_combat_power = attack_point + defence_point

    local coef_gap = 0.02
    local mastery_coef = 1
    if (self.m_masteryLv == 10) then
        mastery_coef = 1.24
    else
        mastery_coef = (1 + coef_gap * self.m_masteryLv)
    end

    total_combat_power = total_combat_power * mastery_coef

    -- 신화드래곤은 최종 전투력 * 0.9
    if (self.m_charType == 'dragon') then
        local t_dragon_data = TableDragon():get(self.m_chapterID)
        if (t_dragon_data and t_dragon_data['rarity'] == 'myth') then
            total_combat_power = total_combat_power * 0.9
        end
    end
    
    --[[
    if IS_DEV_SERVER() then
        cclog(
        self.m_charTable[self.m_chapterID]['t_name'] .. 
        ' :: 공/방 점수 :: ' .. tostring(attack_point) .. ' / ' .. tostring(defence_point) .. 
        ' ... 능력치 전투력 :: ' .. tostring(total_combat_power) .. 
        ' 특성레벨 :: ' .. tostring(self.m_masteryLv) .. 
        ' 특성배율 :: ( ' .. tostring(mastery_coef) .. ' )')
    end]]

    return math_floor(total_combat_power)
end

-------------------------------------
-- function addPassiveAdd
-- @brief
-------------------------------------
function StatusCalculator:addPassiveAdd(stat_type, value)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    -- 특정 타입의 스텟들은 무조건 곱연산
    if (M_SPECIAL_STATUS_TYPE_ONLY_MULTI[stat_type]) then
        indivisual_status:addPassiveMulti(value)
    else
        indivisual_status:addPassiveAdd(value)
    end
end

-------------------------------------
-- function addPassiveMulti
-- @brief
-------------------------------------
function StatusCalculator:addPassiveMulti(stat_type, value)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    -- 특정 타입의 스텟들은 무조건 합연산
    if (M_SPECIAL_STATUS_TYPE_ONLY_ADD[stat_type]) then
        indivisual_status:addPassiveAdd(value)
    else
        indivisual_status:addPassiveMulti(value)
    end
end

-------------------------------------
-- function addMasteryAdd
-- @brief
-------------------------------------
function StatusCalculator:addMasteryAdd(stat_type, value)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    -- 특정 타입의 스텟들은 무조건 곱연산
    if (M_SPECIAL_STATUS_TYPE_ONLY_MULTI[stat_type]) then
        indivisual_status:addMasteryMulti(value)
    else
        indivisual_status:addMasteryAdd(value)
    end
end

-------------------------------------
-- function addMasteryMulti
-- @brief
-------------------------------------
function StatusCalculator:addMasteryMulti(stat_type, value)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    -- 특정 타입의 스텟들은 무조건 합연산
    if (M_SPECIAL_STATUS_TYPE_ONLY_ADD[stat_type]) then
        indivisual_status:addMasteryAdd(value)
    else
        indivisual_status:addMasteryMulti(value)
    end
end

-------------------------------------
-- function addFormationAdd
-- @brief
-------------------------------------
function StatusCalculator:addFormationAdd(stat_type, value)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    -- 특정 타입의 스텟들은 무조건 곱연산
    if (M_SPECIAL_STATUS_TYPE_ONLY_MULTI[stat_type]) then
        indivisual_status:addFormationMulti(value)
    else
        indivisual_status:addFormationAdd(value)
    end
end

-------------------------------------
-- function addFormationMulti
-- @brief
-------------------------------------
function StatusCalculator:addFormationMulti(stat_type, value)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    -- 특정 타입의 스텟들은 무조건 합연산
    if (M_SPECIAL_STATUS_TYPE_ONLY_ADD[stat_type]) then
        indivisual_status:addFormationAdd(value)
    else
        indivisual_status:addFormationMulti(value)
    end
end

-------------------------------------
-- function addStageAdd
-- @brief
-------------------------------------
function StatusCalculator:addStageAdd(stat_type, value)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    -- 특정 타입의 스텟들은 무조건 곱연산
    if (M_SPECIAL_STATUS_TYPE_ONLY_MULTI[stat_type]) then
        indivisual_status:addStageMulti(value)
    else
        indivisual_status:addStageAdd(value)
    end
end

-------------------------------------
-- function addStageMulti
-- @brief
-------------------------------------
function StatusCalculator:addStageMulti(stat_type, value)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    -- 특정 타입의 스텟들은 무조건 합연산
    if (M_SPECIAL_STATUS_TYPE_ONLY_ADD[stat_type]) then
        indivisual_status:addStageAdd(value)
    else
        indivisual_status:addStageMulti(value)
    end
end

-------------------------------------
-- function addBuffAdd
-- @brief
-------------------------------------
function StatusCalculator:addBuffAdd(stat_type, value)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    -- 특정 타입의 스텟들은 무조건 곱연산
    if (M_SPECIAL_STATUS_TYPE_ONLY_MULTI[stat_type]) then
        indivisual_status:addBuffMulti(value)
    else
        indivisual_status:addBuffAdd(value)
    end
end

-------------------------------------
-- function addBuffMulti
-- @brief
-------------------------------------
function StatusCalculator:addBuffMulti(stat_type, value)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    -- 특정 타입의 스텟들은 무조건 합연산
    if (M_SPECIAL_STATUS_TYPE_ONLY_ADD[stat_type]) then
        indivisual_status:addBuffAdd(value)
    else
        indivisual_status:addBuffMulti(value)
    end
end

-------------------------------------
-- function addOption
-- @brief
-------------------------------------
function StatusCalculator:addOption(action, status, value)
    if (action == 'multi') then
        self:addBuffMulti(status, value)

    elseif (action == 'add') then
        self:addBuffAdd(status, value)

    else
        error('action : ' .. action)
    end
end

-------------------------------------
-- function printAllStat
-- @DEBUG
-------------------------------------
function StatusCalculator:printAllStat()
    local str = self:getAllStatString()
    cclog(str)
end

-------------------------------------
-- function getAllStatString
-- @DEBUG
-------------------------------------
function StatusCalculator:getAllStatString()
    local str = ''

    local printLine = function(_str)
        str = str .. _str .. '\n'
    end

    for _, stat_type in ipairs(L_STATUS_TYPE) do
        local indivisual_status = self.m_lStatusList[stat_type]
        if (indivisual_status) then
            local final_stat = self:getFinalStat(stat_type)
            local buff_multi = indivisual_status.m_buffMulti
            local buff_add = indivisual_status.m_buffAdd

		    printLine('- ' .. stat_type .. ' : ' .. final_stat .. ' (' .. buff_multi .. '%, ' .. buff_add .. ')')
        end
    end

    return str
end

-------------------------------------
-- function appendHpRatio
-- @brief Hp ratio를 적용함.
-------------------------------------
function StatusCalculator:appendHpRatio(hp_ratio)
    if (not self.m_tHiddenInfo['hp_multi']) then
        self.m_tHiddenInfo['hp_multi'] = 1
    end

    self.m_tHiddenInfo['hp_multi'] = self.m_tHiddenInfo['hp_multi'] * hp_ratio
end

-------------------------------------
-- function MakeDragonStatusCalculator
-- @brief
-------------------------------------
function MakeDragonStatusCalculator(dragon_id, lv, grade, evolution, eclv)
    lv = (lv or 1)
    grade = (grade or 1)
    evolution = (evolution or 1)

    local status_calc = StatusCalculator('dragon', dragon_id, lv, grade, evolution, eclv)
    return status_calc
end

-------------------------------------
-- function MakeOwnDragonStatusCalculator
-- @brief
-------------------------------------
function MakeOwnDragonStatusCalculator(doid, t_adjust_dragon_data, game_mode)
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)

    if (not t_dragon_data) then
        return nil
    end

    -- 특정 값으로 변경한 상태로 계산하고 싶은 경우 (t_dragon_data는 clone된 데이터로 실제 드래곤 정보에 영향을 주지 않는다.)
    if t_adjust_dragon_data then
        for key,value in pairs(t_adjust_dragon_data) do
            if t_dragon_data[key] then
                t_dragon_data[key] = value
            end
        end
    end

    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data, game_mode)

    return status_calc
end

-------------------------------------
-- function MakeDragonStatusCalculator_fromDragonDataTable
-- @brief
-------------------------------------
function MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data, game_mode)
    local dragon_id = t_dragon_data['did']
    local lv = t_dragon_data['lv']
    local grade = t_dragon_data['grade']
    local evolution = t_dragon_data['evolution']
    local eclv = t_dragon_data['eclv']
    local doid = t_dragon_data['id']
    local status_calc = MakeDragonStatusCalculator(dragon_id, lv, grade, evolution, eclv)
	
	-- 드래곤 강화 수치 와 친밀도(friendship)
	do
        local friendship_obj = t_dragon_data:getFriendshipObject()
		local t_r_rate = t_dragon_data:getReinforceMulti()

        local indivisual_status = status_calc.m_lStatusList['atk']
        indivisual_status:setFriendshipStat(friendship_obj['fatk'])
		indivisual_status:setReinforceMulti(t_r_rate['atk'])

        local indivisual_status = status_calc.m_lStatusList['def']
        indivisual_status:setFriendshipStat(friendship_obj['fdef'])
		indivisual_status:setReinforceMulti(t_r_rate['def'])

        local indivisual_status = status_calc.m_lStatusList['hp']
        indivisual_status:setFriendshipStat(friendship_obj['fhp'])
		indivisual_status:setReinforceMulti(t_r_rate['hp'])
    end

    -- 룬(rune) (개별 룬, 세트 포함)
    do
        local l_add_status, l_multi_status = t_dragon_data:getRuneStatus()

        -- 차원문 모드일 때
        -- 현재 하층이면
        --[[
        if (is_dm_gate_mode) then
            local chapter_id = g_dmgateData:getChapterID(tonumber(g_gameScene.m_stageID))
            -- 리스트를 비워서 룬 효과를 무시한다.
            if (chapter_id <= 1) then
                l_add_status = {}
                l_multi_status = {}
            end
        end]]

        for stat_type,value in pairs(l_add_status) do
            local indivisual_status = status_calc.m_lStatusList[stat_type]
            if (indivisual_status) then
                if (M_SPECIAL_STATUS_TYPE_ONLY_MULTI[stat_type]) then
                    indivisual_status:setRuneMulti(value)
                else
                    indivisual_status:setRuneAdd(value)
                end
            end
        end

        for stat_type,value in pairs(l_multi_status) do
            local indivisual_status = status_calc.m_lStatusList[stat_type]

            if (M_SPECIAL_STATUS_TYPE_ONLY_ADD[stat_type]) then
                indivisual_status:setRuneAdd(value)
            else
                indivisual_status:setRuneMulti(value)
            end
        end
    end

    -- 특성(mastery)
    do
        local l_add_status, l_multi_status = t_dragon_data:getMasterySkillStatus(game_mode)
        
        status_calc.m_masteryLv = t_dragon_data:getMasteryLevel()

        for stat_type,value in pairs(l_add_status) do
            status_calc:addMasteryAdd(stat_type, value)
        end

        for stat_type,value in pairs(l_multi_status) do
            status_calc:addMasteryMulti(stat_type, value)
        end
    end

    -- 축복(mastery)
    do
        -- 소유중인 드래곤인지 판별 후 능력치 적용
        -- 이렇게 처리하는게 맞는지 모르겠다.
        if doid ~= nil and g_dragonsData:getDragonDataFromUid(doid) ~= nil then
            local lair_stats = g_lairData:getLairStats()
            status_calc:applyLairStats(lair_stats)
        end
    end

    return status_calc
end

-------------------------------------
-- function MakeMonsterStatusCalculator_fromMonsterDataTable
-- @brief 몬스터 능력치 계산, 레벨은 해당 스테이지 레벨로 계산함
-------------------------------------
function MakeMonsterStatusCalculator_fromMonsterDataTable(t_monster_data, is_dragon)
    local monster_id = (is_dragon) and t_monster_data['did'] or t_monster_data['mid']
    local lv = t_monster_data['lv'] or 1

    -- 몬스터 드래곤인 경우 evolution 3으로 고정
    local status_calc = (is_dragon) and MakeDragonStatusCalculator(monster_id, lv, 1, 3, 1)
                                    or StatusCalculator('monster', monster_id, lv)
    return status_calc
end