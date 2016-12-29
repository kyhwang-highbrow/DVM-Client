local PARENT = IStateHelper:getCloneClass()

-------------------------------------
-- class LobbyTamer
-------------------------------------
LobbyTamer = class(PARENT, {
        m_rootNode = 'cc.Node',
        m_animator = 'Animator',

        -- state 관련 변수
        m_tStateAni = 'table[string]',        -- state별 animation명
        m_tStateAniLoop = 'table[boolean]',    -- state별 animation loop 여부

        m_moveX = '',
        m_moveY = '',
        m_moveSpeed = '',

        m_shadowSprite = 'cc.Sprite',
        m_dragonAnimator = 'Animator',
     })

-------------------------------------
-- function init
-------------------------------------
function LobbyTamer:init()
    -- rootNode 생성
    self.m_rootNode = cc.Node:create()

    -- state 관련 변수
    self.m_tStateAni = {}
    self.m_tStateAniLoop = {}
end

-------------------------------------
-- function initSchedule
-------------------------------------
function LobbyTamer:initSchedule()
    self.m_rootNode:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initAnimator
-------------------------------------
function LobbyTamer:initAnimator(file_name)
    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeTamerAnimator(file_name)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node, 2)
        self.m_animator.m_node:setScale(0.6)
        self.m_animator.m_node:setPositionY(50)

        self.m_animator.m_node:setMix('idle', 'skill_idle', 0.1)
        self.m_animator.m_node:setMix('skill_idle', 'idle', 0.1)
    end
end

-------------------------------------
-- function releaseAnimator
-------------------------------------
function LobbyTamer:releaseAnimator()
    -- Animator 삭제
    if self.m_animator then
        if self.m_animator.m_node then
            self.m_animator.m_node:removeFromParent(true)
            self.m_animator.m_node = nil
        end
        self.m_animator = nil
    end
end

-------------------------------------
-- function initShadow
-------------------------------------
function LobbyTamer:initShadow(parent, z_order)
    self:releaseShadow()

    self.m_shadowSprite = cc.Sprite:create('res/character/char_shadow.png')
    self.m_shadowSprite:setDockPoint(cc.p(0.5, 0.5))
    self.m_shadowSprite:setAnchorPoint(cc.p(0.5, 0.5))
    parent:addChild(self.m_shadowSprite, z_order or 0)

    self:syncShadow()
end

-------------------------------------
-- function releaseShadow
-------------------------------------
function LobbyTamer:releaseShadow()
    if self.m_shadowSprite then
        self.m_shadowSprite:removeFromParent(true)
        self.m_shadowSprite = nil
    end
end

-------------------------------------
-- function syncShadow
-------------------------------------
function LobbyTamer:syncShadow()
    if (not self.m_shadowSprite) then
        return
    end

    local x, y = self.m_rootNode:getPosition()
    self.m_shadowSprite:setPosition(x, y)
end

-------------------------------------
-- function initDragonAnimator
-------------------------------------
function LobbyTamer:initDragonAnimator(file_name)
    -- Animator 삭제
    self:releaseDragonAnimator()

    -- Animator 생성
    self.m_dragonAnimator = AnimatorHelper:makeDragonAnimator(file_name)
    if self.m_dragonAnimator.m_node then
        self.m_rootNode:addChild(self.m_dragonAnimator.m_node, 1)
        self.m_dragonAnimator.m_node:setScale(0.5)
        self.m_dragonAnimator.m_node:setPosition(-100, 150)

        self.m_dragonAnimator.m_node:setMix('idle', 'skill_idle', 0.1)
        self.m_dragonAnimator.m_node:setMix('skill_idle', 'idle', 0.1)
    end
end

-------------------------------------
-- function releaseDragonAnimator
-------------------------------------
function LobbyTamer:releaseDragonAnimator()
    -- Animator 삭제
    if self.m_dragonAnimator then
        if self.m_dragonAnimator.m_node then
            self.m_dragonAnimator.m_node:removeFromParent(true)
            self.m_dragonAnimator.m_node = nil
        end
        self.m_dragonAnimator = nil
    end
end

-------------------------------------
-- function syncDragon
-------------------------------------
function LobbyTamer:syncDragon(flip, duration, dt)
    if (not self.m_dragonAnimator) then
        return
    end

    self.m_dragonAnimator:setFlip(flip)

    local x, y = self.m_dragonAnimator.m_node:getPosition()

    -- 왼쪽
    if flip then
        x = 100

    -- 오른쪽
    else
        x = -100
    end

    duration = math_max(duration, 0.8)

    local action = cc.MoveTo:create(duration, cc.p(x, y))
    action = cc.EaseInOut:create(action, 2)
    cca.runAction(self.m_dragonAnimator.m_node, action, 100)
    action:step(dt)
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function LobbyTamer:initState()
    self:addState('idle', LobbyTamer.st_idle, 'idle', true)
    self:addState('move', LobbyTamer.st_move, 'skill_idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function LobbyTamer.st_idle(self, dt)
end

-------------------------------------
-- function st_move
-------------------------------------
function LobbyTamer.st_move(self, dt)
    if (self.m_stateTimer == 0) then

        local function finich_cb()
            self:onMove()
            self:changeState('idle')
        end

        local cur_x, cur_y = self.m_rootNode:getPosition()
        local tar_x, tar_y = self.m_moveX, self.m_moveY
        local distance = getDistance(cur_x, cur_y, tar_x, tar_y)
        local duration = (distance / self.m_moveSpeed)
        local action = cc.Sequence:create(cc.MoveTo:create(duration, cc.p(tar_x, tar_y)), cc.CallFunc:create(finich_cb))
        cca.runAction(self.m_rootNode, action, 100)
        action:step(dt)

        -- 방향 지정
        local flip = (cur_x >= tar_x)
        self.m_animator:setFlip(flip)
        self:syncDragon(flip, duration, dt)
    end

    self:onMove()
end

-------------------------------------
-- function setMove
-------------------------------------
function LobbyTamer:setMove(x, y, speed)
    x = math_clamp(x, -1740, 1920 - 50)
    y = math_clamp(y, -320, -80)

    self.m_moveX = x
    self.m_moveY = y

    self.m_moveSpeed = speed

    self:changeState('move')
end

-------------------------------------
-- function setPosition
-------------------------------------
function LobbyTamer:setPosition(x, y)
    self.m_rootNode:setPosition(x, y)
    self:onMove()
end

-------------------------------------
-- function onMove
-------------------------------------
function LobbyTamer:onMove()
    self:syncShadow()
end

-------------------------------------
-- function addState
-- @param state : string
-- @param func : function
-- @param ani : string
-- @param loop : boolean
-- @param priority : number
-------------------------------------
function LobbyTamer:addState(state, func, ani, loop, priority)
    local loop = loop and true

    if ani then    
        self.m_tStateAni[state] = ani
    else
        self.m_tStateAni[state] = nil
    end
    self.m_tStateAniLoop[state] = loop

    PARENT.addState(self, state, func, priority)
end

-------------------------------------
-- function changeState
-- @param state
-- @param forced
-- @return boolean
-------------------------------------
function LobbyTamer:changeState(state, forced)
    -- 지정되지 않은 상태일 경우
    if (not self.m_tStateFunc[state]) then
        error(string.format('"%s" can not be found.', state))
    end

    local changed = PARENT.changeState(self, state, forced)

    if (changed and self.m_animator) then
        self.m_animator:changeAni(self.m_tStateAni[state], self.m_tStateAniLoop[state], true)
    end

    return changed
end

-------------------------------------
-- function release
-------------------------------------
function LobbyTamer:release()
    self:releaseAnimator()
    self:releaseShadow()
    self:releaseDragonAnimator()

    if self.m_rootNode then
        self.m_rootNode:removeFromParent(true)
    end
    
    self.m_rootNode = nil
end