-------------------------------------
-- Class ExperationTime
-- @brief 만료 시간 체크용 클래스
--        이 클래스의 timestamp의 단위는 milliseconds로 사용한다.
-- @kwkang 기존에 seconds로 사용하니 1초 내에 여러번 갱신이 되는 경우에 대한 처리가 제대로 되지 않았음!
-------------------------------------
ExperationTime = class({
    m_updatedAt = 'timestamp', --timestamp 단위: milliseconds
    m_experationTime = 'timestamp', -- timestamp 단위: milliseconds
    m_experationMsg = 'string', -- 만료 시간에 대한 설명 (nil일 수 있다)
})

-------------------------------------
-- function init
-------------------------------------
function ExperationTime:init()
    self:clear()
end

-------------------------------------
-- function clear
-------------------------------------
function ExperationTime:clear()
    self.m_updatedAt = nil
    self.m_experationTime = nil
    self.m_experationMsg = nil
end

-------------------------------------
-- function applyExperationTime
-- @brief 더 빠른 만료 시간을 적용
-- @param timestamp(number) 단위:milliseconds
-- @param msg(string)
-------------------------------------
function ExperationTime:applyExperationTime(timestamp, msg)
    local timestamp_number = tonumber(timestamp)
    if (timestamp_number == nil) then
        return
    end

    -- 이미 지나간 시간일 경우 무시
    if (self.m_updatedAt ~= nil) then
        if (timestamp_number <= self.m_updatedAt) then
            return
        end
    end

    -- 만료 시간이 아직 설정되지 않은 경우
    if (self.m_experationTime == nil) then
        self.m_experationTime = timestamp_number
        self.m_experationMsg = msg
        return
    end

    -- 만료 시간보다 더 빠른 경우
    if (timestamp_number < self.m_experationTime) then
        self.m_experationTime = timestamp_number
        self.m_experationMsg = msg
        return
    end
end

-------------------------------------
-- function applyExperationTime_Midnight
-- @brief 서버상 오늘의 자정 시간을 만료 시간으로 설정
-------------------------------------
function ExperationTime:applyExperationTime_Midnight()
    local timestamp = Timer:getServerTime()

    if (timestamp == nil) or (timestamp == 0) then
        return
    end

    local msg = 'midnight'
    self:applyExperationTime(timestamp, msg)
end

-------------------------------------
-- function applyExperationTime_SecondsLater
-- @brief n초 후를 만료 시간으로 설정
-------------------------------------
function ExperationTime:applyExperationTime_SecondsLater(second, msg)
    local curr_time = Timer:getServerTime()
    local timestamp = curr_time + (second * 1000)
    self:applyExperationTime(timestamp, msg)
end

-------------------------------------
-- function applyExperationTime_MinutesLater
-- @brief n분 후를 만료 시간으로 설정
-------------------------------------
function ExperationTime:applyExperationTime_MinutesLater(minute, msg)
    local curr_time = Timer:getServerTime()
    local timestamp = curr_time + (minute * 60 * 1000)
    self:applyExperationTime(timestamp, msg)
end

-------------------------------------
-- function applyExperationTime_HoursLater
-- @brief n시간 후를 만료 시간으로 설정
-------------------------------------
function ExperationTime:applyExperationTime_HoursLater(hour, msg)
    local curr_time = Timer:getServerTime()
    local timestamp = curr_time + (hour * 60 * 60 * 1000)
    self:applyExperationTime(timestamp, msg)
end

-------------------------------------
-- function getExperationTime
-- @brief 만료 시간
-- @return timestamp(number) 단위:milliseconds
-- @return msg(string)
-------------------------------------
function ExperationTime:getExperationTime()
    return self.m_experationTime, self.m_experationMsg
end

-------------------------------------
-- function setUpdatedAt
-- @brief 갱신된 시간 설정. 만료 시간을 지났을 경우 만료 시간 초기화
-- @param timestamp(number) 단위: milliseconds
-------------------------------------
function ExperationTime:setUpdatedAt(timestamp, reset)
    local reset = (reset or false)
    if (timestamp ~= nil) then
        self.m_updatedAt = timestamp
    else
        local curr_time = Timer:getServerTime()
        self.m_updatedAt = curr_time
    end

    if self.m_experationTime then
        if ((self.m_experationTime <= self.m_updatedAt) or (reset == true)) then
            self.m_experationTime = nil
        end
    end
end

-------------------------------------
-- function getUpdatedAt
-- @brief 갱신된 시간
-- @return timestamp(number) nil리턴 가능, 단위:milliseconds
-------------------------------------
function ExperationTime:getUpdatedAt()
    return self.m_updatedAt
end

-------------------------------------
-- function isExpired
-- @brief 만료 여부
-- @return boolean
-------------------------------------
function ExperationTime:isExpired()
    -- 업데이트된적이 없을 경우
    if (self.m_updatedAt == nil) then
        return true
    end

    -- 만료 시간을 초과했을 경우
    local curr_time = Timer:getServerTime()
    if (self.m_experationTime ~= nil) and (self.m_experationTime <= curr_time) then
        return true
    end

    return false
end

-------------------------------------
-- function getExperationMsg
-- @brief 만료된 이유에 대한 문자열
-------------------------------------
function ExperationTime:getExperationMsg()
    return self.m_experationMsg or 'none'
end


-------------------------------------
-- function printExperationTime
-- @brief 개발 확인용 프린트
-------------------------------------
function ExperationTime:printExperationTime()
    if (self.m_experationTime == nil) then
        cclog('## ExperationTime - m_experationTime is nil!')
        return
    end

    cclog('## ExperationTime - msg : ' .. (self.m_experationMsg or 'none'))
    cclog('## ExperationTime - timestamp : ' .. tostring(self.m_experationTime)) -- timestamp 단위:milliseconds
    cclog('## ExperationTime - date_str : ' .. ServerTime:getInstance():timestampToTimestr(self.m_experationTime / 1000)) --'2021-06-01 00:00:00' 형식

    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds() -- 단위 : 초
    cclog('## ExperationTime - curr : ' .. ServerTime:getInstance():timestampToTimestr(curr_time)) --'2021-06-01 00:00:00' 형식
end

-------------------------------------
-- function createWithUpdatedAyInitialized
-- @brief m_updatedAt이 초기화된 인스턴스 생성
-------------------------------------
function ExperationTime:createWithUpdatedAyInitialized()
    local experation_time = ExperationTime()
    experation_time:setUpdatedAt()
    return experation_time
end