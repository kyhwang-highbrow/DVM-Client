local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_MasterRoadPopup
-------------------------------------
UI_MasterRoadPopup = class(PARENT, {
        m_tableView = '',
		m_currRid = 'number',
		m_selectedSprite = 'cc.Sprite',

        -- "바로 가기"버튼을 클릭했을 때 팝업이 자동으로 닫힐지 여부
        m_bAutoClose = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MasterRoadPopup:init(auto_close)
    if (auto_close == nil) then
        self.m_bAutoClose = true
    else
        self.m_bAutoClose = auto_close
    end

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

	SoundMgr:playBGM('bgm_lobby')

	-- @ TUTORIAL : 1-1 end, 101
	local tutorial_key = TUTORIAL.FIRST_END
	local check_step = 101
	TutorialManager.getInstance():continueTutorial(tutorial_key, check_step, self)

	-- @ TUTORIAL : 1-1 end, 103
	tutorial_key = TUTORIAL.FIRST_END
	check_step = 103
	TutorialManager.getInstance():continueTutorial(tutorial_key, check_step, self)
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

    -- 보상 받을 cell이 생성되기 전까지 비활성화
    vars['rewardBtn']:setEnabled(false)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_MasterRoadPopup:refresh(t_data, b_force)
	local vars = self.vars

	if (not t_data) then
		return
	end
	
	-- 중복 호출 막음
	if (not b_force) and (self.m_currRid == t_data['rid']) then
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

	-- npc 대화
	local npc_speech = Str(t_data['t_speech'])
	vars['npcSpeechLabel']:setString(npc_speech)

    -- 넘버링
    local road_idx = g_masterRoadData:getRoadIdx(t_data['rid'])
    local num_str = Str('{1}번째 임무입니다.', road_idx)
    vars['titleNumLabel']:setString(num_str)

	-- 목표
	local desc = TableMasterRoad:getDescStr(t_data)
	vars['descLabel']:setString(desc)

    -- 스페셜 목표 선택할 경우 프레임 이펙트
    vars['specialSprite']:setVisible(t_data['special'] == 1)

	-- 보상 아이콘
	vars['rewardNode']:removeAllChildren(true)
	self.makeRewardCard(vars['rewardNode'], t_data['t_reward'], false, 'center')

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

    local curr_rid = g_masterRoadData:getDisplayRoad()
	local l_road_list = TableMasterRoad():getSortedList(curr_rid)

    -- 생성 후 동작
	local function after_create_func(ui, t_data)
        -- 버튼 등록
		ui.vars['questBtn']:registerScriptTapHandler(function() 
			self:selectCell(ui, t_data)
		end)

        -- 최초 선택 : ui를 얻어오기 위해 생성 콜백에도 붙임
		if (t_data['rid'] == curr_rid) then
			self:selectCell(ui, t_data)

            -- 보상 받을 cell이 생성된 후에 보상 버튼 활성화
            self.vars['rewardBtn']:setEnabled(true)
		end
	end

    do -- 테이블 뷰 생성
        node:removeAllChildren()

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(250, 260)
        table_view:setCellUIClass(self.makeCellUI, after_create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
		table_view:setItemList(l_road_list)

        self.m_tableView = table_view
           
	    -- 최초 선택 - 가운데로 지정 셀 위치 시킴
        do
            -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
            self.m_tableView:update(0)

            local curr_idx = g_masterRoadData:getRoadIdx(curr_rid)
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

        -- 보상 수령 후에는 전역 항목에 대해 다시 검사한다. 이것들은 클리어 타이밍이 애매하기 때문
        local function re_cb_func()
            self:refresh(t_cell['data'], true)
            self.refreshCell(t_cell['ui'], t_cell['data'])
        end
        g_masterRoadData:updateMasterRoadAfterReward(re_cb_func)
    end
    g_masterRoadData:request_roadReward(self.m_currRid, cb_func)
end

-------------------------------------
-- function click_questLinkBtn
-- @brief 바로가기
-------------------------------------
function UI_MasterRoadPopup:click_questLinkBtn()
    local t_road = TableMasterRoad():get(self.m_currRid)
    
    local clear_type = t_road['clear_type']
    local clear_cond = t_road['clear_value']

    if (clear_type == 'clr_stg') and (clear_cond == 1110102) then
        clear_type = 'stg_ready'
    end
    
    QuickLinkHelper.quickLink(clear_type, clear_cond)

    -- "바로 가기"버튼을 클릭했을 때 팝업이 자동으로 닫힐지 여부
    if (self.m_bAutoClose) then
        self:setCloseCB(nil)
        self:close()
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_MasterRoadPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function makeRewardCard
-- @static
-- @brief 보상 아이콘 생성
-------------------------------------
function UI_MasterRoadPopup.makeRewardCard(reward_node, t_reward, block_btn, allign)
	local reward_cnt = #t_reward
	for idx, t_item in pairs(t_reward) do
        -- 데이터 및 카드 생성
		local item_id = TableItem:getItemIDFromItemType(t_item['item_type']) or tonumber(t_item['item_type'])
		local item_cnt = t_item['count']
        local item_card = UI_ItemCard(item_id, item_cnt)
		local pos_x
        if (allign == 'left') then
            pos_x = 155 * (idx - 1)
        elseif (allign == 'center') then
            pos_x = UIHelper:getCardPosX(reward_cnt, idx)
        end

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

	-- 스페셜 보상 표시
	vars['specialSprite']:setVisible(t_data['special'] == 1)

	-- 보상 아이콘
	vars['rewardNode']:removeAllChildren(true)
	UI_MasterRoadPopup.makeRewardCard(vars['rewardNode'], t_data['t_reward'], 'be block', 'left')
    
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
    if (not ui) then
        return
    end

    local vars = ui.vars
    local rid = t_data['rid']

	-- 진행중
	vars['ingSprite']:setVisible(rid == g_masterRoadData:getFocusRoad())

    -- 보상 상태에 따른 처리
    local reward_state = g_masterRoadData:getRewardState(rid)
    vars['rewardNotiSprite']:setVisible(reward_state == 'has_reward')
    vars['completeSprite']:setVisible(reward_state == 'already_done')
end

--@CHECK
UI:checkCompileError(UI_MasterRoadPopup)