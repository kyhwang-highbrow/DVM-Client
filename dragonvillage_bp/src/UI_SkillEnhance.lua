local PARENT = UI
 
-------------------------------------
-- class UI_SkillEnhance
-------------------------------------
UI_SkillEnhance = class(PARENT, {
		m_tableTamer = 'Table',
		m_skillIndividualInfo = '',

		m_skillIdx = 'num',
		m_enhanceLevel = 'num',
		m_maxSkillLevel = 'num',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillEnhance:init(t_tamer, skill_indivisual_info, skill_idx)
    local vars = self:load('skill_enhance_popup.ui')
    UIManager:open(self, UIManager.POPUP)
	
	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SkillEnhance')

	-- @UI_ACTION
    self:doActionReset()
	self:doAction(nil, false)

	-- 멤버 변수
	self.m_tableTamer = t_tamer
    self.m_skillIndividualInfo = skill_indivisual_info
	self.m_skillIdx = skill_idx
	self.m_enhanceLevel = skill_indivisual_info:getSkillLevel() + 1
	self.m_maxSkillLevel = g_userData:get('lv')
	if (self.m_enhanceLevel > self.m_maxSkillLevel) then
		self.m_enhanceLevel = self.m_maxSkillLevel
	end

    self:initUI()
    self:initButton()
    self:refresh()

    self:setOpacityChildren(true)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SkillEnhance:initUI()
	local vars = self.vars
	local skill_indivisual_info = self.m_skillIndividualInfo
	local skill_level = skill_indivisual_info:getSkillLevel()

    do -- 스킬 아이콘 1 & 2
		local char_type = skill_indivisual_info.m_charType
        local skill_id = skill_indivisual_info:getSkillID()
        local icon = IconHelper:getSkillIcon(char_type, skill_id)
        vars['iconNode1']:addChild(icon)
		local icon2 = IconHelper:getSkillIcon(char_type, skill_id)
        vars['iconNode2']:addChild(icon2)
    end

    do -- LV + 스킬 이름
        local name = skill_indivisual_info:getSkillName()
		local title_str = string.format('LV.%d %s', skill_level, name)
        vars['titleLabel1']:setString(title_str)
    end

	do -- 스킬 설명
        local desc = skill_indivisual_info:getSkillDesc()
        vars['dscLabel1']:setString(desc)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SkillEnhance:initButton()
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
function UI_SkillEnhance:refresh()
	local vars = self.vars
	local skill_indivisual_info = self.m_skillIndividualInfo
	local skill_level = self.m_enhanceLevel

    do -- LV + 스킬 이름
        local name = skill_indivisual_info:getSkillName()
		local title_str = string.format('LV.%d %s', skill_level, name)
        vars['titleLabel2']:setString(title_str)
    end

	do -- 스킬 설명
        local desc = self:getEnhanceSkillDesc(skill_indivisual_info.m_tSkill, skill_level)
        vars['dscLabel2']:setString(desc)
    end

	do -- 강화 레벨 (증가량) + 강화 가격
        local dt_level = self.m_enhanceLevel - skill_indivisual_info:getSkillLevel()
		vars['levelLabel']:setString(dt_level)
	end

	do
        local price = self:getSkillEnhancePrice()
        vars['priceLabel']:setString(price)
    end
end

-------------------------------------
-- function getSkillEnhancePrice
-------------------------------------
function UI_SkillEnhance:getSkillEnhancePrice(dt_level)
	local curr_skill_lv = self.m_skillIndividualInfo:getSkillLevel()
	local skill_level = self.m_enhanceLevel

	return TableReqGold:getTotalReqGold('tamer_skill', curr_skill_lv, skill_level)
end

-------------------------------------
-- function getEnhanceSkillDesc
-------------------------------------
function UI_SkillEnhance:getEnhanceSkillDesc(t_skill, skill_lv)
	local t_skill = clone(TableTamerSkill():getTamerSkill(t_skill['sid']))
	DragonSkillCore.applySkillLevel('tamer', t_skill, skill_lv)
	DragonSkillCore.substituteSkillDesc(t_skill)

	return DragonSkillCore.getSkillDescPure(t_skill)
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_SkillEnhance:click_enhanceBtn()
	if (self.m_skillIndividualInfo:getSkillLevel() == self.m_maxSkillLevel) then
		UIManager:toastNotificationGreen(Str('강화 레벨을 지정하셔야 합니다.'))
		return
	end

    local tid = self.m_tableTamer['tid']
	local function cb_func()
        -- @ MASTER ROAD
        local t_data = {clear_key = 't_sklvup'}
        g_masterRoadData:updateMasterRoad(t_data)

		self:close()
	end

	g_tamerData:request_tamerSkillEnhance(tid, self.m_skillIdx, self.m_enhanceLevel, cb_func)
end

-------------------------------------
-- function click_levelBtn1
-------------------------------------
function UI_SkillEnhance:click_levelBtn1()

    -- 스킬의 현재 레벨을 얻어옴
    local skill_indivisual_info = self.m_skillIndividualInfo
    local skill_level = skill_indivisual_info:getSkillLevel()

    -- 최소 현재레벨 +1 이상은 유지되도록
    if (self.m_enhanceLevel <= (skill_level + 1)) then
        return
    end

	self.m_enhanceLevel = self.m_enhanceLevel - 1
	
	local skill_level = self.m_skillIndividualInfo:getSkillLevel()
	if (self.m_enhanceLevel < skill_level) then
		self.m_enhanceLevel = skill_level
		return
	end

	self:refresh()
end

-------------------------------------
-- function click_levelBtn2
-------------------------------------
function UI_SkillEnhance:click_levelBtn2()
	self.m_enhanceLevel = self.m_enhanceLevel + 1
	
	if (self.m_enhanceLevel > self.m_maxSkillLevel) then
		self.m_enhanceLevel = self.m_maxSkillLevel
		UIManager:toastNotificationGreen(Str('유저 레벨 이상 레벨업 하실 수 없습니다.'))
		return
	end

	self:refresh()
end

-------------------------------------
-- function click_maxBtn
-------------------------------------
function UI_SkillEnhance:click_maxBtn()
	self.m_enhanceLevel = self.m_maxSkillLevel

	self:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SkillEnhance:click_closeBtn()
	local function cb_func()
		-- 강화로 이뤄지지 않은 경우 콜백 X
		self:setCloseCB(nil)
		self:close()
	end

	self:doActionReverse(cb_func, 1, false)
end

--@CHECK