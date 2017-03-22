local PARENT = Dragon

-------------------------------------
-- class Tamer
-------------------------------------
Tamer = class(PARENT, {
        -- 기본 정보
        m_tamerID = '',    -- 드래곤의 고유 ID

        m_barrier = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Tamer:init(file_name, body, ...)
    self.m_charType = 'tamer'
end

-------------------------------------
-- function initAnimator
-------------------------------------
function Tamer:initAnimator(file_name)
    Character.initAnimator(self, file_name)

    -- 보호막
    self.m_barrier = MakeAnimator('res/effect/effect_tamer_shield/effect_tamer_shield.vrp')
    self.m_barrier.m_node:setScale(0.5)
    self.m_rootNode:addChild(self.m_barrier.m_node)
end

-------------------------------------
-- function initState
-------------------------------------
function Tamer:initState()
    PARENT.initState(self)

    self:addState('idle', PARENT.st_idle, 'i_idle', true)
    self:addState('attack', PARENT.st_idle, 'i_idle', false)
    self:addState('attackDelay', PARENT.st_idle, 'i_idle', true)
    self:addState('charge', PARENT.st_idle, 'i_idle', true)
    self:addState('casting', PARENT.st_idle, 'i_idle', true)

    self:addState('wait', PARENT.st_wait, 'i_idle', true)
    self:addState('move', PARENT.st_move, 'i_idle', true)

    self:addState('success_pose', PARENT.st_success_pose, 'i_idle', true)
    self:addState('success_move', PARENT.st_success_move, 'i_idle', true)

    self:addState('dying', Tamer.st_dying, 'i_dying', false, PRIORITY.DYING)
    self:addState('comeback', PARENT.st_comeback, 'i_idle', true)
end

-------------------------------------
-- function release
-------------------------------------
function Tamer:release()
    Entity.release(self)
end

-------------------------------------
-- function update
-------------------------------------
function Tamer:update(dt)
    if self.m_bUseSelfAfterImage then
        self:updateAfterImage(dt)
    end
        
    return Character.update(self, dt)
end

-------------------------------------
-- function st_dying
-------------------------------------
function Tamer.st_dying(owner, dt)
    PARENT.st_dying(owner, dt)

    if (owner.m_stateTimer == 0) then
		owner.m_barrier:changeAni('disappear', false)
        owner.m_barrier:addAniHandler(function()
            owner.m_barrier:setVisible(false)
        end)
    end
end