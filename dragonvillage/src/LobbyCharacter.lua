local PARENT = class(IStateHelper:getCloneClass(), IEventDispatcher:getCloneTable(), IEventListener:getCloneTable())

-------------------------------------
-- class LobbyCharacter
-------------------------------------
LobbyCharacter = class(PARENT, {
        m_rootNode = 'cc.Node',
        m_animator = 'Animator',
        m_backgroundAnimator = 'Animator',      -- 티어랭커 배경과 같은 이펙트용

        -- state 관련 변수
        m_tStateAni = 'table[string]',        -- state별 animation명
        m_tStateAniLoop = 'table[boolean]',    -- state별 animation loop 여부

        m_moveX = 'number',
        m_moveY = 'number',
        m_moveSpeed = 'number',

        m_shadow = '',
     })

LobbyCharacter.MOVE_ACTION = 100

-------------------------------------
-- function init
-------------------------------------
function LobbyCharacter:init()
    -- rootNode 생성
    self.m_rootNode = cc.Node:create()

    -- state 관련 변수
    self.m_tStateAni = {}
    self.m_tStateAniLoop = {}
end

-------------------------------------
-- function initSchedule
-------------------------------------
function LobbyCharacter:initSchedule()
    self.m_rootNode:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initAnimator
-------------------------------------
function LobbyCharacter:initAnimator(file_name)
    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    error('상속받은 클래스에서 구현하세요.')
end

-------------------------------------
-- function releaseAnimator
-------------------------------------
function LobbyCharacter:releaseAnimator()
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
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function LobbyCharacter:initState()
    error('상속받은 클래스에서 구현하세요.')
    self:addState('idle', LobbyCharacter.st_idle, 'idle', true)
    self:addState('move', LobbyCharacter.st_move, 'move', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function LobbyCharacter.st_idle(self, dt)
end


-------------------------------------
-- function st_move
-------------------------------------
function LobbyCharacter.st_move(self, dt)
    if (self.m_stateTimer == 0) then

        self:dispatch('lobby_character_move_start', {}, self)

        local function finich_cb()
            local x, y = self.m_rootNode:getPosition()
            self:dispatch('lobby_character_move', {}, self, x, y)
            
            if (self:onMoveEnd() == true) then
                return
            end

            self:changeState('idle')
        end

        local cur_x, cur_y = self.m_rootNode:getPosition()
        local tar_x, tar_y = self.m_moveX, self.m_moveY
        local distance = getDistance(cur_x, cur_y, tar_x, tar_y)
        local duration = (distance / self.m_moveSpeed)
        local action = cc.Sequence:create(cc.MoveTo:create(duration, cc.p(tar_x, tar_y)), cc.CallFunc:create(finich_cb))
        cca.runAction(self.m_rootNode, action, LobbyTamer.MOVE_ACTION)
        action:step(dt)

        -- 방향 지정
        local flip
        if (cur_x == tar_x) then
            flip = self.m_animator.m_bFlip
        else
            flip = (cur_x > tar_x)
        end

        self.m_animator:setFlip(flip)
    end

    local x, y = self.m_rootNode:getPosition()
    self:dispatch('lobby_character_move', {}, self, x, y)
end

-------------------------------------
-- function onMoveEnd
-------------------------------------
function LobbyCharacter:onMoveEnd()
end

-------------------------------------
-- function setMove
-------------------------------------
function LobbyCharacter:setMove(x, y, speed)
    self.m_moveX = x
    self.m_moveY = y

    self.m_moveSpeed = speed
    
    self:changeState('move')
end

-------------------------------------
-- function setPosition
-------------------------------------
function LobbyCharacter:setPosition(x, y)
    self.m_rootNode:setPosition(x, y)
    self:dispatch('lobby_character_move', {}, self, x, y)
end

-------------------------------------
-- function addState
-- @param state : string
-- @param func : function
-- @param ani : string
-- @param loop : boolean
-- @param priority : number
-------------------------------------
function LobbyCharacter:addState(state, func, ani, loop, priority)
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
function LobbyCharacter:changeState(state, forced)
    -- 지정되지 않은 상태일 경우
    if (not self.m_tStateFunc[state]) then
        error(string.format('"%s" can not be found.', state))
    end

    local prev_state = self.m_state
    local changed = PARENT.changeState(self, state, forced)

    if (changed and self.m_animator) then
        local check = (self.m_tStateAni[state] == 'move')
        self.m_animator:changeAni(self.m_tStateAni[state], self.m_tStateAniLoop[state], check)
    end

    -- 이동이 종료되었을 경우
    if (changed and (prev_state == 'move') and (state ~= 'move')) then
        cca.stopAction(self.m_rootNode, LobbyCharacter.MOVE_ACTION)
        self:dispatch('lobby_character_move_end', {}, self)
    end

    return changed
end

-------------------------------------
-- function release
-------------------------------------
function LobbyCharacter:release()
    self:releaseAnimator()

    if self.m_rootNode then
        self.m_rootNode:removeFromParent(true)
    end
    
    self.m_rootNode = nil

    if self.m_shadow then
        self.m_shadow:release()
        self.m_shadow = nil
    end

    PARENT.release_EventDispatcher(self)
    PARENT.release_EventListener(self)
end

-------------------------------------
-- function showEmotionEffect
-- @brief 감정 이펙트 연출
-------------------------------------
function LobbyCharacter:showEmotionEffect()

    -- 향후 다른 용도로 사용 예정 2017-01-17 Seong-goo Kim
    if true then
        return
    end

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
