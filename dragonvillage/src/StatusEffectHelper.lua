-------------------------------------
-- table StatusEffectHelper
-- @brief 상태 효과 핼퍼
-------------------------------------
StatusEffectHelper = {}

-------------------------------------
-- function statusEffectCheck_onHit
-- @brief 상태 효과 확인
-------------------------------------
function StatusEffectHelper:statusEffectCheck_onHit(activity_carrier, defender)
    -- 피격자가 사망했을 경우 리턴
    if (defender.m_bDead == true) then
        return
    end

    -- 상태 이펙트 유발 리스트 갯수 확인
    local count = table.count(activity_carrier.m_lStatusEffectRate)
    if (count <= 0) then
        return
    end

	local attacker = activity_carrier:getActivityOwner()
    for type, t_content in pairs(activity_carrier.m_lStatusEffectRate) do
		local value = t_content['value']
		local rate = t_content['rate']
        StatusEffectHelper:invokeStatusEffect(attacker, defender, type, value, rate)
    end
end

-------------------------------------
-- function doStatusEffectByStruct
-- @brief statuseffect struct 사용함
-------------------------------------
function StatusEffectHelper:doStatusEffectByStruct(caster, l_skill_target, l_status_effect_struct, cb_invoke)
    -- 피격자가 사망했을 경우 리턴
    if (caster.m_bDead == true) then return end

    local cb_invoke = cb_invoke or function() end

	-- 1. 타겟 대상에 상태효과생성
	local idx = 1
	local effect_str = nil
	local t_effect = nil
	local type = nil 
	local target_type = nil 
    local trigger = nil
	local duration = nil
	local rate = nil
	local value_1 = nil
	local value_2 = nil
	
	while true do 
		-- 1. 파싱할 구문 가져오고 탈출 체크
		status_effect_struct = l_status_effect_struct[idx]
		if (not status_effect_struct) then 
			break 
		end

		-- 2. 파싱하여 규칙에 맞게 분배
		type = status_effect_struct.m_type
		target_type = status_effect_struct.m_targetType
        trigger = status_effect_struct.m_trigger
		duration = status_effect_struct.m_duration
		rate = status_effect_struct.m_rate
		value_1 = status_effect_struct.m_value1
		value_2 = status_effect_struct.m_value2

        -- 3. 타겟 리스트 순회하며 상태효과 걸어준다.
    
	    -- 스킬로 부터 받은 타겟 리스트 사용
		if (target_type == 'target') then
            if (not l_skill_target) then
                error('doStatusEffectByStruct no l_skill_target')
            end

			for _, target in ipairs(l_skill_target) do
				if (StatusEffectHelper:invokeStatusEffect(caster, target, type, value_1, rate, duration)) then
                    cb_invoke(target)
                end
			end

		-- 별도의 계산된 타겟 리스트 사용
		elseif (target_type) then
			local l_target = caster:getTargetListByType(target_type, nil)
			for _, target in ipairs(l_target) do
				if (StatusEffectHelper:invokeStatusEffect(caster, target, type, value_1, rate, duration)) then
					cb_invoke(target)
				end
			end
		end

		-- 4. 인덱스 증가
		idx = idx + 1
	end
end

-------------------------------------
-- function invokeStatusEffect
-- @brief 상태 효과 발동
-------------------------------------
function StatusEffectHelper:invokeStatusEffect(caster, target_char, status_effect_type, status_effect_value, status_effect_rate, duration)
    -- status effect validation
	if (not status_effect_type) or (status_effect_type == '') then
        return nil
    end

	local t_status_effect = TABLE:get('status_effect')[status_effect_type]
	local status_effect_group = t_status_effect['type']

	-- 확률 검사
	if self:checkPermillRate(caster, target_char, status_effect_rate, status_effect_group) then
		return nil
	end
	 
	-- 면역 효과
	if (target_char.m_isImmuneSE) and self:isHarmful(status_effect_group) then 
		return nil
	end
    
	-- 상태효과 생성 시작
	local status_effect = nil
	if (t_status_effect['overlab'] > 0) then
		status_effect = target_char.m_tOverlabStatusEffect[status_effect_type]
	end

	if status_effect then
		status_effect:statusEffectOverlab()
	else
		-- 상태 효과 생성
		status_effect = StatusEffectHelper:makeStatusEffectInstance(caster, target_char, status_effect_type, status_effect_value, status_effect_rate, duration)
	end

	return status_effect
end

-------------------------------------
-- function setTriggerPassive
-------------------------------------
function StatusEffectHelper:setTriggerPassive(char, t_skill)
	error('mskim에게 문의주세요 : setTriggerPassive')
	--[[
	-- 없앨지 말지 고민중
	상태효과 자체가 이벤트를 처리하지 않고
	스킬에서 처리되는 것이 더 좋지 않을까 함.
	
	상태효과에서 처리하던 이벤트를 캐릭터에서 처리하여
	이벤트가 발생하면 스킬을 실행하고 스킬에서 상태효과 실행 
	
	과거) 캐릭터 -> 상태효과 발동 -> 상태효과 상존하면서 이벤트 체크
	미래) 캐릭터 이벤트 체크 -> 스킬 실행 -> 상태효과 실행

	-- 상태효과 타입
	local status_effect_type = self:getStatusEffectTableFromSkillTable(t_skill, 1)['type']
    
	-- @TODO TableStatusEffect 도 만들어야함
	local table_status_effect = TABLE:get('status_effect')
    local t_status_effect = table_status_effect[status_effect_type] or {}

	-- res attr parsing
    local res = t_status_effect['res']
	if (res) then 
		if (res == '') then 
			res = nil 
		else
			res = string.gsub(res, '@', char:getAttribute())
		end
	end

	local trigger_name = t_skill['chance_value'] or 'undergo_attack'
	
	local status_effect = StatusEffect_Trigger(res)
	status_effect:init_trigger(char, trigger_name, t_skill)
	
	char.m_world:addToUnitList(status_effect)

    return status_effect
	]]
end

-------------------------------------
-- function makeStatusEffectInstance
-- @comment 일반 status effect의 경우 rate가 필요없지만 패시브의 경우 실행 시점에서 확률체크하는 경우가 있다.
-------------------------------------
function StatusEffectHelper:makeStatusEffectInstance(caster, target_char, status_effect_type, status_effect_value, status_effect_rate, duration)
    -- 테이블 가져옴
	local table_status_effect = TABLE:get('status_effect')
    local t_status_effect = table_status_effect[status_effect_type]

	-- 여기서는 상태효과가 없으면 에러를 발생시켜야함
    if (not t_status_effect) then
        error('no status_effect table : ' .. status_effect_type)
    end

	-- res attr parsing
    local res = t_status_effect['res']
	if (res) then 
		res = string.gsub(res, '@', target_char:getAttribute())
	end
	-- nil 처리
	if (res == '') then 
		res = nil 
	end

	local status_effect = nil

    ----------- 드래곤 스킬 피드백(보너스) ------------------
	if (status_effect_type == 'feedback_defender' or status_effect_type == 'feedback_attacker'
        or status_effect_type == 'feedback_supporter' or status_effect_type == 'feedback_healer') then
        
        -- TODO: feedback_supporter 타입을 위한 정리 필요할듯...
        local value = tonumber(status_effect_value)

        if (status_effect_type == 'feedback_supporter') then
            status_effect = StatusEffect(res)
            -- 스킬 게이지 회복 타입은 status effect로 현재는 불가능하기 때문에 임시로...
            target_char:increaseActiveSkillCool(value)
        elseif (status_effect_type == 'feedback_healer') then
            status_effect = StatusEffect_Heal(res)
		    status_effect:init_heal(target_char, t_status_effect, status_effect_value, duration)
        else
            status_effect = StatusEffect(res)
        end

	------------ 힐 --------------------------
    elseif isExistValue(status_effect_type, 'passive_recovery') or
		string.find(status_effect_type, 'heal') then
        status_effect = StatusEffect_Heal(res)
		status_effect:init_heal(target_char, t_status_effect, status_effect_value, duration)
		
	----------- 도트 데미지 들어가는 패시브 ------------------
	elseif (t_status_effect['type'] == 'dot_dmg') then
		status_effect = StatusEffect_DotDmg(res)
		status_effect:init_dotDmg(target_char, t_status_effect, status_effect_value, caster)

	----------- HP 보호막 ------------------
	elseif (status_effect_type == 'barrier_protection') then
		status_effect = StatusEffect_Protection(res)
		local adj_value = t_status_effect['val_1'] * (status_effect_value / 100)
		local shield_hp = target_char.m_maxHp * (adj_value / 100)
		status_effect:init_trigger(target_char, shield_hp)
	
	----------- 데미지 경감 보호막 ------------------
	elseif isExistValue(status_effect_type, 'resist', 'barrier_protection_darknix') then
		status_effect = StatusEffect_Resist(res)
		local adj_value = t_status_effect['dmg_adj_rate'] * (status_effect_value / 100)
		local resist_rate = (adj_value / 100)
		status_effect:init_trigger(target_char, resist_rate)

	----------- 특이한 해제 조건을 가진 것들 ------------------
	elseif isExistValue(status_effect_type, 'sleep') then
		status_effect = StatusEffect_Trigger_Release(res)
		status_effect:init_trigger(target_char, 'undergo_attack', {status_effect_type = status_effect_type, status_effect_value = status_effect_value, status_effect_rate = status_effect_rate})
	
	----------- 침묵 ------------------
	elseif (status_effect_type == 'silence') then
		status_effect = StatusEffect_Silence(res)
		status_effect:init_status(target_char)
	
	----------- 속성 변경 ------------------
	elseif (status_effect_type == 'attr_change') then
		--@TODO 카운터 속성으로 변경, 추후 정리
		status_effect = StatusEffect_AttributeChange(res)
		local tar_attr = caster.m_targetChar:getAttribute()
		status_effect:init_statusEffect(target_char, tar_attr)

	----------- 조건부 추가 데미지 ------------------
	elseif string.find(status_effect_type, 'add_dmg_') then
		status_effect = StatusEffect_AddDmg(res)
		local condition = string.gsub(status_effect_type, 'add_dmg_', '')
		status_effect:init_statusEffect(target_char, condition, status_effect_value, caster)


    else
        status_effect = StatusEffect(res)
    end

    status_effect.m_subData = {status_effect_type = status_effect_type, status_effect_value = status_effect_value, status_effect_rate = status_effect_rate}

	 -- 능력치 지정
    local is_abs = (t_status_effect['abs_switch'] and (t_status_effect['abs_switch'] == 1) or false)

    for _, type in ipairs(L_STATUS_TYPE) do
        local value = t_status_effect[type] or 0
        if (value ~= 0) then
			value = value * status_effect_value/100
            status_effect:insertStatus(type, value, is_abs)
        end
    end

    status_effect.m_statusEffectName = status_effect_type
	status_effect.m_type = t_status_effect['type']

    -- 시간 지정 (skill table 에서 받아와서 덮어씌우거나 status effect table 값 사용)
    status_effect.m_duration = tonumber(duration) or tonumber(t_status_effect['duration'])
    status_effect.m_durationTimer = status_effect.m_duration

    -- 중첩 지정
    status_effect.m_maxOverlab = t_status_effect['overlab']

	-- 대상 지정 
	status_effect:setTargetChar(target_char)

	-- 시전자 지정
	status_effect:setCasterChar(caster)
        
	-- 객체 생성
    local world = target_char.m_world
    --world.m_worldNode:addChild(status_effect.m_rootNode, WORLD_Z_ORDER.SE_EFFECT)
    world.m_missiledNode:addChild(status_effect.m_rootNode, 1)
    world:addToUnitList(status_effect)

    status_effect:initState()
    status_effect:changeState('start')

	-- @EVENT 
	if (StatusEffectHelper:isHarmful(status_effect)) then
		local t_event = clone(EVENT_STATUS_EFFECT)
		t_event['char'] = target_char
		t_event['status_effect_name'] = status_effect.m_statusEffectName
		target_char:dispatch('get_debuff', t_event)
	end

    return status_effect
end

-------------------------------------
-- function invokePassive
-------------------------------------
function StatusEffectHelper:invokePassive(char, t_skill)
	local l_status_effect_struct = SkillHelper:makeStructStatusEffectList(t_skill)
	
	-- 1. 발동 조건 확인 (발동되지 않을 경우 리턴)
	-- 기획 이슈로 제거

	-- 2. 타겟 대상에 passive생성
	local idx = 1
	local effect_str = nil
	local t_effect = nil
	local type = nil 
	local target_type = nil
    local start_con = nil
	local duration = nil
	local rate = nil
	local value_1 = nil
	local value_2 = nil

	while true do 
		-- 1. 파싱할 구문 가져오고 탈출 체크
		status_effect_struct = l_status_effect_struct[idx]
		if (not status_effect_struct) then 
			break 
		end

		-- 2. 파싱하여 규칙에 맞게 분배
		type = status_effect_struct.m_type
		target_type = status_effect_struct.m_targetType
        trigger = status_effect_struct.m_trigger
		duration = status_effect_struct.m_duration
		rate = status_effect_struct.m_rate
		value_1 = status_effect_struct.m_value1
		value_2 = status_effect_struct.m_value2
		
		local function apply_world_passive_effect(char)
			local world = char.m_world
			-- 발동된 패시브의 연출을 위해 world에 발동된 passive정보를 저장
			if (not world.m_mPassiveEffect[char]) then
				world.m_mPassiveEffect[char] = {}
			end
			world.m_mPassiveEffect[char][t_skill['t_name']] = true
		end

		-- 3. 타겟 리스트 순회하며 상태효과 걸어준다.
		
		-- 스킬 타겟타입에 의한 타겟 리스트
		if (target_type == 'target') then
			local l_target = char:getTargetListByTable(t_skill)
			for _, target in ipairs(l_target) do
				StatusEffectHelper:invokeStatusEffect(owner, target, type, value_1, rate, duration)
				apply_world_passive_effect(target)
			end

		-- 별도의 계산된 타겟 리스트 사용
		elseif (target_type) then
			local l_target = char:getTargetListByType(target_type, nil)
			for _, target in ipairs(l_target) do
				cclog(target_type, target:getName())
				StatusEffectHelper:invokeStatusEffect(owner, target, type, value_1, rate, duration)
				apply_world_passive_effect(target)
			end

		end

		-- 4. 인덱스 증가
		idx = idx + 1
	end
end

-------------------------------------
-- function invokeStatusEffectForDev
-- @brief
-------------------------------------
function StatusEffectHelper:invokeStatusEffectForDev(char, res)
    -- 상태 효과 생성
    local status_effect = StatusEffect(res)

    -- 시간 지정
    status_effect.m_duration = 100
    status_effect.m_durationTimer = 100

    status_effect.m_owner = char
    status_effect.m_statusEffectName = 'poison'
	status_effect.m_type = 'dot_dmg'

    -- 객체 생성
    local world = char.m_world
    world.m_worldNode:addChild(status_effect.m_rootNode, WORLD_Z_ORDER.SE_EFFECT)
    world:addToUnitList(status_effect)

	status_effect:initState()
    status_effect:changeState('start')
end

-------------------------------------
-- function checkPermillRate
-------------------------------------
function StatusEffectHelper:checkPermillRate(caster, target_char, status_effect_rate, status_effect_group)
	local is_helpful = self:isHarmful(status_effect_group)
	
	-- @ RUNE
	local se_acc = caster:getStat('accuracy')
	local se_resist
	if (is_helpful) then
		se_resist = 0
	else
		se_resist = is_helpful and 0 or target_char:getStat('resistance')
	end

	local adj_rate = (status_effect_rate + se_acc - se_resist)

	if (math_random(1, 1000) < adj_rate * 10) then 
		return true
	end

	return false
end

-------------------------------------
-- function releaseStatusEffect
-- @brief 특정 타입의 상태효과 해제
-------------------------------------
function StatusEffectHelper:releaseStatusEffectByType(char, status_effect_type)
    -- 타입 있는지 검사
    if (not status_effect_type) or (status_effect_type == '') then return end

	-- 피격자가 사망했을 경우 리턴
    if (char.m_bDead == true) then return end

	-- 특정 타입 해제
	-- @TODO 타입명 말고 phys_key로 해제하려면... 해제 주체가 status effect 에 있어야 하는데 아닌 경우도 있어 임시로 처리
	for type, tar_status_effect in pairs(char:getStatusEffectList()) do
		if (status_effect_type == type) then 
			tar_status_effect:changeState('end')
			char:removeStatusEffect(tar_status_effect)
			break
		end
	end
end

-------------------------------------
-- function releaseHarmfulStatusEffect
-- @brief 해로운 상태효과 1가지 해제
-- @return 해제 여부 boolean
-------------------------------------
function StatusEffectHelper:releaseHarmfulStatusEffect(char)
	-- 피격자가 사망했을 경우 리턴
    if (char.m_bDead == true) then return false end

	-- 해제
	for type, status_effect in pairs(char:getStatusEffectList()) do
		if self:isHarmful(status_effect.m_type) then 
			status_effect:changeState('end')
			char:removeStatusEffect(status_effect)
			return true
		end
	end

	return false
end

-------------------------------------
-- function releaseStatusEffectDebuff
-- @brief 모든 debuff 상태효과 해제
-------------------------------------
function StatusEffectHelper:releaseStatusEffectDebuff(char)
	-- 피격자가 사망했을 경우 리턴
    if (char.m_bDead == true) then return end

	-- 해제
	local release_cnt = 0
	for type, status_effect in pairs(char:getStatusEffectList()) do
        if self:isHarmful(status_effect.m_type) then 
		    status_effect:changeState('end')
			release_cnt = release_cnt + 1
        end
	end

	return release_cnt
end

-------------------------------------
-- function releaseStatusEffectAll
-- @brief 모든 상태효과 해제
-------------------------------------
function StatusEffectHelper:releaseStatusEffectAll(char)
	-- 피격자가 사망했을 경우 리턴
    if (char.m_bDead == true) then return end

	-- 해제
	for type, status_effect in pairs(char:getStatusEffectList()) do
		status_effect:changeState('end')
	end
end

-------------------------------------
-- function isHarmful
-- @breif 해로운 효과
-- @param param_1 은 statuseffect 의 'type'이나 statuseffect객체 자체
-------------------------------------
function StatusEffectHelper:isHarmful(param_1)
	local status_effect_type

	if (type(param_1) == 'string') then
		status_effect_type = param_1
	elseif (isInstanceOf(param_1, StatusEffect)) then
		status_effect_type = param_1.m_type
	end

	return isExistValue(status_effect_type, 'debuff', 'cc', 'dot_dmg')
end

-------------------------------------
-- function isHelpful
-- @breif 이로운 효과
-- @param param_1 은 statuseffect 의 'type'이나 statuseffect객체 자체
-------------------------------------
function StatusEffectHelper:isHelpful(param_1)
	local status_effect_type

	if (type(param_1) == 'string') then
		status_effect_type = param_1
	elseif (isInstanceOf(param_1, StatusEffect)) then
		status_effect_type = param_1.m_type
	end

	return isExistValue(status_effect_type, 'buff', 'barrier', 'dot_heal')
end