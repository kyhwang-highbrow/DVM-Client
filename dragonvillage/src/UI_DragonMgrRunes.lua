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
        m_selectedRuneData = 'table',
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
function UI_DragonMgrRunes:init(doid)
    self.m_bChangeDragonList = false

    local vars = self:load('dragon_rune.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonMgrRunes')

    self:sceneFadeInAction()

    self:initUI()
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

    -- 룬 Tab 설정
    self:initUI_runeTab()
end

-------------------------------------
-- function initUI_runeTab
-- @brief 룰 슬롯 버튼 처리
-------------------------------------
function UI_DragonMgrRunes:initUI_runeTab()
    local vars = self.vars
    self:addTab(l_rune_slot_name[1], vars['runeSlotBtn1'], vars['runeSlotSelectSprite1'])
    self:addTab(l_rune_slot_name[2], vars['runeSlotBtn2'], vars['runeSlotSelectSprite2'])
    self:addTab(l_rune_slot_name[3], vars['runeSlotBtn3'], vars['runeSlotSelectSprite3'])
    self:setTab(l_rune_slot_name[1])
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

    if roid then
        vars['useMenu']:setVisible(true)

        local t_rune_infomation = g_runesData:getRuneInfomation(roid)
        --ccdump(t_rune_infomation)
        vars['useRuneNameLabel']:setString(t_rune_infomation['full_name'])

    else
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
    local node = self.vars['selectListNode']
    node:removeAllChildren()

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

    -- 첫 번째 룬을 선택 (자동)
    local t_first_item = table_view_td.m_itemList[1]
    local t_first_rune_data = (t_first_item and t_first_item['data'])
    self:setSelectedRuneData(t_first_rune_data)
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonMgrRunes:initButton()
    local vars = self.vars
    --vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)
    vars['equipBtn']:registerScriptTapHandler(function() self:click_equipBtn() end)
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
        local node = vars['dragonNode']
        node:removeAllChildren()
        local dragon_card = UI_DragonCard(t_dragon_data)
        node:addChild(dragon_card.root)

        -- UI 반응 액션
        cca.uiReactionSlow(dragon_card.root)
    end
    
    do -- 룬 아이콘
        local t_runes = t_dragon_data['runes']
        
        for i,slot_name in ipairs(l_rune_slot_name) do
            local roid = t_runes[slot_name]

            vars['runeSlot' .. i]:removeAllChildren()

            if roid then
                local t_rune_infomation = g_runesData:getRuneInfomation(roid)
                local item_card = UI_ItemCard(t_rune_infomation['rid'], 1, t_rune_infomation)
                item_card.vars['clickBtn']:setEnabled(false)
                vars['runeSlot' .. i]:addChild(item_card.root)
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
-- @brief 인벤에 있는 룬을 장착
-------------------------------------
function UI_DragonMgrRunes:click_equipBtn()
    local t_dragon_data = self.m_selectDragonData
    local t_rune_data = self.m_selectedRuneData

    if (not t_dragon_data) or (not t_rune_data) then
        return
    end
    
    local doid = t_dragon_data['id']
    local roid = t_rune_data['id']

    local function cb_func(ret)

        -- 갱신
        if ret['dragon'] then
            local doid = ret['dragon']['id']
            local b_force = true
            self:setSelectDragonData(doid, b_force)
        end
        --self:refresh()
    end

    g_runesData:requestRuneEquip(doid, roid, cb_func)
end

--@CHECK
UI:checkCompileError(UI_DragonMgrRunes)
