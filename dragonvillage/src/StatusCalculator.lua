L_STATUS_TYPE = {
        'atk',          -- 공격력
        'def',          -- 방어력
        'hp',           -- 생명력

        'aspd',         -- 공격속도
        'cri_chance',   -- 치명확률
        'cri_dmg',      -- 치명피해

        'cri_avoid',    -- 치명방어
        'hit_rate',     -- 적중률
        'avoid',        -- 회피

		--------------------------------------------

		'dmg_adj_rate',	-- 데미지 조정 계수
		'attr_adj_rate', -- 속성 조정 계수
    }

-------------------------------------
-- class StatusCalculator
-------------------------------------
StatusCalculator = class({
        m_lStatusList = 'list',

        m_lPassive = 'list',
        m_lPassiveAbs = 'list',

        -- 세부 능력치 적용
        m_attackTick = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function StatusCalculator:init(char_type, cid, lv, grade, evolution)

    self.m_lStatusList = self:calcStatusList(char_type, cid, lv, grade, evolution)

    self.m_lPassive = {}
    self.m_lPassiveAbs = {}
    for _,type in ipairs(L_STATUS_TYPE) do
        self.m_lPassive[type] = 0
        self.m_lPassiveAbs[type] = 0
    end

    -- # 세부 능력치 적용
    self.m_attackTick = self:getAttackTick()
end

-------------------------------------
-- function calcStatusList
-------------------------------------
function StatusCalculator:calcStatusList(char_type, cid, lv, grade, evolution)
    local l_status = {}

    for _,status_name in pairs(L_STATUS_TYPE) do
        local final_stat, base_stat, lv_stat, grade_stat, evolution_stat = self:calcStat(char_type, cid, status_name, lv, grade, evolution)

        local t_status = {}
        t_status['final'] = final_stat
        t_status['base'] = base_stat
        t_status['lv'] = lv_stat
        t_status['grade'] = grade_stat
        t_status['evolution'] = evolution_stat
        t_status['friendship_bonus'] = 0
        t_status['train_bonus'] = 0

        l_status[status_name] = t_status
    end

    return l_status
end

-------------------------------------
-- function getFinalStat
-------------------------------------
function StatusCalculator:getFinalStat(stat_type)
    local t_status = self.m_lStatusList[stat_type]
    if (not t_status) then
        error('stat_type : ' .. stat_type)
    end

    local stat_value = t_status['final']
    if (not stat_value) then
        error('final')
    end

    do -- 패시브 능력치 적용
        -- %패시브 적용
        local multiply = 0
        multiply = (multiply + (self.m_lPassive[stat_type] / 100))
		
        if (multiply ~= 0) then
            -- 패시브 보너스는 (기본, 레벨, 등급, 진화 능력치 합산의 %능력을 bonus로 줌)
            local stat = (t_status['base'] + t_status['lv'] + t_status['grade'] + t_status['evolution'])
            local passive_bonus = (stat * multiply)
            stat_value = (stat_value + passive_bonus)
        end

        -- 버프 패시브 절대값 적용
        if (self.m_lPassiveAbs[stat_type] ~= 0) then
            stat_value = stat_value + self.m_lPassiveAbs[stat_type]
        end
    end

    return stat_value
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
    local add_stat = t_status['friendship_bonus'] + t_status['train_bonus']

    add_stat = math_floor(add_stat)
    if (add_stat == 0) then
        return ''
    end

    return '(+' .. math_floor(add_stat) .. ')'
end


-------------------------------------
-- function getAdjustRate
-------------------------------------
function StatusCalculator:getAdjustRate(type)
    return self.m_lPassive[type] or 0
end

-------------------------------------
-- function getAttackTick
-------------------------------------
function StatusCalculator:getAttackTick()
    return self:calcAttackTick(self:getFinalStat('aspd'))
end


-------------------------------------
-- function applyFriendshipBonus
-------------------------------------
function StatusCalculator:applyFriendshipBonus(l_bonus)
    if (not l_bonus) then
        return
    end

    for key, value in pairs(l_bonus) do
        local t_status = self.m_lStatusList[key]
        t_status['friendship_bonus'] = value
        t_status['final'] = t_status['final'] + value
    end
end

-------------------------------------
-- function applyTrainBonus
-------------------------------------
function StatusCalculator:applyTrainBonus(l_bonus)
    if (not l_bonus) then
        return
    end

    for key, value in pairs(l_bonus) do
        local t_status = self.m_lStatusList[key]
        t_status['train_bonus'] = value
        t_status['final'] = t_status['final'] + value
    end
end

-------------------------------------
-- function applyFormationBonus
-- @brief 진형 버프 적용 (다른 status effect처럼 패시브 형태로 동작함)
-------------------------------------
function StatusCalculator:applyFormationBonus(formation, slot_idx)
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
            -- 모든 연산이 끝난 후의 능력치 얻어옴 (패시브로 실시간 적용되는 부분은 제외)
            local final_stat = t_status['final']

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
-- function MakeDragonStatusCalculator
-- @brief
-------------------------------------
function MakeDragonStatusCalculator(dragon_id, lv, grade, evolution, l_friendship_bonus, l_train_bonus)
    lv = (lv or 1)
    grade = (grade or 1)
    evolution = (evolution or 1)

    local status_calc = StatusCalculator('dragon', dragon_id, lv, grade, evolution)
    status_calc:applyFriendshipBonus(l_friendship_bonus)
    status_calc:applyTrainBonus(l_train_bonus)
    return status_calc
end

-------------------------------------
-- function MakeOwnDragonStatusCalculator
-- @brief
-------------------------------------
function MakeOwnDragonStatusCalculator(dragon_object_id)
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(dragon_object_id)

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

    -- 친밀도 보너스
    local l_friendship_bonus = {}
    l_friendship_bonus['atk'] = t_dragon_data['atk'] or 0
    l_friendship_bonus['def'] = t_dragon_data['def'] or 0
    l_friendship_bonus['hp'] = t_dragon_data['hp'] or 0

    -- 수련 보너스
    local table_dragon_train_status = TableDragonTrainStatus()
    local l_train_bonus = table_dragon_train_status:getTrainStatus(t_dragon_data['did'], t_dragon_data['train_slot'] or {})

    local status_calc = MakeDragonStatusCalculator(dragon_id, lv, grade, evolution, l_friendship_bonus, l_train_bonus)

    return status_calc
end