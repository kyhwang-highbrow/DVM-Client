local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Inventory
-------------------------------------
UI_Inventory = class(PARENT, {
        m_mainTabMgr = 'UIC_TabManager',
        m_tTabClass = 'table',
        m_selectedItemUI = '',
        m_selectedItemData = '',
        m_selectSellItemsUI = 'UI_InventorySelectSellItems',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Inventory:init()
    local vars = self:load('inventory.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Inventory')

    self:initUI()
    self:initButton()
    self:refresh()

    self.m_selectSellItemsUI = UI_InventorySelectSellItems(self)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Inventory:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Inventory'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('가방')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Inventory:initUI()
    local vars = self.vars

    do
        self.m_tTabClass = {}
        self.m_tTabClass['rune'] = UI_InventoryTabRune(self)
        self.m_tTabClass['material'] = UI_InventoryTabEvolutionStone(self)
        self.m_tTabClass['fruit'] = UI_InventoryTabFruit(self)
    end


    do
        self.m_mainTabMgr = UIC_TabManager()
        self.m_mainTabMgr:addTab('rune', vars['runeBtn'], vars['runeNode'])
        self.m_mainTabMgr:addTab('material', vars['materialBtn'], vars['materialNode'])
        self.m_mainTabMgr:addTab('fruit', vars['fruitBtn'], vars['fruitNode'])
    
		
        self.m_mainTabMgr:setChangeTabCB(function(tab, first) self:onChangeMainTab(tab, first) end)

        self.m_mainTabMgr:setTab('rune')
    end

    self:refreshInventoryLabel()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Inventory:initButton()
    local vars = self.vars
    vars['sortBtn']:registerScriptTapHandler(function() self:click_sortBtn() end)
    vars['inventoryBtn']:registerScriptTapHandler(function() self:click_inventoryBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Inventory:refresh()
    local vars = self.vars
    self:clearItemInfo()
end

-------------------------------------
-- function refreshInventoryLabel
-------------------------------------
function UI_Inventory:refreshInventoryLabel()
    local vars = self.vars
    local inven_type = 'rune'
    local item_count = g_inventoryData:getItemCount()
    local max_count = g_inventoryData:getMaxCount(inven_type)
    self.vars['inventoryLabel']:setString(Str('{1}/{2}', item_count, max_count))
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Inventory:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_inventoryBtn
-------------------------------------
function UI_Inventory:click_inventoryBtn()
    local item_type = 'rune'
    local function finish_cb()
        self:refreshInventoryLabel()
    end

    g_inventoryData:extendInventory(item_type, finish_cb)
end

-------------------------------------
-- function click_sortBtn
-- @brief "정렬" 버튼 클릭
-------------------------------------
function UI_Inventory:click_sortBtn()
    local tab = self.m_mainTabMgr.m_currTab
    if (not self.m_tTabClass[tab]) then
        return
    end

    -- 현재 탭의 click_sortBtn을 호출
    self.m_tTabClass[tab]:click_sortBtn()
end

-------------------------------------
-- function onChangeMainTab
-------------------------------------
function UI_Inventory:onChangeMainTab(tab, first)
    if (not self.m_tTabClass[tab]) then
        return
    end

    -- rune tab일 경우만 가방 버튼 표시
    local vars = self.vars
    vars['inventoryBtn']:setVisible(tab == 'rune')

    self:setSelectedItem(nil, nil)
    self.m_tTabClass[tab]:onEnterInventoryTab(first)
end

-------------------------------------
-- function clearItemInfo
-- @brief
-------------------------------------
function UI_Inventory:clearItemInfo()
    local vars = self.vars

    vars['lockSprite']:setVisible(false)
    vars['lockBtn']:setVisible(false)
    vars['itemDscLabel']:setVisible(false)
    vars['runeDscLabel']:setVisible(false)
    vars['itemNameLabel']:setVisible(false)
    vars['sellBtn']:setVisible(false)
    vars['enhanceBtn']:setVisible(false)
    vars['locationBtn']:setVisible(false)
    vars['useBtn']:setVisible(false)

    vars['itemNode']:removeAllChildren()
    vars['itemNode']:setVisible(false)
    vars['sortBtn']:setVisible(false)
end

-------------------------------------
-- function clearSelectedItem
-- @brief
-------------------------------------
function UI_Inventory:clearSelectedItem()
    self.m_selectedItemUI = nil
    self.m_selectedItemData = nil

    self:clearItemInfo()
end

-------------------------------------
-- function setSelectedItem
-- @brief
-------------------------------------
function UI_Inventory:setSelectedItem(ui, data)
    if self.m_selectedItemUI then
        self.m_selectedItemUI.vars['highlightSprite']:setVisible(false)
    end

    self.m_selectedItemUI = ui
    self.m_selectedItemData = data

    self:clearItemInfo()

    if (ui == nil) then
        return
    end

    local tab = self.m_mainTabMgr.m_currTab
    if (not self.m_tTabClass[tab]) then
        return
    end

    self.m_tTabClass[tab]:onChangeSelectedItem(ui, data)
    cca.uiReactionSlow(ui.root, 0.72, 0.72)

    ui.vars['highlightSprite']:setVisible(true)

    -- 선택 판매 시 사용
    self.m_selectSellItemsUI:setSelectedItem(ui, data)
end

-------------------------------------
-- function response_itemSell
-- @brief
-------------------------------------
function UI_Inventory:response_itemSell(ret)
    if ret['deleted_rune_oids'] then
        self.m_tTabClass['rune']:refresh_tableView(ret['deleted_rune_oids'])
    end

    -- 테이블 뷰의 아이템 리스트 갱신
    for i,v in pairs(self.m_tTabClass) do
        -- 룬 타입은 별도로 처리
        if (i~='rune') then
            v:refresh_tableView()
        else
            self:refreshInventoryLabel()
        end
    end
end

-------------------------------------
-- function response_ticketUse
-- @brief
-------------------------------------
function UI_Inventory:response_ticketUse(ret)
    self.m_mainTabMgr.m_mTabData['rune']['first'] = true
    self.m_tTabClass['rune']:clearTabFirstInfo()
end