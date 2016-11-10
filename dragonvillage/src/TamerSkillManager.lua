-------------------------------------
-- class TamerSkillManager
-------------------------------------
TamerSkillManager = class({
		m_world = 'GameWorld',
		m_charType = 'tamer',
		m_charTable = 'table',

		m_skill_list = 'list',
     })

-------------------------------------
-- function init
-------------------------------------
function TamerSkillManager:init(tamer_id, world)
    local table_tamer = TABLE:get('tamer')
    local t_tamer = table_tamer[tamer_id]

	self.m_charType = 'tamer'
	self.m_charTable = t_tamer
	self.m_world = world
	self.m_skill_list = {}
	self:setSkillSET()
end

-------------------------------------
-- function setSkillSET
-------------------------------------
function TamerSkillManager:setSkillSET()
	local t_tamer = self.m_charTable
	local table_tamer_skill = TABLE:get('tamer_skill')

	local skill_id = nil
	local t_skill = nil 
	local idx = 1

	while true do
		-- 1. skill_id 검증 및 탈출 조건 체크
		skill_id = t_tamer['skill_' .. idx] 
		if (not skill_id) or (skill_id == 0) or (skill_id == 'x') then
			break
		end
		-- 2. skill table 검증
		t_skill = table_tamer_skill[skill_id]
		if t_skill then
			table.insert(self.m_skill_list, t_skill)
		end
		-- 3. idx 증가 및 순회
		idx = idx + 1
	end
end


-------------------------------------
-- function getTargetList
-- @TODO 정리해야함!
-------------------------------------
function TamerSkillManager:getTargetList(t_skill)
	local world = self.m_world

	local target_team = t_skill['target_logic1']
	local target_stat = t_skill['target_logic2']
	local target_calc = t_skill['target_logic3']
	local target_cnt = 1

	-- 1. 아군 or 적군 or 전체
	local l_target = nil
	if (target_team == 'friend') then
		l_target = world:getCharList('ally')
	elseif (target_team == 'enemy') then
		l_target = world:getCharList('enemy')
	elseif (target_team == 'all') then
		l_target = table.merge(world:getCharList('ally'), world:getCharList('enemy'))
		target_cnt = 5
	else
		error('테이머 스킬 대상 로직1이 잘못되었습니다. 확인해주세요\nid : ' .. t_skill['id'] .. ' target logic : ' .. target_team)
	end

	-- 2. 타겟의 기준 status 가 x라면 이후 로직도 볼 필요 없으므로 리턴
	if (target_stat == 'x') then
		return l_target
	end

	-- 3. 선별
	table.sort(l_target, function(a,b)
		if (target_stat == 'hp') then
			if (target_calc == 'max') then
				return a.m_hp > b.m_hp
			else
				return a.m_hp < b.m_hp
			end
		
		else
			local a_stat = a.m_statusCalc:getFinalStat(target_stat)
			local b_stat = b.m_statusCalc:getFinalStat(target_stat)
			if (target_calc == 'max') then
				return a_stat > b_stat
			else
				return a_stat < b_stat
			end
		end

	end)

	-- 4. 제한 숫자 만큼 고름
	local l_target_ret = {}
	for i = 1, target_cnt do
		table.insert(l_target_ret, l_target[i])
	end

	return l_target_ret
end

-------------------------------------
-- function doTamerSkill
-------------------------------------
function TamerSkillManager:doTamerSkill(skill_idx)
	local t_skill = self.m_skill_list[skill_idx]

	if (t_skill['form'] == 'status_effect') then 
		-- 1. target 설정
		local l_target = self:getTargetList(t_skill)

		if (not l_target) then return end

		-- 2. 타겟 대상에 상태효과생성
		local idx = 1
		local effect_str = nil
		local t_effect = nil
		local type = nil 
		local duration = nil
		local value_1 = nil
		local value_2 = nil
		local rate = 100

		while true do 
			-- 1. 파싱할 구문 가져오고 탈출 체크
			effect_str = t_skill['effect'..idx]
			if (not effect_str) or (effect_str == 'x') then 
				break 
			end

			-- 2. 파싱하여 규칙에 맞게 분배
			t_effect = stringSplit(effect_str, ';')
			type = t_effect[1]
			duration = t_effect[2]
			value_1 = t_effect[3]
			--value_2 = t_effect[4]
			
			-- 3. 타겟 리스트 순회하며 상태효과 걸어준다.
			for _,target in ipairs(l_target) do
				StatusEffectHelper:doStatusEffect_simple(target, type, value_1, rate, duration)
			end

			-- 4. 인덱스 증가
			idx = idx + 1
		end

	elseif (t_skill['form'] == 'code') then
		
		-- 1. code 형 스킬은 하나의 필드만 참조 
		local effect_str = t_skill['effect1']
		if (not effect_str) or (effect_str == 'x') then 
			return
		end

		-- 2. 파싱하여 규칙에 맞게 분배
		local t_effect = stringSplit(effect_str, ';')
		local type = t_effect[1]
		local value_1 = t_effect[2]
		
		-- 3. 추가 필요한 변수
		local world = self.m_world
		local res = t_skill['res']

		if (type == 'sum_atk') then
			TamerSpecialSkillCombination:makeSkillInstance(res, self.m_world, value_1)
		end

	else
		cclog('미구현 테이머 스킬 : ' .. t_skill['id'] .. ' / ' .. t_skill['t_name'])
		return false
	end

	return true
end
