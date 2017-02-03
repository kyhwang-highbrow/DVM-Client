local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_RuneBulkSalePopup
-------------------------------------
UI_RuneBulkSalePopup = class(PARENT,{
        m_tableView = '',
        m_sortManagerRune = '',
        m_sellCB = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneBulkSalePopup:init()
    local vars = self:load('rune_bulk_sell_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_RuneBulkSalePopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:init_tableView()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_RuneBulkSalePopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_RuneBulkSalePopup'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('룬 일괄 판매')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneBulkSalePopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneBulkSalePopup:initButton()
    local vars = self.vars
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['sellBtn']:registerScriptTapHandler(function() self:click_sellBtn() end)

    do -- 등급
        local active = g_localData:get('option_rune_bulk_sell', 'grade_5')
        vars['starBtn5'] = UIC_CheckBox(vars['starBtn5'].m_node, vars['starSprite5'], active)
        vars['starBtn5']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_localData:get('option_rune_bulk_sell', 'grade_4')
        vars['starBtn4'] = UIC_CheckBox(vars['starBtn4'].m_node, vars['starSprite4'], active)
        vars['starBtn4']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_localData:get('option_rune_bulk_sell', 'grade_3')
        vars['starBtn3'] = UIC_CheckBox(vars['starBtn3'].m_node, vars['starSprite3'], active)
        vars['starBtn3']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_localData:get('option_rune_bulk_sell', 'grade_2')
        vars['starBtn2'] = UIC_CheckBox(vars['starBtn2'].m_node, vars['starSprite2'], active)
        vars['starBtn2']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_localData:get('option_rune_bulk_sell', 'grade_1')
        vars['starBtn1'] = UIC_CheckBox(vars['starBtn1'].m_node, vars['starSprite1'], active)
        vars['starBtn1']:registerScriptTapHandler(function() self:click_checkBox() end)
    end

    do -- 레어도
        local active = g_localData:get('option_rune_bulk_sell', 'rarity_s')
        vars['rarityBtnS'] = UIC_CheckBox(vars['rarityBtnS'].m_node, vars['raritySpriteS'], active)
        vars['rarityBtnS']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_localData:get('option_rune_bulk_sell', 'rarity_a')
        vars['rarityBtnA'] = UIC_CheckBox(vars['rarityBtnA'].m_node, vars['raritySpriteA'], active)
        vars['rarityBtnA']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_localData:get('option_rune_bulk_sell', 'rarity_b')
        vars['rarityBtnB'] = UIC_CheckBox(vars['rarityBtnB'].m_node, vars['raritySpriteB'], active)
        vars['rarityBtnB']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_localData:get('option_rune_bulk_sell', 'rarity_c')
        vars['rarityBtnC'] = UIC_CheckBox(vars['rarityBtnC'].m_node, vars['raritySpriteC'], active)
        vars['rarityBtnC']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_localData:get('option_rune_bulk_sell', 'rarity_d')
        vars['rarityBtnD'] = UIC_CheckBox(vars['rarityBtnD'].m_node, vars['raritySpriteD'], active)
        vars['rarityBtnD']:registerScriptTapHandler(function() self:click_checkBox() end)
    end
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_RuneBulkSalePopup:init_tableView()
    local node = self.vars['listViewNode']

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.68)
    end

    local l_item_list = {}

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(102, 102)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_RuneCard, create_func)
    local skip_update = true -- 정렬 후 업데이트하기 위해
    table_view_td:setItemList(l_item_list, skip_update)

    self.m_tableView = table_view_td

    local sort_manager = SortManager_Rune()
    sort_manager:pushSortOrder('set_color')
    sort_manager:pushSortOrder('lv')
    sort_manager:pushSortOrder('rarity')
    sort_manager:pushSortOrder('grade')
    self.m_sortManagerRune = sort_manager
end

-------------------------------------
-- function tableViewSortAndRefresh
-- @brief 테이블 뷰 정렬, 갱신
-------------------------------------
function UI_RuneBulkSalePopup:tableViewSortAndRefresh()
    local sort_manager = self.m_sortManagerRune
    sort_manager:sortExecution(self.m_tableView.m_itemList)

    self.m_tableView:expandTemp(0.5)

    local animated = false
    self.m_tableView:relocateContainerDefault(animated)

    if (self.m_tableView:getItemCount() <= 0) then
        self.vars['listViewLabel']:setVisible(true)
    else
        self.vars['listViewLabel']:setVisible(false)
    end
end

-------------------------------------
-- function getRuneList
-------------------------------------
function UI_RuneBulkSalePopup:getRuneList()
    local l_rune_list = g_runesData:getUnequippedRuneList()
    local total_count = table.count(l_rune_list)

    local l_ret_list = {}
    local vars = self.vars

    local l_active = {}
    l_active[1] = vars['starBtn1']:isChecked()
    l_active[2] = vars['starBtn2']:isChecked()
    l_active[3] = vars['starBtn3']:isChecked()
    l_active[4] = vars['starBtn4']:isChecked()
    l_active[5] = vars['starBtn5']:isChecked()
    l_active['s'] = vars['rarityBtnS']:isChecked()
    l_active['a'] = vars['rarityBtnA']:isChecked()
    l_active['b'] = vars['rarityBtnB']:isChecked()
    l_active['c'] = vars['rarityBtnC']:isChecked()
    l_active['d'] = vars['rarityBtnD']:isChecked()

    for i,v in pairs(l_rune_list) do
        local grade = v['grade']
        local rarity = v['rarity']
        if (l_active[grade] and l_active[rarity]) then
            l_ret_list[i] = v
        end
    end

    return l_ret_list, total_count
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneBulkSalePopup:refresh()
    local l_item_list, total_count = self:getRuneList()
    local selected_count = table.count(l_item_list)

    local skip_refresh = true
    self.m_tableView:mergeItemList(l_item_list, skip_refresh)
    self:tableViewSortAndRefresh()

    local total_price = 0
    local table_item = TableItem()
    for i,v in pairs(l_item_list) do
        local item_id = v['rid']
        local price = table_item:getValue(item_id, 'sale_price')
        total_price = total_price + price
    end
    

    local vars = self.vars
    vars['countLabel']:setString(Str('{1}/{2}', selected_count, total_count))
    vars['priceaLabel']:setString(comma_value(total_price))
end

-------------------------------------
-- function click_checkBox
-------------------------------------
function UI_RuneBulkSalePopup:click_checkBox()
    local vars = self.vars

    g_localData:lockSaveData()

    g_localData:applyLocalData(vars['starBtn5']:isChecked(), 'option_rune_bulk_sell', 'grade_5')
    g_localData:applyLocalData(vars['starBtn4']:isChecked(), 'option_rune_bulk_sell', 'grade_4')
    g_localData:applyLocalData(vars['starBtn3']:isChecked(), 'option_rune_bulk_sell', 'grade_3')
    g_localData:applyLocalData(vars['starBtn2']:isChecked(), 'option_rune_bulk_sell', 'grade_2')
    g_localData:applyLocalData(vars['starBtn1']:isChecked(), 'option_rune_bulk_sell', 'grade_1')

    g_localData:applyLocalData(vars['rarityBtnS']:isChecked(), 'option_rune_bulk_sell', 'rarity_s')
    g_localData:applyLocalData(vars['rarityBtnA']:isChecked(), 'option_rune_bulk_sell', 'rarity_a')
    g_localData:applyLocalData(vars['rarityBtnB']:isChecked(), 'option_rune_bulk_sell', 'rarity_b')
    g_localData:applyLocalData(vars['rarityBtnC']:isChecked(), 'option_rune_bulk_sell', 'rarity_c')
    g_localData:applyLocalData(vars['rarityBtnD']:isChecked(), 'option_rune_bulk_sell', 'rarity_d')

    g_localData:unlockSaveData()

    self:refresh()
end

-------------------------------------
-- function click_cancelBtn
-- @brief "취소(닫기)" 버튼 클릭
-------------------------------------
function UI_RuneBulkSalePopup:click_cancelBtn()
    self:close()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_RuneBulkSalePopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_sellBtn
-- @brief "판매" 버튼 클릭
-------------------------------------
function UI_RuneBulkSalePopup:click_sellBtn()
    local selected_item_count = self.m_tableView:getItemCount()

    if (selected_item_count <= 0) then
        UIManager:toastNotificationRed(Str('조건에 해당하는 룬이 없습니다.'))
        return
    end

    local table_item = TableItem()
    local total_price = 0

    local rune_oids = nil
    for i,v in ipairs(self.m_tableView.m_itemList) do
        local roid = v['data']['id']
        local rid = v['data']['rid']
        if (not rune_oids) then
            rune_oids = tostring(roid)
        else
            rune_oids = (rune_oids .. ',' .. tostring(roid))
        end

        local price = table_item:getValue(rid, 'sale_price')
        total_price = total_price + price
    end

    local evolution_stones = nil
    local fruits = nil

    local function cb(ret)
        if self.m_sellCB then
            self.m_sellCB(ret)
        end

        self:refresh()
    end

    local function request_item_sell()
        g_inventoryData:request_itemSell(rune_oids, evolution_stones, fruits, cb)
    end

    local msg = Str('{1}개의 룬을 {2}골드에 판매하시겠습니까?', selected_item_count, comma_value(total_price))
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, request_item_sell)
end

-------------------------------------
-- function setSellCallback
-- @brief 판매 콜백 함수
-- @param sell_cb function(ret)
-------------------------------------
function UI_RuneBulkSalePopup:setSellCallback(sell_cb)
    self.m_sellCB = sell_cb
end



--@CHECK
UI:checkCompileError(UI_RuneBulkSalePopup)
