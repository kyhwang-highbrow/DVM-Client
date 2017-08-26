local PARENT = UI

-------------------------------------
-- class UI_GameDPSPopup
-------------------------------------
UI_GameDPSPopup = class(PARENT, {
		m_world = 'GameWorld',
		m_charList = 'list',
		m_tableView = 'tableView',
		
		m_bShow = 'bool',
		m_bDPS = 'bool',
		m_logKey = 'str',

		m_rootHeight = 'num',

		m_dpsTimer = 'timer',
		m_interval = 'num',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GameDPSPopup:init(world)
	local vars = self:load('ingame_dps_info.ui', false, true, true)

	-- @UI_ACTION
	self:doActionReset()
	self:doAction(nil, false)

	-- 멤버 변수 초기화
	self.m_world = world
	self.m_charList = world.m_myDragons
	self.m_bShow = true
	self.m_bDPS = true
	self.m_logKey = 'damage'
	self.m_rootHeight = vars['listNode']:getContentSize()['height']
	self.m_dpsTimer = 0
	self.m_interval = g_constant:get('INGAME', 'DPS_INTERVAL')

	-- UI 초기화
    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameDPSPopup:initUI()
	local vars = self.vars
	local node = vars['listNode1']

	self.m_tableView = self:makeTableView(self.m_charList, vars['listNode'])

	-- 최초 UI 출력위해 호출
	self:setDpsOrHps()

	-- 자체적으로 업데이트를 돌린다.
	self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GameDPSPopup:initButton()
    local vars = self.vars
	vars['dpsBtn']:registerScriptTapHandler(function() self:click_dpsBtn() end)
	vars['dpsToggleBtn']:registerScriptTapHandler(function() self:click_dpsToggleBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GameDPSPopup:refresh()
end

-------------------------------------
-- function update
-------------------------------------
function UI_GameDPSPopup:update(dt)
	-- 보일때만 동작한다.
	if not (self.m_bShow) then
		return
	end

	self.m_dpsTimer = self.m_dpsTimer + dt
	if (self.m_dpsTimer > self.m_interval) then
		self.m_dpsTimer = self.m_dpsTimer - self.m_interval
		self:refreshTableView(self.m_tableView, self.m_logKey)
	end
end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_GameDPSPopup:makeTableView(l_char_list, node)
    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(185, 21)
    table_view:setCellUIClass(UI_GameDPSListItem, nil)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

	local make_item = true
    table_view:setItemList(l_char_list, make_item)

	return table_view
end

-------------------------------------
-- function refreshTableView
-------------------------------------
function UI_GameDPSPopup:refreshTableView(table_view, log_key)
	local vars = self.vars
	local l_item = table_view.m_itemList

	-- 해당 키의 최고 수치를 찾는다.
	local best_value = BattleStatisticsHelper:findBestValueForTable(l_item, log_key)
	-- dps 계산을 위한 플레이 시간
	local lap_time = self.m_world.m_gameState.m_fightTimer
	-- 해당 키로 정렬한다.
	BattleStatisticsHelper:sortByValueForTable(l_item, log_key)

	-- ui에 적용시킨다.
	for i, item in pairs(l_item) do
		local ui = item['ui'] or item['generated_ui']
		if (ui) then
			ui.m_labTime = lap_time
			ui.m_bestValue = best_value
			ui:setLogKey(log_key)
			ui:refresh()
		end
	end

	table_view:setDirtyItemList()
end

-------------------------------------
-- function setDpsOrHps
-- @breif dps/hps 전환
-------------------------------------
function UI_GameDPSPopup:setDpsOrHps()
	local vars = self.vars

	local title_str
	local res

	-- dps hps인지에 따라 리소스 및 타이틀 결정
	if (self.m_bDPS) then
		title_str = 'DPS'
		res = 'res/ui/buttons/ingame_info_dps.png'
		self.m_logKey = 'damage'
	else
		title_str = 'HPS'
		res = 'res/ui/buttons/ingame_info_hps.png'
		self.m_logKey = 'heal'
	end

	-- 리소스 아이콘으로 박음
	vars['dpsToggleNode']:removeAllChildren(true)
	local sprite = IconHelper:getIcon(res)
	vars['dpsToggleNode']:addChild(sprite)
end







-------------------------------------
-- function click_dpsBtn
-- @breif dps UI를 열고 닫는 버튼
-------------------------------------
function UI_GameDPSPopup:click_dpsBtn()
	local vars = self.vars
	local root_node = self.root

	-- 우선 boolean을 바꾸고
	self.m_bShow = not self.m_bShow

    vars['dpsBtn']:stopAllActions()
    root_node:stopAllActions()
    local duration = 0.3

	-- 안보일땐 아예 꺼주는 액션.
	local visible_action = cc.CallFunc:create(function()
		vars['listNode']:setVisible(self.m_bShow)
	end)

	-- 열고 닫는 액션
    if self.m_bShow then
		-- 열기 (visible 키고 이동)
		local move_action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(0, 0)), 2)
		local seq_action = cc.Sequence:create(visible_action, move_action)
		root_node:runAction(seq_action)

        vars['dpsBtn']:runAction(cc.RotateTo:create(duration, 360))
    else
		-- 닫기 (이동 하고 visible 끄기)
		local move_action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(0, -self.m_rootHeight)), 2)
		local seq_action = cc.Sequence:create(move_action, visible_action)
		root_node:runAction(seq_action)

        vars['dpsBtn']:runAction(cc.RotateTo:create(duration, 180))
    end
end

-------------------------------------
-- function click_dpsToggleBtn
-------------------------------------
function UI_GameDPSPopup:click_dpsToggleBtn()
	local vars = self.vars
	-- dps hps 여부 변경
	self.m_bDPS = not self.m_bDPS
	-- UI 세팅 변경
	self:setDpsOrHps()
	-- 변경된 설정에 맞춰 값 다시 출력
	self:refreshTableView(self.m_tableView, self.m_logKey)
end

--@CHECK
UI:checkCompileError(UI_GameDPSPopup)