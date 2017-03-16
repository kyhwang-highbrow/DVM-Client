-------------------------------------
-- class TimeLib
-- @brief 드래곤히어로즈의 lib/Timer와 동일한 개념
--        TimeLib클래스에서는 모든 시간은 초(sec)단위로 사용
--        서버에서 넘어오는 시간은 1/1000초로 넘어오기때문에 주의해서 사용할 것
-------------------------------------
TimeLib = class({
        m_diffServer = 'number',
        m_dayOfDayChange = ' number', -- 드빌에서 요일이 변경되는 시점
    })

-------------------------------------
-- function init
-------------------------------------
function TimeLib:init()
    self.m_diffServer = 0
end

-------------------------------------
-- function initInstance
-------------------------------------
function TimeLib:initInstance()
    if Timer then
        return
    end
    -- 인스턴스를 생성
    Timer = TimeLib()
end

-------------------------------------
-- function setServerTime
-- @breif 서버의 현재 타임스탬프를 받아와서 클라이언트와의 시간차를 저장
--        서버에서 넘어오는 시간은 1/1000초로 넘어오기때문에 주의해서 사용할 것
-------------------------------------
function TimeLib:setServerTime(server_time)
    self.m_diffServer = server_time - os.time()

    -- 다음 새벽 4시(요일 변경 기준)
    self:setTimeOfDayChange(self:getServerTime())
end

-------------------------------------
-- function getServerTime
-------------------------------------
function TimeLib:getServerTime()
    local server_time = (os.time() + self.m_diffServer)
    return server_time
end

-------------------------------------
-- function setTimeOfDayChange
-- @brief 다음 새벽 4시(요일 변경 기준)
-------------------------------------
function TimeLib:setTimeOfDayChange(server_time)
    local t_time = os.date('*t', server_time)

    -- 새벽 4시를 기준으로 한다
    if (t_time['hour'] < 4) then
        t_time['hour'] = 4
        t_time['min'] = 0
        t_time['sec'] = 0
    else
        t_time['day'] = t_time['day'] + 1
        t_time['hour'] = 4
        t_time['min'] = 0
        t_time['sec'] = 0
    end
    local time_stamp = os.time(t_time)
    self.m_dayOfDayChange = time_stamp
end

-------------------------------------
-- function getTimeOfDayChange
-- @brief 다음 새벽 4시(요일 변경 기준)
-------------------------------------
function TimeLib:getTimeOfDayChange()
    return self.m_dayOfDayChange
end

-------------------------------------
-- function getRealServerDate
-- @brief 실제 날짜 정보 리턴
-------------------------------------
function TimeLib:getRealServerDate(year, month, day)
    local server_time = self:getServerTime()
    return self:getDate(server_time, year, month, day)
end

-------------------------------------
-- function getGameServerDate
-- @brief 새벽 4시가 날짜 변경 기준으로 동작하는 날짜 정보 리턴
-------------------------------------
function TimeLib:getGameServerDate(year, month, day)
    local server_time = self:getServerTime()
    
    -- 새벽 4시 기준이므로 4시간을 빼서 처리한다
    server_time = server_time - (60 * 60 * 4)

    return self:getDate(server_time, year, month, day)
end

-------------------------------------
-- function getDate
-- @brief 오늘 날짜를 '20170308'과 같은 형태로 리턴함
-------------------------------------
function TimeLib:getDate(server_time, year, month, day)
    local t_time = os.date('*t', server_time)

    -- 기본 값들은 true
    local year = (year == nil) and true or year
    local month = (month == nil) and true or month
    local day = (day == nil) and true or day

    local ret = ''

    if year then
        ret = ret .. string.format('%.4d', t_time['year'])
    end

    if month then
        ret = ret .. string.format('%.2d', t_time['month'])
    end

    if day then
        ret = ret .. string.format('%.2d', t_time['day'])
    end

    return ret, t_time
end


-------------------------------------
-- function strToTimeStamp
-- @brief
-------------------------------------
function TimeLib:strToTimeStamp(str)
    local l_str = seperate(str, ' ')
    local date_str = l_str[1]
    local time_str = l_str[2]

    local year, month, day = self:parseDateStr(date_str)
    local hour, minute, second = self:parseTimeStr(time_str)


    local t_time = {}
    t_time['year'] = year
    t_time['month'] = month
    t_time['day'] = day
    t_time['hour'] = hour
    t_time['minute'] = minute
    t_time['second'] = second
    local time_stamp = os.time(t_time)

    return time_stamp
end

-------------------------------------
-- function parseDateStr
-- @brief
-------------------------------------
function TimeLib:parseDateStr(str)
    local l_str = seperate(str, '-')
    local year = l_str[1]
    local month = l_str[2]
    local day = l_str[3]
    return year, month, day
end

-------------------------------------
-- function parseTimeStr
-- @brief
-------------------------------------
function TimeLib:parseTimeStr(str)
    local l_str = seperate(str, ':')
    local hour = l_str[1]
    local minute = l_str[2]
    local second = l_str[3]
    return hour, minute, second
end