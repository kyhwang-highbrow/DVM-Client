local PARENT = UI_GameResultNew

-------------------------------------
-- class UI_GameResult_NestDungeon
-------------------------------------
UI_GameResult_NestDungeon = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GameResult_NestDungeon:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list)
end

-------------------------------------
-- function click_retryButton
-------------------------------------
function UI_GameResult_NestDungeon:click_retryButton()
    local scene = SceneNestDungeon(self.m_stageID)
    scene:runScene()
end

-------------------------------------
-- function click_backBtn
-------------------------------------
function UI_GameResult_NestDungeon:click_backBtn()
    local scene = SceneNestDungeon(self.m_stageID)
    scene:runScene()
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResult_NestDungeon:click_nextBtn()
    local next_stage_id = g_stageData:getNextStage(self.m_stageID) or self.m_stageID
    local scene = SceneNestDungeon(next_stage_id)
    scene:runScene()
end