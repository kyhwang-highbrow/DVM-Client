local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_QuestPopup
-------------------------------------
UI_QuestPopup = class(PARENT, {
		m_tIsOpenOnce = 'table<bool>',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_QuestPopup:init()
	self.m_tIsOpenOnce = {}

	local vars = self:load('quest.ui')
	UIManager:open(self, UIManager.POPUP)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_QuestPopup')

	-- @UI_ACTION
	--self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
	self:doActionReset()
	self:doAction(nil, false)

	-- 통신 후 UI 출력
	local cb_func = function()
		self:initUI()
		self:initTab()
		self:initButton()
		self:refresh()
	end 
	g_questData:requestQuestInfo(cb_func)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_QuestPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_QuestPopup'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('퀘스트')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_QuestPopup:initUI()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_QuestPopup:initTab()
    local vars = self.vars
    self:addTab(TableQuest.CHALLENGE, vars['challengeBtn'], vars['challengeListNode'])
    self:addTab(TableQuest.DAILY, vars['dailyBtn'], vars['dailyListNode'])
	self:addTab(TableQuest.NEWBIE, vars['newbieBtn'], vars['newbieListNode'])
    self:setTab(TableQuest.CHALLENGE)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_QuestPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_QuestPopup:refresh()
	-- 받을수 있는 보상이 있는지 검사하여 UI에 표시
	self:setNotiRewardable()
	-- @TODO 현재 테이블뷰를 다시 만든다.
	self:onChangeTab(self.m_currTab, 'force')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_QuestPopup:onChangeTab(tab, force)
	local vars = self.vars
	local node = vars[tab .. 'ListNode']
	
	-- 최초 생성만 실행
	if (not self.m_tIsOpenOnce[tab]) then 
		self:makeQuestTableView(tab, node)
		self.m_tIsOpenOnce[tab] = true
	end

	-- refresh 할때 강제로 호출
	if (force == 'force') then 
		self:makeQuestTableView(tab, node)
	end

	-- all clear 는 따로 보여준다
	self:setAllClearListItem(tab)
end

-------------------------------------
-- function makeQuestTableView
-------------------------------------
function UI_QuestPopup:makeQuestTableView(tab, node)
    local vars = self.vars

	-- 퀘스트 뭉치
	local t_quest = g_questData:getQuestListByType(tab)
	
    do -- 테이블 뷰 생성
        node:removeAllChildren()

		-- 퀘스트 팝업 자체를 각 아이템이 가지기 위한 생성 콜백
		local create_cb_func = function(ui)
			local function click_rewardBtn()
				ui:click_rewardBtn(self)
			end
			ui.vars['rewardBtn']:registerScriptTapHandler(click_rewardBtn)
		end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(1160, 108)
        table_view:setCellUIClass(UI_QuestListItem, create_cb_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(t_quest)

		-- 오른쪽에서 등장하는 연출
		local content_size = node:getContentSize()
		table_view.m_cellUIAppearCB = function(ui)
			local x, y = ui.root:getPosition()
			local new_x = x + content_size['width']
			ui.root:setPosition(new_x, y)

			ui:cellMoveTo(0.5, cc.p(x, y))
		end
    end
end

-------------------------------------
-- function setAllClearListItem
-------------------------------------
function UI_QuestPopup:setAllClearListItem(tab)
	local node = self.vars['allClearNode']
	node:removeAllChildren()

	if (tab == TableQuest.CHALLENGE) then return end

	local t_quest = g_questData:getAllClearQuestTable(tab)
	local ui = UI_QuestListItem(t_quest, true)
	node:addChild(ui.root)
end

-------------------------------------
-- function setNotiRewardable
-------------------------------------
function UI_QuestPopup:setNotiRewardable(tab)
	local vars = self.vars
	for tab, _ in pairs(self.m_mTabData) do
		local has_reward = g_questData:hasRewardableQuest(tab)
		vars[tab .. 'NotiSprite']:setVisible(has_reward)
	end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_QuestPopup:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_QuestPopup)