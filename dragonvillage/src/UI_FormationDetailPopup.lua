local PARENT = UI

-------------------------------------
-- class UI_FormationDetailPopup
-------------------------------------
UI_FormationDetailPopup = class(PARENT, {
		m_formation = 'str',
		m_isActivated = 'boolean',

        m_formationLevel = 'number',
        m_enhanceLevel = 'number',
     })

local USER_MAX_LV = 70 -- 유저 맥스 레벨 정보는 어디서?

-------------------------------------
-- function init
-------------------------------------
function UI_FormationDetailPopup:init(t_data)
    local vars = self:load('fomation_enhance_popup.ui')
    UIManager:open(self, UIManager.POPUP)
	
    self.m_formation = t_data['formation']
    self.m_formationLevel = t_data['formation_lv']
    self.m_enhanceLevel = self.m_formationLevel + 1
    self.m_isActivated = false

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_FormationDetailPopup')

	-- @UI_ACTION
    self:doActionReset()
	self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:setOpacityChildren(true)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FormationDetailPopup:initUI()
	local vars = self.vars
    local table_formation = TableFormation()

    local formation_type = self.m_formation
	local formation_lv = self.m_formationLevel

    do -- 진형 아이콘 1 & 2
		local is_activated = false
        local icon = IconHelper:getFormationIcon(formation_type, is_activated)
        vars['iconNode1']:addChild(icon)
		local icon2 = IconHelper:getFormationIcon(formation_type, is_activated)
        vars['iconNode2']:addChild(icon2)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FormationDetailPopup:initButton()
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
function UI_FormationDetailPopup:refresh()
	local vars = self.vars
    local table_formation = TableFormation()

    local formation_type = self.m_formation
    local curr_lv = self.m_formationLevel
	local next_lv = self.m_enhanceLevel
    
    do -- LV + 진형 이름 (좌측)
        local formation_name = table_formation:getFormationName(formation_type, curr_lv)
	    local formation_str = string.format('Lv. %d %s', curr_lv, formation_name)
        vars['titleLabel1']:setString(formation_str)
    end

	do -- 진형 설명 (좌측)
        local desc = table_formation:getFormatioDesc(formation_type, curr_lv)
        vars['dscLabel1']:setString(desc)
    end

    do -- LV + 진형 이름 (우측)
        local formation_name = table_formation:getFormationName(formation_type)
	    local formation_str = string.format('Lv. %d %s', next_lv, formation_name)
        vars['titleLabel2']:setString(formation_str)
    end

	do -- 진형 설명 (우측)
        local desc = table_formation:getFormatioDesc(formation_type, next_lv)
        vars['dscLabel2']:setString(desc)
    end

	do -- 강화 레벨 (증가량) + 강화 가격
        local dt_level = self.m_enhanceLevel -self.m_formationLevel
		vars['levelLabel']:setString(dt_level)
	end

	do -- 가격
        local price = self:getFormationEnhancePrice()
        vars['priceLabel']:setString(price)
    end

    
end

-------------------------------------
-- function getFormationEnhancePrice
-------------------------------------
function UI_FormationDetailPopup:getFormationEnhancePrice()
	local curr_formation_level = self.m_formationLevel
	local formation_level = self.m_enhanceLevel

	return TableReqGold:getTotalReqGold('formation', curr_formation_level, formation_level)
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_FormationDetailPopup:click_enhanceBtn()
    local curr_lv = self.m_formationLevel
    local user_lv = g_userData:get('lv')

    if (curr_lv >= USER_MAX_LV) or (curr_lv >= user_lv) then
        UIManager:toastNotificationGreen(Str('유저 레벨 이상 강화 하실 수 없습니다.'))
        return
    end

	local function cb_func()
        self.m_isActivated = true
        local new_data = g_formationData:getFormationInfo(self.m_formation)
        self.m_formationLevel = new_data['formation_lv']
        self.m_enhanceLevel = (self.m_formationLevel == USER_MAX_LV) and USER_MAX_LV or self.m_formationLevel + 1
        self:refresh()

		UIManager:toastNotificationGreen(Str('강화에 성공하였습니다.'))
	end	

    g_formationData:request_lvupFormation(self.m_formation, self.m_enhanceLevel, cb_func)
end

-------------------------------------
-- function click_levelBtn1
-------------------------------------
function UI_FormationDetailPopup:click_levelBtn1()
    -- 최소 현재레벨 +1 이상은 유지되도록
    if (self.m_enhanceLevel <= (self.m_formationLevel + 1)) then
        return
    end

	self.m_enhanceLevel = self.m_enhanceLevel - 1
	self:refresh()
end

-------------------------------------
-- function click_levelBtn2
-------------------------------------
function UI_FormationDetailPopup:click_levelBtn2()
	self.m_enhanceLevel = self.m_enhanceLevel + 1
	
    local max_lv = g_userData:get('lv')

	if (self.m_enhanceLevel > max_lv) then
		self.m_enhanceLevel = max_lv
		UIManager:toastNotificationGreen(Str('유저 레벨 이상 강화 하실 수 없습니다.'))
		return
	end

	self:refresh()
end

-------------------------------------
-- function click_maxBtn
-------------------------------------
function UI_FormationDetailPopup:click_maxBtn()
    local max_lv = g_userData:get('lv')
    if (max_lv == self.m_formationLevel) then
        UIManager:toastNotificationGreen(Str('유저 레벨 이상 강화 하실 수 없습니다.'))
        return
    end

	self.m_enhanceLevel = max_lv
	self:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_FormationDetailPopup:click_closeBtn()
	local function cb_func()
		-- 강화로 이뤄지지 않은 경우 콜백 X
        if (not self.m_isActivated) then 
            self:setCloseCB(nil)
        end
		self:close()
	end

	self:doActionReverse(cb_func, 1, false)
end

--@CHECK