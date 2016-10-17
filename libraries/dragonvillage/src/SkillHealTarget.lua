-------------------------------------
-- class SkillHealTarget
-- @brief
-- t_skill
-- ['res_1']      -- 시전자와 타겟이 연결되는 link effect
-- ['val_1']      -- 타겟 카운트
-- ['hit']        -- 한 타겟에 회복하는 횟수
-- ['power_rate'] -- 한 번에 회복(heal)하는 양
-------------------------------------
SkillHealTarget = class(Entity, {
        m_owner = 'Character',

        -- 타겟 대상 리스트, 링크 이펙트(link effect) 리스트
        m_tTargetList = 'List',
        m_tEffectList = 'List',

        -- t_skill에서 얻어오는 데이터
        m_res = 'string',            -- t_skill['res_1']
        m_targetCount = 'number',    -- t_skill['val_1']
        m_maxRepeatCount = 'number', -- t_skill['hit']
        m_healPercent = 'float',     -- t_skill['power_rate']

        -- 내부에서 사용하는 변수들
        m_duration = 'number',      -- 스킬 지속 시간
        m_repeatTime = 'number',    -- 반복 간격
        m_repeatTimer = 'number',   -- 반복 타이머
        m_repeatCount = 'number',   -- 실시간 반복 횟수
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillHealTarget:init(file_name, body, ...)
    self:initState()
end


-------------------------------------
-- function init_skill
-------------------------------------
function SkillHealTarget:init_skill(owner, t_skill)
    -- 스킬 시전자
    self.m_owner = owner

    -- t_skill에서 얻어오는 데이터
    self.m_res = string.gsub(t_skill['res_1'], '@', owner.m_charTable['attr'])
    self.m_targetCount = t_skill['val_1']
    self.m_maxRepeatCount = math_max(t_skill['hit'], 1) -- 회복 횟수
    self.m_maxRepeatCount = (self.m_maxRepeatCount - 1) -- 회복 횟수 (시간 계산 오차로 추가로 회복되는것 방지)
    self.m_healPercent = (t_skill['power_rate'] / 100)

    -- 쿨타임 지정
    self.m_duration = owner.m_statusCalc.m_attackTick
    self.m_repeatTime = self.m_duration / (self.m_maxRepeatCount + 1) -- 한 번 회복하는데 걸리는 시간(쿨타임)

    -- 타겟 지정
    self.m_tTargetList = self:findTarget(t_skill, self.m_targetCount)
    self.m_tEffectList = {}

    -- 이펙트 생성
    for i,v in ipairs(self.m_tTargetList) do        
        local effect = self:makeEffect(i, self.m_res, v.pos.x, v.pos.y)
        table.insert(self.m_tEffectList, effect)
    end
    self:updatePos()

    -- cast_effect 사용
    self:initAnimator(self.m_res)
    self:changeState('idle')
end

-------------------------------------
-- function initState
-------------------------------------
function SkillHealTarget:initState()
    self:addState('idle', SkillHealTarget.st_idle, 'cast_effect', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillHealTarget.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_repeatCount = 0
        owner.m_repeatTimer = 0
    end

    -- 위치 이동
    local x = owner.m_owner.pos.x
    local y = owner.m_owner.pos.y
    owner:setPosition(x, y)

    -- 내부 쿨타임 동작
    owner.m_repeatTimer = owner.m_repeatTimer + dt
    if ((owner.m_repeatTimer >= owner.m_repeatTime) and (owner.m_repeatCount < owner.m_maxRepeatCount )) then
        owner:heal()
        owner.m_repeatTimer = owner.m_repeatTimer - owner.m_repeatTime
        owner.m_repeatCount = owner.m_repeatCount + 1
    end

    -- 종료
    if ((not owner.m_owner) or owner.m_owner.m_bDead) or (owner.m_stateTimer >= owner.m_duration) then
        owner:changeState('dying')
        return
    end

    owner:updatePos()
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillHealTarget:findTarget(t_skill, count)
    local l_target = self.m_owner:getTargetList(t_skill)
    local l_ret = {}

    for i,target in ipairs(l_target) do
        table.insert(l_ret, target)
        if (count <= i) then
            break
        end
    end

    return l_ret
end

-------------------------------------
-- function heal
-------------------------------------
function SkillHealTarget:heal()
    local atk_dmg = self.m_owner.m_statusCalc:getFinalStat('atk')
    local heal = HealCalc_M(atk_dmg) * self.m_healPercent

    for i,v in pairs(self.m_tTargetList) do
        if (not v.m_bDead) then
            v:healAbs(heal)
            local effect = self.m_world:addInstantEffect(self.m_res, 'heal_effect', v.pos.x, v.pos.y)
        end
    end


end

-------------------------------------
-- function makeEffect
-------------------------------------
function SkillHealTarget:makeEffect(idx, res, x, y)
    local file_name = res
    local start_ani = 'start_idle'
    local link_ani = 'bar_idle'
    local end_ani = 'end_idle'

    local link_effect = LinkEffect(file_name, link_ani, start_ani, end_ani, 200, 200)
    link_effect.m_bRotateEndEffect = false

    link_effect.m_startPointNode:setScale(0.15)
    link_effect.m_endPointNode:setScale(0.3)

    self.m_rootNode:addChild(link_effect.m_node)

    return link_effect
end

-------------------------------------
-- function updatePos
-------------------------------------
function SkillHealTarget:updatePos()
    for i,v in ipairs(self.m_tTargetList) do
        local effect = self.m_tEffectList[i]

        -- 상대좌표 사용
        local tar_x = (v.pos.x - self.pos.x)
        local tar_y = (v.pos.y - self.pos.y)

        LinkEffect_refresh(effect, 0, 0, tar_x, tar_y)
    end
end