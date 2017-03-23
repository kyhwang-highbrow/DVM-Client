local PARENT = class(StatusEffect, IEventListener:getCloneTable())

-------------------------------------
-- class StatusEffect_Trigger
-------------------------------------
StatusEffect_Trigger = class(PARENT, {
		m_triggerName = 'str',
		m_statusEffectInterval = 'number',
		m_triggerFunc = 'function',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Trigger:init(file_name, body)
	self.m_statusEffectInterval = g_constant:get('INGAME', 'STATUEEFFECT_GLOBAL_COOL')
end

-------------------------------------
-- function init_trigger
-- @brief 트리거 설정하고 시전자 저장
-------------------------------------
function StatusEffect_Trigger:init_trigger(char, trigger_name, t_skill)
	self.m_owner = char
	self.m_triggerName = trigger_name
	self.m_subData = t_skill

	self.m_triggerFunc = self:getTriggerFunction()

	char:addListener(self.m_triggerName, self)
end

-------------------------------------
-- function onEvent
-------------------------------------
function StatusEffect_Trigger:onEvent(event_name, t_event, ...)
    if (event_name == self.m_triggerName) then

		-- 트리거 쿨타임을 사용하지 않는 경우
		if (self.m_statusEffectInterval == 0) then
			if (self.m_triggerFunc) then
				self.m_triggerFunc(t_event, ...)
			end

		-- 트리거 쿨타임 사용
		else
			if (self.m_stateTimer > self.m_statusEffectInterval) then
				self.m_stateTimer = self.m_stateTimer - self.m_statusEffectInterval
				if (self.m_triggerFunc) then
					self.m_triggerFunc(t_event, ...)
				end
			end
		end
    end
end

-------------------------------------
-- function statusEffectReset
-------------------------------------
function StatusEffect_Trigger:release()
    self.m_owner:removeListener(self.m_triggerName, self)
    
	--@ TODO 상태효과 관리 구조 재설계 필요
	self:statusEffectReset()
	PARENT.release(self)
end

-------------------------------------
-- function getTriggerFunction
-- @TODO 트리거에서 사용될 함수를 선 정의한다. 좀더 구조화할 방법 고려해야한다
-------------------------------------
function StatusEffect_Trigger:getTriggerFunction()
	local t_skill = self.m_subData
    local char = self.m_owner
	local trigger_func = nil

	if (t_skill['type'] == 'passive_summon_die') then
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

	elseif (t_skill['type'] == 'passive_do_skill') then
		-- 지정된 trigger로 지정된 skill_id 실행 
		trigger_func = function()
			local skill_id = t_skill['val_1']
			char:doSkill(skill_id, nil, nil)
		end

	elseif (t_skill['type'] == 'passive_linked') then
		-- 모션 스트릭이 첨가된 힐
		trigger_func = function()
			local allyList = char:getFellowList()
			StatusEffectHelper:doStatusEffectByStr(char, allyList, {t_skill['status_effect_1'], t_skill['status_effect_2']}, function(target)
				EffectMotionStreak(target.m_world, char.pos.x, char.pos.y, target.pos.x, target.pos.y, RES_SE_MS)
			end)
		end

	elseif (t_skill['type'] == 'passive_vampire') then 
		-- 가한 dmg에 의하여 자기 자신의 체력 회복 
		trigger_func = function(t_event)
			local damage = t_event['damage']
			if (damage) then 
				local heal_abs = damage * (t_skill['val_1'] / 100)
				char:healAbs(heal_abs, true)
			end
		end

	elseif (t_skill['type'] == 'passive_spatter') then 
		-- 퐁당퐁당
		trigger_func = function()
			SkillSpatter:makeSkillInstance(char, t_skill)
		end
	
	elseif (t_skill['type'] == 'passive_add_attack') then 
		-- 추가 공격
		trigger_func = function(t_event)
			local target = t_event['target']
			SkillAddAttack:makeSkillInstance(owner, t_skill, target)
		end

	elseif (t_skill['type'] == 'passive_target') then
		-- target_rule에 따른 대상 1한테 시전
		trigger_func = function()
			local target_list = char:getTargetListByTable(t_skill)
			StatusEffectHelper:doStatusEffectByStr(char, {target_list[1]}, {t_skill['status_effect_1'], t_skill['status_effect_2']})
		end

    elseif (t_skill['type'] == 'passive_target_ms_effect') then
        -- target_rule에 따른 대상한테 시전 하면서 motion_streak effect 추가!
		-- 연출에 따라도 나뉘어야 함
		trigger_func = function(t_event)
			local defender = t_event['defender']
			local target_list = char:getTargetListByTable(t_skill)
			StatusEffectHelper:doStatusEffectByStr(char, target_list, {t_skill['status_effect_1'], t_skill['status_effect_2']}, function(target)
				EffectMotionStreak(target.m_world, defender.pos.x, defender.pos.y, target.pos.x, target.pos.y, RES_SE_MS)
			end)
		end

	-- default : 상태효과 시전
	----------------------------------------------------------------------
	else
		trigger_func = function(t_event)
			local t_status_effect_str = {t_skill['status_effect_1'], t_skill['status_effect_2']}
			StatusEffectHelper:doStatusEffectByStr(char, {defender}, t_status_effect_str)
		end
	end

	return trigger_func
end
