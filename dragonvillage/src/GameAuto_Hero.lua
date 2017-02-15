local PARENT = GameAuto

local AI_FEVER_DELAY_TIME = 0.5

-------------------------------------
-- class GameAuto_Hero
-------------------------------------
GameAuto_Hero = class(PARENT, {
        -- 피버 처리 관련
        m_gameFever = 'GameFever',
        m_aiFeverDelayTime = 'number',  -- 피버 모드 공격 딜레이 시간

        m_tCastingEnemyList = 'table',  -- 시전 중인 적 리스트

        -- UI
        m_autoVisual = '',
     })

-------------------------------------
-- function init
-------------------------------------
function GameAuto_Hero:init(world)
    self.m_gameFever = nil
    
    self.m_aiFeverDelayTime = AI_FEVER_DELAY_TIME

    self.m_tCastingEnemyList = {}

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
-- function bindGameFever
-------------------------------------
function GameAuto_Hero:bindGameFever(gameFever)
    self.m_gameFever = gameFever
    self.m_gameFever:addListener('fever_attack', self)
end

-------------------------------------
-- function update
-------------------------------------
function GameAuto_Hero:update(dt)
    if (not self:isActive()) then return end

    if (self.m_gameFever and self.m_gameFever:isActive()) then
        -- 피버모드가 활성화된 상태일 경우
        self:update_fever(dt)
    else
        self:update_fight(dt)
    end
end

-------------------------------------
-- function update_fight
-------------------------------------
function GameAuto_Hero:update_fight(dt)
    if (self.m_world.m_skillIndicatorMgr:isControlling()) then
        return
    end

    PARENT.update_fight(self, dt)
end

-------------------------------------
-- function update_fever
-------------------------------------
function GameAuto_Hero:update_fever(dt)
    if (self.m_aiFeverDelayTime > 0) then
        self.m_aiFeverDelayTime = self.m_aiFeverDelayTime - dt

        if (self.m_aiFeverDelayTime < 0) then
            self.m_aiFeverDelayTime = 0
        end
    else
        self.m_gameFever:doAttack()
    end
end

-------------------------------------
-- function proccess_tamer
-------------------------------------
function GameAuto_Hero:proccess_tamer()
    if (self.m_world.m_gameMode == GAME_MODE_COLOSSEUM) then
        return false
    end

    local tamerSkillSystem = self.m_world.m_tamerSkillSystem
    if (not tamerSkillSystem) then return end

    local tamerSkillIdx = g_autoPlaySetting:get('tamer_skill')
    if (tamerSkillSystem:isEndSkillCoolTime(tamerSkillIdx)) then
        tamerSkillSystem:click_tamerSkillBtn(tamerSkillIdx)

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

    elseif (event_name == 'hero_casting_start') then
               
    elseif (event_name == 'enemy_casting_start') then
        local arg = {...}
        local enemy = arg[1]

        table.insert(self.m_tCastingEnemyList, enemy)
        
    elseif (event_name == 'hero_active_skill') then
        self.m_aiDelayTime = self:getAiDelayTime()
        
    elseif (event_name == 'fever_attack') then
        self.m_aiFeverDelayTime = AI_FEVER_DELAY_TIME

    end
end