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
    if (struct_fevertime:isGlobalHottime() == true) then
        ui_name = 'event_fevertime_list_item_special.ui' 
    end
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

    do -- 이름
        local str = struct_fevertime:getFevertimeName()
        vars['titleLabel']:setString(str)
    end

    do -- 설명
        local str = struct_fevertime:getFevertimeDesc()
        vars['infoLabel']:setString(str)
    end

    do -- 만료되었는가 (핫타임 시간이 지났건, 일일 핫타임 날짜가 넘어간 경우)
        --local expired = struct_fevertime:isFevertimeExpired()
        --vars['CompletMenu']:setVisible(expired)

        vars['CompletMenu']:setVisible(false)
        vars['nextdayMenu']:setVisible(false)

        if struct_fevertime:isFevertimeExpired() then
            vars['CompletMenu']:setVisible(true)
        elseif struct_fevertime:isBeforeStartDate() then
            vars['nextdayMenu']:setVisible(true)
        end
    end

    do -- 시간
        local str = struct_fevertime:getTimeLabelStr()
        vars['timeLabel']:setString(str)
    end
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FevertimeListItem:initButton()
    local vars = self.vars
    vars['startBtn']:setVisible(false)
    vars['nextdayBtn']:setVisible(false)
    vars['CompletBtn']:setVisible(false)
    vars['questLinkBtn']:setVisible(false)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FevertimeListItem:refresh()
end