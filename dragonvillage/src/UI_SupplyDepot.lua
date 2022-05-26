local PARENT = UI

-------------------------------------
-- class UI_SupplyDepot
-- @brief 깜짝 할인 상품 팝업
-------------------------------------
UI_SupplyDepot = class(PARENT,{
        m_eventId = 'string',
        m_tableView = 'UIC_TableView',
        m_cbBuy = 'function'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SupplyDepot:init(package_name, is_popup)
    self.m_eventId = event_id
    self.m_uiName = 'UI_SupplyDepot'
    local vars = self:load('supply_depot.ui')

    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)

        -- backkey 지정
        g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_SupplyDepot')
    end

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
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
function UI_SupplyDepot:initUI()
    local table_supply = TableSupply()
    local l_supply_product = table_supply:getSupplyProductList()

    local vars = self.vars
    local node = vars['listNode']

    require('UI_SupplyProductListItem')

    local function make_func(data)
        local ui = UI_SupplyProductListItem(data)
        return ui
    end

    local function create_func(ui, data)
        ui.m_parent = self
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(245 + 25, 405)
    table_view:setCellUIClass(make_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_supply_product)
    
    -- ui_priority로 정렬
    local function sort_func(a, b)
        local a_data = a['data']
        local b_data = b['data']

        -- table_supply의 ui_priority로 정렬
        local a_match = a_data['ui_priority'] or 0
        local b_match = b_data['ui_priority'] or 0

        return a_match < b_match
    end
    table.sort(table_view.m_itemList, sort_func)

    self.m_tableView = table_view
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SupplyDepot:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end

    if vars['contractBtn'] then
        vars['contractBtn']:registerScriptTapHandler(function() self:click_contractBtn() end)
    end
end

-------------------------------------
-- function setBuyCB
-------------------------------------
function UI_SupplyDepot:setBuyCB(func)
    self.m_cbBuy = func
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SupplyDepot:refresh()
    if(self.m_cbBuy) then
        self.m_cbBuy()    
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_SupplyDepot:update(dt)
    local vars = self.vars

    -- 서버 시간 표시
    local time_zone_str = ServerTime:getInstance():getServerUTCStr()
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local t = ServerTime:getInstance():timestampToDate(server_time)
    local hour = string.format('%.2d', t.hour)
    local min = string.format('%.2d', t.min)
    local sec = string.format('%.2d', t.sec)
    local str = Str('서버 시간 : {1}시 {2}분 {3}초 ({4})', hour, min, sec, time_zone_str)
    vars['serverTimeLabel']:setString(str)

    -- 갱신 시간 표시
    local diff_hour = 0
    if t.min > 0 then
        diff_hour = 1
    end

    local remain_hour = 24 - t.hour - diff_hour
    local remain_min = 60 - t.min

    if remain_min == 60 then
        remain_min = 0
    end

    if remain_hour > 0 then
        vars['remainTimeLabel']:setString(Str('{1}시간 후 보급품 갱신', string.format('%.2d', remain_hour)))
    else
        vars['remainTimeLabel']:setString(Str('{1}분 후 보급품 갱신', string.format('%.2d', remain_min)))
    end
    
end

-------------------------------------
-- function click_contractBtn
-------------------------------------
function UI_SupplyDepot:click_contractBtn()
    GoToAgreeMentUrl()
end

--@CHECK
UI:checkCompileError(UI_SupplyDepot)
