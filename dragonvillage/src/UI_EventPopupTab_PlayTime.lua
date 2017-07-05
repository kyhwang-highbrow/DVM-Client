local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_PlayTime
-------------------------------------
UI_EventPopupTab_PlayTime = class(PARENT,{
        m_lEventData = 'list'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_PlayTime:init(owner)
    local vars = self:load('event_time.ui')
    self:initUI()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTab_PlayTime:initUI()
    local vars = self.vars
    self.m_lEventData = g_accessTimeData.m_lEventData

    -- 접속시간 이벤트 보상 리스트
    for i, v in ipairs(self.m_lEventData) do
        local ui = UI_PlayTimeDataListItem(v)
        local node = vars['itemNode'..i]
        if node then
            node:removeAllChildren()
            node:addChild(ui.root)
        end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_PlayTime:refresh()
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
function UI_EventPopupTab_PlayTime:onEnterTab()
    self:refresh()
end
