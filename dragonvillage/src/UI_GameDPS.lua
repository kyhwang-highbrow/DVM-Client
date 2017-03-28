local PARENT = class(UI, IEventListener:getCloneTable())

local DPS_ACTION_DURATION = 0.2

-------------------------------------
-- class UI_GameDPS
-------------------------------------
UI_GameDPS = class(PARENT, {
        m_world = '',
		m_dpsTimer = 'timer',
		m_mDragonIconMap = 'map',
		m_mDpsNodeMap = 'map',

		m_bShow = 'bool',
		m_bDPS = 'bool',

		m_interval = 'num',
		m_bestDamage = 'num',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GameDPS:init(world)
    self.m_world = world
	self.m_dpsTimer = 0
	self.m_mDragonIconMap = {}
	self.m_mDpsNodeMap = {}
	self.m_bShow = true
	self.m_bDPS = true
	self.m_interval = g_constant:get('INGAME', 'DPS_INTERVAL')
	self.m_bestDamage = 0

	local vars = self:load('ingame_dps_info.ui')

    self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameDPS:initUI()
	local vars = self.vars
	local l_dragon = self.m_world:getDragonList()

	for i = 1, 5 do
		local dragon = l_dragon[i]
		if (dragon) then
			-- dragon icon
			local sprite = IconHelper:getDragonIconFromTable(dragon.m_tDragonInfo, dragon.m_charTable)
			if (sprite) then
				vars['dragonNode' .. i]:addChild(sprite)
				-- 재활용 위해 아이콘 저장
				self.m_mDragonIconMap[dragon] = sprite
			end
			
			-- 누적 damage
			vars['dpsGaugeLabel' .. i] = NumberLabel_Pumping(vars['dpsGaugeLabel' .. i], 0, DPS_ACTION_DURATION)
			-- dps
			vars['dpsLabel' .. i] = NumberLabel(vars['dpsLabel' .. i], 0, 0.3)
			-- 전체 대비 비율
			vars['dpsGauge' .. i]:setPercentage(0)

			-- 맵핑 저장
			self.m_mDpsNodeMap[dragon] = {node = vars['dpsNode' .. i], idx = i}
		else
			vars['dpsNode' .. i]:setVisible(false)
		end
	end
	
	-- 자체적으로 업데이트를 돌린다.
	self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
	--self.m_world:addListener('wave_start', self)
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
	self:setDpsOrHps()
end

-------------------------------------
-- function setDpsOrHps
-- @breif dps/hps 에 따른 텍스트 정보 설정
-------------------------------------
function UI_GameDPS:setDpsOrHps()
	local vars = self.vars

	local title_str
	local res

	if (self.m_bDPS) then
		title_str = 'DPS'
		res = 'res/ui/btn/ingame_info_dps.png'
	else
		title_str = 'HPS'
		res = 'res/ui/btn/ingame_info_hps.png'
	end

	local sprite = IconHelper:getIcon(res)
	vars['dpsToggleNode']:addChild(sprite)
	for i, dragon in pairs(self.m_world:getDragonList()) do
		vars['titleLabel' .. i]:setString(title_str)
	end
end

-------------------------------------
-- function onEvent
-------------------------------------
function UI_GameDPS:onEvent(event_name, t_event, ...)
	if (event_name == 'wave_start') then
	end
end

-------------------------------------
-- function update
-------------------------------------
function UI_GameDPS:update(dt)
	self.m_dpsTimer = self.m_dpsTimer + dt
	if (self.m_dpsTimer > self.m_interval) then
		self.m_dpsTimer = self.m_dpsTimer - self.m_interval

		local lap_time = self.m_world.m_gameState.m_fightTimer
		local l_dragon = self.m_world:getDragonList()
	
		if (lap_time == 0) then
			lap_time = 1
		end

		-- 데미지 순서대로 정렬한다 -> 데미지가 0인 경우 공격력 순으로 정렬
		self:sortByDamage(l_dragon)

		-- dps 정보 세팅 및 node 이동
		local node_data
		local node
		local idx
		for rank, dragon in pairs(l_dragon) do
			node_data = self.m_mDpsNodeMap[dragon]
			node = node_data['node']
			idx = node_data['idx']
			-- dps 정보 세팅
			self:setDpsInfo(dragon, idx, lap_time)
			-- node 이동
			self:moveDpsNode(node, rank)
		end

		-- 전체 대비 비율
		for _, dragon in pairs(l_dragon) do
			local log_recorder = dragon.m_charLogRecorder
			local sum_damage = log_recorder:getLog('damage')
			local percentage = (sum_damage/self.m_bestDamage) * 100
			
			idx = self.m_mDpsNodeMap[dragon]['idx']
			self.vars['dpsGauge' .. idx]:runAction(cc.ProgressTo:create(DPS_ACTION_DURATION, percentage))
		end
	end
end

-------------------------------------
-- function sortByDamage
-------------------------------------
function UI_GameDPS:sortByDamage(l_dragon)
	table.sort(l_dragon, function(a, b)
		local a_damage = a.m_charLogRecorder:getLog('damage')
		local b_damage = b.m_charLogRecorder:getLog('damage')
		if (a_damage == 0) and (b_damage == 0) then
			local a_atk = a.m_statusCalc:getFinalStat('atk')
			local b_atk = b.m_statusCalc:getFinalStat('atk')
			return a_atk > b_atk
		else
			return a_damage > b_damage
		end
	end)
end

-------------------------------------
-- function setDpsInfo
-- @breif dps 기본 정보를 세팅하고 최고 데미지를 계산한다.
-------------------------------------
function UI_GameDPS:setDpsInfo(dragon, idx, lap_time)
	local vars = self.vars

	-- 누적 damage
	local log_recorder = dragon.m_charLogRecorder
	local sum_damage = math_floor(log_recorder:getLog('damage'))
	vars['dpsGaugeLabel' .. idx]:setNumber(sum_damage)

	-- dps
	local dps = math_floor(sum_damage / lap_time)
	vars['dpsLabel' .. idx]:setNumber(dps)

	-- 최고데미지 산출
	if (self.m_bestDamage < sum_damage) then
		self.m_bestDamage = sum_damage
	end
end

-------------------------------------
-- function moveDpsNode
-- @breif dpsNode를 예쁘게 이동 시킨다. 1위는 -100px, 간격 50px
-------------------------------------
function UI_GameDPS:moveDpsNode(node, rank)
	local pos_x = 0
	local pos_y = (100 - (50 * (rank - 1)))

	local action = cc.EaseInOut:create(cc.MoveTo:create(DPS_ACTION_DURATION, cc.p(pos_x, pos_y)), 2)
	cca.runAction(node, action)
end

-------------------------------------
-- function click_dpsBtn
-------------------------------------
function UI_GameDPS:click_dpsBtn()
	local vars = self.vars
	local root_node = self.root

    vars['dpsBtn']:stopAllActions()
    root_node:stopAllActions()
    local duration = 0.3

    if self.m_bShow then
        root_node:runAction(cc.MoveTo:create(duration, cc.p(-170, 0)))
        vars['dpsBtn']:runAction(cc.RotateTo:create(duration, 180))
    else
        root_node:runAction(cc.MoveTo:create(duration, cc.p(0, 0)))
        vars['dpsBtn']:runAction(cc.RotateTo:create(duration, 360))
    end

	self.m_bShow = not self.m_bShow
end

-------------------------------------
-- function click_dpsToggleBtn
-------------------------------------
function UI_GameDPS:click_dpsToggleBtn()
	local vars = self.vars

	self.m_bDPS = not self.m_bDPS

	self:setDpsOrHps()
end