local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_AccessTime
-------------------------------------
UI_EventPopupTab_AccessTime = class(PARENT,{
        m_lEventDataUi = 'list'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_AccessTime:init(owner)
    local vars = self:load('event_time.ui')
    self.m_lEventDataUi = {}

    self:initUI()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTab_AccessTime:initUI()
    local vars = self.vars
    local event_data = g_accessTimeData.m_lEventData
    
    -- 접속시간 이벤트 보상 리스트
    for i, v in ipairs(event_data) do
        local ui = UI_AccessTimeDataListItem(v)
        local node = vars['itemNode'..i]
        if node then
            node:removeAllChildren()
            node:addChild(ui.root)
        end
        table.insert(self.m_lEventDataUi, ui)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_AccessTime:refresh()
    local vars = self.vars

    -- 오늘 접속 시간
    local is_minute = true
    local play_time = g_accessTimeData:getTime(is_minute)
    vars['timeLabel']:setString(Str('{1}분', play_time))
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_AccessTime:onEnterTab()
    self:refresh()

    -- 보상 리스트 갱신
    for i, v in ipairs(self.m_lEventDataUi) do
        local ui = v
        ui:refresh()
    end
end
