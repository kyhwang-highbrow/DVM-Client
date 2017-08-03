local PARENT = class(IEventListener:getCloneClass(), IEventDispatcher:getCloneTable())

MAX_MANA = 5

-------------------------------------
-- class GameMana
-------------------------------------
GameMana = class(PARENT, {
        m_world = 'GameWorld',
        m_inGameUI = 'UI',

        m_bLeftFormation = 'boolean',
        
        m_prevValue = 'number',
        m_value = 'number',

        m_incValuePerSec = 'number',

        m_bEnable = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function GameMana:init(world, left_formation)
    self.m_world = world
    self.m_inGameUI = world.m_inGameUI

    self.m_bLeftFormation = left_formation

    self.m_prevValue = -1
    self.m_value = 0
    self.m_incValuePerSec = 1 / g_constant:get('INGAME', 'MANA_INTERVAL')
    self.m_bEnable = true
end

-------------------------------------
-- function update
-------------------------------------
function GameMana:update(dt)
    local add = 0

    if (self.m_bEnable) then
        add = self.m_incValuePerSec * dt
    end

    self.m_value = self.m_value + add
    self.m_value = math_min(self.m_value, MAX_MANA)
    
    self:updateGauge(self.m_prevValue ~= math_floor(self.m_value))

    self.m_prevValue = math_floor(self.m_value)
end

-------------------------------------
-- function updateGauge
-- @param updated_int : 정수값이 갱신되었는지 여부
-------------------------------------
function GameMana:updateGauge(updated_int)
    if (not self.m_inGameUI) then return end

    if (self.m_bLeftFormation) then
        self.m_inGameUI:setMana(self.m_value, updated_int)
    end
end

-------------------------------------
-- function onEvent
-- @brief
-------------------------------------
function GameMana:onEvent(event_name, t_event, ...)
    if (event_name == 'dragon_active_skill') then
        local arg = {...}
        local dragon = arg[1]
        
        if (self.m_bLeftFormation == dragon.m_bLeftFormation) then
            self.m_value = self.m_value - dragon.m_activeSkillManaCost
        end
    end
end

-------------------------------------
-- function getCurrMana
-------------------------------------
function GameMana:getCurrMana()
    return math_floor(self.m_value)
end

-------------------------------------
-- function addMana
-------------------------------------
function GameMana:addMana(value)
    self.m_value = self.m_value + value
    self.m_value = math_min(self.m_value, MAX_MANA)

    self:updateGauge()
end

-------------------------------------
-- function setMaxMana
-------------------------------------
function GameMana:setMaxMana()
    self.m_value = MAX_MANA

    self:updateGauge()
end

-------------------------------------
-- function resetMana
-------------------------------------
function GameMana:resetMana()
    self.m_value = 0

    self:updateGauge()
end

-------------------------------------
-- function setEnable
-------------------------------------
function GameMana:setEnable(b)
    self.m_bEnable = b
end