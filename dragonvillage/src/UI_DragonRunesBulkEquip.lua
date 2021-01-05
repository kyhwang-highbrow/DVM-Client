local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_DragonRunesBulkEquip
-------------------------------------
UI_DragonRunesBulkEquip = class(PARENT,{
        m_doid = 'string', 

        m_beforeUI = 'UI_DragonRunesBulkEquipItem',
        m_afterUI = 'UI_DragonRunesBulkEquipItem',

        m_price = 'number', -- 현재까지 필요한 가격

        m_bDirty = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunesBulkEquip:init(doid)
    self.m_doid = doid
    self.m_price = 0
    
    self.m_bDirty = false

    local vars = self:load('dragon_rune_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_cancelBtn() end, 'UI_DragonRunesBulkEquip')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()

    self:initTab()

    self:initButton()

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunesBulkEquip:initUI()
    local vars = self.vars
    
    -- 시뮬레이션 전 후 UI 생성
    do
        local doid = self.m_doid
    
        local before_ui = UI_DragonRunesBulkEquipItem(doid, 'before')
        vars['itemNode1']:addChild(before_ui.root)
        self.m_beforeUI = before_ui
    
        local after_ui = UI_DragonRunesBulkEquipItem(doid, 'after')
        vars['itemNode2']:addChild(after_ui.root)
        self.m_afterUI = after_ui
    end
end

-------------------------------------
-- function initTab
-- @brief type : rune, dragon
-------------------------------------
function UI_DragonRunesBulkEquip:initTab()
    local vars = self.vars
    local type = 'rune'

    local rune_tab = UI_DragonRunesBulkEquipRuneTab(self)
    local dragon_tab = UI_DragonRunesBulkEquipDragonTab(self)
    
    vars['indivisualTabMenu']:addChild(rune_tab.root)
    vars['indivisualTabMenu']:addChild(dragon_tab.root)
    
    self:addTabWithTabUIAndLabel('rune', vars['runeTabBtn'], vars['runeTabLabel'], rune_tab)            -- 룬
    self:addTabWithTabUIAndLabel('dragon', vars['dragonTabBtn'], vars['dragonTabLabel'], dragon_tab)    -- 드래곤

    self:setTab(type)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesBulkEquip:initButton()
    local vars = self.vars

    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['equipBtn']:registerScriptTapHandler(function() self:click_equipBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunesBulkEquip:refresh()

end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_DragonRunesBulkEquip:click_cancelBtn()
    if (self.m_bDirty == false) then
        self.m_closeCB = nil
    end
    
    self:close()
end

-------------------------------------
-- function click_equipBtn
-------------------------------------
function UI_DragonRunesBulkEquip:click_equipBtn()
    
    self:close()
end

-------------------------------------
-- function simulateRune
-- @brief 룬 한개 장착
-------------------------------------
function UI_DragonRunesBulkEquip:simulateRune(roid)
    self.m_afterUI:simulateRune(roid)
end

-------------------------------------
-- function simulateDragonRune
-- @brief 특정 드래곤의 룬 장착
-------------------------------------
function UI_DragonRunesBulkEquip:simulateDragonRune(doid)
    self.m_afterUI:simulateDragonRune(doid)
end
