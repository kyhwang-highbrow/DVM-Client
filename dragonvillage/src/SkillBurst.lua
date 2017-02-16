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
    local t_target = self.m_owner:getTargetListByType(self.m_targetType)
	
    for i, target_char in ipairs(t_target) do
		-- 추가 데미지 여부 판별
		local has_target_status_effect = false
		local multiply_value = 1
		for type, status_effect in pairs(target_char:getStatusEffectList()) do
			if (status_effect.m_statusEffectName == self.m_targetStatusEffectType) then 
				multiply_value = self.m_multiplyDamageRate
				has_target_status_effect = true 
				break
			end
		end

		-- 데미지를 공격시마다 계산
		self.m_activityCarrier:setPowerRate(self.m_powerRate * multiply_value)

        -- 공격
        self:attack(target_char)
		
		-- 이펙트 생성
		self:makeEffect(target_char.pos.x, target_char.pos.y, has_target_status_effect)

		-- 해당 상태효과 해제해야 할시 해제
		if (self.m_isExtinguish) and has_target_status_effect then 
			StatusEffectHelper:releaseStatusEffectByType(target_char, self.m_targetStatusEffectType)
		end 
    end
	
	-- shake
	self.m_owner.m_world.m_shakeMgr:shakeBySpeed(math_random(335-20, 335+20), math_random(500, 1500))

	-- 스킬이 제거할 수 있는 미사일 제거
	self:removeDestructibleMissile()
end

-------------------------------------
-- function makeEffect
-- @breif 추가 이펙트 생성 .. 현재는 같은 리소스 사용
-------------------------------------
function SkillBurst:makeEffect(x, y, is_target_status_effect)
    -- 이팩트 생성
    local effect = MakeAnimator(self.m_burstRes)
    effect:setPosition(x, y)
    
	if (is_target_status_effect) then 
		effect:changeAni('effect_2', false)
		effect.m_node:setScale(1.5)
	else
		effect:changeAni('effect_1', false)
	end

    self.m_owner.m_world.m_missiledNode:addChild(effect.m_node, 0)
	effect:addAniHandler(function() 
		effect.m_node:runAction(cc.RemoveSelf:create())
	end)
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
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
