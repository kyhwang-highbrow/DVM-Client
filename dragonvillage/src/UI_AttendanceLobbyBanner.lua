local PARENT = UI

-------------------------------------
-- class UI_AttendanceLobbyBanner
-------------------------------------
UI_AttendanceLobbyBanner = class(PARENT,{
    m_structAttendanceData = '',
    m_eventData = '',
    m_enddate = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AttendanceLobbyBanner:init(event_data)
    self.m_uiName = 'UI_AttendanceLobbyBanner'
    self.m_eventData = event_data
    self.m_enddate = event_data['end_date_timestamp']

    local ui_name = self.m_eventData['lobby_banner']
    local event_id = tonumber(self.m_eventData['event_id'])

    self.m_structAttendanceData = g_attendanceData:getAttendanceDataByAtdId(event_id)

    local vars = self:load(ui_name)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttendanceLobbyBanner:initUI()
    local vars = self.vars
    local step = self.m_structAttendanceData['today_step']
    -- 다음 날 보상을 체크
    local tomorrow_step = step + 1
    local step_list = self.m_structAttendanceData['step_list']
    local item_id = ''
    local value = ''

    for _,v in pairs(step_list) do
        if tomorrow_step == v['step'] then
            item_id = v['item_id']
            value = comma_value(v['value'])
        end
    end
    local item_name = TableItem:getItemName(item_id)
    local item_card = IconHelper:getItemIcon(item_id)

    local type = TableItem:getItemType(item_id)
    local did = tonumber(TableItem:getDidByItemId(item_id))
    local reward
    if type == 'dragon' then
        local dragonName = string.format('{@%s}%s{@white}', TableDragon:getDragonAttr(did), item_name)
        reward = Str('{1} {2}마리', dragonName, value)
    else
        reward = Str('{1} {2}개', item_name, value)
    end
    vars['itemNode']:addChild(item_card)
    vars['rewardLabel']:setString(Str('{@YELLOW}내일 접속하시면\n{@DEFAULT}{1}', reward))
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AttendanceLobbyBanner:initButton()
    local vars = self.vars
    vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttendanceLobbyBanner:refresh()
end

-------------------------------------
-- function update
-------------------------------------
function UI_AttendanceLobbyBanner:update(dt)
    local vars = self.vars

    local end_time = self.m_enddate / 1000
    local cur_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local remain_time = (end_time - cur_time)

    if (remain_time > 0) then
        vars['timeLabel']:setString(Str('{1} 남음', ServerTime:getInstance():makeTimeDescToSec(remain_time,true)))
    end
    
end

-------------------------------------
-- function click_bannerBtn
-------------------------------------
function UI_AttendanceLobbyBanner:click_bannerBtn()

    local function show_func(pid)
        local event_id = tostring(self.m_eventData['event_id'])
        local event_pid = pl.stringx.split(pid, ';')
        local open_event_pid = event_pid[3]
        
        -- 출석 이벤트의 event_id는 pid와 동일함
        if (event_id == open_event_pid) then
            local ui = UI_EventFullPopup(pid)
            ui:openEventFullPopup()
        end
    end

    g_fullPopupManager:show(FULL_POPUP_TYPE.ATTENDANCE, show_func)

end