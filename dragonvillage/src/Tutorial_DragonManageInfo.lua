local PARENT = UI_DragonManageInfo

-------------------------------------
-- class Tutorial_DragonManageInfo
-------------------------------------
Tutorial_DragonManageInfo = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function Tutorial_DragonManageInfo:init()
    local vars = self.vars

    UIManager:tutorial()
	UIManager:attachToTutorialNode(vars['collectionBtn'])
    UIManager:attachToTutorialNode(vars['evolutionBtn'])
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function Tutorial_DragonManageInfo:click_exitBtn()
    UIManager:releaseTutorial()
    PARENT.click_exitBtn(self)
end