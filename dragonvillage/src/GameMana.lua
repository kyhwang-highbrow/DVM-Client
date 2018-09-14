local PARENT = class(IEventListener:getCloneClass(), IEventDispatcher:getCloneTable())
local security_key = math.random(-6758472,7637467)

local ACCEL_VALUE = 1

START_MANA = 2
START_MANA_COLOSSEUM = 2.5
MAX_MANA = 7

-------------------------------------
-- class GameMana
-------------------------------------
GameMana = class(PARENT, {
        m_world = 'GameWorld',
        m_inGameUI = 'UI',

        m_groupKey = '',

        m_prevValue = 'number',
        m_value = 'number',
        
        m_incValuePerSec = 'number',

        m_bEnable = 'boolean',

        m_accelValue = 'number',
        m_accelDurationTimer = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function GameMana:init(world, group_key)
    self.m_world = world
    
    self.m_groupKey = group_key

    self.m_prevValue = -1
    self.m_value = security_key
    
    if (self.m_world.m_gameMode == GAME_MODE_COLOSSEUM ) then
        self.m_incValuePerSec = 1 / g_constant:get('INGAME', 'MANA_INTERVAL_COLOSSEUM')
    elseif (self.m_world.m_gameMode == GAME_MODE_ARENA ) then
        self.m_incValuePerSec = 1 / g_constant:get('INGAME', 'MANA_INTERVAL_COLOSSEUM')
    elseif (self.m_world.m_gameMode == GAME_MODE_CHALLENGE_MODE ) then
        self.m_incValuePerSec = 1 / g_constant:get('INGAME', 'MANA_INTERVAL_COLOSSEUM')
    elseif (self.m_world.m_gameMode == GAME_MODE_EVENT_GOLD ) then
        self.m_incValuePerSec = 1 / (g_constant:get('INGAME', 'MANA_INTERVAL') / 2)
    else
        self.m_incValuePerSec = 1 / g_constant:get('INGAME', 'MANA_INTERVAL')
    end
    self.m_bEnable = true

    self.m_accelValue = 0
    self.m_accelDurationTimer = 0
end

-------------------------------------
-- function update
-------------------------------------
function GameMana:update(dt)
    local add = 0

    -- 마나 증가량 계산
    if (self.m_bEnable) then
        add = (self.m_incValuePerSec * (1 + self.m_accelValue)) * dt
    end

    -- 마나 갱신
    self:addMana(add)

    -- 배속 타이머 업데이트
    if (self.m_accelDurationTimer > 0) then
        self.m_accelDurationTimer = self.m_accelDurationTimer - dt

        -- 타이머가 끝났을 경우 배속 해제
        if (self.m_accelDurationTimer <= 0) then
            self.m_accelValue = 0
            self.m_accelDurationTimer = 0

            self:updateGauge(false)
        end
    end
end

-------------------------------------
-- function updateGauge
-- @param updated_int : 정수값이 갱신되었는지 여부
-------------------------------------
function GameMana:updateGauge(updated_int)
    if (not self.m_inGameUI) then return end

    self.m_inGameUI:setMana(self:getCurrMana(), updated_int, self.m_accelValue)
end

-------------------------------------
-- function onEvent
-- @brief
-------------------------------------
function GameMana:onEvent(event_name, t_event, ...)
    if (event_name == 'dragon_active_skill') then
        local arg = {...}
        local dragon = arg[1]

        if (self.m_groupKey == dragon:getPhysGroup()) then
            self:subtractMana(dragon:getSkillManaCost())
        end
    end
end

-------------------------------------
-- function init
-------------------------------------
function GameMana:bindUI(ui)
    self.m_inGameUI = ui

    self:updateGauge(true)
end

-------------------------------------
-- function getCurrMana
-------------------------------------
function GameMana:getCurrMana()
    local value = self.m_value - security_key
    return value
end

-------------------------------------
-- function setCurrMana
-------------------------------------
function GameMana:setCurrMana(value)
    self.m_value = value + security_key

    self:updateGauge(self.m_prevValue ~= math_floor(value))

    self.m_prevValue = math_floor(value)
end

-------------------------------------
-- function addMana
-------------------------------------
function GameMana:addMana(value)
    if (value < 0) then return end

    local value = self:getCurrMana() + value
    value = math_min(value, MAX_MANA)

    self:setCurrMana(value)
end

-------------------------------------
-- function subtractMana
-------------------------------------
function GameMana:subtractMana(value)
    if (value < 0) then return end

    local value = self:getCurrMana() - value
    value = math_max(value, 0)

    self:setCurrMana(value)
end

-------------------------------------
-- function resetMana
-------------------------------------
function GameMana:resetMana()
    local value = 0
    
    self:setCurrMana(value)

    self.m_prevValue = 0
end

-------------------------------------
-- function startManaAccel
-------------------------------------
function GameMana:startManaAccel(duration)
    if (self.m_accelValue ~= ACCEL_VALUE) then
        self.m_accelValue = ACCEL_VALUE
        self.m_accelDurationTimer = duration
        
        self:updateGauge(false)

    elseif (self.m_accelDurationTimer < duration) then
        self.m_accelDurationTimer = duration
        
    end
end

-------------------------------------
-- function setEnable
-------------------------------------
function GameMana:setEnable(b)
    self.m_bEnable = b
end