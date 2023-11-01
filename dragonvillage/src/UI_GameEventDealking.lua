local PARENT = UI_Game

-------------------------------------
-- class UI_GameEventDealking
-------------------------------------
UI_GameEventDealking = class(PARENT, {})

-------------------------------------
-- function getUIFileName
-------------------------------------
function UI_GameEventDealking:getUIFileName()
    return 'ingame.ui'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameEventDealking:initUI()
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
-- function initHotTimeUI
-- @brief 핫타임 띄우지 않도록 처리
-------------------------------------
function UI_GameEventDealking:initHotTimeUI()
	local vars = self.vars
	vars['hotTimeStBtn']:setVisible(false)
    vars['hotTimeGoldBtn']:setVisible(false)
    vars['hotTimeExpBtn']:setVisible(false)
    vars['hotTimeMarbleBtn']:setVisible(false)
end

-------------------------------------
-- function init_timeUI
-------------------------------------
function UI_GameEventDealking:init_timeUI(display_wave, time)
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
-- function setTime
-------------------------------------
function UI_GameEventDealking:setTime(sec, is_limit)
    local sec = math_floor(sec)
    local m = math_floor(sec / 60)
    local s = sec % 60
    local str = string.format('%02d:%02d', m, s)
    self.m_timeLabel:setString(str)

	-- 제한시간이 있는 경우에 색상 부여
	if (is_limit) then

        local world = self.m_gameScene.m_gameWorld
        local game_state = world.m_gameState
        
		-- 피버 타임이면 붉은색으로 색상 변경
		if (sec <= game_state:getRemainFeverTime()) then
			self.m_timeLabel:setColor(cc.c3b(255, 0, 0))
		-- 이상은 초록색
		else
			self.m_timeLabel:setColor(cc.c3b(0, 255, 0))
		end
	end
end


-------------------------------------
-- function setTotalDamage
-- @brief 총 피해량 표시
-------------------------------------
function UI_GameEventDealking:setTotalDamage(total_damage)
    local vars = self.vars
    vars['damageLabel']:setString(comma_value(total_damage))
end