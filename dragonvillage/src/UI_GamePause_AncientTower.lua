local PARENT = UI_GamePause

-------------------------------------
-- class UI_GamePause_AncientTower
-------------------------------------
UI_GamePause_AncientTower = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GamePause_AncientTower:init(stage_id, start_cb, end_cb)
end

-------------------------------------
-- function click_homeButton
-------------------------------------
function UI_GamePause_AncientTower:click_homeButton()
	local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
end

-------------------------------------
-- function click_retryButton
-------------------------------------
function UI_GamePause_AncientTower:click_retryButton()
    g_ancientTowerData:goToAncientTowerScene(true) -- use_scene
end