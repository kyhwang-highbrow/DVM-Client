local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_StatisticsListItem
-------------------------------------
UI_StatisticsListItem = class(PARENT, {
		m_dragonInfo = 'data',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_StatisticsListItem:init(dragon)
	local vars = self:load('ingame_result_stats_popup_item_01.ui')

	self.m_dragonInfo = dragon

	-- UI 초기화
    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_StatisticsListItem:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_StatisticsListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_StatisticsListItem:refresh()

end
