local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_FevertimeListItem
-------------------------------------
UI_FevertimeListItem = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FevertimeListItem:init(t_data, isHighlight)
	-- UI load
	local ui_name = 'event_fevertime_list_item.ui' 
	self:load(ui_name)

	-- initialize
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FevertimeListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FevertimeListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FevertimeListItem:refresh()
end