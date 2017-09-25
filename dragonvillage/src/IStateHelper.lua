-------------------------------------
-- interface IStateHelper
-- @brief 사용시 슈퍼 클래스의 update()함수에 적용 필요
-------------------------------------
IStateHelper = {
    m_totalTimer = 'number',-- 전체 타이머

    m_prevState = 'string',
    m_state = 'string',
    m_stateTimer = 'number',

    m_stateStep = 'number',		-- 현재 단계(state 하위개념)
	m_nextStateStep = 'number',

    m_stateStepTimer = 'number',	-- 현재 연출 단계내에서의 타이머
	m_stateStepPrevTime = 'number',	-- 이전 프레임에서의 m_stateStepTimer값

    m_tStateFunc = 'table[function]',    -- state별 동작 함수
    m_tStatePriority = 'table[number]',    -- state별 우선순위
}

-------------------------------------
-- function init
-------------------------------------
function IStateHelper:init()
    self.m_totalTimer = 0

    self.m_prevState = nil
    self.m_state = nil
    self.m_stateTimer = 0

    self.m_stateStep = 0
	self.m_nextStateStep = 0

    self.m_stateStepTimer = 0
	self.m_stateStepPrevTime = 0

    self.m_tStateFunc = {}
    self.m_tStatePriority = {}
end

-------------------------------------
-- function update
-- @brief GameWorld에서 호출되며 true를 반환 할 경우 release를 호출한다.
-- @param dt
-- @return boolean
-------------------------------------
function IStateHelper:update(dt)
    self:updateState()

    -- state함
    if self.m_tStateFunc[self.m_state] then
        if self.m_tStateFunc[self.m_state](self, dt) then
            return true
        end
    end

    self:updateStateTimer(dt)

    return false
end

-------------------------------------
-- function updateState
-- @brief 현재 상태에 대한 처리 이전에 호출되어야함
-------------------------------------
function IStateHelper:updateState()
    if (self.m_prevState ~= self.m_state or self.m_stateTimer == -1) then
        self.m_prevState = self.m_state
		self.m_stateTimer = 0
        self.m_stateStep = 0
	    self.m_nextStateStep = 0
        self.m_stateStepTimer = 0
	    self.m_stateStepPrevTime = 0
    
    elseif (self.m_stateStep ~= self.m_nextStateStep) then
		self.m_stateStep = self.m_nextStateStep
		self.m_stateStepTimer = 0
		self.m_stateStepPrevTime = 0
	end
end

-------------------------------------
-- function updateStateTimer
-- @brief 현재 상태에 대한 처리가 끝난 후 호출되어야함
-------------------------------------
function IStateHelper:updateStateTimer(dt)
	self.m_totalTimer = self.m_totalTimer + dt

    if (self.m_stateTimer == -1) then
        self.m_stateTimer = 0

    elseif (self.m_prevState == self.m_state) then
        self.m_stateTimer = self.m_stateTimer + dt

    end

    self.m_stateStepPrevTime = self.m_stateStepTimer
	self.m_stateStepTimer = self.m_stateStepTimer + dt
end

-------------------------------------
-- function addState
-- @param state : string
-- @param func : function
-- @param priority : number
-------------------------------------
function IStateHelper:addState(state, func, priority)
    self.m_tStateFunc[state] = func
    self.m_tStatePriority[state] = priority or 1
end

-------------------------------------
-- function changeState
-- @return bool state 변경 여부 리턴
-------------------------------------
function IStateHelper:changeState(state, forced)
    local can_change = forced

    -- priority 체크
    if (not can_change) then
        local prev_priority = (self.m_tStatePriority[self.m_state] or 0)
        local next_priority = (self.m_tStatePriority[state] or 0)
        can_change = (prev_priority <= next_priority)
    end

    -- state가 변경 가능한 상태일 경우 변경
    if can_change then
        self.m_prevState = self.m_state
        self.m_state = state
        self.m_stateTimer = -1
        return true
    else
        return false
    end
end

-------------------------------------
-- function nextStep
-------------------------------------
function IStateHelper:nextStep()
	self.m_nextStateStep = self.m_nextStateStep + 1
end

-------------------------------------
-- function isBeginningStep
-------------------------------------
function IStateHelper:isBeginningStep(stateStep)
	local stateStep = stateStep or self.m_stateStep
	
	return (self.m_stateStep == stateStep and self.m_stateStepTimer == 0)
end

-------------------------------------
-- function isPassedStepTime
-------------------------------------
function IStateHelper:isPassedStepTime(time)
	return (self.m_stateStepPrevTime <= time and time <= self.m_stateStepTimer)
end

-------------------------------------
-- function getStep
-------------------------------------
function IStateHelper:getStep()
    return self.m_stateStep
end

-------------------------------------
-- function getStepTimer
-------------------------------------
function IStateHelper:getStepTimer()
    return self.m_stateStepTimer
end

-------------------------------------
-- function getCloneTable
-------------------------------------
function IStateHelper:getCloneTable()
	return clone(IStateHelper)
end

-------------------------------------
-- function getCloneClass
-------------------------------------
function IStateHelper:getCloneClass()
	return class(clone(IStateHelper))
end