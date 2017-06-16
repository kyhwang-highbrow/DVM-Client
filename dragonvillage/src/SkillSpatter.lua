local PARENT = Skill

-------------------------------------
-- class SkillSpatter
-------------------------------------
SkillSpatter = class(PARENT, {
        m_owner = 'Character',
        m_spatterCount = 'number',
        m_spatterMaxCount = 'number',
        m_spatterHealRate = 'number',

        m_stdPosX = 'number',
        m_stdPosY = 'number',

        m_prevPosX = 'number',
        m_prevPosY = 'number',

		m_lTargetList = 'Character list',
		m_targetIdx = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillSpatter:init(file_name, body, ...)
    self:initState()
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillSpatter:init_skill(motionstreak_res, count)
	-- 멤버 변수
    self.m_spatterCount = 0
    self.m_spatterMaxCount = count
    self.m_spatterHealRate = self.m_powerRate / 100

    self.m_stdPosX = self.m_owner.pos.x
    self.m_stdPosY = self.m_owner.pos.y

    self.m_prevPosX = self.m_stdPosX
    self.m_prevPosY = self.m_stdPosY

	self.m_lTargetList = self:findTarget()
	self.m_targetIdx = 1

	-- 위치 지정 및 모션스트릭	
	self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
    self:setMotionStreak(self.m_world:getMissileNode(), motionstreak_res)

	-- 스킬 효과 시작
    self:spatterHeal(self.m_owner) -- 시전자는 회복을 하고 시작
    self:trySpatter()
end

-------------------------------------
-- function initState
-------------------------------------
function SkillSpatter:initState()
    if (self.m_bSkillHitEffect) then
        self:setCommonState(self)
    end
    self:addState('idle', SkillSpatter.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillSpatter.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		local target_char = owner:getNextTarget()

        -- JumpTo액션 실행
		if (target_char) then
			local target_pos = cc.p(target_char.pos.x, target_char.pos.y)
			local action = cc.JumpTo:create(0.5, target_pos, 100, 1)

			-- 액션 종료 후 타겟을 회복, 튀기기 시도
			local function end_func()
				owner:spatterHeal(target_char)
				owner:trySpatter()
			end

			local sequence = cc.Sequence:create(action, cc.CallFunc:create(end_func))
			owner.m_rootNode:runAction(sequence)
		else
			owner:changeState('dying')
		end
    end

    -- m_rootNode의 위치로 클래스위 위치 동기화, 각도 지정
    local x, y = owner.m_rootNode:getPosition()
    local degree = getDegree(owner.m_prevPosX, owner.m_prevPosY, x, y)
    owner:setRotation(degree)
    owner:setPosition(x, y)
    owner.m_prevPosX, owner.m_prevPosY = x, y
end

-------------------------------------
-- function trySpatter
-------------------------------------
function SkillSpatter:trySpatter()
	if (self.m_spatterCount >= self.m_spatterMaxCount) then
        self:changeState('dying')
        return false
    end

    self:changeState('idle')
    
	self.m_spatterCount = self.m_spatterCount + 1
    return true
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillSpatter:findTarget()
    return self:getProperTargetList()
end

-------------------------------------
-- function spatterHeal
-------------------------------------
function SkillSpatter:spatterHeal(target_char)
    if (target_char.m_bDead) then
        return
    end

    -- 시전자의 공격력에 비례한 회복
	local atk_dmg = self.m_owner:getStat('atk')
	local heal = HealCalc_M(atk_dmg) * self.m_spatterHealRate
    target_char:healAbs(self.m_owner, heal, true)

	-- 힐 사운드
	if (self.m_owner:isDragon()) then
		SoundMgr:playEffect('SFX', 'sfx_heal')
	end
end

-------------------------------------
-- function getNextTarget
-------------------------------------
function SkillSpatter:getNextTarget()
	local target_char

	local target_char = self.m_lTargetList[self.m_targetIdx]
	
	-- 타겟이 없거나 죽었을 시 다음 적절한 타겟을 찾기 위해 타겟리스트를 순서대로 한번 순회
	local idx = 0
	while (not target_char) or (target_char.m_bDead) do
		idx = idx + 1
		self.m_targetIdx = self.m_targetIdx + 1
		target_char = self.m_lTargetList[self.m_targetIdx]

		if (self.m_targetIdx > #self.m_lTargetList) then
			self.m_targetIdx = 0
		end

		if (idx > #self.m_lTargetList) then
			break
		end
	end

	self.m_targetIdx = self.m_targetIdx + 1
	return target_char
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillSpatter:makeSkillInstance(owner, t_skill)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
    local motionstreak_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)
    local count = t_skill['hit']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillSpatter(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, {})
    skill:init_skill(motionstreak_res, count)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('idle')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end