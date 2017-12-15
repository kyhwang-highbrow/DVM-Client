local PARENT = GameAuto

-------------------------------------
-- class GameAuto_Hero
-------------------------------------
GameAuto_Hero = class(PARENT, {
        m_inGameUI = 'UI',
     })

-------------------------------------
-- function init
-------------------------------------
function GameAuto_Hero:init(world, game_mana, ui)
    self.m_inGameUI = ui

    if (isExistValue(self.m_world.m_gameMode, GAME_MODE_ADVENTURE, GAME_MODE_NEST_DUNGEON, GAME_MODE_SECRET_DUNGEON)) then
        if (g_autoPlaySetting:isAutoPlay()) then
            -- 연속 전투가 활성화되어있다면 즉시 자동모드를 활성화시킴
            g_autoPlaySetting:setWithoutSaving('auto_mode', true)
        end
    end

    if (g_autoPlaySetting:get('auto_mode')) then
        if (self.m_world.m_gameMode ~= GAME_MODE_INTRO) then
            self:onStart()
        end
    end
end

-------------------------------------
-- function doWork
-------------------------------------
function GameAuto_Hero:doWork(dt)
    -- 인디케이터 조작중일 경우
    if (self.m_world.m_skillIndicatorMgr:isControlling()) then
        return
    end

    if (not self.m_world:isPossibleControl()) then
        return
    end

    PARENT.doWork(self, dt)
end

-------------------------------------
-- function onStart
-------------------------------------
function GameAuto_Hero:onStart()
    PARENT.onStart(self)
    
    if (self.m_inGameUI) then
        self.m_inGameUI.vars['autoVisual']:setVisible(true)
    end
end

-------------------------------------
-- function onEnd
-------------------------------------
function GameAuto_Hero:onEnd()
    PARENT.onEnd(self)

    if (self.m_inGameUI) then
        self.m_inGameUI.vars['autoVisual']:setVisible(false)
    end
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameAuto_Hero:onEvent(event_name, t_event, ...)
    if (event_name == 'auto_start') then
        self:onStart()

    elseif (event_name == 'auto_end') then
        self:onEnd()
        
    elseif (event_name == 'hero_active_skill') then
        self:setWorkTimer()

    end
end