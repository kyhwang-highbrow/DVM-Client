-------------------------------------
-- class ServerData_EventRuneFestival
-- @brief 할로윈 룬 축제(할로윈 이벤트)
-- @instance g_eventRuneFestival
-------------------------------------
ServerData_EventRuneFestival = class({
        m_eventVersion = 'string', -- 이벤트 버전 ex) 2020helloween
        m_dailyMaxSt = 'number', -- 일일 최대 입장권(날개)
        m_dailyUsedSt = 'number', -- 일일 사용 입장권(날개)


        m_eventTokenId = 'number', -- 이벤트 토큰 
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventRuneFestival:init()

end

-------------------------------------
-- function getStatusText
-------------------------------------
function ServerData_EventRuneFestival:getStatusText()
    local time = g_hotTimeData:getEventRemainTime('event_rune_festival') or 0
    return Str('이벤트 종료까지 {1} 남음', datetime.makeTimeDesc(time, true))
end

-------------------------------------
-- function getRuneFestivalStaminaText
-- @brief 일일 입장권(날개) 제한 관련 텍스트
-------------------------------------
function ServerData_EventRuneFestival:getRuneFestivalStaminaText()
    local daily_user_st = self.m_dailyUsedSt or 0
    local daily_max_st = self.m_dailyMaxSt  or 0

    local str = Str('일일 최대 {1}/{2}개 사용 가능', comma_value(daily_user_st), comma_value(daily_max_st))
    return str
end

-------------------------------------
-- function isDailyStLimit
-- @brief 일일 입장권(날개) 제한
-- @return boolean 초과될 경우 true 리턴
-------------------------------------
function ServerData_EventRuneFestival:isDailyStLimit(add_st)
    local add_st = (add_st or 0)
    local daily_user_st = (self.m_dailyUsedSt or 0)
    local daily_max_st = (self.m_dailyMaxSt  or 0)

    -- 초과될 경우 제한 
    if (daily_max_st < (daily_user_st + add_st)) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function applyRuneFestivalInfo
-- @brief /users/lobby, /game/stage/finish에서 rune_festival_info값으로 전달
-- @param t_rune_festival_info table
--        "rune_festival_info":{ 
--          "st_use":0,   # 사용한 날개 수
--          "st_max":1800,  # 최대 사용 가능한 날개 수
--          "version":"2020helloween" // 이벤트 버전
--        }
-------------------------------------
function ServerData_EventRuneFestival:applyRuneFestivalInfo(t_rune_festival_info)
    if (not t_rune_festival_info) then
        return
    end

    self.m_eventVersion = t_rune_festival_info['version'] or '' -- 이벤트 버전 ex) 2020helloween
    self.m_dailyMaxSt = t_rune_festival_info['st_max'] or 0 -- 일일 최대 입장권(날개)
    self.m_dailyUsedSt = t_rune_festival_info['st_use'] or 0 -- 일일 사용 입장권(날개)
end

-------------------------------------
-- function getAdventStageCount
-- @brief 스테이지 수
-------------------------------------
function ServerData_EventRuneFestival:getAdventStageCount()
    return 1
end