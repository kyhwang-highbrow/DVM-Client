-------------------------------------
-- class ServerData_Event
-------------------------------------
ServerData_Event = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Event:init(server_data)
    self.m_serverData = server_data
end


-------------------------------------
-- function getEventPopupTabList
-------------------------------------
function ServerData_Event:getEventPopupTabList()
    local item_list = {}

    local idx = 1

    -- 출석 체크
    for i, v in pairs(g_attendanceData.m_structAttendanceDataList) do
        local event_popup_tab = StructEventPopupTab('attendance', v['attendance_type'], v['category'])
        item_list[event_popup_tab.m_type] = event_popup_tab
        event_popup_tab.m_userData = v
        event_popup_tab.m_hasNoti = v:hasReward()
        event_popup_tab.m_sortIdx = idx

        idx = idx + 1
    end

    -- 이벤트 교환소(현재는 상시 적용)
    for i, v in ipairs(g_exchangeData.m_lExchange) do
        local event_popup_tab = StructEventPopupTab('exchange', v['group_type'], v['t_name'])
        item_list[event_popup_tab.m_type] = event_popup_tab
        event_popup_tab.m_userData = v
        event_popup_tab.m_hasNoti = false
        event_popup_tab.m_sortIdx = idx

        idx = idx + 1
    end

    -- 접속 시간 이벤트(현재는 상시 적용)
    if (g_accessTimeData.m_lEventData) then
        local event_popup_tab = StructEventPopupTab('play_time')
        item_list[event_popup_tab.m_type] = event_popup_tab
        event_popup_tab.m_userData = v
        event_popup_tab.m_hasNoti = false
        event_popup_tab.m_sortIdx = idx

        idx = idx + 1
    end

    --[[
    -- 공개용 빌드에서 제거
    -- 드래곤 생일
    local event_popup_tab = StructEventPopupTab('birthday_calendar')
    event_popup_tab.m_hasNoti = g_birthdayData:hasBirthdayReward()
    item_list[event_popup_tab.m_type] = event_popup_tab
    --]]

    return item_list
end

-------------------------------------
-- function openEventPopup
-------------------------------------
function ServerData_Event:openEventPopup()

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        co:work('# 출석 정보 받는 중')
        g_attendanceData:request_attendanceInfo(co.NEXT, co.ESCAPE)
        if co:waitWork() then return end

        co:work('# 접속시간 저장 중')
        g_accessTimeData:request_saveTime(co.NEXT, co.ESCAPE)
        if co:waitWork() then return end

        co:close()
        UI_EventPopup()
    end

    Coroutine(coroutine_function, 'Event Popup 코루틴')
end

-------------------------------------
-- function hasReward
-- @brief 받아야할 보상이 있는지 여부 (이벤트 팝업을 띄움)
-------------------------------------
function ServerData_Event:hasReward()
    -- 생일 보상 여부
    if g_birthdayData:hasBirthdayReward() then
        return true
    end

    -- 출석 보상 여부
    if g_attendanceData:hasAttendanceReward() then
        return true
    end

    return false
end