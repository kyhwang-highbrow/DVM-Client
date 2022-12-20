-------------------------------------
-- class GameTimeScale
-------------------------------------
GameTimeScale = class({
        m_world = 'GameWorld',

        m_baseTimeScale = 'number',     -- 기본 타임 스케일
        m_timeScale = 'number',      -- 설정된 타임 스케일
        m_remainKeepTime = 'number',    -- 현재 타임 스케일의 남은 유지 시간
     })

-------------------------------------
-- function init
-------------------------------------
function GameTimeScale:init(world)
    self.m_world = world
    
    self.m_baseTimeScale = 1
    self.m_timeScale = 1
    self.m_remainKeepTime = 0

    
    if (self.m_world.m_gameMode == GAME_MODE_INTRO) then
        -- 인트로 전투일 경우 2배속 고정
        --self.m_baseTimeScale = g_constant:get('INGAME', 'QUICK_MODE_TIME_SCALE')

    elseif (self.m_world.m_gameMode == GAME_MODE_CLAN_RAID) then
        -- 클랜 던전일 경우 2배속 고정
        self.m_baseTimeScale = g_constant:get('INGAME', 'QUICK_MODE_TIME_SCALE')

    elseif (g_autoPlaySetting:get('quick_mode')) then
        self.m_baseTimeScale = g_constant:get('INGAME', 'QUICK_MODE_TIME_SCALE')
        
    end

    self:modify()
end

-------------------------------------
-- function update
-------------------------------------
function GameTimeScale:update(dt)
    if self.m_remainKeepTime > 0 then
        self.m_remainKeepTime = self.m_remainKeepTime - dt
        if self.m_remainKeepTime <= 0 then
            self:reset()
        end
    end
end


-------------------------------------
-- function modify
-------------------------------------
function GameTimeScale:modify()
    if g_gameScene then
        local realTimeScale = self.m_baseTimeScale * self.m_timeScale

        g_gameScene:setTimeScale(realTimeScale)
    end
end

-------------------------------------
-- function reset
-------------------------------------
function GameTimeScale:reset()
    self.m_timeScale = 1

    self:modify()
end

-------------------------------------
-- function setBase
-------------------------------------
function GameTimeScale:setBase(baseTimeScale)
    self.m_baseTimeScale = baseTimeScale

    self:modify()
end

-------------------------------------
-- function getBase
-------------------------------------
function GameTimeScale:getBase()
    return self.m_baseTimeScale
end

-------------------------------------
-- function set
-- @brief keepTime 시간동안만 timeScale을 변경시킴(keepTime이 없거나 0일 경우 무한 지속)
-------------------------------------
function GameTimeScale:set(timeScale, keepTime)
    self.m_timeScale = timeScale
    self.m_remainKeepTime = keepTime or 0

    -- 타임 스테일에 맞도록 유지시간 계산
    self.m_remainKeepTime = self.m_remainKeepTime * self.m_timeScale

    self:modify()
end

-------------------------------------
-- function get
-------------------------------------
function GameTimeScale:get()
    return self.m_timeScale
end