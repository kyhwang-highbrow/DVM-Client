local PARENT = UI

-------------------------------------
-- class UI_SkillDetailPopup
-------------------------------------
UI_SkillDetailPopup = class(PARENT, {
        m_tDragonData = 'table',
        m_cbUpgradeBtn = 'function',
        m_bSimpleMode = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillDetailPopup:init(t_dragon_data, is_simple_mode)
    self.m_tDragonData = t_dragon_data
    self.m_bSimpleMode = is_simple_mode

    local vars = self:load('skill_detail_popup_new.ui')
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
    --vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SkillDetailPopup:refresh()
    local t_dragon_data = self.m_tDragonData
    local vars = self.vars

    local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
    for i=0, MAX_DRAGON_EVOLUTION do
    
        vars['skillNode' .. i]:removeAllChildren()
        local ui = UI_SkillDetailPopupListItem(t_dragon_data, skill_mgr, i, self.m_bSimpleMode)
        vars['skillNode' .. i]:addChild(ui.root)

    end
end

-------------------------------------
-- function click_upgradeBtn
-------------------------------------
function UI_SkillDetailPopup:click_upgradeBtn()
    local function ok_cb()
        self:close()

        if self.m_cbUpgradeBtn then
            self.m_cbUpgradeBtn()
        end
    end
    
    MakeSimplePopup(POPUP_TYPE.YES_NO, Str('"승급"화면에서 동일원종의 드래곤을 재료로 사용하여 스킬을 레벨업 할 수 있습니다.\n\n"승급"화면으로 이동하시겠습니까?'), ok_cb)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SkillDetailPopup:click_closeBtn()
    self:close()
end

--@CHECK