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
        t_status['attribute_bonus'] = 0
        t_status['friendship_bonus'] = 0

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
-- function applyAttributeBonusStats
-- @brief 속성 보너스는 (기본, 레벨, 등급, 진화 능력치 합산의 %능력을 bonus로 줌)
-------------------------------------
function StatusCalculator:applyAttributeBonusStats(stat_type, multiply)
    local t_status = self.m_lStatusList[stat_type]

    if (not t_status) then
        error('stat_type : ' .. stat_type)
    end

    -- 속성 보너스는 (기본, 레벨, 등급, 진화 능력치 합산의 %능력을 bonus로 줌)
    local stat = (t_status['base'] + t_status['lv'] + t_status['grade'] + t_status['evolution'])
    local attribute_bonus = (stat * multiply)

    t_status['attribute_bonus'] = (t_status['attribute_bonus'] + attribute_bonus)
    t_status['final'] = (t_status['final'] + attribute_bonus)
end

-------------------------------------
-- function setAttributeBonusStats
-- @brief 속성능력 (추가 능력) 적용
-------------------------------------
function StatusCalculator:setAttributeBonusStats(t_attr_bonus)
    for stat_type,value in pairs(t_attr_bonus) do

        local skip = isExistValue(stat_type, 'damage')

        if (not skip) then
            local value_multiply = (value / 100)
            self:applyAttributeBonusStats(stat_type, value_multiply)
        end
    end

    -- # 세부 능력치 적용
    self.m_attackTick = self:getAttackTick()
end

-------------------------------------
-- function applyFriendshipDetailedStats
-------------------------------------
function StatusCalculator:applyFriendshipDetailedStats(stat_type, add_stat)
    local t_status = self.m_lStatusList[stat_type]

    if (not t_status) then
        error('stat_type : ' .. stat_type)
    end

    t_status['friendship_bonus'] = (t_status['friendship_bonus'] + add_stat)
    t_status['final'] = (t_status['final'] + add_stat)   
end

-------------------------------------
-- function setFriendshipDetailedStats
-------------------------------------
function StatusCalculator:setFriendshipDetailedStats(t_detailed_stats)
    for stat_type,add_stat in pairs(t_detailed_stats) do
        self:applyFriendshipDetailedStats(stat_type, add_stat)
    end

    -- # 세부 능력치 적용
    self.m_attackTick = self:getAttackTick()
end

-------------------------------------
-- function getAttackTick
-------------------------------------
function StatusCalculator:getAttackTick()
    return self:calcAttackTick(self:getFinalStat('aspd'))
end


-------------------------------------
-- function getDPBaseStatus
-- @brief
-- TODO 삭제
-------------------------------------
function StatusCalculator:getDPBaseStatus(status_type)
    return 0
end

-------------------------------------
-- function MakeDragonStatusCalculator
-- @brief
-------------------------------------
function MakeDragonStatusCalculator(dragon_id, lv, grade, evolution)
    local status_calc = StatusCalculator('dragon', dragon_id, lv, grade, evolution)
    return status_calc
end

-------------------------------------
-- function MakeOwnDragonStatusCalculator
-- @brief
-------------------------------------
function MakeOwnDragonStatusCalculator(dragon_id, t_data)
    -- 유저가 보유하고있는 드래곤의 정보
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)

    local lv = t_dragon_data['lv']
    local grade = t_dragon_data['grade']
    local evolution = t_dragon_data['evolution']

    -- 필요한 경우 데이터 조작
    if t_data then
        if t_data['lv'] then
            lv = lv + t_data['lv']
        end

        if t_data['grade'] then
            grade = grade + t_data['grade']
        end

        if t_data['evolution'] then
            evolution = evolution + t_data['evolution']
        end
    end

    local status_calc = MakeDragonStatusCalculator(dragon_id, lv, grade, evolution)

    -- 속성 보너스 (곱연산)
    do
        local attr = g_dragonListData:getTableData(dragon_id, 'attr')
        local attr_num = attributeStrToNum(attr)
        local table_attribute = TABLE:get('attribute')
        local t_attr = table_attribute[attr_num]

        local t_attr_bunus = {}
        for i=1, 3 do
            local option_key = string.format('ability_option_%.2d', i)
            local value_key = string.format('ability_value_%.2d', i)

            local option_type = t_attr[option_key]
            local option_value = t_attr[value_key]

            attributeOption(t_attr_bunus, option_type, option_value)
        end
        status_calc:setAttributeBonusStats(t_attr_bunus)
    end
    
    do -- 친밀도 (합연산)
        local t_friendship_data, t_friendship = g_friendshipData:getFriendship(dragon_id)
        local t_detailed_stats = t_friendship_data['stats']

        -- 친밀도 능력치 추가
        --status_calc:setFriendshipDetailedStats(t_detailed_stats)
    end

    return status_calc
end