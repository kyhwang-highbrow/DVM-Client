local PARENT = UI_GameClanRaid

-------------------------------------
-- class UI_GameIllusion
-------------------------------------
UI_GameIllusion = class(PARENT, {})

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameIllusion:initUI()
    PARENT.initUI(self)

    local vars = self.vars
    
    vars['clanRaidNode']:setVisible(true)
    vars['speedVisual']:setVisible(true)
    vars['speedButton']:setVisible(true)
    vars['autoStartVisual']:setVisible(true)
    vars['autoStartButton']:setVisible(true)
    vars['effectBtn']:setVisible(true)
    

    vars['damageLabel']:setString('0')
end

-------------------------------------
-- function setAutoPlayUI
-- @brief 연속 전투 정보 UI
-------------------------------------
function UI_GameIllusion:setAutoPlayUI()
    local vars = self.vars

    vars['autoStartNode']:setVisible(g_autoPlaySetting:isAutoPlay())
    vars['autoStartNumberLabel']:setString(Str('{1}회 반복중', g_autoPlaySetting:getAutoPlayCnt()))
    vars['autoStartVisual']:setVisible(g_autoPlaySetting:isAutoPlay())
end
