local PARENT = LobbyTamer

-------------------------------------
-- class LobbyTamerBot
-------------------------------------
LobbyTamerBot = class(PARENT, {
        m_randomTime = 'number',
        m_funcGetRandomPos = 'function',
     })

-------------------------------------
-- function init
-------------------------------------
function LobbyTamerBot:init(user_data)
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function LobbyTamerBot:initState()
    PARENT.initState(self)
    self:addState('idle', LobbyTamerBot.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function LobbyTamerBot.st_idle(self, dt)
    if (self.m_stateTimer == 0) then
        self.m_randomTime = math_random(10, 300) / 10

    elseif (self.m_randomTime <= self.m_stateTimer) then
        local x, y = self:getRandomPos()
        self:setMove(x, y, 400)
    end

    LobbyTamer.st_idle(self, dt)
end

-------------------------------------
-- function getRandomPos
-------------------------------------
function LobbyTamerBot:getRandomPos()
    if (self.m_funcGetRandomPos) then
        return self.m_funcGetRandomPos()
    end

    return 0, 0
end