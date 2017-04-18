-------------------------------------
-- DragonSkillBonusHelper
-------------------------------------
DragonSkillBonusHelper = {}

-------------------------------------
-- function getBonusDesc
-- @brief 해당 드래곤의 피드백 스킬 설명 문구를 얻음
-------------------------------------
function DragonSkillBonusHelper:getBonusDesc(dragon, bonus_level)
    if (bonus_level == 0) then return end

    local t_dragon = dragon.m_charTable
    local desc = ''

    local t_info = TableDragonSkillBonus():get(t_dragon['did'])
    if (not t_info) then return end

    local desc = t_info['t_desc' .. bonus_level]
    return desc
end

-------------------------------------
-- function getBonusLevel
-- @brief 해당 스킬 타겟수 점수(%)에 해당하는 보너스 단계를 얻음(0이면 보너스 없음)
-------------------------------------
function DragonSkillBonusHelper:getBonusLevel(dragon, score)
    local t_dragon = dragon.m_charTable
    local list = TableDragonSkillBonus():getLevelCondition(t_dragon['did'])

    if (list) then
        for i = #list, 1, -1 do
            if (score >= list[i]) then
                return i
            end
        end
    end

    return 0
end


-------------------------------------
-- function invokeBonus
-- @brief 드래곤 드래그 스킬 사용시 직군별 보너스 부여
-------------------------------------
function DragonSkillBonusHelper:invokeBonus(dragon, bonus_level)
    if (bonus_level == 0) then return end

    local t_dragon = dragon.m_charTable
    local t_info = TableDragonSkillBonus():get(t_dragon['did'])
    if (not t_info) then return end

    local string_value = t_info['add_option_' .. bonus_level]
    if (not string_value or string_value == '' or string_value == 'x') then return end

    local l_str = seperate(string_value, ';')
    local status_effect_type = l_str[1]
    
    -- 스테이터스 이펙트 적용
	local struct_status_effect = StructStatusEffect({
		type = status_effect_type,
		target_type = l_str[2],
        target_count = l_str[3],
		trigger = 'skill_end',
		duration = l_str[4],
		rate = l_str[5],
		value1 = l_str[6],
		value2 = 0
	})

    if (struct_status_effect) then
        StatusEffectHelper:doStatusEffectByStruct(dragon, {dragon}, {struct_status_effect})

        local desc = self:getBonusDesc(dragon, bonus_level)
        local world = dragon.m_world

		if (not world.m_mPassiveEffect[dragon]) then
			world.m_mPassiveEffect[dragon] = {}
		end
		world.m_mPassiveEffect[dragon][desc] = true
    end
end