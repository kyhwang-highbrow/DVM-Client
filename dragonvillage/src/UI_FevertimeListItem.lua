local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_FevertimeListItem
-------------------------------------
UI_FevertimeListItem = class(PARENT, {
        m_structFevertime = 'StructFevertime',
        m_cbChangeData = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FevertimeListItem:init(struct_fevertime)
    self.m_structFevertime = struct_fevertime

	-- UI load
	local ui_name = 'event_fevertime_list_item.ui' 
    if (struct_fevertime:isGlobalHottime() == true) then
        ui_name = 'event_fevertime_list_item_special.ui' 
    end
	self:load(ui_name)

	-- initialize
    self:initUI()
    self:initButton()
    self:refresh()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FevertimeListItem:initUI()
    local vars = self.vars

    local struct_fevertime = self.m_structFevertime
    local server_timestamp = struct_fevertime:getStartDateForSort() / 1000
    
    local date = TimeLib:convertToServerDate(server_timestamp)
    local wday_str = getWeekdayName(date:weekday_name())
    local str = Str('{1}.{2}\n{3}', date:month(), date:day(), wday_str)

    if (date:is_weekend() == true) then
        str = '{@light_red}' .. str
    end
    vars['dayLabel']:setString(str)

    do -- 이름
        local str = struct_fevertime:getFevertimeName()
        vars['titleLabel']:setString(str)
    end

    do -- 설명
        local str = struct_fevertime:getFevertimeDesc()
        vars['infoLabel']:setString(str)
    end

    do -- 만료되었는가 (핫타임 시간이 지났건, 일일 핫타임 날짜가 넘어간 경우)
        --local expired = struct_fevertime:isFevertimeExpired()
        --vars['CompletMenu']:setVisible(expired)

        vars['CompletMenu']:setVisible(false)
        vars['nextdayMenu']:setVisible(false)

        if struct_fevertime:isFevertimeExpired() then
            vars['CompletMenu']:setVisible(true)
        elseif struct_fevertime:isBeforeStartDate() then
            vars['nextdayMenu']:setVisible(true)
        end
    end

    do -- 시간
        local str = struct_fevertime:getPeriodStr()

        if (str == '') or (struct_fevertime:isDailyHottime() == true) then
            str = struct_fevertime:getTimeLabelStr()
        end
        vars['timeLabel']:setString(str)
    end
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FevertimeListItem:initButton()
    local vars = self.vars
    vars['startBtn']:setVisible(false)
    vars['nextdayBtn']:setVisible(false)
    vars['CompletBtn']:setVisible(false)
    vars['questLinkBtn']:setVisible(true)

    vars['questLinkBtn']:registerScriptTapHandler(function() self:click_linkBtn() end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
    

    -- 일일 핫타임 스케쥴이고, 오늘 날짜에 포함되었을 경우
    local struct_fevertime = self.m_structFevertime

    if (struct_fevertime:isDailyHottimeSchedule() == true) then
        --if (struct_fevertime:isTodayDailyHottime() == true) then
            vars['questLinkBtn']:setVisible(false)
            vars['startBtn']:setVisible(true)
        --end
    end
    
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FevertimeListItem:refresh()
end

-------------------------------------
-- function click_linkBtn
-- @brief 바로가기
-------------------------------------
function UI_FevertimeListItem:click_linkBtn()
    local struct_fevertime = self.m_structFevertime
    local link_type = struct_fevertime:getFevertimeLinkType()
    QuickLinkHelper.quickLink(link_type)
end

-------------------------------------
-- function click_startBtn
-- @brief 일일 핫타임 활성화 (사용)
-------------------------------------
function UI_FevertimeListItem:click_startBtn()
    if self.m_cbChangeData then
        self.m_cbChangeData()
        return
    end

    -- 일일 핫타임 스케쥴이고, 오늘 날짜에 포함되었을 경우
    local struct_fevertime = self.m_structFevertime
    if (struct_fevertime:isTodayDailyHottime() == false) then
        local msg = Str('일일 핫타임은 당일에만 사용할 수 있습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end

    local type = struct_fevertime:getFevertimeType()
    if (g_fevertimeData:isActiveDailyFevertimeByType(type) == true) then
        local msg = Str('같은 종류의 일일 핫타임은 동시에 사용할 수 없습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end

    local id = struct_fevertime:getFevertimeID()
    local function finish_cb(ret)
        if self.m_cbChangeData then
            self.m_cbChangeData()
        end
    end
    g_fevertimeData:request_fevertimeActive(id, finish_cb)
end

-------------------------------------
-- function setChangeDataCB
-- @brief
-------------------------------------
function UI_FevertimeListItem:setChangeDataCB(func)
    self.m_cbChangeData = func
end

-------------------------------------
-- function update
-- @brief
-------------------------------------
function UI_FevertimeListItem:update(dt)
    local vars = self.vars

    local struct_fevertime = self.m_structFevertime

    -- 시간 표기
    if (struct_fevertime:isDailyHottime() == true) then
        str = struct_fevertime:getTimeLabelStr()
        vars['timeLabel']:setString(str)
    end
end