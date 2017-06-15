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

    local t_info = TableDragonSkillBonus():get(dragon.m_dragonID)
    if (not t_info) then return end

    local desc = t_info['t_desc' .. bonus_level]
    return desc
end

-------------------------------------
-- function getBonusLevel
-- @brief 해당 스킬 타겟수 점수(%)에 해당하는 보너스 단계를 얻음(0이면 보너스 없음)
-------------------------------------
function DragonSkillBonusHelper:getBonusLevel(dragon, score)
    --[[
    local list = TableDragonSkillBonus():getLevelCondition(dragon.m_dragonID)

    if (list) then
        for i = #list, 1, -1 do
            if (score >= list[i]) then
                return i
            end
        end
    end
    ]]--
    return 0
end

-------------------------------------
-- function getStatusEffectStruct
-------------------------------------
function DragonSkillBonusHelper:getStatusEffectStruct(dragon, bonus_level)
    if (bonus_level == 0) or (bonus_level == -1) then return end

    local t_info = TableDragonSkillBonus():get(dragon.m_dragonID)
    if (not t_info) then return end

    local string_value = t_info['add_option_' .. bonus_level]
    if (not string_value or string_value == '' or string_value == 'x') then return end

    local l_str = seperate(string_value, ';')
    local status_effect_type = l_str[1]
    
    -- 스테이터스 이펙트 구조체 생성
	local struct_status_effect = StructStatusEffect({
		type = status_effect_type,
		target_type = l_str[2],
        target_count = tonumber(l_str[3]),
		trigger = 'skill_end',
		duration = tonumber(l_str[4]),
		rate = tonumber(l_str[5]),
		value = tonumber(l_str[6])
	})

    return struct_status_effect
end


-------------------------------------
-- function doInvoke
-- @brief 드래곤 드래그 스킬 사용시 직군별 보너스 부여
-------------------------------------
function DragonSkillBonusHelper:doInvoke(dragon, l_target, bonus_level)
    local struct_status_effect = self:getStatusEffectStruct(dragon, bonus_level)
    if (not struct_status_effect) then return end

    -------------------------------------
    -- 보너스 부여
    -------------------------------------
    local l_ally = StatusEffectHelper:doStatusEffect(dragon, {dragon},
        struct_status_effect.m_type,
        struct_status_effect.m_targetType,
        struct_status_effect.m_targetCount,
        struct_status_effect.m_duration,
        struct_status_effect.m_rate,
        struct_status_effect.m_value,
        struct_status_effect.m_source
    )

    -------------------------------------
    -- 연출
    -------------------------------------
    local world = dragon.m_world

    -- 텍스트 표시
    do
        local desc = self:getBonusDesc(dragon, bonus_level)
        for i, dragon in ipairs(l_ally) do
	        if (not world.m_mPassiveEffect[dragon]) then
		        world.m_mPassiveEffect[dragon] = {}
	        end
	        world.m_mPassiveEffect[dragon][desc] = true
        end
    end

    -- 이펙트 연출
    do
        local m_effect = {}
        function makeEffectMotionStreak(dragon, target)
            local t_param = {
                res = 'res/effect/motion_streak_dragskill/motion_streak_dragskill_feedback.png',
                x = target.pos.x,
                y = target.pos.y,
                tar_x = dragon.pos.x,
                tar_y = dragon.pos.y,
                cb_end = function()
                    if (not m_effect[dragon.phys_idx]) then
                        m_effect[dragon.phys_idx] = true
                    
                        world:addInstantEffect(
                            'res/effect/motion_streak_dragskill/motion_streak_dragskill.vrp',
                            'idle',
                            dragon.pos.x,
                            dragon.pos.y
                        )
                    end
                end
            }

            EffectMotionStreak(world, t_param)
        end

        local idx = 1

        if (#l_ally >= #l_target) then
            for i, ally in ipairs(l_ally) do
                local target = l_target[idx]
                if (not target) then
                    idx = 1
                    target = l_target[idx]
                end

                if (target) then
                    makeEffectMotionStreak(ally, target)
                end

                idx = idx + 1
            end
        else
            for i, target in ipairs(l_target) do
                local ally = l_ally[idx]
                if (not ally) then
                    idx = 1
                    ally = l_ally[idx]
                end

                if (ally) then
                    makeEffectMotionStreak(ally, target)
                end

                idx = idx + 1
            end
        end
    end
end