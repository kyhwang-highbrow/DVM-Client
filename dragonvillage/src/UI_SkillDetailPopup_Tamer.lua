local PARENT = UI
 
-------------------------------------
-- class UI_SkillDetailPopup_Tamer
-------------------------------------
UI_SkillDetailPopup_Tamer = class(PARENT, {
        m_tableTamer = 'table',
        m_cbUpgradeBtn = 'function',
        m_bSimpleMode = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillDetailPopup_Tamer:init(t_tamer)
    self.m_tableTamer = t_tamer
    self.m_bSimpleMode = is_simple_mode

    local vars = self:load('tamer_skill_detail_popup.ui')
    UIManager:open(self, UIManager.NORMAL)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SkillDetailPopup_Tamer')

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
function UI_SkillDetailPopup_Tamer:refresh(t_tamer)
    local t_tamer = t_tamer or self.m_tableTamer
	if (not t_tamer) then
		return
	end

    local vars = self.vars
    local skill_mgr = MakeTamerSkill_Temp(t_tamer)
    for i= 1, 3 do
        vars['skillNode' .. i]:removeAllChildren()
        local ui = UI_SkillDetailPopupListItem_Tamer(t_tamer, skill_mgr, i, self.m_bSimpleMode)
        vars['skillNode' .. i]:addChild(ui.root)
    end
end

-------------------------------------
-- function show
-------------------------------------
function UI_SkillDetailPopup_Tamer:show()
    self.root:setVisible(true)
	g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SkillDetailPopup_Tamer')
end

-------------------------------------
-- function hide
-------------------------------------
function UI_SkillDetailPopup_Tamer:hide()
    self.root:setVisible(false)
	g_currScene:removeBackKeyListener(self)
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