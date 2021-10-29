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
            local ui = UIManager:getLastUI()
            ui:sceneFadeInAction()
        end

        local ui = UI_ReadySceneNew_IllusionDungeon(stage_id)
        ui:setCloseCB(close_cb)

    end

    self:sceneFadeOutAndCallFunc(func)
end

-------------------------------------
-- function refresh_difficultyBadge
-- @brief 스테이지 난이도 (모험모드에 한함)
-------------------------------------
function UI_AdventureStageInfo_IllusionDungeon:refresh_difficultyBadge()
    local vars = self.vars
    local stage_id = self.m_stageID

    vars['difficultyLabel']:setVisible(true)
   
    local difficulty = g_illusionDungeonData:parseStageID(stage_id)
   
    if (difficulty == 1) then
        vars['difficultyLabel']:setColor(COLOR['diff_normal'])
        vars['difficultyLabel']:setString(Str('보통'))
   
    elseif (difficulty == 2) then
        vars['difficultyLabel']:setColor(COLOR['diff_hard'])
        vars['difficultyLabel']:setString(Str('어려움'))
   
    elseif (difficulty == 3) then
        vars['difficultyLabel']:setColor(COLOR['diff_hell'])
        vars['difficultyLabel']:setString(Str('지옥'))
    elseif (difficulty == 4) then
        vars['difficultyLabel']:setColor(COLOR['diff_hellfire'])
        vars['difficultyLabel']:setString(Str('불지옥'))
    end

end