-------------------------------------
-- class Entity
-------------------------------------
Entity = class(PhysObject, {
        m_world = '',

        m_rootNode = '',
        m_animator = '',

        -- state 관련 변수
        m_state = 'string',                    -- 현재 state
        m_prevState = 'string',                -- 이전 프레임의 state
        m_tStateFunc = 'table[function]',    -- state별 동작 함수
        m_tStateAni = 'table[string]',        -- state별 animation명
        m_tStateAniLoop = 'table[boolean]',    -- state별 animation loop 여부
        m_tStatePriority = 'table[number]',    -- state별 우선순위
        m_stateTimer = 'number',            -- 현재 state를 지속하고 있는 시간(단위:초)

        -- 타겟 포지션
        m_targetPosX = 'number',
        m_targetPosY = 'number',

        m_motionStreak = 'MotionStreack',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Entity:init(file_name, body)
    
    -- rootNode 생성
    self.m_rootNode = cc.Node:create()

    -- PhysBody 초기화
    local body = body or {0,0,50}
    PhysObject_initPhys(self, body)

    -- Animator 생성
    self:initAnimator(file_name)

    -- state 관련 변수
    self.m_state = nil
    self.m_prevState = nil
    self.m_tStateFunc = {}
    self.m_tStateAni = {}
    self.m_tStateAniLoop = {}
    self.m_tStatePriority = {}
    self.m_stateTimer = 0
end

-------------------------------------
-- function initWorld
-- @param game_world
-------------------------------------
function Entity:initWorld(game_world)
    self.m_world = game_world
end

-------------------------------------
-- function initAnimator
-------------------------------------
function Entity:initAnimator(file_name)
    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    self.m_animator = MakeAnimator(file_name)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node)
    end
end

-------------------------------------
-- function releaseAnimator
-------------------------------------
function Entity:releaseAnimator()
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
-- function getAniDuration
-- @brief
-------------------------------------
function Entity:getAniDuration()
    return self.m_animator:getDuration()
end

-------------------------------------
-- function setPosition
-------------------------------------
function Entity:setPosition(x, y)
    self.m_rootNode:setPosition(x, y)

    PhysObject.setPosition(self, x, y)

    if self.m_motionStreak then
        self.m_motionStreak:setPosition(cc.p(self.pos.x, self.pos.y))
    end
end

-------------------------------------
-- function setRotation
-------------------------------------
function Entity:setRotation(degree)
    if self.m_animator then
        self.m_animator:setRotation(degree)
    end
end

-------------------------------------
-- function release
-------------------------------------
function Entity:release()
    PhysObject.release(self)

    self:releaseAnimator()

    if self.m_rootNode then
        self.m_rootNode:removeFromParent(true)
    end
    
    self.m_rootNode = nil

    if self.m_motionStreak then
        local function removeThis(node)
            node:removeFromParent(true)
        end
        self.m_motionStreak:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(removeThis)))
        self.m_motionStreak = nil
    end
end

-------------------------------------
-- function update
-- @brief GameMgr에서 호출되며 true를 반환 할 경우 release를 호출한다.
-- @param dt
-- @return boolean
-------------------------------------
function Entity:update(dt)
    local prev_state = self.m_state

    -- state함
    if self.m_tStateFunc[self.m_state] then
        if self.m_tStateFunc[self.m_state](self, dt) then
            return true
        end
    end

    -- coroutine
    --self:updateCoroutine(dt)

    -- 이전 상태와 현재 상태가 같을 경우 m_stateTimer 증가
    if self.m_stateTimer == -1 then
        self.m_stateTimer = 0
    elseif prev_state == self.m_state then
        self.m_stateTimer = self.m_stateTimer + dt
    end

    return false
end

-------------------------------------
-- function addState
-- @param state : string
-- @param func : function
-- @param ani : string
-- @param loop : boolean
-- @param priority : number
-------------------------------------
function Entity:addState(state, func, ani, loop, priority)
    local loop = loop and true

    self.m_tStateFunc[state] = func
    self.m_tStatePriority[state] = priority or 1

    if ani then    
        self.m_tStateAni[state] = ani
    else
        self.m_tStateAni[state] = nil
    end
    self.m_tStateAniLoop[state] = loop
end

-------------------------------------
-- function getCurrAniName
-------------------------------------
function Entity:getCurrAniName()
    return self.m_tStateAni[self.m_state], self.m_tStateAniLoop[self.m_state]
end

-------------------------------------
-- function changeState
-- @param state
-- @param forced
-- @return boolean
-------------------------------------
function Entity:changeState(state, forced)

    -- 지정되지 않은 상태일 경우
    if not self.m_tStateFunc[state] then
        error(string.format('"%s" can not be found.', state))
    end

    local changed = false
    if forced or ((self.m_tStatePriority[self.m_state] or 0) <= (self.m_tStatePriority[state] or 0)) then
        self.m_prevState = self.m_state
        self.m_state = state

        -- idle 애니메이션에 한해서 중복 체크
        local check = (state == 'idle') or (state == 'wait_pattern')

        if self.m_animator then
            self.m_animator:changeAni(self.m_tStateAni[state], self.m_tStateAniLoop[state], check)
        end
        self.m_stateTimer = 0
        changed = true
    end

    --[[
    if changed then
        -- 이전 상태 Exit 콜백함수 호출
        if self.m_tStateExitCB and self.m_tStateExitCB[self.m_prevState] then
            self.m_tStateExitCB[self.m_prevState](self)
        end

        -- 현재 상태 Enter 콜백함수 호출
        if self.m_tStateEnterCB and self.m_tStateEnterCB[self.m_state] then
            self.m_tStateEnterCB[self.m_state](self)
        end
    end
    --]]

    return changed
end

-------------------------------------
-- function setTargetPos
-- @param x
-- @param y
-------------------------------------
function Entity:setTargetPos(x, y)
    self.m_targetPosX = x
    self.m_targetPosY = y

    local dx, dy = self.m_targetPosX - self.pos.x, self.m_targetPosY - self.pos.y
    local rad = math_atan2(dy, dx)
    local theta = math_deg(rad)

    self:setDir(theta)
end

-------------------------------------
-- function isOverTargetPos
-------------------------------------
function Entity:isOverTargetPos(pos_currection)
    local old = self.movement_theta
    local pos_currection = pos_currection or false

    local dx, dy = self.m_targetPosX - self.pos.x, self.m_targetPosY - self.pos.y
    local cur = math_deg(math_atan2(dy, dx))

    if math_abs(cur - old) > 90 and math_abs(cur - old) < 270 then
        if pos_currection then
            self:setPosition(self.m_targetPosX, self.m_targetPosY)
        end
        return true
    else
        return false
    end
end

-------------------------------------
-- function addAniHandler
-- @param enabled
-------------------------------------
function Entity:addAniHandler(cb)
    if self.m_animator then
        return self.m_animator:addAniHandler(cb)
    end

    return false
end

-------------------------------------
-- function runAction
-------------------------------------
function Entity:runAction(action)
    self.m_rootNode:runAction(action)
end

-------------------------------------
-- function stopAllActions
-------------------------------------
function Entity:stopAllActions()
    self.m_rootNode:stopAllActions()
end

-------------------------------------
-- function aniHandlerChain
-------------------------------------
function Entity:aniHandlerChain(...)

    -- 함수 리스트를 args에 담는다
    local args = {...}
    local idx = 1

    -- 재귀적으로 사용하기 위해 임시 변수 추가
    local func = nil

    -- 재귀함수 구현
    local func_ = function()
        -- 이전 idx의 함수가 있을 경우 호출
        if args[idx-1] then
            args[idx-1]()
        end

        -- 지금 idx의 함수가 있을 경우 aniHandler에 추가
        if args[idx] then
            self:addAniHandler(func)
        end
        idx = idx + 1
    end

    func = func_

    -- 최초 실행
    func()
end

-------------------------------------
-- function setMotionStreak
-------------------------------------
function Entity:setMotionStreak(parent_node, res, z_order)
    z_order = z_order or 0
    if (not res) or (res == '') then
        return
    end

    if self.m_motionStreak then
        self.m_motionStreak:removeFromParent(true)
        self.m_motionStreak = nil
    end

    self.m_motionStreak = cc.MotionStreak:create(0.3, -1, 50, cc.c3b(255, 255, 255), res)
    if self.m_motionStreak then
        parent_node:addChild(self.m_motionStreak, z_order)
    end
end