local PARENT = class(UI, ITableViewCell:getCloneTable())

local COMMON_UI_ACTION_TIME = 0.3

-------------------------------------
-- class UI_OverallRankingListItem
-------------------------------------
UI_OverallRankingListItem = class(PARENT,{
		m_tRankInfo = '',
		m_isColosseum = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_OverallRankingListItem:init(t_data)
    self:load('fomation_popup_item.ui')

	self:makeDataPretty(t_data)
	self.m_isColosseum = false

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_OverallRankingListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_OverallRankingListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_OverallRankingListItem:refresh()
	local vars = self.vars
end

-------------------------------------
-- function click_detailBtn
-------------------------------------
function UI_OverallRankingListItem:makeDataPretty(t_data)
end

--@CHECK
UI:checkCompileError(UI_OverallRankingListItem)
