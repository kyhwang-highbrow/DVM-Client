local PARENT = IEventListener:getCloneClass()

GLOBAL_COOL_TIME = {
    PASSIVE_SKILL = 1,
    ACTIVE_SKILL = 2
}

-------------------------------------
-- class GameCoolTime
-------------------------------------
GameCoolTime = class(PARENT, {
        m_world = '',
        
        m_mStartTime = 'table',     -- 쿨타임 타입별 시작 시간
        m_mRemainTimer = 'table',   -- 쿨타임 타입별 남은 시간
        
    })

-------------------------------------
-- function init
-------------------------------------
function GameCoolTime:init(world)
    self.m_world = world

    self.m_mStartTime = {}
    self.m_mStartTime[GLOBAL_COOL_TIME.PASSIVE_SKILL] = g_constant:get('INGAME', 'SKILL_GLOBAL_COOLTIME')
    self.m_mStartTime[GLOBAL_COOL_TIME.ACTIVE_SKILL] = g_constant:get('INGAME', 'SKILL_GLOBAL_COOLTIME')
    
    self.m_mRemainTimer = {}
    self.m_mRemainTimer[GLOBAL_COOL_TIME.PASSIVE_SKILL] = 0
    self.m_mRemainTimer[GLOBAL_COOL_TIME.ACTIVE_SKILL] = 0
end

-------------------------------------
-- function update
-------------------------------------
function GameCoolTime:update(dt)
    -- 글로벌 쿨타임 계산
    for k, v in pairs(self.m_mRemainTimer) do
        local remainTimer = v
        if (remainTimer > 0) then
            remainTimer = remainTimer - dt

            if (remainTimer < 0) then
                remainTimer = 0
            end
        end

        self.m_mRemainTimer[k] = remainTimer
    end
end

-------------------------------------
-- function onEvent
-- @brief
-------------------------------------
function GameCoolTime:onEvent(event_name, t_event, ...)
    local arg = {...}
    local add_time = arg[1] or 0

    if (event_name == 'set_global_cool_time_passive') then
        self.m_mRemainTimer[GLOBAL_COOL_TIME.PASSIVE_SKILL] = self.m_mStartTime[GLOBAL_COOL_TIME.PASSIVE_SKILL] + add_time

    elseif (event_name == 'set_global_cool_time_active') then
        self.m_mRemainTimer[GLOBAL_COOL_TIME.ACTIVE_SKILL] = self.m_mStartTime[GLOBAL_COOL_TIME.ACTIVE_SKILL] + add_time

    end
end

-------------------------------------
-- function get
-------------------------------------
function GameCoolTime:get(type)
    return self.m_mRemainTimer[type]
end

-------------------------------------
-- function isWaiting
-------------------------------------
function GameCoolTime:isWaiting(type)
    local val = self.m_mRemainTimer[type]
    --cclog('GameCoolTime:isWaiting val = ' .. val)
    return (self.m_mRemainTimer[type] > 0)
end