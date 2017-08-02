local PARENT = UI_LobbyOld

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

	UIManager:doTutorial()

	UIManager:attachToTutorialNode(vars['adventureBtn'])
	UIManager:attachToTutorialNode(vars['inventoryBtn'])
	UIManager:attachToTutorialNode(vars['mailBtn'])

    UIManager:setTutorialStencil(vars['masterRoadBtn'].m_node)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function Tutorial_Lobby:click_exitBtn()
    UIManager:releaseTutorial()
end