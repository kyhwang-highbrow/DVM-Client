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

    -- 테이블 콜백으로 갱신하면 눈에 보이는 텀이 있어 최초에 호출함
    local t_road = TableMasterRoad():get(g_masterRoadData:getFocusRoad())
	self:refresh(t_road)
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
    local animator = MakeAnimator(res)
    animator:changeAni('idle', true)

	vars['npcNode']:removeAllChildren(true)
    vars['npcNode']:addChild(animator.m_node)

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
	self.makeRewardCard(vars['rewardNode'], t_data['t_reward'])
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

		-- 최초 선택
		if (t_data['rid'] == g_masterRoadData:getFocusRoad()) then
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
function UI_MasterRoadPopup.makeRewardCard(reward_node, t_reward)
	local reward_cnt = #t_reward
	local item_id, item_cnt, item_card, pos_x
	for idx, t_item in pairs(t_reward) do
		item_id = TableItem:getItemIDFromItemType(t_item['item_type']) or tonumber(t_item['item_type'])
		item_cnt = t_item['count']
        item_card = UI_ItemCard(item_id, item_cnt)
		pos_x = UIHelper:getCardPosX(reward_cnt, idx)
		item_card.root:setPositionX(pos_x)
        reward_node:addChild(item_card.root)
        
        item_card.root:setSwallowTouch(false)
	end
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

	-- 진행중
	vars['ingSprite']:setVisible(rid == g_masterRoadData:getFocusRoad())

	-- 퀘스트 순번
	vars['numLabel']:setString(rid - 10000)

	-- 스페셜 표시..?
	vars['specialSprite']:setVisible(t_data['special'] == 1)

	-- 보상 아이콘
	vars['rewardNode']:removeAllChildren(true)
	UI_MasterRoadPopup.makeRewardCard(vars['rewardNode'], t_data['t_reward'])

	return ui
end

-------------------------------------
-- function selectCell
-- @brief 테이블 셀 선택 콜백
-------------------------------------
function UI_MasterRoadPopup:selectCell(ui, t_data)
	-- 해당 정보로 UI 갱신
	self:refresh(t_data)
	
	-- 이전 셀 선택 표시 해제
	if (self.m_selectedSprite) then
		self.m_selectedSprite:setVisible(false)
		self.m_selectedSprite = nil
	end

	-- 해당 셀 선택 표시
	self.m_selectedSprite = ui.vars['selectSprite']
	self.m_selectedSprite:setVisible(true)
end

--@CHECK
UI:checkCompileError(UI_MasterRoadPopup)