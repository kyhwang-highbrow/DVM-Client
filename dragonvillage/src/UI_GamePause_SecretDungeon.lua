local PARENT = UI_GamePause

-------------------------------------
-- class UI_GamePause_SecretDungeon
-------------------------------------
UI_GamePause_SecretDungeon = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GamePause_SecretDungeon:init(stage_id, start_cb, end_cb)
end

-------------------------------------
-- function click_homeButton
-------------------------------------
function UI_GamePause_SecretDungeon:click_homeButton()
	local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
end

-------------------------------------
-- function click_retryButton
-------------------------------------
function UI_GamePause_SecretDungeon:click_retryButton()
    local stage_id = self.m_stageID
    local use_scene = true
    g_secretDungeonData:goToSecretDungeonScene(stage_id, use_scene)
end