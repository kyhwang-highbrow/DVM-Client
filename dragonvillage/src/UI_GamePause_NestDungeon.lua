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
    local scene = SceneNestDungeon()
    scene:runScene()
end

-------------------------------------
-- function click_retryButton
-------------------------------------
function UI_GamePause_NestDungeon:click_retryButton()
    local scene = SceneNestDungeon(self.m_stageID)
    scene:runScene()
end