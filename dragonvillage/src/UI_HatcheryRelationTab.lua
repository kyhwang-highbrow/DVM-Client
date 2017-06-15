local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_HatcheryRelationTab
-------------------------------------
UI_HatcheryRelationTab = class(PARENT,{
        m_sortManagerDragon = 'SortManager_Dragon',
        m_uicSortList = 'UIC_SortList',
        m_tableViewTD = 'UIC_TableViewTD',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HatcheryRelationTab:init(owner_ui)
    local vars = self:load('hatchery_relation.ui')
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_HatcheryRelationTab:onEnterTab(first)
    if first then
        self:init_TableView()
        self:init_dragonSortMgr()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_HatcheryRelationTab:onExitTab()
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_HatcheryRelationTab:init_TableView()
    local list_table_node = self.vars['materialTableViewNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.66)
        -- 클릭 버튼 설정
        --ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonMaterial(data) end)

		--self:createMtrlDragonCardCB(ui, data)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(100, 100)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_tableViewTD = table_view_td

    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel(Str('도와줄 드래곤이 없어요 ㅠㅠ'))

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonList()
    table_view_td:setItemList(l_dragon_list)
end

-------------------------------------
-- function getDragonList
-------------------------------------
function UI_HatcheryRelationTab:getDragonList()
    local table_dragon = TableDragon()

    local function condition_func(t_table)
        if (not t_table['relation_point']) then
            return false
        end
        
        local relation_point = tonumber(t_table['relation_point'])
        if (not relation_point) then
            return false
        end

        if (relation_point <= 0) then
            return false
        end

        return true
    end

    local l_dragon_list = table_dragon:filterTable_condition(condition_func)

    local t_ret = {}
    for i,v in pairs(l_dragon_list) do
        local t_data = {}
        t_data['did'] = v['did']
        t_data['grade'] = v['birthgrade']
        t_ret[i] = StructDragonObject(t_data)
    end

    return t_ret
end

-------------------------------------
-- function init_dragonSortMgr
-- @brief 정렬 도우미
-------------------------------------
function UI_HatcheryRelationTab:init_dragonSortMgr()
    -- 정렬 매니저 생성
    self.m_sortManagerDragon = SortManager_Dragon()

    -- 정렬 UI 생성
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_dragonManage(vars['sortSelectBtn'], vars['sortSelectLabel'], UIC_SORT_LIST_TOP_TO_BOT)
    self.m_uicSortList = uic_sort_list
    

    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        self.m_sortManagerDragon:pushSortOrder(sort_type)
        self:apply_dragonSort()
        --self:save_dragonSortInfo()
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 오름차순/내림차순 버튼
    vars['sortSelectOrderBtn']:registerScriptTapHandler(function()
            local ascending = (not self.m_sortManagerDragon.m_defaultSortAscending)
            self.m_sortManagerDragon:setAllAscending(ascending)
            self:apply_dragonSort()
            --self:save_dragonSortInfo()

            vars['sortSelectOrderSprite']:stopAllActions()
            if ascending then
                vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
            else
                vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
            end
        end)

    -- 세이브데이터에 있는 정렬 값을 적용
    --self:apply_dragonSort_saveData()
    self:apply_dragonSort()
end

-------------------------------------
-- function apply_dragonSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_HatcheryRelationTab:apply_dragonSort()
    local list = self.m_tableViewTD.m_itemList
    self.m_sortManagerDragon:sortExecution(list)
    self.m_tableViewTD:setDirtyItemList()
end