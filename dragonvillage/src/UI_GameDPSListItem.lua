local PARENT = class(UI, ITableViewCell:getCloneTable())

local COMMON_UI_ACTION_TIME = 0.3

-------------------------------------
-- class UI_GameDPSListItem
-------------------------------------
UI_GameDPSListItem = class(PARENT, {
		m_dragonData = 'data', -- Dragon클래스(Dragon.lua)
		m_logKey = 'str',
		m_bestValue = 'num',
		m_labTime = 'time',
        m_bSetExp = 'bool', -- 경험치 정보가 설정되었는지 여부 (게임 중에 경험치 변경은 없으므로 1회만 동작되도록 하기 위함)
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GameDPSListItem:init(dragon)
    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_btn/ingame_btn.plist')

    local vars = self:load('ingame_dps_info_item.ui', false, true, true)

	self.m_dragonData = dragon
	self.m_logKey = ''
	self.m_bestValue = 1
	self.m_labTime = 1
    self.m_bSetExp = false

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
    vars['expGauge']:setScaleX(0)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GameDPSListItem:refresh()
    if (self.m_logKey == 'exp') then
        self:refresh_exp()
        return
    end

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
-- function refresh_exp
-------------------------------------
function UI_GameDPSListItem:refresh_exp()
    if (self.m_bSetExp == true) then
        return
    end

    local dragon = self.m_dragonData -- Dragon클래스 (Dragon.lua)

    local vars = self.vars
    local grade = dragon:getGrade()
    local lv = dragon:getLevel()
    local exp = dragon:getExp()

    local max_level = dragonMaxLevel(grade)
    local is_max_level = (lv >= max_level)

    -- 등급, 레벨 표시
    local grade_and_level_str = tostring(grade) .. ' Lv.' .. tostring(lv)
    vars['expLevelLabel']:setString(grade_and_level_str)

    -- 경험치 비율 or MAX 표시
    local exp_str = ''
    if is_max_level then
        exp_str = 'MAX'
    else
        local table_exp = TableDragonExp()
        local max_exp = table_exp:getDragonMaxExp(grade, lv)
        local exp_percent = (exp / max_exp) * 100
        exp_str = string.format('%.2f%%', exp_percent)

        local percentage = (exp_percent / 100)
        local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.5, percentage, 1))
        vars['expGauge']:runAction(cc.EaseIn:create(action, 2))
    end
    vars['expLabel']:setString(exp_str)

    vars['expMaxSprite']:setVisible(is_max_level == true)
    vars['expGauge']:setVisible(is_max_level == false)

    self.m_bSetExp = true
end

-------------------------------------
-- function getGaugeNode
-------------------------------------
function UI_GameDPSListItem:getGaugeNode(log_key)
	local vars = self.vars
	local gauge_node

	if (log_key == 'damage') then
		gauge_node = vars['dpsGauge']
	elseif (log_key == 'heal') then
		gauge_node = vars['hpsGauge']
	end

	return gauge_node
end

-------------------------------------
-- function changeGauge
-------------------------------------
function UI_GameDPSListItem:changeGauge(log_key)
	local vars = self.vars
    vars['dpsGauge']:setVisible(log_key == 'damage')
    vars['hpsGauge']:setVisible(log_key == 'heal')

    -- damage, heal의 경우에만 사용하는 라벨
	vars['dpsLabel'].m_node:setVisible(log_key ~= 'exp')
	vars['dpsGaugeLabel'].m_node:setVisible(log_key ~= 'exp')

    -- 경험치 메뉴
    vars['expMenu']:setVisible(log_key == 'exp')
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