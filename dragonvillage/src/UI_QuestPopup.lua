local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_QuestPopup
-------------------------------------
UI_QuestPopup = class(PARENT, {
        m_tableView = 'UIC_TableView',
        m_allClearQuestCell = 'UI_QuestListItem',
		m_blockUI = 'UI_BlockPopup',
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

    -- 초기 값 (일일 퀘스트 보상 2배 구독 관련)
    vars['doingLabel']:setString('')
    vars['priceLabel']:setString('')
	vars['dailyQuestLabel']:setString('')
	vars['dailyQuestLabel2']:setString('')

	-- 통신 후 UI 출력
	local cb_func = function()
		self:initUI()
        self:initSubscriptionUI()
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
	-- block UI
	self.m_blockUI = UI_BlockPopup()
	self.m_blockUI:setVisible(false)
	g_currScene:removeBackKeyListener(self.m_blockUI)
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_QuestPopup:initTab()
    local vars = self.vars
    self:addTabAuto(TableQuest.DAILY, vars, vars['dailyTabMenu'])
	self:addTabAuto(TableQuest.SPECIAL, vars, vars['specialTabMenu'])
    self:addTabAuto(TableQuest.CHALLENGE, vars, vars['challengeTabMenu'])
    self:addTabAuto('contents', vars, vars['contentsTabMenu']) -- contents는 TableQuest가 아니라 serverrdata_contentlock에서 관리함
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
	
	-- 컨텐츠탭 갱신의 경우, UI노티 갱신만 필요함
	if (self.m_currTab == 'contents') then
		return
	end
    
    -- 일일 보상 올클 갱신
    if (self.m_currTab == TableQuest.DAILY) then
        self:refreshAllClearQuest()
    end

    -- 테이블뷰 아이템 데이터 교체
    if (t_quest_data and t_quest_data['idx']) then
        local t_item = self.m_tableView:getItem(t_quest_data['idx'])
        if t_item then
            t_item['data'] = t_quest_data
        end
    end
    
    -- 정렬
    self.m_tableView:sortTableView('sort', 'force')


    -- 일일 퀘스트 보상 2배 구독 정보 갱신
    self:refreshSubscriptionUI()
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_QuestPopup:onChangeTab(tab, first)
	local vars = self.vars
	local node = vars[tab .. 'ListNode']
	
	-- 최초 생성만 실행
	if (first) then
        if (tab == 'contents') then
            self:makeContentsQuest(tab, node)
        else
		    self:makeQuestTableView(tab, node)
	        -- all clear 는 따로 보여준다
	        self:setAllClearQuest(tab)
	    end
    end
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
         
    local function sort_func(a, b)
            local a_data = a['data']
            local b_data = b['data']

            -- "일일 퀘스트 10개 클리어하기" 항목은 최상단으로 고정
            if (a_data:getQuestClearType() ~= b_data:getQuestClearType()) then
                if (a_data:getQuestClearType() == 'dq_clear') then
                    return true
                elseif (b_data:getQuestClearType() == 'dq_clear') then
                    return false
                end
            end

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
        end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(1160 + 10, 80 + 10)
        table_view:setCellUIClass(UI_QuestListItem, create_cb_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_quest)
        table_view:insertSortInfo('sort', sort_func)
        self.m_tableView = table_view
    end
end

-------------------------------------
-- function makeContentsQuest
-------------------------------------
function UI_QuestPopup:makeContentsQuest(tab, node)
    -- 퀘스트 뭉치
	local t_quest = g_contentLockData:getContentsQuestList()
    local l_quest = table.MapToList(t_quest)

    do -- 테이블 뷰 생성
        node:removeAllChildren()
        
        -- 퀘스트 팝업 자체를 각 아이템이 가지기 위한 생성 콜백
		local create_cb_func = function(ui, data)
            self:cellCreateCB_contents(ui, data)
		end

        -- 퀘스트 정렬 기준
        local function sort_func(a, b)
            local a_value = tonumber(a['id']) or 0
            local b_value = tonumber(b['id']) or 0
            return a_value < b_value
        end

        -- 정렬
        table.sort(l_quest, sort_func)

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(1160 + 10, 100 + 10)
        table_view:setCellUIClass(UI_QuestListItem_Contents, create_cb_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_quest)

        -- 리워드 받을 위치에 포커싱
        -- 다른 퀘스트들과는 다르게 정렬하지 않고 포커싱만 함
        local focus_idx = 0
        for idx, data in ipairs(l_quest) do
            local content_name = data['content_name']
            local req_stage = data['req_stage_id']
            local reward_state = UI_QuestListItem_Contents.getRewardState(content_name) -- 보상 가능일 때 1 리턴
            if (reward_state == 1) then
               focus_idx = idx
               break
            end
        end

        table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
        table_view:relocateContainerFromIndex(focus_idx+2)
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
end

-------------------------------------
-- function refreshAllClearQuest
-- @brief 올클리어 갱신
-------------------------------------
function UI_QuestPopup:refreshAllClearQuest()
    if (not self.m_allClearQuestCell) then
        return
    end

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

    -- "일일 퀘스트 10개 클리어하기" 항목은 갱신을 위해 따로 저장
    local t_quest = data['t_quest']
    if (t_quest['key'] == 'dq_clear') then
        self.m_allClearQuestCell = ui
    end
end

-------------------------------------
-- function cellCreateCB_contents
-------------------------------------
function UI_QuestPopup:cellCreateCB_contents(ui, data)
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

-------------------------------------
-- function setBlock
-------------------------------------
function UI_QuestPopup:setBlock(b)
    self.m_blockUI:setVisible(b)
end

-------------------------------------
-- function initSubscriptionUI
-- @brief 일일 퀘스트 보상 2배 상품 관련 UI 초기화
-------------------------------------
function UI_QuestPopup:initSubscriptionUI()
    local vars = self.vars

    -- 상품 가격
    local struct_product = g_subscriptionData:getSubscriptionProductInfo('daily_quest')
    vars['priceLabel']:setString(struct_product:getPriceStr())

    -- 상품명
    local product_name = Str(struct_product['t_name'])
    vars['dailyQuestLabel']:setString(product_name)

    -- 상품 설명
    local product_desc = struct_product:getDesc()
    vars['dailyQuestLabel2']:setString(product_desc)

    -- 상품 구매
    vars['buyBtn']:registerScriptTapHandler(function() self:click_subscriptionBuyBtn() end)
end

-------------------------------------
-- function refreshSubscriptionUI
-- @brief 일일 퀘스트 보상 2배 상품 관련 UI 갱신
-------------------------------------
function UI_QuestPopup:refreshSubscriptionUI()
    local vars = self.vars

    local is_subscription_active = g_questData:isSubscriptionActive()
    vars['buyBtn']:setVisible(not is_subscription_active)
    vars['doingSprite']:setVisible(is_subscription_active)
    if is_subscription_active then
        local cur_day, max_day = g_questData:subscriptionDayInfo()
        local str = Str('적용 중\n{1}/{2} 일', cur_day, max_day)
        vars['doingLabel']:setString(str)
    end
end

-------------------------------------
-- function click_subscriptionBuyBtn
-- @brief 일일 퀘스트 보상 2배 상품 구매 버튼 클릭
-------------------------------------
function UI_QuestPopup:click_subscriptionBuyBtn()
    local function cb_func(ret)
        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
        self:close()
        UI_QuestPopup()
    end
    UI_PromoteQuestDouble(cb_func, false) -- param : cb_func, is_promote
end

--@CHECK
UI:checkCompileError(UI_QuestPopup)