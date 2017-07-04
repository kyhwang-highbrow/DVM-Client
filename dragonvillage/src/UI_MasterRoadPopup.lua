local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_MasterRoadPopup
-------------------------------------
UI_MasterRoadPopup = class(PARENT, {
        m_tableView = '',
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
	self:refresh()
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

	-- ??
	-- vars['titleNumLabel']:setString()

	-- 목표
	local desc = Str(t_data['t_desc'], t_data['clear_value'])
	vars['descLabel']:setString(desc)

	-- 보상 아이콘
	vars['rewardNode']:removeAllChildren(true)
	local reward_cnt = #t_data['t_reward']
	local item_id, item_cnt, item_card, pos_x
	for idx, t_item in pairs(t_data['t_reward']) do
		item_id = TableItem:getItemIDFromItemType(t_item['item_type']) or t_item['item_type']
		item_cnt = t_item['count']
        item_card = UI_ItemCard(item_id, item_cnt)
		pos_x = UIHelper:getCardPosX(reward_cnt, idx)
		item_card.root:setPositionX(pos_x)
        vars['rewardNode']:addChild(item_card.root)
	end
end

-------------------------------------
-- function makeRoadTableView
-------------------------------------
function UI_MasterRoadPopup:makeRoadTableView()
	local node = self.vars['listNode']
	
	local t_road_table = TableMasterRoad().m_orgTable
	local l_road_list = table.MapToList(t_road_table)
	table.sort(l_road_list, function(a, b) 
		local a_id = (a['mid'])
		local b_id = (b['mid'])
		return a_id < b_id
	end)

	local function after_create_func(ui, t_data)
		ui.vars['questBtn']:registerScriptTapHandler(function() self:refresh(t_data) end)
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
-- function click_okBtn
-------------------------------------
function UI_MasterRoadPopup.makeCellUI(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('master_road_item.ui')
	ccdump(t_data)

	vars['ingSprite']:setVisible(false)
	vars['numLabel']:setString(t_data['mid'])
	vars['specialSprite']:setVisible(t_data['special'] == 1)

	return ui
end

--@CHECK
UI:checkCompileError(UI_MasterRoadPopup)