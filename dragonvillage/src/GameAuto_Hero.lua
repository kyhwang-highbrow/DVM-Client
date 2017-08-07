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
function GameAuto_Hero:init(world)
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
-- function update
-------------------------------------
function GameAuto_Hero:update(dt)
    self:update_fight(dt)
end

-------------------------------------
-- function update_fight
-------------------------------------
function GameAuto_Hero:update_fight(dt)
    -- 인디케이터 조작중일 경우
    if (self.m_world.m_skillIndicatorMgr:isControlling()) then
        return
    end

    if (not self.m_world:isPossibleControl()) then
        return
    end

    PARENT.update_fight(self, dt)
end

-------------------------------------
-- function proccess_tamer
-------------------------------------
function GameAuto_Hero:proccess_tamer()
    if (self.m_world.m_gameMode == GAME_MODE_COLOSSEUM) then
        return false
    end

    local tamer = self.m_world.m_tamer
    if (not tamer) then return end

    if (not tamer:isEndActiveSkillCool()) then
        return false
    end

    local t_skill = tamer:getActiveSkillTable()

    -- TODO : 스킬 타입별 고유한 조건으로 체크되어야함
    if (self:checkSkill(tamer, t_skill, GAME_AUTO_AI_ATTACK__COOLTIME, GAME_AUTO_AI_HEAL__LOW_HP)) then
        --tamer:doSkillActive()

        -- AI 딜레이 시간 설정
        self.m_aiDelayTime = self:getAiDelayTime()

        return true
    end

    return false
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
-- function getUnitList
-------------------------------------
function GameAuto_Hero:getUnitList()
    return self.m_world:getDragonList()
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
        self.m_aiDelayTime = self:getAiDelayTime()

    end
end