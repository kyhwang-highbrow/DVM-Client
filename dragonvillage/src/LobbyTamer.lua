local PARENT = class(IStateHelper:getCloneClass(), IEventDispatcher:getCloneTable())

-------------------------------------
-- class LobbyTamer
-------------------------------------
LobbyTamer = class(PARENT, {
        m_userData = '',

        m_rootNode = 'cc.Node',
        m_animator = 'Animator',

        -- state 관련 변수
        m_tStateAni = 'table[string]',        -- state별 animation명
        m_tStateAniLoop = 'table[boolean]',    -- state별 animation loop 여부

        m_moveX = '',
        m_moveY = '',
        m_moveSpeed = '',

        m_dragonAnimator = 'Animator',
     })

-------------------------------------
-- function init
-------------------------------------
function LobbyTamer:init(user_data)
    self.m_userData = user_data

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
-- function initDragonAnimator
-------------------------------------
function LobbyTamer:initDragonAnimator(file_name, flip)
    -- Animator 삭제
    self:releaseDragonAnimator()

    -- Animator 생성
    self.m_dragonAnimator = AnimatorHelper:makeDragonAnimator(file_name)
    if self.m_dragonAnimator.m_node then
        self.m_rootNode:addChild(self.m_dragonAnimator.m_node, 1)
        self.m_dragonAnimator.m_node:setScale(0.5)

        local x = flip and 100 or -100
        self.m_dragonAnimator.m_node:setPosition(x, 150)
        self.m_dragonAnimator:setFlip(flip)

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

    if (self.m_dragonAnimator.m_bFlip == flip) then
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
            local x, y = self.m_rootNode:getPosition()
            self:dispatch('lobby_tamer_move', self, x, y)
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
        local flip
        if (cur_x == tar_x) then
            flip = self.m_animator.m_bFlip
        else
            flip = (cur_x > tar_x)
        end

        self.m_animator:setFlip(flip)
        self:syncDragon(flip, duration, dt)
    end

    local x, y = self.m_rootNode:getPosition()
    self:dispatch('lobby_tamer_move', self, x, y)
end

-------------------------------------
-- function setMove
-------------------------------------
function LobbyTamer:setMove(x, y, speed)
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
    self:dispatch('lobby_tamer_move', self, x, y)
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
    self:releaseDragonAnimator()

    if self.m_rootNode then
        self.m_rootNode:removeFromParent(true)
    end
    
    self.m_rootNode = nil
end

-------------------------------------
-- function showEmotionEffect
-- @brief 감정 이펙트 연출
-------------------------------------
function LobbyTamer:showEmotionEffect()
    local animator = MakeAnimator('res/ui/a2d/emotion/emotion.vrp')

    do -- 에니메이션 지정
        local sum_random = SumRandom()
        sum_random:addItem(1, 'curious')
        sum_random:addItem(2, 'exciting')
        sum_random:addItem(2, 'like')
        sum_random:addItem(2, 'love')
        local ani_name = sum_random:getRandomValue()     
        animator:changeAni(ani_name, false)
    end

    -- 위치 지정
    animator:setPosition(-70, 200)
    
    -- 재생 후 삭제
    local duration = animator.m_node:getDuration()
    animator:setScale(0.7)
    animator.m_node:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))
    self.m_rootNode:addChild(animator.m_node, 3)
end
