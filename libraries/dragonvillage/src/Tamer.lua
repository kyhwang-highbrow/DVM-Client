local PARENT = Hero

-------------------------------------
-- class Tamer
-------------------------------------
Tamer = class(PARENT, {
        m_tamerTarget = 'char',
        m_tamerTargetEffect = 'vrp',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Tamer:init(file_name, body, ...)
    self.m_charType = 'tamer'
    self.m_tamerTargetEffect = MakeAnimator('res/indicator/indicator_effect_target/indicator_effect_target.vrp')
    self.m_tamerTargetEffect.m_node:retain()
    self.m_tamerTargetEffect:changeAni('idle', true)
end

-------------------------------------
-- function initAnimator
-------------------------------------
function Tamer:initAnimator(file_name)
    
end

-------------------------------------
-- function initAnimatorTamer
-------------------------------------
function Tamer:initAnimatorTamer(file_name)
    -- Animator 삭제
    if self.m_animator then
        if self.m_animator.m_node then
            self.m_animator.m_node:removeFromParent(true)
            self.m_animator.m_node = nil
        end
        self.m_animator = nil
    end

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeTamerAnimator(file_name)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node)
    end
end

Tamer.st_attack = PARENT.st_idle
Tamer.st_attack = PARENT.st_attack
Tamer.st_attackDelay = PARENT.st_attackDelay
Tamer.st_dying = PARENT.st_dying
Tamer.st_dead = PARENT.st_dead
Tamer.st_delegate = PARENT.st_delegate

-------------------------------------
-- function initState
-------------------------------------
function Tamer:initState()
    self:addState('idle', Tamer.st_idle, 'idle', true)
    self:addState('attack', Tamer.st_attack, 'attack', true) -- attack1
    self:addState('attackDelay', Tamer.st_attackDelay, 'idle', true)

    -- 테이머는 액티브 스킬이 없음
    --self:addState('skillPrepare', Tamer.st_skillPrepare, 'skill_appear', true)
    --self:addState('skillIdle', Tamer.st_skillIdle, 'skill_idle', true)
    --self:addState('skillAttack', Tamer.st_skillAttack, 'skill_idle', true)
    --self:addState('skillDisappear', Tamer.st_skillDisappear, 'skill_disappear', false)
    --
    self:addState('dying', Tamer.st_dying, 'idle', false, 9)
    self:addState('dead', Tamer.st_dead, nil, nil, 10)

    self:addState('delegate', Tamer.st_delegate, 'idle', true)
    self:addState('wait', Tamer.st_wait, 'idle', true)

    self:addState('stun', PARENT.st_stun, 'idle', true, PRIORITY.STUN)
	self:addState('stun_esc', PARENT.st_stun_esc, 'idle', true, PRIORITY.STUN_ESC)
    self:addState('comeback', PARENT.st_comeback, 'idle', true)

    -- 테이머만 고유하게 사용
    self:addState('started_directing', Tamer.st_started_directing, 'idle', true) -- move 애니메이션이 없음
    self:addState('started_directing2', Tamer.st_started_directing2, 'summon', false) -- charging

    -- success
    self:addState('success_pose', Hero.st_success_pose, 'pose_1', false)
    self:addState('success_move', Hero.st_success_move, 'idle', true)
end

-------------------------------------
-- function initStatus
-------------------------------------
function Tamer:initStatus(t_char, level, grade, evolution)
    PARENT.initStatus(self, t_char, level, grade, evolution)

    -- 테이머 기본 타겟 지정 인디케이터
    self.m_skillIndicator = SkillIndicator_Tamer(self)
end
-------------------------------------
-- function st_started_directing
-------------------------------------
function Tamer.st_started_directing(owner, dt)

    if (owner.m_stateTimer == 0) then

        local start_x = -100
        local start_y = -200
        local end_x = 800
        local speed = 1000
        local duration = math_abs(end_x - start_x) / speed

        -- 왼쪽에서 테이머가 등장하여 화면 중앙까지 달려나감 (저공비행)
        owner:setPosition(start_x, start_y)
        owner:setSpeed(0)

        local move_1 = cc.MoveTo:create(duration, cc.p(end_x, start_y))
        local func = cc.CallFunc:create(function() owner:dispatch('tamer_appear') end)
        local move_2 = cc.MoveTo:create(duration * 2, cc.p(owner.m_homePosX, owner.m_homePosY))
        local func2 = cc.CallFunc:create(function() owner:changeState('started_directing2') end)
        local secuence = cc.Sequence:create(
            cc.EaseInOut:create(move_1, 2),
            func,
            cc.EaseInOut:create(move_2, 1.5),
            func2)

        -- 액션 실행
        owner:runAction(secuence)
    else

        -- 위치 동기화
        local x, y = owner.m_rootNode:getPosition()
        if (owner.pos.x ~= x) or (owner.pos.y ~= y) then
            owner:setPosition(x, y)
        end
    end
end

-------------------------------------
-- function st_started_directing2
-------------------------------------
function Tamer.st_started_directing2(owner, dt)

    if (owner.m_stateTimer == 0) then
        SoundMgr:playEffect('EFFECT', 't_ready')

        local func1 = function()
            owner.m_animator:changeAni('summon') -- 'attack1'
        end

        local func2 = function()
            owner:dispatch('tamer_appear_done')
            owner.m_animator:changeAni('idle', true)
        end

        --owner:aniHandlerChain(func1, func2)

        owner:aniHandlerChain(func2)
    end
end

-------------------------------------
-- function setTamerTarget
-- @breif 테이머의 기본 타겟
-------------------------------------
function Tamer:setTamerTarget(target)
    self.m_tamerTarget = target

    self.m_tamerTargetEffect.m_node:removeFromParent()

    if target then    
        target.m_rootNode:addChild(self.m_tamerTargetEffect.m_node)
    end
end

-------------------------------------
-- function getTamerTarget
-- @breif 테이머의 기본 타겟
-------------------------------------
function Tamer:getTamerTarget()
    if (not self.m_tamerTarget) then
        return nil
    end

    if (self.m_tamerTarget.m_bDead) then
        self:setTamerTarget(nil)
        return nil
    end

    return self.m_tamerTarget
end

-------------------------------------
-- function checkTarget
-------------------------------------
function Tamer:checkTarget(t_skill)
    local target = self:getTamerTarget()
    if target then
        self.m_targetChar = target
        return
    end

    -- 기본 룰로 타겟 지정
    PARENT.checkTarget(self, t_skill)
end

-------------------------------------
-- function release
-------------------------------------
function Tamer:release()
    self.m_tamerTargetEffect.m_node:release()
    PARENT.release(self)
end

-------------------------------------
-- function dispatch
-------------------------------------
function Tamer:dispatch(event_name, ...)
    PARENT.dispatch(self, event_name, ...)

    -- 기본 공격 성공 시
    if (event_name == 'hit_basic') then
        local arg = {...}
        local target = arg[1]
        local activity_carrier = arg[2]
        self:onTamerHitBasic(target, activity_carrier)
    end
end


-------------------------------------
-- function onTamerHitBasic
-------------------------------------
function Tamer:onTamerHitBasic(target, activity_carrier)

    -- 중복실행되지 않기 위해 처리
    if (activity_carrier.m_lFlag['tamer_chain_attack'] == true) then
        return
    end

    activity_carrier.m_lFlag['tamer_chain_attack'] = true

    -- 10퍼센트로 발동
    --if (math_random(1, 100) <= 10) then
    -- @TODO 합동 공격 제외
    if false then 
        local idx = 0
        for _,char in pairs(self.m_world.m_lDragonList) do
            if (char.m_charType == 'dragon') and (not char.m_bDead) then
                idx = (idx + 1)
                local wait = (idx * 0.1)
                SkillLeonBasic:makeSkillInstnce(char, target.pos['x'], target.pos['y'], wait, 1, 2500, 0.5, nil)
            end
        end

        UIManager:toastNotificationGreen('합동 공격 발동!!')
    end
end