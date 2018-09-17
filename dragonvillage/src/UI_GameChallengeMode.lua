local PARENT = UI_GameArena

-------------------------------------
-- class UI_GameChallengeMode
-------------------------------------
UI_GameChallengeMode = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_GameChallengeMode:init(game_scene)
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_pauseButton() end, 'UI_GameChallengeMode')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameChallengeMode:initUI()
    PARENT.initUI(self)

    local vars = self.vars
    
    -- 그림자의 신전에서는 연속 전투를 제공하지 않음
    vars['autoStartButton']:setVisible(false)
end

-------------------------------------
-- function rockButton
-- @brief 그림자의 신전에서는 연속 전투를 제공하지 않음
-------------------------------------
function UI_GameChallengeMode:rockButton()
    local vars = self.vars

    -- 연속 전투 UI off
    vars['autoStartButton']:setVisible(false)
end
