local PARENT = UI
local MAX_MIN = 60

-------------------------------------
-- class UI_EventPopupTab_AccessTime
-- @brief 접속 시간 보상
--        이벤트 팝업에서 일간 접속 시간에 따라 보상을 획득
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
    table.sort(event_data, function(a, b)
        return tonumber(a['step']) < tonumber(b['step'])
    end)
 
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

    local function update(dt)
        self:refresh()
    end
    self.root:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_AccessTime:refresh()
    local vars = self.vars

    local play_second = g_accessTimeData:getTime()
    
    -- 오늘 접속 시간
    if (play_second >= (MAX_MIN * 60)) then
        vars['timeLabel']:setString(Str('완료'))
        vars['timeGauge']:setPercentage(100)
    else
        local t_detail = {5, 10, 20, 30, 45, 60}
        
        for i, v in ipairs(t_detail) do
            if (play_second < (v * 60)) then
                local div = 100/#t_detail

                local pre_sec = (i == 1) and 0 or t_detail[(i - 1)] * 60
                local cur_sec = t_detail[i] * 60
                local need_sec = cur_sec - pre_sec
                local play_second = play_second - pre_sec
                local per = div * (i - 1) + (div * (play_second/(need_sec)))

                vars['timeGauge']:setPercentage(per)
                break
            end
        end

        -- 보상 리스트 갱신
        for i, ui in ipairs(self.m_lEventDataUi) do
            ui:refresh()
        end

        local is_minute = true
        local play_min = g_accessTimeData:getTime(is_minute)
        vars['timeLabel']:setString(Str('{1}분', play_min))
    end

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
