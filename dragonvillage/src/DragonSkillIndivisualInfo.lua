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
		m_tAddedValue = 'table',
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

	self.m_tAddedValue = {}
end

-------------------------------------
-- function applySkillLevel
-------------------------------------
function DragonSkillIndivisualInfo:applySkillLevel(t_add_value)
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
		if (modify_column) then

			-- 소수점 3째자리까지 계산
			local modify_value_unit = SkillHelper:getValid(t_skill['mod_max_val_' .. idx]) / 69
			modify_value_unit = math_floor(modify_value_unit * 1000)
			modify_value_unit = modify_value_unit / 1000

			local tar_data = SkillHelper:getValid(t_skill[modify_column])
			if (tar_data) then
				local add_value = (modify_value_unit * (skill_lv - 1))
				tar_data = tar_data + add_value
				self.m_tAddedValue[modify_column] = add_value
			end

			-- 레벨 계산된 값으로 치환
			t_skill[modify_column] = tar_data
		end
	end

	-- 스킬을 덮어씌울때 덮어씌워진 스킬의 레벨 옵션을 그대로 갖고와 적용시킨다.
	if (t_add_value) then
		for column, value in pairs(t_add_value) do
			t_skill[column] = t_skill[column] + value
		end
		self.m_tAddedValue = t_add_value
	end
end

-------------------------------------
-- function applySkillDesc
-- @brief desc column에서 수정할 column명을 가져와 대체하는 함수를 호출한다.
-------------------------------------
function DragonSkillIndivisualInfo:applySkillDesc()
	IDragonSkillManager:substituteSkillDesc(self.m_tSkill)
end

-------------------------------------
-- function getSkillDesc
-------------------------------------
function DragonSkillIndivisualInfo:getSkillDesc()
    local skill_desc = IDragonSkillManager:getSkillDescPure(self.m_tSkill)
    return skill_desc
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





