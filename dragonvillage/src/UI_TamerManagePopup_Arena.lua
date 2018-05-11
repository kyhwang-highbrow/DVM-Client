local PARENT = UI_TamerManagePopup

-------------------------------------
-- class UI_TamerManagePopup_Arena
-------------------------------------
UI_TamerManagePopup_Arena = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_TamerManagePopup_Arena:init(tamer_id)
end

-------------------------------------
-- function _request_setTamer
-- @brief 서버에 선택된 테이머 저장
-------------------------------------
function UI_TamerManagePopup_Arena:_request_setTamer(tamer_id, cb_func)
	-- 서버에 저장
	--g_tamerData:request_setTamer(tamer_id, cb_func)
    cb_func()
end