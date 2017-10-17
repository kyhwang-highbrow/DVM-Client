-------------------------------------
-- class DragonSkillIndivisualInfo
-- @TODO Individual로 수정 예정
-------------------------------------
DragonSkillIndivisualInfo = class({
        m_className = '',
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
    self.m_className = 'DragonSkillIndivisualInfo'

    self.m_charType = char_type
    self.m_skillType = skill_type
    self.m_skillID = skill_id
    self.m_skillLevel = (skill_level or 1)
    self.m_turnCount = 0
    self.m_timer = 0
    self.m_cooldownTimer = 0

	self.m_tAddedValue = nil

    -- indie_time 타입의 스킬은 해당 값만큼 먼저 기다리도록 초기값 설정
    if (self.m_skillType == 'indie_time') then
        local t_skill = GetSkillTable(self.m_charType):get(self.m_skillID)
        self.m_timer = t_skill['chance_value']
    end
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
    if (not self.m_tSkill['cooldown'] or self.m_tSkill['cooldown'] == '') then
        self.m_cooldownTimer = 0
    else
        self.m_cooldownTimer = tonumber(self.m_tSkill['cooldown'])
    end

    if (self.m_skillType == 'indie_time') then
        self.m_timer = self.m_tSkill['chance_value']
    end
end

-------------------------------------
-- function isEndCoolTime
-------------------------------------
function DragonSkillIndivisualInfo:isEndCoolTime()
    if (self.m_skillType == 'indie_time') then
        return (self.m_cooldownTimer == 0 and self.m_timer == 0)
    else
        return (self.m_cooldownTimer == 0)
    end
end

-------------------------------------
-- function resetCoolTime
-------------------------------------
function DragonSkillIndivisualInfo:resetCoolTime()
    self.m_cooldownTimer = 0
end

-------------------------------------
-- function mergeSkillInfo
-- @brief 성룡 강화의 경우 기존 스킬 info를 가져와 레벨업된 부분만 합쳐버린다.
-------------------------------------
function DragonSkillIndivisualInfo:mergeSkillInfo(old_skill_info)
	if not (old_skill_info) then
		return
	end

	if (self:getSkillType() ~= old_skill_info:getSkillType()) then
		error('강화될 스킬과 성룡 강화 스킬의 타입이 다르다.')
	end

	DragonSkillCore.applyModification(self.m_tSkill, old_skill_info:getAddValueTable())
end

-------------------------------------
-- function applySkillLevel
-------------------------------------
function DragonSkillIndivisualInfo:applySkillLevel()
	local skill_id = self.m_skillID
    local t_skill = GetSkillTable(self.m_charType):get(skill_id)

    if (not t_skill) then
        error('존재하지 않는 skill_id ' .. skill_id)
    end

    -- 값이 변경되므로 복사해서 사용
    self.m_tSkill = clone(t_skill)
	
	-- 필요한 데이터 선언
	local t_skill = self.m_tSkill
	local skill_lv = self.m_skillLevel

	-- 레벨이 반영된 데이터 계산
	local _, t_add_value = DragonSkillCore.applySkillLevel(self.m_charType, t_skill, skill_lv)
	self.m_tAddedValue = t_add_value

    -- indie_time 타입의 스킬은 해당 값만큼 먼저 기다리도록 초기값 설정
    if (self.m_skillType == 'indie_time') then
        self.m_timer = self.m_tSkill['chance_value']
    end
end

-------------------------------------
-- function applySkillDesc
-- @brief desc column에서 수정할 column명을 가져와 대체하는 함수를 호출한다.
-------------------------------------
function DragonSkillIndivisualInfo:applySkillDesc()
	DragonSkillCore.substituteSkillDesc(self.m_tSkill)
end

-------------------------------------
-- function getSkillDesc
-------------------------------------
function DragonSkillIndivisualInfo:getSkillDesc()
    return DragonSkillCore.getSkillDescPure(self.m_tSkill)
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

-------------------------------------
-- function getAddValueTable
-------------------------------------
function DragonSkillIndivisualInfo:getAddValueTable()
    return self.m_tAddedValue
end

-------------------------------------
-- function isActivated
-------------------------------------
function DragonSkillIndivisualInfo:isActivated()
    return self.m_skillLevel > 0
end

-------------------------------------
-- function getCoolTime
-- @brief 순수한 의미의 쿨타임..
-------------------------------------
function DragonSkillIndivisualInfo:getCoolTime()
    local cooltime = self.m_tSkill['cooldown'] 

    -- 예외처리
    if (cooltime == '') then
        return nil
    elseif (cooltime == 999) then
        return nil
    elseif (cooltime == 0) then
        return nil
    elseif (cooltime == 1) then
        return nil
    end

    return cooltime
end

-------------------------------------
-- function getCoolTimeDesc
-- @brief 쿨타임 표기용
-------------------------------------
function DragonSkillIndivisualInfo:getCoolTimeDesc()
    local cooltime = self:getCoolTime()

    -- 텍스트 처리
    local desc
    if (cooltime) then
        desc = Str('{1}초', cooltime)
    end

    return desc
end

-------------------------------------
-- function getReqMana
-- @brief 필요 마나 리턴 (active 스킬만 유효한 값을 가짐)
-------------------------------------
function DragonSkillIndivisualInfo:getReqMana()
    local req_mana = self.m_tSkill['req_mana']

    if (not req_mana) or (type(req_mana) == 'string') then
        req_mana = 0
    end

    return req_mana
end

-------------------------------------
-- function getSkillTypeForUI
-------------------------------------
function DragonSkillIndivisualInfo:getSkillTypeForUI()
    local t_skill = GetSkillTable(self.m_charType):get(self.m_skillID)

    if (self.m_charType == 'tamer' and t_skill['game_mode'] == 'pvp') then
        return 'colosseum'
    end

    return self.m_skillType
end