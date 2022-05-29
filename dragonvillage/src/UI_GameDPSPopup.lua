local PARENT = UI

-------------------------------------
-- class UI_GameDPSPopup
-------------------------------------
UI_GameDPSPopup = class(PARENT, {
		m_world = 'GameWorld',
		m_charList = 'list', -- Dragon클래스(Dragon.lua)를 리스트로 가지고 있다.
		m_tableView = 'tableView',
		
		m_bShow = 'bool',

        -------------------------------------
        m_lDisplayType = 'list', -- {'damage', 'heal', 'exp'}
        m_currIdx = 'number',
        m_currType = 'string',
        -------------------------------------

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
	self.m_dpsTimer = 0
	self.m_interval = g_constant:get('INGAME', 'DPS_INTERVAL')

    --- 초기화
    self.m_lDisplayType = {'damage', 'heal', 'exp'}
    self.m_currIdx = 1 -- 기본은 damage 패널
    -- 쫄작 중인 경우 exp 패널이 기본이 되도록 함
    if g_autoPlaySetting:isAutoPlay() and g_autoPlaySetting:get('stop_condition_dragon_lv_max') then
        -- stop_condition_dragon_lv_max <- 이 설정을 사용하지 않는 모드 제거
        if (not isExistValue(world.m_gameMode, GAME_MODE_ARENA, GAME_MODE_ARENA_NEW, GAME_MODE_EVENT_ARENA, GAME_MODE_EVENT_ILLUSION_DUNSEON)) then
            self.m_currIdx = 3
        end
    end
    self.m_currType = self.m_lDisplayType[self.m_currIdx]

	-- UI 초기화
    self:initUI()
	self:initButton()

    --
    local dps_panel = g_autoPlaySetting:get('dps_panel')

    if (isLowEndMode()) then
        -- 저사양모드일 경우 시작 시 비활성화 시킴
        dps_panel = false

    elseif (dps_panel == nil) then
        dps_panel = true
    end 
    
    if (not dps_panel) then
        self:click_dpsBtn()
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameDPSPopup:initUI()
	local vars = self.vars
	local node = vars['listNode']

    -- 드래곤 5마리 초과하면 listNode 크기 변경
    if (#self.m_charList > 5) then
        local multi = 2
        self.m_rootHeight = node:getContentSize()['height'] * multi

        local size = node:getContentSize()
        node:setContentSize(cc.size(size.width, self.m_rootHeight))
        vars['dpsBtn']:setPositionY(vars['dpsBtn']:getPositionY() + self.m_rootHeight/multi)
        vars['dpsToggleNode']:setPositionY(vars['dpsToggleNode']:getPositionY() + self.m_rootHeight/multi)

        vars['dpsToggleBtn']:setContentSize(cc.size(size.width, self.m_rootHeight + 45)) -- 45는 리스트 위쪽에 텍스트 영역도 클릭이 되어야 하기 때문이다.
    else
        self.m_rootHeight = node:getContentSize()['height']
    end

	self.m_tableView = self:makeTableView(self.m_charList, node)

	-- 최초 UI 출력위해 호출
    self:refreshDisplay()

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
		self:refreshTableView(self.m_tableView, self.m_currType)
	end
end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_GameDPSPopup:makeTableView(l_char_list, node)
    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(185, 21)
    table_view:setCellUIClass(UI_GameDPSListItem)
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
	self:sortDragonListItem(l_item, log_key)

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
-- function sortDragonListItem
-- @brief 해당 키로 정렬한다.
-------------------------------------
function UI_GameDPSPopup:sortDragonListItem(l_item, log_key)
    if (log_key == 'exp') then
        self:sortDragonListItem_exp(l_item)

    else -- 'damage', 'heal'
	    BattleStatisticsHelper:sortByValueForTable(l_item, log_key)
    end
end

-------------------------------------
-- function sortDragonListItem_exp
-- @brief 경험치일 경우 정렬
-------------------------------------
function UI_GameDPSPopup:sortDragonListItem_exp(l_item)
	table.sort(l_item, function(a, b)
		local a_dragon = a['data'] -- Dragon 클래스 (Dragon.lua)
		local b_dragon = b['data'] -- Dragon 클래스 (Dragon.lua)
		
        -- 등급이 더 높은 드래곤 우선
        local a_grade = a_dragon:getGrade()
        local b_grade = b_dragon:getGrade()
        if (a_grade ~= b_grade) then
            return a_grade > b_grade
        end

        -- 레벨이 더 높은 드래곤 우선
        local a_lv = a_dragon:getLevel()
        local b_lv = b_dragon:getLevel()
        if (a_lv ~= b_lv) then
            return a_lv > b_lv
        end

        -- 경험치가 더 높은 드래곤 우선 (등급과 레벨이 같은 상태)
        local a_exp = a_dragon:getExp()
        local b_exp = b_dragon:getExp()
        if (a_exp ~= b_exp) then
            return a_exp > b_exp
        end

        -- 리스트에 삽입된 순서로 정렬 
        return a['idx'] < b['idx']
	end)
end

-------------------------------------
-- function refreshDisplay
-- @breif
-------------------------------------
function UI_GameDPSPopup:refreshDisplay()
	local vars = self.vars

	local res = nil

	-- 타입에 따라 리소스 및 타이틀 결정
	if (self.m_currType == 'damage') then
		res = 'ingame_info_dps.png'

	elseif (self.m_currType == 'heal') then
		res = 'ingame_info_hps.png'
	
    elseif (self.m_currType == 'exp') then
		res = 'ingame_info_exp.png'
	end

	-- 리소스 아이콘으로 박음
	vars['dpsToggleNode']:removeAllChildren(true)
	
    local sprite = nil
    if res then
        sprite = cc.Sprite:createWithSpriteFrameName(res)
    end

    if (sprite) then
        sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
	    vars['dpsToggleNode']:addChild(sprite)
    end
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

    g_autoPlaySetting:setWithoutSaving('dps_panel', self.m_bShow)

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

    -- 리스트에 있는 순서대로 디스플레이 타입 변경
    local new_idx = (self.m_currIdx  + 1)
    local max_idx = table.count(self.m_lDisplayType)
    if (max_idx < new_idx) then
        new_idx = 1
    end
    self.m_currIdx = new_idx
    self.m_currType = self.m_lDisplayType[self.m_currIdx]
    
    -- UI 세팅 변경
    self:refreshDisplay()

    -- 변경된 설정에 맞춰 값 다시 출력
	self:refreshTableView(self.m_tableView, self.m_currType)
end

--@CHECK
UI:checkCompileError(UI_GameDPSPopup)