local PARENT = class(UI, ITableViewCell:getCloneTable())

local DPS_ACTION_DURATION = 0.2

-------------------------------------
-- class UI_GameResult_StatisticsListItem
-------------------------------------
UI_GameResult_StatisticsListItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GameResult_StatisticsListItem:init(world)
	local vars = self:load('')

	-- UI 초기화
    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameResult_StatisticsListItem:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GameResult_StatisticsListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GameResult_StatisticsListItem:refresh()

end
