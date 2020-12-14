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

-- 모든 탭에 일괄적용하기 위해
UI_Inventory.CARD_SCALE = 0.63
UI_Inventory.CARD_CELL_SIZE = cc.size(97, 97)

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
    self.m_titleStr = nil -- 인벤 확장 버튼 있으므로 타이틀 삭제
    self.m_bShowInvenBtn = true 
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Inventory:initUI()
    local vars = self.vars

    do
        self.m_tTabClass = {}
        self.m_tTabClass['material'] = UI_InventoryTabEvolutionStone(self)
        self.m_tTabClass['fruit'] = UI_InventoryTabFruit(self)
        self.m_tTabClass['transform'] = UI_InventoryTabTransform(self)
        self.m_tTabClass['egg'] = UI_InventoryTabEgg(self)
    end


    do
        self.m_mainTabMgr = UIC_TabManager()
        self.m_mainTabMgr:addTabAuto('material', vars, vars['materialNode'])
        self.m_mainTabMgr:addTabAuto('fruit', vars, vars['fruitNode'])
        self.m_mainTabMgr:addTabAuto('transform', vars, vars['transformNode'])
        self.m_mainTabMgr:addTabAuto('egg', vars, vars['eggNode'])
    
		
        self.m_mainTabMgr:setChangeTabCB(function(tab, first) self:onChangeMainTab(tab, first) end)

        self.m_mainTabMgr:setTab('material')
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Inventory:initButton()
    local vars = self.vars
    vars['sortBtn']:registerScriptTapHandler(function() self:click_sortBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Inventory:refresh()
    local vars = self.vars
    self:clearItemInfo()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Inventory:click_exitBtn()
	g_highlightData:saveNewDoidMap()
    self:close()
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
    vars['itemNameLabel']:setVisible(false)
    vars['sellBtn']:setVisible(false)
    vars['enhanceBtn']:setVisible(false)
    vars['locationBtn']:setVisible(false)
    vars['combineBtn']:setVisible(false)
    vars['useBtn']:setVisible(false)
    vars['itemDscNode2']:setVisible(false)
    vars['runeDscNode']:setVisible(false)
    vars['itemNode']:removeAllChildren()
    vars['itemNode']:setVisible(false)
    vars['sortBtn']:setVisible(false)
end

-------------------------------------
-- function clearSelectedItem
-- @brief
-------------------------------------
function UI_Inventory:clearSelectedItem(skip_clear_info)
    self.m_selectedItemUI = nil
    self.m_selectedItemData = nil

    if (not skip_clear_info) then
        self:clearItemInfo()
    end
end

-------------------------------------
-- function setSelectedItem
-- @brief
-------------------------------------
function UI_Inventory:setSelectedItem(ui, data)
    if (ui == nil) then
        return
    end
    
    if self.m_selectedItemUI then
        self.m_selectedItemUI:setHighlightSpriteVisible(false)
    end

    self.m_selectedItemUI = ui
    self.m_selectedItemData = data

    self:clearItemInfo()


    local tab = self.m_mainTabMgr.m_currTab
    if (not self.m_tTabClass[tab]) then
        return
    end

    self.m_tTabClass[tab]:onChangeSelectedItem(ui, data)
    cca.uiReactionSlow(ui.root, UI_Inventory.CARD_SCALE, UI_Inventory.CARD_SCALE)

    ui:setHighlightSpriteVisible(true)

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
        end
    end
end

-------------------------------------
-- function response_ticketUse
-- @brief
-------------------------------------
function UI_Inventory:response_ticketUse(ret)
    if self.m_mainTabMgr.m_mTabData['rune'] then
        self.m_mainTabMgr.m_mTabData['rune']['first'] = true
    end

    if self.m_tTabClass['rune'] then
        self.m_tTabClass['rune']:clearTabFirstInfo()
    end
end