local PARENT = UI_TamerManagePopup

-------------------------------------
-- class UI_TamerManagePopup_Colosseum
-------------------------------------
UI_TamerManagePopup_Colosseum = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_TamerManagePopup_Colosseum:init(tamer_id)
end

-------------------------------------
-- function _request_setTamer
-- @brief 서버에 선택된 테이머 저장
-------------------------------------
function UI_TamerManagePopup_Colosseum:_request_setTamer(tamer_id, cb_func)
	-- 서버에 저장
	--g_tamerData:request_setTamer(tamer_id, cb_func)
    cb_func()
end