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
        m_mSelectRuneMap = 'map', -- grade마다 현재 선택되어있는 룬 저장하는 map, map[grade][roid]
        m_mCombineDataMap = 'map', -- 조합 정보 저장, map[unique_key] = StructRuneCombine
        m_currUniqueKey = 'number', -- StructRuneCombine의 유니크 키를 생성하기 애매한 부분이 있어서 숫자로 관리
    })

UI_RuneForgeCombineTab.CARD_SCALE = 0.6
UI_RuneForgeCombineTab.CARD_CELL_SIZE = cc.size(94, 94)

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
    for grade = 1, 7 do
        self.m_mSelectRuneMap[grade] = {}
    end

    self.m_mCombineDataMap = {}
    self.m_currUniqueKey = 1
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
    uic_sort_list:setSelectSortType(0) -- 필터 '전체' 선택
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
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_rune(data) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(node)
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

     do -- 오름차순/내림차순 버튼
        local function click()
            local sort_manager = self.m_sortManager
            local ascending = (not sort_manager.m_defaultSortAscending)
            sort_manager:setAllAscending(ascending)
            self.m_sortManager:sortExecution(self.m_tableView.m_itemList)
            self.m_tableView:setDirtyItemList()

            vars['sortOrderSprite']:stopAllActions()
            if ascending then
                vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
            else
                vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
            end
        end

        vars['sortOrderBtn']:registerScriptTapHandler(click)
    end
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
        return UI_RuneForgeCombineItem(self, object)
    end

    local function create_func(ui, data)
    end

    -- 테이블뷰 생성
    local l_item_list = self.m_mCombineDataMap
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(530, 180)
    table_view:setCellUIClass(make_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    self.m_combineTableView = table_view
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeCombineTab:refresh()
    local vars = self.vars
    
    local all_count = table.count(self.m_tableView.m_itemList)
    local select_count = 0
    for grade = 1, 7 do
        select_count = select_count + table.count(self.m_mSelectRuneMap[grade])
    end
    vars['countLabel']:setString(Str('{1}/{2}', select_count, all_count))

    local combine_max_count = 10
    local combine_count = table.count(self.m_mCombineDataMap)
    vars['selectLabel']:setString(Str('{1}/{2}', combine_count, combine_max_count))

    self:refreshCombineItems()
end

-------------------------------------
-- function refreshCombineItems
-- @brief 조합 정보 UI 갱신
-------------------------------------
function UI_RuneForgeCombineTab:refreshCombineItems()
    self.m_combineTableView:refreshAllItemUI()
end

-------------------------------------
-- function addCombineItem
-- @brief 조합 UI 추가
-- @param grade : 만들려는 combine ui의 룬 grade
-- @param t_first_rune_data : 처음 생성될 때 첫 칸을 차지할 룬 데이터
-------------------------------------
function UI_RuneForgeCombineTab:addCombineItem(grade, t_first_rune_data)
    
    
    local unique_key = self.m_currUniqueKey
    local t_rune_combine_data = StructRuneCombine(grade)

    if (t_first_rune_data ~= nil) then
        t_rune_combine_data:addRuneObject(t_first_rune_data)
    end

    self.m_mCombineDataMap[unique_key] = t_rune_combine_data

    self.m_combineTableView:addItem(unique_key, t_rune_combine_data)
    self.m_combineTableView:getCellUI(unique_key)

    self.m_currUniqueKey = self.m_currUniqueKey + 1
end

-------------------------------------
-- function removeCombineItem
-- @brief 조합 UI 제거
-- @param unique_key : 제거하려는 combine data의 unique_key
-------------------------------------
function UI_RuneForgeCombineTab:removeCombineItem(unique_key)
    self.m_mCombineDataMap[unique_key] = nil
    self.m_combineTableView:delItem(unique_key)
end

-------------------------------------
-- function click_rune
-- @brief 룬 선택
-------------------------------------
function UI_RuneForgeCombineTab:click_rune(data)
    local t_rune_data = data
    local roid = t_rune_data['roid']
    local grade = t_rune_data['grade']
    
    local rune_card = self.m_tableView:getCellUI(roid)
   
    local select_roid_map = self.m_mSelectRuneMap[grade]

    if (select_roid_map[roid] == nil) then
        rune_card:setCheckSpriteVisible(true)
        self:selectRune(t_rune_data)

    else 
        rune_card:setCheckSpriteVisible(false)
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

    if (select_roid_map[roid]) then return end

    local combine_data_id 
    local b_add_rune = false
    for unique_key, combine_data in pairs(self.m_mCombineDataMap) do
        if (grade == combine_data.m_grade) then
            b_is_full = combine_data:isFull() -- 추가적인 룬 등록이 가능한 상태인가
            if not b_is_full then
                b_add_rune = true
                combine_data_id = unique_key
                combine_data:addRuneObject(t_rune_data)
                break
            end
        end
    end

    -- 룬이 추가되지 못한 경우, 적절한 combine_data가 없는 것이므로 추가
    if (not b_add_rune) then
        -- 이미 조합 갯수가 가득찬 경우
        if (table.count(self.m_mCombineDataMap) >= 10) then
            return
        end 

        combine_data_id = self.m_currUniqueKey
        self:addCombineItem(grade, t_rune_data) -- param : grade, t_first_rune_data
    end

    local data = {}
    data['combine_id'] = combine_data_id
    data['data'] = t_rune_data
    select_roid_map[roid] = data

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
    
    local combine_data_id = select_roid_map[roid]['combine_id']
    local combine_data = self.m_mCombineDataMap[combine_data_id]
    combine_data:removeRuneObject(t_rune_data)
    
    if (combine_data:isEmpty()) then
        self:removeCombineItem(combine_data_id)
    end
    
    select_roid_map[roid] = nil
end

-------------------------------------
-- function click_autoBtn
-- @brief 자동 등록
-------------------------------------
function UI_RuneForgeCombineTab:click_autoBtn()
    
    -- 기존에 이미 등록된 조합 정보에서 남은 칸부터 채울 수 있으면 채운다.
    local clone_table_item_list = clone(self.m_tableView.m_itemList)
    local sort_manager = SortManager_Rune()
    sort_manager:pushSortOrder('rarity')
    sort_manager:setAllAscending(true)
    sort_manager:sortExecution(clone_table_item_list)
    
    for combine_data_id, combine_data in pairs(self.m_mCombineDataMap) do
        if (not combine_data:isFull()) then
            local combine_grade = combine_data.m_grade
            local blank_slot_count = combine_data:getBlankSlotCount()
            local select_roid_map = self.m_mSelectRuneMap[combine_grade]

            -- 왼쪽 창에서 선택되지 않은 것 중 희귀도가 낮은 것부터 고른다
            for i, v in pairs(clone_table_item_list) do
                local t_rune_data = v['data']
                local roid = t_rune_data['roid']
                local grade = t_rune_data['grade']
                
                -- 같은 등급에 아직 선택되지 않은 룬이라면
                if ((grade == combine_grade) and (select_roid_map[roid] == nil)) then
                    -- 조합 정보에 룬 정보 등록
                    combine_data:addRuneObject(t_rune_data)
                    
                    -- self에 룬 정보 등록
                    local data = {}
                    data['combine_id'] = combine_data_id
                    data['data'] = t_rune_data
                    select_roid_map[roid] = data
                    
                    -- 룬 카드에 체크 표시 추가
                    local rune_card = self.m_tableView:getCellUI(roid)
                    rune_card:setCheckSpriteVisible(true)

                    -- 현재 조합 정보 빈 칸 다 채웠는지 확인
                    blank_slot_count = blank_slot_count - 1
                    if (blank_slot_count == 0) then
                        break
                    end
                end
            end
        end
    end

    -- 추가로 낮은 등급부터 차례로 채운다
    local blank_combine_count = 10 - table.count(self.m_mCombineDataMap)
    for grade = 1, 7 do
        if ((self.m_sortGrade == 0) or (self.m_sortGrade == grade)) then
            local b_next_grade = false
            local select_roid_map = self.m_mSelectRuneMap[grade]

            while(not b_next_grade) do
                local require_count = RUNE_COMBINE_REQUIRE
                local t_rune_data_list = {}
                -- 왼쪽 창에서 선택되지 않은 것 중 희귀도가 낮은 것부터 고른다
                for i, v in pairs(clone_table_item_list) do
                    local t_rune_data = v['data']
                    local roid = t_rune_data['roid']
                    local rune_grade = t_rune_data['grade']

                    -- 같은 등급에 아직 선택되지 않은 룬이라면
                    if ((grade == rune_grade) and (select_roid_map[roid] == nil)) then
                        table.insert(t_rune_data_list, v)
                        
                        require_count = require_count - 1
                        if (require_count == 0) then
                            break
                        end
                    end
                end

                -- 등록 가능할 때
                if (require_count == 0) then
                    local combine_data_id = self.m_currUniqueKey
                    self:addCombineItem(grade, nil)
                    local combine_data = self.m_mCombineDataMap[combine_data_id]

                    for i, v in ipairs(t_rune_data_list) do
                        local t_rune_data = v['data']
                        local roid = t_rune_data['roid']

                        -- 조합 정보에 룬 정보 등록
                        combine_data:addRuneObject(t_rune_data)
                    
                        -- self에 룬 정보 등록
                        local data = {}
                        data['combine_id'] = combine_data_id
                        data['data'] = t_rune_data
                        select_roid_map[roid] = data
                    
                        -- 룬 카드에 체크 표시 추가
                        local rune_card = self.m_tableView:getCellUI(roid)
                        rune_card:setCheckSpriteVisible(true)
                    end
                    
                    blank_combine_count = blank_combine_count - 1
                    if (blank_combine_count == 0) then
                        break
                    end
                
                -- 현재 등급에서 등록 불가능할 때
                else
                    b_next_grade = true
                end

            end

            -- 최대 조합 가능 개수를 넘었을 때
            if (blank_combine_count == 0) then
                break
            end
        end
    end

    self:refresh()
end
