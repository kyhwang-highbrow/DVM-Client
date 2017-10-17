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
function SkillExplosion:init_skill(explosion_res, jump_res)
	PARENT.init_skill(self, jump_res)
	
	self.m_explosionRes = explosion_res
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillExplosion:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_range = t_data['size']
	end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillExplosion:initState()
	self:setCommonState(self)
    self:addState('start', SkillExplosion.st_move, nil, true)
    self:addState('attack', SkillExplosion.st_attack, nil, false)
	self:addState('comeback', SkillExplosion.st_comeback, nil, true)
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
