local PARENT = GameAuto

-------------------------------------
-- class GameAuto_Hero
-------------------------------------
GameAuto_Hero = class(PARENT, {
        -- UI
        m_autoVisual = '',
     })

-------------------------------------
-- function init
-------------------------------------
function GameAuto_Hero:init(world, game_mana)
    self:initUI()
    
    if (g_autoPlaySetting:isAutoPlay()) then
        -- 연속 전투가 활성화되어있다면 즉시 자동모드를 활성화시킴
        g_autoPlaySetting:set('auto_mode', true)
    end

    if (g_autoPlaySetting:get('auto_mode')) then
        self:onStart()
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function GameAuto_Hero:initUI()
    local ui = self.m_world.m_inGameUI

    self.m_autoVisual = ui.vars['autoVisual']
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
    
    if (self.m_autoVisual) then
        self.m_autoVisual:setVisible(true)
    end
end

-------------------------------------
-- function onEnd
-------------------------------------
function GameAuto_Hero:onEnd()
    PARENT.onEnd(self)

    if (self.m_autoVisual) then
        self.m_autoVisual:setVisible(false)
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

-------------------------------------
-- function doWork_skill
-------------------------------------
function GameAuto_Hero:doWork_skill(unit, priority)
    local b = PARENT.doWork_skill(self, unit, priority)

    if (not b) then
    end

    return b
end