local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillCharge
-------------------------------------
SkillCharge = class(PARENT, {
		m_animationName = 'str', 
		m_tAttackCount = 'num',
		m_maxAttackCount = 'num',

        m_physObject = 'PhysObject',	-- 돌진 바디
		m_preCollisionTime = 'number',	-- 충돌 시간
		m_chargePos = 'number',			-- 돌진 위치
		m_atkPhysPosX = 'number',		-- 돌진 바디 위치

		m_speedSet = 'number',
		m_speedMove = 'number',
		m_speedComeback = 'number',
		m_speedCollision = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillCharge:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillCharge:init_skill(attack_count, animation_name)
	PARENT.init_skill(self)

	-- 멤버변수
	self.m_animationName = animation_name
	self.m_tAttackCount = {}
	self.m_maxAttackCount = attack_count
	self.m_preCollisionTime = 0
	
	self.m_speedSet = 200
	self.m_speedMove = 1500
	self.m_speedComeback = 1500
	self.m_speedCollision = 50

	local pos_x
	if (self.m_owner.m_bLeftFormation) then
		pos_x = 2000
		self.m_atkPhysPosX = self.m_owner.body.size * 3
	else
		pos_x = -500
		self.m_atkPhysPosX = -(self.m_owner.body.size * 3)
	end
	self.m_chargePos = {x = pos_x, y = self.m_targetPos.y}
end

-------------------------------------
-- function initState
-------------------------------------
function SkillCharge:initState()
	self:setCommonState(self)
    self:addState('start', SkillCharge.st_set, nil, true)
	self:addState('ready', SkillCharge.st_ready, nil, true)
	self:addState('charge', SkillCharge.st_charge, nil, true)
    self:addState('comeback', SkillCharge.st_comeback, nil, true)
end

-------------------------------------
-- function st_set
-- @brief 돌격할 대상과 직선 위치를 맞추는 과정
-------------------------------------
function SkillCharge.st_set(owner, dt)
	local char = owner.m_owner
	if (owner.m_stateTimer == 0) then
		char:setMove(char.pos.x , owner.m_chargePos.y, owner.m_speedSet)
	elseif (char.m_isOnTheMove == false) then
        owner:changeState('ready')
	end
end

-------------------------------------
-- function st_ready
-- @brief 공격 준비
-------------------------------------
function SkillCharge.st_ready(owner, dt)
	if (owner.m_stateTimer == 0) then
		local char = owner.m_owner
		-- 캐릭터
		char.m_animator:changeAni(owner.m_animationName .. '_appear', false) 
		char.m_animator:addAniHandler(function() 
			owner:changeState('charge')
		end)	 
	end
end

-------------------------------------
-- function st_charge
-- @brief 돌격
-------------------------------------
function SkillCharge.st_charge(owner, dt)
    local char = owner.m_owner

    if (owner.m_stateTimer == 0) then
		char:setMove(owner.m_chargePos.x ,owner.m_chargePos.y, owner.m_speedMove)
		char.m_animator:changeAni(owner.m_animationName .. '_idle', true) 
        char:setAfterImage(true)

        owner:makeCrashPhsyObject()

    elseif (char.m_isOnTheMove == false) then
        owner:changeState('comeback')

    end
end

-------------------------------------
-- function st_comeback
-- @brief 돌아옴
-------------------------------------
function SkillCharge.st_comeback(owner, dt)
    local char = owner.m_owner

    if (owner.m_stateTimer == 0) then
        owner:releaseCrashPhsyObject()
		char:setMoveHomePos(owner.m_speedComeback)

    elseif (char.m_isOnTheMove == false) then
		char.m_animator:changeAni(owner.m_animationName .. '_disappear', false) 
		char:setAfterImage(false)
		owner:changeState('dying')

    end
end

-------------------------------------
-- function update
-------------------------------------
function SkillCharge:update(dt)
    if (self.m_owner.m_bDead) then
        self:changeState('dying')
	elseif (self.m_state == 'charge') then
		if (self.m_stateTimer > self.m_preCollisionTime + 0.3) then
			self.m_owner:setMove(self.m_chargePos.x ,self.m_chargePos.y, self.m_speedMove)
			self.m_preCollisionTime = self.m_stateTimer
		end
    end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function makeCrashPhsyObject
-------------------------------------
function SkillCharge:makeCrashPhsyObject()
    if (self.m_physObject) then
        error('이미 충돌박스가 존재')
    end

    local char = self.m_owner
    local object_key = char:getAttackPhysGroup()

    local phys_object = char:addPhysObject(char, object_key, {0, 0, char.body.size * 2}, self.m_atkPhysPosX, 0)
    phys_object:addAtkCallback(function(attacker, defender, i_x, i_y)
		self:doChargeAttack(defender)
		phys_object:clearCollisionObjectList()
    end)

    self.m_physObject = phys_object
end

-------------------------------------
-- function doChargeAttack
-------------------------------------
function SkillCharge:doChargeAttack(defender)
	-- 충돌 물리 객체 확인
	if (not self.m_physObject) then 
		return 
	end
	-- 충돌 횟수 초기화
	if (not self.m_tAttackCount[defender]) then
		self.m_tAttackCount[defender] = 0
	end
	-- 최대 공격수 도달했다면 원속으로 복귀
	if (self.m_tAttackCount[defender] > self.m_maxAttackCount) then 
		return 
	end
	-- 공격 간격 설정
	if (self.m_stateTimer < self.m_preCollisionTime + 0.1) then
		return 
	end

    -- 돌진 공격
    if defender then
		-- 공격 및 카운트
        self:attack(defender)
		self.m_tAttackCount[defender] = self.m_tAttackCount[defender] + 1

		-- 충돌 중에는 속도 줄임
		self.m_owner:setMove(self.m_chargePos.x ,self.m_chargePos.y, self.m_speedCollision)

		-- 충돌 시간 저장
		self.m_preCollisionTime = self.m_stateTimer
    end
end

-------------------------------------
-- function releaseCrashPhsyObject
-------------------------------------
function SkillCharge:releaseCrashPhsyObject()
    self.m_owner:removePhysObject(self.m_physObject)
    self.m_physObject = nil
end

-------------------------------------
-- function release
-------------------------------------
function SkillCharge:release()
    self:releaseCrashPhsyObject()
    PARENT.release(self)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillCharge:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local effect_res = t_skill['res_1']
	local animation_name = t_skill['animation']
    local attack_count = t_skill['hit']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillCharge(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count, animation_name)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end