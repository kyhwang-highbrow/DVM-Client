local PARENT = UI_DragonManagementEvolution

-------------------------------------
-- class Tutorial_Lobby
-------------------------------------
Tutorial_DragonEvolution = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function Tutorial_DragonEvolution:init()
    local vars = self.vars

    UIManager:tutorial()
	UIManager:attachToTutorialNode(vars['moveBtn1'])
    UIManager:attachToTutorialNode(vars['moveBtn2'])
    UIManager:attachToTutorialNode(vars['moveBtn3'])
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function Tutorial_DragonEvolution:click_exitBtn()
    UIManager:releaseTutorial()
    PARENT.click_exitBtn(self)
end