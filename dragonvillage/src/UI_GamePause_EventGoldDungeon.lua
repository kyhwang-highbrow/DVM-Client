local PARENT = UI_GamePause

-------------------------------------
-- class UI_GamePause_EventGoldDungeon
-------------------------------------
UI_GamePause_EventGoldDungeon = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GamePause_EventGoldDungeon:init(stage_id, gamekey, start_cb, end_cb)
end

-------------------------------------
-- function click_retryButton
-------------------------------------
function UI_GamePause_EventGoldDungeon:click_retryButton()
    local function retry_func()
        if (GOLD_DUNGEON_ALWAYS_OPEN == true) then
            UINavigator:goTo('gold_dungeon')
        else
            UINavigator:goTo('event_gold_dungeon')
        end
    end
    
    self:confirmExit(retry_func)
end

-------------------------------------
-- function click_homeButton
-------------------------------------
function UI_GamePause_EventGoldDungeon:click_homeButton()
    local function retry_func()
        if (GOLD_DUNGEON_ALWAYS_OPEN == true) then
            UINavigator:goTo('gold_dungeon')
        else
            UINavigator:goTo('event_gold_dungeon')
        end
    end
    
    self:confirmExit(retry_func)
end