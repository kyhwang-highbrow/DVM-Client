local PARENT = UI_GamePause

-------------------------------------
-- class UI_GamePause_ClanRaid
-------------------------------------
UI_GamePause_ClanRaid = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GamePause_ClanRaid:init(stage_id, gamekey, start_cb, end_cb)
end

-------------------------------------
-- function click_retryButton
-------------------------------------
function UI_GamePause_ClanRaid:click_retryButton()
    local function retry_func()
        link_type = 'ply_clan_raid'
        QuickLinkHelper.quickLink(link_type, condition)
    end
    
    self:confirmExit(retry_func)
end