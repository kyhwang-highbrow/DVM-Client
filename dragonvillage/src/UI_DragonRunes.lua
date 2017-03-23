local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_DragonRunes
-------------------------------------
UI_DragonRunes = class(PARENT,{
        m_listFilterSetID = 'number', -- 0번은 전체 1~8은 해당 세트만
        m_tableViewTD = 'UIC_TableViewTD',
        m_selectedRuneObject = 'StructRuneObject',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunes:init(doid, slot_idx)
    self.m_listFilterSetID = 0

    local vars = self:load('dragon_rune_new.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonRunes')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    -- 룬 Tab 설정
    self:initUI_runeTab(slot_idx)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunes:initUI()
    self:init_tableViewTD()

    self:setEquipedRuneObject(nil)
    self:setSelectedRuneObject(nil)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunes:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunes:refresh()
end

-------------------------------------
-- function initUI_runeTab
-- @brief 룰 슬롯 버튼 처리
-------------------------------------
function UI_DragonRunes:initUI_runeTab(slot_idx)
    local vars = self.vars
    slot_idx = slot_idx or 1
    self:addTab(1, vars['runeSlotBtn1'], vars['runeSlotSelectSprite1']) --, vars[l_rune_slot_name[1] .. 'TableViewNode'])
    self:addTab(2, vars['runeSlotBtn2'], vars['runeSlotSelectSprite2']) --, vars[l_rune_slot_name[2] .. 'TableViewNode'])
    self:addTab(3, vars['runeSlotBtn3'], vars['runeSlotSelectSprite3']) --, vars[l_rune_slot_name[3] .. 'TableViewNode'])
    self:addTab(4, vars['runeSlotBtn4'], vars['runeSlotSelectSprite4']) --, vars[l_rune_slot_name[3] .. 'TableViewNode'])
    self:addTab(5, vars['runeSlotBtn5'], vars['runeSlotSelectSprite5']) --, vars[l_rune_slot_name[3] .. 'TableViewNode'])
    self:addTab(6, vars['runeSlotBtn6'], vars['runeSlotSelectSprite6']) --, vars[l_rune_slot_name[3] .. 'TableViewNode'])
    self:setTab(slot_idx)
end

-------------------------------------
-- function init_tableViewTD
-- @brief
-------------------------------------
function UI_DragonRunes:init_tableViewTD()
    local node = self.vars['runeTableViewNode']
    node:removeAllChildren()

    local l_item_list = {}

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.66)

        --ui.m_dragonCard.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(data) end)
        local rune_obj = data
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:setSelectedRuneObject(rune_obj) end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(101, 101)
    table_view_td.m_nItemPerCell = 7
    table_view_td:setCellUIClass(UI_RuneCard, create_func)
    table_view_td:setItemList(l_item_list)
    table_view_td:makeDefaultEmptyDescLabel(Str('룬 인벤토리가 비어있습니다.\n다양한 전투를 통해 룬을 획득해보세요!'))

    -- 정렬
    self.m_tableViewTD = table_view_td
end

-------------------------------------
-- function onChangeTab
-- @brief 룬 슬롯 탭이 변경되었을 때
-------------------------------------
function UI_DragonRunes:onChangeTab(tab, first)
    self:refreshTableViewList()
end

-------------------------------------
-- function setListFilterSetID
-- @brief
-------------------------------------
function UI_DragonRunes:setListFilterSetID(list_filter_set_id)
    if (self.m_listFilterSetID == list_filter_set_id) then
        return
    end

    self.m_listFilterSetID = list_filter_set_id
end


-------------------------------------
-- function refreshTableViewList
-- @brief
-------------------------------------
function UI_DragonRunes:refreshTableViewList()
    local equiped = false
    local slot = self.m_currTab
    local set_id = self.m_listFilterSetID

    local l_item_list = g_runesData:getFilteredRuneList(equiped, slot, set_id)

    self.m_tableViewTD:mergeItemList(l_item_list)
end

-------------------------------------
-- function setEquipedRuneObject
-- @brief
-------------------------------------
function UI_DragonRunes:setEquipedRuneObject(rune_obj)
    local vars = self.vars
    --self.m_selectedRuneObject = rune_obj

    -- 룬 아이콘 삭제
    vars['useRuneNode']:removeAllChildren()
    vars['useRuneNameLabel']:setString('')
    vars['useMainOptionLabel']:setString('')
    vars['useSubOptionLabel']:setString('')
    vars['useRuneSetLabel']:setString('')

    if (not rune_obj) then
        return
    end

    -- 룬 명칭
    vars['useRuneNameLabel']:setString(rune_obj['name'])

    -- 룬 아이콘
    local rune_icon = UI_RuneCard(rune_obj)
    vars['useRuneNode']:addChild(rune_icon.root)

    -- 메인, 유니크 옵션
    vars['useMainOptionLabel']:setString(rune_obj:makeRuneDescRichText())

    -- 서브 옵션
    vars['useSubOptionLabel']:setString('')

    -- 세트 옵션
    vars['useRuneSetLabel']:setString('')
end

-------------------------------------
-- function setSelectedRuneObject
-- @brief
-------------------------------------
function UI_DragonRunes:setSelectedRuneObject(rune_obj)
    local vars = self.vars
    self.m_selectedRuneObject = rune_obj

    -- 룬 아이콘 삭제
    vars['selectRuneNode']:removeAllChildren()
    vars['selectRuneNameLabel']:setString('')
    vars['selectMainOptionLabel']:setString('')
    vars['selectSubOptionLabel']:setString('')
    vars['selectRuneSetLabel']:setString('')

    if (not rune_obj) then
        return
    end

    -- 룬 명칭
    vars['selectRuneNameLabel']:setString(rune_obj['name'])

    -- 룬 아이콘
    local rune_icon = UI_RuneCard(rune_obj)
    vars['selectRuneNode']:addChild(rune_icon.root)

    -- 메인, 유니크 옵션
    vars['selectMainOptionLabel']:setString(rune_obj:makeRuneDescRichText())

    -- 서브 옵션
    vars['selectSubOptionLabel']:setString('')

    -- 세트 옵션
    vars['selectRuneSetLabel']:setString('')
end
