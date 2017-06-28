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
				self:addListener(skill_type, self)
			end
		end
	end

	-- 기본적으로 등록되어야 할 이벤트들
	--self:addListener('get_debuff', self) -- 테이머만 사용중
	self:addListener('stat_changed', self)
end

-------------------------------------
-- function onEvent
-------------------------------------
function Character:onEvent(event_name, t_event, ...)
	if (event_name == 'under_atk_rate') then
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
		self:onEvent_updateStat()

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

	if (table.count(self.m_lSkillIndivisualInfo['under_atk_rate']) > 0) then
    end
end


-------------------------------------
-- function onEvent_underAtkTurn
-------------------------------------
function Character:onEvent_underAtkTurn()
    if (not self.m_lSkillIndivisualInfo['under_atk_turn']) then return end
    if (not self.m_statusCalc) then return end

	local under_atk_cnt = self.m_charLogRecorder:getLog('under_atk')
	local campare_cnt
	
	for i,v in pairs(self.m_lSkillIndivisualInfo['under_atk_turn']) do
        if (v:isEndCoolTime()) then
            campare_cnt = v.m_tSkill['chance_value']
		    -- mod를 사용하여 판별
		    if (under_atk_cnt > 0) and (under_atk_cnt%campare_cnt == 0) then
			    local skill_id = v.m_skillID
                self:doSkill(skill_id, 0, 0)
            end
        end
    end	
	
	if (table.count(self.m_lSkillIndivisualInfo['under_atk_turn']) > 0) then
    end
end

-------------------------------------
-- function onEvent_underSelfHp
-------------------------------------
function Character:onEvent_underSelfHp(hp, max_hp)
    if (not self.m_lSkillIndivisualInfo['under_self_hp']) then return end
    if (not self.m_statusCalc) then return end

    local percentage = (hp / max_hp) * 100

    for i, v in pairs(self.m_lSkillIndivisualInfo['under_self_hp']) do
        if (v:isEndCoolTime()) then
            if (percentage <= v.m_tSkill['chance_value']) then
                self:doSkill(v.m_skillID, 0, 0)
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
function Character:onEvent_updateStat()
	if (not self.m_statusCalc) then return end

	-- 체력 버프 발동시 실시간 변화
	if (self:getStat('hp') ~= self.m_maxHp) then
		local max_hp = self:getStat('hp')
		local curr_hp_percent = self.m_hp/self.m_maxHp
		self.m_maxHp = max_hp
		self.m_hp = max_hp * curr_hp_percent
	end
end

-------------------------------------
-- function onEvent_common
-------------------------------------
function Character:onEvent_common(event_name)
    if (not self.m_lSkillIndivisualInfo['event_name']) then return end
    if (not self.m_statusCalc) then return end

    if (not self.m_lSkillIndivisualInfo[event_name]) then
        return
    end

    for i, v in pairs(self.m_lSkillIndivisualInfo[event_name]) do
        if (v:isEndCoolTime()) then
            local rand = math_random(1, 100)
            if (rand <= v.m_tSkill['chance_value']) then
                self:doSkill(v.m_skillID, 0, 0)
            end
        end
    end
end