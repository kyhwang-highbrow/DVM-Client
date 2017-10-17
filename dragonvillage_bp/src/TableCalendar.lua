local PARENT = TableClass



-------------------------------------
-- class TableCalendar
-------------------------------------
TableCalendar = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableCalendar:init()
    self.m_tableName = 'calendar'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getCalendarRowCnt
-------------------------------------
function TableCalendar:getCalendarRowCnt(month)
    local month = tonumber(month)
    
    local t_table = self:get(month)

    -- 이달의 마지막 날짜
    local last_day = t_table['last_day']

    -- 이달 1일의 요일
    local first_day = t_table['first_day']


    local calendar_slot_idx = last_day + (day_of_week_num[first_day] - 1)

    local row_cnt = math_ceil(calendar_slot_idx / 7)

    cclog(month, row_cnt)

end


-------------------------------------
-- function getCalendarDayList
-------------------------------------
function TableCalendar:getCalendarDayList(year, month)
    local year_month = string.format('%.4d%.2d', year, month)
    local year_month = tonumber(year_month)

    local t_table = self:get(year_month)

    -- 이달의 마지막 날짜
    local last_day = t_table['last_day']

    local dey_of_week_list = {}
    dey_of_week_list[1] = 'sun'
    dey_of_week_list[2] = 'mon'
    dey_of_week_list[3] = 'tue'
    dey_of_week_list[4] = 'wed'
    dey_of_week_list[5] = 'thu'
    dey_of_week_list[6] = 'fri'
    dey_of_week_list[7] = 'sat'

    -- 이달 1일의 요일
    local day_of_week_map = {}
    for i,v in ipairs(dey_of_week_list) do
        day_of_week_map[v] = i
    end

    local first_day = t_table['first_day']
    local offset_idx = (day_of_week_map[first_day] - 1)

    local t_ret = {}

    for i=1, last_day do
        local struct_calendar_day = StructCalendarDay()
        local day = i

        struct_calendar_day.m_year = year
        struct_calendar_day.m_month = month
        struct_calendar_day.m_day = day
        --struct_calendar_day.m_dayOfWeek = day
        struct_calendar_day.m_idxOnCalendar = (day + offset_idx)

        local day_of_week_num = struct_calendar_day.m_idxOnCalendar % 7
        struct_calendar_day.m_dayOfWeek = dey_of_week_list[day_of_week_num]

        t_ret[i] = struct_calendar_day
    end

    return t_ret
end