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
    if g_nestDungeonData:isExistData() then
        local scene = SceneNestDungeon(self.m_stageID)
        scene:runScene()
    else
        local scene = SceneGame(nil, self.m_stageID, 'stage_' .. self.m_stageID, false)
        scene:runScene()
    end
end

-------------------------------------
-- function click_backBtn
-------------------------------------
function UI_GameResult_NestDungeon:click_backBtn()
    if g_nestDungeonData:isExistData() then
        local scene = SceneNestDungeon(self.m_stageID)
        scene:runScene()
    else
        local scene = SceneLobby()
        scene:runScene()
    end
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResult_NestDungeon:click_nextBtn()
    -- @TODO sgkim 네스트 던전도 다음 스테이지로 이동 가능 하도록 변경할 것

    -- 다음 스테이지 ID 지정
    if g_nestDungeonData:isExistData() then
        local scene = SceneNestDungeon(self.m_stageID)
        scene:runScene()
    else
        local scene = SceneGame(nil, self.m_stageID, 'stage_' .. self.m_stageID, false)
        scene:runScene()
    end
end
