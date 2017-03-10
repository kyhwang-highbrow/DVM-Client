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

    -- 출석 체크
    for i,v in pairs(g_attendanceData.m_structAttendanceDataList) do
        local event_popup_tab = StructEventPopupTab('attendance', v.attendance_type)
        table.insert(item_list, event_popup_tab)
    end

    -- 드래곤 생일
    table.insert(item_list, StructEventPopupTab('birthday_calendar'))

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