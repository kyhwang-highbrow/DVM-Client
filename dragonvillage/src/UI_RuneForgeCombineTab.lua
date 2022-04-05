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

        m_runeType = 'string', -- normal, ancient
        ---------------------------------
        m_mSelectRuneMap = 'map', -- grade마다 현재 선택되어있는 룬 저장하는 map, map[grade][roid]
        m_mCombineDataMap = 'map', -- 합성 정보 저장, map[unique_key] = StructRuneCombine
        m_currUniqueKey = 'number', -- StructRuneCombine의 유니크 키를 생성하기 애매한 부분이 있어서 숫자로 관리
        ---------------------------------
        m_bDoingAutoBtn = 'boolean', -- 자동 등록 버튼 로직이 돌고 있다면 true (연속해서 빠르게 누를 때 렉 걸리는거 방지)
    })

UI_RuneForgeCombineTab.CARD_SCALE = 0.51
UI_RuneForgeCombineTab.CARD_CELL_SIZE = cc.size(78, 78)
UI_RuneForgeCombineTab.MAX_COMBINE_COUNT = 10 -- 한번에 합성 가능한 최대 갯수

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeCombineTab:init(owner_ui)
    local vars = self:load('rune_forge_combine.ui')
    
    self.m_sortGrade = 0
    self.m_runeType = 'normal'

    self:initBtn()
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgeCombineTab:onEnterTab(first)
    self.m_ownerUI:hideNpc() -- NPC 숨김

    if (first == true) then
        self:initUI()
        self:refresh()
    else
        -- 초기화
        self.m_uicSortList:setSelectSortType(0) -- 필터 '전체' 선택
    end
end



-------------------------------------
-- function initBtn
-------------------------------------
function UI_RuneForgeCombineTab:initBtn()
    local vars = self.vars
    -- infoBtn
    if (vars['infoBtn']) then 
        if IS_DEV_SERVER() and  IS_TEST_MODE() then
            vars['infoBtn']:registerScriptTapHandler(function()
                if (self.m_runeType == 'normal') then
                    self.m_runeType = 'ancient'
                else
                    self.m_runeType = 'normal'
                end
                self:initTableView()
                self:initCombineTableView()

                self:refresh()
            end)
        else
            vars['infoBtn']:registerScriptTapHandler(function() UI_RuneForgeCombineHelp() end)
        end
    end
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
    vars['combineBtn']:registerScriptTapHandler(function() self:click_combineBtn() end)

    local uic_sort_list = MakeUICSortList_runeCombine(vars['sortBtn'], vars['sortLabel'])
    uic_sort_list:setSelectSortType(0) -- 필터 '전체' 선택
    self.m_uicSortList = uic_sort_list
    
    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        self.m_sortGrade = sort_type
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
    
    -- 기존 테이블뷰 삭제
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

        
        -- UI_RuneCard의 press_clickBtn으로 열린 UI_ItemInfoPopup이 닫힐 때 불리는 callback function
        local function close_info_callback()
            -- 룬이 잠금처리 되어 있을 경우 tableview에서 삭제
            if ui:isRuneLock() then
                local roid = ui.m_runeData:getObjectId()
                -- 우측 m_combineTableView의 UI_RuneForgeCombineItem 에서 해체
                local combine_item_ui = self:FindCombineItem(roid)

                if combine_item_ui then
                    combine_item_ui:click_rune(ui.m_runeData)
                end

                -- 좌측 m_tableView에서 제거
                self.m_tableView:delItem(roid)
                self:refresh()
            end
        end

        ui:setCloseInfoCallback(close_info_callback)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = UI_RuneForgeCombineTab.CARD_CELL_SIZE
    table_view_td.m_nItemPerCell = 6
    table_view_td:setCellUIClass(make_func, create_func)
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    table_view_td:makeDefaultEmptyDescLabel(Str('룬 가방이 비어있습니다.\n다양한 전투를 통해 룬을 획득해보세요!'))
    self.m_tableView = table_view_td

    -- 재료로 사용 가능한 리스트를 얻어옴
    local grade = self.m_sortGrade
    local lock_include = false
    local l_rune_list = g_runesData:getUnequippedRuneList(nil, grade, lock_include, self.m_runeType) -- param : set_id, grade, lock_include
    local l_rune_no_ancient_list = {}

    for roid, t_rune_data in pairs(l_rune_list) do
        --if (not t_rune_data:isAncientRune()) then
            l_rune_no_ancient_list[roid] = t_rune_data
        --end
    end

    self.m_tableView:setItemList(l_rune_no_ancient_list)

    if (self.m_sortManager == nil) then
        local sort_manager = SortManager_Rune()
        self.m_sortManager = sort_manager
    else
        vars['sortOrderSprite']:setRotation(180)
    end

    -- 정렬 우선순위 : 등급 - 희귀도 - 세트 - 슬롯
    self.m_sortManager:pushSortOrder('slot', true)
	self.m_sortManager:pushSortOrder('set_id', true)
	self.m_sortManager:pushSortOrder('rarity', true)
    self.m_sortManager:pushSortOrder('grade', true)
    self.m_sortManager:sortExecution(self.m_tableView.m_itemList)

     do -- 오름차순/내림차순 버튼
        local function click()
            local sort_manager = self.m_sortManager
            local ascending

            -- 등급이 정해져있을때는 부가옵션들을 변경해준다.
            if (self.m_sortGrade ~= 0) then
                ascending = (not sort_manager.m_mSortType['rarity']['ascending'])
                sort_manager.m_mSortType['rarity']['ascending'] = ascending
                sort_manager.m_mSortType['set_id']['ascending'] = ascending
                sort_manager.m_mSortType['slot']['ascending'] = ascending
            
            -- 등급이 정해져있지 않을땐 등급의 정렬 순서만 변경한다. (나머지 옵션들은 다 오름차순)
            else
                ascending = (not sort_manager.m_mSortType['grade']['ascending'])
                sort_manager.m_mSortType['grade']['ascending'] = ascending
            end
            
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

    -- 선택된 룬 초기화
    self.m_mSelectRuneMap = {}
    for grade = 1, 7 do
        self.m_mSelectRuneMap[grade] = {}
    end
end

-------------------------------------
-- function initCombineTableView
-- @brief 오른쪽 합성 테이블뷰 생성
-------------------------------------
function UI_RuneForgeCombineTab:initCombineTableView()
    local vars = self.vars
    local node = vars['runeCombineTableViewNode']
    
    -- 기존 테이블뷰 삭제
    node:removeAllChildren()
    
    -- 리스트 아이템 생성 콜백
    local function make_func(object)
        return UI_RuneForgeCombineItem(self, object)
    end

    local function create_func(ui, data)
    end

    -- 테이블뷰 생성
    self.m_currUniqueKey = 1
    self.m_bDoingAutoBtn = false
    self.m_mCombineDataMap = {}
    local l_item_list = self.m_mCombineDataMap

    
    
   
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(530, 105)
    table_view:setCellUIClass(make_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	table_view:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view:setItemList(l_item_list)
    self.m_combineTableView = table_view
    
    for i = 1, UI_RuneForgeCombineTab.MAX_COMBINE_COUNT do
        self:addCombineItem(nil)
    end

    table_view:makeAllItemUINoAction()

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeCombineTab:refresh()
    local vars = self.vars
    
    -- 현재 선택된 룬 개수 표기
    local all_count = table.count(self.m_tableView.m_itemList)
    local select_count = 0
    for grade = 1, 7 do
        select_count = select_count + table.count(self.m_mSelectRuneMap[grade])
    end
    vars['countLabel']:setString(Str('선택된 룬') .. Str(' {@white}{1}/{2}', select_count, all_count))

    -- 현재 합성 개수 표기
    local combine_max_count = UI_RuneForgeCombineTab.MAX_COMBINE_COUNT
    local combine_count = 0
    for i, v in pairs(self.m_mCombineDataMap) do
        if (v:isFull()) then
            combine_count = combine_count + 1
        end
    end
    vars['selectLabel']:setString(Str('{1}/{2}', combine_count, combine_max_count))

    self:refreshCombineItems()
end

-------------------------------------
-- function refreshCombineItems
-- @brief 합성 정보 UI 갱신
-------------------------------------
function UI_RuneForgeCombineTab:refreshCombineItems()
    self.m_combineTableView:refreshAllItemUI()
end


-------------------------------------
-- function FindCombineItem
-- @brief 주어진 id를 가진 UI_RuneForgeCombineItem을 찾음
-- @param roid : rune object id
-- @return 조건에 맞는 ui가 있으면 리턴, 아니면 nil을 리턴
-------------------------------------
function UI_RuneForgeCombineTab:FindCombineItem(roid)
    for i = 1, self.m_currUniqueKey do
        local item_ui = self.m_combineTableView:getCellUI(i)

        if item_ui and item_ui.m_runeCombineData:hasRuneObject(roid) then
            return item_ui
        end
    end

    return nil
end

-------------------------------------
-- function addCombineItem
-- @brief 합성 UI 추가
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

    self.m_currUniqueKey = self.m_currUniqueKey + 1
end

-------------------------------------
-- function removeCombineItem
-- @brief 합성 UI 제거
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
    
    local select_roid_map = self.m_mSelectRuneMap[grade]

    if (select_roid_map[roid] == nil) then
        self:selectRune(t_rune_data)

    else 
        self:deselectRune(t_rune_data)
    end

    if t_rune_data:getLock() then
        --self:initTableView()
        --self:initCombineTableView()
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
        if (grade == combine_data.m_grade) or (combine_data.m_grade == nil) then
            local b_is_full = combine_data:isFull() -- 추가적인 룬 등록이 가능한 상태인가
            if not b_is_full then
                b_add_rune = true
                combine_data_id = unique_key
                combine_data:addRuneObject(t_rune_data)
                break
            end
        end
    end

    -- 룬이 재료로 등록될 자리가 없는 경우
    if (not b_add_rune) then
        UIManager:toastNotificationRed(Str('한번에 합성 가능한 룬 개수를 초과했습니다.'))
        return
    end

    local data = {}
    data['combine_id'] = combine_data_id
    data['data'] = t_rune_data
    select_roid_map[roid] = data

    local rune_card = self.m_tableView:getCellUI(roid)
    rune_card:setCheckSpriteVisible(true)

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

    if (not select_roid_map) or (not select_roid_map[roid]) then
        return
    end
    
    local combine_data_id = select_roid_map[roid]['combine_id']
    local combine_data = self.m_mCombineDataMap[combine_data_id]
    combine_data:removeRuneObject(roid)
    
    if (combine_data:isEmpty()) then
        combine_data.m_grade = nil
    end
    
    select_roid_map[roid] = nil
    
    local rune_card = self.m_tableView:getCellUI(roid)
    rune_card:setCheckSpriteVisible(false)
end

-------------------------------------
-- function click_autoBtn
-- @brief 자동 등록
-------------------------------------
function UI_RuneForgeCombineTab:click_autoBtn()
    -- 로직 돌고 있는 동안 또 돌지 않게 
    if (self.m_bDoingAutoBtn == true) then
        return
    end
    self.m_bDoingAutoBtn = true

    local clone_table_item_list = clone(self.m_tableView.m_itemList)

    -- 1. 유저가 등록한 룬이 존재하던 조합 재료부터 채운다.
    for combine_data_id, combine_data in pairs(self.m_mCombineDataMap) do
        -- 아직 등록되지 않은 재료 룬이 있는 경우에
        if (not combine_data:isFull()) then
            local combine_grade = combine_data.m_grade
            local select_roid_map = self.m_mSelectRuneMap[combine_grade]

            -- 무언가 하나라도 등록되어서 등급이 정해져있던 경우
            if (combine_grade ~= nil) then
                -- 왼쪽 창에서 선택되지 않은 것들을 차례로 골라서 넣는다
                for i, v in ipairs(clone_table_item_list) do
                    local t_rune_data = v['data']
                    local roid = t_rune_data['roid']
                    local grade = t_rune_data['grade']
                
                    -- 같은 등급에 아직 선택되지 않은 룬이라면
                    if ((grade == combine_grade) and (select_roid_map[roid] == nil)) then
                        -- 합성 정보에 룬 정보 등록
                        combine_data:addRuneObject(t_rune_data)

                        -- self에 룬 정보 등록
                        local data = {}
                        data['combine_id'] = combine_data_id
                        data['data'] = t_rune_data
                        select_roid_map[roid] = data
                    
                        -- 룬 카드에 체크 표시 추가
                        local rune_card = self.m_tableView:getCellUI(roid)
                        rune_card:setCheckSpriteVisible(true)

                        -- 현재 합성 정보 빈 칸 다 채웠는지 확인
                        if (combine_data:isFull() == true) then
                            break
                        end
                    end
                end
            end
        end
    end

    -- 2. 유저가 아무것도 등록하지 않았던 합성 재료를 '전부' 채우는 게 가능할 때 채운다
    local check_item_idx = 0
    for combine_data_id, combine_data in pairs(self.m_mCombineDataMap) do
        -- 아직 아무것도 들어서지 않은 경우
        if (combine_data.m_grade == nil) then
            local curr_grade = nil
            local l_roid_list = {}
            local l_rune_data_list = {}
            -- 왼쪽 창에서 선택되지 않은 것들을 차례로 골라서 넣는다
            for idx, v in ipairs(clone_table_item_list) do
                -- 매 루프마다 어디까지 검사했었나 저장하여 효율적인 탐색
                if (check_item_idx < idx ) then
                    check_item_idx = idx
                    
                    local check_rune_data = v['data']
                    local roid = check_rune_data['roid']
                    local grade = check_rune_data['grade']
                    local select_roid_map = self.m_mSelectRuneMap[grade]

                    -- 현재 바라보는 등급 정하기
                    if ((curr_grade == nil) or (curr_grade ~= grade)) then
                        curr_grade = grade
                        l_roid_list = {}
                        l_rune_data_list = {}
                    end

                    -- 같은 등급에 아직 선택되지 않은 룬이라면
                    if ((grade == curr_grade) and (select_roid_map[roid] == nil)) then
                        table.insert(l_roid_list, roid)
                        table.insert(l_rune_data_list, check_rune_data)

                        -- 다 채우는 게 가능한 경우 합성 재료 등록
                        if (table.count(l_roid_list) == RUNE_COMBINE_REQUIRE) then
                            
                            for i, roid in ipairs(l_roid_list) do
                                -- 합성 정보에 룬 정보 등록
                                local t_rune_data = l_rune_data_list[i]
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

                            break
                        end
                    end
                end
            end
        end
    end

    self:refresh()
    
    -- 마구잡이로 해당 버튼을 누르면 렉을 유발하니까 딜레이를 준다.
    local function reserve_func()
        self.m_bDoingAutoBtn = false
    end

    local node = self.root
    cca.reserveFunc(node, 0.3, reserve_func)
end

-------------------------------------
-- function click_combineBtn
-- @brief 합성 요청
-------------------------------------
function UI_RuneForgeCombineTab:click_combineBtn()
    local uid = g_userData:get('uid')
    local src_roids = ''
    local full_combine_data_id_list = {}

    for combine_data_id, combine_data in pairs(self.m_mCombineDataMap) do
        if (combine_data:isFull()) then -- 재료가 전부 등록된 것만 합성되어 이후 화면에서 제거됨
            local roids = combine_data:getRoids()
            if (src_roids == '') then
                src_roids = roids
            else
                src_roids = src_roids .. ',' .. roids
            end
        
            table.insert(full_combine_data_id_list, combine_data_id)
        end
    end

    if (src_roids == '') then
        UIManager:toastNotificationRed(Str('합성에 필요한 룬이 부족합니다.'))
        return
    end

    local ok_btn_cb
    local close_cb
    local finish_cb

    local runeType = (self.m_runeType == 'normal') and 0 or 1
    ok_btn_cb = function()
        g_runesData:request_runeCombine(src_roids, runeType, finish_cb)
    end

    close_cb = function()
        self:initTableView()
        self:initCombineTableView()

        self:refresh()
    end

    finish_cb = function(ret)
		local gacha_type = 'combine'
        local l_rune_list = ret['runes']

        local ui = UI_GachaResult_Rune(gacha_type, l_rune_list)
        
        ui:setCloseCB(close_cb)
    end

    local combine_result_rune_count = table.count(full_combine_data_id_list) 
    local combine_material_rune_count = combine_result_rune_count * RUNE_COMBINE_REQUIRE
    local combine_str = Str('{@MUSTARD}{1}개{@DESC} 룬을 재료로 사용하여 {@MUSTARD}{2}개{@DESC} 룬을 합성합니다.\n합성하시겠습니까?', combine_material_rune_count, combine_result_rune_count)
	MakeSimplePopup(POPUP_TYPE.YES_NO, combine_str, ok_btn_cb)
end







-------------------------------------
-- class UI_RuneForgeCombineHelp
-------------------------------------
UI_RuneForgeCombineHelp = class(UI, {
})

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeCombineHelp:init(owner_ui)
    local vars = self:load('rune_forge_combine_info_popup.ui')
    
    UIManager:open(self, UIManager.POPUP)

    self:initButton()
end

function UI_RuneForgeCombineHelp:initButton()
    local vars = self.vars

    -- infoBtn
    if (vars['closeBtn']) then vars['closeBtn']:registerScriptTapHandler(function() self:close() end) end
end
