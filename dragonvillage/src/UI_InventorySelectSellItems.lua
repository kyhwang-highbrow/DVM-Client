-------------------------------------
-- class UI_InventorySelectSellItems
-- @brief UI_Inventory에서 아이템 선택 판매를 도와주는 클래스
-------------------------------------
UI_InventorySelectSellItems = class({
        m_inventoryUI = 'UI_Inventory',
        vars = 'table',
        m_bActive = 'boolean',
        m_selectedItemUIMap = '',

        m_runeList = 'StructRuneObject',
        m_evolutionList = 'Item',
        m_fruitList = 'Item',
        m_transformList = 'Item',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InventorySelectSellItems:init(inventory_ui)
    self.m_inventoryUI = inventory_ui
    self.vars = inventory_ui.vars
    self.m_bActive = false
    self.m_selectedItemUIMap = {}

    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_InventorySelectSellItems:initButton()
    local vars = self.vars

    -- "선택 판매" 버튼
    vars['selectSellBtn1']:registerScriptTapHandler(function()
            self:setActive(true)
        end)

    -- "판매" 버튼
    vars['selectSellBtn2']:registerScriptTapHandler(function() self:click_sellBtn() end)

    -- "완료" 버튼 (취소 기능)
    vars['selectSellBtn3']:registerScriptTapHandler(function()
            self:setActive(false)
        end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_InventorySelectSellItems:refresh()
    local vars = self.vars

    if self.m_bActive then
        vars['selectSellBtn1']:setVisible(false)
        vars['selectSellBtn2']:setVisible(true)
        vars['selectSellBtn3']:setVisible(true)

        vars['bulkSellBtn']:setVisible(false)
        vars['sellBtn']:setVisible(false)
    else
        vars['selectSellBtn1']:setVisible(true)
        vars['selectSellBtn2']:setVisible(false)
        vars['selectSellBtn3']:setVisible(false)

        -- 룬 탭일 경우
        if (self.m_inventoryUI.m_mainTabMgr.m_currTab == 'rune') then
            vars['bulkSellBtn']:setVisible(true)
        end

        -- 선택된 아이템이 있을 경우
        if (self.m_inventoryUI.m_selectedItemUI) then
            vars['sellBtn']:setVisible(true)
        end
    end
end

-------------------------------------
-- function setActive
-------------------------------------
function UI_InventorySelectSellItems:setActive(active)
    self.m_bActive = active

    if (not active) then
        for i,v in pairs(self.m_selectedItemUIMap) do
            local ui = v['ui']
            ui:setCheckSpriteVisible(false)
        end
        self.m_selectedItemUIMap = {}
    end

    self:refresh()
end

-------------------------------------
-- function setSelectedItem
-------------------------------------
function UI_InventorySelectSellItems:setSelectedItem(ui, data)
    if (not self.m_bActive) then
        return
    end

    local item_id = ui.m_itemID
    local item_type = TableItem():getValue(item_id, 'type')

    -- 알은 선택 판매 불가
    if (item_type == 'egg') then
        UIManager:toastNotificationRed(Str('알은 판매할 수 없습니다.'))
        return
    end

    -- 0개인 아이템도 표시 - 선택 판매 불가능하게 막아줌
    if (item_type ~= 'rune' and data['count'] and data['count'] == 0) then
        UIManager:toastNotificationRed(Str('보유한 아이템이 아닙니다.'))
        return
    end

    local unique_id
    if (item_type == 'rune') then
        if (data['lock']) then
            UIManager:toastNotificationRed(Str('잠금 상태입니다.'))
            return
        end
        unique_id = data['roid']
    else
        unique_id = item_id
    end

    if self.m_selectedItemUIMap[unique_id] then
        ui:setCheckSpriteVisible(false)
        self.m_selectedItemUIMap[unique_id] = nil
    else
        ui:setCheckSpriteVisible(true)
        self.m_selectedItemUIMap[unique_id] = {ui=ui, data=data}
    end
end

-------------------------------------
-- function click_sellBtn
-------------------------------------
function UI_InventorySelectSellItems:click_sellBtn()
    local count = table.count(self.m_selectedItemUIMap)

    -- 선택된 아이템을 list_m_item_id에 저장
    list_m_item_id = {}
    for key, value in pairs(self.m_selectedItemUIMap) do
        for k, v in pairs(value) do
            for ke, va in pairs(v) do
                if(ke == 'm_itemID') then
                    table.insert(list_m_item_id, va)
                end
            end
        end
    end

    -- 모든 아이템 정보 획득
    self.m_runeList = g_runesData:getUnequippedRuneList(slot_idx)
    self.m_evolutionList = g_evolutionStoneData:getEvolutionStoneList(is_all)
    self.m_fruitList = g_userData:getFruitList(is_all)
    self.m_transformList = g_userData:getTransformList(is_all)

    -- 이용할 정보. new_itemList과 new_runeList
    temp_runeList = {}
    new_runeList_roid = {}
    new_runeList = {}
    new_itemList = {}

    -- 룬 정보 획득
    for k, v in pairs(self.m_runeList) do
        for index, value in pairs(list_m_item_id) do
            if(v['rid'] == value) then
                temp_t = {}
                temp_t[k] = v
                table.insert(temp_runeList, temp_t)
            end
        end
    end

    -- 아이템 정보 획득 (진화 재료, 친밀도 열매, 외형 변환 재료)
    for k, v in pairs(self.m_evolutionList) do
        for index, value in pairs(list_m_item_id) do
            if(k == value) then
                temp_t = {}
                temp_t[k] = v
                table.insert(new_itemList, temp_t)
            end
        end
    end

    for k, v in pairs(self.m_fruitList) do
        for index, value in pairs(list_m_item_id) do
            if(v['fid'] == value) then
                temp_t = {}
                table.insert(temp_t, v)
                table.insert(new_itemList, temp_t)
            end
        end
    end

    for k, v in pairs(self.m_transformList) do
        for index, value in pairs(list_m_item_id) do
            if(v['mid'] == value) then
                temp_t = {}
                table.insert(temp_t, v)
                table.insert(new_itemList, temp_t)
            end
        end
    end
    


    if (count <= 0) then
        UIManager:toastNotificationRed(Str('선택된 아이템이 없습니다.'))
        return
    end

    local rune_oids
    local items

    local total_price = 0

    local table_item = TableItem()
    for i,v in pairs(self.m_selectedItemUIMap) do
        local ui = v['ui']
        local data = v['data']
        local item_id = ui.m_itemID

        local item_type = table_item:getValue(item_id, 'type')
        local price = table_item:getValue(item_id, 'sale_price')
        local item_count = 1

        -- 룬 판매
        if (item_type == 'rune') then
            local roid = i
            table.insert(new_runeList_roid, roid) -- rune roid 저장
            if (not rune_oids) then
                rune_oids = roid
            else
                rune_oids = rune_oids .. ',' .. roid
            end
        
        -- 그외 (진화석, 외형변환, 열매)
        else
            item_count = data['count']
            local str = tostring(item_id) .. ':' .. item_count
            if (not items) then
                items = str
            else
                items = items .. ',' .. str
            end
        end

        total_price = total_price + (price * item_count)
    end

    -- 사용하지 않는 룬 제거 new_runeList를 생성하여 사용함.
    for k, v in pairs(temp_runeList) do
        for ke, va in pairs(v) do
            
            for key, value in pairs(new_runeList_roid) do
                if(ke == value) then
                    new_runeList[ke] = va
                end
            end
        end
    end


    -- 선택된 룬이 판매되었으니 선택 해제
    local function cb(ret)
        self.m_inventoryUI:response_itemSell(ret)
        self.m_inventoryUI:clearSelectedItem()

        self.m_selectedItemUIMap = {}
        self:setActive(false)
    end

    local function request_item_sell()
        g_inventoryData:request_itemSell(rune_oids, items, cb)
    end

    UI_ItemBulkSalePopup(new_runeList, new_itemList, comma_value(total_price), request_item_sell)


    --local msg = Str('{1}개의 아이템을 {2}골드에 판매하시겠습니까?', count, comma_value(total_price))
    --MakeSimplePopup(POPUP_TYPE.YES_NO, msg, request_item_sell)
end