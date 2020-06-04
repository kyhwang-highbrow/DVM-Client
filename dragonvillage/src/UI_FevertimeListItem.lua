local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_FevertimeListItem
-------------------------------------
UI_FevertimeListItem = class(PARENT, {
        m_structFevertime = 'StructFevertime',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FevertimeListItem:init(struct_fevertime)
    self.m_structFevertime = struct_fevertime

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

    local struct_fevertime = self.m_structFevertime
    local server_timestamp = struct_fevertime:getStartDateForSort() / 1000
    
    local date = TimeLib:convertToServerDate(server_timestamp)
    local wday_str = getWeekdayName(date:weekday_name())
    local str = Str('{1}.{2}\n{3}', date:month(), date:day(), wday_str)

    if (date:is_weekend() == true) then
        str = '{@light_red}' .. str
    end
    vars['dayLabel']:setString(str)
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