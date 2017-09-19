local PARENT = SkillAoESquare

-------------------------------------
-- class SkillAoESquare_Charge
-------------------------------------
SkillAoESquare_Charge = class(PARENT, {
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
function SkillAoESquare_Charge:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoESquare_Charge:init_skill(hit, effect_res)
    PARENT.init_skill(self, hit)

	self.m_addEffectRes = effect_res

	if (self:isRightFormation()) then
        self.m_readyPosX = 2000
		self.m_chargePosX = -500
	else
		self.m_readyPosX = -500
		self.m_chargePosX = 2000
	end

	self.m_chargeSpeed = g_constant:get('SKILL', 'AS_CHARGE_SPEED')
	self.m_comebackSpeed = g_constant:get('SKILL', 'AS_COMEBACK_SPEED')
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoESquare_Charge:initState()
	self:setCommonState(self)
	-- @TODO 임시로 통짜리소스 동작되도록 처리... appear, disapper애니 추가 필요
	self:addState('start', SkillAoESquare_Charge.st_ready, nil, false)
	self:addState('charge', SkillAoESquare_Charge.st_charge, nil, false)
	self:addState('comeback', SkillAoESquare_Charge.st_comeback, nil, false)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillAoESquare_Charge:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('square_width', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_skillHeight = t_data['size']
	end
end

-------------------------------------
-- function st_ready
-- @brief 돌진을 위해 뿅하고 사라짐
-------------------------------------
function SkillAoESquare_Charge.st_ready(owner, dt)
	-- 캐릭터가 사라지는 연출과 동시에 돌진 준비 좌표로 보냄
	if (owner.m_stateTimer == 0) then
		local res = 'res/effect/effect_appear/effect_appear.spine'
		local function cb_func() 
			owner:changeState('charge') 
		end

		local char = owner.m_owner
		owner:makeEffect(res, char.pos.x, char.pos.y, 'idle', cb_func)
		char:setPosition(owner.m_readyPosX, owner.m_targetPos.y)
	end
end

-------------------------------------
-- function st_charge
-- @brief 돌격!
-------------------------------------
function SkillAoESquare_Charge.st_charge(owner, dt)
	-- 공격
	PARENT.st_attack(owner, dt)

	local char = owner.m_owner

	-- 캐릭터 돌격
	if (owner.m_stateTimer == 0) then
		char:setMove(owner.m_chargePosX, owner.m_targetPos.y, owner.m_chargeSpeed)
		char:setAfterImage(true)

	-- 이동 완료 시 다시 돌진 준비 좌표로 보내고 종료
	elseif (char.m_isOnTheMove == false) then
        owner:changeState('comeback')
		char:setPosition(owner.m_readyPosX, char.m_homePosY)

	end
end

-------------------------------------
-- function st_comeback
-- @brief 돌격 후 뒤에서부터 다시 나타나 제자리로 위치
-------------------------------------
function SkillAoESquare_Charge.st_comeback(owner, dt)
	local char = owner.m_owner

	-- 제자리로 이동
	if (owner.m_stateTimer == 0) then
		char:setMoveHomePos(owner.m_comebackSpeed)
		char:setAfterImage(false)

	-- 이동 완료시 종료
    elseif (char.m_isOnTheMove == false) then
        owner:changeState('dying')

    end
end

-------------------------------------
-- function enterAttack
-- @brief 공격이 시작되는 시점에 실행
-------------------------------------
function SkillAoESquare_Charge:enterAttack()
	-- 이펙트 재생 단위 시간
	self:setAttackInterval()
	-- 첫 공격은 1 인터벌 타임이 지난후 발동되도록 함
	self.m_multiAtkTimer = 0
	-- 공격 카운트 초기화
	self.m_attackCount = 0
end

-------------------------------------
-- function setAttackInterval
-------------------------------------
function SkillAoESquare_Charge:setAttackInterval()
	self.m_hitInterval = 0.4
end

-------------------------------------
-- function escapeAttack
-- @brief 공격이 종료되는 시점에 실행
-------------------------------------
function SkillAoESquare_Charge:escapeAttack()
	-- NOTHING TO DO
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoESquare_Charge:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local charge_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local effect_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)
	
	local hit = t_skill['hit'] -- 공격 횟수

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoESquare_Charge(charge_res)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill(hit, effect_res)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
