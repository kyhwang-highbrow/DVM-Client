local PARENT = UI

-------------------------------------
-- class UI_BannerNewServerEvent
-------------------------------------
UI_BannerNewServerEvent = class(PARENT,{
    m_structAttendanceData = '',
    m_enddate = 'String',
    m_atd_id = 'String'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BannerNewServerEvent:init(atd_id, end_data)
    self.m_uiName = 'UI_BannerNewServerEvent'
    self.m_enddate = end_data
    self.m_atd_id = atd_id
    local vars = self:load('lobby_banner_event_attendance.ui')

    self.m_structAttendanceData = g_attendanceData:getAttendanceDataByAtdId(atd_id)

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
function UI_BannerNewServerEvent:initUI()
    local vars = self.vars
    local step = self.m_structAttendanceData['today_step']
    -- 다음 날 보상을 체크
    local tomorrow_step = step + 1
    local step_list = self.m_structAttendanceData['step_list']
    local item_id = ''
    local value = ''

    local info = ServerData_Attendance:getAttendanceDataList()

    for _,v in pairs(step_list) do
        if tomorrow_step == v['step'] then
            item_id = v['item_id']
            value = v['value']
        end
    end
    local item_name = TableItem:getItemName(item_id)
    local item_card = IconHelper:getItemIcon(item_id)
    local type = TableItem:getItemType(item_id)
    local did = tonumber(TableItem:getDidByItemId(item_id))

    if type == 'dragon' then
        local dragonName = string.format('{@%s}%s{@white}', TableDragon:getDragonAttr(did), item_name)
        vars['rewardLabel']:setString(Str('{1} {2}마리', dragonName, value))
    else
        vars['rewardLabel']:setString(Str('{1} {2}개', item_name, value))
    end
    vars['itemNode']:addChild(item_card)
    vars['ddayLabel']:setString(Str('D-1'))
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BannerNewServerEvent:initButton()
    local vars = self.vars
    vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BannerNewServerEvent:refresh()
end

-------------------------------------
-- function update
-------------------------------------
function UI_BannerNewServerEvent:update(dt)
    local vars = self.vars

    local end_time = self.m_enddate / 1000
    local cur_time = Timer:getServerTime()
    local remain_time = (end_time - cur_time)

    if (remain_time > 0) then
        vars['timeLabel']:setString(Str('{1} 남음', datetime.makeTimeDesc(remain_time,true)))
    end
    
end

-------------------------------------
-- function click_bannerBtn
-------------------------------------
function UI_BannerNewServerEvent:click_bannerBtn()
    local atd_id = 'attendance_event;event;50029'
    FullPopupManager:showFullPopup(atd_id)
end