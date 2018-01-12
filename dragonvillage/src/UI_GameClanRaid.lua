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

    vars['damageLabel']:setString('0')
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