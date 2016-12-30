local PARENT = Character

-------------------------------------
-- class Monster
-------------------------------------
Monster = class(PARENT, {
        m_bWaitState = 'boolean',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster:init(file_name, body, ...)
    self.m_charType = 'monster'
    self.m_bWaitState = false
end

-------------------------------------
-- function initAnimator
-------------------------------------
function Monster:initAnimator(file_name)
end

-------------------------------------
-- function initAnimatorMonster
-------------------------------------
function Monster:initAnimatorMonster(file_name, attr)
    -- Animator 삭제
    if self.m_animator then
        if self.m_animator.m_node then
            self.m_animator.m_node:removeFromParent(true)
            self.m_animator.m_node = nil
        end
        self.m_animator = nil
    end

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeMonsterAnimator(file_name, attr)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node)
    end

    -- 각종 쉐이더 효과 시 예외 처리할 슬롯 설정(Spine)
    self:blockMatchingSlotShader('effect_')
end

-------------------------------------
-- function initState
-------------------------------------
function Monster:initState()
    PARENT.initState(self)

    self:addState('charge', Monster.st_charge, 'idle', true)
    self:addState('casting', Monster.st_casting, 'idle', true)

    self:addState('wait', Monster.st_wait, 'idle', true)
end

-------------------------------------
-- function st_charge
-------------------------------------
function Monster.st_charge(owner, dt)
    if (owner.m_stateTimer == 0) then

        -- 차지 이팩트 재생
        local res = 'res/effect/effect_attack_ready/effect_attack_ready.vrp'
        local animator = MakeAnimator(res)
        animator:changeAni('idle', false)
        owner.m_rootNode:addChild(animator.m_node)
        local duration = animator:getDuration()
        animator:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))

        local size_type = owner.m_charTable['size_type']
        if (size_type == 's') then
            animator:setPosition(0, -25)
        elseif (size_type == 'm') then
            animator:setPosition(0, -50)
        elseif (size_type == 'l') then
            animator:setPosition(0, -75)
        end

    elseif (owner.m_stateTimer >= 0.5) then
        owner.m_chargeDuration = owner.m_stateTimer
        owner:changeState('attack')
    end
end

-------------------------------------
-- function st_casting
-------------------------------------
function Monster.st_casting(owner, dt)
    PARENT.st_casting(owner, dt)

    if owner.m_state == 'casting' and owner.m_stateTimer == 0 then
        SoundMgr:playEffect('EFFECT', 'monster_skill_cast')
    end
end

-------------------------------------
-- function st_wait
-------------------------------------
function Monster.st_wait(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.speed = 0
    end
end

-------------------------------------
-- function setWaitState
-------------------------------------
function Monster:setWaitState(is_wait_state)
    self.m_bWaitState = is_wait_state

    if is_wait_state then
        if isExistValue(self.m_state, 'idle', 'attackDelay') then
            self:changeState('wait')
        end
    else
        if (self.m_state == 'wait') then
            self:changeState('attackDelay')
        end
    end
end

-------------------------------------
-- function release
-------------------------------------
function Monster:release()
    PARENT.release(self)

    if self.m_world then
        self.m_world:removeEnemy(self)
    end
end

-------------------------------------
-- function changeState
-- @param state
-- @param forced
-- @return boolean
-------------------------------------
function Monster:changeState(state, forced)
    if self.m_bWaitState then
        if (not isExistValue(state, 'dying', 'dead')) then
            return PARENT.changeState(self, 'wait', false)
        end
    end

    return PARENT.changeState(self, state, forced)
end