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
    
    vars['speedVisual']:setVisible(false)
    vars['speedButton']:setVisible(false)
    vars['autoStartVisual']:setVisible(false)
    vars['autoStartButton']:setVisible(false)
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