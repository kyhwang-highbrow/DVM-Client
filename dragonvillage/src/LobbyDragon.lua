local PARENT = LobbyCharacter

-------------------------------------
-- class LobbyDragon
-------------------------------------
LobbyDragon = class(PARENT, {
        m_bAwake = 'bool',
        m_bWating = 'bool',
        m_targetX = '',
        m_targetY = '',
        m_targetTamer = '',
        m_bInitFirstPos = 'bool',
     })

LobbyDragon.MOVE_ACTION = 100
LobbyDragon.DELAY_ACTION = 200
LobbyDragon.SPEED = 400
LobbyDragon.Y_OFFSET = 150

-------------------------------------
-- function init
-------------------------------------
function LobbyDragon:init()
    self.m_bInitFirstPos = false
end

-------------------------------------
-- function initAnimator
-------------------------------------
function LobbyDragon:initAnimator(file_name)
    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeDragonAnimator(file_name)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node, 1)
        self.m_animator.m_node:setScale(0.5)
        self.m_animator.m_node:setPosition(0, LobbyDragon.Y_OFFSET)
    end

    --SimplePrimitivesDraw(self.m_rootNode, 0, LobbyDragon.Y_OFFSET, 70)
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function LobbyDragon:initState()
    self:addState('idle', LobbyDragon.st_idle, 'idle', true)
    self:addState('move', LobbyDragon.st_move, 'move', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function LobbyDragon.st_idle(self, dt)
    if (self.m_stateTimer == 0) then
        self.m_bAwake = false
        self.m_bWating = true
    end
end

-------------------------------------
-- function st_move
-------------------------------------
LobbyDragon.st_move = LobbyCharacter.st_move

-------------------------------------
-- function onEvent
-------------------------------------
function LobbyDragon:onEvent(event_name, ...)
    if (event_name == 'lobby_character_move') then
        local arg = {...}
        local lobby_tamer = arg[1]
        local x = arg[2]
        local y = arg[3]

        self.m_targetTamer = lobby_tamer

        self.m_targetX = x
        self.m_targetY = y

        -- 최초 위치가 설정되지 않았을 경우
        if (not self.m_bInitFirstPos) then
            local flip = lobby_tamer.m_animator.m_bFlip
            if (not flip) then
                x = x - 100
            else
                x = x + 100
            end
            self:setPosition(x, y)
            self.m_animator:setFlip(flip)
            self.m_bInitFirstPos = true

        elseif (not self.m_bAwake) then
            local function func()
                self:awakeDragon()
            end
            cca.reserveFuncWithTag(self.m_rootNode, 1, func, LobbyDragon.DELAY_ACTION)
            self.m_bAwake = true

        elseif (not self.m_bWating) then
            local dragon_x, dragon_y = self.m_rootNode:getPosition()
            local distance_x = math_abs(x - dragon_x)
            local distance_y = math_abs(y - dragon_y)

            if (distance_x > 100) or (distance_y >= 80) then
                self:moveToTamer()
            end

        else
            -- 거리 체크
            local dragon_x, dragon_y = self.m_rootNode:getPosition()
            local distance_x = math_abs(x - dragon_x)
            local distance_y = math_abs(y - dragon_y)

            if (distance_x >= 200) or (distance_y >= 80) then
                self:awakeDragon()
                return
            end
        end
    end
end

-------------------------------------
-- function onMoveEnd
-------------------------------------
function LobbyDragon:onMoveEnd()
    if (not self.m_targetTamer) then
        return
    end

    local flip = self.m_targetTamer.m_animator.m_bFlip
    self.m_animator:setFlip(flip)
end

-------------------------------------
-- function awakeDragon
-------------------------------------
function LobbyDragon:awakeDragon()
    local node = self.m_rootNode
    cca.stopAction(node, LobbyDragon.DELAY_ACTION)

    self.m_bWating = false
    self:moveToTamer()
end

-------------------------------------
-- function moveToTamer
-------------------------------------
function LobbyDragon:moveToTamer()
    local dragon_x, dragon_y = self.m_rootNode:getPosition()

    local x = self.m_targetX

    local flip = self.m_targetTamer.m_animator.m_bFlip

    --if (dragon_x < self.m_targetX) then
    if (not flip) then
        x = x - 100
    else
        x = x + 100
    end

    self:setMove(x, self.m_targetY, LobbyDragon.SPEED)
end