local PARENT = LobbyCharacter

-------------------------------------
-- class LobbyTamer
-------------------------------------
LobbyTamer = class(PARENT, {
        m_userData = '',
        m_attackTarget = '',
        m_dragon = '',
        m_ui = '',
     })

LobbyTamer.MOVE_ACTION = 100

-------------------------------------
-- function init
-------------------------------------
function LobbyTamer:init(user_data)
    self.m_userData = user_data
end

-------------------------------------
-- function initAnimator
-------------------------------------
function LobbyTamer:initAnimator(file_name)
    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    self.m_animator = MakeAnimator(file_name)--AnimatorHelper:makeTamerAnimator(file_name)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node, 2)
        self.m_animator.m_node:setScale(0.6)
        self.m_animator.m_node:setPositionY(50)

        self.m_animator.m_node:setMix('idle', 'skill_idle', 0.1)
        self.m_animator.m_node:setMix('skill_idle', 'idle', 0.1)
    end
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function LobbyTamer:initState()
    self:addState('idle', LobbyTamer.st_idle, 'idle', true)
    self:addState('move', LobbyTamer.st_move, 'skill_idle', true)
    self:addState('attack', LobbyTamer.st_attack, 'attack_hack', false)
end

-------------------------------------
-- function st_idle
-------------------------------------
function LobbyTamer.st_idle(self, dt)
end

-------------------------------------
-- function st_move
-------------------------------------
LobbyTamer.st_move = LobbyCharacter.st_move

-------------------------------------
-- function onMoveEnd
-------------------------------------
function LobbyTamer:onMoveEnd()
    if self.m_attackTarget then
        self:changeState('attack')
    else
        self:changeState('idle')
    end
    return true
end

-------------------------------------
-- function st_attack
-------------------------------------
function LobbyTamer.st_attack(self, dt)
    if (self.m_stateTimer == 0) then

        local user_x, user_y = self.m_rootNode:getPosition()
        local box_x, box_y = self.m_attackTarget.m_rootNode:getPosition()

        if (user_x ~= box_x) then
            local flip = (box_x < user_x)
            self.m_animator:setFlip(flip)
        end

        self.m_animator:addAniHandler(function()
            if self.m_attackTarget then
                self:changeState('attack')
            else
                self:changeState('idle')
            end
        end)
    end
end

-------------------------------------
-- function setAttack
-------------------------------------
function LobbyTamer:setAttack(target)
    local user_x, user_y = self.m_rootNode:getPosition()
    local box_x, box_y = target.m_rootNode:getPosition()

    local distance = getDistance(user_x, user_y, box_x, box_y)
    if (distance <= 150) then
        if (self.m_attackTarget == target) then
            if (self.m_state == 'attack') then
   
            else
                self:changeState('attack')
            end
        end
    else
        self.m_moveX = box_x + 100
        self.m_moveY = box_y

        self.m_moveSpeed = 400
    
        self:changeState('move')
    end

    self.m_attackTarget = target
end

-------------------------------------
-- function setMove
-------------------------------------
function LobbyTamer:setMove(x, y, speed)
    self.m_attackTarget = nil
    PARENT.setMove(self, x, y, speed)
end

-------------------------------------
-- function release
-------------------------------------
function LobbyTamer:release()
    if self.m_dragon then
        self.m_dragon:release()
        self.m_dragon = nil
    end

    if self.m_ui then
        self.m_ui:release()
        self.m_ui = nil
    end

    PARENT.release(self)
end