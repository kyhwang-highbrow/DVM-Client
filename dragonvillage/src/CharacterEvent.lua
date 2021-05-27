-------------------------------------
-- function initTriggerListener
-- @brief 이벤트 처리 해야하는 스킬 등록
-------------------------------------
function Character:initTriggerListener()
	-- @TODO dragonskillmanager를 다중 상속함을 가정....

    -- 설정된 드래곤 스킬 정보로부터 등록이 필요한 이벤트 리스트를 얻어와서 등록
    local l_trigger = self:getDragonSkillTriggerList()

    for _, trigger in ipairs(l_trigger) do
        self:addListener(trigger, self)
    end

	-- 기본적으로 등록되어야 할 이벤트들
	self:addListener('stat_changed', self)
end

-------------------------------------
-- function onEvent
-------------------------------------
function Character:onEvent(event_name, t_event, ...)
    if (event_name == 'dead') then
		self:onEvent_dead(t_event)

    elseif (self:isDead()) then
        

	elseif (event_name == 'under_atk_rate') then
		self:onEvent_underAtkRate()

	elseif (event_name == 'under_atk_turn') then
		self:onEvent_underAtkTurn()

    elseif (event_name == 'under_self_hp') then
        local hp = t_event['hp']
        local max_hp = t_event['max_hp']

		self:onEvent_underSelfHp(hp, max_hp)

    elseif (event_name == 'under_ally_hp') then
        local hp = t_event['hp']
        local max_hp = t_event['max_hp']

        self:onEvent_underAllyHp(hp, max_hp)

    elseif (event_name == 'under_teammate_hp') then
        local hp = t_event['hp']
        local max_hp = t_event['max_hp']
        local arg = {...}
        local owner = arg[1]

        self:onEvent_underTeammateHp(hp, max_hp, owner)
    
	elseif (event_name == 'stat_changed') then
		self:onEvent_updateStat(t_event)

    elseif (event_name == 'enemy_last_attack') then
        self:onEvent_lastAttack(event_name, t_event)

    elseif (pl.stringx.endswith(event_name, '_active_skill')) then
        local arg = {...}
        local owner = arg[1]
        self:onEvent_useActiveSkill(event_name, t_event, owner)

    elseif (pl.stringx.endswith(event_name, 'get_status_effect')) then
        local arg = {...}
        local target = arg[1]
        
        local target_string = event_name:sub(1, event_name:find('_'))
        self:onEvent_getStatusEffect(t_event, target_string, target)

    elseif (event_name == 'teammate_dead') then
        local arg = {...}
        local died_unit = arg[1]

        -- 부활 스킬을 별도로 처리하기 위함...
        self:onEvent_teammateDead(event_name, t_event, died_unit)

    else
        self:onEvent_common(event_name)

	end
end

-------------------------------------
-- function onEvent_underAtkRate
-------------------------------------
function Character:onEvent_underAtkRate()
    local list = self:getSkillIndivisualInfo('under_atk_rate')

    if (not list) then return end
    if (not self.m_statusCalc) then return end

	local sum_random = SumRandom()

    for i,v in pairs(list) do
        if (v:isEndCoolTime()) then
            local rate = v:getChanceValue()
            local skill_id = v.m_skillID
            sum_random:addItem(rate, skill_id)
        end
    end

    local remain_rate = math_max(0, (100 - sum_random.m_rateSum))
    sum_random:addItem(remain_rate, 0)

    local skill_id = sum_random:getRandomValue()
    if (skill_id ~= 0) then
        self:doSkill(skill_id, 0, 0)
    end
end


-------------------------------------
-- function onEvent_underAtkTurn
-------------------------------------
function Character:onEvent_underAtkTurn()
    local list = self:getSkillIndivisualInfo('under_atk_turn')

    if (not list) then return end
    if (not self.m_statusCalc) then return end

	for i, v in pairs(list) do
        if (v:isEndCoolTime()) then
            v.m_curChanceValue = v.m_curChanceValue + 1

            if (v.m_curChanceValue >= v:getChanceValue()) then
                self:doSkill(v.m_skillID, 0, 0)
            end
        end
    end	
end

-------------------------------------
-- function onEvent_underSelfHp
-------------------------------------
function Character:onEvent_underSelfHp(hp, max_hp)
    if (not self.m_statusCalc) then return end

    local percentage = (hp / max_hp) * 100

    do
        local list = self:getSkillIndivisualInfo('under_self_hp') or {}

        for i, v in ipairs(list) do
            if (v:isEndCoolTime()) then
                if (percentage <= v:getChanceValue()) then
                    -- 롤백이 필요할 수도 있음
                    if (SEQUENTIAL_PERFECT_BARRIER == true) then 
                        -- 무적 스킬의 경우 바로 발동하지 않고 발동될 스킬 정보를 return
                        if (not v:hasPerfectBarrier()) then self:doSkill(v.m_skillID, 0, 0) end
                    else
                        -- chance_value값(ex)무적 50%, 생존 30%)이 다른 스킬은 동시에 발동 안됨 skill_1 skill_2 chance value 같으면 둘다 발동함
                        local is_diff_chance_value = self:isDiffChanceValue(v.m_skillID)
                        if (is_diff_chance_value) then break end
                        self:doSkill(v.m_skillID, 0, 0)
                    end
                end
            end
        end
    end

    if (not self:isZeroHp()) then
        local list = self:getSkillIndivisualInfo('under_self_hp_alive') or {}

        for i, v in pairs(list) do
            if (v:isEndCoolTime()) then
                if (percentage <= v:getChanceValue()) then
                    -- 롤백이 필요할 수도 있음
                    if (SEQUENTIAL_PERFECT_BARRIER == true) then 
                        -- 무적 스킬의 경우 바로 발동하지 않고 발동될 스킬 정보를 return
                        if (not v:hasPerfectBarrier()) then self:doSkill(v.m_skillID, 0, 0) end
                    else
                        self:doSkill(v.m_skillID, 0, 0)
                    end
                end
            end
        end
    end
end

-------------------------------------
-- function onEvent_underAllyHp
-------------------------------------
function Character:onEvent_underAllyHp(hp, max_hp)
    local list = self:getSkillIndivisualInfo('under_ally_hp')

    if (not list) then return end
    if (not self.m_statusCalc) then return end

    local percentage = (hp / max_hp) * 100

    for i, v in pairs(list) do
        if (v:isEndCoolTime()) then
            if (percentage <= v:getChanceValue()) then
                -- 롤백이 필요할 수도 있음
                if (SEQUENTIAL_PERFECT_BARRIER == true) then
                    if (not v:hasPerfectBarrier()) then self:doSkill(v.m_skillID, 0, 0) end
                else
                    self:doSkill(v.m_skillID, 0, 0)
                end
            end
        end
    end
end

function Character:doPerfectBarrierSkill(t_event)
    local hp = t_event['hp']
    local max_hp = t_event['max_hp']
    local l_possible_perfect_barrier_skill = {}

    local func_insert = function(l_list)
        l_possible_perfect_barrier_skill = table.merge(l_possible_perfect_barrier_skill, l_list)
    end

    -- 현재 hp로 발동되는 나의 무적 스킬을 리스트에 추가
    func_insert(self:checkPerfectBarrierSkill(self, hp, max_hp, 'under_self_hp'))
    if (not self:isZeroHp()) then
        func_insert(self:checkPerfectBarrierSkill(self, hp, max_hp, 'under_self_hp_alive'))
    end
    
    -- 현재 hp로 발동되는 동료의 무적 스킬 리스트에 추가
    for _, fellow in pairs(self:getFellowList()) do
        func_insert(fellow:checkPerfectBarrierSkill(self, hp, max_hp, 'under_ally_hp'))
        if (self ~= fellow) then
            func_insert(fellow:checkPerfectBarrierSkill(self, hp, max_hp, 'under_teammate_hp'))
        end
    end

    local l_list = l_possible_perfect_barrier_skill
    -- 발동할 스킬이 없다면 탈출
    if (#l_list == 0) then
        return
    end
    
    -- chance_value 순서로 정렬
    local func_sort = function(a, b)
        return a['chance_value'] > b['chance_value']
    end
    table.sort(l_list, func_sort)

    if (IS_TEST_MODE()) then
        cclog('********************************************************')
        cclog(string.format('%s(%s) 의 체력이 %d %%', self:getName(), dragonAttributeName(self:getAttribute()), (hp/max_hp)*100))

        if (l_list and #l_list > 0) then cclog('↓↓↓ 적용 및 대기중인 무적스킬 리스트 ↓↓↓') end

        for i, v in ipairs(l_list) do
            cclog(string.format('%d. %s(%s) 의 스킬 : %s chance_value : %d', i, v['skill_owner']:getName(), dragonAttributeName(v['skill_owner']:getAttribute()), TableDragonSkill():getSkillName(v['skill_id']), v['chance_value']))
        end
        cclog('********************************************************')
    end

    -- 첫번째 무적 스킬만 발동
    local possible_perfect_barrier_skill = l_list[1]
    if (possible_perfect_barrier_skill) then
        local skill_owner = possible_perfect_barrier_skill['skill_owner']
        local skill_id = possible_perfect_barrier_skill['skill_id']
        local is_do_skill = skill_owner:doSkill(skill_id, 0, 0)
    end
end

-------------------------------------
-- function checkPerfectBarrierSkill
-------------------------------------
function Character:checkPerfectBarrierSkill(owner, hp, max_hp, type)
    local list = self:getSkillIndivisualInfo(type)

    if (not list) then return end
    if (not self.m_statusCalc) then return end

    local percentage = (hp / max_hp) * 100
    local l_list = {}

    for i, v in pairs(list) do
        if (v:isEndCoolTime()) then
            if (percentage <= v:getChanceValue()) then
                if (v:hasPerfectBarrier()) then       
                    l_list[v.m_skillID] = {['skill_owner'] = self, ['chance_value'] = v:getChanceValue(), ['skill_id'] = v.m_skillID}
                end
            end
        end
    end

    return l_list
end

-------------------------------------
-- function onEvent_underTeammateHp
-------------------------------------
function Character:onEvent_underTeammateHp(hp, max_hp, unit)
    local list = self:getSkillIndivisualInfo('under_teammate_hp')

    if (not list) then return end
    if (not self.m_statusCalc) then return end

    local percentage = (hp / max_hp) * 100

    for i, v in ipairs(list) do
        if (v:isEndCoolTime()) then        
            if (percentage <= v:getChanceValue()) then
                -- 롤백이 필요할 수도 있음
                if (SEQUENTIAL_PERFECT_BARRIER == true) then
                    if (not v:hasPerfectBarrier()) then self:doSkill(v.m_skillID, 0, 0) end
                else
                    local is_diff_chance_value = unit:isDiffChanceValue(v.m_skillID)
                    if (is_diff_chance_value) then break end
                    self:doSkill(v.m_skillID, 0, 0)
                end
            end          
        end
    end
end

-------------------------------------
-- function onEvent_updateStat
-------------------------------------
function Character:onEvent_updateStat(t_event)
	if (not self.m_statusCalc) then return end

    if (t_event['hp']) then
        local new_max_hp = self:getStat('hp') * (self.m_statusCalc:getHiddenInfo('hp_multi') or 1)
        local game_state = self.m_world.m_gameState
        local is_start_buff = false -- 시작 버프 여부

        -- 시작 버프인지 체크
        if (self.m_world.m_gameMode == GAME_MODE_CLAN_RAID and game_state:isWaveInterMission()) then
            is_start_buff = true
        elseif (self.m_world.m_gameMode == GAME_MODE_COLOSSEUM and game_state:isWaveInterMission()) then
            is_start_buff = true
        elseif (self.m_world.m_gameMode == GAME_MODE_ARENA and game_state:isWaveInterMission()) then
            is_start_buff = true
        elseif (self.m_world.m_gameMode == GAME_MODE_ARENA_NEW and game_state:isWaveInterMission()) then
            is_start_buff = true
        elseif (self.m_world.m_gameMode == GAME_MODE_EVENT_ARENA and game_state:isWaveInterMission()) then
            is_start_buff = true
        elseif (self.m_world.m_gameMode == GAME_MODE_CHALLENGE_MODE and game_state:isWaveInterMission()) then
            is_start_buff = true
        elseif (self.m_world.m_waveMgr:isFirstWave() and game_state:isEnemyAppear()) then
            is_start_buff = true
        -- @kwkang 21-01-04 첫 웨이브가 아닌 웨이브에 나오는 적 드래곤의 경우 HP 패시브 버프가 올바르게 들어가지 않았던 현상 수정
        elseif ((t_event['is_boss']) and game_state:isEnemyAppear()) then
            is_start_buff = true
        end

        if (is_start_buff) then
            -- 시작 버프일 경우 체력 증가 버프에서 현재 체력값도 같이 증가시킴
		    local curr_hp_percent = self:getHpRate()
		    self.m_maxHp = new_max_hp
		    self.m_hp = new_max_hp * curr_hp_percent
        else
            -- 시작 버프가 아닐 경우 최대 체력만 증가시킴
            self.m_maxHp = new_max_hp
        end

        self:setHp(self.m_hp)
	end

    if (t_event['aspd']) then
        self:calcAttackPeriod(true)
    end
end

-------------------------------------
-- function onEvent_dead
-------------------------------------
function Character:onEvent_dead(t_event)
    local list = self:getSkillIndivisualInfo('dead')

    if (not list) then return end
    if (not self.m_statusCalc) then return end

    for i, v in pairs(list) do
        if (v:isEndCoolTime()) then
            local chance_value = v:getChanceValue()
            if ( (not chance_value) or (chance_value == '') ) then
                chance_value = 100
            end

            local rand = math_random(1, 100)
            if (rand <= chance_value) then
                self:doSkill(v.m_skillID, 0, 0)
            end
        end
    end
end

-------------------------------------
-- function onEvent_getStatusEffect
-------------------------------------
function Character:onEvent_getStatusEffect(t_event, target_str, target_char)
    -- no prefix, 상태 이상에 걸렸을 때
    if (target_str == 'get_') then
        local status_effect_name = 'get_status_effect'
        local list = self:getSkillIndivisualInfo(status_effect_name)
        if (not list) then return end
        if (not self.m_statusCalc) then return end

        for i, v in pairs(list) do
            if (v:isEndCoolTime()) then
                local chance_value = v:getChanceValue()

                -- 테이블 잘못 입력했을 때를 대비
                if (chance_value) then
                    local rand = math_random(1, 100)
                    if (rand <= chance_value) then
                        self:doSkill(v.m_skillID, 0, 0)
                    end
                else
                    cclog('chance_value is nil... Sending Crashlytics if exsists')
                    PerpleSdkManager.getCrashlytics():setExceptionLog('showAd_0')
                end
            end
        end
    -- target_str : self, ally, teammate, enemy
    else
        local status_effect_name = target_str .. 'get_status_effect'
        local list = self:getSkillIndivisualInfo(status_effect_name)

        if (not list) then return end
        if (not self.m_statusCalc) then return end

        for i, v in pairs(list) do
            if (v:isEndCoolTime()) then
                local status_effect = v:getChanceValue()
                local l_se = pl.stringx.split(status_effect, ';')
                local col, name = l_se[1], l_se[2]
                if (name == t_event[col]) then
                    self:doSkill(v.m_skillID, 0, 0)
                end
            end
        end
    end
end

-------------------------------------
-- function onEvent_lastAttack
-------------------------------------
function Character:onEvent_lastAttack(event_name, t_event)
    local list = self:getSkillIndivisualInfo(event_name)

    if (not list) then return end
    if (not self.m_statusCalc) then return end
    
    for i, v in pairs(list) do
        if (v:isEndCoolTime()) then
            local chance_value = v:getChanceValue()
            if ( (not chance_value) or (chance_value == '') ) then
                chance_value = 100
            end

            local rand = math_random(1, 100)
            if (rand <= chance_value) then
                self:doSkill(v.m_skillID, 0, 0, t_event)
            end

        end
    end
end

-------------------------------------
-- function onEvent_useActiveSkill
-------------------------------------
function Character:onEvent_useActiveSkill(event_name, t_event, owner)
    local list = self:getSkillIndivisualInfo(event_name)

    if (not list) then return end
    if (not self.m_statusCalc) then return end
    
    for i, v in pairs(list) do
        if (v:isEndCoolTime()) then
            if (self.m_bLeftFormation == owner.m_bLeftFormation) then
                local chance_value = v:getChanceValue()
                if ( (not chance_value) or (chance_value == '') ) then
                    chance_value = 1
                end
                local cost = owner:getSkillManaCost()
                if (cost == chance_value) then
                    self:doSkill(v.m_skillID, 0, 0)
                end
            end
        end
    end

end

-------------------------------------
-- function onEvent_teammateDead
-------------------------------------
function Character:onEvent_teammateDead(event_name, t_event, unit)
    local list = self:getSkillIndivisualInfo(event_name)

    if (not list) then return end
    if (not self.m_statusCalc) then return end
    
    for i, v in pairs(list) do
        if (v:isEndCoolTime()) then
            local b = true
            local t_data = {}

            -- 부활 스킬인 경우 이벤트 주체 대상이 있고 죽었을 경우만 발동
            if (v.m_tSkill['skill_type'] == 'skill_resurrect') then
                if (unit and unit:isDead() and unit.m_bPossibleRevive and not unit:hasStatusEffectToResurrect()) then
                    t_data = {
                        target = unit,
                        target_list = { unit }
                    }
                else
                    b = false
                end
            else
                local has_resurrect = false

                for i = 1, 4 do
                    if (v.m_tSkill['add_option_type_' .. i] == 'resurrect') then
                        has_resurrect = true
                        break
                    end
                end

                -- 부활 상태효과를 가지고 있다면 죽은 대상이 없을 경우 발동되지 않도록 처리
                if (has_resurrect) then
                    local l_dead = self.m_world:getDeadList(self)
                    if (#l_dead == 0) then
                        b = false
                    end
                end
            end

            if (b) then
                local chance_value = v:getChanceValue()
                if ( (not chance_value) or (chance_value == '') ) then
                    chance_value = 100
                end

                local rand = math_random(1, 100)
                if (rand <= chance_value) then
                    self:doSkill(v.m_skillID, 0, 0, t_data)
                end
            end
        end
    end
end

-------------------------------------
-- function onEvent_common
-------------------------------------
function Character:onEvent_common(event_name)
    local list = self:getSkillIndivisualInfo(event_name)

    if (not list) then return end
    if (not self.m_statusCalc) then return end
    
    for i, v in pairs(list) do
        if (v:isEndCoolTime()) then
            local chance_value = v:getChanceValue()
            if ( (not chance_value) or (chance_value == '') ) then
                chance_value = 100
            end

            local rand = math_random(1, 100)
            if (rand <= chance_value) then
                self:doSkill(v.m_skillID, 0, 0)
            end

        end
    end
end

-------------------------------------
-- function getChanceValue
-------------------------------------
function Character:getChanceValue(skill_id)
    local table_skill = GetSkillTable(self.m_charType)
    if (not table_skill) then
        return nil
    end
    
    local t_skill = table_skill:get(skill_id)
    if (not t_skill)then
        return nil
    end

    local chance_value = t_skill['chance_value']

    -- 발동 조건값(chance_value)이 수식인 경우 수식을 계산
    if (type(chance_value) == 'function') then
        chance_value = chance_value(self, nil, nil, skill_id)
    else
        chance_value = chance_value
    end

    return chance_value
end

-------------------------------------
-- function isDiffChanceValue
-------------------------------------
function Character:isDiffChanceValue(target_skill_id)
    local target_chance_value = self:getChanceValue(target_skill_id)

    for skill_type, status_effect_class in pairs(self.m_mStatusEffect) do
        if (status_effect_class) then
            if (status_effect_class.m_keep_value) then
                if (target_chance_value ~= status_effect_class.m_keep_value) then
                    return true
                end
            end
        end
    end

    return false
end
