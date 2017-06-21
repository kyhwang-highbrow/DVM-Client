local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Book
-------------------------------------
UI_Book = class(PARENT, {
        m_mTabUI = 'map',

        -- refresh 체크 용도
        m_collectionLastChangeTime = 'timestamp',

		m_roleRadioButton = 'UIC_RadioButton',
        m_attrRadioButton = 'UIC_RadioButton',

        m_tableViewTD = 'UIC_TableViewTD',
        m_sortManager = 'SortManager',
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Book:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Book'
    self.m_bVisible = true
    self.m_titleStr = Str('도감')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_Book:init()
    local vars = self:load('collection.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Book')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()

    self.m_collectionLastChangeTime = g_collectionData:getLastChangeTimeStamp()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Book:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Book:initUI()
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
-- function initButton
-------------------------------------
function UI_Book:initButton()
    local vars = self.vars

    -- 콜랙션 포인트 보상 확인
    --vars['collectionPointBtn']:registerScriptTapHandler(function() self:click_collectionPointBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Book:refresh()
    local vars = self.vars

    do -- 콜랙션 포인트 임시 초기값
        --vars['titleLabel']:setString(Str(g_collectionData:getTamerTitle()))
        --vars['collectionPointLabel']:setString(comma_value(g_collectionData:getCollectionPoint()))
    end
end

-------------------------------------
-- function makeSortManager
-- @brief
-------------------------------------
function UI_Book:makeSortManager()
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
function UI_Book:onChangeOption()
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
function UI_Book:init_TableViewTD()
    local node = self.vars['dragonListNode']

    local l_item_list = {}

	-- cell_size 지정
    local item_size = 150
    local item_scale = 0.885
    local cell_size = cc.size(item_size*item_scale, item_size*item_scale)

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(item_scale)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cell_size
    table_view_td.m_nItemPerCell = 8
    table_view_td:setCellUIClass(UI_BookDragonCard, create_func)
    table_view_td:setItemList(l_item_list)

    -- 정렬
    self.m_tableViewTD = table_view_td
end

-------------------------------------
-- function click_collectionPointBtn
-- @brief 콜랙션 포인트 보상 확인 버튼
-------------------------------------
function UI_Book:click_collectionPointBtn()
    local ui = UI_BookPointReward()
    
    local function close_cb()
        self:checkRefresh()
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function checkRefresh
-- @brief 도감 데이터가 변경되었는지 확인 후 변경되었으면 갱신
-------------------------------------
function UI_Book:checkRefresh()
    local is_changed = g_collectionData:checkChange(self.m_collectionLastChangeTime)

    if is_changed then
        self.m_collectionLastChangeTime = g_collectionData:getLastChangeTimeStamp()
        self:refresh()
    end
end

--@CHECK
UI:checkCompileError(UI_Book)
