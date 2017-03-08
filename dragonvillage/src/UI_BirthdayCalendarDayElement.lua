local PARENT = UI

-------------------------------------
-- class UI_BirthdayCalendarDayElement
-------------------------------------
UI_BirthdayCalendarDayElement = class(PARENT, {
        m_structCalendarDay = 'StructCalendarDay',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_BirthdayCalendarDayElement:init(struct_calendar_day)
    self.m_structCalendarDay = struct_calendar_day

    local vars = self:load('event_birthday_list.ui')

    self:refresh()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BirthdayCalendarDayElement:refresh()
    local vars = self.vars

    local struct_calendar_day = self.m_structCalendarDay

    local day = struct_calendar_day.m_day

    vars['dayLabel']:setString(tostring(day))
end