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
    UIManager:open(self, UIManager.POPUP)

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
    
        local before_ui = UI_DragonRunesBulkEquipItem(self, doid, 'before')
        vars['itemNode1']:addChild(before_ui.root)
        self.m_beforeUI = before_ui
    
        local after_ui = UI_DragonRunesBulkEquipItem(self, doid, 'after')
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
    local vars = self.vars
    
    vars['priceLabel']:setString(comma_value(self.m_price))    
end

-------------------------------------
-- function refreshPrice
-- @brief 골드 계산
-------------------------------------
function UI_DragonRunesBulkEquip:refreshPrice()
    local l_before_rune_list = self.m_beforeUI.m_lRoidList
    local l_after_rune_list = self.m_afterUI.m_lRoidList
    local total_price = 0    

    for slot_idx = 1, 6 do
        local before_roid = l_before_rune_list[slot_idx]
        local after_roid = l_after_rune_list[slot_idx]

        -- 전에 장착하지 않움, 후에 장착하지 않음
        if (before_roid == nil) and (after_roid == nil) then

        -- 전에 장착하지 않음, 후에 장착
        elseif (before_roid == nil) and (after_roid ~= nil) then
            local after_rune_obj = g_runesData:getRuneObject(after_roid)
            
            -- 다른 드래곤이 장착한 룬인 경우            
            if (after_rune_obj['owner_doid']) then
                local after_rune_grade = after_rune_obj['grade']
                local price = TableRuneGrade:getUnequipPrice(after_rune_grade)
                total_price = total_price + price
            end    

        -- 전에 장착, 후에 장착하지 않음
        elseif (before_roid ~= nil) and (after_roid == nil) then
            local before_rune_obj = g_runesData:getRuneObject(before_roid)    
            local before_rune_grade = before_rune_obj['grade']
            local price = TableRuneGrade:getUnequipPrice(before_rune_grade)
            total_price = total_price + price

        -- 전에 장착, 후에 장착
        else
            -- 전과 후가 다른 경우
            if (before_roid ~= after_roid) then
                local before_rune_obj = g_runesData:getRuneObject(before_roid)    
                local before_rune_grade = before_rune_obj['grade']
                local before_price = TableRuneGrade:getUnequipPrice(before_rune_grade)
                total_price = total_price + before_price

                local after_rune_obj = g_runesData:getRuneObject(after_roid)    
                -- 다른 드래곤이 장착한 룬인 경우            
                if (after_rune_obj['owner_doid']) then
                    local after_rune_grade = after_rune_obj['grade']
                    local after_price = TableRuneGrade:getUnequipPrice(after_rune_grade)
                    total_price = total_price + after_price
                end    
            end
        end

    end

    if (self.m_price ~= total_price) then
        self.m_price = total_price
        self:refresh()
    end
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
    local doid = self.m_doid
    local after_roid_list = self.m_afterUI.m_lRoidList
    local price = self.m_price
    local ui = UI_DragonRunesBulkEquipPopup(doid, after_roid_list, price)
    
    function close_cb()
        
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function simulateRune
-- @brief 룬 한개 장착
-------------------------------------
function UI_DragonRunesBulkEquip:simulateRune(slot_idx, roid)
    self.m_afterUI:simulateRune(slot_idx, roid)
    self:refreshPrice()
end

-------------------------------------
-- function simulateDragonRune
-- @brief 특정 드래곤의 룬 장착
-------------------------------------
function UI_DragonRunesBulkEquip:simulateDragonRune(doid)
    self.m_afterUI:simulateDragonRune(doid)
    self:refreshPrice()
end
   
-------------------------------------
-- function isEquipRune
-- @brief 현재 시뮬레이터상 장착된 룬인지
-------------------------------------
function UI_DragonRunesBulkEquip:isEquipRune(roid)
    local l_simulate_rune_list = self.m_afterUI.m_lRoidList

    for slot_idx = 1, 6 do
        if (l_simulate_rune_list[slot_idx]) and (l_simulate_rune_list[slot_idx] == roid) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function refreshRuneCheck
-- @brief UI_DragonRunesBulkEquipRuneTab의 테이블뷰 룬 카드 체크 표시 갱신
-------------------------------------
function UI_DragonRunesBulkEquip:refreshRuneCheck(slot_idx, roid)
    local ui = self.m_mTabData['rune']['ui']
    ui:refreshRuneCheck(slot_idx, roid)
end