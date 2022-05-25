local PARENT = Structure

-------------------------------------
-- class StructFevertime
-------------------------------------
StructFevertime = class(PARENT, {
        id = 'string', -- 고유값
        key = 'string', --
        type = 'string', -- 핫타임의 타입
        value = 'number', -- 핫타임의 적용 수치
        date = 'number', -- 일일 핫타임의 날짜 20200603
        hour = 'number',
        start_date = 'number', -- timestamp
        end_date = 'number', -- timestamp
        badge = 'string',
        title = 'string', -- title

        --------------------------------------------------
        start_date_for_sort = 'number',
        end_date_for_sort = 'number',
    })

StructFevertime.KEY = {}
StructFevertime.KEY.GLOBAL_HOTTIME = 'global_hottime'
StructFevertime.KEY.DAILY_HOTTIME_SCHEDULE = 'daily_hottime_schedule'
StructFevertime.KEY.DAILY_HOTTIME = 'daily_hottime'

StructFevertime.KEY_IDX = {}
StructFevertime.KEY_IDX[StructFevertime.KEY.GLOBAL_HOTTIME] = 1000
StructFevertime.KEY_IDX[StructFevertime.KEY.DAILY_HOTTIME_SCHEDULE] = 900
StructFevertime.KEY_IDX[StructFevertime.KEY.DAILY_HOTTIME] = 800

local THIS = StructFevertime

-------------------------------------
-- function init
-------------------------------------
function StructFevertime:init(data)
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructFevertime:getClassName()
    return 'StructFevertime'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructFevertime:getThis()
    return THIS
end

-------------------------------------
-- function isActiveFevertime
-------------------------------------
function StructFevertime:isActiveFevertime()
    if (self['start_date'] == nil) then
        return false
    end

    if (self['end_date'] == nil) then
        return false
    end
    
    local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    if (cur_time < self['start_date']) then
        return false
    end

    if (self['end_date'] < cur_time) then
        return false
    end

    return true
end

-------------------------------------
-- function isTodayDailyHottime
-------------------------------------
function StructFevertime:isTodayDailyHottime()
    if (self['date'] == nil) then
        return false
    end

    local server_timestamp = ServerTime:getInstance():getCurrentTimestampSeconds()
    local date = TimeLib:convertToServerDate(server_timestamp)
    local server_date = (date:year() * 10000) + (date:month() * 100) + (date:day())
   

    -- number타입, YYYYMMDD형태의 값. ex) 20200605
    local is_today = (self['date'] == server_date)
    return is_today
end

-------------------------------------
-- function isFevertimeExpired
-------------------------------------
function StructFevertime:isFevertimeExpired()
    local end_date = self:getEndDateForSort()

    local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    if (end_date < cur_time) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function isAfterStartDate
-------------------------------------
function StructFevertime:isAfterStartDate()
    local start_date = self:getStartDateForSort()

    local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    if (start_date < cur_time) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function isBeforeStartDate
-------------------------------------
function StructFevertime:isBeforeStartDate()
    local start_date = self:getStartDateForSort()

    local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    if (cur_time < start_date) then
        return true
    else
        return false
    end
end


-------------------------------------
-- function getStartDateForSort
-------------------------------------
function StructFevertime:getStartDateForSort()
    if (self['start_date_for_sort'] == nil) then

        if self['start_date'] then
            self['start_date_for_sort'] = self['start_date']

        elseif self['date'] then
            local date_format = 'yyyymmddHHMMSS'
            local parser = pl.Date.Format(date_format)
            local date_str = tostring(self['date']) .. '000000' -- 시, 분, 초를 넣지 않았을 때 0시 0분 0초로 설정되지 않는 이슈가 있었다.
            local date = parser:parse(date_str)
            local local_timestamp = date['time']
            local server_timestamp = TimeLib:convertToServerTimestamp(local_timestamp)
            self['start_date_for_sort'] = (server_timestamp * 1000)

        else
            self['start_date_for_sort'] = 0
        end

    end

    return self['start_date_for_sort']
end

-------------------------------------
-- function getEndDateForSort
-------------------------------------
function StructFevertime:getEndDateForSort()
    if (self['end_date_for_sort'] == nil) then

        if self['end_date'] then
            self['end_date_for_sort'] = self['end_date']

        elseif self['date'] then
            local date_format = 'yyyymmddHHMMSS'
            local parser = pl.Date.Format(date_format)
            local date_str = tostring(self['date']) .. '000000' -- 시, 분, 초를 넣지 않았을 때 0시 0분 0초로 설정되지 않는 이슈가 있었다.
            local date = parser:parse(date_str)
            local local_timestamp = date['time'] + (24 * 60 * 60) -- 1일을 더해준다.
            local server_timestamp = TimeLib:convertToServerTimestamp(local_timestamp)
            self['end_date_for_sort'] = (server_timestamp * 1000)

        else
            self['end_date_for_sort'] = 0
        end

    end

    return self['end_date_for_sort']
end

-------------------------------------
-- function getKeyIdxForSort
-------------------------------------
function StructFevertime:getKeyIdxForSort()
    local key = self['key']
    local idx = StructFevertime.KEY_IDX[key] or 0
    return idx
end

-------------------------------------
-- function getFtoid
-------------------------------------
function StructFevertime:getFtoid()
    if (self['id'] == nil) then
        self['id'] = math_random(1, 9999999)
    end
    return self['id']
end

-------------------------------------
-- function getFevertimeName
-------------------------------------
function StructFevertime:getFevertimeName()
    local name = TableFevertime:getFevertimeName(self['type'])
    return Str(name)
end

-------------------------------------
-- function getFevertimeDesc
-------------------------------------
function StructFevertime:getFevertimeDesc()
    local desc = TableFevertime:getFevertimeDesc(self['type'])
    local value = self['value'] * 100
    local ret_desc = Str(desc, value)
    return ret_desc
end

-------------------------------------
-- function getFevertimeLinkType
-------------------------------------
function StructFevertime:getFevertimeLinkType()
    local link_type = TableFevertime:getLinkType(self['type'])
    return link_type
end

-------------------------------------
-- function getFevertimeIcon
-- @brief 아이콘의 경로를 가져온다.
-------------------------------------
function StructFevertime:getFevertimeIcon()
    local icon = TableFevertime:getIcon(self['type'])
    return icon
end

-------------------------------------
-- function getFevertimeEnddate
-- @return number timestapm(1000분의 1초)
-------------------------------------
function StructFevertime:getFevertimeEnddate()
    return self['end_date']
end


-------------------------------------
-- function getPeriodStr
-- @breif 기간 문자열
-- @return string
-------------------------------------
function StructFevertime:getPeriodStr()
    if (self:isDailyHottimeSchedule() == true) then
        return ''
    end

    local start_str = ''
    do
        local server_timestamp = self['start_date'] / 1000
        local date = TimeLib:convertToServerDate(server_timestamp)
        local wday_str = getWeekdayName(date:weekday_name())
        start_str = string.format('%d.%d %s %.2d:%.2d', date:month(), date:day(), wday_str, date:hour(), date:min())
    end

    local end_str = ''
    do
        local server_timestamp = self['end_date'] / 1000
        local date = TimeLib:convertToServerDate(server_timestamp)
        local wday_str = getWeekdayName(date:weekday_name())
        end_str = string.format('%d.%d %s %.2d:%.2d', date:month(), date:day(), wday_str, date:hour(), date:min())
    end

    local str = start_str .. ' ~ ' .. end_str
    return str
end

-------------------------------------
-- function getTimeLabelStr
-------------------------------------
function StructFevertime:getTimeLabelStr()
    if (self:isDailyHottimeSchedule() == true) then
        local seconds = self['hour'] * 60 * 60
        local time_str = datetime.makeTimeDesc(seconds, false) -- param : milliseconds, day_special
        local str = Str('{1}', time_str)
        return str
    else
        local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
        -- 시작 전
        if (cur_time < self['start_date']) then
            local milliseconds = self['end_date'] - self['start_date']
            local time_str = datetime.makeTimeDesc_timer(milliseconds, false) -- param : milliseconds, day_special
            local str = Str('남은 시간 : {1}', time_str)
            return str
        -- 시작 후
        else
            local milliseconds = math_max(self['end_date'] - cur_time, 0)
            local time_str = datetime.makeTimeDesc_timer(milliseconds, false) -- param : milliseconds, day_special
            local str = Str('남은 시간 : {1}', time_str)
            return str
        end
    end
end

-------------------------------------
-- function isDailyHottime
-------------------------------------
function StructFevertime:isDailyHottime()
    return self['key'] == StructFevertime.KEY.DAILY_HOTTIME
end

-------------------------------------
-- function isDailyHottimeSchedule
-------------------------------------
function StructFevertime:isDailyHottimeSchedule()
    return self['key'] == StructFevertime.KEY.DAILY_HOTTIME_SCHEDULE
end


-------------------------------------
-- function isGlobalHottime
-------------------------------------
function StructFevertime:isGlobalHottime()
    return self['key'] == StructFevertime.KEY.GLOBAL_HOTTIME
end

-------------------------------------
-- function getFevertimeType
-------------------------------------
function StructFevertime:getFevertimeType()
    return self['type']
end

-------------------------------------
-- function getFevertimeValue
-------------------------------------
function StructFevertime:getFevertimeValue()
    return self['value']
end

-------------------------------------
-- function getFevertimeID
-------------------------------------
function StructFevertime:getFevertimeID()
    return self['id']
end

-------------------------------------
-- function getBadgeStr
-------------------------------------
function StructFevertime:getBadgeStr()
    return self['badge']
end

-------------------------------------
-- function getTitleStr
-------------------------------------
function StructFevertime:getTitleStr()
    return self['title']
end

-------------------------------------
-- function sortFunc
-------------------------------------
function StructFevertime.sortFunc(struct_a, struct_b)

    -- 0. 만료된 것이 우선
    if (struct_a:isFevertimeExpired() ~= struct_b:isFevertimeExpired()) then
        return struct_a:isFevertimeExpired()
    end

    -- 1. 활성화 중인게 우선
    if (struct_a:isActiveFevertime() ~= struct_b:isActiveFevertime()) then
        return struct_a:isActiveFevertime()
    end

    -- 2. 시작 시간이 빠른 것이 우선
    if (struct_a:getStartDateForSort() ~= struct_b:getStartDateForSort()) then
        return struct_a:getStartDateForSort() < struct_b:getStartDateForSort()
    end

    -- 3. 종료 시간이 빠른 것이 우선
    if (struct_a:getEndDateForSort() ~= struct_b:getEndDateForSort()) then
        return struct_a:getEndDateForSort() < struct_b:getEndDateForSort()
    end

    -- 4. 키 별 정렬
    if (struct_a:getKeyIdxForSort() ~= struct_b:getKeyIdxForSort()) then
        return struct_a:getKeyIdxForSort() > struct_b:getKeyIdxForSort()
    end
    
   -- 5. oid별 정렬
   return struct_a:getFtoid() < struct_b:getFtoid()
end







-------------------------------------
-- function create_forFevertime
-------------------------------------
function StructFevertime:create_forFevertime(t_data)
    local struct_fevertime = StructFevertime()
    struct_fevertime['id'] = t_data['id']
    struct_fevertime['key'] = StructFevertime.KEY.DAILY_HOTTIME
    struct_fevertime['type'] = t_data['type']
    struct_fevertime['value'] = t_data['value']
    struct_fevertime['date'] = nil
    struct_fevertime['hour'] = nil
    struct_fevertime['start_date'] = t_data['start']
    struct_fevertime['end_date'] = t_data['end']
    struct_fevertime['badge'] = t_data['badge']
    struct_fevertime['title'] = t_data['desc'] or '일일 핫타임'
    return struct_fevertime
end

-------------------------------------
-- function create_forFevertimeSchedule
-------------------------------------
function StructFevertime:create_forFevertimeSchedule(t_data)
    local struct_fevertime = StructFevertime()
    struct_fevertime['id'] = t_data['id']
    struct_fevertime['key'] = StructFevertime.KEY.DAILY_HOTTIME_SCHEDULE
    struct_fevertime['type'] = t_data['type']
    struct_fevertime['value'] = t_data['value']
    struct_fevertime['date'] = t_data['date']
    struct_fevertime['hour'] = t_data['hour']
    struct_fevertime['start_date'] = nil
    struct_fevertime['end_date'] = nil
    struct_fevertime['badge'] = t_data['badge']
    struct_fevertime['title'] = t_data['desc'] or '일일 핫타임'
    
    return struct_fevertime
end

-------------------------------------
-- function create_forFevertimeGlobal
-------------------------------------
function StructFevertime:create_forFevertimeGlobal(t_data)
    local struct_fevertime = StructFevertime()
    struct_fevertime['id'] = t_data['id']
    struct_fevertime['key'] = StructFevertime.KEY.GLOBAL_HOTTIME
    struct_fevertime['type'] = t_data['type']
    struct_fevertime['value'] = t_data['value']
    struct_fevertime['date'] = nil
    struct_fevertime['hour'] = nil
    struct_fevertime['start_date'] = t_data['start']
    struct_fevertime['end_date'] = t_data['end']
    struct_fevertime['badge'] = t_data['badge']
    struct_fevertime['title'] = t_data['desc'] or '스페셜 핫타임'

    return struct_fevertime
end