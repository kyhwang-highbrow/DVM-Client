local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_MasterRoadPopup
-------------------------------------
UI_MasterRoadPopup = class(PARENT, {
        m_tableView = '',
		m_currRid = 'number',
		m_selectedSprite = 'cc.Sprite',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MasterRoadPopup:init()
	local vars = self:load('master_road_popup.ui')
	UIManager:open(self, UIManager.SCENE)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_MasterRoadPopup')

	-- @UI_ACTION
	self:doActionReset()
	self:doAction(nil, false)

	self:initUI()
	self:initButton()
	--self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_MasterRoadPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_MasterRoadPopup'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('마스터의 길')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_MasterRoadPopup:initUI()
	self:makeRoadTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_MasterRoadPopup:initButton()
    local vars = self.vars
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    vars['questLinkBtn']:registerScriptTapHandler(function() self:click_questLinkBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_MasterRoadPopup:refresh(t_data)
	local vars = self.vars

	if (not t_data) then
		return
	end
	
	-- 중복 호출 막음
	if (self.m_currRid == t_data['rid']) then
		return
	end

	-- id 저장
	self.m_currRid = t_data['rid']

    -- npc 일러스트
    local res = t_data['res']
    if self:checkVarsKey('npcNode', res) then
	    vars['npcNode']:removeAllChildren(true)
        local animator = MakeAnimator(res)
        animator:changeAni('idle', true)
        vars['npcNode']:addChild(animator.m_node)
    end

	-- npc 이름
	local npc_name = Str(t_data['t_name'])
	vars['npcNameLabel']:setString(npc_name)

	-- npc 대화
	local npc_speech = Str(t_data['t_speech'])
	vars['npcSpeechLabel']:setString(npc_speech)

	-- 목표
	local desc = Str(t_data['t_desc'], t_data['desc_1'], t_data['desc_2'], t_data['desc_3'])
	vars['descLabel']:setString(desc)

	-- 보상 아이콘
	vars['rewardNode']:removeAllChildren(true)
	self.makeRewardCard(vars['rewardNode'], t_data['t_reward'], false)

    -- 보상 상태에 따른 버튼 처리
    local reward_state = g_masterRoadData:getRewardState(t_data['rid'])
    vars['rewardBtn']:setVisible(reward_state == 'has_reward')
    vars['completeSprite']:setVisible(reward_state == 'already_done')
    vars['questLinkBtn']:setVisible((reward_state == 'not_yet') and (t_data['rid'] == g_masterRoadData:getFocusRoad()))
end

-------------------------------------
-- function makeRoadTableView
-------------------------------------
function UI_MasterRoadPopup:makeRoadTableView()
	local node = self.vars['listNode']

	local l_road_list = TableMasterRoad():getSortedList()

    -- 생성 후 동작
	local function after_create_func(ui, t_data)
        -- 버튼 등록
		ui.vars['questBtn']:registerScriptTapHandler(function() 
			self:selectCell(ui, t_data)
		end)

        -- 최초 선택 : ui를 얻어오기 위해 생성 콜백에도 붙임
		if (t_data['rid'] == g_masterRoadData:getDisplayRoad()) then
			self:selectCell(ui, t_data)
		end
	end

    do -- 테이블 뷰 생성
        node:removeAllChildren()

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(180, 120)
        table_view:setCellUIClass(self.makeCellUI, after_create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
		table_view:setItemList(l_road_list)

        self.m_tableView = table_view
           
	    -- 최초 선택 - 가운데로 지정 셀 위치 시킴
        do
            -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
            self.m_tableView:update(0)

            local rid = g_masterRoadData:getDisplayRoad()
            local curr_idx = g_masterRoadData:getRoadIdx(rid)
            local t_cell = self.m_tableView:getItem(curr_idx)
            self:selectCell(nil, t_cell['data'], true)
        end
    end
end

-------------------------------------
-- function click_rewardBtn
-- @brief 보상 받기
-------------------------------------
function UI_MasterRoadPopup:click_rewardBtn()
    local function cb_func(ret)

        -- 보상 획득
        ItemObtainResult(ret)
        
        -- 보상 받은 road의 셀 갱신 (보상 표시 제거)
        local curr_idx = g_masterRoadData:getRoadIdx(self.m_currRid)
        local t_cell = self.m_tableView:getItem(curr_idx)
        self.refreshCell(t_cell['ui'], t_cell['data'])
        
        -- 다음 road로 UI 갱신
        local next_idx = g_masterRoadData:getRoadIdx(g_masterRoadData:getFocusRoad())
        t_cell = self.m_tableView:getItem(next_idx)
        self:selectCell(t_cell['ui'], t_cell['data'])
    end
    g_masterRoadData:request_roadReward(self.m_currRid, cb_func)
end

-------------------------------------
-- function click_questLinkBtn
-------------------------------------
function UI_MasterRoadPopup:click_questLinkBtn()
    local t_road = TableMasterRoad():get(self.m_currRid)
    
    local clear_type = t_road['clear_type']
    local clear_cond = t_road['clear_value']

    QuickLinkHelper.quickLink(clear_type, clear_cond)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_MasterRoadPopup:click_exitBtn()
    self:closeWithAction()
end

-------------------------------------
-- function makeRewardCard
-- @static
-- @brief 보상 아이콘 생성
-------------------------------------
function UI_MasterRoadPopup.makeRewardCard(reward_node, t_reward, block_btn)
	local reward_cnt = #t_reward
	for idx, t_item in pairs(t_reward) do
        -- 데이터 및 카드 생성
		local item_id = TableItem:getItemIDFromItemType(t_item['item_type']) or tonumber(t_item['item_type'])
		local item_cnt = t_item['count']
        local item_card = UI_ItemCard(item_id, item_cnt)
		local pos_x = UIHelper:getCardPosX(reward_cnt, idx)

        -- 카드 속성 부여
        item_card.root:setPositionX(pos_x)
        item_card.root:setSwallowTouch(false)
        item_card.vars['clickBtn']:setEnabled(not block_btn)

        -- 카드 UI 등록
        reward_node:addChild(item_card.root)
	end
end

-------------------------------------
-- function selectCell
-- @brief 테이블 셀 선택 콜백
-------------------------------------
function UI_MasterRoadPopup:selectCell(ui, t_data, is_first)
	-- 해당 정보로 UI 갱신
	self:refresh(t_data)
	
	-- 이전 셀 선택 표시 해제
	if (self.m_selectedSprite) then
		self.m_selectedSprite:setVisible(false)
		self.m_selectedSprite = nil
	end

	-- 해당 셀 선택 표시
    if (ui) then
	    self.m_selectedSprite = ui.vars['selectSprite']
	    self.m_selectedSprite:setVisible(true)
    end

    -- 셀 중앙 이동
    local road_idx = g_masterRoadData:getRoadIdx(t_data['rid'])
    self.m_tableView:relocateContainerFromIndex(road_idx, (not is_first))
end


 

-------------------------------------
-- function makeCellUI
-- @static
-- @brief 테이블 셀 생성
-------------------------------------
function UI_MasterRoadPopup.makeCellUI(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('master_road_item.ui')
	local rid = t_data['rid']

	-- 퀘스트 순번
    local road_idx = g_masterRoadData:getRoadIdx(rid)
	vars['numLabel']:setString(road_idx)

	-- 스페셜 표시..?
	vars['specialSprite']:setVisible(t_data['special'] == 1)

	-- 보상 아이콘
	vars['rewardNode']:removeAllChildren(true)
	UI_MasterRoadPopup.makeRewardCard(vars['rewardNode'], t_data['t_reward'], 'be block')
    
    -- 진행중 및 보상 표시
    UI_MasterRoadPopup.refreshCell(ui, t_data)

	return ui
end

-------------------------------------
-- function refreshCell
-- @static
-- @brief 테이블 셀 갱신
-------------------------------------
function UI_MasterRoadPopup.refreshCell(ui, t_data)
    local vars = ui.vars
    local rid = t_data['rid']

	-- 진행중
	vars['ingSprite']:setVisible(rid == g_masterRoadData:getFocusRoad())

    -- 보상 상태에 따른 버튼 처리
    local reward_state = g_masterRoadData:getRewardState(rid)
    vars['rewardNotiSprite']:setVisible(reward_state == 'has_reward')
    vars['completeSprite']:setVisible(reward_state == 'already_done')
end

--@CHECK
UI:checkCompileError(UI_MasterRoadPopup)