local PARENT = UI_Colosseum

-------------------------------------
-- class Tutorial_Colosseum
-------------------------------------
Tutorial_Colosseum = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function Tutorial_Colosseum:init()
    local vars = self.vars

    UIManager:doTutorial()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function Tutorial_Colosseum:click_exitBtn()
    UIManager:releaseTutorial()
    PARENT.click_exitBtn(self)
end