-------------------------------------
-- class ServerTime
-- @brief 서버에 설정된 타임존으로 각종 시간을 처리하는데 도움을 주는 클래스
-------------------------------------
ServerTime = class({
    -- 서버의 타임존
    m_serverTimeZoneStr = 'string', -- 'Asia/Seoul'와 같은 타임존 문자열
    m_serverUTCOffset = 'number', -- 서버에서 사용하는 타임존의 증감값 e.g. 모든 서버가 UTC + 0 시로 사실 상 0
    m_serverUTCOffsetSec = 'number',

    -- 로컬(기기)의 타임존
    m_localUTCOffset = 'number',
    m_localUTCOffsetSec = 'number',

    -- 서버와 로컬의 시간 차이
    m_timeDiff = 'number', -- seconds
    m_timeDiffMilliseconds = 'number', -- milliseconds

    m_midnightServerTime = 'number', -- 서버 기준 오늘의 자정 milliseconds
})

-------------------------------------
-- function init
-------------------------------------
function ServerTime:init()
    self.m_timeDiff = 0
    self.m_timeDiffMilliseconds = 0

    self:setServerUTCOffset(0)

    -- 로컬(기기)의 타임존 설정
    self:setLocalUTCOffset()
end

local instance = nil

-------------------------------------
-- function getInstance
-------------------------------------
function ServerTime:getInstance()
    if (instance == nil) then
        instance = ServerTime()
    end
   
    return instance
end

-------------------------------------
-- function applyResponse
-- @brief 서버에서 받은 시간 관련 정보 받음
-------------------------------------
function ServerTime:applyResponse(ret)
    -- cclog('########### ServerTime:applyResponse(ret)')
    -- ccdump(ret)
    --error('########### ServerTime:applyResponse(ret)')
    -- cclog('########### ServerTime:applyResponse(ret)')
    local server_info = ret['server_info']
    if (server_info == nil) then
        return
    end

    --"server_info":{
    --    "midnight":1618326000000,
    --    "hour":9,
    --    "server_time":1618310263689,
    --    "timezone":"Asia/Seoul"
    --  }

    cclog('##############################')
    ccdump(server_info)

    if server_info['hour'] then
        self:setServerUTCOffset(server_info['hour'])
    end

    if server_info['timezone'] then
        self.m_serverTimeZoneStr = server_info['timezone']
    end

    if server_info['server_time'] then
        local local_timestamp_millisec = os.time() * 1000--cc.utils.getTimeInMillisecondsSinceUnixEpoch()
        self.m_timeDiffMilliseconds = (server_info['server_time'] - local_timestamp_millisec)
        self.m_timeDiff = math_floor(self.m_timeDiffMilliseconds / 1000)
    end  

    if server_info['midnight'] then
        self.m_midnightServerTime = server_info['midnight']
    end
end

-------------------------------------
-- function setServerUTCOffset
-- @brief 서버의 타임존 설정
-------------------------------------
function ServerTime:setServerUTCOffset(utc_offset)
    self.m_serverUTCOffset = utc_offset

    -- 시간단위 -> 초단위
    self.m_serverUTCOffsetSec = (utc_offset * 60 * 60)
end

-------------------------------------
-- function getServerUTCOffset
-- @brief 서버의 타임존
-------------------------------------
function ServerTime:getServerUTCOffset()
    local server_utc_offset = self.m_serverUTCOffsetSec
    return server_utc_offset
end

-------------------------------------
-- function setLocalUTCOffset
-- @brief 로컬(기기)의 타임존 설정
-------------------------------------
function ServerTime:setLocalUTCOffset()
    local now = os.time()
    local now_utc = os.time(os.date('!*t', now)) -- '!*t'로 date를 생성하면 UTC기준의 date테이블이 생성된다.
    self.m_localUTCOffsetSec = (now - now_utc) -- 로컬(기기)의 시간과 UTC시간의 차이를 저장한다.

    -- 초단위 -> 시간단위
    self.m_localUTCOffset = (self.m_localUTCOffsetSec / 60 / 60)
end

-------------------------------------
-- function getLocalUTCOffset
-- @brief 서버의 타임존
-------------------------------------
function ServerTime:getLocalUTCOffset()
    local local_utc_offset = self.m_localUTCOffsetSec
    return local_utc_offset
end

-------------------------------------
-- function timestampToDate
-- @brief 타임스템프를 date테이블로 변환
-- @param timestamp(number) 단위:초
-------------------------------------
function ServerTime:timestampToDate(timestamp)
    -- 아래의 코드에서 UIC+0기준의 date를 생성할 것이기 때문에 미리 서버의 UTC Offset을 더해준다.
    local timestamp_for_servertime = (timestamp + self.m_serverUTCOffsetSec)

    -- '!*t'로 date를 생성하면 UTC기준의 date테이블이 생성된다.
    -- 만약 '*t'로 date를 생성하면 로컬(기기)의 시간대에 테이블이 생성되므로 주의한다.
    local date = os.date('!*t', timestamp_for_servertime)

    return date
end

-------------------------------------
-- function dateToTimestamp
-- @brief 초단위의 타임스템프로 date테이블
-- @param 
-- @return timestamp(number) e.g. 1617631200
-------------------------------------
function ServerTime:dateToTimestamp(year, month, day, hour, min, sec)
    local year = tonumber(year)
    local month = tonumber(month)
    local day = tonumber(day)
    local hour = tonumber(hour)
    local min = tonumber(min)
    local sec = tonumber(sec)

    if (2037 < year) then
        cclog('#### WARNING!! #### ServerTime:dateToTimestamp year : ' .. tostring(year))
        cclog('year가 2037 이상이 되면 os.time함수에서 nil을 리턴함. 따라서 2037로 보정함.(2038년 문제)')
        year = 2037
    end
    
    local date = {}
    date['year'] = year
    date['month'] = month
    date['day'] = day
    date['hour'] = hour
    date['min'] = min
    date['sec'] = sec

    -- 로컬(기기)의 타임존을 기준으로 timestamp가 리턴됨
    local timestamp = os.time(date)
    if (timestamp == nil) then
        ccdump(date)
        local error_log = tostring(year) .. '/' .. tostring(month) .. '/' .. tostring(day) .. ' ' .. tostring(hour) .. ':' .. tostring(min) .. ' ' .. tostring(sec) 
        error('date가 유효하지 않습니다 : ' .. error_log)
    end
    
    -- UTC+0 타임존 기준으로 변경하기 위해 localUTCOffset을 더해준다.
    local timestamp_utc = (timestamp + self.m_localUTCOffsetSec)

    -- 서버 타임존 기준으로 변경하기 위해 serverUTCOffset을 빼준다.
    local timestamp_for_servertime = (timestamp_utc - self.m_serverUTCOffsetSec)
    return timestamp_for_servertime
end

-------------------------------------
-- function convertLocalTimestampMilliseconds
-- @brief 현재 시간(timestamp)을 1/1000초 단위로 가져오기
-- @return timestamp(number) 1/1000초
-------------------------------------
function ServerTime:convertLocalTimestampMilliseconds(local_timestamp)
    local timestamp = local_timestamp

    -- 서버와 시간 차이를 보정
    timestamp = (timestamp + self.m_timeDiffMilliseconds)

    return timestamp
end

-------------------------------------
-- function convertLocalTimestampSeconds
-- @brief 현재 시간(timestamp)을 1초 단위로 가져오기
-- @return timestamp(number) 단위:초
-------------------------------------
function ServerTime:convertLocalTimestampSeconds(local_timestamp)
    local timestamp = local_timestamp

    -- 서버와 시간 차이를 보정
    timestamp = (timestamp + self.m_timeDiff)

    return timestamp
end

-------------------------------------
-- function getCurrentTimestampMilliseconds
-- @brief 현재 시간(timestamp)을 1/1000초 단위로 가져오기
-- @return timestamp(number) 1/1000초
-------------------------------------
function ServerTime:getCurrentTimestampMilliseconds()
    local timestamp = nil

    -- 드빌NEW에서 사용하는 함수 (manual로 추가한 함수이기 때문에 빌드 시점에 따라 해당 함수가 없을 수 있다)
    -- if cc.utils.getTimeInMillisecondsSinceUnixEpoch then
    --     timestamp = cc.utils.getTimeInMillisecondsSinceUnixEpoch()
    -- end

    -- 적절한 milliseconds 함수가 제공되지 않을 경우 seconds단위의 timestamp를 리턴하는 os.time()에 1000을 곱해서 사용한다.
    if (timestamp == nil) then
        timestamp = os.time() * 1000
    end

    -- 서버와 시간 차이를 보정
    timestamp = (timestamp + self.m_timeDiffMilliseconds)

    return timestamp
end

-------------------------------------
-- function getCurrentTimestampSeconds
-- @brief 현재 시간(timestamp)을 1초 단위로 가져오기
-- @return timestamp(number) 단위:초
-------------------------------------
function ServerTime:getCurrentTimestampSeconds()
    local timestamp = os.time()

    -- 서버와 시간 차이를 보정
    timestamp = (timestamp + self.m_timeDiff)

    return timestamp
end

-------------------------------------
-- function getMidnightTimeStampMilliseconds
-- @brief 서버 기준 오늘의 자정 milliseconds
-- @return timestamp(number) 단위:밀리세컨드
-------------------------------------
function ServerTime:getMidnightTimeStampMilliseconds()
    return self.m_midnightServerTime or 0
end

-------------------------------------
-- function getMidnightTimeStampSeconds
-- @brief 서버 기준 오늘의 자정 seconds
-- @return timestamp(number) 단위:초
-------------------------------------
function ServerTime:getMidnightTimeStampSeconds()
    local timestamp_millisec = (self.m_midnightServerTime or 0)
    local timestamp_sec = math_floor(timestamp_millisec / 1000)
    return timestamp_sec
end

-------------------------------------
-- function getDailyInitRemainTimeStampSeconds
-- @brief 서버 일일 초기화까지 남은 시간 seconds
-- @return timestamp(number) 단위:초
-------------------------------------
function ServerTime:getDailyInitRemainTimeStampSeconds()
    -- 초기화되는 시간
    local init_time = self:getMidnightTimeStampSeconds()

    -- 현재 시간
    local curr_time = self:getCurrentTimestampSeconds()

    -- 차이만큼 반환
    local remain_time = math_max(0, init_time - curr_time)
    return remain_time
end


-------------------------------------
-- function isPastTimestampMilliseconds
-- @brief millisec timestamp 받아 해당 timestamp가 과거의 시간이면 true
-------------------------------------
function ServerTime:isPastTimestampMilliseconds(timestamp)
    -- 현재 시간
    local curr_timestamp = self:getCurrentTimestampMilliseconds()
    local is_past = (curr_timestamp > timestamp)
    return is_past
end

-------------------------------------
-- function datestrToTimestampSec
-- @brief
-- @param date_str(string) e.g. '2020-05-06 00:00:00'
-- @return timestamp(number) nil리턴 가능, 단위:초
-------------------------------------
function ServerTime:datestrToTimestampSec(date_str)
    if (type(date_str) ~= 'string') then
        return nil
    end

    if (date_str == '') then
        return nil
    end

    local year, month, day, hour, min, sec = string.match(date_str, '(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)')
    local timestamp = self:dateToTimestamp(year, month, day, hour, min, sec)
    return timestamp
end

-------------------------------------
-- function checkTimeRangeWithDatestr
-- @brief 
-- @param start_date_str(string) e.g. '2020-05-06 00:00:00'
--        start_date_str값이 유효하지 않을 경우 기간에 포함된다고 간주 (nil or 0보다 작은 값)
-- @param end_date_str(string) e.g. '2020-05-06 00:00:00'
--        end_date_str 유효하지 않을 경우 기간에 포함된다고 간주 (nil or 0보다 작은 값)
-- @return boolean true를 리턴하면 유효한 기간, false를 리턴하면 유효하지 않은 기간
-------------------------------------
function ServerTime:checkTimeRangeWithDatestr(start_date_str, end_date_str)
    local curr_timestamp_sec = self:getCurrentTimestampSeconds()

    local start_timestamp_sec = self:datestrToTimestampSec(start_date_str)
    if (start_timestamp_sec ~= nil) and (0 < start_timestamp_sec) then

        -- 시작 시간 전인 경우
        if (curr_timestamp_sec < start_timestamp_sec) then
            return false
        end

    end

    local end_timestamp_sec = self:datestrToTimestampSec(end_date_str)
    if (end_timestamp_sec ~= nil) and (0 < end_timestamp_sec) then

        -- 종료 시간이 넘어간 경우
        if (end_timestamp_sec < curr_timestamp_sec) then
            return false
        end

    end

    return true
end

-------------------------------------
-- function datestrToTimestampSec_YYYYMMDD
-- @brief
-- @param date_str(string) e.g. '20220111'
-- @param end_of_day(boolean) d
-- @return timestamp(number) nil리턴 가능, 단위:초
-------------------------------------
function ServerTime:datestrToTimestampSec_YYYYMMDD(date_str, end_of_day)
    -- 문자열 타입 체크
    if (type(date_str) ~= 'string') then
        return nil
    end

    -- 빈 문자열
    if (date_str == '') then
        return nil
    end

    -- YYYYMMDD 형식의 문자열은 8자여야 한다. e.g. 20220111
    if (string.len(date_str) ~= 8) then
        return nil
    end

    -- 년
    local year_str = string.sub(date_str, 1, 4)
    local year = tonumber(year_str)
    if (year == nil) then
        return nil
    end

    -- 월
    local month_str = string.sub(date_str, 5, 6)
    local month = tonumber(month_str)
    if (month == nil) then
        return nil
    end

    -- 일
    local day_str = string.sub(date_str, 7, 8)
    local day = tonumber(day_str)
    if (day == nil) then
        return nil
    end

    local hour = 0
    local min = 0
    local sec = 0

    if (end_of_day == true) then
        hour = 23
        min = 59
        sec = 59
    end

    local timestamp = self:dateToTimestamp(year, month, day, hour, min, sec)
    return timestamp
end

-------------------------------------
-- function datestrToTimestampMillisec
-- @brief
-- @param date_str(string) e.g. '2020-05-06 00:00:00'
-- @return timestamp(number) nil리턴 가능, 단위:밀리세컨드
-------------------------------------
function ServerTime:datestrToTimestampMillisec(date_str)
    if (type(date_str) ~= 'string') then
        return nil
    end

    if (date_str == '') then
        return nil
    end

    local year, month, day, hour, min, sec = string.match(date_str, '(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)')
    local timestamp = (self:dateToTimestamp(year, month, day, hour, min, sec) * 1000) -- sec -> millisec
    return timestamp
end

-------------------------------------
-- function timestampSecToDatestr
-- @brief
-- @param timestamp_sec(number) nil리턴 가능, 단위:초
-- @return date_str(string) e.g. '2020-05-06 00:00:00'
-------------------------------------
function ServerTime:timestampSecToDatestr(timestamp_sec)
    local date = self:timestampToDate(timestamp_sec)
    
    if (date == nil) then
        return ''
    end

    local date_str = string.format('%.4d-%.2d-%.2d %.2d:%.2d:%.2d', date['year'], date['month'], date['day'], date['hour'], date['min'], date['sec'])
    return date_str
end

-------------------------------------
-- function timestampMillisecToTimeDesc
-- @brief
-- @param timestamp_millisec(number) nil리턴 가능, 단위:밀리세컨드
-- @return time_desc_str(string) e.g. {1}일, {1}일 {2}시간, '%.2d:%.2d:%.2d'
-------------------------------------
function ServerTime:timestampMillisecToTimeDesc(timestamp_millisec, day_special)

    local day = math.floor(timestamp_millisec / 86400000)
    timestamp_millisec = timestamp_millisec - (day * 86400000)

    local hour = math.floor(timestamp_millisec / 3600000)
    timestamp_millisec = timestamp_millisec - (hour * 3600000)

    local min = math.floor(timestamp_millisec / 60000)
    timestamp_millisec = timestamp_millisec - (min * 60000)

    local sec = math.floor(timestamp_millisec / 1000)
    timestamp_millisec = timestamp_millisec - (sec * 1000)

    local millisec = timestamp_millisec

    local str = ''
    if (0 < day) then
        --str = string.format('%.2d:%.2d:%.2d:%.2d:%.3d', day, hour, min, sec, millisec)
        str = string.format('%.2d:%.2d:%.2d:%.2d', day, hour, min, sec)
        if day_special then
            --local day_str = Str('{1}일', day)
            --local hour_min_sec_str = string.format('%.2d:%.2d:%.2d',  hour, min, sec)
            --str = Str('{1} {2}', day_str, hour_min_sec_str)

            str = Str('{1}일 {2}:{3}:{4}', day, string.format('%.2d',  hour), string.format('%.2d',  min), string.format('%.2d',  sec))
        end

    elseif (0 < hour) then
        --str = string.format('%.2d:%.2d:%.2d:%.3d',  hour, min, sec, millisec)
        str = string.format('%.2d:%.2d:%.2d',  hour, min, sec)

    elseif (0 < min) then
        --str = string.format('%.2d:%.2d:%.3d',  min, sec, millisec)
        str = string.format('%.2d:%.2d',  min, sec)

    --elseif (0 < sec) then
    else
        --str = string.format('%.2d:%.3d', sec, millisec)
        str = string.format('%d', sec)

    end

    return str
end

-------------------------------------
-- function timestampSecToTimeDesc
-- @brief
-- @param  timestamp_sec(number) nil리턴 가능, 단위:초
-- @return time_desc_str(string) e.g. {1}일, {1}일 {2}시간, '%.2d:%.2d:%.2d'
-------------------------------------
function ServerTime:timestampSecToTimeDesc(timestamp_sec, day_special)

    local timestamp_millisec = timestamp_sec * 1000

    return self:timestampMillisecToTimeDesc(timestamp_millisec, day_special)
end

-------------------------------------
-- function timestampSecToTimeDesc
-- @brief
-- @param  timestamp_sec(number) nil리턴 가능, 단위:초
-- @return time_desc_str(string) e.g. {1}일, {1}일 {2}시간, '%.2d:%.2d:%.2d'
-------------------------------------
function ServerTime:makeTimeDescToSec(sec, showSeconds, firstOnly, timeOnly)
    local showSeconds = showSeconds and true or false
    local sec = math.floor(sec)
    if sec < 60 then
        if showSeconds then
            --return string.format('%d초', sec)
            return Str('{1}초', sec)
        else
            --return string.format('1분 미만')
            return Str('1분 미만')
        end

    elseif sec < 3600 then
        local min = math.floor(sec / 60)
        sec = sec % 60
        if sec == 0 or firstOnly then
            return Str('{1}분', min)
        else
            return Str('{1}분 {2}초', min, sec)
        end

    elseif sec < 86400 or timeOnly then
        local hour = math.floor(sec / 3600)
        local min = math.floor(sec / 60) % 60
        if min == 0 or firstOnly then
            return Str('{1}시간', hour)
        else
            return Str('{1}시간 {2}분', hour, min)
        end

    else
        local day = math.floor(sec / 86400)
        local hour = math.floor(sec / 3600) % 24
        if hour == 0 or firstOnly then
            return Str('{1}일', day)
        else
            return Str('{1}일 {2}시간', day, hour)
        end
    end
end

-------------------------------------
-- function timestampSecToDatestrExceptTime
-- @brief
-- @param timestamp(number) nil리턴 가능, 단위:초
-- @param specific_format(string) 특정 문자열 커스텀 형식 e.g. '%4d.%2d.%2d'
-- @return date_str(string) e.g. '2020-05-06
-------------------------------------
function ServerTime:timestampSecToDatestrExceptTime(timestamp_sec, specific_format)
    local date = self:timestampToDate(timestamp_sec)
    
    if (date == nil) then
        return ''
    end

    local specific_format = specific_format or '%.4d-%.2d-%.2d'
    local date_str = string.format(specific_format, date['year'], date['month'], date['day'])
    return date_str
end

-------------------------------------
-- function timestampSecToDatestrExceptDate
-- @brief
-- @param timestamp(number) nil리턴 가능, 단위:초
-- @param specific_format(string) 특정 문자열 커스텀 형식 e.g. '%4d.%2d.%2d'
-- @return date_str(string) e.g. '08:00:13'
-------------------------------------
function ServerTime:timestampSecToDatestrExceptDate(timestamp_sec, specific_format)
    local date = self:timestampToDate(timestamp_sec)
    
    if (date == nil) then
        return ''
    end

    local specific_format = specific_format or '%02d:%02d:%02d'
    local date_str = string.format(specific_format, date['hour'], date['min'], date['sec'])
    return date_str
end

-------------------------------------
-- function timestampMillisecToDatestr
-- @brief
-- @param timestamp_millisec(number) nil리턴 가능, 단위:밀리세컨드
-- @return date_str(string) e.g. '2020-05-06 00:00:00'
-------------------------------------
function ServerTime:timestampMillisecToDatestr(timestamp_millisec)
    -- Millisecond to second.
    local timestamp_sec = timestamp_millisec / 1000

    return self:timestampSecToDatestr(timestamp_sec)
end

-------------------------------------
-- function timestampMillisecToDatestrExceptTime
-- @brief
-- @param timestamp_sec(number) nil리턴 가능, 단위:밀리세컨드
-- @param specific_format(string) 특정 문자열 커스텀 형식 e.g. '%4d.%2d.%2d'
-- @return date_str(string) e.g. '2020-05-06
-------------------------------------
function ServerTime:timestampMillisecToDatestrExceptTime(timestamp_millisec, specific_format)
    -- Millisecond to second.
    local timestamp_sec = timestamp_millisec / 1000

    return self:timestampSecToDatestrExceptTime(timestamp_sec, specific_format)
end

-------------------------------------
-- function timestampMillisecToDatestrExceptDate
-- @brief
-- @param timestamp_sec(number) nil리턴 가능, 단위:밀리세컨드
-- @param specific_format(string) 특정 문자열 커스텀 형식 e.g. '%4d.%2d.%2d'
-- @return time_str(string) e.g. '08:00:13'
-------------------------------------
function ServerTime:timestampMillisecToDatestrExceptDate(timestamp_millisec, specific_format)
    -- Millisecond to second.
    local timestamp_sec = timestamp_millisec / 1000

    return self:timestampSecToDatestrExceptDate(timestamp_sec, specific_format)
end



-------------------------------------
-- function getServerTimeText
-- @brief 서버의 현재 시간 문자열
-- @return date_str(string) e.g. '2020-05-06 00:00:00'
-------------------------------------
function ServerTime:getServerTimeText()
    local curr_timestamp_sec = self:getCurrentTimestampSeconds()
    local str = self:timestampSecToDatestr(curr_timestamp_sec)
    return str
end

-------------------------------------
-- function getServerTimeTextForUI
-- @brief 서버의 현재 시간 문자열
-- @return date_str(string) e.g. '서버 시간 : 2020-05-06 00:00:00 (UTC +9)'
-------------------------------------
function ServerTime:getServerTimeTextForUI()
    local date_str = self:getServerTimeText()

    if (0 <= self.m_serverUTCOffset) then
        date_str = date_str .. ' (UTC +' .. self.m_serverUTCOffset .. ')'
    else
        date_str = date_str .. ' (UTC ' .. self.m_serverUTCOffset .. ')'
    end
    
    local str = Str('서버 시간 : {1}', date_str)
    return str
end

-------------------------------------
-- function dateSample
-- @brief
-------------------------------------
function ServerTime:dateSample()
    
    local date = os.date()
    cclog("os.date()")
    ccdump(date)
    -- '04/05/21 13:03:27'

    local date = os.date('*t')
    cclog("os.date('*t')")
    ccdump(date)
    --{
    --    ['sec']=27;
    --    ['min']=3;
    --    ['day']=5;
    --    ['isdst']=false;
    --    ['wday']=2;
    --    ['yday']=95;
    --    ['year']=2021;
    --    ['month']=4;
    --    ['hour']=13;
    --}

    local date_utc = os.date('!*t')
    cclog("os.date('!*t')")
    ccdump(date)
    --{
    --    ['sec']=27;
    --    ['min']=3;
    --    ['day']=5;
    --    ['isdst']=false;
    --    ['wday']=2;
    --    ['yday']=95;
    --    ['year']=2021;
    --    ['month']=4;
    --    ['hour']=4;
    --}

    
    local hour_local = date['hour'] -- 로컬(기기)의 시간
    local hour_utc = date_utc['hour'] -- UTC의 시간
    local utc_offset_hour = hour_local  - hour_utc -- 로컬(기기)의 시간과 UTC시간의 차이
    ccdump(utc_offset_hour) -- 9

    local date = os.date('%c')
    cclog("os.date('%c')")
    ccdump(date)
    -- '04/05/21 13:03:27'
end