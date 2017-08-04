local PARENT = UI_AncientTower

-------------------------------------
-- class Tutorial_AncientTower
-------------------------------------
Tutorial_AncientTower = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function Tutorial_AncientTower:init()
    local vars = self.vars

    UIManager:doTutorial()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function Tutorial_AncientTower:click_exitBtn()
    UIManager:releaseTutorial()
    PARENT.click_exitBtn(self)
end