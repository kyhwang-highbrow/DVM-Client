-------------------------------------
-- function calcStat
-- @brief
-------------------------------------
function StatusCalculator:calcStat(char_type, cid, status_name, lv, grade, evolution)
	
	if isExistValue(status_name, 'dmg_adj_rate', 'attr_adj_rate') then return 0, 0, 0, 0, 0 end 

    -- 케릭터 타입별 테이블 얻어옴
    local table_char = self.m_charTable
    local t_char = table_char[cid]

    -- 능력치 테이블
    local table_status = TABLE:get('status')
    local t_status = table_status[status_name]

    -- 1. 기본 능력치
    local base_stat = t_status['base_stat']

    -- 2. 레벨 추가 능력치
    local lv_stat = nil
    local grade_stat = 0
    local evolution_stat = 0

	-- 2-1. 공방체 스탯만 레벨에 따라 증가시키고 나머지는 고정값이다. 
	if isExistValue(status_name, 'atk', 'def', 'hp') then 
        local max_lv_value = t_char[status_name .. '_max']
        local value_per_level = (max_lv_value / 70)
		lv_stat = value_per_level * lv

        -- 드래곤들만 적용
        if (char_type == 'dragon') then

            -- 진화 단계 보너스
            --evolution_stat = value_per_level * self.m_evolutionTable:getBonusStatusLv(evolution)

            -- 승급 단계 보너스
            --grade_stat = value_per_level * self.m_gradeTable:getBonusStatusLv(grade)
        end
	else
		lv_stat = t_char[status_name]
	end

    local final_stat = base_stat + lv_stat + grade_stat + evolution_stat

    return final_stat, base_stat, lv_stat, grade_stat, evolution_stat
end

-- # 세부 능력치의 실제 적용
-------------------------------------
-- function calcAttackTick
-------------------------------------
function StatusCalculator:calcAttackTick(attack_speed)
    local tick = 3 - (2 * ((attack_speed-100)/100))
    return tick
end