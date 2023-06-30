-------------------------------------
-- function calcStat
-- @brief
-------------------------------------
function StatusCalculator:calcStat(char_type, cid, status_name, lv, grade, evolution, eclv)

    -- 케릭터 타입별 테이블 얻어옴
    local table_char = self.m_charTable
    local t_char = table_char[cid]

    if (not t_char) then
        error(char_type .. ' cid : ' .. cid)
    end

    -- 능력치 테이블
    local table_status = TABLE:get('status')
    local t_status = table_status[status_name]

    -- 1. 기본 능력치
    local base_stat = t_status['base_stat']

    -- 2. 레벨 추가 능력치
    local lv_stat = nil
    local grade_stat = 0
    local evolution_stat = 0
    local eclv_stat = 0

	-- 2-1. 공방체 스탯만 레벨에 따라 증가시키고 나머지는 고정값이다. 
	if isExistValue(status_name, 'atk', 'def', 'hp') then
        local max_lv_value = t_char[status_name .. '_max']
        
        if (not max_lv_value) or (max_lv_value == '') then
            error(string.format('%s의 %s_max 스탯에 문제가 있어 에러가 발생했습니다.', t_char['t_name'], status_name))
        end

        local value_per_level = (max_lv_value / 208) -- @ commnet 최대 레벨이 바뀔때마다 수정해야하니 외부에서 참조하도록...
		lv_stat = value_per_level * lv

        -- 드래곤들만 적용
        if (char_type == 'dragon') then

            -- 승급 단계 보너스
            grade_stat = value_per_level * self.m_gradeTable:getBonusStatusLv(grade)

            -- 진화 단계 보너스
            evolution_stat = value_per_level * self.m_evolutionTable:getBonusStatusLv(evolution)
        end
	else
        lv_stat = t_char[status_name]
	end

    local basic_stat = base_stat + lv_stat + grade_stat + evolution_stat + eclv_stat

    return basic_stat, base_stat, lv_stat, grade_stat, evolution_stat, eclv_stat
end