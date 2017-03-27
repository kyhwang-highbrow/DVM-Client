-------------------------------------
-- class UI_GameDPS
-------------------------------------
UI_GameDPS = class(UI, {
        m_world = '',
		m_dpsTimer = 'timer',
		m_bShow = 'bool',
		m_mDragonIconMap = 'map',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GameDPS:init(world)
    self.m_world = world
	self.m_dpsTimer = 0
	self.m_bShow = true
	self.m_mDragonIconMap = {}

	local vars = self:load('ingame_dps_info.ui')

    self:initUI()
	self:initButton()
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
				sprite:setDockPoint(CENTER_POINT)
				sprite:setAnchorPoint(CENTER_POINT)
				vars['dragonNode' .. i]:addChild(sprite)
				-- 재활용 위해 아이콘 저장
				self.m_mDragonIconMap[dragon] = sprite
			end
			-- DPS or HPS
			vars['titleLabel' .. i]:setString('DPS')
			-- 누적 damage
			vars['dpsGaugeLabel' .. i] = NumberLabel(vars['dpsGaugeLabel' .. i], 0, 0.1)
			-- dps
			vars['dpsLabel' .. i]:setString(0)
			-- 전체 대비 비율
			vars['dpsGauge' .. i]:setPercentage(0)
		else
			vars['dpsGaugeLabel' .. i]:setVisible(false)
			vars['dpsLabel' .. i]:setVisible(false)
			vars['titleLabel' .. i]:setVisible(false)
			vars['dragonNode' .. i]:setVisible(false)
			vars['dpsGauge' .. i]:setVisible(false)
		end
	end
	
	-- 자체적으로 업데이트를 돌린다.
	self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_GameDPS:initButton()
	local vars = self.vars
	vars['dpsBtn']:registerScriptTapHandler(function() self:click_dpsBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GameDPS:refresh()
	local vars = self.vars

end

-------------------------------------
-- function update
-------------------------------------
function UI_GameDPS:update(dt)
	self.m_dpsTimer = self.m_dpsTimer + dt
	if (self.m_dpsTimer > 0.5) then
		self.m_dpsTimer = self.m_dpsTimer - 0.5

		local vars = self.vars
		local state = self.m_world.m_gameState
		local lap_time = state.m_fightTimer
		local l_dragon = self.m_world:getDragonList()
		local best_damage = 0
	
		if (lap_time == 0) then
			lap_time = 1
		end

		table.sort(l_dragon, function(a, b)
			local a_damage = a.m_charLogRecorder:getLog('damage')
			local b_damage = b.m_charLogRecorder:getLog('damage')
			return a_damage > b_damage
		end)

		for i, dragon in pairs(l_dragon) do
			-- dragon icon (재활용)
			local sprite = self.m_mDragonIconMap[dragon]
			sprite:retain()
			sprite:removeFromParent()
			vars['dragonNode' .. i]:addChild(sprite)
			sprite:release()

			-- 누적 damage
			local log_recorder = dragon.m_charLogRecorder
			local sum_damage = math_floor(log_recorder:getLog('damage'))
			vars['dpsGaugeLabel' .. i]:setNumber(sum_damage)

			-- dps
			local dps = math_floor(sum_damage / lap_time)
			vars['dpsLabel' .. i]:setString(dps)

			-- 총데미지 계산
			if (best_damage < sum_damage) then
				best_damage = sum_damage
			end
		end

		for i, dragon in pairs(l_dragon) do
			-- 전체 대비 비율
			local log_recorder = dragon.m_charLogRecorder
			local sum_damage = log_recorder:getLog('damage')
			local percentage = (sum_damage/best_damage) * 100
			vars['dpsGauge' .. i]:runAction(cc.ProgressTo:create(0.2, percentage))
		end
	end
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