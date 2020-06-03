local PARENT = class(UI, ITableViewCell:getCloneTable())

local COMMON_UI_ACTION_TIME = 0.3

-------------------------------------
-- class UI_StatisticsListItem
-------------------------------------
UI_StatisticsListItem = class(PARENT, {
		m_dragonData = 'data',
		m_logKey = 'str',
		m_bestValue = 'num',
		m_rank = 'num',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_StatisticsListItem:init(dragon)
	local ui_name
	if (dragon.m_bLeftFormation) then
		ui_name = 'ingame_result_stats_popup_item_01.ui'
	else
		ui_name = 'ingame_result_stats_popup_item_02.ui'
	end

	local vars = self:load(ui_name) 

	self.m_dragonData = dragon

	-- UI 초기화
    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_StatisticsListItem:initUI()
	local vars = self.vars
	local dragon = self.m_dragonData

	-- dragon icon
	local ui = UI_DragonCard(dragon.m_tDragonInfo)
	vars['iconNode']:addChild(ui.root)
	
	-- 랭킹
	vars['rankingLabel'] = NumberLabel(vars['rankingLabel'], 0, COMMON_UI_ACTION_TIME)

	-- 이름
	vars['nameLabel']:setString(dragon:getName())
	
	-- 누적 damage
	vars['gaugeLabel'] = NumberLabel_Pumping(vars['gaugeLabel'], 0, COMMON_UI_ACTION_TIME)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_StatisticsListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_StatisticsListItem:refresh()
	local vars = self.vars
	local dragon = self.m_dragonData

	-- 누적 수치
	local log_recorder = dragon.m_charLogRecorder
	local sum_value = log_recorder:getLog(self.m_logKey)
	vars['gaugeLabel']:setNumber(math_floor(sum_value))

	-- 랭킹
	vars['rankingLabel']:setNumber(self.m_rank)

	-- 게이지 초기화
	self:initGauge()

	-- 누적 수치의 비율
	local percentage = (sum_value/self.m_bestValue) * 100
	local gauge_node = self:getGaugeNode(self.m_logKey)
	gauge_node:runAction(cc.ProgressTo:create(COMMON_UI_ACTION_TIME, percentage))
end

-------------------------------------
-- function initGauge
-------------------------------------
function UI_StatisticsListItem:initGauge()
	local vars = self.vars
	vars['dealtGauge']:setPercentage(0)
	vars['takenGauge']:setPercentage(0)
	vars['healingGauge']:setPercentage(0)
end

-------------------------------------
-- function getGaugeNode
-------------------------------------
function UI_StatisticsListItem:getGaugeNode(log_key)
	local vars = self.vars
	local gauge_node
	
	if (log_key == 'damage') then
		gauge_node = vars['dealtGauge']
	elseif (log_key == 'be_damaged') then
		gauge_node = vars['takenGauge']
	elseif (log_key == 'heal') then
		gauge_node = vars['healingGauge']
	end

	return gauge_node
end