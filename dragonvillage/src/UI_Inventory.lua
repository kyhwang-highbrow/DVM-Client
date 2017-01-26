local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Inventory
-------------------------------------
UI_Inventory = class(PARENT, {
        m_mainTabMgr = 'UIC_TabManager',
        m_tTabClass = 'table',
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
    --vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Inventory:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Inventory:click_exitBtn()
    self:close()
end

-------------------------------------
-- function onChangeMainTab
-------------------------------------
function UI_Inventory:onChangeMainTab(tab, first)
    if (not self.m_tTabClass[tab]) then
        return
    end

    self.m_tTabClass[tab]:onEnterInventoryTab(first)
end