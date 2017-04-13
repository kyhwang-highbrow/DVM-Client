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
-- function doStatusEffectByTable
-- @brief 별도의 타겟을 가져오지 않고 스킬 테이블 통해서 상태효과 시전
-------------------------------------
function StatusEffectHelper:doStatusEffectByTable(char, t_skill, cb_func)
	-- 1. skill의 타겟룰로 상태효과의 대상 리스트를 얻어옴
	local l_target = char:getTargetListByTable(t_skill)
			
	-- 2. 상태효과 구조체
	local l_status_effect_struct = SkillHelper:makeStructStatusEffectList(t_skill)
			
	-- 3. 타겟에 상태효과생성
	StatusEffectHelper:doStatusEffectByStruct(char, l_target, l_status_effect_struct, cb_func)
end

-------------------------------------
-- function doStatusEffectByStruct
-- @brief 별도의 타겟을 받아와서 외부에서 상태효과 구조체 생성하여 상태효과 시전
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
	--[[
	-- 없앨지 말지 고민중
	상태효과 자체가 이벤트를 처리하지 않고
	스킬에서 처리되는 것이 더 좋지 않을까 함.
	
	상태효과에서 처리하던 이벤트를 캐릭터에서 처리하여
	이벤트가 발생하면 스킬을 실행하고 스킬에서 상태효과 실행 
	
	과거) 캐릭터 -> 상태효과 발동 -> 상태효과 상존하면서 이벤트 체크
	미래) 캐릭터 이벤트 체크 -> 스킬 실행 -> 상태효과 실행
	]]

	-- 상태효과 타입
	local status_effect_type = t_skill['add_option_type_1']
    
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
		
	----------- 도트 데미지 패시브 ------------------
	elseif (status_effect_type == 'bleed') then
		status_effect = StatusEffect_DotDmg_Bleed(res)
		status_effect:init_dotDmg(target_char, caster, t_status_effect, status_effect_value)
	elseif (status_effect_type == 'burn') then
		status_effect = StatusEffect_DotDmg_Burn(res)
		status_effect:init_dotDmg(target_char, caster, t_status_effect, status_effect_value)
	elseif (status_effect_type == 'poison') then
		status_effect = StatusEffect_DotDmg_Poison(res)
		status_effect:init_dotDmg(target_char, caster, t_status_effect, status_effect_value)

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

	----------- 디버프 해제 ------------------
	elseif isExistValue(status_effect_type, 'cure', 'remove', 'invalid') then
		status_effect = StatusEffect_Dispell(res)
		status_effect:init_status(status_effect_type, status_effect_value)

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
		se_resist = target_char:getStat('resistance')
	end

	-- 확률 permill 로 체크
	local adj_rate = (status_effect_rate + se_acc - se_resist)
	if (math_random(1, 1000) > adj_rate * 10) then
		-- 실패
		return true
	end

	-- 성공
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
			break
		end
	end
end

-------------------------------------
-- function releaseStatusEffectDebuff
-- @brief n개의 debuff 상태효과 해제
-- @return 해제 여부 boolean
-------------------------------------
function StatusEffectHelper:releaseStatusEffectDebuff(char, max_release_cnt)
	-- 피격자가 사망했을 경우 리턴
    if (char.m_bDead == true) then return end

	local max_release_cnt = max_release_cnt or 32
	local release_cnt = 0

	-- 해제
	for type, status_effect in pairs(char:getStatusEffectList()) do
        -- 해로운 효과 해제
		if self:isHarmful(status_effect.m_type) then 
		    status_effect:changeState('end')
			release_cnt = release_cnt + 1
        end
		-- 갯수 체크
		if (release_cnt >= max_release_cnt) then
			break
		end
	end

	return (release_cnt > 0)
end

-------------------------------------
-- function releaseStatusEffectBuff
-- @brief n개의 buff 상태효과 해제
-- @return 해제 여부 boolean
-------------------------------------
function StatusEffectHelper:releaseStatusEffectBuff(char, max_release_cnt)
	-- 피격자가 사망했을 경우 리턴
    if (char.m_bDead == true) then return end

	local max_release_cnt = max_release_cnt or 32
	local release_cnt = 0

	-- 해제
	for type, status_effect in pairs(char:getStatusEffectList()) do
        -- 해로운 효과 해제
		if self:isHelpful(status_effect.m_type) then 
		    status_effect:changeState('end')
			release_cnt = release_cnt + 1
        end
		-- 갯수 체크
		if (release_cnt >= max_release_cnt) then
			break
		end
	end

	return (release_cnt > 0)
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