local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_EventMatchCardTimeListItem
-------------------------------------
UI_EventMatchCardTimeListItem = class(PARENT, {
        m_dataInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventMatchCardTimeListItem:init(data_info)
    self.m_dataInfo = data_info
    local vars = self:load('event_match_card_time_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventMatchCardTimeListItem:initUI()
    local vars = self.vars
    local data_info = self.m_dataInfo
    local step = data_info['step']

    -- 필요 시간
    local need_time = data_info['time']
    if (need_time == 0) then
        vars['timeLabel']:setString(Str('접속'))
    else
        vars['timeLabel']:setString(Str('{1}분', need_time/60))
    end 
    
    -- 보상버튼
    local finish_cb 
    finish_cb = function()
        self:refresh() 
    end

    vars['receiveBtn']:registerScriptTapHandler(function() 
        g_eventMatchCardData:request_timeReward(step, function() finish_cb() end)
    end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventMatchCardTimeListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventMatchCardTimeListItem:refresh()
    local vars = self.vars
    local data_info = self.m_dataInfo

    local step = data_info['step']
    local need_time = data_info['time']
    local cur_time = g_accessTimeData:getTime()

    -- 받은 보상인지
    local is_get = g_eventMatchCardData:isGetTicket(step)
    vars['checkSprite']:setVisible(is_get or need_time == 0)
    
    -- 버튼 활성화
    local condition = (cur_time >= need_time) and (not is_get) 
    vars['receiveBtn']:setEnabled(condition)
    vars['readySprite']:setVisible(not condition)
end
