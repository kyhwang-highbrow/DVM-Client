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
        m_cooldownTimer = 'number', -- 쿨타임 시간 저장용

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
    self.m_cooldownTimer = 0

	self.m_tAddedValue = nil
end

-------------------------------------
-- function update
-------------------------------------
function DragonSkillIndivisualInfo:update(dt)
    -- TODO: 차후 드래그 스킬 쿨타임도 여기서 처리될 수 있도록 수정해야할듯...
    if (self.m_skillType == 'active') then return end

    -- indie_time 타이머
    if (self.m_timer > 0) then
        self.m_timer = self.m_timer - dt

        if (self.m_timer <= 0) then
            self.m_timer = 0
        end
    end
    
    -- 스킬 쿨타임
    if (self.m_cooldownTimer > 0) then
        self.m_cooldownTimer = self.m_cooldownTimer - dt

        if (self.m_cooldownTimer <= 0) then
            self.m_cooldownTimer = 0
        end
    end
end

-------------------------------------
-- function startCoolTime
-------------------------------------
function DragonSkillIndivisualInfo:startCoolTime()
    self.m_cooldownTimer = self.m_tSkill['cooldown'] or 0
end

-------------------------------------
-- function isEndCoolTime
-------------------------------------
function DragonSkillIndivisualInfo:isEndCoolTime()
    return (self.m_cooldownTimer == 0)
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
-- function mergeSkillInfo
-- @brief 성룡 강화의 경우 기존 스킬 info를 가져와서 합쳐버린다...!
-------------------------------------
function DragonSkillIndivisualInfo:mergeSkillInfo(other_skill_info)
	if not (other_skill_info) then
		return
	end

	if (self:getSkillType() ~= other_skill_info:getSkillType()) then
		error('강화될 스킬과 성룡 강화 스킬의 타입이 다르다.')
	end

	local other_t_skill = other_skill_info:getSkillTable()
	for column, value in pairs(self.m_tSkill) do
		
		local other_value = other_t_skill[column]


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
    return IDragonSkillManager:getSkillDescPure(self.m_tSkill)
end

-------------------------------------
-- function getSkillID
-------------------------------------
function DragonSkillIndivisualInfo:getSkillID()
    return self.m_skillID
end

-------------------------------------
-- function getSkillName
-------------------------------------
function DragonSkillIndivisualInfo:getSkillName()
    return Str(self.m_tSkill['t_name'])
end

-------------------------------------
-- function getSkillLevel
-------------------------------------
function DragonSkillIndivisualInfo:getSkillLevel()
    return self.m_skillLevel
end

-------------------------------------
-- function getSkillLevel
-------------------------------------
function DragonSkillIndivisualInfo:getSkillType()
    return self.m_skillType
end

-------------------------------------
-- function getSkillTable
-------------------------------------
function DragonSkillIndivisualInfo:getSkillTable()
    return self.m_tSkill
end



