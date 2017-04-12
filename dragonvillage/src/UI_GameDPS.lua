local PARENT = UI

local DPS_ACTION_DURATION = 0.2

-------------------------------------
-- class UI_GameDPS
-------------------------------------
UI_GameDPS = class(PARENT, {
        m_world = '',
		m_charList = '',
		m_dpsTimer = 'timer',
		m_mDpsNodeMap = 'map',

		m_bShow = 'bool',
		m_bDPS = 'bool',

		m_interval = 'num',
		m_bestValue = 'num',
		m_logKey = 'str',

		m_dpsNodePosY_top = 'num',
		m_dpsNodePosY_gap = 'num',
		m_rootWidth = 'num',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GameDPS:init(world)
	local vars = self:load('ingame_dps_info.ui')
    
	-- 멤버 변수 초기화
	self.m_world = world
	self.m_charList = table.clone(world:getDragonList())
	self.m_mDpsNodeMap = {}
	
	self.m_dpsTimer = 0

	self.m_bShow = true
	self.m_bDPS = true
	self.m_interval = g_constant:get('INGAME', 'DPS_INTERVAL')
	self.m_bestValue = 1
	self.m_logKey = 'damage'
	
	self.m_dpsNodePosY_top = vars['dpsNode1']:getPositionY()
	self.m_dpsNodePosY_gap = vars['dpsNode1']:getPositionY() - vars['dpsNode2']:getPositionY()
	self.m_rootWidth = vars['dpsNode1']:getContentSize()['width']

	-- UI 초기화
    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameDPS:initUI()
	local vars = self.vars

	for i = 1, 5 do
		local dragon = self.m_charList[i]
		if (dragon) then
			-- dragon icon
			local sprite = IconHelper:getDragonIconFromTable(dragon.m_tDragonInfo, dragon.m_charTable)
			if (sprite) then
				vars['dragonNode' .. i]:addChild(sprite)
			end
			-- 누적 damage
			vars['dpsGaugeLabel' .. i] = NumberLabel_Pumping(vars['dpsGaugeLabel' .. i], 0, DPS_ACTION_DURATION)
			-- dps
			vars['dpsLabel' .. i] = NumberLabel(vars['dpsLabel' .. i], 0, 0.3)
			-- 전체 대비 비율
			vars['dpsGauge' .. i]:setPercentage(0)
			vars['hpsGauge' .. i]:setPercentage(0)

			-- 맵핑 저장
			self.m_mDpsNodeMap[dragon] = {node = vars['dpsNode' .. i], idx = i}
		else
			vars['dpsNode' .. i]:setVisible(false)
		end
	end

	-- 최초 UI 출력위해 호출
	self:setDpsOrHps()

	-- 자체적으로 업데이트를 돌린다.
	self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GameDPS:initButton()
	local vars = self.vars
	vars['dpsBtn']:registerScriptTapHandler(function() self:click_dpsBtn() end)
	vars['dpsToggleBtn']:registerScriptTapHandler(function() self:click_dpsToggleBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GameDPS:refresh()
	local lap_time = self.m_world.m_gameState.m_fightTimer
		
	-- 나누기 오류 방지
	if (lap_time == 0) then
		lap_time = 1
	end

	-- 데미지 순서대로 정렬한다 -> 데미지가 0인 경우 공격력 순으로 정렬
	self:sortByValue(self.m_charList, self.m_logKey)
			
	-- 최고데미지 산출
	self:findBestValue(self.m_charList, self.m_logKey)

	-- dps 정보 세팅 및 node 이동
	local node_data
	local node
	local idx
	for rank, dragon in pairs(self.m_charList) do
		node_data = self.m_mDpsNodeMap[dragon]
		node = node_data['node']
		idx = node_data['idx']
		-- xps 정보 세팅
		self:setXpsInfo(dragon, idx, lap_time, self.m_logKey)
		-- node 이동
		self:moveDpsNode(node, rank)
	end
end

-------------------------------------
-- function setDpsOrHps
-- @breif dps/hps 전환
-------------------------------------
function UI_GameDPS:setDpsOrHps()
	local vars = self.vars

	local title_str
	local res

	-- dps hps인지에 따라 리소스 및 타이틀 결정
	if (self.m_bDPS) then
		title_str = 'DPS'
		res = 'res/ui/btn/ingame_info_dps.png'
		self.m_logKey = 'damage'
	else
		title_str = 'HPS'
		res = 'res/ui/btn/ingame_info_hps.png'
		self.m_logKey = 'heal'
	end

	-- 리소스 아이콘으로 박음
	vars['dpsToggleNode']:removeAllChildren(true)
	local sprite = IconHelper:getIcon(res)
	vars['dpsToggleNode']:addChild(sprite)

	-- 타이틀 및 게이지
	for i, dragon in pairs(self.m_charList) do
		-- 타이틀 문구 변경
		vars['titleLabel' .. i]:setString(title_str)
		
		local dps_gauge = vars['dpsGauge' .. i]
		local hps_gauae = vars['hpsGauge' .. i]

		-- 게이지 on/off
		dps_gauge:setVisible(self.m_bDPS)
		hps_gauae:setVisible(not self.m_bDPS)

		-- 연출 예쁘게 하기 위해서 이전 게이지 값을 미리 설정한다.
		if (self.m_bDPS) then
			dps_gauge:setPercentage(hps_gauae:getPercentage())
		else
			hps_gauae:setPercentage(dps_gauge:getPercentage())
		end
	end
	
	-- 최고값이 다시 기록되도록 초기화
	self.m_bestValue = 1
end

-------------------------------------
-- function update
-------------------------------------
function UI_GameDPS:update(dt)
	-- 보일때만 동작한다.
	if not (self.m_bShow) then
		return
	end

	self.m_dpsTimer = self.m_dpsTimer + dt
	if (self.m_dpsTimer > self.m_interval) then
		self.m_dpsTimer = self.m_dpsTimer - self.m_interval
		self:refresh()
	end
end

-------------------------------------
-- function findBestValue
-- @breif 최고의 누적 수치를 찾는다.
-------------------------------------
function UI_GameDPS:findBestValue(l_char_list, log_key)
	for _, dragon in pairs(l_char_list) do
		local log_recorder = dragon.m_charLogRecorder
		local sum_value = log_recorder:getLog(log_key)
		if (self.m_bestValue < sum_value) then
			self.m_bestValue = sum_value
		end
	end
end

-------------------------------------
-- function sortByValue
-- @breif 특정 값 순서대로 정렬한다 -> 값 0인 경우 공격력 순으로 정렬
-------------------------------------
function UI_GameDPS:sortByValue(l_char_list, log_key)
	table.sort(l_char_list, function(a, b)
		local a_value = a.m_charLogRecorder:getLog(log_key)
		local b_value = b.m_charLogRecorder:getLog(log_key)
		if (a_value == 0) and (b_value == 0) then
			local a_atk = a:getStat('atk')
			local b_atk = b:getStat('atk')
			return a_atk > b_atk
		else
			return a_value > b_value
		end
	end)
end

-------------------------------------
-- function setXpsInfo
-- @breif Xps 정보 표시
-------------------------------------
function UI_GameDPS:setXpsInfo(dragon, idx, lap_time, log_key)
	local vars = self.vars

	-- 누적 수치
	local log_recorder = dragon.m_charLogRecorder
	local sum_value = log_recorder:getLog(log_key)
	vars['dpsGaugeLabel' .. idx]:setNumber(math_floor(sum_value))

	-- xps
	local xps = math_floor(sum_value / lap_time)
	vars['dpsLabel' .. idx]:setNumber(xps)

	-- 누적 수치의 비율
	local percentage = (sum_value/self.m_bestValue) * 100
	local guage_node
	if (log_key == 'damage') then
		guage_node = vars['dpsGauge' .. idx]
	elseif (log_key == 'heal') then
		guage_node = vars['hpsGauge' .. idx]
	end
	guage_node:runAction(cc.ProgressTo:create(DPS_ACTION_DURATION, percentage))
end

-------------------------------------
-- function moveDpsNode
-- @breif dpsNode를 예쁘게 이동 시킨다. 최고높이 m_dpsNodePosY_top px, 간격 m_dpsNodePosY_gap px
-------------------------------------
function UI_GameDPS:moveDpsNode(node, rank)
	node:stopAllActions()
	
	local pos_x = 0
	local pos_y = (self.m_dpsNodePosY_top - (self.m_dpsNodePosY_gap * (rank - 1)))
	local action = cc.EaseInOut:create(cc.MoveTo:create(DPS_ACTION_DURATION, cc.p(pos_x, pos_y)), 2)
	cca.runAction(node, action)
end

-------------------------------------
-- function click_dpsBtn
-- @breif dps UI를 열고 닫는 버튼
-------------------------------------
function UI_GameDPS:click_dpsBtn()
	local vars = self.vars
	local root_node = self.root

	-- 우선 boolean을 바꾸고
	self.m_bShow = not self.m_bShow

    vars['dpsBtn']:stopAllActions()
    root_node:stopAllActions()
    local duration = 0.3

	-- 안보일땐 아예 꺼주는 액션.
	local visible_action = cc.CallFunc:create(function()
		for dragon, node_data in pairs(self.m_mDpsNodeMap) do
			local idx = node_data['idx']
			vars['dpsNode' .. idx]:setVisible(self.m_bShow)
		end
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
		local move_action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p((-self.m_rootWidth), 0)), 2)
		local seq_action = cc.Sequence:create(move_action, visible_action)
		root_node:runAction(seq_action)

        vars['dpsBtn']:runAction(cc.RotateTo:create(duration, 180))
    end
end

-------------------------------------
-- function click_dpsToggleBtn
-------------------------------------
function UI_GameDPS:click_dpsToggleBtn()
	local vars = self.vars
	-- dps hps 여부 변경
	self.m_bDPS = not self.m_bDPS
	-- UI 세팅 변경
	self:setDpsOrHps()
	-- 변경된 설정에 맞춰 값 다시 출력
	self:refresh()
end