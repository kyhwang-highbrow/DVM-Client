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
    -- 출석 체크
    -- 이벤트 출석
    -- 드래곤 생일
    -- 이벤트

    local item_list = {}

    table.insert(item_list, StructEventPopupTab('attendance_basic'))
    table.insert(item_list, StructEventPopupTab('attendance_event'))
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
        if co:wait() then return end

        UI_EventPopup()
    end

    Coroutine(coroutine_function, 'Event Popup 코루틴')
end