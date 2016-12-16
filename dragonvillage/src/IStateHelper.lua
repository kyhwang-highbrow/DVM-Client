-------------------------------------
-- interface IStateHelper
-- @brief 사용시 슈퍼 클래스의 update()함수에 적용 필요
-------------------------------------
IStateHelper = {
    m_totalTimer = 'number',-- 전체 타이머

    m_prevState = 'string',
    m_state = 'string',
    m_stateTimer = 'number',

    m_step = 'number',		-- 현재 단계(state 하위개념)
	m_nextStep = 'number',

    m_stepTimer = 'number',	-- 현재 연출 단계내에서의 타이머
	m_stepPrevTime = 'number',	-- 이전 프레임에서의 m_stepTimer값
}

-------------------------------------
-- function init
-------------------------------------
function IStateHelper:init()
    self.m_totalTimer = 0

    self.m_prevState = nil
    self.m_state = nil
    self.m_stateTimer = 0

    self.m_step = 0
	self.m_nextStep = 0

    self.m_stepTimer = 0
	self.m_stepPrevTime = 0
end

-------------------------------------
-- function updateState
-- @brief 현재 상태에 대한 처리 이전에 호출되어야함
-------------------------------------
function IStateHelper:updateState()
    if (self.m_prevState ~= self.m_state or self.m_stateTimer == -1) then
        self.m_prevState = self.m_state
		self.m_stateTimer = 0
        self.m_step = 0
	    self.m_nextStep = 0
        self.m_stepTimer = 0
	    self.m_stepPrevTime = 0
    
    elseif (self.m_step ~= self.m_nextStep) then
		self.m_step = self.m_nextStep
		self.m_stepTimer = 0
		self.m_stepPrevTime = 0
	end
end

-------------------------------------
-- function updateTimer
-- @brief 현재 상태에 대한 처리가 끝난 후 호출되어야함
-------------------------------------
function IStateHelper:updateTimer(dt)
	self.m_totalTimer = self.m_totalTimer + dt

    if (self.m_stateTimer == -1) then
        self.m_stateTimer = 0

    elseif (self.m_prevState == self.m_state) then
        self.m_stateTimer = self.m_stateTimer + dt

    end

    self.m_stepPrevTime = self.m_stepTimer
	self.m_stepTimer = self.m_stepTimer + dt
end

-------------------------------------
-- function changeState
-------------------------------------
function IStateHelper:changeState(state)
    self.m_prevState = self.m_state
    self.m_state = state
    self.m_stateTimer = -1
end

-------------------------------------
-- function nextStep
-------------------------------------
function IStateHelper:nextStep()
	self.m_nextStep = self.m_nextStep + 1
end

-------------------------------------
-- function isBeginningStep
-------------------------------------
function IStateHelper:isBeginningStep(step)
	local step = step or self.m_step
	
	return (self.m_step == step and self.m_stepTimer == 0)
end

-------------------------------------
-- function isPassedStepTime
-------------------------------------
function IStateHelper:isPassedStepTime(time)
	return (self.m_stepPrevTime <= time and time <= self.m_stepTimer)
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