local PARENT = UI

-------------------------------------
-- class UI_FormationDetailPopup
-------------------------------------
UI_FormationDetailPopup = class(PARENT, {
		m_formation = 'str',
		m_isActivated = 'boolean',

        m_formationLevel = 'number',
        m_enhanceLevel = 'number',
        m_maxEnhanceLevel = 'number',
     })

--@jhakiim 20191219 업데이트에서 테이머 레벨 99 확장, but 진형 테이머 스킬 레벨은 70으로 제한
local USER_MAX_LV = 70

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

    local user_lv = g_userData:get('lv')
    self.m_maxEnhanceLevel = math.min(USER_MAX_LV, user_lv)
    self.m_enhanceLevel = math.min(self.m_enhanceLevel, self.m_maxEnhanceLevel)

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
        vars['priceLabel']:setString(comma_value(price))
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
    local enhance_lv = self.m_enhanceLevel


	if (self.m_formationLevel == self.m_maxEnhanceLevel) then
		UIManager:toastNotificationRed(Str('강화 레벨을 지정하셔야 합니다.'))
		return
	end

    if (enhance_lv > self.m_maxEnhanceLevel) then
        enhance_lv = self.m_maxEnhanceLevel

        local msg = ''
        if (self.m_enhanceLevel == USER_MAX_LV) then
            msg = Str('더 이상 레벨업할 수 없습니다.')
        else
            msg = Str('유저 레벨 이상 레벨업 하실 수 없습니다.')
		end
        UIManager:toastNotificationRed(msg)
        return
    end

	local function cb_func()
        self.m_isActivated = true
        local new_data = g_formationData:getFormationInfo(self.m_formation)
        self.m_formationLevel = new_data['formation_lv']
        self.m_enhanceLevel = (self.m_formationLevel == self.m_maxEnhanceLevel) and self.m_maxEnhanceLevel or self.m_formationLevel + 1
        self:refresh()

        -- 이펙트 추가
        local visual = self.vars['enhanceVisual']
        visual:setVisible(true)
        visual:changeAni('slot_fx_01', false)
        visual:addAniHandler(function() visual:setVisible(false) end)

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
	if (self.m_enhanceLevel > self.m_maxEnhanceLevel) then
        self.m_enhanceLevel = self.m_maxEnhanceLevel

        local msg = ''
        if (self.m_enhanceLevel == USER_MAX_LV) then
            msg = Str('더 이상 레벨업할 수 없습니다.')
        else
            msg = Str('유저 레벨 이상 레벨업 하실 수 없습니다.')
		end
        UIManager:toastNotificationRed(msg)
        return
    end

	self:refresh()
end

-------------------------------------
-- function click_maxBtn
-------------------------------------
function UI_FormationDetailPopup:click_maxBtn()
    if (self.m_enhanceLevel == self.m_maxEnhanceLevel) then
        local msg = ''
        if (self.m_enhanceLevel == USER_MAX_LV) then
            msg = Str('더 이상 레벨업할 수 없습니다.')
        else
            msg = Str('유저 레벨 이상 레벨업 하실 수 없습니다.')
		end
        UIManager:toastNotificationRed(msg)
        return
    end

    self.m_enhanceLevel = self.m_maxEnhanceLevel
	self:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_FormationDetailPopup:click_closeBtn()
	-- 강화로 이뤄지지 않은 경우 콜백 X
    if (not self.m_isActivated) then 
        self:setCloseCB(nil)
    end
	self:close()
end

--@CHECK