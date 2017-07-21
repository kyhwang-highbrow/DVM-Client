local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_QuestPopup
-------------------------------------
UI_QuestPopup = class(PARENT, {
        m_tableView = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_QuestPopup:init()
	local vars = self:load('quest.ui')
	UIManager:open(self, UIManager.SCENE)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_QuestPopup')

	-- @UI_ACTION
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
    self:addTab(TableQuest.DAILY, vars['dailyBtn'], vars['dailyListNode'])
    self:addTab(TableQuest.CHALLENGE, vars['challengeBtn'], vars['challengeListNode'])
    self:setTab(TableQuest.DAILY)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
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
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_QuestPopup:onChangeTab(tab, first)
	local vars = self.vars
	local node = vars[tab .. 'ListNode']
	
	-- 최초 생성만 실행
	if (first) then 
		self:makeQuestTableView(tab, node)
	    -- all clear 는 따로 보여준다
	    self:setAllClearListItem(tab)
	end

    vars['allClearNode']:setVisible(tab == TableQuest.DAILY)
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
		local create_cb_func = function(ui, data)
			local function click_rewardBtn()
				ui:click_rewardBtn(self)
			end
			ui.vars['rewardBtn']:registerScriptTapHandler(click_rewardBtn)
		end
         
        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(1160 + 10, 108)
        table_view:setCellUIClass(UI_QuestListItem, create_cb_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(t_quest)

        self.m_tableView = table_view
    end
end

-------------------------------------
-- function setAllClearListItem
-------------------------------------
function UI_QuestPopup:setAllClearListItem(tab)
    -- 업적에선 사용하지 않는다.
	if (tab == TableQuest.CHALLENGE) then
        return
    end

    -- 최초만 생성
	local node = self.vars['allClearNode']
	local t_quest = g_questData:getAllClearDailyQuestTable()
	local ui = UI_QuestListItem(t_quest, true)
    ui.vars['rewardBtn']:registerScriptTapHandler(function() ui:click_rewardBtn(self) end)
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