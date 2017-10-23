local PARENT = class(ForestObject, IStateHelper:getCloneTable(), IEventDispatcher:getCloneTable(), IEventListener:getCloneTable())

-------------------------------------
-- class ForestCharacter
-------------------------------------
ForestCharacter = class(PARENT, {
        -- state 관련 변수
        m_tStateAni = 'table[string]',        -- state별 animation명
        m_tStateAniLoop = 'table[boolean]',    -- state별 animation loop 여부

        m_moveX = 'number',
        m_moveY = 'number',
        m_moveSpeed = 'number',

        m_shadow = '',
     })

ForestCharacter.MOVE_ACTION = 100
ForestCharacter.SPEED = 400

-------------------------------------
-- function init
-------------------------------------
function ForestCharacter:init()
    -- state 관련 변수
    self.m_tStateAni = {}
    self.m_tStateAniLoop = {}
end

-------------------------------------
-- function st_idle
-------------------------------------
function ForestCharacter.st_idle(self, dt)
end

-------------------------------------
-- function st_move
-------------------------------------
function ForestCharacter.st_move(self, dt)
    
    if (self.m_stateTimer == 0) then
        
        self:onMoveStart()

        local function finich_cb()
            local struct_event = StructForestEvent()
            struct_event:setObject(self)
            struct_event:setPosition(self:getPosition())
            self:dispatch('forest_character_move', struct_event)

            self:onMoveEnd()
            self:changeState('idle')
        end

        local cur_x, cur_y = self:getPosition()
        local tar_x, tar_y = self.m_moveX, self.m_moveY
        local distance = getDistance(cur_x, cur_y, tar_x, tar_y)
        local duration = (distance / self.m_moveSpeed)
        local action = cc.Sequence:create(cc.MoveTo:create(duration, cc.p(tar_x, tar_y)), cc.CallFunc:create(finich_cb))
        cca.runAction(self.m_rootNode, action, ForestCharacter.MOVE_ACTION)
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
    
    -- 이벤트 구조체 생성
    local struct_event = StructForestEvent()
    struct_event:setObject(self)
    struct_event:setPosition(self:getPosition())

    -- 이동 이벤트 dispatch
    self:dispatch('forest_character_move', struct_event)

    -- zorder 업데이트
    self:setForestZOrder()

    -- 움직임을 예쁘게 하려면?
    --self.m_moveSpeed = self.m_moveSpeed + (math_sin(dt) * 100)

    return struct_event
end

-------------------------------------
-- function onMoveStart
-------------------------------------
function ForestCharacter:onMoveStart()
end

-------------------------------------
-- function onMoveEnd
-------------------------------------
function ForestCharacter:onMoveEnd()
end

-------------------------------------
-- function setMove
-------------------------------------
function ForestCharacter:setMove(x, y, speed)
    self.m_moveX = x
    self.m_moveY = y

    self.m_moveSpeed = speed or ForestCharacter.SPEED

    self:changeState('move')
end

-------------------------------------
-- function addState
-- @param state : string
-- @param func : function
-- @param ani : string
-- @param loop : boolean
-- @param priority : number
-------------------------------------
function ForestCharacter:addState(state, func, ani, loop, priority)
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
function ForestCharacter:changeState(state, forced)
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
        cca.stopAction(self.m_rootNode, ForestCharacter.MOVE_ACTION)
    end

    return changed
end

-------------------------------------
-- function release
-------------------------------------
function ForestCharacter:release()
    PARENT.release(self)

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
function ForestCharacter:showEmotionEffect()
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
    animator:setScale(0.7)
    self.m_rootNode:addChild(animator.m_node, 3)
    
    -- 재생 후 삭제
    local duration = animator.m_node:getDuration()
    animator.m_node:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))
end
