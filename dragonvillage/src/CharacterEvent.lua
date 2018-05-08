-------------------------------------
-- function initTriggerListener
-- @brief 이벤트 처리 해야하는 스킬 등록
-------------------------------------
function Character:initTriggerListener()
	-- @TODO dragonskillmanager를 다중 상속함을 가정....

	for skill_type, t_individual_info in pairs(self.m_lSkillIndivisualInfo) do
		-- 이벤트 처리 할 가능성이 없는 스킬 타입 제외
		if not isExistValue(skill_type, 'active', 'basic', 'leader') then
			-- 존재 여부는 갯수로 체크
			if (table.count(t_individual_info) > 0) then
                if (skill_type == 'hp_rate_per_short') then
                    skill_type = 'under_self_hp'
                end
                
                self:addListener(skill_type, self)
			end
		end
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

        self:onEvent_underTeammateHp(hp, max_hp)
    
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
    else
        self:onEvent_common(event_name)

	end
end

-------------------------------------
-- function onEvent_underAtkRate
-------------------------------------
function Character:onEvent_underAtkRate()
    if (not self.m_lSkillIndivisualInfo['under_atk_rate']) then return end
    if (not self.m_statusCalc) then return end

	local sum_random = SumRandom()

    for i,v in pairs(self.m_lSkillIndivisualInfo['under_atk_rate']) do
        if (v:isEndCoolTime()) then
            local rate = v.m_tSkill['chance_value']
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
    if (not self.m_lSkillIndivisualInfo['under_atk_turn']) then return end
    if (not self.m_statusCalc) then return end

	for i, v in pairs(self.m_lSkillIndivisualInfo['under_atk_turn']) do
        if (v:isEndCoolTime()) then
            v.m_turnCount = v.m_turnCount + 1

            if (v.m_turnCount >= v.m_tSkill['chance_value']) then
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

    if (self.m_lSkillIndivisualInfo['under_self_hp']) then
        for i, v in pairs(self.m_lSkillIndivisualInfo['under_self_hp']) do
            if (v:isEndCoolTime()) then
                if (percentage <= v.m_tSkill['chance_value']) then
                    self:doSkill(v.m_skillID, 0, 0)
                end
            end
        end
    end

    if (self.m_lSkillIndivisualInfo['hp_rate_per_short']) then
        for i, v in pairs(self.m_lSkillIndivisualInfo['hp_rate_per_short']) do
            if (v:isEndCoolTime()) then
                if (percentage <= v.m_hpRate) then
                    v.m_hpRate = math_max(v.m_hpRate - v.m_tSkill['chance_value'], 0)

                    self:doSkill(v.m_skillID, 0, 0)
                end
            end
        end
    end
end

-------------------------------------
-- function onEvent_underAllyHp
-------------------------------------
function Character:onEvent_underAllyHp(hp, max_hp)
    if (not self.m_lSkillIndivisualInfo['under_ally_hp']) then return end
    if (not self.m_statusCalc) then return end

    local percentage = (hp / max_hp) * 100

    for i, v in pairs(self.m_lSkillIndivisualInfo['under_ally_hp']) do
        if (v:isEndCoolTime()) then
            if (percentage <= v.m_tSkill['chance_value']) then
                self:doSkill(v.m_skillID, 0, 0)
            end
        end
    end
end

-------------------------------------
-- function onEvent_underTeammateHp
-------------------------------------
function Character:onEvent_underTeammateHp(hp, max_hp)
    if (not self.m_lSkillIndivisualInfo['under_teammate_hp']) then return end
    if (not self.m_statusCalc) then return end

    local percentage = (hp / max_hp) * 100

    for i, v in pairs(self.m_lSkillIndivisualInfo['under_teammate_hp']) do
        if (v:isEndCoolTime()) then
            if (percentage <= v.m_tSkill['chance_value']) then
                self:doSkill(v.m_skillID, 0, 0)
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
        local new_max_hp = self:getStat('hp') * (self.m_statusCalc:getHiddenInto('hp_multi') or 1)
        local game_state = self.m_world.m_gameState
        local is_start_buff = false -- 시작 버프 여부

        -- 시작 버프인지 체크
        if (self.m_world.m_gameMode == GAME_MODE_CLAN_RAID and game_state:isWaveInterMission()) then
            is_start_buff = true
        elseif (self.m_world.m_gameMode == GAME_MODE_COLOSSEUM and game_state:isWaveInterMission()) then
            is_start_buff = true
        elseif (self.m_world.m_gameMode == GAME_MODE_ARENA and game_state:isWaveInterMission()) then
            is_start_buff = true
        elseif (self.m_world.m_waveMgr:isFirstWave() and game_state:isEnemyAppear()) then
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
    if (not self.m_lSkillIndivisualInfo['dead']) then return end
    if (not self.m_statusCalc) then return end

    for i, v in pairs(self.m_lSkillIndivisualInfo['dead']) do
        if (v:isEndCoolTime()) then
            local chance_value = v.m_tSkill['chance_value']
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
    local status_effect_name = target_str .. 'get_' .. 'status_effect'

    if (not self.m_lSkillIndivisualInfo[status_effect_name]) then return end
    if (not self.m_statusCalc) then return end

    for i, v in pairs(self.m_lSkillIndivisualInfo[status_effect_name]) do
        if (v:isEndCoolTime()) then

            local status_effect = v.m_tSkill['chance_value']
            local l_se = pl.stringx.split(status_effect, ';')
            local col, name = l_se[1], l_se[2]
            if (name == t_event[col]) then
                self:doSkill(v.m_skillID, 0, 0)
            end
        end
    end

end

-------------------------------------
-- function onEvent_lastAttack
-------------------------------------
function Character:onEvent_lastAttack(event_name, t_event)
    if (not self.m_statusCalc) then return end
    if (not self.m_lSkillIndivisualInfo[event_name]) then return end
    for i, v in pairs(self.m_lSkillIndivisualInfo[event_name]) do
        if (v:isEndCoolTime()) then
            local chance_value = v.m_tSkill['chance_value']
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

    if (not self.m_statusCalc) then return end
    if (not self.m_lSkillIndivisualInfo[event_name]) then return end

    for i, v in pairs(self.m_lSkillIndivisualInfo[event_name]) do
        if (v:isEndCoolTime()) then
            if (self.m_bLeftFormation == owner.m_bLeftFormation) then
                local chance_value = tonumber(v.m_tSkill['chance_value'])
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
-- function onEvent_common
-------------------------------------
function Character:onEvent_common(event_name)
    if (not self.m_statusCalc) then return end
    if (not self.m_lSkillIndivisualInfo[event_name]) then
        return
    end

    for i, v in pairs(self.m_lSkillIndivisualInfo[event_name]) do
        if (v:isEndCoolTime()) then
            local chance_value = v.m_tSkill['chance_value']
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
