local PARENT = UI
 
-------------------------------------
-- class UI_SkillEnhance
-------------------------------------
UI_SkillEnhance = class(PARENT, {
		m_tableTamer = 'Table',
		m_skillIndividualInfo = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillEnhance:init(t_tamer, skill_indivisual_info)
	self.m_tableTamer = t_tamer
    self.m_skillIndividualInfo = skill_indivisual_info

    local vars = self:load('skill_enhance_popup.ui')
    UIManager:open(self, UIManager.POPUP)
	
	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SkillEnhance')

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
function UI_SkillEnhance:initUI()
	local vars = self.vars
	local skill_indivisual_info = self.m_skillIndividualInfo
	local skill_level = skill_indivisual_info:getSkillLevel()

    do -- 스킬 아이콘
		local char_type = skill_indivisual_info.m_charType
        local skill_id = skill_indivisual_info:getSkillID()
        local icon = IconHelper:getSkillIcon(char_type, skill_id)
        vars['iconNode1']:addChild(icon)
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
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SkillEnhance:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SkillEnhance:click_closeBtn()
	local function cb_func()
		self:close()
	end

	self:doActionReverse(cb_func, 1, false)
end

--@CHECK