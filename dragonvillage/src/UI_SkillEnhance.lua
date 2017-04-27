local PARENT = UI
 
-------------------------------------
-- class UI_SkillEnhance
-------------------------------------
UI_SkillEnhance = class(PARENT, {
        m_cbUpgradeBtn = 'function',
        m_bSimpleMode = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillEnhance:init(t_tamer)
    self.m_bSimpleMode = is_simple_mode

    local vars = self:load('skill_enhance_popup.ui')
    UIManager:open(self, UIManager.NORMAL)

	-- @UI_ACTION
    self:doActionReset()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SkillEnhance:initUI()
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
-- function show
-------------------------------------
function UI_SkillEnhance:show()
	local function cb_func()
		g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SkillEnhance')
	end
    self:doAction(cb_func, false)
end

-------------------------------------
-- function hide
-------------------------------------
function UI_SkillEnhance:hide()
	local function cb_func()
		g_currScene:removeBackKeyListener(self)
	end
	self:doActionReverse(cb_func, 1, false)
end

-------------------------------------
-- function isShow
-------------------------------------
function UI_SkillEnhance:isShow()
    return self.root:isVisible()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SkillEnhance:click_closeBtn()
    self:hide()
end

--@CHECK