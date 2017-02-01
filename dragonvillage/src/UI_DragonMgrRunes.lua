local PARENT = class(UI_DragonManage_Base, ITabUI:getCloneTable())

local l_rune_slot_name = {}
l_rune_slot_name[1] = 'bellaria'
l_rune_slot_name[2] = 'tutamen'
l_rune_slot_name[3] = 'cimelium'

local l_rune_slot_idx = {}
for i,v in pairs(l_rune_slot_name) do
    l_rune_slot_idx[v] = i
end

-------------------------------------
-- class UI_DragonMgrRunes
-------------------------------------
UI_DragonMgrRunes = class(PARENT,{
        m_bChangeDragonList = 'boolean',
        m_usedRuneData = 'table',
        m_selectedRuneData = 'table',

        -- 테이블 뷰
        m_mTableViewListMap = 'map',

        -- 갱신 여부 확인용
        m_refreshFlag_selectedDoid = 'string',
        m_refreshFlag_mRuneSlotDoid = 'map',
        m_refreshFlag_selectedRoid = 'string',

        m_runeSortManager = 'RuneSortManager',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonMgrRunes:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonMgrRunes'
    self.m_bVisible = true or false
    self.m_titleStr = Str('룬') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMgrRunes:init(doid, slot_idx)
    self.m_bChangeDragonList = false
    self.m_mTableViewListMap = {}
    self.m_refreshFlag_selectedDoid = nil
    self.m_refreshFlag_mRuneSlotDoid = {}
    self.m_refreshFlag_selectedRoid = nil

    local vars = self:load('dragon_rune.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonMgrRunes')

    self:sceneFadeInAction()

    -- 정렬
    self.m_runeSortManager = RuneSortManager()

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)

    self:initUI_runeTab(slot_idx) -- 룬 Tab 설정
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonMgrRunes:initUI()
    local vars = self.vars
    self:init_dragonTableView()

    -- 미구현인 부분 visible off
    vars['selectLockBtn']:setVisible(false)
    vars['useLockBtn']:setVisible(false)
    vars['binBtn']:setVisible(false)
end

-------------------------------------
-- function initUI_runeTab
-- @brief 룰 슬롯 버튼 처리
-------------------------------------
function UI_DragonMgrRunes:initUI_runeTab(slot_idx)
    local vars = self.vars
    slot_idx = slot_idx or 1
    self:addTab(l_rune_slot_name[1], vars['runeSlotBtn1'], vars['runeSlotSelectSprite1'], vars[l_rune_slot_name[1] .. 'TableViewNode'])
    self:addTab(l_rune_slot_name[2], vars['runeSlotBtn2'], vars['runeSlotSelectSprite2'], vars[l_rune_slot_name[2] .. 'TableViewNode'])
    self:addTab(l_rune_slot_name[3], vars['runeSlotBtn3'], vars['runeSlotSelectSprite3'], vars[l_rune_slot_name[3] .. 'TableViewNode'])
    self:setTab(l_rune_slot_name[slot_idx])
end

-------------------------------------
-- function onChangeTab
-- @brief 룬 슬롯 탭이 변경되었을 때
--        'bellaria', 'tutamen', 'cimelium'
-------------------------------------
function UI_DragonMgrRunes:onChangeTab(tab)
    local rune_slot_type = tab
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local t_runes = t_dragon_data['runes']
    local roid = t_runes[rune_slot_type]

    local vars = self.vars

    -- 재료 리스트뷰 초기화
    self:init_runeTableView(rune_slot_type)

    -- 장착중인 룬 정보 갱신
    self:refresh_useMenu()

    -- 선택중인 룬 정보 갱신
    self:setSelectedRuneData(nil)

    do
        local table_view = self.m_mTableViewListMap[rune_slot_type]
        self.m_runeSortManager:clearTableView(table_view)
        self.m_runeSortManager:changeSort()
        table_view:relocateContainer(false)
    end
end


function UI_RuneCard(t_rune_data)
    local rid = t_rune_data['rid']
    local roid = t_rune_data['id']
    local t_rune_information = g_runesData:getRuneInfomation(roid)
    local item_count = 1
    local ui = UI_ItemCard(rid, item_count, t_rune_information)
    return ui
end

-------------------------------------
-- function init_runeTableView
-------------------------------------
function UI_DragonMgrRunes:init_runeTableView(rune_slot_type)
    if (not self.m_mTableViewListMap[rune_slot_type]) then
        local node = self.vars[rune_slot_type .. 'TableViewNode']
        --node:removeAllChildren()

        local l_item_list = g_runesData:getUnequippedRuneList(rune_slot_type)

        -- 생성 콜백
        local function create_func(ui, data)
            ui.root:setScale(0.66)
            ui.vars['clickBtn']:registerScriptTapHandler(function()
                local t_rune_data = data
                self:setSelectedRuneData(t_rune_data)
            end)

            -- 선택중인 아이콘일 경우 하일라이트
            if self.m_selectedRuneData and (self.m_selectedRuneData['id'] == data['id']) then
                ui.vars['highlightSprite']:setVisible(true)
            end
        end

        -- 테이블 뷰 인스턴스 생성
        local table_view_td = UIC_TableViewTD(node)
        table_view_td.m_cellSize = cc.size(103, 103)
        table_view_td.m_nItemPerCell = 4
        table_view_td:setCellUIClass(UI_RuneCard, create_func)
        local skip_update = true
        table_view_td:setItemList(l_item_list, skip_update)

        self.m_mTableViewListMap[rune_slot_type] = table_view_td
    end

    --[[
    -- 첫 번째 룬을 선택 (자동)
    local table_view_td = self.m_mTableViewListMap[rune_slot_type]
    if (not self.m_selectedRuneData) or (not table_view_td:getItem(self.m_selectedRuneData['id'])) then
        local t_first_item = table_view_td.m_itemList[1]
        local t_first_rune_data = (t_first_item and t_first_item['data'])
        self:setSelectedRuneData(t_first_rune_data)
    end
    --]]
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonMgrRunes:initButton()
    local vars = self.vars
    
    -- 장착
    vars['equipBtn']:registerScriptTapHandler(function() self:click_equipBtn() end)

    -- 장착 해제
    vars['removeBtn']:registerScriptTapHandler(function() self:click_removeBtn() end)

    -- 강화 버튼
    vars['useEnhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn('used') end)
    vars['selectEnhance']:registerScriptTapHandler(function() self:click_enhanceBtn('selected') end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMgrRunes:refresh()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars


    do -- 선택중인 드래곤 아이콘
        if (self.m_refreshFlag_selectedDoid ~= t_dragon_data['id']) then
            local node = vars['dragonNode']
            node:removeAllChildren()
            local dragon_card = UI_DragonCard(t_dragon_data)
            node:addChild(dragon_card.root)

            -- UI 반응 액션
            cca.uiReactionSlow(dragon_card.root)
            self.m_refreshFlag_selectedDoid = t_dragon_data['id']
        end        
    end
    
    do -- 룬 아이콘
        local t_runes = t_dragon_data['runes']
        
        for i,slot_name in ipairs(l_rune_slot_name) do
            local roid = t_runes[slot_name]

            -- 변경 여부 체크
            if (self.m_refreshFlag_mRuneSlotDoid[slot_name] ~= roid) then
                vars['runeSlot' .. i]:removeAllChildren()

                if roid and (roid ~= '') then
                    local t_rune_infomation = g_runesData:getRuneInfomation(roid)
                    local item_card = UI_ItemCard(t_rune_infomation['rid'], 1, t_rune_infomation)
                    item_card.vars['clickBtn']:setEnabled(false)
                    vars['runeSlot' .. i]:addChild(item_card.root)

                    -- UI 반응 액션
                    cca.uiReactionSlow(item_card.root)
                end
                self.m_refreshFlag_mRuneSlotDoid[slot_name] = roid
            end
        end
    end

    self:refresh_useMenu()
    self:refresh_selectRuneSetData(t_dragon_data, self.m_selectedRuneData)
end

-------------------------------------
-- function getRuneIconInMaterialTableView
-- @brief
-------------------------------------
function UI_DragonMgrRunes:getRuneIconInMaterialTableView(roid)
    for slot_type,table_view in pairs(self.m_mTableViewListMap) do
        local item = table_view:getItem(roid)
        if item then
            return item['ui']
        end
    end

    return nil
end

-------------------------------------
-- function setSelectedRuneData
-- @brief 인벤상에서 선택된 룬
-------------------------------------
function UI_DragonMgrRunes:setSelectedRuneData(t_rune_data)
    -- 선택 아이콘 제거
    if self.m_selectedRuneData then
        local roid = self.m_selectedRuneData['id']
        local ui = self:getRuneIconInMaterialTableView(roid)
        if ui then
            ui.vars['highlightSprite']:setVisible(false)
        end
    end

    self.m_selectedRuneData = t_rune_data
    self:refresh_selectMenu(t_rune_data)

    -- 선택 아이콘 표시
    if self.m_selectedRuneData then
        local roid = self.m_selectedRuneData['id']
        local ui = self:getRuneIconInMaterialTableView(roid)
        if ui then
            ui.vars['highlightSprite']:setVisible(true)
        end
    end
end

-------------------------------------
-- function refresh_useMenu
-- @brief 드래곤에 장착된 룬의 정보 표시
-------------------------------------
function UI_DragonMgrRunes:refresh_useMenu()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local t_runes = t_dragon_data['runes']
    local rune_slot_type = self.m_currTab
    local roid = t_runes[rune_slot_type]

    local vars = self.vars

    if roid and (roid ~= '') then
        vars['useMenu']:setVisible(true)

        local with_set_data = true
        local t_rune_data = g_runesData:getRuneData(roid, with_set_data)
        local t_rune_information = t_rune_data['information']
        vars['useRuneNameLabel']:setString(t_rune_information['full_name'])

        do -- 룬 아이콘
            vars['useRuneNode']:removeAllChildren()
            local icon = UI_RuneCard(t_rune_data)
            vars['useRuneNode']:addChild(icon.root)

            cca.uiReactionSlow(icon.root)
        end

        -- 주옵션 문자열
        local main_option_str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['mopt'])
        vars['useMainOptionLabel']:setString(main_option_str)

        -- 부옵션 문자열
        local sub_option_str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['sopt'])
        vars['useSubOptionLabel']:setString(sub_option_str)

        -- 세트 효과
        local t_rune_set = t_rune_data['rune_set']
        if t_rune_set then
            vars['useRuneSetLabel']:setVisible(true)
            local str = TableRuneStatus:makeRuneSetOptionStr(t_rune_set)
            vars['useRuneSetLabel']:setString(str)
        else
            vars['useRuneSetLabel']:setVisible(false)
        end

        -- 강화 버튼
        vars['useEnhanceBtn']:setVisible(not t_rune_information['is_max_lv'])

        self.m_usedRuneData = t_rune_data

        cca.uiReactionSlow(vars['useMenu'], 1, 1, 0.98)
    else
        self.m_usedRuneData = nil
        vars['useMenu']:setVisible(false)
    end
end

-------------------------------------
-- function refresh_selectMenu
-- @brief 인벤상에서 선택된 룬의 정보 표시
-------------------------------------
function UI_DragonMgrRunes:refresh_selectMenu(t_rune_data)
    local roid = (t_rune_data and t_rune_data['id'] or nil)

    local prev_roid = self.m_refreshFlag_selectedRoid
    self.m_refreshFlag_selectedRoid = roid

    local vars = self.vars

    if t_rune_data then
        vars['selectMenu']:setVisible(true)
    else
        vars['selectMenu']:setVisible(false)
        return
    end

    if (prev_roid == roid) then
        return
    end

    do -- 룬 아이콘
        vars['selectRuneNode']:removeAllChildren()
        local icon = UI_RuneCard(t_rune_data)
        vars['selectRuneNode']:addChild(icon.root)

        cca.uiReactionSlow(icon.root)
    end

    do -- 룬 풀 네임
        local roid = t_rune_data['id']
        local t_rune_infomation = g_runesData:getRuneInfomation(roid)
        vars['removeRuneNameLabel']:setString(t_rune_infomation['full_name'])
    end

    cca.uiReactionSlow(vars['selectMenu'], 1, 1, 0.98)

    -- selectLockSprite
    -- selectLockBtn
    -- equipBtn
    -- selectEnhance
    -- selectSubOptionLabel
    -- selectMainOptionLabel
    -- selectRuneSetLabel
    -- removeRuneNameLabel

    local t_rune_information = t_rune_data['information']

    -- 주옵션 문자열
    local main_option_str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['mopt'])
    vars['selectMainOptionLabel']:setString(main_option_str)

    -- 부옵션 문자열
    local sub_option_str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['sopt'])
    vars['selectSubOptionLabel']:setString(sub_option_str)

    -- 세트 효과
    local t_dragon_data = self.m_selectDragonData
    self:refresh_selectRuneSetData(t_dragon_data, t_rune_data)

    -- 강화 버튼
    vars['selectEnhance']:setVisible(not t_rune_information['is_max_lv'])
end

-------------------------------------
-- function refresh_selectRuneSetData
-- @brief 인벤상에서 선택된 룬을 장착하면 발동될 세트 효과 체크
-------------------------------------
function UI_DragonMgrRunes:refresh_selectRuneSetData(t_dragon_data, t_rune_data)
    if (not t_rune_data) then
        return
    end

    local vars = self.vars
    local runes_map = clone(t_dragon_data['runes'])
    
    local rune_slot = t_rune_data['type']
    local roid = t_rune_data['id']
    runes_map[rune_slot] = roid

    local l_rune_roid = {}
    for i,v in pairs(runes_map) do
        table.insert(l_rune_roid, v)
    end
    local t_rune_set = g_runesData:makeRuneSetData_usingRoid(l_rune_roid[1], l_rune_roid[2], l_rune_roid[3])

    if t_rune_set then
        vars['selectRuneSetLabel']:setVisible(true)
        local str = TableRuneStatus:makeRuneSetOptionStr(t_rune_set)
        vars['selectRuneSetLabel']:setString(str)
    else
        vars['selectRuneSetLabel']:setVisible(false)
    end
end

-------------------------------------
-- function refresh_currDragonInfo
-- @brief 왼쪽 정보(현재 진화 단계)
-------------------------------------
function UI_DragonMgrRunes:refresh_currDragonInfo(t_dragon_data, t_dragon)
    local vars = self.vars
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonMgrRunes:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_equipBtn
-- @brief 인벤에 있는 룬을 장착 (혹은 교체)
-------------------------------------
function UI_DragonMgrRunes:click_equipBtn()
    local t_dragon_data = self.m_selectDragonData
    local t_rune_data = self.m_selectedRuneData

    if (not t_dragon_data) or (not t_rune_data) then
        return
    end

    local doid = t_dragon_data['id']
    local roid = t_rune_data['id']
    local rid = t_rune_data['rid']
    local slot = t_rune_data['type']

    local function cb_func(ret)
        -- 장착으로 인해 변경된 룬 정보 처리
        self:solveModifiedRunes_tableView(ret['modified_runes'])

        -- 드래곤 정보 갱신
        self:setSelectDragonDataRefresh()
        self:refresh()

        self:refresh_useMenu()
        self:setSelectedRuneData(nil)
        

        self.m_bChangeDragonList = true
    end

    -- 슬롯이 비어있으면 "장착"
    if (not t_dragon_data['runes'][slot]) or (t_dragon_data['runes'][slot] == '') then
        g_runesData:requestRuneEquip(doid, roid, cb_func)

    -- 슬롯이 비어있지 않으면 "교체"
    else
        local function yes_cb()
            g_runesData:requestRuneEquip(doid, roid, cb_func)
        end
        local msg = Str('새로운 룬을 장착하면\n착용되어 있는 룬은 파괴됩니다.\n\n장착하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, yes_cb)
    end
end

-------------------------------------
-- function click_removeBtn
-- @brief 룬 장착 해제
-------------------------------------
function UI_DragonMgrRunes:click_removeBtn()
    local t_dragon_data = self.m_selectDragonData
    local t_rune_data = self.m_usedRuneData

    if (not t_dragon_data) or (not t_rune_data) then
        return
    end
    
    local doid = t_dragon_data['id']
    local roid = t_rune_data['id']
    local rid = t_rune_data['rid']
    local slot = t_rune_data['type']

    local function cb_func(ret)
        -- 장착으로 인해 변경된 룬 정보 처리
        self:solveModifiedRunes_tableView({ret['rune']})

        -- 드래곤 정보 갱신
        self:setSelectDragonDataRefresh()
        self:refresh()

        self:refresh_useMenu()

        -- 장착 해제한 룬을 선택
        local t_rune_data = g_runesData:getRuneData(roid)
        self:setSelectedRuneData(t_rune_data)

        self.m_bChangeDragonList = true
    end

    local fee = TableRune:getRuneUnequipFee(rid)

    -- 자수정이 부족할 경우
    if (g_userData:get('cash') < fee) then
        local msg = Str('자수정이 부족합니다.\n상점으로 이동하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, openShopPopup)

    -- 자수정이 부족하지 않은 경우
    else
        local function yes_cb()
            g_runesData:requestRuneUnequip(doid, roid, slot, cb_func)
        end
        local msg = Str('룬을 장착 해제하려면\n{1}개의 자수정이 소모됩니다.\n해제하시겠습니까?', fee)
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, yes_cb)
    end
end

-------------------------------------
-- function click_enhanceBtn
-- @brief 룬 강화
-------------------------------------
function UI_DragonMgrRunes:click_enhanceBtn(type)
    local ui
    if (type == 'used') then
        ui = UI_RuneEnchantPopup(self.m_usedRuneData)

    elseif (type == 'selected') then
        ui = UI_RuneEnchantPopup(self.m_selectedRuneData)

    else
        error('type : ' .. type)

    end
    
    local function close_cb()
        self:enchantFinishCB(ui, type)
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function enchantFinishCB
-- @brief 룬 강화 UI 종료 콜백
-------------------------------------
function UI_DragonMgrRunes:enchantFinishCB(ui, type)
    if (not ui.m_bDirtyRuneData) then
        return
    end
    
    -- 삭제된 룬 테이블 뷰에서 삭제
    self:solveDeletedRunes_tableView(ui.m_lDeletedRuneRoid)

    -- 장착되어있는 룬 정보 갱신을 위해 초기화
    if (type == 'used') then
        local slot_type = self.m_usedRuneData['type']
        self.m_refreshFlag_mRuneSlotDoid[slot_type] = nil
        self:refresh_useMenu()

    elseif (type == 'selected') then
        self.m_refreshFlag_selectedRoid = nil

        local roid = self.m_selectedRuneData['id']
        local t_rune_data = g_runesData:getRuneData(roid)
        self:setSelectedRuneData(t_rune_data)
        self:refresh_materialTableViewRuneIcon(t_rune_data)

    else
        error('type : ' .. type)
    end

    -- 드래곤 정보 갱신
    self:setSelectDragonDataRefresh()
    self:refresh()

    self.m_bChangeDragonList = true
end

-------------------------------------
-- function refresh_materialTableViewRuneIcon
-- @brief
-------------------------------------
function UI_DragonMgrRunes:refresh_materialTableViewRuneIcon(t_rune_data)
    local roid = t_rune_data['id']

    local l_modified_slot = {}

    for slot_type,table_view in pairs(self.m_mTableViewListMap) do
        local item = table_view:getItem(roid)
        if item then
            table_view:addItem(t_rune_data['id'], t_rune_data)
            l_modified_slot[slot_type] = true
        end
    end

    -- 변경된 룬 타입의 테이블뷰를 갱신
    for slot_type,_ in pairs(l_modified_slot) do
        local table_view_td = self.m_mTableViewListMap[slot_type]
        self.m_runeSortManager:changeSort()
    end
end

-------------------------------------
-- function solveModifiedRunes_tableView
-- @brief
-------------------------------------
function UI_DragonMgrRunes:solveModifiedRunes_tableView(l_modified_runes)
    if (not l_modified_runes) then
        return
    end

    local l_modified_slot = {}

    -- 변경된 룬을 테이블 뷰에서 삽입, 제거
    for i,v in ipairs(l_modified_runes) do

        -- 슬롯 타입
        local slot_type = v['type']

        -- 장착 여부
        local is_equiped = (v['odoid'] ~= nil) and (v['odoid'] ~= '')

        if self.m_mTableViewListMap[slot_type] then
            if is_equiped then
                self.m_mTableViewListMap[slot_type]:delItem(v['id'])
            else
                self.m_mTableViewListMap[slot_type]:addItem(v['id'], v)
            end

            l_modified_slot[slot_type] = true
        end
    end

    -- 변경된 룬 타입의 테이블뷰를 갱신
    for slot_type,_ in pairs(l_modified_slot) do
        local table_view_td = self.m_mTableViewListMap[slot_type]
        self.m_runeSortManager:changeSort()
        table_view_td:relocateContainer(true)

        --[[
        -- 첫 번째 룬을 선택 (자동)
        local t_first_item = table_view_td.m_itemList[1]
        local t_first_rune_data = (t_first_item and t_first_item['data'])
        self:setSelectedRuneData(t_first_rune_data)
        --]]
    end
end

-------------------------------------
-- function solveDeletedRunes_tableView
-- @brief
-------------------------------------
function UI_DragonMgrRunes:solveDeletedRunes_tableView(l_deleted_runes)
    local l_modified_slot = {}

    for i,v in ipairs(l_deleted_runes) do
        local roid = v
        for slot_type,table_view in pairs(self.m_mTableViewListMap) do
            if table_view:delItem(roid) then
                l_modified_slot[slot_type] = true
            end
        end 
    end

    -- 변경된 룬 타입의 테이블뷰를 갱신
    for slot_type,_ in pairs(l_modified_slot) do
        local table_view_td = self.m_mTableViewListMap[slot_type]
        self.m_runeSortManager:changeSort()
        table_view_td:relocateContainer(false)

        --[[
        -- 첫 번째 룬을 선택 (자동)
        local t_first_item = table_view_td.m_itemList[1]
        local t_first_rune_data = (t_first_item and t_first_item['data'])
        self:setSelectedRuneData(t_first_rune_data)
        --]]
    end
end


--@CHECK
UI:checkCompileError(UI_DragonMgrRunes)
