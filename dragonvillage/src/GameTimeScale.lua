-------------------------------------
-- class GameTimeScale
-------------------------------------
GameTimeScale = class({
        m_world = 'GameWorld',
        m_curTimeScaleStep = 'number', -- 단계
        m_maxTimeScaleStep = 'number', -- 최종 단계
        m_timeScaleStepList = 'list<number>', -- 단계별 timescale

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

    self.m_curTimeScaleStep = 1
    self.m_maxTimeScaleStep = 2
    self.m_timeScaleStepList = {1, 1.5, 3}


    if (self.m_world.m_gameMode == GAME_MODE_CLAN_WAR) then -- 클랜전
        self.m_maxTimeScaleStep = 3
    elseif (self.m_world.m_gameMode == GAME_MODE_ANCIENT_TOWER) then -- 고대의 탑, 시험의 탑
        self.m_maxTimeScaleStep = 3
    elseif (self.m_world.m_gameMode == GAME_MODE_LEAGUE_RAID) then -- 레이드
        self.m_maxTimeScaleStep = 3
    elseif (self.m_world.m_gameMode == GAME_MODE_ARENA) then -- 아레나
        self.m_maxTimeScaleStep = 3
    elseif (self.m_world.m_gameMode == GAME_MODE_ARENA_NEW) then -- 아레나
        self.m_maxTimeScaleStep = 3
    elseif (self.m_world.m_gameMode == GAME_MODE_COLOSSEUM) then -- 콜로세움
        self.m_maxTimeScaleStep = 3
    elseif (self.m_world.m_gameMode == GAME_MODE_CHALLENGE_MODE) then -- 그림자 신전
        self.m_maxTimeScaleStep = 3
    end

    if (self.m_world.m_gameMode == GAME_MODE_INTRO) then
    elseif (self.m_world.m_gameMode == GAME_MODE_CLAN_RAID) then
        -- 클랜 던전일 경우 2배속 고정
        self.m_baseTimeScale = g_constant:get('INGAME', 'QUICK_MODE_TIME_SCALE')
    else
        
        local time_scale = g_autoPlaySetting:get('quick_mode_time_scale')
        local idx = table.find(self.m_timeScaleStepList, time_scale)
        self.m_baseTimeScale = time_scale
        if idx ~= nil then
            self.m_curTimeScaleStep = math_min(idx, self.m_maxTimeScaleStep)
            cclog('self.m_curTimeScaleStep', self.m_curTimeScaleStep)
        end
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

-------------------------------------
-- function increaseTimeScaleStep
-- @brief 게임 배속 단계 증가(최종 단계에서 증가 시킬 경우 다시 1배속)
-------------------------------------
function GameTimeScale:increaseTimeScaleStep()
    local list_count = #self.m_timeScaleStepList
    if self.m_curTimeScaleStep + 1 > self.m_maxTimeScaleStep then
        self.m_curTimeScaleStep = 1
    else
        self.m_curTimeScaleStep = self.m_curTimeScaleStep + 1
    end

    local time_scale = self.m_timeScaleStepList[self.m_curTimeScaleStep]
    self:setBase(time_scale)
    g_autoPlaySetting:setWithoutSaving('quick_mode_time_scale', time_scale)    

    if self.m_curTimeScaleStep == 1 then
        UIManager:toastNotificationGreen(Str('빠른모드 비활성화'))
    else
        UIManager:toastNotificationGreen(Str('{1}배속 모드 활성화', math_pow(2, self.m_curTimeScaleStep - 1)))
    end

    return self.m_curTimeScaleStep
end

-------------------------------------
-- function getTimeScaleStep
-- @brief 게임 배속 단계
-------------------------------------
function GameTimeScale:getTimeScaleStep()
    return self.m_curTimeScaleStep
end