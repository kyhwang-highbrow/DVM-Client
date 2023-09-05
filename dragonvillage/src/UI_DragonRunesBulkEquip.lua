local PARENT = class(UI_DragonManage_Base, ITabUI:getCloneTable())

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
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonRunesBulkEquip:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonRunesBulkEquip'
    self.m_titleStr = nil
    self.m_invenType = 'rune'
    self.m_bShowInvenBtn = true 
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

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
    local doid = self.m_doid

    do -- 배경
        local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
        local attr = dragon_obj:getAttr()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    -- 시뮬레이션 전 후 UI 생성
    do
        local before_ui = UI_DragonRunesBulkEquipItem(self, doid, 'before')
        vars['itemNode1']:addChild(before_ui.root)
        self.m_beforeUI = before_ui
    
        local after_ui = UI_DragonRunesBulkEquipItem(self, doid, 'after')
        vars['itemNode2']:addChild(after_ui.root)
        self.m_afterUI = after_ui
    end

    vars['priceLabel'] = NumberLabel(vars['priceLabel'], 0, 0.3)
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
    
    -- 룬을 출력하는 TableView(runeTableViewNode)가 relative size의 영향을 받는다.
    -- UI가 생성되고 부모 노드에 addChild가 된 후에 해당 노드의 크기가 결정되므로 외부에서 호출하도록 한다.
    -- setTab -> onChangeTab -> initTableView 의 순서로 TableView가 생성됨.
    rune_tab:setParentAndInit(vars['indivisualTabMenu'])
    dragon_tab:setParentAndInit(vars['indivisualTabMenu'])

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

    do
        local user_level = g_userData:get('lv')
        local free_level = g_constant:get('INGAME', 'FREE_RUNE_UNEQUIP_USER_LV')
        if user_level <= free_level then
            local text = Str('{@yellow}75레벨 이하 룬 해제비용 없음{@}')
            local node = self:getBubbleText(text)

            node:setPositionX(0)
            node:setPositionY(50)

            vars['equipBtn']:addChild(node)
        end
    end
end

-------------------------------------
-- function getBubbleText
-------------------------------------
function UI_DragonRunesBulkEquip:getBubbleText(txt_str)
	-- 베이스 노드
	local node = cc.Node:create()
	node:setDockPoint(cc.p(0.5, 0.5))
	node:setAnchorPoint(cc.p(0.5, 0.5))

	-- 말풍선 프레임
	local frame = cc.Scale9Sprite:create('res/ui/frames/event_0202.png')
	frame:setDockPoint(cc.p(0.5, 0.5))
	frame:setAnchorPoint(cc.p(0.5, 0.5))
    --frame:setScaleX(-1)


	-- 텍스트 (rich_label)
	local rich_label = UIC_RichLabel()
    rich_label:setString(txt_str)
    rich_label:setFontSize(20)
    rich_label:setDimension(500, 70)
    rich_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	rich_label:setDockPoint(cc.p(0.5, 0.5))
    rich_label:setAnchorPoint(cc.p(0.5, 0.5))
	rich_label:setPosition(0, 5)
    --rich_label.m_node:setScaleX(-1)

	-- label 사이즈로 프레임 조정
	local width = math_max(226, rich_label:getStringWidth() + 50)
	local size = frame:getContentSize()
	frame:setNormalSize(width, size['height'] + 10)

	-- addChild
	frame:addChild(rich_label.m_node)
	node:addChild(frame)

	-- fade out을 위해 설정
	doAllChildren(node, function(node) node:setCascadeOpacityEnabled(true) end)

	return node
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunesBulkEquip:refresh()
    local vars = self.vars
    
    vars['priceLabel']:setNumber(self.m_price)    
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
        local before_roid = l_before_rune_list[slot_idx] or ''
        local after_roid = l_after_rune_list[slot_idx] or ''

        -- 전에 장착하지 않움, 후에 장착하지 않음
        if (before_roid == '') and (after_roid == '') then

        -- 전에 장착하지 않음, 후에 장착
        elseif (before_roid == '') and (after_roid ~= '') then
            local after_rune_obj = g_runesData:getRuneObject(after_roid)
            
            -- 다른 드래곤이 장착한 룬인 경우            
            if (after_rune_obj['owner_doid']) then
                local after_rune_grade = after_rune_obj['grade']
                local price = TableRuneGrade:getUnequipPrice(after_rune_grade)
                total_price = total_price + price
            end    

        -- 전에 장착, 후에 장착하지 않음
        elseif (before_roid ~= '') and (after_roid == '') then
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

    -- 룬 할인 이벤트
	local dc_value = g_hotTimeData:getDiscountEventValue('rune')
    local user_level = g_userData:get('lv')
    local free_level = g_constant:get('INGAME', 'FREE_RUNE_UNEQUIP_USER_LV')

	if (dc_value) then
		total_price = total_price * (1 - (dc_value / 100))
	end

    if user_level <= free_level then
        total_price = 0
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


    -- 룬 변화가 있는지 확인
    local b_is_change = false
    local l_before_rune_list = self.m_beforeUI.m_lRoidList
    local l_after_rune_list = self.m_afterUI.m_lRoidList

    for slot_idx = 1,6 do
        local before_roid = l_before_rune_list[slot_idx] or ''
        local after_roid = l_after_rune_list[slot_idx] or ''
        if (before_roid ~= after_roid) then
            b_is_change = true
            break
        end
    end

    if (b_is_change == false) then
        UIManager:toastNotificationRed(Str('변경된 룬이 없습니다.'))
        return
    end
    
    -- 골드가 충분히 있는지 확인
    local need_gold = self.m_price
    if (not ConfirmPrice('gold', need_gold)) then -- 골드가 부족한경우 상점이동 유도 팝업이 뜬다. (ConfirmPrice함수 안에서)
	    return
    end

    local function finish_cb()
        -- 시뮬레이터 before, after 갱신
        self.m_beforeUI:resetRoidList()
        self.m_afterUI:resetRoidList()

        -- rune, dragon tab 갱신
        local rune_tab_ui = self.m_mTabData['rune']['ui']
        rune_tab_ui:initTableView()
        local dragon_tab_ui = self.m_mTabData['dragon']['ui']
        dragon_tab_ui:initTableView()

        -- 돈 계산 
        self:refreshPrice()
    
        self.m_bDirty = true
    end

    local ui = UI_DragonRunesBulkEquipPopup(doid, after_roid_list, need_gold, finish_cb)
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

-------------------------------------
-- function changeRuneSlot
-- @brief UI_DragonRunesBulkEquipRuneTab 의 테이블뷰 룬 슬롯 변경
-------------------------------------
function UI_DragonRunesBulkEquip:changeRuneSlot(slot_idx)
    local ui = self.m_mTabData['rune']['ui']
    ui:setTab(slot_idx)
end

-------------------------------------
-- function focusSlotIndex
-------------------------------------
function UI_DragonRunesBulkEquip:getRuneSlot()
    local ui = self.m_mTabData['rune']['ui']
    local slot_idx = ui.m_currTab
    return slot_idx
end

-------------------------------------
-- function focusSlotIndex
-------------------------------------
function UI_DragonRunesBulkEquip:focusSlotIndex(slot_idx)
    self.m_beforeUI:focusSlotIndex(slot_idx)
    self.m_afterUI:focusSlotIndex(slot_idx)
end