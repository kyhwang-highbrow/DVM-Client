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
function UI_GamePause_Colosseum:init(stage_id, gamekey, start_cb, end_cb)
end

-------------------------------------
-- function click_homeButton
-- @brief 로비로 가기 버튼
-------------------------------------
function UI_GamePause_Colosseum:click_homeButton()
    local function ok_cb()
	    local is_use_loading = true
        local scene = SceneLobby(is_use_loading)
        scene:runScene()
    end

    self:confirmExit(ok_cb)
end

-------------------------------------
-- function click_retryButton
-- @brief 다시하기 버튼
-------------------------------------
function UI_GamePause_Colosseum:click_retryButton()
    local function ok_cb()
        UINavigator:goTo('colosseum')
    end

    self:confirmExit(ok_cb)
end

-------------------------------------
-- function confirmExit
-- @brief 콜로세움에서 중도에 나가면 패배로 처리됨
--        유저에게 패배처리가 되어도 나가겠냐는 확인 팝업
-------------------------------------
function UI_GamePause_Colosseum:confirmExit(exit_cb)
    local msg = Str('지금 콜로세움에서 퇴장하면 {@RED}패배로 처리{@default}됩니다.\n퇴장하시겠습니까?')

    local function ok_cb(ret)
        g_colosseumData:request_colosseumCancel(self.m_gameKey, exit_cb)
    end

    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_cb)
end