local PARENT = class(PhysObject, IStateHelper:getCloneTable())

-------------------------------------
-- class Entity
-------------------------------------
Entity = class(PARENT, {
        m_world = '',

        m_rootNode = '',
        m_animator = '',

        -- state 관련 변수
        m_tStateAni = 'table[string]',        -- state별 animation명
        m_tStateAniLoop = 'table[boolean]',    -- state별 animation loop 여부
        
        -- 타겟 포지션
        m_targetPosX = 'number',
        m_targetPosY = 'number',

        --
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
	-- @TODO 
	self.m_rootNode:retain()

    -- PhysBody 초기화
    local body = body or {0,0,50}
    self:initPhys(body)

    -- Animator 생성
    self:initAnimator(file_name)

    -- state 관련 변수
    self.m_tStateAni = {}
    self.m_tStateAniLoop = {}
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
        self.m_animator:release()
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
    if self.m_rootNode then
        self.m_rootNode:setPosition(x, y)
    end

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
		self.m_rootNode:release()
        self.m_rootNode:removeFromParent(true)
    end
    
    self.m_rootNode = nil
    
    if self.m_motionStreak then
		self.m_motionStreak:removeFromParent(true)
		self.m_motionStreak = nil
    end
end

-------------------------------------
-- function updateState
-- @brief 현재 상태에 대한 처리 이전에 호출되어야함
-------------------------------------
function Entity:updateState()
    -- 상태가 시작할때 해당 애니메이션으로 설정
    if (self.m_prevState ~= self.m_state or self.m_stateTimer == -1) then
        if (self.m_animator) then
            -- idle 애니메이션에 한해서 중복 체크
            local check = isExistValue(self.m_state, 'idle', 'attackDelay', 'pattern_wait')
            self.m_animator:changeAni(self.m_tStateAni[self.m_state], self.m_tStateAniLoop[self.m_state], check)

            -- delegate 상태이고 idle 애니가 아닐 경우 재생 후 idle 애니로 변경
            if (self.m_state == 'delegate' and self.m_tStateAni[self.m_state] ~= 'idle') then
                self.m_animator:addAniHandler(function()
                    self.m_animator:changeAni('idle', true)
                end)
            end

        end
    end

    PARENT.updateState(self)
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

    if ani then    
        self.m_tStateAni[state] = ani
    else
        self.m_tStateAni[state] = nil
    end
    self.m_tStateAniLoop[state] = loop

    PARENT.addState(self, state, func, priority)
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
    if (not self.m_tStateFunc[state]) then
        error(string.format('"%s" can not be found.', state))
    end

    local changed = PARENT.changeState(self, state, forced)
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
    if (self.m_rootNode) then
        self.m_rootNode:runAction(action)
    end
end

-------------------------------------
-- function stopAllActions
-------------------------------------
function Entity:stopAllActions()
    if (self.m_rootNode) then
        self.m_rootNode:stopAllActions()
    end
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
        self.m_motionStreak:setBezierMode(true)
        parent_node:addChild(self.m_motionStreak, z_order)
    end
end

-------------------------------------
-- function blockMatchingSlotShader
-- @brief 특정 네이밍 패턴을 가지는 슬롯들을 각종 쉐이더 효과 시 무시시킴
-------------------------------------
function Entity:blockMatchingSlotShader(str)
    if (not self.m_animator or not isInstanceOf(self.m_animator, AnimatorSpine)) then
        return
    end
     
    local slotList = self.m_animator:getSlotList()

    for i, slotName in ipairs(slotList) do
        if startsWith(slotName, str) then
            self.m_animator.m_node:setSlotGLProgramName(slotName, cc.SHADER_POSITION_TEXTURE_COLOR)
        end
    end
end

-------------------------------------
-- function setMatchingSlotShader
-- @brief 특정 네이밍 패턴을 가지는 슬롯들의 쉐이더를 설정
-------------------------------------
function Entity:setMatchingSlotShader(str, shaderKey)
    if (not self.m_animator or not isInstanceOf(self.m_animator, AnimatorSpine)) then
        return
    end

    if (not shaderKey) then
        return
    end
     
    local slotList = self.m_animator:getSlotList()

    for i, slotName in ipairs(slotList) do
        if startsWith(slotName, str) then
            self.m_animator.m_node:setSlotGLProgramName(slotName, shaderKey)
        end
    end
end

-------------------------------------
-- function setVisibleSlot
-- @brief 특정 네이밍 패턴을 가지는 슬롯들의 visible 설정
-------------------------------------
function Entity:setVisibleSlot(str, b)
    if (not self.m_animator or not isInstanceOf(self.m_animator, AnimatorSpine)) then
        return
    end
 
    local slotList = self.m_animator:getSlotList()
    for i, slotName in ipairs(slotList) do
        if startsWith(slotName, str) then
            self.m_animator.m_node:setVisibleSlot(slotName, b)
        end
    end
end

-------------------------------------
-- function setTemporaryPause
-- @brief
-------------------------------------
function Entity:setTemporaryPause(pause)
    if (self.m_temporaryPause == pause) then
        return false
    end

    self.m_temporaryPause = pause

    local action_mgr = cc.Director:getInstance():getActionManager()

    if pause then
        action_mgr:pauseTarget(self.m_rootNode)
        if (self.m_animator) then
            self.m_animator:setAnimationPause(true)
        end
    else
        action_mgr:resumeTarget(self.m_rootNode)
        if (self.m_animator) then
            self.m_animator:setAnimationPause(false)
        end
    end

    return true
end