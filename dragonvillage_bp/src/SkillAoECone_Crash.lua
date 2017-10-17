local PARENT = class(SkillAoECone, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillAoECone_Crash
-- @brief 목표 지점에 특정 각도의 원뿔 공격 실행
-------------------------------------
SkillAoECone_Crash = class(PARENT, {
		m_dashEffect = 'Animator',
     })

local MOVE_SPEED = 1500

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoECone_Crash:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoECone_Crash:init_skill(dash_res, attack_count, dir)
    PARENT.init_skill(self, attack_count, dir)

	-- dash
	self:initDashEffect(dash_res)
end

-------------------------------------
-- function initDashEffect
-------------------------------------
function SkillAoECone_Crash:initDashEffect(dash_res)
	self.m_dashEffect = MakeAnimator(dash_res)
	self.m_rootNode:addChild(self.m_dashEffect.m_node)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoECone_Crash:initState()
	self:setCommonState(self)
	self:addState('start', SkillAoECone_Crash.st_move, nil, false)
    self:addState('attack', SkillAoECone_Crash.st_attack, 'idle', false)
	self:addState('comeback', SkillAoECone_Crash.st_comeback, nil, false)
end

-------------------------------------
-- function st_move
-------------------------------------
function SkillAoECone_Crash.st_move(owner, dt)
    local char = owner.m_owner
    owner:setPosition(char.pos.x, char.pos.y)

    if (owner.m_stateTimer == 0) then
		-- 캐릭터 이동 시작
		char:setMove(owner.m_targetPos.x, owner.m_targetPos.y, MOVE_SPEED)
		-- 스킬 이펙트 각도
        owner:setRotation(owner.m_dir)
		-- 대쉬 이펙트 각도
		owner.m_dashEffect:setRotation(char.movement_theta)
		-- 스킬 이펙트 일단 가림
		owner.m_animator:setVisible(false)

    elseif (char.m_isOnTheMove == false) then
		-- 대쉬 이펙트 해제
		owner.m_dashEffect:release()
		owner.m_dashEffect = nil

		-- 공격 시작
        owner:changeState('attack')
    else
    end
end

-------------------------------------
-- function st_comeback
-------------------------------------
function SkillAoECone_Crash.st_comeback(owner, dt)
    local char = owner.m_owner

    if (owner.m_stateTimer == 0) then
		-- 스킬 이펙트 다시 가림
		owner.m_animator:setVisible(false)
		-- 캐릭터 원위치
        char:setMoveHomePos(MOVE_SPEED)
    elseif (char.m_isOnTheMove == false) then
        owner:changeState('dying')
    end
end

-------------------------------------
-- function enterAttack
-- @brief 공격이 시작되는 시점에 실행
-------------------------------------
function SkillAoECone_Crash:enterAttack()
	PARENT.enterAttack(self)
	-- 스킬 이펙트 보임
	self.m_animator:setVisible(true)
end

-------------------------------------
-- function escapeAttack
-- @brief 공격이 종료되는 시점에 실행
-------------------------------------
function SkillAoECone_Crash:escapeAttack()
	self:changeState('comeback')
	self.m_animator:addAniHandler(function()
	end)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoECone_Crash:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local dash_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)
	
	local attack_count = t_skill['hit']
    local dir = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoECone_Crash(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(dash_res, attack_count, dir)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
