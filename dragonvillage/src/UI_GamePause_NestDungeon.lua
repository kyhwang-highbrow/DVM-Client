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
function UI_GamePause_NestDungeon:init(stage_id, gamekey, start_cb, end_cb)
end

-------------------------------------
-- function click_retryButton
-------------------------------------
function UI_GamePause_NestDungeon:click_retryButton()
    local function retry_func()
        local is_ready = true
        local scene = SceneNestDungeon(self.m_stageID, nil, is_ready)
        scene:runScene()
    end
    
    self:confirmExit(retry_func)
end