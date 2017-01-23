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
        m_useRuneData = 'table',
        m_selectedRuneData = 'table',

        -- 테이블 뷰
        m_mTableViewListMap = 'map',

        -- 갱신 여부 확인용
        m_refreshFlag_selectedDoid = 'string',
        m_refreshFlag_mRuneSlotDoid = 'map',
        m_refreshFlag_selectedRoid = 'string',
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

    self:initUI()
    self:initUI_runeTab(slot_idx) -- 룬 Tab 설정
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)
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

    if roid and (roid ~= '') then
        vars['useMenu']:setVisible(true)

        local t_rune_infomation, t_rune_data = g_runesData:getRuneInfomation(roid)
        --ccdump(t_rune_infomation)
        vars['useRuneNameLabel']:setString(t_rune_infomation['full_name'])

        do -- 룬 아이콘
            vars['useRuneNode']:removeAllChildren()
            local icon = UI_RuneCard(t_rune_data)
            vars['useRuneNode']:addChild(icon.root)

            cca.uiReactionSlow(icon.root)
        end
        self.m_useRuneData = t_rune_data

        cca.uiReactionSlow(vars['useMenu'], 1, 1, 0.98)
    else
        self.m_useRuneData = nil
        vars['useMenu']:setVisible(false)
    end

    -- 재료 리스트뷰 초기화
    self:init_runeTableView(rune_slot_type)
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
        end

        -- 테이블 뷰 인스턴스 생성
        local table_view_td = UIC_TableViewTD(node)
        table_view_td.m_cellSize = cc.size(103, 103)
        table_view_td.m_nItemPerCell = 4
        table_view_td:setCellUIClass(UI_RuneCard, create_func)
        table_view_td:setItemList(l_item_list)

        self.m_mTableViewListMap[rune_slot_type] = table_view_td
    end

    -- 첫 번째 룬을 선택 (자동)
    local table_view_td = self.m_mTableViewListMap[rune_slot_type]
    if (not self.m_selectedRuneData) or (not table_view_td:getItem(self.m_selectedRuneData['id'])) then
        local t_first_item = table_view_td.m_itemList[1]
        local t_first_rune_data = (t_first_item and t_first_item['data'])
        self:setSelectedRuneData(t_first_rune_data)
    end
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
    --vars['useEnhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
    --vars['selectEnhance']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
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

    self:refreshCurrTab()
end

-------------------------------------
-- function setSelectedRuneData
-- @brief 인벤상에서 선택된 룬
-------------------------------------
function UI_DragonMgrRunes:setSelectedRuneData(t_rune_data)
    self.m_selectedRuneData = t_rune_data
    self:refresh_selectMenu(t_rune_data)
end

-------------------------------------
-- function refresh_selectMenu
-- @brief 인벤상에서 선택된 룬의 정보 표시
-------------------------------------
function UI_DragonMgrRunes:refresh_selectMenu(t_rune_data)
    local roid = (t_rune_data and t_rune_data['id'] or nil)

    if (self.m_refreshFlag_selectedRoid == roid) then
        return
    end
    self.m_refreshFlag_selectedRoid = roid

    local vars = self.vars

    if t_rune_data then
        vars['selectMenu']:setVisible(true)
    else
        vars['selectMenu']:setVisible(false)
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

        self.m_bChangeDragonList = true
    end

    -- 슬롯이 비어있으면 "장착"
    if (not t_dragon_data['runes'][slot]) or (t_dragon_data['runes'][slot] == '') then
        g_runesData:requestRuneEquip(doid, roid, cb_func)

    -- 슬롯이 비어있지 않으면 "교체"
    else
        local fee = TableRune:getRuneUnequipFee(rid)

        -- 캐시가 부족할 경우
        if (g_userData:get('cash') < fee) then
            local msg = Str('캐시가 부족합니다.\n상점으로 이동하시겠습니까?')
            MakeSimplePopup(POPUP_TYPE.YES_NO, msg, openShopPopup)

        -- 캐시가 부족하지 않은 경우
        else
            local function yes_cb()
                g_runesData:requestRuneEquip(doid, roid, cb_func)
            end
            local msg = Str('룬을 교체하여 장착하려면\n{1}개의 자수정이 소모됩니다.\n교체하시겠습니까?', fee)
            MakeSimplePopup(POPUP_TYPE.YES_NO, msg, yes_cb)
        end
    end
end

-------------------------------------
-- function click_removeBtn
-- @brief 룬 장착 해제
-------------------------------------
function UI_DragonMgrRunes:click_removeBtn()
    local t_dragon_data = self.m_selectDragonData
    local t_rune_data = self.m_useRuneData

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

        self.m_bChangeDragonList = true
    end

    local fee = TableRune:getRuneUnequipFee(rid)

    -- 캐시가 부족할 경우
    if (g_userData:get('cash') < fee) then
        local msg = Str('캐시가 부족합니다.\n상점으로 이동하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, openShopPopup)

    -- 캐시가 부족하지 않은 경우
    else
        local function yes_cb()
            g_runesData:requestRuneUnequip(doid, roid, slot, cb_func)
        end
        local msg = Str('룬을 장착 해제하려면\n{1}개의 자수정이 소모됩니다.\n해제하시겠습니까?', fee)
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, yes_cb)
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
        table_view_td:expandTemp(0.5)
        table_view_td:relocateContainer(true)

        -- 첫 번째 룬을 선택 (자동)
        local t_first_item = table_view_td.m_itemList[1]
        local t_first_rune_data = (t_first_item and t_first_item['data'])
        self:setSelectedRuneData(t_first_rune_data)
    end
end


--@CHECK
UI:checkCompileError(UI_DragonMgrRunes)
