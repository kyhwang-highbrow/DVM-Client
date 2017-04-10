-------------------------------------
-- class DragonSkillIndivisualInfo
-- @TODO Individual로 수정 예정
-------------------------------------
DragonSkillIndivisualInfo = class({
        m_idx = 'number',       -- 스킬 순번
        m_charType = 'string',  -- 캐릭터 타입 'dragon', 'monster'
        m_skillID = 'number',   -- 스킬 ID
        m_skillType = 'string',
        m_tSkill = 'table',     -- 스킬 테이블
        m_turnCount = 'number', -- 턴 공격 횟수 저장용
        m_timer = 'number',     -- 타임 공격 저장용

        m_skillLevel = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function DragonSkillIndivisualInfo:init(char_type, skill_type, skill_id, skill_level)
    self.m_charType = char_type
    self.m_skillType = skill_type
    self.m_skillID = skill_id
    self.m_skillLevel = (skill_level or 1)
    self.m_turnCount = 0
    self.m_timer = 0
end

-------------------------------------
-- function applySkillLevel
-------------------------------------
function DragonSkillIndivisualInfo:applySkillLevel()
	local skill_id = self.m_skillID
    local table_skill = TABLE:get(self.m_charType .. '_skill')

    if (not table_skill[skill_id]) then
        error('skill_id ' .. skill_id)
    end

    -- 값이 변경되므로 복사해서 사용
    self.m_tSkill = clone(table_skill[skill_id])
	
	-- 레벨이 반영된 데이터 계산
	local t_skill = self.m_tSkill
	local skill_lv = self.m_skillLevel
	for idx = 1, 5 do
		local modify_column = SkillHelper:getValid(t_skill['mod_col_' .. idx])
		local modify_value = SkillHelper:getValid(t_skill['mod_val_' .. idx])
		
		if (modify_column) then
			local tar_data = SkillHelper:getValid(t_skill[modify_column])

			if (tar_data) then
				tar_data = tar_data + (modify_value * (skill_lv - 1))
			end

			-- 레벨 계산된 값으로 치환
			t_skill[modify_column] = tar_data
		end
	end
end

-------------------------------------
-- function applySkillDesc
--@brief desc column에서 수정할 column명을 가져와 대체
-------------------------------------
function DragonSkillIndivisualInfo:applySkillDesc()
	local t_skill = self.m_tSkill

	for idx = 1, 5 do
		local raw_data = t_skill['desc_' .. idx]
		local desc_value

		-- 1. 연산이 필요한지 확인하고 필요하다면 연산하여 산출
		if string.find(raw_data, '[*+/-]') then
			local operator = string.match(raw_data, '[*+/-]')
			local l_parsed = seperate(raw_data, operator)

			-- 숫자가 들어갔을 경우도 고려되어있다.
			local column_name_1 = trim(l_parsed[1])
			local value_1
			if (tonumber(column_name_1)) then
				value_1 = column_name_1
			else
				value_1 = t_skill[column_name_1]
			end

			-- 숫자가 들어갔을 경우도 고려되어있다.
			local column_name_2 = trim(l_parsed[2])
			local value_2
			if (tonumber(column_name_2)) then
				value_2 = column_name_2
			else
				value_2 = t_skill[column_name_2]
			end

			-- 연산자에 따른 실제 연산 실행
			if (operator == '*') then
				desc_value = value_1 * value_2
			elseif (operator == '/') then
				desc_value = value_1 / value_2
			elseif (operator == '+') then
				desc_value = value_1 + value_2
			elseif (operator == '-') then
				desc_value = value_1 - value_2
			end
		
		-- 2. 단순 숫자라면 그대로 추출
		elseif (type(raw_data) == 'number') then
			desc_value = raw_data

		-- 3. 이외는 column명으로 가정하고 테이블에서 추출
		else
			desc_value =  t_skill[raw_data]
		end

		-- 4. 실제 들어가야할 숫자로 치환
		t_skill['desc_' .. idx] = desc_value
	end
end

-------------------------------------
-- function getSkillID
-------------------------------------
function DragonSkillIndivisualInfo:getSkillID()
    local skill_id = self.m_skillID
    return skill_id
end

-------------------------------------
-- function getSkillName
-------------------------------------
function DragonSkillIndivisualInfo:getSkillName()
    local name = Str(self.m_tSkill['t_name'])
    return name
end

-------------------------------------
-- function getSkillLevel
-------------------------------------
function DragonSkillIndivisualInfo:getSkillLevel()
    local skill_level = self.m_skillLevel
    return skill_level
end



-------------------------------------
-- function getSkillDesc
-------------------------------------
function DragonSkillIndivisualInfo:getSkillDesc()
    local skill_desc = IDragonSkillManager:getSkillDescPure(self.m_tSkill)
    return skill_desc
end

