local PARENT = SkillLeap

-------------------------------------
-- class SkillExplosion
-------------------------------------
SkillExplosion = class(PARENT, {
		m_explosionRes = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillExplosion:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillExplosion:init_skill(explosion_res, jump_res, range)
	PARENT.init_skill(self, jump_res, range)
	
	self.m_explosionRes = explosion_res
	
	-- 특정 드래곤 전용 
	self:boombaSideEffect()

	self:makeRangeEffect(RES_RANGE, range)
end

-------------------------------------
-- function boombaSideEffect
-- @breif 특정 드래곤 하드 코딩
-------------------------------------
function SkillExplosion:boombaSideEffect() 
	-- 액티브 스킬 사용시 def 버프 해제
	StatusEffectHelper:releaseStatusEffect(self.m_owner, self.m_lStatusEffectStr)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillExplosion:initState()
	self:setCommonState(self)
    self:addState('start', SkillExplosion.st_move, nil, true)
    self:addState('attack', SkillExplosion.st_attack, nil, false)
	self:addState('comeback', SkillExplosion.st_comeback, nil, true)
	
	-- 영웅을 제어하는 스킬은 dying state를 별도로 정의
	self:addState('dying', IStateDelegate.st_dying, nil, nil, 10)
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillExplosion.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 공격
		owner:makeEffect(owner.m_explosionRes, owner.m_targetPos.x, owner.m_targetPos.y)
		owner:runAttack()
		owner.m_world.m_shakeMgr:shakeBySpeed(owner.movement_theta, 1500)
		owner:changeState('comeback')
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillExplosion:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local explosion_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local jump_res = t_skill['res_2']
    local range = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillExplosion(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(explosion_res, jump_res, range)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

    -- 5. 하이라이트
    if (skill.m_bHighlight) then
        world.m_gameHighlight:addMissile(skill)
    end
end
