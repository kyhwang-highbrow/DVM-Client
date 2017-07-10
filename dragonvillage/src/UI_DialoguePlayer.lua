local PARENT = UI_ScenarioPlayer

-------------------------------------
-- class UI_DialoguePlayer
-------------------------------------
UI_DialoguePlayer = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DialoguePlayer:init(scenario_name)
end

-------------------------------------
-- function init_player
-------------------------------------
function UI_DialoguePlayer:init_player()
    local vars = self:load_keepZOrder('scenario_talk_new.ui', false)

	UIManager:open(self,UIManager.NORMAL)
	vars['skipBtn']:setVisible(false)
	self.m_bSkipEnable = false
end