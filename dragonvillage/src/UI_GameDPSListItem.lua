local PARENT = class(UI, ITableViewCell:getCloneTable())

local COMMON_UI_ACTION_TIME = 0.3

-------------------------------------
-- class UI_GameDPSListItem
-------------------------------------
UI_GameDPSListItem = class(PARENT, {
		m_dragonData = 'data',
		m_logKey = 'str',
		m_bestValue = 'num',
		m_labTime = 'time',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GameDPSListItem:init(dragon)
    local vars = self:load('ingame_dps_info_item.ui', false, true, true)

	self.m_dragonData = dragon
	self.m_logKey = 'damage'
	self.m_bestValue = 1
	self.m_labTime = 1

	-- UI 초기화
    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameDPSListItem:initUI()
	local vars = self.vars
	local dragon = self.m_dragonData

	-- dragon icon
    local sprite = IconHelper:getDragonIconFromTable(dragon.m_tDragonInfo, dragon.m_charTable)
	if (sprite) then
		vars['dragonNode']:addChild(sprite)
	end
    	
	-- damage per sec
	vars['dpsLabel'] = NumberLabelWithSpriteFrame(vars['dpsLabel'], 0, cc.TEXT_ALIGNMENT_RIGHT)
	
	-- 누적 damage
	vars['dpsGaugeLabel'] = NumberLabelWithSpriteFrame(vars['dpsGaugeLabel'], 0, cc.TEXT_ALIGNMENT_LEFT)

	-- 게이지 초기화
	vars['dpsGauge']:setScaleX(0)
	vars['hpsGauge']:setScaleX(0)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GameDPSListItem:refresh()
	if (self.m_labTime == 0) then
		return
	end

	local vars = self.vars
	local dragon = self.m_dragonData

	-- 누적 수치
	local log_recorder = dragon.m_charLogRecorder
	local sum_value = math_floor(log_recorder:getLog(self.m_logKey))
	vars['dpsGaugeLabel']:setNumber(sum_value, 0.5)
	
	-- 누적 수치의 비율
	local percentage = sum_value / self.m_bestValue
	local gauge_node = self:getGaugeNode(self.m_logKey)
	local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.5, percentage, 1))
    gauge_node:runAction(cc.EaseIn:create(action, 2))
	
	-- per second
	local lab_time = self.m_labTime
	local xps = math_floor(sum_value/lab_time)
	vars['dpsLabel']:setNumber(xps, 0.5)
end

-------------------------------------
-- function getGaugeNode
-------------------------------------
function UI_GameDPSListItem:getGaugeNode(log_key)
	local vars = self.vars
	local gauge_node
	local is_dps = (log_key == 'damage')

	if (is_dps) then
		gauge_node = vars['dpsGauge']
	else
		gauge_node = vars['hpsGauge']
	end

	return gauge_node
end

-------------------------------------
-- function changeGauge
-------------------------------------
function UI_GameDPSListItem:changeGauge(log_key)
	local vars = self.vars
	local is_dps = (log_key == 'damage')

	local dps_gauge = vars['dpsGauge']
	local hps_gauae = vars['hpsGauge']

	-- 게이지 on/off
	dps_gauge:setVisible(is_dps)
	hps_gauae:setVisible(not is_dps)
end

-------------------------------------
-- function setLogKey
-------------------------------------
function UI_GameDPSListItem:setLogKey(log_key)
	if (log_key ~= self.m_logKey) then
		self:changeGauge(log_key)
	end

	self.m_logKey = log_key
end