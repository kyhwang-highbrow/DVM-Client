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

        m_curDragonList = 'list',
     })


UI_Book.isOnceTouched = false

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
    local vars = self:load_keepZOrder('book.ui')
    UIManager:open(self, UIManager.SCENE)
    UI_Book.isOnceTouched = true
    self.m_curDragonList = {}

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

    self:focusDragonCardTab()
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
        radio_button:addButtonWithLabel('all', vars['roleAllRadioBtn'], vars['roleAllRadioLabel'])
        radio_button:addButtonAuto('tanker', vars)
        radio_button:addButtonAuto('dealer', vars)
        radio_button:addButtonAuto('supporter', vars)
        radio_button:addButtonAuto('healer', vars)
        radio_button:setSelectedButton('all')
        radio_button:setChangeCB(function() self:onChangeOption() end)
        self.m_roleRadioButton = radio_button
    end

    do -- 속성(attribute)
        local radio_button = UIC_RadioButton()
        --radio_button:addButton('all', vars['attrAllBtn'])
        radio_button:addButtonAuto('fire', vars)
        radio_button:addButtonAuto('water', vars)
        radio_button:addButtonAuto('earth', vars)
        radio_button:addButtonAuto('dark', vars)
        radio_button:addButtonAuto('light', vars)
        radio_button:setSelectedButton('earth')
        radio_button:setChangeCB(function() self:onChangeOption() end)
        self.m_attrRadioButton = radio_button
    end

    -- 모두 받기 버튼
    -- 기능은 만들었으나 사용되지 않음
	--vars['rewardAllBtn']:registerScriptTapHandler(function() self:click_rewardAll() end)
    vars['rewardAllBtn']:setVisible(false)
    local has_reward = g_bookData:hasReward()
    

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
    UIHelper:autoNoti(g_bookData:getBookNotiList(), self.m_tNotiSpriteTable, 'RadioBtn', self.vars)
end

-------------------------------------
-- function makeSortManager
-- @brief
-------------------------------------
function UI_Book:makeSortManager()
    local sort_manager = SortManager_Dragon()

    -- 자코랑 슬라임은 아래로 내림
	sort_manager:addPreSortType('object_type_book', false, function(a, b, ascending) return sort_manager:sort_object_type_book(a, b, ascending) end)

    -- 타입 순 정렬 추가
    sort_manager:addSortType('dragon_type', false, function(a, b, ascending) return sort_manager:sort_dragon_type(a, b, ascending) end)

    -- 등급, 타입, did, 진화도 순으로 정렬
    sort_manager:pushSortOrder('evolution')
	sort_manager:pushSortOrder('did')
    sort_manager:pushSortOrder('dragon_type')
    sort_manager:pushSortOrder('grade')

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

    local only_hatch = true
    local l_item_list = g_bookData:getBookList(role_option, attr_option, only_hatch)

    -- 리스트 머지 (조건에 맞는 항목만 노출)
    self.m_tableViewTD:mergeItemList(l_item_list)

    -- 정렬
    self.m_sortManager:sortExecution(self.m_tableViewTD.m_itemList)

	self.m_preAttr = attr_option

    -- 보상 있는 카드로 포커싱
    self:focusDragonCard()
end

-------------------------------------
-- function init_TableViewTD
-- @brief
-------------------------------------
function UI_Book:init_TableViewTD()
    local node = self.vars['dragonListNode']

    local l_item_list = {}
	local table_view_td

    -- 리스트 아이템 생성 콜백
    local function make_func(data)
        return UI_BookDragonCard_Bundle(data, self)
    end

    -- 테이블 뷰 인스턴스 생성
    table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(330 + 6, 160 + 6)
    table_view_td.m_nItemPerCell = 3
	table_view_td:setCellUIClass(make_func)
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

	-- 수집 여부에 따른 음영 처리
	if (not g_bookData:isExist(data)) then
		ui:setShadowSpriteVisible(true)
	end

	-- 보상 수령 가능하면 보상 아이콘 출력
	if (g_bookData:haveBookReward(did, evolution)) then
		ui:setBookRewardVisual(true)
        ui:setNotiSpriteVisible(true)
	end


	-- 버튼 클릭시 상세 팝업
	ui.vars['clickBtn']:registerScriptTapHandler(function()


        
		-- 보상이 있다면 보상 수령
		if (g_bookData:haveBookReward(did, evolution)) then
            local pre_cash = g_userData:get('cash')
			local function finish_cb(cash)
				local reward_value = cash - pre_cash
				local reward_str = Str('다이아 {1}개를 수령했습니다.', comma_value(reward_value))
				UI_ToastPopup(reward_str)
				ui:setBookRewardVisual(false)
				book_ui:refresh_noti()

                -- 테이블 리셋
                book_ui.m_tableViewTD:clearItemList()
                book_ui:onChangeOption()
                UI_Book.isOnceTouched = false
			end

            if UI_Book.isOnceTouched == true then
                return
            end

            UI_Book.isOnceTouched = true
			g_bookData:request_bookReward(did, evolution, finish_cb)
				
		-- 없으면 상세 팝업
		else
			local detail_ui = UI_BookDetailPopup(data)
			detail_ui:setBookList(book_ui.m_tableViewTD.m_itemList)
		end

        
	end)
end

-------------------------------------
-- function click_rewardAll
-------------------------------------
function UI_Book:click_rewardAll()
	-- 보상이 없다면
	local has_reward = g_bookData:hasReward()
	if (not has_reward) then
		UIManager:toastNotificationRed(Str('획득할 보상이 없습니다'))
		return
	end

	local pre_cash = g_userData:get('cash')
	local function finish_cb(cash)
		local reward_value = cash - pre_cash
		local reward_str = Str('다이아 {1}개를 수령했습니다.', comma_value(reward_value))
		UI_ToastPopup(reward_str)
		self:refresh_noti()
		self:setAllRewardReceieved()
        
        -- 더 이상 받을 보상이 없기 때문에 비활성화
        self:setRewardEnabled(false)
	end
	g_bookData:request_bookRewardAll(finish_cb)			
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

-------------------------------------
-- function setAllRewardReceieved
-- @brief 도감 보상의 리워드 표시 모두 비활성화(다 받았다는 표시)
-------------------------------------
function UI_Book:setAllRewardReceieved()
    local l_card = self.m_tableViewTD.m_itemList
    for i, t_data in ipairs(l_card) do
        if (t_data['ui']) then
            t_data['ui']:refresh()
        end
    end
end

-------------------------------------
-- function focusDragonCard
-- @brief 해당 탭에서 강조만 필요할 경우
-------------------------------------
function UI_Book:focusDragonCard()
	-- 인연포인트가 모아진 곳에 포커싱
	local l_item = self.m_tableViewTD.m_itemList
    for idx, data in ipairs(l_item) do
        local did = data['data']['did']
        for evolution = 1, 3 do
            local has_reward = g_bookData:haveBookReward(tonumber(did), evolution)
            if (has_reward) then
                self.m_tableViewTD:update(0)
                self.m_tableViewTD.m_bFirstLocation = false
	            self.m_tableViewTD:relocateContainerFromIndex(idx) -- idx,_show_cnt, _offset, max_pos_
                return        
            end
        end
    end

    self.m_tableViewTD:update(0)
    self.m_tableViewTD.m_bFirstLocation = false
    self.m_tableViewTD:relocateContainerFromIndex(0) 
end

-------------------------------------
-- function focusDragonCardTab
-- @brief 인연포인트 완성된 탭을 찾아 탭 세팅
-------------------------------------
function UI_Book:focusDragonCardTab()
	local focus_tab_name = self:getFocusTab()
	if (not focus_tab_name) then
        if (not self.m_tableViewTD) then
            self.m_attrRadioButton:setSelectedButton(focus_tab_name)
        end
        self:onChangeOption()

        self.m_tableViewTD:update(0)
        self.m_tableViewTD.m_bFirstLocation = false
		self.m_tableViewTD:relocateContainerFromIndex(0)	
		return
	end
    self.m_attrRadioButton:setSelectedButton(focus_tab_name)
	self:onChangeOption()
end

-------------------------------------
-- function getFocusTab
-- @brief  
-------------------------------------
function UI_Book:getFocusTab()
    local l_attr_tab = getAttrTextList()
	-- 탭 각각 인연포인트 완성된 탭을 찾음
	for i, attr_name in ipairs(l_attr_tab) do
		local l_dragon = self:getCurDragonList(attr_name)
		for did, data in pairs(l_dragon) do
			for evolution = 1, 3 do
				local has_reward = g_bookData:haveBookReward(data['did'], evolution)
				if (has_reward) then
            		return attr_name
				end
			end
		end
	end

	return nil
end

-------------------------------------
-- function getCurDragonList
-- @brief  
-------------------------------------
function UI_Book:getCurDragonList(attr)
    local role_option = self.m_roleRadioButton.m_selectedButton
    local attr_option = attr

    local l_item_list = g_bookData:getBookList(role_option, attr_option, true)
    return l_item_list
end

--@CHECK
UI:checkCompileError(UI_Book)
