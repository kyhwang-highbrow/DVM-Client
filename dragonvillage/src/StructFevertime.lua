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
        start_date = 'number', -- timestamp
        end_date = 'number', -- timestamp

        --------------------------------------------------
        start_date_for_sort = 'number',
        end_date_for_sort = 'number',
    })

StructFevertime.KEY = {}
StructFevertime.KEY.DAILY_HOTTIME = 'daily_hottime'
StructFevertime.KEY.GLOBAL_HOTTIME = 'global_hottime'

StructFevertime.KEY_IDX = {}
StructFevertime.KEY_IDX[StructFevertime.KEY.DAILY_HOTTIME] = 1000
StructFevertime.KEY_IDX[StructFevertime.KEY.GLOBAL_HOTTIME] = 900

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
    
    local cur_time = Timer:getServerTime_Milliseconds()
    if (cur_time < self['start_date']) then
        return false
    end

    if (self['end_date'] < cur_time) then
        return false
    end

    return true
end


-------------------------------------
-- function getStartDateForSort
-------------------------------------
function StructFevertime:getStartDateForSort()
    if (self['start_date_for_sort'] == nil) then

        if self['start_date'] then
            self['start_date_for_sort'] = self['start_date']

        elseif self['date'] then
            local date_format = 'yyyymmdd'
            local parser = pl.Date.Format(date_format)
            local date_str = tostring(self['date'])
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
            local date_format = 'yyyymmdd'
            local parser = pl.Date.Format(date_format)
            local date = parser:parse(self['date'])
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
    return self['id']
end

-------------------------------------
-- function sortFunc
-------------------------------------
function StructFevertime.sortFunc(struct_a, struct_b)

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
    struct_fevertime['start_date'] = t_data['start']
    struct_fevertime['end_date'] = t_data['end']
    return struct_fevertime
end

-------------------------------------
-- function create_forFevertimeSchedule
-------------------------------------
function StructFevertime:create_forFevertimeSchedule(t_data)
    local struct_fevertime = StructFevertime()
    struct_fevertime['id'] = t_data['id']
    struct_fevertime['key'] = StructFevertime.KEY.DAILY_HOTTIME
    struct_fevertime['type'] = t_data['type']
    struct_fevertime['value'] = t_data['value']
    struct_fevertime['date'] = t_data['date']
    struct_fevertime['start_date'] = nil
    struct_fevertime['end_date'] = nil
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
    struct_fevertime['start_date'] = t_data['start']
    struct_fevertime['end_date'] = t_data['end']
    return struct_fevertime
end