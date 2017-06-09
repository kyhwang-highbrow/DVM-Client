local PARENT = Skill

-------------------------------------
-- class SkillBurst
-------------------------------------
SkillBurst = class(PARENT, {
		m_burstRes = 'str',
		m_targetStatusEffectType = 'str',
		m_isExtinguish = 'bool',
		m_multiplyDamageRate = 'num',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillBurst:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillBurst:init_skill(burst_res, target_status_effect_type, is_extinguish, add_damage_rate)
    PARENT.init_skill(self)

	-- 멤버 변수
    self.m_burstRes = burst_res 
    self.m_targetStatusEffectType = target_status_effect_type
	self.m_isExtinguish = is_extinguish == 1
	self.m_multiplyDamageRate = add_damage_rate / 100
end

-------------------------------------
-- function initState
-------------------------------------
function SkillBurst:initState()
	self:setCommonState(self)
    self:addState('start', SkillBurst.st_attack, nil, false)
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillBurst.st_attack(owner, dt)
	if (owner.m_stateTimer == 0) then
		owner:runAttack()
	else
		owner:changeState('dying')
	end
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillBurst:runAttack()
    local l_target = self.m_owner:getTargetListByType(self.m_targetType, nil, nil)

    local pos_x, pos_y = self:getAttackPositionAtWorld()
    local l_collision = SkillTargetFinder:getCollisionFromTargetList(l_target, pos_x, pos_y)
	
    for _, collision in ipairs(l_collision) do
        local target = collision:getTarget()

		-- 추가 데미지 여부 판별
		local has_target_status_effect = false
		local multiply_value = 1
		for type, status_effect in pairs(target:getStatusEffectList()) do
			if (status_effect.m_statusEffectName == self.m_targetStatusEffectType) then 
				multiply_value = self.m_multiplyDamageRate
				has_target_status_effect = true 
				break
			end
		end

		-- 데미지를 공격시마다 계산
		self.m_activityCarrier:setPowerRate(self.m_powerRate * multiply_value)

        -- 공격
        self:attack(collision)
		
		-- 이펙트 생성
		local effect = self:makeEffect(self.m_burstRes, target.pos.x, target.pos.y)
		if (has_target_status_effect) then 
			effect:changeAni('effect_2', false)
			effect.m_node:setScale(1.5)
		else
			effect:changeAni('effect_1', false)
		end

		-- 해당 상태효과 해제해야 할시 해제
		if (self.m_isExtinguish) and has_target_status_effect then 
			StatusEffectHelper:releaseStatusEffectByType(target, self.m_targetStatusEffectType)
		end 
    end
	
	-- shake
	self.m_owner.m_world.m_shakeMgr:shakeBySpeed(math_random(335-20, 335+20), math_random(500, 1500))

	self:doCommonAttackEffect()
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillBurst:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local burst_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)

    local target_status_effect_type = t_skill['val_1']
	local is_extinguish = t_skill['val_2']
	local add_damage_rate = t_skill['val_3']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillBurst(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(burst_res, target_status_effect_type, is_extinguish, add_damage_rate)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
