local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_PassiveSkill
-------------------------------------
StatusEffect_PassiveSkill = class(PARENT, {
		m_tSkill = 'table',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_PassiveSkill:init(file_name, body)
    self.m_overlabCnt = 1
end

-------------------------------------
-- function init_passiveSkill
-- @brief 트리거 패시브 스킬 관련 정보 설정
-------------------------------------
function StatusEffect_PassiveSkill:init_passiveSkill(trigger_name, t_skill)
    self.m_triggerName = trigger_name
	self.m_tSkill = t_skill

    self.m_triggerFunc = self:getTriggerFunction()
end

-------------------------------------
-- function getTriggerFunction
-- @TODO 트리거에서 사용될 함수를 선 정의한다. 좀더 구조화할 방법 고려해야한다
-------------------------------------
function StatusEffect_PassiveSkill:getTriggerFunction()
	local t_skill = self.m_tSkill
    if (not t_skill) then return end

    local char = self.m_owner
	local trigger_func = nil
    local skill_id = t_skill['sid']
	local skill_type = t_skill['skill_type']

	if (skill_type == 'passive_summon_die') then
		-- 지정된 trigger로 해당 위치에 지정된 몬스터를 appear로 소환
		trigger_func = function()
            local mid = t_skill['val_1']
			local lv = t_skill['val_2']
			local dest = t_skill['val_3']
			local effect_res = t_skill['res_1']
			local pos_x = char.pos.x
			local pos_y = char.pos.y

			-- 소환자 위치에 몬스터 소환
			local enemy = char.m_world.m_waveMgr:spawnEnemy_dynamic(mid, lv, 'Appear', nil, dest, 0.5)
			enemy:setPosition(pos_x, pos_y)
			enemy:setHomePos(pos_x, pos_y)
			if enemy.m_hpNode then
				enemy.m_hpNode:setVisible(true)
			end

			-- 소환 연출
			char.m_world:addInstantEffect(effect_res, 'idle', pos_x, pos_y)
		end

	elseif (skill_type == 'passive_do_skill') then
		-- 지정된 trigger로 지정된 skill_id 실행 
		trigger_func = function()
            local skill_id = t_skill['val_1']
			char:doSkill(skill_id, nil, nil)
		end

	elseif (skill_type == 'passive_linked') then
		-- 모션 스트릭이 첨가된 힐
		trigger_func = function()
			local allyList = char:getFellowList()
			StatusEffectHelper:doStatusEffectByStruct(char, allyList, SkillHelper:makeStructStatusEffectList(t_skill), function(target)
                local t_param = {
                    res = RES_SE_MS,
                    x = char.pos.x,
                    y = char.pos.y,
                    tar_x = target.pos.x,
                    tar_y = target.pos.y
                }

				EffectMotionStreak(target.m_world, t_param)
			end, skill_id)
		end

	elseif (skill_type == 'passive_vampire') then 
		-- 가한 dmg에 의하여 자기 자신의 체력 회복 
		trigger_func = function(t_event)
			local damage = t_event['damage']
			if (damage) then 
				local heal_abs = damage * (t_skill['val_1'] / 100)
				char:healAbs(char, heal_abs, true)
			end
		end

	elseif (skill_type == 'passive_spatter') then 
		-- 퐁당퐁당
		trigger_func = function()
			SkillSpatter:makeSkillInstance(char, t_skill)
		end
	
	elseif (skill_type == 'passive_add_attack') then 
		-- 추가 공격
		trigger_func = function(t_event)
			local target = t_event['target']
			SkillAddAttack:makeSkillInstance(owner, t_skill, target)
		end

	elseif (skill_type == 'passive_target') then
		-- target_rule에 따른 대상 1한테 시전
		trigger_func = function()
			local target_list = char:getTargetListByTable(t_skill)
			StatusEffectHelper:doStatusEffectByStruct(char, {target_list[1]}, SkillHelper:makeStructStatusEffectList(t_skill), nil, skill_id)
		end

    elseif (skill_type == 'passive_target_ms_effect') then
        -- target_rule에 따른 대상한테 시전 하면서 motion_streak effect 추가!
		-- 연출에 따라도 나뉘어야 함
		trigger_func = function(t_event)
			local defender = t_event['defender']
			local target_list = char:getTargetListByTable(t_skill)
			StatusEffectHelper:doStatusEffectByStruct(char, target_list, SkillHelper:makeStructStatusEffectList(t_skill), function(target)
                local t_param = {
                    res = RES_SE_MS,
                    x = defender.pos.x,
                    y = defender.pos.y,
                    tar_x = target.pos.x,
                    tar_y = target.pos.y
                }

				EffectMotionStreak(target.m_world, t_param)
			end, skill_id)
		end

	-- default : 상태효과 시전
	----------------------------------------------------------------------
	else
		trigger_func = function(t_event)
			StatusEffectHelper:doStatusEffectByStruct(char, {defender}, SkillHelper:makeStructStatusEffectList(t_skill), nil, skill_id)
		end
	end

	return trigger_func
end
