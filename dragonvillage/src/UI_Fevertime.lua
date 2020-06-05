local PARENT = UI

-------------------------------------
-- class UI_Fevertime
-- @breif 핫타임(개발 코드는 fevertime)
-------------------------------------
UI_Fevertime = class(PARENT,{
        m_bDirty = 'boolean',
        m_bRequested = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Fevertime:init()
    local ui_name = 'event_fevertime.ui'
    self:load(ui_name)

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self.m_bDirty = false
    self.m_bRequested = false
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Fevertime:initUI()
    local vars = self.vars

    vars['serverTimeLabel']:setString('')
    vars['hotTimeExpLabel']:setString('')
    vars['hotTimeGoldLabel']:setString('')

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Fevertime:initButton()
    local vars = self.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_Fevertime:onEnterTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Fevertime:refresh()
    local vars = self.vars

    do -- 테이블 뷰 생성
        local node = vars['listNode']
        node:removeAllChildren()
        local content_size = node:getContentSize()

        local l_item_list = g_fevertimeData:getAllStructFevertimeList()

        local function sort_func(a, b)
            local struct_a = a['data']
            local struct_b = b['data']
            return StructFevertime.sortFunc(struct_a, struct_b)
        end

        local function create_func(ui, data)
            ui:setChangeDataCB(function() self.m_bDirty = true end)
        end
        

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(900, 90 + 10)
        require('UI_FevertimeListItem')
        table_view:setCellUIClass(UI_FevertimeListItem, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_item_list)
        table_view:insertSortInfo('sort', sort_func)
        table_view:sortImmediately('sort')
        --self.m_tableView = table_view

        do -- 포커싱
            local idx = 0
            local l_struct_fevertime = table_view.m_itemList
            for i, v in ipairs(l_struct_fevertime) do
                local struct = v['data']
                if (struct:isAfterStartDate() == true) and (struct:isFevertimeExpired() == false) then
                    idx = i
                    break
                end
            end
            idx = math_min(idx + 1, #l_struct_fevertime)

            table_view:relocateContainerFromIndex(idx, false)
        end
    end

    self.m_bDirty = false
end

-------------------------------------
-- function update
-- @brief
-------------------------------------
function UI_Fevertime:update(dt)
    local vars = self.vars

    -- 서버 시간 표시
    --[[
    local time_zone_str, t = datetime.getTimeUTCHourStr()
    local hour = string.format('%.2d', t.hour)
    local min = string.format('%.2d', t.min)
    local sec = string.format('%.2d', t.sec)
    local str = Str('서버 시간 : {1}시 {2}분 {3}초 ({4})', hour, min, sec, time_zone_str)
    --]]
    do -- 서버 시간 표시
        -- h : UTC 기준 시각 (UTC+h)
	    local h = Timer:getUTCHour()
        local utc = ''
        if h >= 0 then
            utc = Str('UTC+{1}', h)
        else
            utc = Str('UTC{1}', h)
        end

        local server_timestamp = Timer:getServerTime()
        local date = TimeLib:convertToServerDate(server_timestamp)
        local wday_str = getWeekdayName(date:weekday_name())
        local str = string.format('%d.%d %s %.2d:%.2d', date:month(), date:day(), wday_str, date:hour(), date:min())

        vars['serverTimeLabel']:setString(Str('서버 시간 : {1}', str .. ' (' .. utc .. ')'))
    end

    -- 데이터 갱신이 필요할 경우
    if (self.m_bRequested == false) and (g_fevertimeData:needToUpdateFevertimeInfo() == true) then
        local function cb()
            self.m_bRequested = false
            if (self.closed == true) then
                return
            end
            self:refresh()    
        end
        self.m_bRequested = true
        g_fevertimeData:request_fevertimeInfo(cb, cb)
    end

    if (self.m_bDirty == true) then
        self:refresh()
    end
end

--@CHECK
UI:checkCompileError(UI_Fevertime)
