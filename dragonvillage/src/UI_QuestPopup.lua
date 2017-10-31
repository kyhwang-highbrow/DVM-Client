local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_QuestPopup
-------------------------------------
UI_QuestPopup = class(PARENT, {
        m_tableView = 'UIC_TableView',
        m_allClearQuestCell = 'UI_QuestListItem',
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
    self:addTabAuto(TableQuest.DAILY, vars, vars['dailyListNode'])
    self:addTabAuto(TableQuest.CHALLENGE, vars, vars['challengeListNode'])
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
function UI_QuestPopup:refresh(t_quest_data)
	-- 받을수 있는 보상이 있는지 검사하여 UI에 표시
	self:setNotiRewardable()
    
    -- 일일 보상 올클 갱신
    if (self.m_currTab == TableQuest.DAILY) then
        self:refreshAllClearQuest()
    end

    -- 테이블뷰 아이템 데이터 교체
    if (t_quest_data) then
        local t_item = self.m_tableView:getItem(t_quest_data['idx'])
        t_item['data'] = t_quest_data
    end
    
    -- 정렬
    self.m_tableView:sortTableView('sort', 'force')
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
	    self:setAllClearQuest(tab)
	end

    vars['allClearNode']:setVisible(tab == TableQuest.DAILY)
end

-------------------------------------
-- function makeQuestTableView
-------------------------------------
function UI_QuestPopup:makeQuestTableView(tab, node)
    local vars = self.vars

	-- 퀘스트 뭉치
	local l_quest = g_questData:getQuestListByType(tab)
    for idx, v in pairs(l_quest) do
        v['idx'] = idx
    end

    do -- 테이블 뷰 생성
        node:removeAllChildren()

		-- 퀘스트 팝업 자체를 각 아이템이 가지기 위한 생성 콜백
		local create_cb_func = function(ui, data)
            self:cellCreateCB(ui, data)
		end
         
        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(1160 + 10, 108)
        table_view:setCellUIClass(UI_QuestListItem, create_cb_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_quest)

        table_view:insertSortInfo('sort', function(a, b)
            local a_data = a['data']
            local b_data = b['data']
            if (a_data:isEnd() and not b_data:isEnd()) then
                return false
            elseif (not a_data:isEnd() and b_data:isEnd()) then
                return true
            elseif (a_data:hasReward() and not b_data:hasReward()) then
                return true
            elseif (not a_data:hasReward() and b_data:hasReward()) then
                return false
            else
                return (a_data:getQid() < b_data:getQid())
            end
        end)

        self.m_tableView = table_view
    end
end

-------------------------------------
-- function setAllClearQuest
-- @brief 올클리어 생성
-------------------------------------
function UI_QuestPopup:setAllClearQuest(tab)
    -- 업적에선 사용하지 않는다.
	if (tab == TableQuest.CHALLENGE) then
        return
    end

    -- 최초 생성
	local node = self.vars['allClearNode']
	local t_quest = g_questData:getAllClearDailyQuestTable()
	local ui = UI_QuestListItem(t_quest, true)
    ui.vars['rewardBtn']:registerScriptTapHandler(function() ui:click_rewardBtn(self) end)
	node:addChild(ui.root)
    self.m_allClearQuestCell = ui
end

-------------------------------------
-- function refreshAllClearQuest
-- @brief 올클리어 갱신
-------------------------------------
function UI_QuestPopup:refreshAllClearQuest()
    local t_quest = g_questData:getAllClearDailyQuestTable()
    self.m_allClearQuestCell:refresh(t_quest)
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

-------------------------------------
-- function cellCreateCB
-------------------------------------
function UI_QuestPopup:cellCreateCB(ui, data)
    -- 보상 받기 버튼
	local function click_rewardBtn()
		ui:click_rewardBtn(self)
	end
	ui.vars['rewardBtn']:registerScriptTapHandler(click_rewardBtn)

    -- 바로가기 버튼
	local function click_questLinkBtn()
		ui:click_questLinkBtn(self)
	end
	ui.vars['questLinkBtn']:registerScriptTapHandler(click_questLinkBtn)
end

--@CHECK
UI:checkCompileError(UI_QuestPopup)