-------------------------------------
-- class StructEventPopupTab
-- @brief 이벤트 팝업에 등록된 탭
-------------------------------------
StructEventPopupTab = class({
        m_type = 'string',
        m_sortIdx = 'number',
        m_eventData = 'map',
        m_hasNoti = '',
    })

-------------------------------------
-- function init
-------------------------------------
function StructEventPopupTab:init(event_data)
    self.m_eventData = event_data
    self.m_sortIdx = event_data['ui_priority'] or 99
end

-------------------------------------
-- function getTabButtonName
-------------------------------------
function StructEventPopupTab:getTabButtonName()
	local name = self.m_eventData['t_name'] or '이벤트'
    return Str(name)
end

-------------------------------------
-- function getTabIcon
-------------------------------------
function StructEventPopupTab:getTabIcon()
    local res = self.m_eventData['icon']
    return res
end

-------------------------------------
-- function getVersion
-------------------------------------
function StructEventPopupTab:getVersion()
    return self.m_eventData['version']
end


function StructEventPopupTab:getEventID()
    return self.m_eventData['event_id']
end
