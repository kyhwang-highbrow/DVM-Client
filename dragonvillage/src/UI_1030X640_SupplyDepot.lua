local PARENT = UI

-------------------------------------
-- class UI_1030X640_SupplyDepot
-- @brief 보급소 (정액제)
-------------------------------------
UI_1030X640_SupplyDepot = class(PARENT,{
        m_eventId = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_1030X640_SupplyDepot:init()
    self.m_eventId = event_id

    self.m_uiName = 'UI_1030X640_SupplyDepot'
    
    local ui_res = 'supply_depot.ui'
    local vars = self:load(ui_res)
    --UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    --g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_1030X640_SupplyDepot')

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
function UI_1030X640_SupplyDepot:initUI()
    local table_supply = TableSupply()
    local l_supply_product = table_supply:getSupplyProductList()

    local vars = self.vars
    local node = vars['listNode']

    require('UI_SupplyProductListItem')

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(245 + 25, 405)
    table_view:setCellUIClass(UI_SupplyProductListItem)
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
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_1030X640_SupplyDepot:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:setVisible(false)
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end

    if vars['contractBtn'] then
        vars['contractBtn']:registerScriptTapHandler(function() self:click_contractBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_1030X640_SupplyDepot:refresh()
end

-------------------------------------
-- function update
-------------------------------------
function UI_1030X640_SupplyDepot:update(dt)
    local vars = self.vars

    -- 서버 시간 표시
    local time_zone_str, t = datetime.getTimeUTCHourStr()
    local hour = string.format('%.2d', t.hour)
    local min = string.format('%.2d', t.min)
    local sec = string.format('%.2d', t.sec)
    local str = Str('서버 시간 : {1}시 {2}분 {3}초 ({4})', hour, min, sec, time_zone_str)
    vars['serverTimeLabel']:setString(str)
end

-------------------------------------
-- function click_contractBtn
-------------------------------------
function UI_1030X640_SupplyDepot:click_contractBtn()
    GoToAgreeMentUrl()
end

--@CHECK
UI:checkCompileError(UI_1030X640_SupplyDepot)
