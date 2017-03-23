-------------------------------------
-- function initTriggerListener
-- @brief 이벤트 처리 해야하는 스킬 등록
-------------------------------------
function Character:initTriggerListener()
	-- @TODO dragonskillmanager를 다중 상속함을 가정....

	for skill_type, t_individual_info in pairs(self.m_lSkillIndivisualInfo) do
		-- 이벤트 처리 할 가능성이 없는 스킬 타입 제외
		if not isExistValue(skill_type, 'active', 'basic', 'touch') then
			-- 존재 여부는 갯수로 체크
			if (table.count(t_individual_info) > 0) then
				self:addListener(skill_type, self)
			end
		end
	end
end

-------------------------------------
-- function onEvent
-------------------------------------
function Character:onEvent(event_name, t_event, ...)
	if (event_name == 'under_atk_rate') then
		self:onEvent_underAtkRate()

	elseif (event_name == 'under_atk_turn') then
		self:onEvent_underAtkTurn()

	else
		cclog(event_name)
	end
end

-------------------------------------
-- function onEvent_underAtkRate
-------------------------------------
function Character:onEvent_underAtkRate()
	local sum_random = SumRandom()

    for i,v in pairs(self.m_lSkillIndivisualInfo['under_atk_rate']) do
        local rate = (v.m_tSkill['chance_value'] * 100)
        local skill_id = v.m_skillID
        sum_random:addItem(rate, skill_id)
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
	local under_atk_cnt = self.m_charLogRecorder:getLog('under_atk')
	local campare_cnt
	
	for i,v in pairs(self.m_lSkillIndivisualInfo['under_atk_turn']) do
        campare_cnt = v.m_tSkill['chance_value']
		-- mod를 사용하여 판별
		if (under_atk_cnt > 0) and (under_atk_cnt%campare_cnt == 0) then
			local skill_id = v.m_skillID
            self:doSkill(skill_id, 0, 0)
        end
    end	
	
	if (table.count(self.m_lSkillIndivisualInfo['under_atk_turn']) > 0) then
    end
end
