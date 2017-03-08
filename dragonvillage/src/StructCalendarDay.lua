-------------------------------------
-- class StructCalendarDay
-------------------------------------
StructCalendarDay = class({
        m_year = 'number',
        m_month = 'number',
        m_day = 'number',
        m_dayOfWeek = 'number',
        m_idxOnCalendar = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function StructCalendarDay:init()
end

-------------------------------------
-- function isToday
-------------------------------------
function StructCalendarDay:isToday()
    local year_month, t_time = Timer:getGameServerDate()

    if (self.m_year ~= t_time['year']) then
        return false

    elseif (self.m_month ~= t_time['month']) then
        return false

    elseif (self.m_day ~= t_time['day']) then
        return false
    end

    return true
end