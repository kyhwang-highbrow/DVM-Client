local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Inventory
-------------------------------------
UI_Inventory = class(PARENT, {
        m_mainTabMgr = 'UIC_TabManager',
        m_tTabClass = 'table',
        m_selectedItemUI = '',
        m_selectedItemData = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Inventory:init()
    local vars = self:load('inventory.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Inventory')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Inventory:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_QuestPopup'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('인벤토리')
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
        self.m_mainTabMgr:addTab('ticket', vars['ticketBtn'], vars['ticketNode'])
    

        self.m_mainTabMgr:setChangeTabCB(function(tab, first) self:onChangeMainTab(tab, first) end)

        self.m_mainTabMgr:setTab('rune')
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
    vars['runeSetLabel']:setVisible(false)
    vars['runeSubOptionLabel']:setVisible(false)
    vars['runeMainOptionLabel']:setVisible(false)
    vars['itemNameLabel']:setVisible(false)
    vars['sellBtn']:setVisible(false)
    vars['enhanceBtn']:setVisible(false)
    vars['locationBtn']:setVisible(false)

    vars['itemNode']:removeAllChildren()
    vars['itemNode']:setVisible(false)
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

    ui.vars['highlightSprite']:setVisible(true)
end

-------------------------------------
-- function request_itemSell
-- @brief
-------------------------------------
function UI_Inventory:request_itemSell(rune_oids, evolution_stones, fruits, cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_itemSell(ret, cb)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/inventory/sell')
    ui_network:setParam('uid', uid)
    ui_network:setParam('rune_oids', rune_oids)
    ui_network:setParam('evolution_stones', evolution_stones)
    ui_network:setParam('fruits', fruits)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function response_itemSell
-- @brief
-------------------------------------
function UI_Inventory:response_itemSell(ret, cb)
    -- server_info 정보를 갱신 (gold, evolution_stones, fruits)
    g_serverData:networkCommonRespone(ret)

    if ret['deleted_rune_oids'] then
        g_runesData:deleteRuneData_list(ret['deleted_rune_oids'])
        self.m_tTabClass['rune']:refresh_tableView(ret['deleted_rune_oids'])
    end

    -- 테이블 뷰의 아이템 리스트 갱신
    for i,v in pairs(self.m_tTabClass) do
        -- 룬 타입은 별도로 처리
        if (i~='rune') then
            v:refresh_tableView()
        end
    end

    if cb then
        cb(ret)
    end
end