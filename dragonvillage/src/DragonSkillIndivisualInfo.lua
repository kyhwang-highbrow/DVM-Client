-------------------------------------
-- class DragonSkillIndivisualInfo
-- @TODO Individual로 수정 예정
-------------------------------------
DragonSkillIndivisualInfo = class({
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

	self.m_tAddedValue = nil
end

-------------------------------------
-- function applySkillLevel
-------------------------------------
function DragonSkillIndivisualInfo:applySkillLevel()
	local skill_id = self.m_skillID
    local table_skill = TABLE:get(self.m_charType .. '_skill')

    if (not table_skill[skill_id]) then
        error('존재하지 않는 skill_id ' .. skill_id)
    end

    -- 값이 변경되므로 복사해서 사용
    self.m_tSkill = clone(table_skill[skill_id])
	
	-- 필요한 데이터 선언
	local t_skill = self.m_tSkill
	local skill_lv = self.m_skillLevel

	-- 레벨이 반영된 데이터 계산
	local _, t_add_value = IDragonSkillManager:applySkillLevel(t_skill, skill_lv)
	self.m_tAddedValue = t_add_value
end

-------------------------------------
-- function insertAddValue
-- @brief 액티브 강화의 경우 기본 액티브의 레벨로 증가한 수치를 가져와 적용
-------------------------------------
function DragonSkillIndivisualInfo:insertAddValue(t_add_value)
	if not (self.m_skillType == 'active') then
		return 
	end
	if not (t_add_value) then
		return
	end

	-- 스킬을 덮어씌울때 덮어씌워진 스킬의 레벨 옵션을 그대로 갖고와 적용시킨다.
	local t_skill = self.m_tSkill
	for column, value in pairs(t_add_value) do
		self.m_tSkill[column] = self.m_tSkill[column] + value
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

-------------------------------------
-- function getSkillLevel
-------------------------------------
function DragonSkillIndivisualInfo:getSkillType()
    local skill_type = self.m_skillType
    return skill_type
end




