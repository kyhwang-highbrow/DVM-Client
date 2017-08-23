local PARENT = SkillCharge

-------------------------------------
-- class SkillRush
-------------------------------------
SkillRush = class(PARENT, {
		m_chargeRes = 'str',
		m_chargeEffect = 'Effect',
		m_chargeScale = 'num',
		m_originScale = 'num',

		m_readyPosX = 'num',
		m_atkPhysSize = 'num',

		m_chargeSpeed = 'num',
		m_comebackSpeed = 'num',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillRush:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillRush:init_skill(hit, charge_res)
	PARENT.init_skill(self, hit)

	self.m_atkPhysSize = 150
	self.m_speedMove = 1500
	self.m_speedCollision = 100
	
	-- 스케일 변수
	self.m_originScale = self.m_owner.m_animator:getScale()
	self.m_chargeScale = self.m_originScale * 1.25

	-- 참조 좌표값 선언
	self.m_chargePos = {x = 0, y = self.m_targetPos.y}

	local std_pos_x = self.m_owner.m_homePosX
	if (self.m_owner.m_bLeftFormation) then
		self.m_readyPosX = std_pos_x - 800
		self.m_chargePos.x = std_pos_x + 2000
	else
		self.m_readyPosX = std_pos_x + 800
		self.m_chargePos.x = std_pos_x - 2000
	end

	-- 돌진 리소스 세팅
	do
		self.m_chargeEffect = MakeAnimator(charge_res)
		self.m_chargeEffect:setAniAttr(self.m_owner:getAttribute())
		self.m_owner.m_rootNode:addChild(self.m_chargeEffect.m_node)
		self.m_chargeEffect:setVisible(false)
		self.m_chargeEffect:setPositionX(-100)
		self.m_chargeEffect:setScale(1.5)

        if (not self.m_owner.m_bLeftFormation) then
            self.m_chargeEffect:setPositionX(-100)

        elseif (not self.m_owner.m_bLeftFormation) then
            self.m_chargeEffect:setPositionX(100)
            self.m_chargeEffect:setFlip(true)
        end
	end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillRush:initState()
	self:setCommonState(self)
	-- @TODO 임시로 통짜리소스 동작되도록 처리... appear, disapper애니 추가 필요
	self:addState('start', SkillRush.st_ready, nil, false)
	self:addState('charge', SkillRush.st_charge, nil, false)
	self:addState('comeback', SkillRush.st_comeback, nil, false)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillRush:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('square_width', self.m_skillSize)  
		self.m_atkPhysSize = t_data['size']
	end
end

-------------------------------------
-- function st_ready
-- @brief 돌진을 위해 뿅하고 사라짐
-------------------------------------
function SkillRush.st_ready(owner, dt)
	-- 캐릭터가 사라지는 연출과 동시에 돌진 준비 좌표로 보냄
	if (owner.m_stateTimer == 0) then
		local res = 'res/effect/tamer_magic_1/tamer_magic_1.vrp'
		local function cb_func() 
			owner:changeState('charge') 
		end

		local char = owner.m_owner
		owner:makeEffect(res, char.pos.x, char.pos.y, 'bomb', cb_func)
		char:setPosition(owner.m_readyPosX, owner.m_targetPos.y)
	end
end

-------------------------------------
-- function st_charge
-- @brief 돌격!
-------------------------------------
function SkillRush.st_charge(owner, dt)
	local char = owner.m_owner

	-- 캐릭터 돌격 시작
	if (owner.m_stateTimer == 0) then
		owner:makeCrashPhsyObject()

		-- 이동 및 ani 변경
		char:setMove(owner.m_chargePos.x, owner.m_chargePos.y, owner.m_speedMove)
        char.m_animator:changeAni('skill_rush', true)
		char:setAfterImage(true)
		
		-- 돌격시 캐릭터 스케일 키움
		char.m_animator:setScale(owner.m_chargeScale)

		-- 돌격 이펙트 추가
		owner.m_chargeEffect:setVisible(true)
		owner.m_chargeEffect:changeAni('idle', true)

	-- 이동 완료 시 홈 좌표로 보내고 다음 연출 준비
	elseif (char.m_isOnTheMove == false) then
		-- 돌격 이펙트 삭제
		owner.m_chargeEffect.m_node:removeFromParent(true)
		owner.m_chargeEffect = nil

		char.m_animator:setVisible(false)
		char:setPosition(char.m_homePosX, char.m_homePosY)
		char:setMoveHomePos(owner.m_speedComeback)
		char:setAfterImage(false)

        owner:changeState('comeback')

    elseif (owner.m_stateTimer > owner.m_prevCollisionTime + 0.3) then
        owner.m_owner:setMove(owner.m_chargePos.x ,owner.m_chargePos.y, owner.m_speedMove)
		owner.m_prevCollisionTime = owner.m_stateTimer

	end
end

-------------------------------------
-- function st_comeback
-- @brief 스킬 종료 연출
-------------------------------------
function SkillRush.st_comeback(owner, dt)
	local char = owner.m_owner

	if (owner.m_stateTimer == 0) then
		-- 제자리로 이동
		char:setMoveHomePos(owner.m_speedComeback)

		-- 캐릭터 스케일 원복
		char.m_animator:setScale(owner.m_originScale)

		-- 복귀 연출
		char.m_animator:setVisible(true)
		char.m_animator:changeAni('skill_disappear', false)
		char.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function onStateDelegateExit
-- @brief 강제 종료 될 경우 원복 처리
-------------------------------------
function SkillRush:onStateDelegateExit()
	-- 돌격 이펙트 삭제
	if (self.m_chargeEffect) then
		self.m_chargeEffect.m_node:removeFromParent(true)
		self.m_chargeEffect = nil
	end

	-- 캐릭터 스케일 원복
	self.m_owner.m_animator:setScale(self.m_originScale)

	-- 잔상 해제
	self.m_owner:setAfterImage(false)
end

-------------------------------------
-- function makeCrashPhsyObject
-- @overriding
-------------------------------------
function SkillRush:makeCrashPhsyObject()
    if (self.m_physObject) then
        error('이미 충돌박스가 존재')
    end

    local char = self.m_owner
    local object_key = char:getAttackPhysGroup()

    local phys_object = char:addPhysObject(char, object_key, {0, 0, self.m_atkPhysSize/2}, 0, 0)
    phys_object:addAtkCallback(function(attacker, defender, i_x, i_y, body_key)
        self:doChargeAttack(defender, body_key)
		phys_object:clearCollisionObjectList()
    end)

    self.m_physObject = phys_object
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillRush:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local charge_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)

	local hit = t_skill['hit'] -- 공격 횟수

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillRush(nil)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill(hit, charge_res)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end