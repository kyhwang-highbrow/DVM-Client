local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_RuneBulkSalePopup
-------------------------------------
UI_ItemBulkSalePopup = class(PARENT,{
        m_tableView = '',
        m_sortManagerRune = '',
        m_sellCB = '',
        m_bOptionChanged = 'boolean',
        m_setId = 'number',
        m_list_rune = 'StructRune',
        m_list_item = 'items',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ItemBulkSalePopup:init(list_rune, list_item)
    local vars = self:load('inventory_sell_popup_03.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_setId = 0
    self.m_list_rune = list_rune
    self.m_list_item = list_item

    --[[local l_item_list = g_userData:getFruitList(is_all)
    for i, v in pairs(list_item) do
        l_item_list[i]['count'] = v[i]['count']
        l_list_item[i]['fid'] = v[i]['fid']
    end
    self.m_list_item = l_item_list--]]

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_RuneBulkSalePopup')


    local node = self.vars['listViewNode2']

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(UI_Inventory.CARD_SCALE)

        local function click_func()
            self.m_inventoryUI:setSelectedItem(ui, data)
        end

        ui.vars['clickBtn']:registerScriptTapHandler(click_func)
    end

    -- 열매 아이콘 생성 함수(내부에서 Item Card)
    local function make_func(t_data)
        return self:createCard(t_data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = UI_Inventory.CARD_CELL_SIZE
    table_view_td.m_nItemPerCell = 8
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    table_view_td:setCellUIClass(make_func, create_func)
    table_view_td:setItemList(self.m_list_item)
    table_view_td:makeDefaultEmptyDescLabel(Str('보유한 알이 없습니다.'))
    self.m_tableView = table_view_td

    print('well done')
    -------------------------------------------------여기까지 아이템만---------------------------------------------

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    
    self:init_tableView2()

    self:refresh2()

    -- 정렬
    --[[
    local sort_manager = SortManager_Rune()
    sort_manager:sortExecution(table_view_td.m_itemList)
    
    self.m_mSortManagerMap[slot_idx] = sort_manager
    self.m_mTableViewListMap[slot_idx] = table_view_td
    --]]



    --[[

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:init_tableView()
    self:refresh()

    self.m_bOptionChanged = false--]]
end


-------------------------------------
-- function createCard
-------------------------------------
function UI_ItemBulkSalePopup:createCard(t_data)
    print('t_data')
    ccdump(t_data)
    local item_id = t_data['esid'] or t_data['fid'] or t_data['mid']
    if(item_id == nil) then
        ccdump(t_data)
        for k, v in pairs(t_data) do
            t_data = v
        end
        ccdump(t_data)
        item_id = t_data['esid'] or t_data['fid'] or t_data['mid']
    end
    local count = t_data['count']
    print(item_id)
    local ui = UI_ItemCard(tonumber(item_id), 0)
    ui:setNumberLabel(count)

    return ui
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ItemBulkSalePopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_RuneBulkSalePopup'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('룬 일괄 판매')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ItemBulkSalePopup:initUI()
    local text = string.format('%s (%s)', Str('세트'), Str('전체'))
    self.vars['setRuneLabel']:setString(text)
end

-------------------------------------
-- function init_tableView2
-------------------------------------
function UI_ItemBulkSalePopup:init_tableView2()
    local node = self.vars['listViewNode']

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.55)
    end

    local l_item_list = {}

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(80, 80)
    table_view_td.m_nItemPerCell = 6
    table_view_td:setCellUIClass(UI_RuneCard, create_func)
    table_view_td:setItemList(l_item_list)

    self.m_tableView = table_view_td

    local sort_manager = SortManager_Rune()
    sort_manager:pushSortOrder('set_id')
    sort_manager:pushSortOrder('lv')
    sort_manager:pushSortOrder('rarity')
    sort_manager:pushSortOrder('grade')
    --sort_manager:pushSortOrder('rune_num')
    --sort_manager:pushSortOrder('mopt')
    self.m_sortManagerRune = sort_manager
end


-------------------------------------
-- function refresh2
-------------------------------------
function UI_ItemBulkSalePopup:refresh2()
    self.m_tableView:mergeItemList(self.m_list_rune)
    --[[self:tableViewSortAndRefresh()

    local total_price = 0
    local table_item = TableItem()
    for i,v in pairs(l_item_list) do
        local item_id = v['rid']
        local price = table_item:getValue(item_id, 'sale_price')
        total_price = total_price + price
    end
    

    local vars = self.vars
    vars['countLabel']:setString(Str('{1}/{2}', selected_count, total_count))
    vars['priceaLabel']:setString(comma_value(total_price))--]]
end
-------------------------------------
-- function initButton
-------------------------------------
function UI_ItemBulkSalePopup:initButton()
    local vars = self.vars
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['sellBtn']:registerScriptTapHandler(function() self:click_sellBtn() end)
    vars['resetBtn'] = UIC_CheckBox(vars['allCheckBtn'].m_node, vars['allCheckSprite'], active)
    vars['resetBtn']:registerScriptTapHandler(function()       
        self:click_resetBtn()      
    end)

    do -- 등급
        local active = g_settingData:get('option_rune_bulk_sell', 'grade_6')
        vars['starBtn6'] = UIC_CheckBox(vars['starBtn6'].m_node, vars['starSprite6'], active)
        vars['starBtn6']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_settingData:get('option_rune_bulk_sell', 'grade_5')
        vars['starBtn5'] = UIC_CheckBox(vars['starBtn5'].m_node, vars['starSprite5'], active)
        vars['starBtn5']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_settingData:get('option_rune_bulk_sell', 'grade_4')
        vars['starBtn4'] = UIC_CheckBox(vars['starBtn4'].m_node, vars['starSprite4'], active)
        vars['starBtn4']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_settingData:get('option_rune_bulk_sell', 'grade_3')
        vars['starBtn3'] = UIC_CheckBox(vars['starBtn3'].m_node, vars['starSprite3'], active)
        vars['starBtn3']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_settingData:get('option_rune_bulk_sell', 'grade_2')
        vars['starBtn2'] = UIC_CheckBox(vars['starBtn2'].m_node, vars['starSprite2'], active)
        vars['starBtn2']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_settingData:get('option_rune_bulk_sell', 'grade_1')
        vars['starBtn1'] = UIC_CheckBox(vars['starBtn1'].m_node, vars['starSprite1'], active)
        vars['starBtn1']:registerScriptTapHandler(function() self:click_checkBox() end)
    end

    do -- 레어도
        local active = g_settingData:get('option_rune_bulk_sell', 'rarity_4')
        vars['rarityBtn4'] = UIC_CheckBox(vars['rarityBtn4'].m_node, vars['raritySprite4'], active)
        vars['rarityBtn4']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_settingData:get('option_rune_bulk_sell', 'rarity_3')
        vars['rarityBtn3'] = UIC_CheckBox(vars['rarityBtn3'].m_node, vars['raritySprite3'], active)
        vars['rarityBtn3']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_settingData:get('option_rune_bulk_sell', 'rarity_2')
        vars['rarityBtn2'] = UIC_CheckBox(vars['rarityBtn2'].m_node, vars['raritySprite2'], active)
        vars['rarityBtn2']:registerScriptTapHandler(function() self:click_checkBox() end)

        local active = g_settingData:get('option_rune_bulk_sell', 'rarity_1')
        vars['rarityBtn1'] = UIC_CheckBox(vars['rarityBtn1'].m_node, vars['raritySprite1'], active)
        vars['rarityBtn1']:registerScriptTapHandler(function() self:click_checkBox() end)
    end

    do -- 강화 단계
        local active = g_settingData:get('option_rune_bulk_sell', 'enhance')
        vars['enhanceBtn'] = UIC_CheckBox(vars['enhanceBtn'].m_node, vars['enhanceSprite'], active)
        vars['enhanceBtn']:registerScriptTapHandler(function() self:click_checkBox() end)
    end

    do -- 룬 번호 : 홀수
       local active = g_settingData:get('option_rune_bulk_sell', 'odd')
       vars['oddBtn'] = UIC_CheckBox(vars['oddBtn'].m_node, vars['oddSprite'], active)
       vars['oddBtn']:registerScriptTapHandler(function() self:click_checkBox() end)

       -- 룬 번호 : 짝수
       local active = g_settingData:get('option_rune_bulk_sell', 'even')
       vars['evenBtn'] = UIC_CheckBox(vars['evenBtn'].m_node, vars['evenSprite'], active)
       vars['evenBtn']:registerScriptTapHandler(function() self:click_checkBox() end)
    end

    do -- 주옵션
        for i = 1, 8 do 
            local active = g_settingData:get('option_rune_bulk_sell', 'mopt'..i)
            vars['moptBtn'..i] = UIC_CheckBox(vars['moptBtn'..i].m_node, vars['moptSprite'..i], active)
            vars['moptBtn'..i]:registerScriptTapHandler(function() self:click_checkBox() end)
        end
    end




    vars['setRuneBtn']:registerScriptTapHandler(function() self:click_setSortBtn() end)
end

-------------------------------------
-- function click_setSortBtn
-------------------------------------
function UI_ItemBulkSalePopup:click_setSortBtn()
    local ui = UI_RuneSetFilter()
    ui:setCloseCB(function(set_id)
        self:refresh_runeSetFilter(set_id)
    end)
end

-------------------------------------
-- function refresh_runeSetFilter
-------------------------------------
function UI_ItemBulkSalePopup:refresh_runeSetFilter(set_id)
    local vars = self.vars
    local table_rune_set = TableRuneSet()
    local text = (set_id == 0) and string.format('%s (%s)', Str('세트'), Str('전체')) or table_rune_set:makeRuneSetNameRichText(set_id)
    vars['setRuneLabel']:setString(text)
    self.m_setId = set_id

    self:refresh()
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_ItemBulkSalePopup:init_tableView()
    local node = self.vars['listViewNode']

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.55)
    end

    local l_item_list = {}

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(80, 80)
    table_view_td.m_nItemPerCell = 6
    table_view_td:setCellUIClass(UI_RuneCard, create_func)
    table_view_td:setItemList(l_item_list)

    self.m_tableView = table_view_td

    local sort_manager = SortManager_Rune()
    sort_manager:pushSortOrder('set_id')
    sort_manager:pushSortOrder('lv')
    sort_manager:pushSortOrder('rarity')
    sort_manager:pushSortOrder('grade')
    --sort_manager:pushSortOrder('rune_num')
    --sort_manager:pushSortOrder('mopt')
    self.m_sortManagerRune = sort_manager
end

-------------------------------------
-- function tableViewSortAndRefresh
-- @brief 테이블 뷰 정렬, 갱신
-------------------------------------
function UI_ItemBulkSalePopup:tableViewSortAndRefresh()
    local sort_manager = self.m_sortManagerRune
    sort_manager:sortExecution(self.m_tableView.m_itemList)

    self.m_tableView:setDirtyItemList()

    if (self.m_tableView:getItemCount() <= 0) then
        self.vars['listViewLabel']:setVisible(true)
    else
        self.vars['listViewLabel']:setVisible(false)
    end
end

-------------------------------------
-- function getRuneList
-------------------------------------
function UI_ItemBulkSalePopup:getRuneList()
    local unequipped = true
    local l_rune_list = g_runesData:getFilteredRuneList(unequipped, nil, self.m_setId)
    local total_count = table.count(l_rune_list)

    local l_ret_list = {}
    local vars = self.vars

    local l_stars = {}
    local is_all_stars = true
    for i = 1, 6 do
        l_stars[i] = vars['starBtn'..i]:isChecked()
        if (vars['starBtn'..i]:isChecked()) then
            is_all_stars = false
        end
    end
    

    local l_rarity = {}
    local is_all_rarity = true
    for i = 1, 4 do
        l_rarity[i] = vars['rarityBtn'..i]:isChecked()
        if (vars['rarityBtn'..i]:isChecked()) then
            is_all_rarity = false
        end
    end

    local l_rune_num = {}
    local is_all_rune_num = true
    for i = 1, 6 do
        if (i%2 == 1) then
            l_rune_num[i] = vars['evenBtn']:isChecked()
            if (vars['evenBtn']:isChecked()) then
                is_all_rune_num = false
            end
        else
            l_rune_num[i] = vars['oddBtn']:isChecked()
            if (vars['oddBtn']:isChecked()) then
                is_all_rune_num = false
            end
        end
    end

    local l_mopt = {}
    local is_all_mopt = true
    for i = 1, 8 do
        l_mopt[i] = vars['moptBtn'..i]:isChecked()
        if (vars['moptBtn'..i]:isChecked()) then
            is_all_mopt = false
        end
    end

    local with_enhanced_runes = vars['enhanceBtn']:isChecked()
    for i,v in pairs(l_rune_list) do
        local grade = v['grade']
        if (is_all_stars) then
            l_stars[grade] = true
        end
        
        local rarity = v['rarity']
        if (is_all_rarity) then
            l_rarity[rarity] = true
        end

        local lv = v['lv']

        local lock = v['lock']
        
        local mopt = self:parseMopt(v['mopt'])
        if (is_all_mopt) then
            l_mopt[mopt] = true
        end

        local slot = (7-v['slot']) -- 슬롯 순서가 반대
        if (is_all_rune_num) then
            l_rune_num[slot] = true
        end

        if (not with_enhanced_runes) and (1 <= lv) then
        elseif (lock == true) then
        elseif (l_stars[grade] and l_rarity[rarity] and l_rune_num[slot] and l_mopt[mopt]) then
            l_ret_list[i] = v
        end
    end

    return l_ret_list, total_count
end

-------------------------------------
-- function getRuneSelectSellList
-- get all rune information except lock
-- type StructRuneObject
-------------------------------------
function UI_ItemBulkSalePopup:getRuneSelectSellList()
    local unequipped = true
    local l_rune_list = g_runesData:getFilteredRuneList(unequipped, nil, self.m_setId)
    local total_count = table.count(l_rune_list)

    local l_ret_list = {}
    local vars = self.vars

    local l_stars = {}
    local is_all_stars = true
    

    local l_rarity = {}
    local is_all_rarity = true

    local l_rune_num = {}
    local is_all_rune_num = true

    local l_mopt = {}
    local is_all_mopt = true

    local with_enhanced_runes = true
    for i,v in pairs(l_rune_list) do
        local grade = v['grade']
        if (is_all_stars) then
            l_stars[grade] = true
        end
        
        local rarity = v['rarity']
        if (is_all_rarity) then
            l_rarity[rarity] = true
        end

        local lv = v['lv']

        local lock = v['lock']
        
        local mopt = self:parseMopt(v['mopt'])
        if (is_all_mopt) then
            l_mopt[mopt] = true
        end

        local slot = (7-v['slot']) -- 슬롯 순서가 반대
        if (is_all_rune_num) then
            l_rune_num[slot] = true
        end

        if (not with_enhanced_runes) and (1 <= lv) then
        elseif (lock == true) then
        elseif (l_stars[grade] and l_rarity[rarity] and l_rune_num[slot] and l_mopt[mopt]) then
            l_ret_list[i] = v
        end
    end

    return l_ret_list, total_count
end

-------------------------------------
-- function parseMopt
-------------------------------------
function UI_ItemBulkSalePopup:parseMopt(mopt_str)
    if (not mopt_str) then
        return 1
    end
    local l_mopt = pl.stringx.split(mopt_str, ';')
    if (#l_mopt < 2) then
        return 1
    end

    local mopt = l_mopt[1]
    if (string.match(mopt, 'hp')) then
        return 1
    elseif (string.match(mopt, 'atk')) then
        return 2
    elseif (string.match(mopt, 'def')) then
        return 3
    elseif (string.match(mopt, 'aspd')) then
        return 4
    elseif (string.match(mopt, 'cri_chance')) then
        return 5
    elseif (string.match(mopt, 'cri_dmg')) then
        return 6
    elseif (string.match(mopt, 'accuracy')) then
        return 7
    elseif (string.match(mopt, 'resistance')) then
        return 8
    else
        return 1
    end

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ItemBulkSalePopup:refresh()
    local l_item_list, total_count = self:getRuneSelectSellList()
    local selected_count = table.count(l_item_list)
    ccdump(l_item_list)
    self.m_tableView:mergeItemList(l_item_list)
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
function UI_ItemBulkSalePopup:click_checkBox()
    self.m_bOptionChanged = true
    self:refresh()
end

-------------------------------------
-- function click_cancelBtn
-- @brief "취소(닫기)" 버튼 클릭
-------------------------------------
function UI_ItemBulkSalePopup:click_cancelBtn()
    self:close()
end

-------------------------------------
-- function click_resetBtn
-- @brief "조건(취소)" 버튼 클릭
-------------------------------------
function UI_ItemBulkSalePopup:click_resetBtn()
    local vars = self.vars
    local is_reset = vars['resetBtn']:isChecked()

    vars['starBtn6']:setChecked(is_reset)
    vars['starBtn5']:setChecked(is_reset)
    vars['starBtn4']:setChecked(is_reset)
    vars['starBtn3']:setChecked(is_reset)
    vars['starBtn2']:setChecked(is_reset)
    vars['starBtn1']:setChecked(is_reset)
    
    vars['rarityBtn4']:setChecked(is_reset)
    vars['rarityBtn3']:setChecked(is_reset)
    vars['rarityBtn2']:setChecked(is_reset)
    vars['rarityBtn1']:setChecked(is_reset)
    
    vars['enhanceBtn']:setChecked(is_reset)

    vars['oddBtn']:setChecked(is_reset)
    vars['evenBtn']:setChecked(is_reset)
    
    for i = 1, 8 do
        vars['moptBtn'..i]:setChecked(is_reset)
    end

    self:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ItemBulkSalePopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_sellBtn
-- @brief "판매" 버튼 클릭
-------------------------------------
function UI_ItemBulkSalePopup:click_sellBtn()
    local selected_item_count = self.m_tableView:getItemCount()

    if (selected_item_count <= 0) then
        UIManager:toastNotificationRed(Str('조건에 해당하는 룬이 없습니다.'))
        return
    end

    local table_item = TableItem()
    local total_price = 0

    local rune_oids = nil
    for i,v in ipairs(self.m_tableView.m_itemList) do
        local roid = v['data']['roid']
        local rid = v['data']['rid']
        if (not rune_oids) then
            rune_oids = tostring(roid)
        else
            rune_oids = (rune_oids .. ',' .. tostring(roid))
        end

        local price = table_item:getValue(rid, 'sale_price')
        total_price = total_price + price
    end

    local items = nil

    local function cb(ret)
        if self.m_sellCB then
            self.m_sellCB(ret)
        end

        self:refresh()
    end

    local function request_item_sell()
        g_inventoryData:request_itemSell(rune_oids, items, cb)
    end

    local msg = Str('{1}개의 룬을 {2}골드에 판매하시겠습니까?', selected_item_count, comma_value(total_price))
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, request_item_sell)
end

-------------------------------------
-- function setSellCallback
-- @brief 판매 콜백 함수
-- @param sell_cb function(ret)
-------------------------------------
function UI_ItemBulkSalePopup:setSellCallback(sell_cb)
    self.m_sellCB = sell_cb
end

-------------------------------------
-- function onClose
-------------------------------------
function UI_ItemBulkSalePopup:onClose()
    if (self.m_bOptionChanged == true) then
        local vars = self.vars

        g_settingData:lockSaveData()

        g_settingData:applySettingData(vars['starBtn6']:isChecked(), 'option_rune_bulk_sell', 'grade_6')
        g_settingData:applySettingData(vars['starBtn5']:isChecked(), 'option_rune_bulk_sell', 'grade_5')
        g_settingData:applySettingData(vars['starBtn4']:isChecked(), 'option_rune_bulk_sell', 'grade_4')
        g_settingData:applySettingData(vars['starBtn3']:isChecked(), 'option_rune_bulk_sell', 'grade_3')
        g_settingData:applySettingData(vars['starBtn2']:isChecked(), 'option_rune_bulk_sell', 'grade_2')
        g_settingData:applySettingData(vars['starBtn1']:isChecked(), 'option_rune_bulk_sell', 'grade_1')

        g_settingData:applySettingData(vars['rarityBtn4']:isChecked(), 'option_rune_bulk_sell', 'rarity_4')
        g_settingData:applySettingData(vars['rarityBtn3']:isChecked(), 'option_rune_bulk_sell', 'rarity_3')
        g_settingData:applySettingData(vars['rarityBtn2']:isChecked(), 'option_rune_bulk_sell', 'rarity_2')
        g_settingData:applySettingData(vars['rarityBtn1']:isChecked(), 'option_rune_bulk_sell', 'rarity_1')

        g_settingData:applySettingData(vars['enhanceBtn']:isChecked(), 'option_rune_bulk_sell', 'enhance')

        g_settingData:applySettingData(vars['oddBtn']:isChecked(), 'option_rune_bulk_sell', 'odd')
        g_settingData:applySettingData(vars['evenBtn']:isChecked(), 'option_rune_bulk_sell', 'even')


        for i = 1, 8 do
            g_settingData:applySettingData(vars['moptBtn'..i]:isChecked(), 'option_rune_bulk_sell', 'mopt'..i)
        end


        g_settingData:unlockSaveData()
        self.m_bOptionChanged = false
    end

    PARENT.onClose(self)
end


--@CHECK
UI:checkCompileError(UI_ItemBulkSalePopup)
