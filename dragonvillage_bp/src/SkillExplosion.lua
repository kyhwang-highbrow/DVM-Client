local PARENT = SkillLeap

-------------------------------------
-- class SkillExplosion
-------------------------------------
SkillExplosion = class(PARENT, {
		m_explosionRes = '',
        m_bExistOwnerAni = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillExplosion:init(file_name, body, ...)
    self.m_bExistOwnerAni = false
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillExplosion:init_skill(explosion_res, jump_res, rotate_count)
	PARENT.init_skill(self, jump_res)
	
	self.m_explosionRes = explosion_res
    self.m_rotateCount = rotate_count

    -- skill_rush 애니메이션이 있다면 해당 애니메이션으로 설정
    local list = self.m_owner.m_animator:getVisualList()
    if (table.find(list, 'skill_rush')) then
        self.m_bExistOwnerAni = true
    end
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
-- function st_move
-------------------------------------
function SkillExplosion.st_move(owner, dt)
    PARENT.st_move(owner, dt)

    if (owner.m_stateTimer == 0) then
        -- skill_rush 애니메이션이 있다면 해당 애니메이션으로 설정
        if (owner.m_bExistOwnerAni) then
            owner.m_owner.m_animator:changeAni('skill_rush', true)
        end
    end
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
-- function st_comeback
-------------------------------------
function SkillExplosion.st_comeback(owner, dt)
    PARENT.st_comeback(owner, dt)

    if (owner.m_stateTimer == 0) then
        if (owner.m_bExistOwnerAni) then
            owner.m_owner.m_animator:changeAni('idle', true)
        end
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
    local rotate_count = SkillHelper:getValid(t_skill['val_1'], 0)

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillExplosion(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(explosion_res, jump_res, rotate_count)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
