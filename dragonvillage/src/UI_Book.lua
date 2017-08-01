local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Book
-------------------------------------
UI_Book = class(PARENT, {
        m_mTabUI = 'map',

        -- refresh 체크 용도
        m_bookLastChangeTime = 'timestamp',

		m_roleRadioButton = 'UIC_RadioButton',
        m_attrRadioButton = 'UIC_RadioButton',
		m_preAttr = 'string',

        m_tableViewTD = 'UIC_TableViewTD',
        m_sortManager = 'SortManager',

		m_tNotiSpriteTable = 'List<Sprite>',
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
    local vars = self:load('book.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Book')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	self.m_tNotiSpriteTable = {}
    self.m_bookLastChangeTime = g_bookData:getLastChangeTimeStamp()

	self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
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
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Book:initButton()
    local vars = self.vars

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
        --radio_button:addButton('all', vars['attrAllBtn'])
        radio_button:addButton('fire', vars['fireBtn'])
        radio_button:addButton('water', vars['waterBtn'])
        radio_button:addButton('earth', vars['earthBtn'])
        radio_button:addButton('dark', vars['darkBtn'])
        radio_button:addButton('light', vars['lightBtn'])
        radio_button:setSelectedButton('fire')
        radio_button:setChangeCB(function() self:onChangeOption() end)
        self.m_attrRadioButton = radio_button
    end

	-- 오름차순/내림차순 버튼
    vars['sortOrderBtn']:registerScriptTapHandler(function()
		local ascending = (not self.m_sortManager.m_defaultSortAscending)
		self.m_sortManager:setAllAscending(ascending)
		
		local list = self.m_tableViewTD.m_itemList
		self.m_sortManager:sortExecution(list)
		self.m_tableViewTD:setDirtyItemList()

		local order_spr = vars['sortOrderSprite']
		order_spr:stopAllActions()
		if ascending then
			order_spr:runAction(cc.RotateTo:create(0.15, 180))
		else
			order_spr:runAction(cc.RotateTo:create(0.15, 0))
		end
	end)

    -- 최초에 한번 실행
    self:onChangeOption()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Book:refresh()
	-- 수집 현황
	self:refresh_collect()

	-- 보상 노티
	self:refresh_noti()
end

-------------------------------------
-- function refresh_collect
-------------------------------------
function UI_Book:refresh_collect()
	local coll_cnt = g_bookData:getCollectCount()
	local total_cnt = table.count(g_bookData:getBookList())
	self.vars['collectLabel']:setString(Str('{1} / {2}', coll_cnt, total_cnt))
end

-------------------------------------
-- function refresh_noti
-------------------------------------
function UI_Book:refresh_noti()
	-- 노티를 전부 끈다.
	do
		for _, spr in pairs(self.m_tNotiSpriteTable) do
			spr:setVisible(false)
		end
	end

	-- 노티를 켠다
	local vars = self.vars
	local t_noti = g_bookData:getBookNotiList()
	for noti, _ in pairs(t_noti) do
		-- 없으면 생성
		if (not self.m_tNotiSpriteTable[noti]) then
			local spr = cc.Sprite:create('res/ui/icons/noti_icon_0101.png')
			spr:setAnchorPoint(CENTER_POINT)
			spr:setDockPoint(cc.p(1, 1))
			spr:setPosition(-5, -5)
			vars[noti .. 'Btn']:addChild(spr)
			self.m_tNotiSpriteTable[noti] = spr

		-- 있으면 킴
		else
			self.m_tNotiSpriteTable[noti]:setVisible(true)

		end
	end
end

-------------------------------------
-- function makeSortManager
-- @brief
-------------------------------------
function UI_Book:makeSortManager()
    local sort_manager = SortManager_Dragon()

	-- 진화도는 무조건 우열을 가름
    local function sort_evolution(a, b, ascending)
		local a_data = a['data']
		local b_data = b['data']

		local a_value = a_data['evolution']
		local b_value = b_data['evolution']

		-- nil return 을 하지 않음
		if (a_value == b_value) then return nil end

		-- 오름차순 or 내림차순
		if ascending then return a_value < b_value
		else              return a_value > b_value
		end
    end
    sort_manager:addSortType('evolution', false, sort_evolution)
	
    local function sort_grade(a, b, ascending)
		local a_data = a['data']
		local b_data = b['data']

		local a_value = a_data['grade']
		local b_value = b_data['grade']

		-- nil return 을 하지 않음
		-- if (a_value == b_value) then return nil end

		-- 오름차순 or 내림차순
		if ascending then return a_value < b_value
		else              return a_value > b_value
		end
    end
    -- sort_manager:addSortType('grade', false, sort_grade)
	

	-- 진화도부터 체크 후에 등급 체크
	sort_manager:pushSortOrder('evolution', false)
    --sort_manager:pushSortOrder('grade', false)

    self.m_sortManager = sort_manager
end

-------------------------------------
-- function onChangeOption
-- @brief
-------------------------------------
function UI_Book:onChangeOption()
    local role_option = self.m_roleRadioButton.m_selectedButton
    local attr_option = self.m_attrRadioButton.m_selectedButton
	
	-- 속성을 옮길 경우 항상 전체직업군을 가리키도록 한다.
	if (role_option ~= 'all') and (attr_option ~= self.m_preAttr) then
		self.m_preAttr = attr_option
		self.m_roleRadioButton:setSelectedButton('all')
		return
	end

    local l_item_list = g_bookData:getBookList(role_option, attr_option)

    -- 리스트 머지 (조건에 맞는 항목만 노출)
    self.m_tableViewTD:mergeItemList(l_item_list)

    -- 정렬
    self.m_sortManager:sortExecution(self.m_tableViewTD.m_itemList)

	self.m_preAttr = attr_option
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
    local item_scale = 0.75
    local cell_size = cc.size(item_size*item_scale + 12, item_size*item_scale + 12)

	local table_view_td

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        self.cellCreateCB(ui, data, self)
    end

    -- 테이블 뷰 인스턴스 생성
    table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cell_size
    table_view_td.m_nItemPerCell = 8
	table_view_td:setCellUIClass(UI_BookDragonCard, create_func)
    table_view_td:setItemList(l_item_list)
	
	table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)

    -- 정렬
    self.m_tableViewTD = table_view_td
end

-------------------------------------
-- function cellCreateCB
-- @static
-- @brief cell 생성 후의 콜백
-------------------------------------
function UI_Book.cellCreateCB(ui, data, book_ui)
	local did = data['did']
	local grade = data['grade']
	local evolution = data['evolution']

    -- scale 조정
	ui.root:setScale(0.8)

	-- 수집 여부에 따른 음영 처리
	if (not g_bookData:isExist(data)) then
		ui:setShadowSpriteVisible(true)
	end

	-- 보상 수령 가능하면 보상 아이콘 출력
	if (g_bookData:haveBookReward(did, evolution)) then
		ui:setBookRewardVisual(true)
	end

	-- 버튼 클릭시 상세 팝업
	ui.vars['clickBtn']:registerScriptTapHandler(function()
        
		-- 보상이 있다면 보상 수령
		if (g_bookData:haveBookReward(did, evolution)) then
            local pre_cash = g_userData:get('cash')
			local function finish_cb(cash)
				local reward_value = cash - pre_cash
				local reward_str = Str('다이아 {1}개를 수령했습니다.', reward_value)
				UI_ToastPopup(reward_str)
				ui:setBookRewardVisual(false)
				book_ui:refresh_noti()
			end
			g_bookData:request_bookReward(did, evolution, finish_cb)
				
		-- 없으면 상세 팝업
		else
			local detail_ui = UI_BookDetailPopup(data)
			detail_ui:setBookList(book_ui.m_tableViewTD.m_itemList)
		end
	end)
end

-------------------------------------
-- function click_bookPointBtn
-- @brief 콜랙션 포인트 보상 확인 버튼
-------------------------------------
function UI_Book:click_bookPointBtn()
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
    local is_changed = g_bookData:checkChange(self.m_bookLastChangeTime)

    if is_changed then
        self.m_bookLastChangeTime = g_bookData:getLastChangeTimeStamp()
        self:refresh()
    end
end

--@CHECK
UI:checkCompileError(UI_Book)
