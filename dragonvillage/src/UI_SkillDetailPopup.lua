local PARENT = UI

-------------------------------------
-- class UI_SkillDetailPopup
-------------------------------------
UI_SkillDetailPopup = class(PARENT, {
        m_dragonObject = 'table',
        m_bSimpleMode = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillDetailPopup:init(dragon_object)
    self.m_dragonObject = dragon_object

    -- 플레이어의 드래곤이 아닐 경우 예외처리
    if (not self.m_bSimpleMode) then
        local uid = g_userData:get('uid')
        if (dragon_object['uid'] ~= uid) then
            self.m_bSimpleMode = true
        end
    end

    local vars = self:load('dragon_skill_detail_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SkillDetailPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SkillDetailPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SkillDetailPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SkillDetailPopup:refresh()
    local dragon_object = self.m_dragonObject
    local vars = self.vars

    local skill_mgr = MakeDragonSkillFromDragonData(dragon_object)
    for i=0, MAX_DRAGON_EVOLUTION do
    
        vars['skillNode' .. i]:removeAllChildren()
        local ui = UI_SkillDetailPopupListItem(dragon_object, skill_mgr, i, self.m_bSimpleMode)
        vars['skillNode' .. i]:addChild(ui.root)

    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SkillDetailPopup:click_closeBtn()
    self:close()
end

--@CHECK