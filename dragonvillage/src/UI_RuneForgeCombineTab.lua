local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_RuneForgeCombineTab
-------------------------------------
UI_RuneForgeCombineTab = class(PARENT,{
        m_tableView = 'UIC_TableViewTD',
        m_combineTableView = 'UIC_TableView',
        m_uicSortList = 'UIC_SortList', -- 룬 등급 정렬
        m_sortManager = 'SortManager',
        m_sortGrade = 'number',
        ---------------------------------
        m_mSelectRuneMap = 'map', -- grade마다 현재 선택되어있는 룬 저장하는 map, map[grade][roid] = StructRuneObject
        m_mSelectRuneList = 'map', -- grade마다 현재 선택되어있는 룬 저장하는 list, 선택 순서를 저장하기 위함
        m_lCombineDataList = 'list', -- 조합 관련 정보 리스트
    })

UI_RuneForgeCombineTab.CARD_SCALE = 0.6
UI_RuneForgeCombineTab.CARD_CELL_SIZE = cc.size(94, 94)
UI_RuneForgeCombineTab.RUNE_COMBINE_REQUIRE = 10

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeCombineTab:init(owner_ui)
    local vars = self:load('rune_forge_combine.ui')
    
    self.m_sortGrade = 0
    
end

-------------------------------------
-- function initSelectRunes
-------------------------------------
function UI_RuneForgeCombineTab:initSelectRunes()
    self.m_mSelectRuneMap = {}
    self.m_mSelectRuneList = {}
    for grade = 1, 7 do
        self.m_mSelectRuneMap[grade] = {}
        self.m_mSelectRuneList[grade] = {}
    end

    self.m_lCombineDataList = {}
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgeCombineTab:onEnterTab(first)
    self.m_ownerUI:hideNpc() -- NPC 숨김

    if (first == true) then
        self:initSelectRunes()
        self:initUI()
    end
    
    self:refresh()
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_RuneForgeCombineTab:onExitTab()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeCombineTab:initUI()
    local vars = self.vars

    vars['autoBtn']:registerScriptTapHandler(function() self:click_autoBtn() end)

    local uic_sort_list = MakeUICSortList_runeCombine(vars['sortBtn'], vars['sortLabel'])
    self.m_uicSortList = uic_sort_list
    
    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        self.m_sortGrade = sort_type
        self:initSelectRunes()
        self:initTableView()
        self:initCombineTableView()
        self:refresh()
    end

    uic_sort_list:setSortChangeCB(sort_change_cb)

    self:initTableView()
    self:initCombineTableView()
end

-------------------------------------
-- function initTableView
-- @brief 왼쪽 룬 목록 테이블뷰 생성
-------------------------------------
function UI_RuneForgeCombineTab:initTableView()
    local vars = self.vars
    local node = vars['listNode']
    
    node:removeAllChildren()
    
    -- 리스트 아이템 생성 콜백
    local function make_func(object)
        return UI_RuneCard(object)
    end

    local function create_func(ui, data)
        -- 새로 획득한 룬 뱃지
        local is_new_rune = data:isNewRune()
        ui:setNewSpriteVisible(is_new_rune)

        ui.root:setScale(UI_RuneForgeCombineTab.CARD_SCALE)

        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_rune(ui, data) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(node)
    --table_view_td.m_cellSize = cc.size(102, 102)
    table_view_td.m_cellSize = UI_RuneForgeCombineTab.CARD_CELL_SIZE
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(make_func, create_func)
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    self.m_tableView = table_view_td

    -- 재료로 사용 가능한 리스트를 얻어옴
    local grade = self.m_sortGrade
    local l_rune_list = g_runesData:getUnequippedRuneList(nil, grade) -- param : set_id, grade
    self.m_tableView:setItemList(l_rune_list)

    if (self.m_sortManager == nil) then
        local sort_manager = SortManager_Rune()
        self.m_sortManager = sort_manager
    end

    self.m_sortManager:sortExecution(self.m_tableView.m_itemList)
end

-------------------------------------
-- function initCombineTableView
-- @brief 오른쪽 조합 테이블뷰 생성
-------------------------------------
function UI_RuneForgeCombineTab:initCombineTableView()
    local vars = self.vars
    local node = vars['runeCombineTableViewNode']
    
    node:removeAllChildren()
    
    -- 리스트 아이템 생성 콜백
    local function make_func(object)
        return UI_RuneForgeCombineItem(self, nil, nil, nil)
    end

    local function create_func(ui, data)
        -- ui.root:setScale(UI_RuneForgeCombineTab.CARD_SCALE)

        -- 클릭 버튼 설정
        -- ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_rune(ui, data) end)
    end

    -- 테이블뷰 생성
    local l_item_list = self.m_lCombineDataList
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(530, 180)
    table_view:setCellUIClass(make_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    self.m_combineTableView = table_view
end



-------------------------------------
-- function refresh
-- @brief 선택된 룬 갯수
-------------------------------------
function UI_RuneForgeCombineTab:refresh()
    local vars = self.vars
    
    local all_count = table.count(self.m_tableView.m_itemList)
    local select_count = 0
    for grade = 1, 7 do
        select_count = select_count + table.count(self.m_mSelectRuneList[grade])
    end
    vars['countLabel']:setString(Str('{1}/{2}', select_count, all_count))

    local combine_max_count = 10
    local combine_count = table.count(self.m_lCombineDataList)
    vars['selectLabel']:setString(Str('{1}/{2}', combine_count, combine_max_count))

    self:refreshCombineItems()
end

-------------------------------------
-- function refreshCombineItems
-- @brief 조합 정보 UI 갱신
-------------------------------------
function UI_RuneForgeCombineTab:refreshCombineItems()
    --local l_item_list = self.m_lCombineDataList
    --local table_view = self.m_combineTableView
    --table_view:setItemList(l_item_list)
    self.m_combineTableView:setItemList(self.m_lCombineDataList)
end

-------------------------------------
-- function addCombineItem
-- @brief 조합 UI 추가
-- @param grade : 만들려는 combine ui의 룬 grade
-- @param idx : 만들려는 combine ui의 grade별 idx
-- @param t_first_rune_data : 처음 생성될 때 첫 칸을 차지할 룬 데이터
-------------------------------------
function UI_RuneForgeCombineTab:addCombineItem(grade, idx, t_first_rune_data)
    table.insert(self.m_lCombineDataList, {'test'})

end

-------------------------------------
-- function removeCombineItem
-- @brief 조합 UI 제거
-- @param grade : 제거하려는 combine ui의 룬 grade
-- @param idx : 제거하려는 combine ui의 grade별 idx
-------------------------------------
function UI_RuneForgeCombineTab:removeCombineItem(grade, idx)
    
end

-------------------------------------
-- function click_rune
-- @brief 룬 선택
-------------------------------------
function UI_RuneForgeCombineTab:click_rune(ui, data)
    local rune_card = ui
    local t_rune_data = data

    local roid = t_rune_data['roid']
    local grade = t_rune_data['grade']
    local select_roid_map = self.m_mSelectRuneMap[grade]

    if (select_roid_map[roid] == nil) then
        ui:setCheckSpriteVisible(true)
        self:selectRune(t_rune_data)

    else 
        ui:setCheckSpriteVisible(false)
        self:deselectRune(t_rune_data)
    end

    self:refresh()
end

-------------------------------------
-- function selectRune
-- @brief 룬 선택
-- @param t_rune_data : 선택된 룬 데이터 (StructRuneObject)
-------------------------------------
function UI_RuneForgeCombineTab:selectRune(t_rune_data)
    local roid = t_rune_data['roid']
    local grade = t_rune_data['grade']
    local select_roid_map = self.m_mSelectRuneMap[grade]
    local select_roid_list = self.m_mSelectRuneList[grade]

    if (select_roid_map[roid]) then return end

    select_roid_map[roid] = t_rune_data
    table.insert(select_roid_list, t_rune_data)

    local b_add_rune = false
    local last_idx = 0
    --for idx, combine_data in ipairs(self.m_lCombineDataList) do
        --if (grade == combine_ui.m_grade) then
            --b_add_rune = combine_ui:addRune(t_rune_data) -- 해당 룬을 추가할 수 있다면 추가하면서 true 반환, 이미 가득차있다면 false 반환
            --if b_add_rune then
                --break
            --else
                --last_idx = combine_ui.m_idx
            --end
        --end
    --end

    -- 룬이 추가되지 못한 경우, 적절한 combine_data가 없는 것이므로 추가
    if (not b_add_rune) then
        local new_idx = last_idx + 1
        self:addCombineItem(grade, new_idx, t_rune_data) -- param : grade, idx, t_first_rune_data
    end
end

-------------------------------------
-- function deselectRune
-- @brief 룬 선택 해제
-- @param t_rune_data : 선택된 룬 데이터 (StructRuneObject)
-------------------------------------
function UI_RuneForgeCombineTab:deselectRune(t_rune_data)
    local roid = t_rune_data['roid']
    local grade = t_rune_data['grade']
    local select_roid_map = self.m_mSelectRuneMap[grade]
    local select_roid_list = self.m_mSelectRuneList[grade]

    select_roid_map[roid] = nil
    for idx, data in ipairs(select_roid_list) do
        if (data['roid'] == roid) then
            table.remove(select_roid_list, idx)
            break
        end
    end
end

-------------------------------------
-- function click_autoBtn
-- @brief 자동 등록
-------------------------------------
function UI_RuneForgeCombineTab:click_autoBtn()
   
end
