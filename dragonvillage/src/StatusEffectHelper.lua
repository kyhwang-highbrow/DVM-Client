-------------------------------------
-- table StatusEffectHelper
-- @brief 상태 효과 핼퍼
-------------------------------------
StatusEffectHelper = {}

-------------------------------------
-- function statusEffectCheck_onHit
-- @brief 상태 효과 확인
-------------------------------------
function StatusEffectHelper:statusEffectCheck_onHit(attack_damage, defender)
    -- 피격자가 사망했을 경우 리턴
    if (defender.m_bDead == true) then
        return
    end

    -- 상태 이펙트 유발 리스트 갯수 확인
    local count = table.count(attack_damage.m_lStatusEffectRate)
    if (count <= 0) then
        return
    end

    for type, t_content in pairs(attack_damage.m_lStatusEffectRate) do
		local value = t_content['value']
		local rate = t_content['rate']

        -- 확률을 퍼밀로 계산
        local permill = rate * 10
        if (math_random(1, 1000) <= permill) then
            StatusEffectHelper:invokeStatusEffect(defender, type, value, rate)
        end
    end
end

-------------------------------------
-- function doStatusEffect_simple
-- @brief 리팩토링중
-------------------------------------
function StatusEffectHelper:doStatusEffect_simple(char, status_effect_type, status_effect_value, status_effect_rate, duration)
    -- 타입 있는지 검사
    if (not status_effect_type) or (status_effect_type == 'x') then return end

	-- 피격자가 사망했을 경우 리턴
    if (char.m_bDead == true) then return end

	-- 확률 검사
    if (math_random(1, 1000) > status_effect_rate * 10) then return end

	-- 상태효과 실행
	StatusEffectHelper:invokeStatusEffect(char, status_effect_type, status_effect_value, status_effect_rate, duration)
end

-------------------------------------
-- function doStatusEffect
-- @brief 확률 체크하여 패시브 발동 
-- @TODO 공격이나 스킬에 묻어나는 경우.. 
-------------------------------------
function StatusEffectHelper:doStatusEffect(char, t_skill)
	local status_effect_type = t_skill['status_effect_type']
	local status_effect_value = t_skill['status_effect_value']
	local status_effect_rate = t_skill['status_effect_rate']

	self:doStatusEffectByType(char, status_effect_type, status_effect_value, status_effect_rate)
end

-------------------------------------
-- function doStatusEffectByType
-- @brief 확률 체크하여 패시브 발동 
-- @brief skill table을 사용하지 않기 위해 
-------------------------------------
function StatusEffectHelper:doStatusEffectByType(char, status_effect_type, status_effect_value, status_effect_rate, duration)
    -- 타입 있는지 검사
    if (not status_effect_type) or (status_effect_type == 'x') then return end

	-- 피격자가 사망했을 경우 리턴
    if (char.m_bDead == true) then return end
	
	-- ;로 구분하여 다중 버프 가능하도록 함
	local t_status_effect_type = stringSplit(status_effect_type, ';')
	local t_status_effect_value = stringSplit(status_effect_value, ';')
	local t_status_effect_rate = stringSplit(status_effect_rate, ';')
	for i, type in ipairs(t_status_effect_type) do
		local value = t_status_effect_value[i]
		local rate = t_status_effect_rate[i]
	 
		-- 확률 검사
		if (math_random(1, 1000) < rate * 10) then 
			-- 상태효과 실행
			StatusEffectHelper:invokeStatusEffect(char, type, value, rate, duration)
		end
	end
end

-------------------------------------
-- function doStatusEffectByStr
-- @brief statuseffect 배열 사용함
-------------------------------------
function StatusEffectHelper:doStatusEffectByStr(owner, t_target, l_status_effect_str)
   	-- 피격자가 사망했을 경우 리턴
    if (owner.m_bDead == true) then return end
	
	-- 1. 타겟 대상에 상태효과생성
	local idx = 1
	local effect_str = nil
	local t_effect = nil
	local type = nil 
	local target_type = nil 
	local duration = nil
	local rate = nil
	local value_1 = nil
	local value_2 = nil
	
	while true do 
		-- 1. 파싱할 구문 가져오고 탈출 체크
		effect_str = l_status_effect_str[idx]
		if (not effect_str) or (effect_str == 'x') then 
			break 
		end

		-- 2. 파싱하여 규칙에 맞게 분배
		t_effect = stringSplit(effect_str, ';')
		type = t_effect[1]
		target_type = t_effect[2]
		duration = t_effect[3]
		rate = t_effect[4] 
		value_1 = t_effect[5]
		--value_2 = t_effect[4]
		
		-- 3. 타겟 리스트 순회하며 상태효과 걸어준다.
		if (target_type == 'self') then 
			StatusEffectHelper:invokeStatusEffect(owner, type, value_1, rate, duration)
		elseif (target_type == 'target') then 
			for _, target in ipairs(t_target) do
				StatusEffectHelper:invokeStatusEffect(target, type, value_1, rate, duration)
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
function StatusEffectHelper:invokeStatusEffect(char, status_effect_type, status_effect_value, status_effect_rate, duration)
    -- validation
	if (not status_effect_type) or (status_effect_type == 'x') then
        return nil
    end
		 
	-- 확률 검사
	if (math_random(1, 1000) > status_effect_rate * 10) then 
		return nil
	end

    local table_status_effect = TABLE:get('status_effect')
    local t_status_effect = table_status_effect[status_effect_type]

    assert(t_status_effect, 'status_effect_type : ' .. status_effect_type)
	
    local status_effect = nil
    if (t_status_effect['overlab'] > 0) then
        status_effect = char.m_tOverlabStatusEffect[status_effect_type]
    end

    if status_effect then
        status_effect:statusEffectOverlab()
    else
        -- 상태 효과 생성
        status_effect = StatusEffectHelper:makeStatusEffectInstance(char, status_effect_type, status_effect_value, status_effect_rate, duration)
    end

    if (t_status_effect['overlab'] > 0) then
        char.m_tOverlabStatusEffect[status_effect_type] = status_effect
    end
	
	-- groggy 옵션이 있다면 stun 상태로 바꾼다. 이외의 부가적인 효과는 개별적으로 구현
	if (t_status_effect['groggy'] == 'true') then 
		char:changeState('stun')
	end	

	-- character에 status_effect 저장
	char:insertStatusEffect(status_effect)

    return status_effect
end

-------------------------------------
-- function setTriggerPassive
-------------------------------------
function StatusEffectHelper:setTriggerPassive(char, t_skill)
    local table_status_effect = TABLE:get('status_effect')
	local status_effect_type = self:getStatusEffectTypeFromSkillTable(t_skill)
    local t_status_effect = table_status_effect[status_effect_type]
    
    local res = t_status_effect['res']
    if (res == 'x') then res = nil end

	local status_effect = StatusEffect_Trigger(res)

	-- 적 처치 시
	if (t_skill['type'] == 'skill_cri_chance_up') then
		cclog('123123')
		status_effect:init_trigger('slain', char)
	
	-- 모든 공격시
	elseif (t_skill['type'] == 'skill_poison') then
		status_effect:init_trigger('hit', char)

	-- 일반 공격시
	elseif isExistValue(t_skill['type'], 'skill_rage') then
		status_effect:init_trigger('hit_basic', char)
	
	elseif (status_effect_type == 'passive_add_attack') then
        status_effect = StatusEffect_addAttack(res)
		status_effect:init_trigger('hit_basic', char)

	-- 피격시
	elseif (t_skill['type'] == 'skill_def_up_overlab') then
		status_effect:init_trigger('undergo_attack', char)
	
	-- 회피시
	elseif (status_effect_type == 'passive_spatter') then
        status_effect = StatusEffect_PassiveSpatter(res)
		status_effect:init_trigger('avoid', char)

	-- default : 피격시
	else
		status_effect:init_trigger('undergo_attack', char)
    end
			
    status_effect.m_subData = t_skill

    return status_effect
end

-------------------------------------
-- function makeStatusEffectInstance
-- @comment 일반 status effect의 경우 rate가 필요없지만 패시브의 경우 실행 시점에서 확률체크하는 경우가 있다.
-------------------------------------
function StatusEffectHelper:makeStatusEffectInstance(char, status_effect_type, status_effect_value, status_effect_rate, duration)
    local table_status_effect = TABLE:get('status_effect')
    local t_status_effect = table_status_effect[status_effect_type]
    local res = t_status_effect['res']
	
    if (res == 'x') then
        res = nil
    end

	local status_effect = nil

	------------ 힐 --------------------------
    if (status_effect_type == 'heal') then
        status_effect = StatusEffect_Recovery(res)
		status_effect:init_recovery(char, t_status_effect, status_effect_value, duration)

	----------- 필드 체크 필요한 패시브 ------------------
	elseif (status_effect_type == 'passive_bloodlust') then
		status_effect = StatusEffect_CheckWorld(res)
		status_effect:init_checkWorld(char, 'bleed') 

	----------- 도트 데미지 들어가는 패시브 ------------------
	elseif (t_status_effect['type'] == 'dot_dmg') then
		status_effect = StatusEffect_DotDmg(res)
		status_effect:init_dotDmg(char, t_status_effect)

	----------- 보호막 ------------------
	elseif (t_status_effect['type'] == 'barrier') then
		status_effect = StatusEffect_Protection(res)
		local shield_hp = char.m_maxHp * (t_status_effect['val_1'] / 100)
		status_effect:init_buff(char, shield_hp)

    else
        status_effect = StatusEffect(res)
    end

    status_effect.m_subData = {status_effect_type = status_effect_type, status_effect_value = status_effect_value, status_effect_rate = status_effect_rate}

	 -- 능력치 지정
    for _, type in ipairs(L_STATUS_TYPE) do
        local value = t_status_effect[type]
        if (value ~= 0) then
			value = value * status_effect_value/100
            status_effect:insertStatus(type, value)
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
	status_effect:setTargetChar(char)
        
	-- 객체 생성
    local world = char.m_world
    world.m_worldNode:addChild(status_effect.m_rootNode, 10)
    world:addToUnitList(status_effect)

    status_effect:initState()
    status_effect:changeState('start')

    return status_effect
end

-------------------------------------
-- function invokePassive
-------------------------------------
function StatusEffectHelper:invokePassive(char, t_skill)
	local table_status_effect = TABLE:get('status_effect')
	local status_effect_type = self:getStatusEffectTypeFromSkillTable(t_skill)
	local l_status_effect_str = {t_skill['status_effect_1'], t_skill['status_effect_2']}
	
	-- 1. 발동 조건 확인 (발동되지 않을 경우 리턴)\
	-- 기획 이슈로 제거

	-- 2. skill의 타겟룰로 passive의 대상 리스트를 얻어옴
	local l_target = char:getTargetList(t_skill)

	-- 3. 타겟 대상에 passive생성
	local idx = 1
	local effect_str = nil
	local t_effect = nil
	local type = nil 
	local target_type = nil 
	local duration = nil
	local rate = nil
	local value_1 = nil
	local value_2 = nil
	local t_status_effect = {}

	while true do 
		-- 1. 파싱할 구문 가져오고 탈출 체크
		effect_str = l_status_effect_str[idx]
		if (not effect_str) or (effect_str == 'x') then 
			break 
		end

		-- 2. 파싱하여 규칙에 맞게 분배
		t_effect = stringSplit(effect_str, ';')
		type = t_effect[1]
		target_type = t_effect[2]
		duration = t_effect[3]
		rate = t_effect[4] 
		value_1 = t_effect[5]
		--value_2 = t_effect[4]
		
		t_status_effect = table_status_effect[type]
					
		-- 3. 타겟 리스트 순회하며 상태효과 걸어준다.
		if (target_type == 'self') then 
			StatusEffectHelper:invokeStatusEffect(char, type, value_1, rate, duration)

			local world = char.m_world
			-- 발동된 패시브의 연출을 위해 world에 발동된 passive정보를 저장
			if (not world.m_lPassiveEffect[char]) then
				world.m_lPassiveEffect[char] = {}
			end
			table.insert(world.m_lPassiveEffect[char], t_status_effect['t_name'])

		elseif (target_type == 'target') then 
			for _, target in ipairs(l_target) do
				StatusEffectHelper:invokeStatusEffect(target, type, value_1, rate, duration)

				local world = target.m_world
				-- 발동된 패시브의 연출을 위해 world에 발동된 passive정보를 저장
				if (not world.m_lPassiveEffect[target]) then
					world.m_lPassiveEffect[target] = {}
				end
				table.insert(world.m_lPassiveEffect[target], t_status_effect['t_name'])
			end
		end

		-- 4. 인덱스 증가
		idx = idx + 1
	end
end

-------------------------------------
-- function checkPassiveActivation
-- @brief 발동조건을 체크하여 활성화된 패시브인지 확인한다. 
-------------------------------------
function StatusEffectHelper:checkPassiveActivation(char, chance_value, t_status_effect)
	if (chance_value == 'none') then
		return true
	elseif (chance_value == 'front') then
		if (char:getFormationMgr():getFormation(char.pos.x, char.pos.y) == FORMATION_FRONT) then 
			return true
		end
	elseif (chance_value == 'middle') then
		if (char:getFormationMgr():getFormation(char.pos.x, char.pos.y) == FORMATION_MIDDLE) then 
			return true
		end
	elseif (chance_value == 'rear') then
		if (char:getFormationMgr():getFormation(char.pos.x, char.pos.y) == FORMATION_REAR) then 
			return true
		end
	elseif (string.find(chance_value, 'attr')) then
		local attr = t_status_effect['val_1']
		local goal = t_status_effect['val_2']
		local match_count = 0

		-- characterlist 순회
		-- @TODO list 가져오는것 수정해야함
		for i, character in pairs(char.m_world.m_lDragonList) do
			if (character:getAttribute() == attr) then
				match_count = match_count + 1
			end
			if (match_count >= goal) then
				-- 조건 달성 시
				return true
			end
		end
	else
		error('정의 되지 않은 패시브 발동 조건 : ' .. chance_value)
	end

	return false
end

-------------------------------------
-- function invokeStatusEffectForDev
-- @brief
-------------------------------------
function StatusEffectHelper:invokeStatusEffectForDev(char, res)
    -- 상태 효과 생성
    local status_effect = StatusEffect(res)

    -- 시간 지정
    status_effect.m_duration = 5
    status_effect.m_durationTimer = 5

    status_effect.m_owner = char
    status_effect.m_statusEffectName = 'burn'

    -- 객체 생성
    local world = char.m_world
    world.m_worldNode:addChild(status_effect.m_rootNode, 10)
    world:addToUnitList(status_effect)

	char:insertStatusEffect(status_effect)

	status_effect:initState()
    status_effect:changeState('start')
end

-------------------------------------
-- function releaseStatusEffect
-- @brief 특정 타입의 상태효과 해제
-------------------------------------
function StatusEffectHelper:releaseStatusEffect(char, t_status_effect_str)
    -- 타입 있는지 검사
    if (not status_effect_type) or (status_effect_type == 'x') then return end

	-- 피격자가 사망했을 경우 리턴
    if (char.m_bDead == true) then return end

	-- 특정 타입 해제
	local idx = 1
	while true do 
		local effect_str = t_status_effect_str[idx]
		if (not effect_str) or (effect_str == 'x') then 
			break 
		end
		
		local t_effect = stringSplit(effect_str, ';')
		local status_effect_type = t_effect[1]

		-- @TODO 타입명 말고 phys_key로 해제하려면... 해제 주체가 status effect 에 있어야 하는데 아닌 경우도 있어 임시로 처리
		for type, tar_status_effect in pairs(char:getStatusEffectList()) do
			if (status_effect_type == type) then 
				tar_status_effect:changeState('end')
				char:removeStatusEffect(tar_status_effect)
				break
			end
		end

		idx = idx + 1
	end
end

-------------------------------------
-- function releaseHarmfulStatusEffect
-- @brief 해로운 상태효과 해제
-------------------------------------
function StatusEffectHelper:releaseHarmfulStatusEffect(char)
	-- 피격자가 사망했을 경우 리턴
    if (char.m_bDead == true) then return end

	-- 해제
	for type, status_effect in pairs(char:getStatusEffectList()) do
		if isExistValue(status_effect.m_type, 'debuff', 'cc', 'dot_dmg') then 
			status_effect:changeState('end')
			break
		end
	end
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
-- function getStatusEffectTypeFromSkillTable
-- @brief 상태효과 타입 파싱해서 가져옴
-------------------------------------
function StatusEffectHelper:getStatusEffectTypeFromSkillTable(t_skill)
	local effect_str = t_skill['status_effect_1']
	if (not effect_str) or (effect_str == 'x') then 
		return nil 
	end
	local t_effect = stringSplit(effect_str, ';')
	local status_effect_type = t_effect[1]

	return status_effect_type
end