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
    if (defender:isDead()) then
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
function StatusEffectHelper:doStatusEffect(caster, l_skill_target, type, target_type, target_count, duration, rate, value, source, cb_invoke, skill_id, add_param)
    local l_ret = {} -- 상태효과가 적용된 대상 리스트
 
    -- 스킬로 부터 받은 타겟 리스트 사용
	if (target_type == 'target') then
        if (not l_skill_target) then
            error('doStatusEffect no l_skill_target')
        end

        local l_target = l_skill_target
        for _, target in ipairs(l_target) do
			if (StatusEffectHelper:invokeStatusEffect(caster, target, type, value, source, rate, duration, skill_id, add_param)) then
                table.insert(l_ret, target)

                if (cb_invoke) then
                    cb_invoke(target)
                end
            end
		end

    elseif (target_type == 'target_random') then
        if(not l_skill_target) then
            error('doStatusEffect no l_skill_target')
        end

        local l_target = l_skill_target
        l_target = table.sortRandom(l_target)
        l_target = table.getPartList(l_target, target_count)

        for _, target in ipairs(l_target) do
            if (StatusEffectHelper:invokeStatusEffect(caster, target, type, value, source, rate, duration, skill_id, add_param)) then
                table.insert(l_ret, target)

                if (cb_invoke) then
                    cb_invoke(target)
                end
            end
        end

	-- 별도의 계산된 타겟 리스트 사용
	elseif (target_type) then
        local t_status_effect = TableStatusEffect():get(type)
        local status_effect_group = t_status_effect['type']
        local l_target = {}

        -- 부활의 경우는 죽은 대상들로부터 타겟 리스트를 설정
        if (status_effect_group == 'resurrect') then
            local target_count = tonumber(target_count) or 1
            l_target = caster:getTargetListByType('teammate_dead', target_count)
            
        -- 좀비의 경우는 죽기 직전 대상들로부터 타겟 리스트를 설정
        elseif (status_effect_group == 'zombie') then
            if (target_type == 'self') then
                l_target = { caster }

            else
                for _, target_char in pairs(caster:getFellowList()) do
                    if (not target_char:isDead() and target_char.m_hp == 0 and not target_char.m_isZombie) then
                        table.insert(l_target, target_char)
                    end
                end

            end
            
        else
            if (target_type == 'self') then
                target_count = 1
            end

            l_target = caster:getTargetListByType(target_type, target_count)

        end
                
        for _, target in ipairs(l_target) do
			if (StatusEffectHelper:invokeStatusEffect(caster, target, type, value, source, rate, duration, skill_id, add_param)) then
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
function StatusEffectHelper:doStatusEffectByTable(char, t_skill, cb_func, t_data)
	-- 1. skill의 타겟룰로 상태효과의 대상 리스트를 얻어옴
	local l_target = char:getTargetListByTable(t_skill, t_data)
			
	-- 2. 상태효과 구조체
	local l_status_effect_struct = SkillHelper:makeStructStatusEffectList(t_skill)
			
	-- 3. 타겟에 상태효과생성
	StatusEffectHelper:doStatusEffectByStruct(char, l_target, l_status_effect_struct, cb_func, t_skill['sid'])
end

-------------------------------------
-- function doStatusEffectByStruct
-- @brief 별도의 타겟을 받아와서 외부에서 상태효과 구조체 생성하여 상태효과 시전
-------------------------------------
function StatusEffectHelper:doStatusEffectByStruct(caster, l_skill_target, l_status_effect_struct, cb_invoke, skill_id, add_param)
    -- 시전자가 사망했을 경우 리턴
    if (caster:isDead()) then return end

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
	local value = nil
		
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
            duration, rate, value, source, cb_invoke, skill_id, add_param)

		-- 4. 인덱스 증가
		idx = idx + 1
	end
end

-------------------------------------
-- function invokeStatusEffect
-- @brief 상태 효과 발동
-------------------------------------
function StatusEffectHelper:invokeStatusEffect(caster, target_char, status_effect_type, status_effect_value, status_effect_source, status_effect_rate, duration, skill_id, add_param)
    -- status effect validation
	if (not status_effect_type) or (status_effect_type == '') then
        return nil
    end

	local t_status_effect = TableStatusEffect():get(status_effect_type)
	local status_effect_category = t_status_effect['category']
    local world = target_char.m_world

    -- 전투 중 검사
    if (self:isHarmful(status_effect_category) and not world.m_gameState:isFight()) then
        return nil
    end

    -- status_effect_rate 검사
    if (self:checkRate(caster, target_char, status_effect_rate, add_param)) then
        return nil
    end

	-- 효과 적중 및 효과 저항 검사
	if (self:checkStatus(caster, target_char, status_effect_category)) then
		return nil
	end

	-- 면역 효과
	if (self:isHarmful(status_effect_category) and target_char:isImmuneSE()) then 
        target_char:makeImmuneFont(target_char.pos['x'], target_char.pos['y'], 1.5)
		return nil
	end

    -- 보스의 경우 cc타입의 상태효과는 면역 처리
    if (target_char:isBoss() and t_status_effect['type'] == 'cc') then
        target_char:makeImmuneFont(target_char.pos['x'], target_char.pos['y'], 1.5)
        return nil
    end

    -- 적용값(status_effect_value)이 수식인 경우 수식을 계산
    if (type(status_effect_value) == 'function') then
        status_effect_value = status_effect_value(caster, target_char, add_param)
    else
        status_effect_value = tonumber(status_effect_value)
    end

    local status_effect = target_char:getStatusEffect(status_effect_type, true)
    if (status_effect) then
        -- 상태 효과 중첩 혹은 갱신
        local duration = tonumber(duration) or tonumber(t_status_effect['duration'])
        status_effect:addOverlabUnit(caster, skill_id, status_effect_value, status_effect_source, duration, add_param)
    else
        -- 상태 효과 생성
		status_effect = StatusEffectHelper:makeStatusEffectInstance(caster, target_char, status_effect_type, status_effect_value, status_effect_source, duration, skill_id, add_param)
    end
    
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
-- function makeStatusEffectInstance
-- @comment 일반 status effect의 경우 rate가 필요없지만 패시브의 경우 실행 시점에서 확률체크하는 경우가 있다.
-------------------------------------
function StatusEffectHelper:makeStatusEffectInstance(caster, target_char, status_effect_type, status_effect_value, status_effect_source, duration, skill_id, add_param)
    local t_status_effect = TableStatusEffect():get(status_effect_type)
    if (not t_status_effect) then
        error('no status_effect table : ' .. status_effect_type)
    end

    local status_effect_group = t_status_effect['type']
    local status_effect = nil
	local res = TableStatusEffect():getRes(status_effect_type, caster:getAttribute())

    ----------- 상태효과 변경 ------------------
	if (status_effect_group == 'transfer') then
        status_effect = StatusEffect_Transfer(res)

    ----------- 상태효과 변경 ------------------
	elseif (status_effect_group == 'modify') then
        status_effect = StatusEffect_Modify(res)

    ---------- 부활 ------------
    elseif (status_effect_group == 'resurrect') then
        status_effect = StatusEffect_Resurrect(res)

    ---------- 좀비 ------------
    elseif (status_effect_group == 'zombie') then
        status_effect = StatusEffect_Zombie(res)

    ---------- 불사 ------------
    elseif (status_effect_group == 'immortal') then
        status_effect = StatusEffect_Immortal(res)

    ----------- 마나 관련 ----------------------
    elseif (status_effect_group == 'add_mana') then
        status_effect = StatusEffect_AddMana(res)
        status_effect:init_status(status_effect_value)

    elseif (status_effect_group == 'mana_reduce') then
        status_effect = StatusEffect_ManaReduce(res)
        status_effect:init_status(status_effect_value)

    elseif (status_effect_group == 'accel_mana') then
        status_effect = StatusEffect_AccelMana(res)

    ---------- 조건부 버프 ---------------------
    elseif (status_effect_group == 'conditional_buff') then
        status_effect = StatusEffect_ConditionalBuff(res)

    ---------- 조건부로 스탯 변경 (공격시/피격시 등) ----------------------
    elseif (status_effect_group == 'modify_dmg') then
        status_effect = StatusEffect_ConditionalModify(res)

    ----------- 보호막 ------------------
	elseif (status_effect_group == 'barrier') then
		status_effect = StatusEffect_Protection(res)

    elseif (status_effect_group == 'barrier_time') then
        status_effect = StatusEffect_ProtectionByTime(res)

    ------------ 도트 --------------------------
    elseif (status_effect_group == 'dot_dmg') then
        local dot_dmg_type = t_status_effect['val_1']

        if (dot_dmg_type == 'bleed') then
            status_effect = StatusEffect_Bleed(res)
	    elseif (dot_dmg_type == 'poison') then
            status_effect = StatusEffect_Poison(res)
        else
		    status_effect = StatusEffect(res)
        end
        status_effect:setOverlabClass(StatusEffectUnit_Dot_Damage)

    elseif (status_effect_group == 'dot_heal') then
        status_effect = StatusEffect(res)
        status_effect:setOverlabClass(StatusEffectUnit_Dot_Heal)
        		
	----------- 디버프 해제 ------------------
    elseif (status_effect_group == 'dispell') then
		status_effect = StatusEffect_Dispell(res)
		status_effect:init_status(status_effect_type, status_effect_value)

    ----------- 군중 제어기 ------------------
    elseif (status_effect_group == 'cc') then
        -- 침묵
	    if (status_effect_type == 'silence') then
		    status_effect = StatusEffect_Silence(res)

        -- 수면 
        elseif (status_effect_type == 'sleep') then
            status_effect = StatusEffect_Sleep(res)

        else
            status_effect = StatusEffect(res)
        end

    ----------- 중첩을 소모하는 추가 미사일 ----------------------
    elseif (status_effect_group == 'consume_missile') then
        status_effect = StatusEffect_ConsumeToMissile(res)

        -- 해당 상태효과를 유발한 스킬의 충돌 정보 리스트를 가져옴
        local l_collision = add_param['skill_collision_list']
        status_effect:init_statusEffect(caster, l_collision)

    ----------- 추가 피해 ------------------
	elseif (status_effect_group == 'add_dmg') then
		status_effect = StatusEffect(res)
        status_effect:setName(status_effect_type)
        status_effect:setOverlabClass(StatusEffectUnit_AddDmg)

    elseif (status_effect_group == 'add_dmg_one_time') then
		status_effect = StatusEffect_AddDmgOneTime(res)
        status_effect:init_statusEffect(caster)
        status_effect:setOverlabClass(StatusEffectUnit_AddDmgOneTime)

    ----------- 속성 변경 ------------------
	elseif (status_effect_type == 'attr_change') then
		--@TODO 카운터 속성으로 변경, 추후 정리
		status_effect = StatusEffect_AttributeChange(res)
		status_effect:init_statusEffect(target_char)

    else
        status_effect = StatusEffect(res)
    end

    local world = target_char.m_world

    -- 초기값 설정
    status_effect:initWorld(world)
    status_effect:initFromTable(t_status_effect, target_char)

    -- 타켓에게 status_effect 저장
	target_char:insertStatusEffect(status_effect)

    -- 객체 생성
    world.m_missiledNode:addChild(status_effect.m_rootNode, 1)
    world:addToUnitList(status_effect)

    status_effect:changeState('start')

    -- 시간 지정 (skill table 에서 받아와서 덮어씌우거나 status effect table 값 사용)
    local duration = tonumber(duration) or tonumber(t_status_effect['duration'])

    -----------------------------------------------------------------
    -- StatusEffectUnit 생성 및 추가
    status_effect:addOverlabUnit(caster, skill_id, status_effect_value, status_effect_source, duration, add_param)

    return status_effect
end

-------------------------------------
-- function checkRate
-------------------------------------
function StatusEffectHelper:checkRate(caster, target_char, status_effect_rate, add_param)
    local rate

    if (type(status_effect_rate) == 'function') then
        rate = status_effect_rate(caster, target_char, add_param)
    else
        rate = tonumber(status_effect_rate or 100)
    end
    rate = math_max(rate, 0)

    return (math_random(1, 100) > rate)
end

-------------------------------------
-- function checkStatus
-- 스텟(효과 적중, 효과 저항)으로 적용 여부 판단
-------------------------------------
function StatusEffectHelper:checkStatus(caster, target_char, status_effect_category)
	local is_harmful = self:isHarmful(status_effect_category)
	
	-- @ RUNE
	local accuracy = caster:getStat('accuracy')
	local resistance = 0
	if (is_harmful) then
		resistance = target_char:getStat('resistance')
	end

	-- 확률 permill 로 체크
	local adj_rate = CalcAccuracyChance(accuracy, resistance)
	return (math_random(1, 100) > adj_rate)
end

-------------------------------------
-- function releaseStatusEffect
-- @brief 특정 타입의 상태효과 해제
-------------------------------------
function StatusEffectHelper:releaseStatusEffectByType(char, status_effect_type)
    -- 타입 있는지 검사
    if (not status_effect_type) or (status_effect_type == '') then return end

	-- 특정 타입 해제
	-- @TODO 타입명 말고 phys_key로 해제하려면... 해제 주체가 status effect 에 있어야 하는데 아닌 경우도 있어 임시로 처리
	for type, tar_status_effect in pairs(char:getStatusEffectList()) do
		if (status_effect_type == type) then 
			tar_status_effect:changeState('end')
            tar_status_effect:setTemporaryPause(false)
			break
		end
	end
end

-------------------------------------
-- function releaseStatusEffectDebuff
-- @brief n개의 debuff 상태효과 해제
-- @return 해제 여부 boolean
-------------------------------------
function StatusEffectHelper:releaseStatusEffectDebuff(char, max_release_cnt, status_effect_name)
	local max_release_cnt = max_release_cnt or 32
	local release_cnt = 0

    if (not status_effect_name) then
	    -- 해제
	    for type, status_effect in pairs(char:getStatusEffectList()) do
            -- 해로운 효과 해제
		    if (status_effect.m_bHarmful) then
		        status_effect:changeState('end')
            	status_effect:setTemporaryPause(false)
			    release_cnt = release_cnt + 1
            end
		    -- 갯수 체크
		    if (release_cnt >= max_release_cnt) then
			    break
		    end
	    end

    else
        for type, status_effect in pairs(char:getStatusEffectList()) do
            -- 해로운 효과 해제
            if (status_effect.m_bHarmful) then
                if(status_effect_name == status_effect.m_statusEffectName) then
                    status_effect:changeState('end')
            		status_effect:setTemporaryPause(false)
			        release_cnt = release_cnt + 1
                end
            end
            -- 갯수 체크
		    if (release_cnt >= max_release_cnt) then
			    break
		    end
        end
    end 

	return (release_cnt > 0)
end

-------------------------------------
-- function releaseStatusEffectBuff
-- @brief n개의 buff 상태효과 해제
-- @return 해제 여부 boolean
-------------------------------------
function StatusEffectHelper:releaseStatusEffectBuff(char, max_release_cnt, status_effect_name)
	local max_release_cnt = max_release_cnt or 32
	local release_cnt = 0

    if (not status_effect_name) then
        -- 해제
        for type, status_effect in pairs(char:getStatusEffectList()) do
            -- 이로운 효과 해제
	        if self:isHelpful(status_effect.m_category) then 
		        status_effect:changeState('end')
                status_effect:setTemporaryPause(false)
		        release_cnt = release_cnt + 1
            end
	        -- 갯수 체크
	        if (release_cnt >= max_release_cnt) then
		        break
	        end
        end
    else 
        -- 해제
        for type, status_effect in pairs(char:getStatusEffectList()) do
            -- 이로운 효과 해제
	        if self:isHelpful(status_effect.m_category) then 
                if(status_effect_name == status_effect.m_statusEffectName) then
                    status_effect:changeState('end')
                    status_effect:setTemporaryPause(false)
			        release_cnt = release_cnt + 1
                end
            end
	        -- 갯수 체크
	        if (release_cnt >= max_release_cnt) then
		        break
	        end
        end


    end
	return (release_cnt > 0)
end

-------------------------------------
-- function releaseStatusEffectAll
-- @brief 모든 상태효과 해제
-------------------------------------
function StatusEffectHelper:releaseStatusEffectAll(char)
	-- 해제
	for type, status_effect in pairs(char:getStatusEffectList()) do
        status_effect:changeState('end')
	end
end

-------------------------------------
-- function isHarmful
-- @breif 해로운 효과
-- @param param_1 은 statuseffect 의 'category'이나 statuseffect객체 자체
-------------------------------------
function StatusEffectHelper:isHarmful(param_1)
	local status_effect_category

	if (type(param_1) == 'string') then
		status_effect_category = param_1
	elseif (isInstanceOf(param_1, StatusEffect)) then
		status_effect_category = param_1.m_category
	end

	return (status_effect_category == 'bad')
end

-------------------------------------
-- function isHelpful
-- @breif 이로운 효과
-- @param param_1 은 statuseffect 의 'category'이나 statuseffect객체 자체
-------------------------------------
function StatusEffectHelper:isHelpful(param_1)
	local status_effect_category

	if (type(param_1) == 'string') then
		status_effect_category = param_1
	elseif (isInstanceOf(param_1, StatusEffect)) then
		status_effect_category = param_1.m_category
	end

	return (status_effect_category == 'good')
end


-------------------------------------
-- function isHidden
-- @breif 해제되지 않고 계속 유지되며 별도의 표시가 없는 상태효과(리더스킬 or 패시브 스킬)인지 여부 체크
-------------------------------------
function StatusEffectHelper:isHidden(effect_name)
    return (string.find(effect_name, 'leader') or string.find(effect_name, 'passive'))
end