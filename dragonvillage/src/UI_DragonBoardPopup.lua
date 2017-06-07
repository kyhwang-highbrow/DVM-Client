local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonBoardPopup
-------------------------------------
UI_DragonBoardPopup = class(PARENT,{
		m_tBoardData = 'table',
		
		m_didSource = 'number',
		m_did = 'number',
		m_offset = 'number',
		m_order = 'string',
		
		m_tableView = 'UIC_TableView',
		m_attrRadioButton = 'UIC_RadioButton',
		m_uicSortList = 'UIC_SortList',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonBoardPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonBoardPopup'
    self.m_titleStr = Str('드래곤 게시판')
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonBoardPopup:init(t_dragon_data)
    local vars = self:load('dragon_board.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonBoardPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- initialize
	self.m_did = t_dragon_data['did']
	self.m_offset = 0

    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonBoardPopup:initUI()
	local vars = self.vars
	
	-- 통신하는 동안 에쁘게 보이도록 수정
	vars['dragonNameLabel']:setString('')
	vars['gradeGauge']:setPercentage(0)
	vars['gradeLabel']:setString(Str('평점 {1}', string.format('%.1f', 0)))

    self:makeAttrOptionRadioBtn()
	self:makeUICSortList()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonBoardPopup:initButton()
	local vars = self.vars

    vars['assessBtn']:registerScriptTapHandler(function() self:click_assessBtn() end)
	vars['writeBtn']:registerScriptTapHandler(function() self:click_writeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonBoardPopup:refresh()
	local vars = self.vars
	local did = self.m_did

	local t_dragon = TableDragon():get(did)
	local t_board_data = g_boardData:getBoards(did)
	self.m_tBoardData = t_board_data

	-- 이름
	vars['dragonNameLabel']:setString(Str(t_dragon['t_name']))

	-- 카드
	vars['dragonNode']:removeAllChildren()
	local card = MakeSimpleDragonCard(did)
	vars['dragonNode']:addChild(card.root)

	-- 평점
	self:refresh_rate(t_board_data['rate'])

	-- tableView
	self:makeTableView()
end

-------------------------------------
-- function refresh_rate
-------------------------------------
function UI_DragonBoardPopup:refresh_rate(rate)
	local vars = self.vars
	local rate = rate or g_boardData:getRate(self.m_did)

	vars['gradeGauge']:runAction(cc.ProgressTo:create(0.3, rate/5 * 100))
	vars['gradeLabel']:setString(Str('평점 {1}', string.format('%.1f', rate)))
end

-------------------------------------
-- function requestBoard
-- @brief 평가 게시물을 다시 요청하고 초기화한다.
-------------------------------------
function UI_DragonBoardPopup:requestBoard()
	self.m_offset = 0

	local did = self.m_did
	local offset = self.m_offset
	local order = self.m_order

	local function cb_func()
		self:refresh()
	end

	g_boardData:request_dragonBoard(did, offset, order, cb_func)
end

-------------------------------------
-- function makeMailTableView
-------------------------------------
function UI_DragonBoardPopup:makeTableView()
	local node = self.vars['listNode']
	node:removeAllChildren(true)

	local l_item_list = self.m_tBoardData['boards']

	-- 생성 콜백
    local function create_func(ui, data)
		-- 평가 삭제
        local function click_deleteBtn()
            ui:click_deleteBtn()
			self:requestBoard() 
        end
        ui.vars['deleteBtn']:registerScriptTapHandler(click_deleteBtn)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
	table_view.m_bUseEachSize = true
    table_view.m_defaultCellSize = cc.size(884, 155)
    table_view:setCellUIClass(UI_DragonBoardListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list, true)
    table_view:makeDefaultEmptyDescLabel(Str('첫번째 리뷰를 남겨주세요!'))

	-- 테이블 뷰 scroll end callback
	if (table.count(l_item_list) == 10) then
		table_view:setScrollEndCB(function() self:onScrollEnd() end)
	end

	self.m_tableView = table_view
end

-------------------------------------
-- function makeAttrOptionRadioBtn
-- @brief
-------------------------------------
function UI_DragonBoardPopup:makeAttrOptionRadioBtn()
	local vars = self.vars

	-- 속성별 버튼 정의
    local radio_button = UIC_RadioButton()
	radio_button:addButton('fire', vars['fireBtn'])
	radio_button:addButton('water', vars['waterBtn'])
	radio_button:addButton('earth', vars['earthBtn'])
	radio_button:addButton('dark', vars['darkBtn'])
	radio_button:addButton('light', vars['lightBtn'])
	radio_button:setChangeCB(function() self:onChangeOption() end)
	self.m_attrRadioButton = radio_button

	-- 같은 종류의 드래곤을 속성별로 체크한다.
	local did = self.m_did
	local did_source = math_floor(did / 10) * 10
	self.m_didSource= did_source
	for i = 1, 5 do
		local t_dragon = TableDragon():get(did_source + i)
		if (not t_dragon) then
			local attr = attributeNumToStr(i)
			vars[attr .. 'Btn']:setVisible(false)
		end
	end 

	-- 현재 드래곤을 선택된 값으로 한다 
	local attr = TableDragon:getDragonAttr(self.m_did)
	self.m_attrRadioButton:setSelectedButton(attr)
end

-------------------------------------
-- function makeUICSortList
-- @brief
-------------------------------------
function UI_DragonBoardPopup:makeUICSortList()
	local button = self.vars['sortBtn']
	local label = self.vars['sortLabel']

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_SortList()
    uic.m_direction = UIC_SORT_LIST_TOP_TO_BOT
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    parent:addChild(uic.m_node)

    uic:addSortType('time', Str('최신 순'))
    uic:addSortType('like', Str('추천 순'))

	self.m_uicSortList = uic
	self.m_uicSortList:setSortChangeCB(function(sort_type) self:onSortChangeOption(sort_type) end)
end

-------------------------------------
-- function onScrollEnd
-- @brief 다음 10개 게시물을 가져온다.
-------------------------------------
function UI_DragonBoardPopup:onScrollEnd()
	self.m_offset = self.m_offset + 10
	local function cb_func(t_ret)
		if (table.count(t_ret) > 0) then
			self.m_tableView:addItemList(t_ret)
		else
			self.m_tableView:setScrollEndCB(nil)
		end
		self.m_tableView:setScrollLock(false)
	end
	g_boardData:request_dragonBoard(self.m_did, self.m_offset, self.m_order, cb_func)
end

-------------------------------------
-- function onChangeOption
-- @brief 속성 변경하고 평가 테이블을 새로 생성한다.
-------------------------------------
function UI_DragonBoardPopup:onChangeOption()
    local attr_option = self.m_attrRadioButton.m_selectedButton
	local attr_num = attributeStrToNum(attr_option)
	self.m_did = self.m_didSource + attr_num
	
	self:requestBoard()
end

-------------------------------------
-- function onSortChangeOption
-- @brief 정렬 순서를 변경하고 평가 테이블을 새로 생성한다.
-------------------------------------
function UI_DragonBoardPopup:onSortChangeOption(sort_type)
	self.m_uicSortList:hide()
	self.m_order = sort_type
	
	self:requestBoard()
end

-------------------------------------
-- function click_assessBtn
-- @brief 별점
-------------------------------------
function UI_DragonBoardPopup:click_assessBtn()
	local did = self.m_did
	local my_rate = self.m_tBoardData['myrate']

	local ui = UI_DragonBoardPopup_Evaluate(did, my_rate)
	local function close_cb()
		self:refresh_rate()
	end
	ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_writeBtn
-- @brief 평가 쓰기
-------------------------------------
function UI_DragonBoardPopup:click_writeBtn()
	if (self.m_tBoardData['myboard']) then
		UIManager:toastNotificationGreen(Str('이미 평가 글을 작성했습니다. 나의 평가를 삭제하고 다시 작성해주세요.'))
		return
	end

	local did = self.m_did
	local ui = UI_DragonBoardPopup_Write(did)
	local function close_cb()
		self:requestBoard() 
	end
	ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonBoardPopup:click_exitBtn()
	self:close()
end


--@CHECK
UI:checkCompileError(UI_DragonBoardPopup)
