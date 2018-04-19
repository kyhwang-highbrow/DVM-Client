local PARENT = TableClass

-------------------------------------
-- class TableNaverEvent
-------------------------------------
TableNaverEvent = class(PARENT, {
    })

    
local THIS = TableNaverEvent

-------------------------------------
-- function init
-------------------------------------
function TableNaverEvent:init()
    self.m_tableName = 'table_naver_event'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getOnTimeEventList
-- @breif
-------------------------------------
function TableNaverEvent:getOnTimeEventList()
    if (self == THIS) then
        self = THIS()
    end

    if (not self.m_orgTable) then
        return {}
    end
    
    local l_ret = {}
    for i, t_event in pairs(self.m_orgTable) do
        -- 날짜 조건
        if (ServerData_Event:checkEventTime(t_event['start_date'], t_event['end_date'])) then
            table.insert(l_ret, t_event)
        end
    end 
    return l_ret
end