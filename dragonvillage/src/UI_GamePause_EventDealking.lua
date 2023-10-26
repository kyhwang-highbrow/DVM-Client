local PARENT = UI_GamePause

-------------------------------------
-- class UI_GamePause_EventDealking
-------------------------------------
UI_GamePause_EventDealking = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GamePause_EventDealking:init(stage_id, gamekey, start_cb, end_cb)
end

-------------------------------------
-- function click_retryButton
-------------------------------------
function UI_GamePause_EventDealking:click_retryButton()
    local function retry_func()
        link_type = 'ply_cldg'
        QuickLinkHelper.quickLink(link_type, condition)
    end
    
    self:confirmExit(retry_func)
end

-------------------------------------
-- function confirmExit
-------------------------------------
function UI_GamePause_EventDealking:confirmExit(exit_cb)
    local msg = Str('현재까지의 점수로 던전이 종료됩니다.\n종료하시겠습니까?')
    local function ok_cb()
        g_gameScene.m_gameWorld.m_gameState:changeState(GAME_STATE_RESULT)
        self:click_continueButton()
    end

    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_cb)
end