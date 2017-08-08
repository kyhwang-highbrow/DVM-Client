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
-- function click_retryButton
-------------------------------------
function UI_GamePause_SecretDungeon:click_retryButton()
    local function retry_func()
        local stage_id = self.m_stageID
        UINavigator:goTo('secret_relation', stage_id)
    end
    
    self:confirmExit(retry_func)
end