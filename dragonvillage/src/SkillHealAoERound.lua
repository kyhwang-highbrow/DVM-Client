local PARENT = class(Skill, ISkillMultiAttack:getCloneTable(), IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillHealAoERound
-------------------------------------
SkillHealAoERound = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillHealAoERound:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillHealAoERound:init_skill(hit)
	PARENT.init_skill(self)

    -- 멤버 변수
	self.m_maxAttackCount = hit 
    --self.m_hitInterval -> attack state에서 지정

    self:setPosition(self.m_targetPos.x, self.m_targetPos.y)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillHealAoERound:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', self.m_skillSize)  

		--self.m_resScale = t_data['scale']
		self.m_range = t_data['size']
	end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillHealAoERound:initState()
	self:setCommonState(self)
    self:addState('start', PARENT.st_appear, 'appear', false)
    self:addState('attack', PARENT.st_attack, 'idle', true)
	self:addState('disappear', PARENT.st_disappear, 'disappear', false)
end

-------------------------------------
-- function onStateDelegateEnter
-- @brief 
-------------------------------------
function SkillHealAoERound:onStateDelegateEnter()
    local owner = self.m_character

    owner.m_tStateAni['delegate'] = 'skill_disappear'
    owner.m_tStateAniLoop['delegate'] = false
end

-------------------------------------
-- function enterAttack
-- @brief 공격이 시작되는 시점에 실행
-------------------------------------
function SkillHealAoERound:enterAttack()
	-- 이펙트 재생 단위 시간
	self:setAttackInterval()
	-- 첫프레임부터 공격하기 위해서 인터벌 타임으로 설정
	self.m_multiAtkTimer = self.m_hitInterval
	-- 공격 카운트 초기화
	self.m_attackCount = 0
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillHealAoERound:runAttack()
    self:runHeal()
end

-------------------------------------
-- function escapeAttack
-- @brief 공격이 종료되는 시점에 실행
-------------------------------------
function SkillHealAoERound:escapeAttack()
	self:changeState('disappear')
end

-------------------------------------
-- function setAttackInterval
-------------------------------------
function SkillHealAoERound:setAttackInterval()
	local duration = 0
    
    -- 스킬의 에니메이션 길이를 적용
    if (self.m_animator) then
        duration = self.m_animator:getDuration()

    -- 스킬을 사용하는 주체의 에니메이션 길이를 적용 (드래곤의 스킬 후모션 길이)
    elseif (self.m_owner and self.m_owner.m_animator) then
        duration = self.m_owner.m_animator:getDuration()
    end

    -- 기본값 1초
    if (duration == 0) then
        duration = 1
    end

    -- 이펙트 재생 단위 시간
    self.m_hitInterval = (duration / self.m_maxAttackCount)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillHealAoERound:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	-- 스킬 본연의 리소스

    local hit = t_skill['hit'] -- 공격 횟수

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillHealAoERound(missile_res)

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
