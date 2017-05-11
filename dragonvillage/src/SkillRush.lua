local PARENT = SkillCharge

-------------------------------------
-- class SkillRush
-------------------------------------
SkillRush = class(PARENT, {
		m_readyPosX = 'num',
		m_chargePosX = 'num',

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
-- @brief 부모함수를 호출하지 않는다... 연결성이 약함
-------------------------------------
function SkillRush:init_skill(hit)
	self.m_tAttackCount = {}
	self.m_maxAttackCount = hit
	self.m_preCollisionTime = 0

	if (self.m_owner.m_bLeftFormation) then
		self.m_readyPosX = -500
		self.m_chargePosX = 2000
	else
		self.m_readyPosX = 2000
		self.m_chargePosX = -500
	end

	self.m_chargeSpeed = 1500 -- g_constant:get('SKILL', 'AS_CHARGE_SPEED')
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
		self.m_atkPhysPosX = t_data['size']
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

	-- 캐릭터 돌격
	if (owner.m_stateTimer == 0) then
		char.m_animator:changeAni('skill_rush', true)
		char:setMove(owner.m_chargePosX, owner.m_targetPos.y, self.m_chargeSpeed)
		owner.m_afterimageMove = 0
		owner:makeCrashPhsyObject()

	-- 이동 완료 시 홈 좌표로 보내고 다음 연출 준비
	elseif (char.m_isOnTheMove == false) then
		char.m_animator:setVisible(false)
		char:setPosition(char.m_homePosX, char.m_homePosY)
        owner:changeState('comeback')
	
	-- 애프터 이미지
    else
        owner:updateAfterImage(dt)

	end
end

-------------------------------------
-- function st_comeback
-- @brief 스킬 종료 연출
-------------------------------------
function SkillRush.st_comeback(owner, dt)
	local char = owner.m_owner

	-- 제자리로 이동
	if (owner.m_stateTimer == 0) then
		char.m_animator:setVisible(true)
		char.m_animator:changeAni('skill_disappear', false)
		char.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillRush:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local charge_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)

	local hit = t_skill['hit'] -- 공격 횟수

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillRush(charge_res)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill(hit)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end