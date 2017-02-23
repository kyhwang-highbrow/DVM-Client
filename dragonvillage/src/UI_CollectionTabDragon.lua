-------------------------------------
-- class UI_CollectionTabDragon
-------------------------------------
UI_CollectionTabDragon = class({
        vars = 'table',
        m_ownerUI = 'UI',

        m_roleRadioButton = 'UIC_RadioButton',
        m_attrRadioButton = 'UIC_RadioButton',

        m_tableViewTD = 'UIC_TableViewTD',
        m_sortManager = 'SortManager',

        -- refresh 체크 용도
        m_collectionLastChangeTime = 'timestamp',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionTabDragon:init(owner_ui)
    self.m_ownerUI = owner_ui
    self.vars = owner_ui.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_CollectionTabDragon:onEnterTab(first)
    if first then
        self.m_collectionLastChangeTime = g_collectionData:getLastChangeTimeStamp()
        self:initUI()
    end
end

-------------------------------------
-- function initUI
-- @brief
-------------------------------------
function UI_CollectionTabDragon:initUI()
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
function UI_CollectionTabDragon:makeSortManager()
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
function UI_CollectionTabDragon:onChangeOption()
    local role_option = self.m_roleRadioButton.m_selectedButton
    local attr_option = self.m_attrRadioButton.m_selectedButton

    local l_item_list = g_collectionData:getCollectionList(role_option, attr_option)

    -- 리스트 머지 (조건에 맞는 항목만 노출)
    self.m_tableViewTD:mergeItemList(l_item_list)

    -- 정렬
    self.m_sortManager:sortExecution(self.m_tableViewTD.m_itemList)
end

-------------------------------------
-- function init_TableViewTD
-- @brief
-------------------------------------
function UI_CollectionTabDragon:init_TableViewTD()
    local node = self.vars['dragonListNode']
    --node:removeAllChildren()

    local l_item_list = {}

    -- 생성 콜백
    local scale = 0.8
    local function create_func(ui, data)
        ui.root:setScale(scale)

        ui.m_dragonCard.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(data) end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size((150 * scale) + 2, (188 * scale) + 5)
    table_view_td.m_nItemPerCell = 8
    table_view_td:setCellUIClass(UI_CollectionDragonCard, create_func)
    table_view_td:setItemList(l_item_list)
    --table_view_td:makeDefaultEmptyDescLabel(Str(''))

    -- 정렬
    self.m_tableViewTD = table_view_td
end

-------------------------------------
-- function click_dragonCard
-- @brief
-------------------------------------
function UI_CollectionTabDragon:click_dragonCard(data)
    local l_dragons_data = self.m_tableViewTD.m_itemList
    local did = data['did']
    local item = self.m_tableViewTD:getItem(did)
    local init_idx = item['idx']

    local ui = UI_CollectionDetailPopup(l_dragons_data, init_idx)
    local function close_cb()
        self:checkRefresh()
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function checkRefresh
-- @brief 도감 데이터가 변경되었는지 확인 후 변경되었으면 갱신
-------------------------------------
function UI_CollectionTabDragon:checkRefresh()
    local is_changed = g_collectionData:checkChange(self.m_collectionLastChangeTime)

    if is_changed then
        self.m_collectionLastChangeTime = g_collectionData:getLastChangeTimeStamp()

        -- 리스트 refresh
        self.m_tableViewTD:refreshAllItemUI()
    end
end