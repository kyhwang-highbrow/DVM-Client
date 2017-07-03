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
    local skill_id = activity_carrier:getSkillId()

    for type, t_content in pairs(activity_carrier.m_lStatusEffectRate) do
		local value = t_content['value']
		local rate = t_content['rate']
        local source = t_content['source']
        local duration = t_content['duration']
        StatusEffectHelper:invokeStatusEffect(attacker, defender, type, value, source, rate, duration, skill_id)
    end
end

-------------------------------------
-- function doStatusEffect
-- @brief 해당 파라미터의 정보로 상태효과를 시전하고 대상자 리스트를 리턴
-------------------------------------
function StatusEffectHelper:doStatusEffect(caster, l_skill_target, type, target_type, target_count, duration, rate, value, source, cb_invoke, skill_id)
    local l_ret = {} -- 상태효과가 적용된 대상 리스트
 
    -- 스킬로 부터 받은 타겟 리스트 사용
	if (target_type == 'target') then
        if (not l_skill_target) then
            error('doStatusEffectByStruct no l_skill_target')
        end

        local l_target = l_skill_target
        for _, target in ipairs(l_target) do
			if (StatusEffectHelper:invokeStatusEffect(caster, target, type, value, source, rate, duration, skill_id)) then
                table.insert(l_ret, target)

                if (cb_invoke) then
                    cb_invoke(target)
                end
            end
		end

    elseif (target_type == 'target_random') then
        if(not l_skill_target) then
            error('doStatusEffectByStruct no l_skill_target')
        end

        local l_target = l_skill_target
        l_target = table.sortRandom(l_target)
        l_target = table.getPartList(l_target, target_count)

        for _, target in ipairs(l_target) do
            if (StatusEffectHelper:invokeStatusEffect(caster, target, type, value, source, rate, duration, skill_id)) then
                table.insert(l_ret, target)

                if (cb_invoke) then
                    cb_invoke(target)
                end
            end
        end

	-- 별도의 계산된 타겟 리스트 사용
	elseif (target_type) then
		local l_target = caster:getTargetListByType(target_type, target_count)
        for _, target in ipairs(l_target) do
			if (StatusEffectHelper:invokeStatusEffect(caster, target, type, value, source, rate, duration, skill_id)) then
                table.insert(l_ret, target)

                if (cb_invoke) then
				    cb_invoke(target)
                end
			end
		end
	end

    return l_ret
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
	StatusEffectHelper:doStatusEffectByStruct(char, l_target, l_status_effect_struct, cb_func, t_skill['sid'])
end

-------------------------------------
-- function doStatusEffectByStruct
-- @brief 별도의 타겟을 받아와서 외부에서 상태효과 구조체 생성하여 상태효과 시전
-------------------------------------
function StatusEffectHelper:doStatusEffectByStruct(caster, l_skill_target, l_status_effect_struct, cb_invoke, skill_id)
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
        target_count = status_effect_struct.m_targetCount
        trigger = status_effect_struct.m_trigger
		duration = status_effect_struct.m_duration
		rate = status_effect_struct.m_rate
		value = status_effect_struct.m_value
        source = status_effect_struct.m_source
		
        -- 3. 타겟 리스트 순회하며 상태효과 걸어준다.
        self:doStatusEffect(caster, l_skill_target, type, target_type, target_count,
            duration, rate, value, source, cb_invoke, skill_id)

		-- 4. 인덱스 증가
		idx = idx + 1
	end
end

-------------------------------------
-- function invokeStatusEffect
-- @brief 상태 효과 발동
-------------------------------------
function StatusEffectHelper:invokeStatusEffect(caster, target_char, status_effect_type, status_effect_value, status_effect_source, status_effect_rate, duration, skill_id)
    -- status effect validation
	if (not status_effect_type) or (status_effect_type == '') then
        return nil
    end

	local t_status_effect = TableStatusEffect():get(status_effect_type)
	local status_effect_group = t_status_effect['type']

	-- 확률 검사
	if self:checkPermillRate(caster, target_char, status_effect_rate, status_effect_group) then
		return nil
	end

	-- 면역 효과
	if (target_char:isImmuneSE() and self:isHarmful(status_effect_group)) then 
		return nil
	end

    local status_effect = target_char:getStatusEffect(status_effect_type)
    if (status_effect) then
        -- 상태 효과 중첩 혹은 갱신
        local duration = tonumber(duration) or tonumber(t_status_effect['duration'])
        status_effect:addOverlabUnit(caster, skill_id, status_effect_value, status_effect_source, duration)
    else
        -- 상태 효과 생성
		status_effect = StatusEffectHelper:makeStatusEffectInstance(caster, target_char, status_effect_type, status_effect_value, status_effect_source, status_effect_rate, duration, skill_id)
    end

	return status_effect
end

-------------------------------------
-- function makeStatusEffectInstance
-- @comment 일반 status effect의 경우 rate가 필요없지만 패시브의 경우 실행 시점에서 확률체크하는 경우가 있다.
-------------------------------------
function StatusEffectHelper:makeStatusEffectInstance(caster, target_char, status_effect_type, status_effect_value, status_effect_source, status_effect_rate, duration, skill_id)
    -- 테이블 가져옴
	local table_status_effect = TableStatusEffect()
    local t_status_effect = table_status_effect:get(status_effect_type)
    local category = t_status_effect['type']

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
        
        if (status_effect_type == 'feedback_supporter') then
            status_effect = StatusEffect(res)
        elseif (status_effect_type == 'feedback_healer') then
            status_effect = StatusEffect(res)
            status_effect:setOverlabClass(StatusEffectUnit_Dot_Heal)
        else
            status_effect = StatusEffect(res)
        end

	------------ 도트 --------------------------
    elseif (status_effect_type == 'burn') then
		status_effect = StatusEffect(res)
        status_effect:setOverlabClass(StatusEffectUnit_Dot_Damage)

    elseif isExistValue(status_effect_type, 'passive_recovery') or
		(category == 'dot_heal' and string.find(status_effect_type, 'heal')) then
        status_effect = StatusEffect(res)
        status_effect:setOverlabClass(StatusEffectUnit_Dot_Heal)
        		
	----------- 트리거 ------------------
	elseif (status_effect_type == 'bleed') then
        status_effect = StatusEffect_Bleed(res)
        
	elseif (status_effect_type == 'poison') then
        status_effect = StatusEffect_Poison(res)

    elseif (status_effect_type == 'immortal') then
        status_effect = StatusEffect_Immortal(res)

    elseif (status_effect_type == 'zombie') then
        status_effect = StatusEffect_Zombie(res)

	----------- HP 보호막 ------------------
	elseif (status_effect_type == 'barrier_protection') then
		status_effect = StatusEffect_Protection(res)
	
	----------- 데미지 경감 보호막 ------------------
	elseif isExistValue(status_effect_type, 'resist', 'barrier_protection_darknix') then
		status_effect = StatusEffect_Resist(res)
		
	----------- 디버프 해제 ------------------
	elseif isExistValue(status_effect_type, 'cure', 'remove', 'invalid') then
		status_effect = StatusEffect_Dispell(res)
		status_effect:init_status(status_effect_type, status_effect_value)

	----------- 특이한 해제 조건을 가진 것들 ------------------
	elseif isExistValue(status_effect_type, 'sleep') then
		status_effect = StatusEffect_Sleep(res)
	
	----------- 침묵 ------------------
	elseif (status_effect_type == 'silence') then
		status_effect = StatusEffect_Silence(res)
	
	----------- 속성 변경 ------------------
	elseif (status_effect_type == 'attr_change') then
		--@TODO 카운터 속성으로 변경, 추후 정리
		status_effect = StatusEffect_AttributeChange(res)
		status_effect:init_statusEffect(target_char)

	----------- 조건부 추가 데미지 ------------------
	elseif string.find(status_effect_type, 'add_dmg') then
		status_effect = StatusEffect(res)
        status_effect:setName(status_effect_type)
        status_effect:setOverlabClass(StatusEffectUnit_AddDmg)

    else
        status_effect = StatusEffect(res)
    end

    -- 초기값 설정
    status_effect:initFromTable(t_status_effect, target_char)

    -- 타켓에게 status_effect 저장
	target_char:insertStatusEffect(status_effect)

    -- 객체 생성
    local world = target_char.m_world
    world.m_missiledNode:addChild(status_effect.m_rootNode, 1)
    world:addToUnitList(status_effect)

    status_effect:changeState('start')

    -- 시간 지정 (skill table 에서 받아와서 덮어씌우거나 status effect table 값 사용)
    local duration = tonumber(duration) or tonumber(t_status_effect['duration'])

    -----------------------------------------------------------------
    -- StatusEffectUnit 생성 및 추가
    status_effect:addOverlabUnit(caster, skill_id, status_effect_value, status_effect_source, duration)

    -- 해로운 상태효과 걸렸을 시
	if (self:isHarmful(status_effect)) then
        -- @EVENT 
		local t_event = clone(EVENT_STATUS_EFFECT)
		t_event['char'] = target_char
		t_event['status_effect_name'] = status_effect.m_statusEffectName
		target_char:dispatch('get_debuff', t_event)
	end

    return status_effect
end

-------------------------------------
-- function checkPermillRate
-------------------------------------
function StatusEffectHelper:checkPermillRate(caster, target_char, status_effect_rate, status_effect_group)
	local is_harmful = self:isHarmful(status_effect_group)
	
	-- @ RUNE
	local se_acc = caster:getStat('accuracy')
	local se_resist
	if (is_harmful) then
		se_resist = target_char:getStat('resistance')
	else
		se_resist = 0
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
    if (char.m_bDead) then return end

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
    if (char.m_bDead) then return end

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
    if (char.m_bDead) then return end

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