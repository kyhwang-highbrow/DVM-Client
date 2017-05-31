local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonBoardPopup
-------------------------------------
UI_DragonBoardPopup = class(PARENT,{
		m_tBoardData = 'table',
		m_did = 'number',
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

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonBoardPopup:initUI()
	local vars = self.vars
	vars['gradeGauge']:setPercentage(0)
	vars['gradeLabel']:setString(Str('평점 {1}', string.format('%.1f', 0)))
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
	local did = self.m_did

	local function cb_func()
		local vars = self.vars

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
		local grade = t_board_data['rate']
		vars['gradeGauge']:runAction(cc.ProgressTo:create(0.3, grade/5 * 100))
		vars['gradeLabel']:setString(Str('평점 {1}', string.format('%.1f', grade)))

		-- tableView
		self:makeTableView()
	end

	g_boardData:request_dragonBoard(did, cb_func)
end

-------------------------------------
-- function makeMailTableView
-------------------------------------
function UI_DragonBoardPopup:makeTableView()
	local node = self.vars['listNode']
	node:removeAllChildren(true)

	local l_item_list = self.m_tBoardData['boards']
	if (self.m_tBoardData['myboard']) then
		table.insert(l_item_list, 1, self.m_tBoardData['myboard'])
	end

	-- 생성 콜백
    local function create_func(ui, data)
		-- 평가 삭제
        local function click_deleteBtn()
            ui:click_deleteBtn()
			self:refresh()
        end
        ui.vars['deleteBtn']:registerScriptTapHandler(click_deleteBtn)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(884, 155)
    table_view:setCellUIClass(UI_DragonBoardListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    table_view:makeDefaultEmptyDescLabel(Str('첫번째 리뷰를 남겨주세요!'))
end

-------------------------------------
-- function click_assessBtn
-- @brief 평가 게시판
-------------------------------------
function UI_DragonBoardPopup:click_assessBtn()
	local did = self.m_did
	local my_rate = self.m_tBoardData['myrate']

	local ui = UI_DragonBoardPopup_Evaluate(did, my_rate)
	ui:setCloseCB(function() self:refresh() end)
end

-------------------------------------
-- function click_writeBtn
-- @brief 평가 게시판
-------------------------------------
function UI_DragonBoardPopup:click_writeBtn()
	if (self.m_tBoardData['myboard']) then
		UIManager:toastNotificationGreen(Str('이미 평가 글을 작성했습니다. 나의 평가를 삭제하고 다시 작성해주세요.'))
		return
	end

	local did = self.m_did
	local ui = UI_DragonBoardPopup_Write(did)
	ui:setCloseCB(function() self:refresh() end)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonBoardPopup:click_exitBtn()
	self:close()
end


--@CHECK
UI:checkCompileError(UI_DragonBoardPopup)
