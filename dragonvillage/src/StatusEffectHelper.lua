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
        StatusEffectHelper:invokeStatusEffect(defender, type, value, rate)
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
		elseif (target_type == 'ally') then 
			-- @TODO 피아 구분해서 가져오도록..
			local ally = owner.m_world:getDragonList()
			for _, target in pairs(ally) do
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
	local status_effect_type = self:getStatusEffectTypeFromSkillTable(t_skill, 1)
    local t_status_effect = table_status_effect[status_effect_type] or {}
    
    local res = t_status_effect['res']
    if (res == 'x') then res = nil end

	local status_effect = nil
	local trigger_name = t_skill['chance_value'] or 'undergo_attack'
	local event_function = nil

	-- 클래스 종류가 다른 경우
	if (status_effect_type == 'passive_add_attack') then
        status_effect = StatusEffect_addAttack(res)
	elseif (status_effect_type == 'passive_spatter') then
        status_effect = StatusEffect_PassiveSpatter(res)
		char.m_world:addToUnitList(status_effect)
	else
		status_effect = StatusEffect_Trigger(res)
	end
	
	-- @TODO trigger function을 여기서 전달할건지 클래스로 파일을 분리할건지..
	-- 트리거로 발동될 함수 개별 설정
	if (t_skill['type'] == 'skill_summon_die') then
		event_function = function()
			local mid = t_skill['val_1']
			local lv = t_skill['val_2']
			local dest = t_skill['val_3']
			local effect_res = t_skill['res_1']
			local pos_x = char.pos.x
			local pos_y = char.pos.y

			local enemy = char.m_world.m_waveMgr:spawnEnemy_dynamic(mid, lv, 'Appear', nil, dest, 0.5)
			enemy:setPosition(pos_x, pos_y)
			enemy:setHomePos(pos_x, pos_y)

			char.m_world:addInstantEffect(effect_res, 'idle', pos_x, pos_y)
		end
	elseif (t_skill['type'] == 'skill_trigger') then
		event_function = function()
			local skill_id = t_skill['sid']
			char:doSkill(skill_id, nil, nil, nil)
		end
	end
		
	-- 테이블에서 받아온 트리거 네임 설정	
	status_effect:init_trigger(char, trigger_name, event_function)

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
    if isExistValue(status_effect_type, 'passive_recovery', 'heal', 'heal_per_atk', 'tamer_heal') then
        status_effect = StatusEffect_Heal(res)
		status_effect:init_heal(char, t_status_effect, status_effect_value, duration)

	----------- 필드 체크 필요한 패시브 ------------------
	elseif (status_effect_type == 'passive_bloodlust') then
		status_effect = StatusEffect_CheckWorld(res)
		status_effect:init_checkWorld(char, 'bleed') 
		
	----------- 도트 데미지 들어가는 패시브 ------------------
	elseif (t_status_effect['type'] == 'dot_dmg') then
		status_effect = StatusEffect_DotDmg(res)
		status_effect:init_dotDmg(char, t_status_effect)

	----------- HP 보호막 ------------------
	elseif (status_effect_type == 'barrier_protection') then
		status_effect = StatusEffect_Protection(res)
		local shield_hp = char.m_maxHp * (t_status_effect['val_1'] / 100)
		status_effect:init_buff(char, shield_hp)

	----------- 특이한 해제 조건을 가진 것들 ------------------
	elseif isExistValue(status_effect_type, 'sleep') then
		status_effect = StatusEffect_Trigger_Release(res)
		status_effect:init_trigger(char, 'undergo_attack', nil)
	
	----------- 침묵 ------------------
	elseif (status_effect_type == 'silence') then
		status_effect = StatusEffect_Silence(res)
		status_effect:init_status(char)

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
		for i, character in pairs(char.m_world:getDragonList()) do
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
-- function getStatusEffectTableFromSkillTable
-- @brief 상태효과 파싱하여 테이블화
-------------------------------------
function StatusEffectHelper:getStatusEffectTableFromSkillTable(t_skill, idx)
	local effect_str = t_skill['status_effect_' .. idx]
	if (not effect_str) or (effect_str == 'x') then 
		return {}
	end
	return stringSplit(effect_str, ';')
end

-------------------------------------
-- function getStatusEffectTypeFromSkillTable
-- @brief 상태효과 타입 파싱해서 가져옴
-------------------------------------
function StatusEffectHelper:getStatusEffectTypeFromSkillTable(t_skill, idx)
	local t_effect = self:getStatusEffectTableFromSkillTable(t_skill, idx)
	return t_effect[1]
end

-------------------------------------
-- function parsingStatusEffectStr
-- @brief 상태효과 타입 파싱해서 가져옴
-------------------------------------
function StatusEffectHelper:parsingStatusEffectStr(l_status_effect_str, idx)
	local effect_str = l_status_effect_str[idx]
	if (not effect_str) or (effect_str == 'x') then 
		return nil 
	end
	local t_effect = stringSplit(effect_str, ';')

	return t_effect
end