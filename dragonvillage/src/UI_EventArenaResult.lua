local PARENT = UI_ArenaResult

-------------------------------------
-- class UI_EventArenaResult
-------------------------------------
UI_EventArenaResult = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_EventArenaResult:init(is_win, t_data)
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_okBtn() end, 'UI_EventArenaResult')
end

-------------------------------------
-- function click_okBtn
-- @brief "확인" 버튼
-------------------------------------
function UI_EventArenaResult:click_okBtn()
	UINavigator:goTo('grand_arena')
end

-------------------------------------
-- function click_homeBtn
-------------------------------------
function UI_EventArenaResult:click_homeBtn()
	-- 씬 전환을 두번 호출 하지 않도록 하기 위함
	local block_ui = UI_BlockPopup()

	local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
end