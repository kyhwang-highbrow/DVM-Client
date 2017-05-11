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
    }

L_STATUS_TYPE = clone(L_BASIC_STATUS_TYPE)
table.addList(L_STATUS_TYPE, {
		'dmg_adj_rate',	-- 데미지 조정 계수
		'attr_adj_rate', -- 속성 조정 계수

        -- 룬 세트가 추가되면서 추가된 능력치
        'accuracy',     -- 효과 적중 +{1}%
        'resistance',   -- 효과 저항 +{1}%
        'drag_gauge',   -- 드래그 게이지 +{1} 충전 상태에서 시작
        'drag_cool',    -- 드래그 스킬 쿨타임 +{1} 감소
        'cool_actu',    -- 쿨타임 스킬 시간 +{1}%

        -- 스테이지 버프로 추가된 능력치
        'hp_drain',         -- 공격 명중시 피해량의 +{1}% 만큼 HP회복
        'drag_dmg',         -- 드래그 스킬 데미지 +{1}% 만큼 증가
        'heal_power',       -- 회복 스킬 효과 +{1}% 증가
        'debuff_time',      -- 해로운 효과 지속 시간 +{1}% 증가

		-- 기획 이슈로 제거
        --'pass_chance',  -- 패시브 발동 +{1}% 

    })

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
end

-------------------------------------
-- function calcStatusList
-------------------------------------
function StatusCalculator:calcStatusList(char_type, cid, lv, grade, evolution, eclv)
    local l_status = {}

    -- 기본 능력치들 계산
    for _,status_name in pairs(L_BASIC_STATUS_TYPE) do
        local basic_stat, base_stat, lv_stat, grade_stat, evolution_stat, eclv_stat = self:calcStat(char_type, cid, status_name, lv, grade, evolution, eclv)

        local indivisual_status = StructIndividualStatus(status_name)
        indivisual_status:setBasicStat(base_stat, lv_stat, grade_stat, evolution_stat, eclv_stat)

        l_status[status_name] = indivisual_status--t_status
    end

    -- 확장 능력치들 구조 생성
    for _,status_name in pairs(L_STATUS_TYPE) do
        if (not l_status[status_name]) then
            l_status[status_name] = StructIndividualStatus(status_name)
        end
    end

    return l_status
end

-------------------------------------
-- function getFinalStat
-------------------------------------
function StatusCalculator:getFinalStat(stat_type)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    local final_stat = indivisual_status:getFinalStat()
    return final_stat
end

-------------------------------------
-- function getFinalStatDisplay
-------------------------------------
function StatusCalculator:getFinalStatDisplay(stat_type)
    local stat_value = self:getFinalStat(stat_type)
    return comma_value(math_floor(stat_value))
end

-------------------------------------
-- function getFinalAddStatDisplay
-- @brief 친밀도, 수련으로 증가된 수치 표시 (추후 항목이 추가될 수 있음)
-- 삭제 예정
-------------------------------------
function StatusCalculator:getFinalAddStatDisplay(stat_type)
    return ''
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
    return self:calcAttackTick(self:getFinalStat('aspd'))
end

-------------------------------------
-- function applyDragonResearchBuff
-- @brief 연구 버프 적용
-------------------------------------
function StatusCalculator:applyDragonResearchBuff(rlv)
    if (self.m_charType ~= 'dragon') then
        return
    end

    local did = self.m_chapterID
    local dragon_type = TableDragon:getDragonType(did)
    local atk, def, hp = TableDragonResearch:getDragonResearchStatus(dragon_type, rlv)

    self.m_lStatusList['atk']:setResearchStat(atk)
    self.m_lStatusList['def']:setResearchStat(def)
    self.m_lStatusList['hp']:setResearchStat(hp)
end

-------------------------------------
-- function applyFormationBonus
-- @brief 진형 버프 적용 (다른 status effect처럼 패시브 형태로 동작함)
-------------------------------------
function StatusCalculator:applyFormationBonus(formation, slot_idx)
    local l_buff = TableFormation:getBuffList(formation, slot_idx)

    for i,v in ipairs(l_buff) do
        local action = v['action']
        local status = v['status']
        local value = v['value']

        self:addOption(action, status, value)
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
    if (stage_id == COLOSSEUM_STAGE_ID) then return end

    local t_info

    if (is_enemy) then
        t_info = TableDrop():getStageEnemyBuff(stage_id)
    else
        t_info = TableDrop():getStageHeroBuff(stage_id)
    end
    if (not t_info) then return end
    
    local t_char = self.m_charTable[self.m_chapterID]
    if (t_char[t_info['condition_type']] ~= t_info['condition_value']) then return end

    local buff_type = t_info['buff_type']
    local buff_value = t_info['buff_value']

    local t_option = TableOption():get(buff_type)
    if (not t_option) then return end

    local status_type = t_option['status']
    if (not status_type) then return end

    self:addOption(t_option['action'], status_type, buff_value)
    
    --cclog('applyStageBonus ' .. Str(t_option['t_desc'], math_abs(buff_value)))
end

-------------------------------------
-- function getCombatPower
-- @brief 드래곤의 최종 전투력을 얻어옴
--        UI에서 사용되는 함수이므로 패시브 발동은 제외
-------------------------------------
function StatusCalculator:getCombatPower()
    local total_combat_power = 0
    local table_status = TableStatus()

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
-- function addBuffAdd
-- @brief
-------------------------------------
function StatusCalculator:addBuffAdd(stat_type, value)
    local indivisual_status = self.m_lStatusList[stat_type]
    if (not indivisual_status) then
        error('stat_type : ' .. stat_type)
    end

    indivisual_status:addBuffAdd(value)
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

    indivisual_status:addBuffMulti(value)
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
	for stat_type, indivisual_status in pairs(self.m_lStatusList) do
		cclog('- ' .. stat_type .. ' : ' .. indivisual_status:getFinalStat())
	end
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
function MakeOwnDragonStatusCalculator(doid, t_adjust_dragon_data)
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

    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data)

    return status_calc
end

-------------------------------------
-- function MakeDragonStatusCalculator_fromDragonDataTable
-- @brief
-------------------------------------
function MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data)
    local dragon_id = t_dragon_data['did']
    local lv = t_dragon_data['lv']
    local grade = t_dragon_data['grade']
    local evolution = t_dragon_data['evolution']
    local eclv = t_dragon_data['eclv']

    local status_calc = MakeDragonStatusCalculator(dragon_id, lv, grade, evolution, eclv)

    -- 연구(research)
    local rlv = t_dragon_data['rlv']
    status_calc:applyDragonResearchBuff(rlv)

    -- 친밀도(friendship)
    do
        local friendship_obj = t_dragon_data:getFriendshipObject()

        local indivisual_status = status_calc.m_lStatusList['atk']
        indivisual_status:setFriendshipStat(friendship_obj['fatk'])

        local indivisual_status = status_calc.m_lStatusList['def']
        indivisual_status:setFriendshipStat(friendship_obj['fdef'])

        local indivisual_status = status_calc.m_lStatusList['hp']
        indivisual_status:setFriendshipStat(friendship_obj['fhp'])
    end

    -- 룬(rune) (개별 룬, 세트 포함)
    do
        local l_add_status, l_multi_status = t_dragon_data:getRuneStatus()
        for stat_type,value in pairs(l_add_status) do
            local indivisual_status = status_calc.m_lStatusList[stat_type]
            indivisual_status:setRuneAdd(value)
        end

        for stat_type,value in pairs(l_multi_status) do
            local indivisual_status = status_calc.m_lStatusList[stat_type]
            indivisual_status:setRuneMulti(value)
        end
    end

    return status_calc
end