local PARENT = UI_Game

-------------------------------------
-- class UI_GameEventGold
-------------------------------------
UI_GameEventGold = class(PARENT, {})

-------------------------------------
-- function getUIFileName
-------------------------------------
function UI_GameEventGold:getUIFileName()
    return 'ingame.ui'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameEventGold:initUI()
    PARENT.initUI(self)

    local vars = self.vars
    
    vars['clanRaidNode']:setVisible(true)
    vars['autoStartButton']:setVisible(true)
    vars['damageLabel']:setString('0')
end

-------------------------------------
-- function init_timeUI
-------------------------------------
function UI_GameEventGold:init_timeUI(display_wave, time)
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
-- @brief 총 피해량 표시
-------------------------------------
function UI_GameEventGold:setTotalDamage(total_damage)
    local vars = self.vars

    vars['damageLabel']:setString(comma_value(total_damage))
end