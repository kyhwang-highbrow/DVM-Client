local PARENT = Entity

-------------------------------------
-- class CommonMissile
-- @brief 공용탄을 쏘기 위한 클래스, 일종의 간이 미사일런처 
-------------------------------------
CommonMissile = class(PARENT, {
		m_owner = 'Character',
		m_target = 'Charater',

		m_missileRes = 'str',
		m_motionStreakRes = 'str',

		m_powerRate = 'num',
		m_activityCarrier = 'AttackDamage',

		m_statusEffectType = '',
		m_statusEffectRate = '',

		m_targetType = '', -- target_type 필드, 상대 선택 규칙
     })

-------------------------------------
-- function init
-------------------------------------
function CommonMissile:init(file_name, body)
end

-------------------------------------
-- function initCommonMissile
-------------------------------------
function CommonMissile:initCommonMissile(owner, t_skill)
    -- 변수 초기화
	self.m_owner = owner
	
	local attr = owner.m_charTable['attr'] or ''
	self.m_missileRes = string.gsub(t_skill['res_1'], '@', attr)
	self.m_motionStreakRes = string.gsub(t_skill['res_2'], '@', attr)

	self.m_powerRate = t_skill['power_rate']
	self.m_statusEffectType = t_skill['status_effect_type']
	self.m_statusEffectRate = t_skill['status_effect_rate']
	self.m_targetType = t_skill['target_type']

	self.m_target = self:getRandomTargetByRule()

	self:initActvityCarrier()
	self:initState()

	-- resource 체크 
	if (not self.m_missileRes) or (self.m_missileRes == 'x') then
		error('공통탄 .. ' ..  t_skill['type'] .. ' 리소스 없다 ..')
	end
	if (self.m_motionStreakRes == 'x') then 
		self.m_motionStreakRes = nil 
	end
end

-------------------------------------
-- function initActvityCarrier
-------------------------------------
function CommonMissile:initActvityCarrier()    
    -- 공격력 계산을 위해
    self.m_activityCarrier = self.m_owner:makeAttackDamageInstance()
    self.m_activityCarrier:insertStatusEffectRate(self.m_statusEffectType, self.m_statusEffectRate)
    self.m_activityCarrier.m_skillCoefficient = (self.m_powerRate / 100)
	
	-- 타격 이벤트에서 일반탄인지 구분할 때 사용
	self.m_activityCarrier:setSkillType('basic') 
end

-------------------------------------
-- function initState
-------------------------------------
function CommonMissile:initState()    
    -- 상태 생성
    self:addState('attack', CommonMissile.st_attack, nil, true)
    self:addState('dying', function(owner, dt) return true end, nil, true, 3)
end

-------------------------------------
-- function getRandomTargetByRule()
-- @brief 테이블 target_type 에 따른 랜덤한 타겟 선택 
-------------------------------------
function CommonMissile:getRandomTargetByRule()
    local l_target = self.m_owner:getTargetListByType(self.m_targetType)
    local target = l_target[1]

    if (not target) then
	    return nil
    end

    return target
end

-------------------------------------
-- function fireMissile
-------------------------------------
function CommonMissile:fireMissile()
	error('KMS - 공용탄은 자식클래스에서 탄을 정의합니다.')
end

-------------------------------------
-- function st_attack
-------------------------------------
function CommonMissile.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:fireMissile()
		owner:changeState('dying')
        return true
    end

    return false
end

-------------------------------------
-- function makeInstance
-------------------------------------
function CommonMissile:makeInstance(owner, t_skill)
	local common_missile = CommonMissile()
	common_missile:initCommonMissile(owner, t_skill)

	owner.m_world:addToUnitList(common_missile)
    owner.m_world.m_worldNode:addChild(common_missile.m_rootNode)
end
