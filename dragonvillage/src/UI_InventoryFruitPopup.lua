local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_InventoryFruitPopup
-------------------------------------
UI_InventoryFruitPopup = class(PARENT, {
        m_fruitBoardUI = 'fruit_board_02.ui',
        m_selectedFruitFullType = 'string',
        m_upgradeCount = 'number',
        m_lUpgradeCountBtn = 'list[button]',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InventoryFruitPopup:init()
    local vars = self:load('inventory_fruit_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- 열매 교환 갯수 (1, 5, 25, 50) 버튼
    vars['oneBtn']:registerScriptTapHandler(function() self:click_oneBtn() end)
    vars['fiveBtn']:registerScriptTapHandler(function() self:click_fiveBtn() end)
    vars['twentyFiveBtn']:registerScriptTapHandler(function() self:click_twentyFiveBtn() end)
    vars['fiftyBtn']:registerScriptTapHandler(function() self:click_fiftyBtn() end)

    self.m_lUpgradeCountBtn = {}
    self.m_lUpgradeCountBtn[1] = vars['oneBtn']
    self.m_lUpgradeCountBtn[5] = vars['fiveBtn']
    self.m_lUpgradeCountBtn[25] = vars['twentyFiveBtn']
    self.m_lUpgradeCountBtn[50] = vars['fiftyBtn']

    -- 열매 교환(열매 업그레이드) 버튼
    vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)
    
    vars['numberBeforeLabel']:setString('')
    vars['numberAfterLabel']:setString('')
    vars['priceLabel']:setString('')
    vars['beforeLabel']:setString('')
    vars['afterLabel']:setString('')

    self.m_upgradeCount = 0

    self:init_tableView()
    self:refresh()

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_InventoryFruitPopup')
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_InventoryFruitPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_InventoryFruitPopup'
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init_tableView
-- @brief 테이블뷰 초기화
-------------------------------------
function UI_InventoryFruitPopup:init_tableView()
    local table_view = self.vars['tableView']
    
    -- 관리를 위해 리스트에서 board 하나만을 사용
    local board, size = self:createBoard()

    -- board의 사이즈로 cell info를 설정
    table_view:setCellInfo(1, size)

    -- table view 리스트 update
    local items = {board}
    local create_ui_func = UI_InventoryFruitPopup.tableView_createUIFunc
    table_view:setItemInfo(items, create_ui_func)
    table_view:update()
end

-------------------------------------
-- function tableView_createUIFunc
-- @breif 테이블뷰 아이템 UI 생성
-------------------------------------
function UI_InventoryFruitPopup.tableView_createUIFunc(t_param)
    local cell = t_param['cell']
    local item = t_param['item'] -- fruit_board_02.ui

    item.root:setDockPoint(cc.p(0, 0))
    item.root:setAnchorPoint(cc.p(0, 0))
    cell:addChild(item.root)
end

-------------------------------------
-- function createBoard
-- @breif
-------------------------------------
function UI_InventoryFruitPopup:createBoard()
    local ui = UI()
    self.m_fruitBoardUI = ui
    local vars = ui:load('fruit_board_02.ui')
    local size = ui.root:getContentSize()

    -- boad가 스크롤 될 수 있도록 menu들의 swallow touch를 비활성화
    vars['atkPlusNode']:setSwallowTouch(false)
    vars['defPlusNode']:setSwallowTouch(false)
    vars['tacticPlusNode']:setSwallowTouch(false)

    -- 열매 이름 리스트 작성 (망강의 열매 reset은 제외)
    local t_data = g_fruitData.m_tData
    local l_fruit_full_type = {}
    for rarity,t in pairs(t_data) do
        for detailed_stats_type, value in pairs(t) do
            if (detailed_stats_type ~= 'reset') then
                local fruit_full_type = DataFruit:makeFruitFullType(rarity, detailed_stats_type)
                table.insert(l_fruit_full_type, fruit_full_type)
            end
        end
    end

    for _,fruit_full_type in ipairs(l_fruit_full_type) do
        -- 열매 버튼
        local button = self:getFruitButton(fruit_full_type)
        button:registerScriptTapHandler(function() self:click_fruitListItem(fruit_full_type) end)

        -- 열매 갯수 확인
        local label = self:getFruitLabelRefresh(fruit_full_type)
    end

    return ui, size
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_InventoryFruitPopup:click_exitBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    self:close()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_InventoryFruitPopup:refresh()
    if (not self.m_selectedFruitFullType) then
        return
    end

    local vars = self.vars

    do -- 초기화
        vars['fruitBeforeNode']:removeAllChildren()
        vars['fruitAfterNode']:removeAllChildren()
        vars['numberBeforeLabel']:setString('')
        vars['numberAfterLabel']:setString('')
        vars['gradeAfterLabel']:setString(Str('[등급]'))
        vars['priceLabel']:setString('')
        vars['beforeLabel']:setString('')
        vars['afterLabel']:setString('')
    end

    do -- 선택된 열매
        local table_fruit = TABLE:get('fruit')
        local fruit_full_type = self.m_selectedFruitFullType
        local t_fruit = table_fruit[fruit_full_type]

        -- 이름
        vars['fruitNameLabel']:setString('[' .. Str(t_fruit['t_name']) .. ']')

        -- 설명
        vars['beforeLabel']:setString(Str(t_fruit['t_desc']))

        -- 등급
        local rarity_str = DataFruit:fruitRarityNumToStr(t_fruit['rarity'])
        vars['gradeBeforeLabel']:setString('[' .. rarity_str .. ']')

        -- 아이콘
        local icon = IconHelper:getItemIcon(fruit_full_type)
        vars['fruitBeforeNode']:addChild(icon)

        -- 개수
        local need_fruit_count, need_gold = DataFruit:getUpgradeInfo(fruit_full_type)
        local cnt = g_fruitData:getFruitCount(fruit_full_type)

        if (need_fruit_count and need_gold) then
            vars['numberBeforeLabel']:setString(comma_value(cnt) .. '/' .. comma_value(need_fruit_count))
        else
            vars['numberBeforeLabel']:setString(comma_value(cnt))
        end

        -- 가격
        if need_gold then
            vars['priceLabel']:setString(comma_value(need_gold))
        end
    end


    -- 다음 등급 열매
    local next_fruit_full_type = DataFruit:getFruitNextRarity(self.m_selectedFruitFullType)
    if next_fruit_full_type then
        local table_fruit = TABLE:get('fruit')
        local fruit_full_type = next_fruit_full_type
        local t_fruit = table_fruit[fruit_full_type]

        if t_fruit then
            -- 설명
            vars['afterLabel']:setString(Str(t_fruit['t_desc']))

            -- 등급
            local rarity_str = DataFruit:fruitRarityNumToStr(t_fruit['rarity'])
            vars['gradeAfterLabel']:setString('[' .. rarity_str .. ']')

            -- 아이콘
            local icon = IconHelper:getItemIcon(fruit_full_type)
            vars['fruitAfterNode']:addChild(icon)

            -- 개수
            local cnt = g_fruitData:getFruitCount(fruit_full_type)
            --vars['numberAfterLabel']:setString(comma_value(cnt))
        end
    end

    vars['numberAfterLabel']:setString(comma_value(self.m_upgradeCount))
end

-------------------------------------
-- function click_fruitListItem
-- @breif
-------------------------------------
function UI_InventoryFruitPopup:click_fruitListItem(fruit_full_type)
    SoundMgr:playEffect('EFFECT', 'ui_button')
    if (self.m_selectedFruitFullType == fruit_full_type) then
        return
    end

    self.m_selectedFruitFullType = fruit_full_type

    self.m_upgradeCount = 0

    self:refresh()
    self:setUpgradeCount(1)
end

-------------------------------------
-- function setUpgradeCount
-- @breif
-------------------------------------
function UI_InventoryFruitPopup:setUpgradeCount(count)
    if (not self.m_selectedFruitFullType) then
        return false
    end

    if (count <= 0) then
        return false
    end

    local fruit_full_type = self.m_selectedFruitFullType

    local need_fruit_count, need_gold = DataFruit:getUpgradeInfo(fruit_full_type)

    if (not need_fruit_count) or (not need_gold) then
        return false
    end

    local total_need_count = count * need_fruit_count
    local cnt = g_fruitData:getFruitCount(fruit_full_type)

    --[[
    if (cnt < total_need_count) then
        return false
    end
    --]]

    self.m_upgradeCount = count

    self.vars['numberAfterLabel']:setString(comma_value(count))
    self.vars['priceLabel']:setString(comma_value(count * need_gold))

    do -- 버튼 상태 변경
        for _,button in pairs(self.m_lUpgradeCountBtn) do
            button:setEnabled(true)
        end
        self.m_lUpgradeCountBtn[count]:setEnabled(false)
    end

    return true
end

-------------------------------------
-- function click_oneBtn
-- @breif 열매 교환 갯수 버튼 1개
-------------------------------------
function UI_InventoryFruitPopup:click_oneBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    self:setUpgradeCount(1)
end

-------------------------------------
-- function click_fiveBtn
-- @breif 열매 교환 갯수 버튼 5개
-------------------------------------
function UI_InventoryFruitPopup:click_fiveBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    self:setUpgradeCount(5)
end

-------------------------------------
-- function click_twentyFiveBtn
-- @breif 열매 교환 갯수 버튼 25개
-------------------------------------
function UI_InventoryFruitPopup:click_twentyFiveBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    self:setUpgradeCount(25)
end

-------------------------------------
-- function click_fiftyBtn
-- @breif 열매 교환 갯수 버튼 50개
-------------------------------------
function UI_InventoryFruitPopup:click_fiftyBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    self:setUpgradeCount(50)
end

-------------------------------------
-- function click_upgradeBtn
-- @breif
-------------------------------------
function UI_InventoryFruitPopup:click_upgradeBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    
    if (not self.m_selectedFruitFullType) then
        return false
    end

    local fruit_full_type = self.m_selectedFruitFullType
    local count = self.m_upgradeCount

    local success, l_invalid_data = g_fruitData:upgradeFruit(fruit_full_type, count)

    if success then
        local curr_fruit_full_type = self.m_selectedFruitFullType
        local next_fruit_full_type = DataFruit:getFruitNextRarity(curr_fruit_full_type)

        self:getFruitLabelRefresh(curr_fruit_full_type)
        self:getFruitLabelRefresh(next_fruit_full_type)

        self:refresh()
    else
        if l_invalid_data then
            for _,t_invalid_data in ipairs(l_invalid_data) do
                UIManager:toastNotificationRed(t_invalid_data['msg'])
            end
        end
    end
end

-------------------------------------
-- function getFruitButton
-- @breif 열매 타입으로 해당 열매 버튼 리턴
-------------------------------------
function UI_InventoryFruitPopup:getFruitButton(fruit_full_type)
    local vars = self.m_fruitBoardUI.vars
    local luaname = (string.gsub(fruit_full_type, 'fruit_', '') .. '_btn')
    return vars[luaname]
end

-------------------------------------
-- function getFruitLabel
-- @breif 열매 타입으로 해당 열매 라벨 리턴
-------------------------------------
function UI_InventoryFruitPopup:getFruitLabel(fruit_full_type)
    local vars = self.m_fruitBoardUI.vars
    local luaname = (string.gsub(fruit_full_type, 'fruit_', '') .. '_label')
    return vars[luaname]
end

-------------------------------------
-- function getFruitLabelRefresh
-- @breif 열매 타입으로 해당 열매 갯수 갱신
-------------------------------------
function UI_InventoryFruitPopup:getFruitLabelRefresh(fruit_full_type)
    local cnt = g_fruitData:getFruitCount(fruit_full_type)
    local label = self:getFruitLabel(fruit_full_type)
    label:setString(tostring(cnt))
end