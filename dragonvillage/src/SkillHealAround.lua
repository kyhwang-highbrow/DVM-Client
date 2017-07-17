local PARENT = Skill

-------------------------------------
-- class SkillHealAround
-------------------------------------
SkillHealAround = class(PARENT, {
        m_limitTime = '',
        m_multiHitTime = '',
        m_multiHitTimer = '',
        m_multiHitMax = '',
        m_hitCount = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillHealAround:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillHealAround:init_skill(duration, hit_cnt)
	PARENT.init_skill(self)

    -- 멤버 변수
    self.m_hitCount = 0
    self.m_limitTime = duration
    self.m_multiHitTime = self.m_limitTime / hit_cnt -- 한 번 회복하는데 걸리는 시간(쿨타임)
    self.m_multiHitMax = hit_cnt - 1 -- 회복 횟수 (시간 계산 오차로 추가로 회복되는것 방지)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillHealAround:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', self.m_skillSize)  
		
		--self.m_resScale = t_data['scale']
		self.m_range = t_data['size']
	end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillHealAround:initState()
	self:setCommonState(self)
    self:addState('start', SkillHealAround.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillHealAround.st_idle(owner, dt)

    if (owner.m_stateTimer == 0) then
        owner.m_hitCount = 0
        owner.m_multiHitTimer = 0
    end

    -- 위치 이동
    local x = owner.m_owner.pos.x
    local y = owner.m_owner.pos.y
    owner:setPosition(x, y)

    -- 내부 쿨타임 동작
    owner.m_multiHitTimer = owner.m_multiHitTimer + dt
    if (owner.m_multiHitTimer >= owner.m_multiHitTime) and
        (owner.m_hitCount < owner.m_multiHitMax ) then

        owner:runHeal()

        owner.m_multiHitTimer = owner.m_multiHitTimer - owner.m_multiHitTime
        owner.m_hitCount = owner.m_hitCount + 1
    end

    -- 종료
    if ((not owner.m_owner) or owner.m_owner:isDead()) or (owner.m_stateTimer >= owner.m_limitTime) then
        owner:changeState('dying')
        return
    end
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillHealAround:findCollision()
    local l_target = self:getProperTargetList()
	local x = self.m_owner.pos.x
	local y = self.m_owner.pos.y
	local range = self.m_range

	local l_ret = SkillTargetFinder:findCollision_AoERound(l_target, x, y, range)

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillHealAround:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local duration = owner.m_statusCalc.m_attackTick
	local hit_cnt = t_skill['hit']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillHealAround(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(duration, hit_cnt)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
