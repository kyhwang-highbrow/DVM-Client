-------------------------------------
-- class UI_CollectionTabGrade
-------------------------------------
UI_CollectionTabGrade = class({
        vars = 'table',
        m_ownerUI = 'UI',

        m_roleRadioButton = 'UIC_RadioButton',
        m_attrRadioButton = 'UIC_RadioButton',

        m_tableView = 'UIC_TableView',
        m_sortManager = 'SortManager',

        -- refresh 체크 용도
        m_collectionLastChangeTime = 'timestamp',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionTabGrade:init(owner_ui)
    self.m_ownerUI = owner_ui
    self.vars = owner_ui.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_CollectionTabGrade:onEnterTab(first)
    if first then
        self.m_collectionLastChangeTime = g_collectionData:getLastChangeTimeStamp()
        self:initUI()
    end
end

-------------------------------------
-- function initUI
-- @brief
-------------------------------------
function UI_CollectionTabGrade:initUI()
    local vars = self.vars

    self:makeSortManager()

    -- 테이블 뷰 생성
    self:init_TableViewTD()

    do -- 역할(role)
        local radio_button = UIC_RadioButton()
        radio_button:addButton('all', vars['roleAllBtn'])
        radio_button:addButton('tanker', vars['tankerBtn'])
        radio_button:addButton('dealer', vars['dealerBtn'])
        radio_button:addButton('supporter', vars['supporterBtn'])
        radio_button:addButton('healer', vars['healerBtn'])
        radio_button:setSelectedButton('all')
        radio_button:setChangeCB(function() self:onChangeOption() end)
        self.m_roleRadioButton = radio_button
    end

    do -- 속성(attribute)
        local radio_button = UIC_RadioButton()
        radio_button:addButton('all', vars['attrAllBtn'])
        radio_button:addButton('fire', vars['fireBtn'])
        radio_button:addButton('water', vars['waterBtn'])
        radio_button:addButton('earth', vars['earthBtn'])
        radio_button:addButton('dark', vars['darkBtn'])
        radio_button:addButton('light', vars['lightBtn'])
        radio_button:setSelectedButton('all')
        radio_button:setChangeCB(function() self:onChangeOption() end)
        self.m_attrRadioButton = radio_button
    end

    -- 최초에 한번 실행
    self:onChangeOption()
end

-------------------------------------
-- function makeSortManager
-- @brief
-------------------------------------
function UI_CollectionTabGrade:makeSortManager()
    local sort_manager = SortManager_Dragon()

    -- did선에서 무조건 우열을 가리도록 설정
    local function sort_did(a, b, ascending)
        local a_data = a['data']
        local b_data = b['data']

        local a_value = a_data['did']
        local b_value = b_data['did']

        -- 오름차순 or 내림차순
        if ascending then return a_value < b_value
        else              return a_value > b_value
        end
    end
    sort_manager:addSortType('did', false, sort_did)

    -- did 내림차순
    sort_manager:pushSortOrder('did', false)

    -- 역할 내림차순
    sort_manager:pushSortOrder('role', false)

    -- 레어도 내림차순
    sort_manager:pushSortOrder('rarity', false)

    self.m_sortManager = sort_manager
end

-------------------------------------
-- function onChangeOption
-- @brief
-------------------------------------
function UI_CollectionTabGrade:onChangeOption()
    local role_option = self.m_roleRadioButton.m_selectedButton
    local attr_option = self.m_attrRadioButton.m_selectedButton

    local l_item_list = g_collectionData:getCollectionList(role_option, attr_option)

    -- 리스트 머지 (조건에 맞는 항목만 노출)
    self.m_tableView:mergeItemList(l_item_list)

    -- 정렬
    self.m_sortManager:sortExecution(self.m_tableView.m_itemList)
end

-------------------------------------
-- function init_TableViewTD
-- @brief
-------------------------------------
function UI_CollectionTabGrade:init_TableViewTD()
    local node = self.vars['gradeListNode']

    local l_item_list = {}

    local width, height = UI_CollectionGradeCard:getUISize()

    local function click_cb(did, grade)
        self:click_dragonCard(did, grade)
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui:setDragonCardClick(click_cb)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(width, height + 7)
    table_view:setCellUIClass(UI_CollectionGradeCard, create_func)
	table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    -- 정렬
    self.m_tableView = table_view
end

-------------------------------------
-- function click_dragonCard
-- @brief
-------------------------------------
function UI_CollectionTabGrade:click_dragonCard(did, grade)
	ccdisplay(grade .. '등급 드래곤')
end

-------------------------------------
-- function checkRefresh
-- @brief 도감 데이터가 변경되었는지 확인 후 변경되었으면 갱신
-------------------------------------
function UI_CollectionTabGrade:checkRefresh()
    local is_changed = g_collectionData:checkChange(self.m_collectionLastChangeTime)

    if is_changed then
        self.m_collectionLastChangeTime = g_collectionData:getLastChangeTimeStamp()

        -- 리스트 refresh
        self.m_tableView:refreshAllItemUI()
    end
end