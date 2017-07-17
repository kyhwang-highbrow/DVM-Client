local PARENT = SkillLeap

-------------------------------------
-- class SkillSuicideExplosion
-------------------------------------
SkillSuicideExplosion = class(PARENT, {
		m_explosionRes = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillSuicideExplosion:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillSuicideExplosion:init_skill(explosion_res, jump_res)
	PARENT.init_skill(self, jump_res)
	
	self.m_explosionRes = explosion_res
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillSuicideExplosion:initSkillSize()
end

-------------------------------------
-- function initState
-------------------------------------
function SkillSuicideExplosion:initState()
	self:setCommonState(self)
    self:addState('start', SkillExplosion.st_move, nil, true)
    self:addState('attack', SkillExplosion.st_attack, nil, false)
end

-------------------------------------
-- function update
-------------------------------------
function SkillSuicideExplosion:update(dt)
    -- 드래곤의 애니와 객체 위치 동기화
	if (self.m_state ~= 'dying') then 
		self.m_owner:syncAniAndPhys()
	end
	
    return Skill.update(self, dt)
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillSuicideExplosion.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 공격
		owner:makeEffect(owner.m_explosionRes, owner.m_targetPos.x, owner.m_targetPos.y)
		owner:runAttack()
		owner.m_world.m_shakeMgr:shakeBySpeed(owner.movement_theta, 1500)
		owner:changeState('dying')
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillSuicideExplosion:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local explosion_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local jump_res = t_skill['res_2']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillExplosion(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(explosion_res, jump_res)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
