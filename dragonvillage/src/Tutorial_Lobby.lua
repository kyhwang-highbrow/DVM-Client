local PARENT = UI_Lobby

-------------------------------------
-- class Tutorial_Lobby
-------------------------------------
Tutorial_Lobby = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function Tutorial_Lobby:init()
    local vars = self.vars

	UIManager:tutorial()
	UIManager:attachToTutorialNode(vars['adventureBtn'])
	UIManager:attachToTutorialNode(vars['inventoryBtn'])
	UIManager:attachToTutorialNode(vars['mailBtn'])
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function Tutorial_Lobby:click_exitBtn()
    UIManager:releaseTutorial()
end