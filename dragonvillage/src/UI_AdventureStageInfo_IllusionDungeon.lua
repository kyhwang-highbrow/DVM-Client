local PARENT = UI_AdventureStageInfo

-------------------------------------
-- class UI_AdventureStageInfo_IllusionDungeon
-------------------------------------
UI_AdventureStageInfo_IllusionDungeon = class(PARENT,{

    })

-------------------------------------
-- function click_enterBtn
-------------------------------------
function UI_AdventureStageInfo_IllusionDungeon:click_enterBtn()
    local func = function()
        local stage_id = self.m_stageID

        local function close_cb()
            self:sceneFadeInAction()
        end

        local ui = UI_ReadySceneNew_IllusionDungeon(stage_id)
        ui:setCloseCB(close_cb)

    end

    self:sceneFadeOutAndCallFunc(func)
end