-------------------------------------
-- function calcStat
-- @brief
-------------------------------------
function StatusCalculator:calcStat(char_type, cid, status_name, lv, grade, evolution)
	
	if (status_name == 'dmg_adj_rate') then return 0, 0, 0, 0, 0 end 

    -- 케릭터 타입별 테이블 얻어옴
    local table_char = TABLE:get(char_type)
    local t_char = table_char[cid]

    -- 능력치 테이블
    local table_status = TABLE:get('status')
    local t_status = table_status[status_name]

    -- 1. 기본 능력치
    local base_stat = t_status['base_stat']

    -- 2. 레벨 추가 능력치
    local max_key = status_name .. '_max'
    local max_lv_value = t_char[max_key]
    local lv_stat = nil
	-- 2-1. 특정 수치의 레벨에 상관없이 고정된 값을 추가한다.
	if (status_name == 'aspd') then 
		lv_stat = t_char[status_name .. '_abs']
	else
		lv_stat = (max_lv_value / 60) * lv
	end

    -- 3. 승급 능력치
    local grade_key = 'grade_' .. grade
    local grade_stat = t_status[grade_key]

    -- 4. 진화 능력치
    local evolution_key = ('evolution_' .. evolution)
    local evolution_stat = t_status[evolution_key]

    local final_stat = base_stat + lv_stat + grade_stat + evolution_stat

    return final_stat, base_stat, lv_stat, grade_stat, evolution_stat
end

-- # 세부 능력치의 실제 적용
-------------------------------------
-- function calcAttackTick
-------------------------------------
function StatusCalculator:calcAttackTick(attack_speed)
    local tick = 3.5 - (3 * ((attack_speed-100)/100))
    return tick
end