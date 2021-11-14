local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_DragonRunesBulkEquipDragonTab
-------------------------------------
UI_DragonRunesBulkEquipDragonTab = class(PARENT,{
        m_ownerUI = 'UI_DragonRunesBulkEquip',
        
        m_tableViewTD = 'UIC_TableViewTD',
        m_sortManagerDragon = 'SortManager_Dragon',

        m_selectDoid = 'string',

        m_multiDeckMgr = '',
    })


UI_DragonRunesBulkEquipDragonTab.CARD_SCALE = 0.52
UI_DragonRunesBulkEquipDragonTab.CARD_CELL_SIZE = cc.size(80, 80)

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:init(owner_ui)
    local vars = self:load('dragon_rune_popup_dragon.ui')

    self.m_ownerUI = owner_ui
    self.m_selectDoid = nil
end

-------------------------------------
-- function setParentAndInit
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:setParentAndInit(parent_node)
    -- 룬을 출력하는 TableView(runeTableViewNode)가 relative size의 영향을 받는다.
    -- UI가 생성되고 부모 노드에 addChild가 된 후에 해당 노드의 크기가 결정되므로 외부에서 호출하도록 한다.
    -- setTab -> onChangeTab -> initTableView 의 순서로 TableView가 생성됨.
    --self:setTab(1, true)
    
    parent_node:addChild(self.root)

    self:initUI()

    self:initTableView()

    self:initButton()

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:initUI()
    local vars = self.vars

end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:initTableView()
    local vars = self.vars

    local list_table_node = self.vars['dragonTableViewNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(UI_DragonRunesBulkEquipDragonTab.CARD_SCALE)
        
        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_DragonCard(ui, data) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = UI_DragonRunesBulkEquipDragonTab.CARD_CELL_SIZE
    table_view_td.m_nItemPerCell = 7
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_tableViewTD = table_view_td

    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel(Str('룬이 장착된 드래곤이 없습니다.'))

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonList()
    self.m_tableViewTD:setItemList(l_dragon_list)
	
    -- 정렬
    if (self.m_sortManagerDragon == nil) then
        local sort_manager = SortManager_Dragon()

        do -- 정렬 UI 생성
            local uic_sort_list = MakeUICSortList_dragonManage(vars['sortBtn'], vars['sortLabel'], UIC_SORT_LIST_TOP_TO_BOT)
        
            -- 버튼을 통해 정렬이 변경되었을 경우
            local function sort_change_cb(sort_type)
                sort_manager:pushSortOrder(sort_type)
                self:applyDragonSort()
            end

            uic_sort_list:setSortChangeCB(sort_change_cb)

            uic_sort_list:setSelectSortType('combat_power', false)
        end

        do -- 오름차순/내림차순 버튼
            local function click()
                local ascending = (not sort_manager.m_defaultSortAscending)
                sort_manager:setAllAscending(ascending)
                self:applyDragonSort()

                vars['sortOrderSprite']:stopAllActions()
                if ascending then
                    vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
                else
                    vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
                end
            end

            vars['sortOrderBtn']:registerScriptTapHandler(click)
        end

        self.m_sortManagerDragon = sort_manager

        -- 멀티덱 사용시 우선순위 추가
        local deck_name = g_deckData:getSelectedDeckName()

        if (string.find(deck_name, 'league_raid')) then
            self.m_multiDeckMgr = MultiDeckMgr(MULTI_DECK_MODE.LEAGUE_RAID, true)

            if (self.m_multiDeckMgr) then
                local function cond_raid(a, b)
                    return self.m_multiDeckMgr:sort_multi_deck_raid(a, b)
                end

                self.m_sortManagerDragon:addPreSortType('multi_deck', false, cond_raid)
            end
        end
    end

    self:applyDragonSort()
end



-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:initButton()
    local vars = self.vars

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:refresh()
    local vars = self.vars


end

-------------------------------------
-- function getDragonList
-- @brief 룬이 장착되어있는 드래곤
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:getDragonList()
    local dragon_dic = g_dragonsData:getDragonsList()

    -- 룬이 아무것도 장착되지 않은 드래곤은 제외
    for oid, v in pairs(dragon_dic) do
        if (table.count(v:getRuneObjectList()) == 0) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
-- function applyDragonSort
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:applyDragonSort()
	if (not self.m_sortManagerDragon) then
		return
	end

    if (not self.m_tableViewTD) then
		return
	end

	self.m_sortManagerDragon:sortExecution(self.m_tableViewTD.m_itemList)
    self.m_tableViewTD:setDirtyItemList()
end

-------------------------------------
-- function click_DragonCard
-- @brief 드래곤의 룬 장착
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:click_DragonCard(ui, data)
    local vars = self.vars

    local doid = data['id']
    self.m_ownerUI:simulateDragonRune(doid)

    if (self.m_selectDoid ~= nil) then
        if (self.m_tableViewTD.m_itemMap[self.m_selectDoid]) then
            local selected_ui = self.m_tableViewTD:getCellUI(self.m_selectDoid)
            if (selected_ui ~= nil) then
                selected_ui:setHighlightSpriteVisible(false)
            end
        end
    end

    self.m_selectDoid = doid
    ui:setHighlightSpriteVisible(true)
end