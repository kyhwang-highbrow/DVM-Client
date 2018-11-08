local PARENT = class(Skill, ISkillMultiAttack:getCloneTable(), IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillAoERound
-------------------------------------
SkillAoERound = class(PARENT, {
		m_aoeRes = 'str', 
        m_aoeEffectCount = 'number',
        m_aoeEffectTimer = 'number',

        m_lCollision = 'table'
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoERound:init(file_name, body, ...)    
    self.m_aoeEffectCount = 0
    self.m_aoeEffectTimer = 0
    self.m_lCollision = {}
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoERound:init_skill(aoe_res, attack_count, aoe_res_delay)
    PARENT.init_skill(self)

	-- 멤버 변수
    self.m_maxAttackCount = attack_count 
    self.m_multiAtkDelay = aoe_res_delay or 0
	self.m_aoeRes = aoe_res
    
	--self.m_hitInterval -> attack state에서 지정
	
	self:setPosition(self.m_targetPos.x, self.m_targetPos.y)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillAoERound:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_range = t_data['size']
	end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoERound:initState()
	self:setCommonState(self)
    self:addState('start', PARENT.st_appear, 'appear', false)
    self:addState('attack', SkillAoERound.st_attack, 'idle', false)
	self:addState('disappear', PARENT.st_disappear, 'disappear', false)
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillAoERound.st_attack(owner, dt)
    PARENT.st_attack(owner, dt)

    owner.m_aoeEffectTimer = owner.m_aoeEffectTimer + dt

    -- 공격 타이머와는 별개로 이펙트를 출력(공격 딜레이가 있는 경우 때문)
    if (owner.m_aoeEffectTimer > owner.m_hitInterval) then
        if (owner.m_aoeEffectCount < owner.m_maxAttackCount) then
            owner:doAoeEffect()
            owner.m_aoeEffectTimer = owner.m_aoeEffectTimer - owner.m_hitInterval
            owner.m_aoeEffectCount = owner.m_aoeEffectCount + 1
        end
    end
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillAoERound:runAttack()
    local collisions = self.m_lCollision

    for _, collision in ipairs(collisions) do
        self:attack(collision)
    end

	self:doCommonAttackEffect()
end

-------------------------------------
-- function setAttackInterval
-- @brief 스킬에 따라 오버라이딩 해서 사용
-------------------------------------
function SkillAoERound:setAttackInterval()
    local duration = 0
    
    if (self.m_animator) then
        duration = self.m_animator:getDuration()
    end

	-- 이펙트 재생 단위 시간
    if (duration == 0) then
        self.m_hitInterval = 1 / self.m_maxAttackCount
    else
	    self.m_hitInterval = duration / self.m_maxAttackCount
    end
end

-------------------------------------
-- function onStateDelegateEnter
-- @brief 
-------------------------------------
function SkillAoERound:onStateDelegateEnter()
    local owner = self.m_character

    owner.m_tStateAni['delegate'] = 'skill_disappear'
    owner.m_tStateAniLoop['delegate'] = false
end

-------------------------------------
-- function enterAttack
-------------------------------------
function SkillAoERound:enterAttack()
	-- 이펙트 재생 단위 시간
	self:setAttackInterval()
	-- 첫프레임부터 공격하기 위해서 인터벌 타임으로 설정
	self.m_multiAtkTimer = self.m_hitInterval
	-- 공격 카운트 초기화
	self.m_attackCount = 0

    -- 개별 이펙트 관련 정보 초기화
    self.m_aoeEffectCount = 0
    self.m_aoeEffectTimer = self.m_hitInterval

    -- 피격될 리스트를 얻어옴(해당 스킬이 패시브 스킬에서도 사용된다고 하면 수정 필요!!!)
    self.m_lCollision = self:getProperCollisionList()
end

-------------------------------------
-- function escapeAttack
-- @brief 공격이 종료되는 시점에 실행
-------------------------------------
function SkillAoERound:escapeAttack()
	self:changeState('disappear')
end

-------------------------------------
-- function doAoeEffect
-- @brief 개별 이펙트를 표시
-------------------------------------
function SkillAoERound:doAoeEffect()
    if (not self.m_aoeRes) then return end

    local collisions = self.m_lCollision

    -- 타겟별 리소스
    for _, collision in ipairs(collisions) do
        self:makeEffect(self.m_aoeRes, collision:getPosX(), collision:getPosY())
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoERound:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local attack_count = t_skill['hit']	  -- 공격 횟수
	local aoe_res_delay = tonumber(t_skill['val_1']) or 0
    
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	-- 스킬 본연의 리소스
	local aoe_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)		-- 개별 타겟 이펙트 리소스

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoERound(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(aoe_res, attack_count, aoe_res_delay)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end