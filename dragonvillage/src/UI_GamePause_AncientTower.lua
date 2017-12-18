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
function UI_GamePause_AncientTower:init(stage_id, gamekey, start_cb, end_cb)
end

-------------------------------------
-- function click_retryButton
-------------------------------------
function UI_GamePause_AncientTower:click_retryButton()
    local function retry_func()
        g_ancientTowerData:checkAttrTowerAndGoStage()
    end
    
    self:confirmExit(retry_func)
end