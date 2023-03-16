local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_FevertimeListItem
-------------------------------------
UI_FevertimeListItem = class(PARENT, {
        m_structFevertime = 'StructFevertime',
        m_cbChangeData = 'function',

        m_defaultColorTitle = 'cc.c3b',
        m_defaultColorInfo = 'cc.c3b',
        m_defaultColorTime = 'cc.c3b',

        m_bEnabledLinkBtn = 'boolean', -- 바로가기 버튼 사용 가능 여부
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FevertimeListItem:init(struct_fevertime)
    self.m_structFevertime = struct_fevertime
    self.m_bEnabledLinkBtn = true

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
    local str = Str('{1}.{2} {3}', date:month(), date:day(), wday_str)

    if (date:is_weekend() == true) then
        str = '{@light_red}' .. str
    end
    vars['dayLabel']:setString(str)

    do -- 아이콘
        local fevertime_type = struct_fevertime:getFevertimeType()
        local icon_sprite = self:makeFevertimeIcon(struct_fevertime)
        vars['iconNode']:addChild(icon_sprite, -1)

        local fevertime_str = struct_fevertime:getFevertimeIconLabelStr()
        vars['hotTimePerLabel']:setString(fevertime_str)
    end

    do -- 이름
        local str = '[' .. Str(struct_fevertime:getTitleStr()) .. ']'
        vars['titleLabel']:setString(str)
    end

    do -- 설명
        local str = struct_fevertime:getFevertimeDesc()
        vars['infoLabel']:setString(str)
    end

    do -- 기본 색상 저장
        self.m_defaultColorTitle = vars['titleLabel'].m_defaultColor
        self.m_defaultColorInfo = vars['infoLabel'].m_defaultColor
        self.m_defaultColorTime = vars['timeLabel'].m_defaultColor
    end

    do -- 만료되었는가 (핫타임 시간이 지났건, 일일 핫타임 날짜가 넘어간 경우)
        --local expired = struct_fevertime:isFevertimeExpired()
        --vars['CompletMenu']:setVisible(expired)

        vars['CompletMenu']:setVisible(false)
        vars['nextdayMenu']:setVisible(false)
        vars['activeSprite']:setVisible(struct_fevertime:isActiveFevertime())

        local is_shaded = false

        if struct_fevertime:isFevertimeExpired() then
            vars['CompletMenu']:setVisible(true)
            is_shaded = true
        elseif struct_fevertime:isBeforeStartDate() then
            vars['nextdayMenu']:setVisible(true)
            is_shaded = true
        end

        if (is_shaded == true) then
            vars['titleLabel']:setDefualtColor(cc.c3b(180, 180, 180))
            vars['infoLabel']:setDefualtColor(cc.c3b(180, 180, 180))
            vars['timeLabel']:setDefualtColor(cc.c3b(180, 180, 180))
        else
            vars['titleLabel']:setDefualtColor(self.m_defaultColorTitle)
            vars['infoLabel']:setDefualtColor(self.m_defaultColorInfo)
            vars['timeLabel']:setDefualtColor(self.m_defaultColorTime)
        end
    end

    do -- 시간
        local str = struct_fevertime:getPeriodStr()

        if (str == '') or (struct_fevertime:isDailyHottime() == true) then
            str = struct_fevertime:getTimeLabelStr()
            vars['timeLabel']:setString(str)
        else
            local period = struct_fevertime:getPeriodStr()
            vars['dayLabel']:setString(period)
            vars['timeLabel']:setString('')
        end
    end
    
    do -- 뱃지 확인
        local badge_str = struct_fevertime:getBadgeStr()
        if (badge_str ~= nil) and (badge_str ~= '') then
            local node = vars[badge_str .. 'Sprite'] -- bonusSprite
            if (node) then
                node:setVisible(true)
            end
        end
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
    vars['inactivestartBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
    vars['inactivequestLinkBtn']:registerScriptTapHandler(function() self:click_linkBtn() end)
    

    -- 일일 핫타임 스케쥴이고, 오늘 날짜에 포함되었을 경우
    local struct_fevertime = self.m_structFevertime

    if (struct_fevertime:isDailyHottimeSchedule() == true) then
        --if (struct_fevertime:isTodayDailyHottime() == true) then
            vars['questLinkBtn']:setVisible(false)
            vars['startBtn']:setVisible(true)
        --end

        if (struct_fevertime:isTodayDailyHottime() == true) then
            vars['startBtnNotiSprite']:setVisible(true)
        else
            vars['startBtnNotiSprite']:setVisible(false)
        end
    end
    
end

-------------------------------------
-- function setEnabled_linkBtn
-- @brief 바로가기 버튼이 동작하지 않아야 될 경우 사용
-- @param enabled boolean
-------------------------------------
function UI_FevertimeListItem:setEnabled_linkBtn(enabled)
    self.m_bEnabledLinkBtn = enabled
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
    if (self.m_bEnabledLinkBtn == false) then
        local msg = Str('지금 화면에서는 바로가기를 사용할 수 없습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end

    local struct_fevertime = self.m_structFevertime
    local link_type = struct_fevertime:getFevertimeLinkType()
    QuickLinkHelper.quickLink(link_type)
end

-------------------------------------
-- function click_startBtn
-- @brief 일일 핫타임 활성화 (사용)
-------------------------------------
function UI_FevertimeListItem:click_startBtn()
    -- 일일 핫타임 스케쥴이고, 오늘 날짜에 포함되었을 경우
    local struct_fevertime = self.m_structFevertime
    if (struct_fevertime:isTodayDailyHottime() == false) then
        --local msg = Str('일일 핫타임은 당일에만 사용할 수 있습니다.')
        --MakeSimplePopup(POPUP_TYPE.OK, msg)
        UIManager:toastNotificationRed(Str('일일 핫타임은 당일에만 사용할 수 있습니다.'))
        return
    end

    local type = struct_fevertime:getFevertimeType()
    if (g_fevertimeData:isActiveDailyFevertimeByType(type) == true) then
        --local msg = Str('같은 종류의 일일 핫타임은 동시에 사용할 수 없습니다.')
        --MakeSimplePopup(POPUP_TYPE.OK, msg)
        UIManager:toastNotificationRed(Str('같은 종류의 일일 핫타임은 동시에 사용할 수 없습니다.'))
        return
    end

    self:FevertimeConfirmPopup(struct_fevertime)
end

-------------------------------------
-- function FevertimeConfirmPopup
-- @brief 피버타임 사용 결정을 하는 확인 팝업을 띄워준다.
-------------------------------------
function UI_FevertimeListItem:FevertimeConfirmPopup(struct_fevertime)
    local id = struct_fevertime:getFevertimeID()

    local function finish_cb(ret)
        if self.m_cbChangeData then
            self.m_cbChangeData()
        end
    end

    local function okBtn()
        g_fevertimeData:request_fevertimeActive(id, finish_cb)
    end

    UI_FevertimeConfirmPopup(struct_fevertime, okBtn)
end

-------------------------------------
-- function setChangeDataCB
-- @brief
-------------------------------------
function UI_FevertimeListItem:setChangeDataCB(func)
    self.m_cbChangeData = func
end

-------------------------------------
-- function makeFevertimeIcon
-- @brief 피버타임 아이콘 sprite 생성
-------------------------------------
function UI_FevertimeListItem:makeFevertimeIcon(struct_fevertime)
    local path = struct_fevertime:getFevertimeIcon()

    local sprite = cc.Sprite:create(path)
    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))
    
    return sprite
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

    do -- 만료되었는가 (핫타임 시간이 지났건, 일일 핫타임 날짜가 넘어간 경우)
        --local expired = struct_fevertime:isFevertimeExpired()
        --vars['CompletMenu']:setVisible(expired)

        vars['CompletMenu']:setVisible(false)
        vars['nextdayMenu']:setVisible(false)
        vars['inactivestartBtn']:setVisible(false)
        vars['inactivequestLinkBtn']:setVisible(false)
        vars['activeSprite']:setVisible(struct_fevertime:isActiveFevertime())

        local is_shaded = false
        if struct_fevertime:isFevertimeExpired() then
            vars['CompletMenu']:setVisible(true)
            is_shaded = true

            if (struct_fevertime:isDailyHottimeSchedule() == true) then
                vars['inactivestartBtn']:setVisible(true)
            elseif (struct_fevertime:isDailyHottime() == true) then
                vars['inactivequestLinkBtn']:setVisible(true)
            elseif (struct_fevertime:isGlobalHottime() == true) then
                vars['inactivequestLinkBtn']:setVisible(true)
            end
        elseif struct_fevertime:isBeforeStartDate() then
            vars['nextdayMenu']:setVisible(true)
            is_shaded = true

            if (struct_fevertime:isDailyHottimeSchedule() == true) then
                vars['inactivestartBtn']:setVisible(true)
            elseif (struct_fevertime:isDailyHottime() == true) then
                vars['inactivestartBtn']:setVisible(true)
            elseif (struct_fevertime:isGlobalHottime() == true) then
                vars['inactivequestLinkBtn']:setVisible(true)
            end
        end

        if (is_shaded == true) then
            vars['titleLabel']:setDefualtColor(cc.c3b(180, 180, 180))
            vars['infoLabel']:setDefualtColor(cc.c3b(180, 180, 180))
            vars['timeLabel']:setDefualtColor(cc.c3b(180, 180, 180))
        else
            vars['titleLabel']:setDefualtColor(self.m_defaultColorTitle)
            vars['infoLabel']:setDefualtColor(self.m_defaultColorInfo)
            vars['timeLabel']:setDefualtColor(self.m_defaultColorTime)
        end
    end
end