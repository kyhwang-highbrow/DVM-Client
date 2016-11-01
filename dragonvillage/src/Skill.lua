-------------------------------------
-- class ISkill
-------------------------------------
ISkill = {
        m_owner = 'Character',
        m_activityCarrier = 'AttackDamage',
		m_range = 'num',
		m_powerRate = 'num',
		m_preDelay = 'num',

		-- 타겟 관련 .. 
		m_targetType = 'str', -- 타겟 선택하는 룰
		m_targetChar = 'Character', 
		m_targetPos = 'pos', -- 타겟 위치 정보 빠르게 접근하기 위해..~
		
		-- 상태 효과 관련 변수들
		m_statusEffectType = '',
		m_statusEffectValue = '',
		m_statusEffectRate = '',

		-- 스킬 타입 명 ex) skill_expolosion 
		m_skillType = 'str', 

		-- 캐릭터의 중심을 기준으로 실제 공격이 시작되는 offset
        m_attackPosOffsetX = 'number',
        m_attackPosOffsetY = 'number',
     }

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function ISkill:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-- @brief actvityCarrier, AttackOffset, defualt target, default target pos를 설정한다. 
-------------------------------------
function ISkill:init_skill()
	self:initActvityCarrier(self.m_powerRate)
	self:initAttackPosOffset()
	
	if (not self.m_targetChar) then
		self.m_targetChar = self:getDefaultTarget()
	end
    if (not self.m_targetPos.x) or (not self.m_targetPos.y) then
        local x, y = self:getDefaultTargetPos()
		self.m_targetPos = {x = x, y = y}
    end
end

-------------------------------------
-- function initActvityCarrier
-------------------------------------
function ISkill:initActvityCarrier(power_rate)    
    -- 공격력 계산을 위해
    self.m_activityCarrier = self.m_owner:makeAttackDamageInstance()
    self.m_activityCarrier.m_skillCoefficient = (power_rate / 100)
end

-------------------------------------
-- function initState
-- @breif state 정의
-- @breif 모든 스킬은 delay로 시작하고 start로 본래의 스킬 state를 진행한다.
-------------------------------------
function ISkill:setCommonState(skill)
	skill:addState('delay', ISkill.st_delay, nil, false)
    skill:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function setParams
-- @brief 멤버변수 정의
-------------------------------------
function ISkill:setParams(owner, power_rate, target_type, pre_delay, status_effect_type, status_effect_value, status_effect_rate, skill_type, tar_x, tar_y, target)
	self.m_owner = owner
	self.m_powerRate = power_rate
	self.m_targetType = target_type
	self.m_preDelay = pre_delay or 0
	self.m_statusEffectType = status_effect_type
	self.m_statusEffectValue = status_effect_value
	self.m_statusEffectRate = status_effect_rate
	self.m_skillType = skill_type
	self.m_targetPos = {x = tar_x, y = tar_y}
	self.m_targetChar = target
end

-------------------------------------
-- function st_delay
-------------------------------------
function ISkill.st_delay(owner, dt)
    if (owner.m_stateTimer == 0) then
		if (not owner.m_targetChar) then 
			owner:changeState('dying') 
		end
	elseif (owner.m_stateTimer > owner.m_preDelay) then
		owner:changeState('start')
    end
end

-------------------------------------
-- function st_idle
-------------------------------------
function ISkill.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
	else
		owner:changeState('attack')
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function ISkill.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:attack()
	else
		owner:changeState('dying')
    end
end

-------------------------------------
-- function attack
-- @brief findtarget으로 찾은 적에게 공격을 실행한다. 
-------------------------------------
function ISkill:attack()
    local t_targets = self:findTarget()
	
    for i,target_char in ipairs(t_targets) do
        -- 공격
        self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
        target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)
    end
end

-------------------------------------
-- function findTarget
-- @brief 모든 공격 대상 찾음
-- @default 직선거리에서 범위를 기준으로 충돌여부 판단
-------------------------------------
function ISkill:findTarget(x, y, range)
	local x = x or self.m_targetPos.x
	local y = y or self.m_targetPos.y
	local range = range or self.m_range

    local world = self.m_world
	local l_target = world:getTargetList(self.m_owner, x, y, 'enemy', 'x', 'distance_line')
    
	local l_ret = {}
    local distance = 0

    for _, target in pairs(l_target) do
		-- 바디사이즈를 감안한 충돌 체크
		if isCollision(x, y, target, range) then 
			table.insert(l_ret, target)
		end
    end
    
    return l_ret
end

-------------------------------------
-- function getDefaultTarget
-- @brief 디폴트 타겟을 반환한다.
-- @brief 인디케이터 없이 시전 된 경우 사용된다.
-- @default 타겟 룰에 따른 타겟 리스트 중 첫번째를 선택
-------------------------------------
function ISkill:getDefaultTarget()
    local l_target = self.m_owner:getTargetListByType(self.m_targetType)
	return l_target[1]
end

-------------------------------------
-- function getDefaultTargetPos
-- @brief 디폴트 타겟의 좌표를 반환한다.
-------------------------------------
function ISkill:getDefaultTargetPos()
    local target = self:getDefaultTarget()
    if target then
		self.m_targetChar = target
		return target.pos.x, target.pos.y
    else
        return self.m_owner.pos.x, self.m_owner.pos.y
    end
end

-------------------------------------
-- function initAttackPosOffset
-- @brief 캐릭터의 중심을 기준으로 실제 공격이 시작되는 offset 지정
-------------------------------------
function ISkill:initAttackPosOffset()
    self.m_attackPosOffsetX = 0
    self.m_attackPosOffsetY = 0

    local animator = self.m_owner.m_animator
    
    local l_event_data = animator:getEventList('attack', 'attack')

    if (not l_event_data[1]) then
        return
    end

    local string_value = l_event_data[1]['stringValue']

    if (not string_value) or (string_value == '') then
        return
    end

    local l_str = seperate(string_value, ',')

    local scale = animator:getScale()
    self.m_attackPosOffsetX = (l_str[1] * scale)
    self.m_attackPosOffsetY = (l_str[2] * scale)
end

-------------------------------------
-- function getAttackPosition
-- @brief 캐릭터의 애니메이션상 공격 시작 위치의 offset을 가져온다.
-------------------------------------
function ISkill:getAttackPosition()
    return self.m_attackPosOffsetX, self.m_attackPosOffsetY
end

-------------------------------------
-- function makeSkillInstnce
-- @brief 실제 스킬 인스턴스를 생성하고 월드에 등록하는 부분
-------------------------------------
function ISkill:makeSkillInstnce()
end

-------------------------------------
-- function makeSkillInstnceFromSkill
-- @brief Character - doSkill 에서 호출될 부분 
-- 스킬 테이블에서 필요한 데이터를 가공하여 전달.
-------------------------------------
function ISkill:makeSkillInstnceFromSkill()
end

-------------------------------------
-- function getCloneTable
-- @brief
-------------------------------------
function ISkill:getCloneTable()
    return clone(ISkill)
end

-------------------------------------
-- function getCloneClass
-- @brief
-------------------------------------
function ISkill:getCloneClass()
    return class(clone(ISkill))
end