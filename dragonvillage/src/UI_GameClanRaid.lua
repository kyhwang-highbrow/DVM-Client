local PARENT = UI_Game

-------------------------------------
-- class UI_GameClanRaid
-------------------------------------
UI_GameClanRaid = class(PARENT, {})

-------------------------------------
-- function getUIFileName
-------------------------------------
function UI_GameClanRaid:getUIFileName()
    return 'ingame.ui'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameClanRaid:initUI()
    PARENT.initUI(self)

    local vars = self.vars
    
    vars['clanRaidNode']:setVisible(true)
    vars['speedVisual']:setVisible(false)
    vars['speedButton']:setVisible(false)
    vars['autoStartVisual']:setVisible(false)
    vars['autoStartButton']:setVisible(false)
    vars['effectBtn']:setVisible(false)
    

    vars['damageLabel']:setString('0')
end

-------------------------------------
-- function click_pauseButton
-------------------------------------
function UI_GameClanRaid:click_pauseButton()
	local world = self.m_gameScene.m_gameWorld
    if (not world or world:isFinished()) then return end
    
    if (world.m_skillIndicatorMgr and world.m_skillIndicatorMgr:isControlling()) then
        world.m_skillIndicatorMgr:clear()
    end

    -- 이미 타임 아웃 상태에서 일시정지를 누를 경우
    local game_state = world.m_gameState
    if (game_state and game_state:isTimeOut()) then
        world:setGameFinish()

        game_state:changeState(GAME_STATE_FAILURE)
        return
    end

    local stage_id = self.m_gameScene.m_stageID
    local game_mode = self.m_gameScene.m_gameMode
    local gamekey = self.m_gameScene.m_gameKey

    local function start_cb()
        self.m_gameScene:gamePause()
    end

    local function end_cb()
        self.m_gameScene:gameResume()
    end

    UI_GamePause_ClanRaid(stage_id, gamekey, start_cb, end_cb)
end

-------------------------------------
-- function initHotTimeUI
-- @brief 핫타임 띄우지 않도록 처리
-------------------------------------
function UI_GameClanRaid:initHotTimeUI()
	local vars = self.vars
	vars['hotTimeStBtn']:setVisible(false)
    vars['hotTimeGoldBtn']:setVisible(false)
    vars['hotTimeExpBtn']:setVisible(false)
    vars['hotTimeMarbleBtn']:setVisible(false)
end

-------------------------------------
-- function init_timeUI
-------------------------------------
function UI_GameClanRaid:init_timeUI(display_wave, time)
    local vars = self.vars

    vars['timeNode']:setVisible(false)
    vars['waveVisual']:setVisible(false)
    
    self.m_timeLabel = vars['clanRaidtimeLabel']
    
    if (time) then
        self.m_timeLabel:setVisible(true)

        self:setTime(time)
    end
end

-------------------------------------
-- function setAutoPlayUI
-- @brief 연속 전투 정보 UI
-------------------------------------
function UI_GameClanRaid:setAutoPlayUI()
    local vars = self.vars

    vars['autoStartNode']:setVisible(false)
    vars['autoStartNumberLabel']:setVisible(false)
    vars['autoStartVisual']:setVisible(false)
end

-------------------------------------
-- function setAutoPlayUI
-- @brief 총 피해량 표시
-------------------------------------
function UI_GameClanRaid:setTotalDamage(total_damage)
    local vars = self.vars

    vars['damageLabel']:setString(comma_value(total_damage))
end