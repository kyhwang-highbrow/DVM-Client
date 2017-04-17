local PARENT = UI

local DPS_ACTION_DURATION = 0.2

-------------------------------------
-- class UI_GameResult_StatisticsPopup
-------------------------------------
UI_GameResult_StatisticsPopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GameResult_StatisticsPopup:init(world)
	local vars = self:load('')

	-- UI 초기화
    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameResult_StatisticsPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GameResult_StatisticsPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GameResult_StatisticsPopup:refresh()

end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_GameResult_StatisticsPopup:click_exitBtn()
    self:close()
end


--@CHECK
UI:checkCompileError(UI_GameResult_StatisticsPopup)