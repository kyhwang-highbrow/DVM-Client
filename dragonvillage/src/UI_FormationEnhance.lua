local PARENT = UI
 
-------------------------------------
-- class UI_FormationEnhance
-------------------------------------
UI_FormationEnhance = class(PARENT, {
		m_formation = 'str',
		m_currFormationLV = 'num',
		m_enhanceLevel = 'num',
		m_maxFormationLevel = 'num',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_FormationEnhance:init(formation, formation_lv)
	-- 멤버 변수
    local vars = self:load('skill_enhance_popup.ui')
    UIManager:open(self, UIManager.POPUP)
	
	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_FormationEnhance')

	-- @UI_ACTION
    self:doActionReset()
	self:doAction(nil, false)

	-- 멤버 변수
	self.m_formation = formation
	self.m_currFormationLV = formation_lv
	self.m_enhanceLevel = formation_lv + 1
	self.m_maxFormationLevel = g_userData:get('lv')
	if (self.m_enhanceLevel > self.m_maxFormationLevel) then
		self.m_enhanceLevel = self.m_maxFormationLevel
	end

	-- init
    self:initUI()
    self:initButton()
    self:refresh()

    self:setOpacityChildren(true)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FormationEnhance:initUI()
	local vars = self.vars
	
	local table_formation = TableFormation()
	
	local formation_type = self.m_formation
	local formation_lv = self.m_currFormationLV

    do -- 진형 아이콘 1 & 2
		local icon = IconHelper:getFormationIcon(formation_type, true)
        vars['iconNode1']:addChild(icon)
		local icon2 = IconHelper:getFormationIcon(formation_type, true)
        vars['iconNode2']:addChild(icon2)
    end

    do -- LV + 진형 이름
        local formation_name = table_formation:getFormationName(formation_type)
		local formation_str = string.format('Lv. %d %s', formation_lv, formation_name)
        vars['titleLabel1']:setString(formation_str)
    end

	do -- 진형 설명
        local desc = table_formation:getFormatioDesc(formation_type, formation_lv)
        vars['dscLabel1']:setString(desc)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FormationEnhance:initButton()
    local vars = self.vars

    vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
	vars['levelBtn1']:registerScriptTapHandler(function() self:click_levelBtn1() end)
	vars['levelBtn2']:registerScriptTapHandler(function() self:click_levelBtn2() end)
	vars['maxBtn']:registerScriptTapHandler(function() self:click_maxBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FormationEnhance:refresh()
	local vars = self.vars
	
	local table_formation = TableFormation()
	
	local formation_type = self.m_formation
	local formation_lv = self.m_enhanceLevel

    do -- LV + 진형 이름
        local formation_name = table_formation:getFormationName(formation_type)
		local formation_str = string.format('Lv. %d %s', formation_lv, formation_name)
        vars['titleLabel2']:setString(formation_str)
    end

	do -- 진형 설명
        local desc = table_formation:getFormatioDesc(formation_type, formation_lv)
        vars['dscLabel2']:setString(desc)
    end

	do -- 강화 레벨 (증가량) + 강화 가격
        local dt_level = self.m_enhanceLevel - self.m_currFormationLV
		vars['levelLabel']:setString(dt_level)
	end

	do
        local price = self:getFormationEnhancePrice()
        vars['priceLabel']:setString(price)
    end
end

-------------------------------------
-- function getFormationEnhancePrice
-------------------------------------
function UI_FormationEnhance:getFormationEnhancePrice()
	local curr_formation_level = self.m_currFormationLV
	local formation_level = self.m_enhanceLevel

	return TableReqGold:getTotalReqGold('formation', curr_formation_level, formation_level)
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_FormationEnhance:click_enhanceBtn()
	if (self.m_currFormationLV == self.m_maxFormationLevel) then
		UIManager:toastNotificationGreen(Str('강화 레벨을 지정하셔야 합니다.'))
		return
	end

	local function cb_func()
		self:close()
	end

	g_formationData:request_lvupFormation(self.m_formation, self.m_enhanceLevel, cb_func)
end

-------------------------------------
-- function click_levelBtn1
-------------------------------------
function UI_FormationEnhance:click_levelBtn1()
	self.m_enhanceLevel = self.m_enhanceLevel - 1
	
	local curr_formation_level = self.m_currFormationLV
	if (self.m_enhanceLevel < curr_formation_level) then
		self.m_enhanceLevel = curr_formation_level
		return
	end

	self:refresh()
end

-------------------------------------
-- function click_levelBtn2
-------------------------------------
function UI_FormationEnhance:click_levelBtn2()
	self.m_enhanceLevel = self.m_enhanceLevel + 1
	
	if (self.m_enhanceLevel > self.m_maxFormationLevel) then
		self.m_enhanceLevel = self.m_maxFormationLevel
		UIManager:toastNotificationGreen(Str('유저 레벨 이상 레벨업 하실 수 없습니다.'))
		return
	end

	self:refresh()
end

-------------------------------------
-- function click_maxBtn
-------------------------------------
function UI_FormationEnhance:click_maxBtn()
	self.m_enhanceLevel = self.m_maxFormationLevel

	self:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_FormationEnhance:click_closeBtn()
	local function cb_func()
		-- 강화가 이뤄지지 않은 경우 콜백 X
		self:setCloseCB(nil)
		self:close()
	end

	self:doActionReverse(cb_func, 1/2, false)
end

--@CHECK