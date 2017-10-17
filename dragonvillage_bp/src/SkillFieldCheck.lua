local PARENT = Skill

-------------------------------------
-- class SkillFieldCheck
-------------------------------------
SkillFieldCheck = class(PARENT, {
		m_tarRes = 'str',
		m_drainRes = 'str',
		m_fieldType = 'str',
		m_targetStatusEffectType = 'str',
		m_isReleaseStatusEffect = 'bool',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillFieldCheck:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillFieldCheck:init_skill(tar_res, drain_res, field_type, target_status_effect_type, is_release_status_effect)
    PARENT.init_skill(self)

	-- 멤버 변수
    self.m_tarRes = tar_res 
	self.m_drainRes = drain_res
    self.m_fieldType = field_type
	self.m_targetStatusEffectType = target_status_effect_type
	self.m_isReleaseStatusEffect = is_release_status_effect
end

-------------------------------------
-- function initState
-------------------------------------
function SkillFieldCheck:initState()
	self:setCommonState(self)
    self:addState('start', SkillFieldCheck.st_attack, nil, false)
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillFieldCheck.st_attack(owner, dt)
	if (owner.m_stateTimer == 0) then
		owner:runAttack()
	else
		owner:changeState('dying')
	end
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillFieldCheck:runAttack()
    -- 모든 대상 반환
	local l_target = self.m_owner:getTargetListByType(self.m_fieldType .. '_none', nil, nil)

	-- 특정 상태효과를 지닌 대상 탐색
	for _, target_char in pairs(l_target) do
		for type, status_effect in pairs(target_char:getStatusEffectList()) do
			if (status_effect.m_statusEffectName == self.m_targetStatusEffectType) then 
				
				-- 이펙트 생성
				self:makeEffect(self.m_tarRes, target_char.pos.x, target_char.pos.y, 'effect')

				-- 흡수 이펙트
				for i = 1, 5 do
					self:makeDrainEffect(target_char.pos.x, target_char.pos.y)
				end
		
				-- 상태효과 시전
				for i = 1, status_effect.m_overlabCnt do 
                    self:dispatch(CON_SKILL_HIT, {l_target = {target_char}})
				end
	
				-- 대상의 상태효과 해제(필요한경우)
				if self.m_isReleaseStatusEffect then 
					StatusEffectHelper:releaseStatusEffectByType(target_char, self.m_targetStatusEffectType)
				end

			end
		end
	end
	
	-- shake
	self.m_owner.m_world.m_shakeMgr:shakeBySpeed(math_random(335-20, 335+20), math_random(500, 1500))
end

-------------------------------------
-- function makeDrainEffect
-- @breif 흡수하는 투사체 이펙트 생성 
-------------------------------------
function SkillFieldCheck:makeDrainEffect(x, y)
	if (self.m_drainRes == '') then return end

    -- 이팩트 생성
    local effect = MakeAnimator(self.m_drainRes)
    effect:setPosition(x, y)
	local world = self.m_owner.m_world
    
    local missileNode = world:getMissileNode()
    missileNode:addChild(effect.m_node, 0)

	-- random요소 - 점프 높이, 방향, 지속시간, 스케일
	local jump_height = math_random(100, 200)
	local duration = math_random(10, 20)/10
	if (math_random(1, 2) == 1) then
		jump_height = -jump_height
	end
	effect.m_node:setScale(duration)

	-- 액션 실행
	local target_pos = cc.p(self.m_owner.pos.x, self.m_owner.pos.y)
    local action = cc.JumpTo:create(duration, target_pos, jump_height, 1)
	local action2 = cc.RemoveSelf:create()
	effect.m_node:runAction(cc.Sequence:create(cc.EaseIn:create(action, 2), action2))
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillFieldCheck:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local tar_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local drain_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)

    local field_type = t_skill['val_1']
	local target_status_effect_type = t_skill['val_2']
	local is_release_status_effect = t_skill['val_3']
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillFieldCheck(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(tar_res, drain_res, field_type, target_status_effect_type, is_release_status_effect)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
