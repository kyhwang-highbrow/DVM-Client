local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_DragonRunesBulkEquipDragonTab
-------------------------------------
UI_DragonRunesBulkEquipDragonTab = class(PARENT,{
        m_ownerUI = 'UI_DragonRunesBulkEquip',
        
        m_tableViewTD = 'UIC_TableViewTD',
        m_sortManagerDragon = 'SortManager_Dragon',

    })


UI_DragonRunesBulkEquipDragonTab.CARD_SCALE = 0.52
UI_DragonRunesBulkEquipDragonTab.CARD_CELL_SIZE = cc.size(80, 80)

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:init(owner_ui)
    local vars = self:load('dragon_rune_popup_dragon.ui')

    self.m_ownerUI = owner_ui

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

    -- ����Ʈ ������ ���� �ݹ�
    local function create_func(ui, data)
        ui.root:setScale(UI_DragonRunesBulkEquipDragonTab.CARD_SCALE)
        
        -- Ŭ�� ��ư ����
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_DragonCard(ui, data) end)
    end

    -- ���̺�� ����
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = UI_DragonRunesBulkEquipDragonTab.CARD_CELL_SIZE
    table_view_td.m_nItemPerCell = 8
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_tableViewTD = table_view_td

    -- ����Ʈ�� ����� ��
    table_view_td:makeDefaultEmptyDescLabel(Str('���� ������ �巡���� �����ϴ�.'))

    -- ���� ��� ������ ����Ʈ�� ����
    local l_dragon_list = self:getDragonList()
    self.m_tableViewTD:setItemList(l_dragon_list)
	
    -- ����
    if (self.m_sortManagerDragon == nil) then
        local sort_manager = SortManager_Dragon()

        do -- ���� UI ����
            local uic_sort_list = MakeUICSortList_dragonManage(vars['sortBtn'], vars['sortLabel'], UIC_SORT_LIST_TOP_TO_BOT)
        
            -- ��ư�� ���� ������ ����Ǿ��� ���
            local function sort_change_cb(sort_type)
                sort_manager:pushSortOrder(sort_type)
                self:applyDragonSort()
            end

            uic_sort_list:setSortChangeCB(sort_change_cb)
        end

        do -- ��������/�������� ��ư
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
-- @brief ���� �����Ǿ��ִ� �巡��
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:getDragonList()
    local dragon_dic = g_dragonsData:getDragonsList()

    -- ���� �ƹ��͵� �������� ���� �巡���� ����
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
-- @brief �巡���� �� ����
-------------------------------------
function UI_DragonRunesBulkEquipDragonTab:click_DragonCard(ui, data)
    local vars = self.vars

    local doid = data['id']
    self.m_ownerUI:simulateDragonRune(doid)
end