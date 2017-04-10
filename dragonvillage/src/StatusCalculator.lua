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

    for _,status_name in pairs(L_STATUS_TYPE) do
        local basic_stat, base_stat, lv_stat, grade_stat, evolution_stat, eclv_stat = self:calcStat(char_type, cid, status_name, lv, grade, evolution, eclv)

        local indivisual_status = StructIndividualStatus()
        indivisual_status:setBasicStat(base_stat, lv_stat, grade_stat, evolution_stat, eclv_stat)

        l_status[status_name] = indivisual_status--t_status
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
-------------------------------------
function StatusCalculator:getFinalAddStatDisplay(stat_type)
    local t_status = self.m_lStatusList[stat_type]

    add_stat = math_floor(add_stat)
    if (add_stat == 0) then
        return ''
    end

    return '(+' .. math_floor(add_stat) .. ')'
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
    -- 임시로 막아둠
    if true then
        return
    end

    if (self.m_charType ~= 'dragon') then
        return
    end

    local did = self.m_chapterID
    local dragon_type = TableDragon:getDragonType(did)
    local atk, def, hp = TableDragonResearch:getDragonResearchStatus(dragon_type, rlv)

    self.m_lPassiveAbs['atk'] = (self.m_lPassiveAbs['atk'] + atk)
    self.m_lPassiveAbs['def'] = (self.m_lPassiveAbs['def'] + def)
    self.m_lPassiveAbs['hp'] = (self.m_lPassiveAbs['hp'] + hp)
end

-------------------------------------
-- function applyFormationBonus
-- @brief 진형 버프 적용 (다른 status effect처럼 패시브 형태로 동작함)
-------------------------------------
function StatusCalculator:applyFormationBonus(formation, slot_idx)
    -- 임시로 막아둠
    if true then
        return
    end

    local l_buff = TableFormation:getBuffList(formation, slot_idx)

    for i,v in ipairs(l_buff) do
        local buff_type = v['buff_type']
        local buff_value = v['buff_value']

        if (buff_type == '') then
        
        -- 공격력 상승
        elseif (buff_type == 'atk_up') then
            self.m_lPassive['atk'] = (self.m_lPassive['atk'] + buff_value)

        -- 방어력 상승
        elseif (buff_type == 'def_up') then
            self.m_lPassive['def'] = (self.m_lPassive['def'] + buff_value)
        
        -- 공격력 하락
        elseif (buff_type == 'atk_down') then
            self.m_lPassive['atk'] = (self.m_lPassive['atk'] - buff_value)

        else
            error('buff_type : ' .. buff_type)
        end
    end
end

-------------------------------------
-- function applyFriendBuff
-- @brief 친구 버프 적용
-------------------------------------
function StatusCalculator:applyFriendBuff(t_friend_buff)
    -- 임시로 막아둠
    if true then
        return
    end

    if (not t_friend_buff) then
        return
    end

    -- 절대값으로 상승하는 보너스
    local t_add_bonus = t_friend_buff['add_status']
    if (t_add_bonus) then
        for key, value in pairs(t_add_bonus) do
            local t_status = self.m_lStatusList[key]
            t_status['basic_stat'] = t_status['basic_stat'] + value
        end
    end

    -- 비율로 상승하는 보너스
    local t_multiply_bonus = t_friend_buff['multiply_status']
    if (t_multiply_bonus) then
        for key, value in pairs(t_multiply_bonus) do
            self.m_lPassive[key] = (self.m_lPassive[key] + value)
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

    -- 능력치별 전투력 계수를 곱해서 전투력 합산
    for stat_name,t_status in pairs(self.m_lStatusList) do
        
        if (not isExistValue(stat_name, 'dmg_adj_rate', 'attr_adj_rate')) then
            -- 모든 연산이 끝난 후의 능력치 얻어옴
            local final_stat = self:getFinalStat(stat_name)

            -- 능력치별 계수(coef)를 얻어옴
            local coef = table_status:getValue(stat_name, 'combat_power_coef') or 0

            -- 능력치별 전투력 계산
            local combat_power = (final_stat * coef)
            total_combat_power = (total_combat_power + combat_power)
        end
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
-- function MakeDragonStatusCalculator
-- @brief
-------------------------------------
function MakeDragonStatusCalculator(dragon_id, lv, grade, evolution, eclv)
    lv = (lv or 1)
    grade = (grade or 1)
    evolution = (evolution or 1)

    local status_calc = StatusCalculator('dragon', dragon_id, lv, grade, evolution, eclv)
    status_calc:applyDragonResearchBuff(rlv or 0)
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

    return status_calc
end