local PARENT = UI_GamePause

-------------------------------------
-- class UI_GamePause_NestDungeon
-------------------------------------
UI_GamePause_NestDungeon = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GamePause_NestDungeon:init(stage_id, start_cb, end_cb)
end

-------------------------------------
-- function click_homeButton
-------------------------------------
function UI_GamePause_NestDungeon:click_homeButton()
    if g_nestDungeonData:isExistData() then
        local scene = SceneNestDungeon()
        scene:runScene()
    else
        local scene = SceneLobby()
        scene:runScene()
    end
end

-------------------------------------
-- function click_retryButton
-------------------------------------
function UI_GamePause_NestDungeon:click_retryButton()
    if g_nestDungeonData:isExistData() then
        local scene = SceneNestDungeon(self.m_stageID)
        scene:runScene()
    else
        local scene = SceneGame(nil, self.m_stageID, 'stage_' .. self.m_stageID, false)
        scene:runScene()
    end
end