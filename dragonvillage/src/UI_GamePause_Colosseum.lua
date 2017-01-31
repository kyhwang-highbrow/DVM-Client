local PARENT = UI_GamePause

-------------------------------------
-- class UI_GamePause_Colosseum
-------------------------------------
UI_GamePause_Colosseum = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GamePause_Colosseum:init(stage_id, start_cb, end_cb)
end

-------------------------------------
-- function click_homeButton
-------------------------------------
function UI_GamePause_Colosseum:click_homeButton()
    local scene = SceneLobby()
    scene:runScene()
end

-------------------------------------
-- function click_retryButton
-------------------------------------
function UI_GamePause_Colosseum:click_retryButton()
    local scene = SceneColosseum()
    scene:runScene()
end