local PARENT = class(Skill, ISkillMultiAttack:getCloneTable())

-------------------------------------
-- class SkillAoERound
-------------------------------------
SkillAoERound = class(PARENT, {
		m_aoeRes = 'str', 
        m_aoe_res_predelay = 'num',
        m_multiAttackEffectFlag = 'bool',
        m_lTarget = 'table',
        m_lCollision = 'table'
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoERound:init(file_name, body, ...)    
    self.m_multiAttackEffectFlag = true
    self.m_lTarget = {}
    self.m_lCollision= {}
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoERound:init_skill(aoe_res, attack_count, aoe_res_predelay)
    PARENT.init_skill(self)

	-- 멤버 변수
    self.m_maxAttackCount = attack_count 
	self.m_aoeRes = aoe_res
    self.m_aoe_res_predelay = aoe_res_predelay or 0
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
    self:addState('attack', self.st_attack, 'idle', true)
	self:addState('disappear', PARENT.st_disappear, 'disappear', false)
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillAoERound:runAttack(l_collision)

    for _, collision in ipairs(l_collision) do
        self:attack(collision)
    end

	-- 특수한 부가 효과 구현
	self:doSpecialEffect(l_target)

	self:doCommonAttackEffect()
end

-------------------------------------
-- function setAttackInterval
-- @brief 스킬에 따라 오버라이딩 해서 사용
-------------------------------------
function SkillAoERound:setAttackInterval()
	-- 이펙트 재생 단위 시간
	self.m_hitInterval = 1
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
end

-------------------------------------
-- function escapeAttack
-- @brief 공격이 종료되는 시점에 실행
-------------------------------------
function SkillAoERound:escapeAttack()
	self:changeState('disappear')
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoERound:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local attack_count = t_skill['hit']	  -- 공격 횟수
	local aoe_res_predelay = tonumber(t_skill['val_1']) or 0

	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	-- 스킬 본연의 리소스
	local aoe_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)		-- 개별 타겟 이펙트 리소스

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoERound(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(aoe_res, attack_count, aoe_res_predelay)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end



-------------------------------------
-- function st_attack
-------------------------------------
function SkillAoERound.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:enterAttack()
        owner.m_lTarget, owner.m_lCollision = owner:findTarget()
    end
    owner.m_multiAtkTimer = owner.m_multiAtkTimer + dt
    if (owner.m_multiAttackEffectFlag) then
        if (owner.m_attackCount < owner.m_maxAttackCount) then

            -- 타겟별 리소스
            for _, target in ipairs(owner.m_lTarget) do
	            owner:makeEffect(owner.m_aoeRes, target.pos.x, target.pos.y)
            end
            owner.m_multiAttackEffectFlag = false
        end
    end

	if (owner.m_aoe_res_predelay < owner.m_multiAtkTimer) then
        -- 반복 공격
        if (owner.m_multiAtkTimer > owner.m_hitInterval) then
		    -- 공격 횟수 초과시 탈출
		    if (owner.m_attackCount >= owner.m_maxAttackCount) then
			    owner:escapeAttack()
		    else
			    owner:runAttack(owner.m_lCollision)
                owner.m_multiAtkTimer = owner.m_multiAtkTimer - owner.m_hitInterval
			    owner.m_attackCount = owner.m_attackCount + 1
                owner.m_multiAttackEffectFlag = true
		    end
        end
    end
end
