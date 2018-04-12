local PARENT = UI
 
-------------------------------------
-- class UI_SkillDetailPopup_Tamer
-------------------------------------
UI_SkillDetailPopup_Tamer = class(PARENT, {
        m_cbUpgradeBtn = 'function',
        m_bSimpleMode = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillDetailPopup_Tamer:init(t_tamer)
    self.m_bSimpleMode = is_simple_mode
    self.m_uiName = 'UI_SkillDetailPopup_Tamer'

    local vars = self:load('tamer_skill_detail_popup_new.ui')
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
function UI_SkillDetailPopup_Tamer:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SkillDetailPopup_Tamer:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SkillDetailPopup_Tamer:refresh(t_tamer, skill_mgr)
    local t_tamer = t_tamer
	if (not t_tamer) then
		return
	end
	local skill_mgr = skill_mgr
	if (not skill_mgr) then
		local t_tamer_data = g_tamerData:getTamerServerInfo(t_tamer['tid'])
		skill_mgr = MakeTamerSkillManager(t_tamer_data)
	end

    local vars = self.vars
    for i= 0, 3 do
        vars['skillNode' .. i]:removeAllChildren()
        local ui = UI_SkillDetailPopupListItem_Tamer(t_tamer, skill_mgr, i, self.m_bSimpleMode)
        vars['skillNode' .. i]:addChild(ui.root)
    end
end

-------------------------------------
-- function show
-------------------------------------
function UI_SkillDetailPopup_Tamer:show()
	local function cb_func()
		g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SkillDetailPopup_Tamer')
	end
    self:doAction(cb_func, false)
end

-------------------------------------
-- function hide
-------------------------------------
function UI_SkillDetailPopup_Tamer:hide()
	local function cb_func()
		g_currScene:removeBackKeyListener(self)
	end

	self:doActionReverse(cb_func, 1, false)
	-- 갱신을 위해
	if (self.m_closeCB) then
		self.m_closeCB()
	end
end

-------------------------------------
-- function isShow
-------------------------------------
function UI_SkillDetailPopup_Tamer:isShow()
    return self.root:isVisible()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SkillDetailPopup_Tamer:click_closeBtn()
    self:hide()
end

--@CHECK