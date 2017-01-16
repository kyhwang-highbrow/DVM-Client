local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillCharge
-------------------------------------
SkillCharge = class(PARENT, {
		m_animationName = 'str', 
		m_effect = 'Animator',
		m_tAttackCount = 'num',
		m_maxAttackCount = 'num',

        m_afterimageMove = 'number',
        m_physObject = 'PhysObject',	-- 돌진 바디
		m_preCollisionTime = 'number',	-- 충돌 시간
		m_chargePos = 'number',			-- 돌진 위치
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillCharge:init(file_name, body, ...)    
end

local SPEED_SET = 200
local SPEED_COLLISION = 70
local SPEED_MOVE = 1500
local SPEED_COMEBACK = 1500

-------------------------------------
-- function init_skill
-------------------------------------
function SkillCharge:init_skill(animation_name, effect_res, attack_count)
	PARENT.init_skill(self)

	-- 멤버변수
	self.m_animationName = animation_name
	self.m_tAttackCount = {}
	self.m_maxAttackCount = attack_count
	self.m_preCollisionTime = 0
	
	self.m_chargePos = {x = 0, y = self.m_targetPos.y}

	-- StateDelegate 적용
    self.m_owner:setStateDelegate(self)
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
	self:addState('dying', IStateDelegate.st_dying, nil, nil, 10)
end

-------------------------------------
-- function st_set
-- @brief 돌격할 대상과 직선 위치를 맞추는 과정
-------------------------------------
function SkillCharge.st_set(owner, dt)
	local char = owner.m_owner
	if (owner.m_stateTimer == 0) then
		char:setMove(char.pos.x , owner.m_chargePos.y, SPEED_SET)
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
			char:setMove(owner.m_chargePos.x ,owner.m_chargePos.y, SPEED_MOVE)
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
        owner.m_afterimageMove = 0
        owner:makeCrashPhsyObject()
		char.m_animator:changeAni(owner.m_animationName .. '_idle', true) 

    elseif (char.m_isOnTheMove == false) then
        owner:changeState('comeback')
    else
        owner:updateAfterImage(dt)
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
		char:setMove(char.m_homePosX, char.m_homePosY, SPEED_COMEBACK)

    elseif (char.m_isOnTheMove == false) then
		char.m_animator:changeAni(owner.m_animationName .. '_disappear', false) 
		owner:changeState('dying')
    end
end

-------------------------------------
-- function update
-------------------------------------
function SkillCharge:update(dt)
    if (self.m_owner.m_bDead) then
        self:changeState('dying')
    end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function updateAfterImage
-------------------------------------
function SkillCharge:updateAfterImage(dt)
    local char = self.m_owner

    -- 에프터이미지
    self.m_afterimageMove = self.m_afterimageMove + (char.speed * dt)
    local interval = 50

    if (self.m_afterimageMove >= interval) then
        self.m_afterimageMove = self.m_afterimageMove - interval
        local duration = (interval / char.speed) * 1.5 -- 3개의 잔상이 보일 정도
        duration = math_clamp(duration, 0.3, 0.7)

        local res = char.m_animator.m_resName
        local rotation = char.m_animator:getRotation()
        local accidental = MakeAnimator(res)
        accidental:changeAni(char.m_animator.m_currAnimation)
        local parent = char.m_rootNode:getParent()
        char.m_world.m_worldNode:addChild(accidental.m_node, 2)
        accidental:setScale(char.m_animator:getScale())
        accidental:setFlip(char.m_animator.m_bFlip)
        accidental.m_node:setOpacity(255 * 0.3)
        accidental.m_node:setPosition(char.pos.x, char.pos.y)
        accidental.m_node:runAction(cc.Sequence:create(cc.FadeTo:create(duration, 0), cc.RemoveSelf:create()))
    end
end

-------------------------------------
-- function makeCrashPhsyObject
-------------------------------------
function SkillCharge:makeCrashPhsyObject()
    if (self.m_physObject) then
        error()
    end

    local char = self.m_owner
    local object_key = char:getAttackPhysGroup()

    local phys_object = char:addPhysObject(char, object_key, {0, 0, 60}, -200, 0)
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
		self.m_owner:setMove(self.m_chargePos.x ,self.m_chargePos.y, SPEED_MOVE)
		return 
	end
	-- 공격 간격 설정
	if (self.m_stateTimer < self.m_preCollisionTime + 0.1) then
		return 
	end

    -- 돌진 공격
    if defender then
		-- 화면 떨림 연출
        self.m_owner.m_world.m_shakeMgr:shakeBySpeed(math_random(335-20, 335+20), math_random(500, 1500))
		
		-- 공격 및 카운트
        self:attack(defender)
		self.m_tAttackCount[defender] = self.m_tAttackCount[defender] + 1

		-- 충돌 중에는 속도 줄임
		self.m_owner:setMove(self.m_chargePos.x ,self.m_chargePos.y, SPEED_COLLISION)

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
    skill:init_skill(animation_name, effect_res, attack_count)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end