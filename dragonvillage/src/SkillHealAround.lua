local PARENT = Skill

-------------------------------------
-- class SkillHealAround
-------------------------------------
SkillHealAround = class(PARENT, {
        m_range = 'number',
        m_tTargetList = 'list',
        m_limitTime = '',
        m_multiHitTime = '',
        m_multiHitTimer = '',
        m_multiHitMax = '',
        m_hitCount = '',
        m_healRate = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillHealAround:init(file_name, body, ...)

    self.m_hitCount = 0

    self:initState()
end


-------------------------------------
-- function init_skill
-------------------------------------
function SkillHealAround:init_skill(range, duration, hit_cnt)
	PARENT.init_skill(self)

    -- 멤버 변수
    self.m_range = range
    self.m_limitTime = duration
    self.m_multiHitTime = self.m_limitTime / hit_cnt -- 한 번 회복하는데 걸리는 시간(쿨타임)
    self.m_multiHitMax = hit_cnt - 1 -- 회복 횟수 (시간 계산 오차로 추가로 회복되는것 방지)
    self.m_healRate = (self.m_powerRate / 100)
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

        -- 타겟 지정
        owner:findTarget()
        owner:doHeal()

        owner.m_multiHitTimer = owner.m_multiHitTimer - owner.m_multiHitTime
        owner.m_hitCount = owner.m_hitCount + 1
    end

    -- 종료
    if ((not owner.m_owner) or owner.m_owner.m_bDead) or (owner.m_stateTimer >= owner.m_limitTime) then
        owner:changeState('dying')
        return
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillHealAround:findTarget()
    local world = self.m_owner.m_world
    local target_formation_mgr = self.m_owner:getFormationMgr() 

    local l_remove = {}
    local l_target = target_formation_mgr:findNearTarget(self.pos.x, self.pos.y, self.m_range, -1, l_remove)
    self.m_tTargetList = l_target
end

-------------------------------------
-- function heal
-------------------------------------
function SkillHealAround:doHeal()

    local atk_dmg = self.m_owner.m_statusCalc:getFinalStat('atk')
    local heal = HealCalc_M(atk_dmg)

    heal = (heal * self.m_healRate)

    for i,v in pairs(self.m_tTargetList) do
        v:healAbs(heal)
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillHealAround:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local range = t_skill['val_1']
	local duration = owner.m_statusCalc.m_attackTick
	local hit_cnt = t_skill['hit']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillHealAround(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(range, duration, hit_cnt)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode(nil, skill.m_bHighlight)
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
