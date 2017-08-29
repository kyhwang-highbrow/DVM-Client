-------------------------------------
-- class StructEventPopupTab
-- @brief 이벤트 팝업에 등록된 탭
-------------------------------------
StructEventPopupTab = class({
        m_type = 'string',
        m_sortIdx = 'number',

        m_bAttendance = 'boolean',
        m_eventData = 'map',
        m_hasNoti = '',
    })

-------------------------------------
-- function init
-------------------------------------
function StructEventPopupTab:init(event_data)
    self.m_eventData = event_data
    self.m_bAttendance = (event_data['attendance_type']) and true or false

    local sortNum = 10

    -- 출석 체크 고정 (기본출석, 이벤트출석)
    if (self.m_bAttendance) then
        self.m_type = 'attendance_' .. event_data['attendance_type']
        self.m_sortIdx = sortNum

    -- 기타 가변적인 이벤트 (shop, banner, access_time)
    else        
        self.m_sortIdx = event_data['ui_priority'] or 99
    end
end

-------------------------------------
-- function getTabButtonName
-------------------------------------
function StructEventPopupTab:getTabButtonName()
    local name 
    if (self.m_type == 'attendance_basic') then
        name = Str('출석')

    elseif (self.m_type == 'attendance_event') then
        name = Str('이벤트 출석')

    else
        name = self.m_eventData['t_name']
    end

    return name
end

-------------------------------------
-- function getTabIcon
-------------------------------------
function StructEventPopupTab:getTabIcon()
    local res = self.m_eventData['icon']
    return res
end