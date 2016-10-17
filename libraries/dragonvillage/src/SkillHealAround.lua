-------------------------------------
-- class SkillHealAround
-------------------------------------
SkillHealAround = class(Entity, {
        m_owner = 'Character',

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
function SkillHealAround:init_skill(owner, res, x, y, t_skill)
    self.m_owner = owner

    local range = t_skill['val_1']
    self.m_range = range

    -- 쿨타임 지정
    local duration = owner.m_statusCalc.m_attackTick
    self.m_limitTime = duration
    local hit = math_max(t_skill['hit'], 1) -- 회복 횟수
    self.m_multiHitTime = self.m_limitTime / hit -- 한 번 회복하는데 걸리는 시간(쿨타임)
    self.m_multiHitMax = hit - 1 -- 회복 횟수 (시간 계산 오차로 추가로 회복되는것 방지)

    -- 1회당 회복량 비율
    self.m_healRate = (t_skill['power_rate'] / 100)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillHealAround:initState()
    self:addState('idle', SkillHealAround.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    self:changeState('idle')
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
        owner:heal()

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
function SkillHealAround:findTarget(count)

    local world = self.m_owner.m_world
    local target_formation_mgr = nil

    if self.m_owner.m_bLeftFormation then
        target_formation_mgr = world.m_leftFormationMgr
    else
        target_formation_mgr = world.m_rightFormationMgr
    end

    local l_remove = {}
    -- 본인도 포함하도록 변경
    --l_remove[self.m_owner.phys_idx] = true

    local l_target = target_formation_mgr:findNearTarget(self.pos.x, self.pos.y, self.m_range, -1, l_remove)
    self.m_tTargetList = l_target
end

-------------------------------------
-- function heal
-------------------------------------
function SkillHealAround:heal()

    local atk_dmg = self.m_owner.m_statusCalc:getFinalStat('atk')
    local heal = HealCalc_M(atk_dmg)

    heal = (heal * self.m_healRate)

    for i,v in pairs(self.m_tTargetList) do
        v:healAbs(heal)
    end
end