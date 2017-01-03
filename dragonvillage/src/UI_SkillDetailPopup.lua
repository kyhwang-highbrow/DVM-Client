local PARENT = UI

-------------------------------------
-- class UI_SkillDetailPopup
-------------------------------------
UI_SkillDetailPopup = class(PARENT, {
        m_tDragonData = 'table',
        m_cbUpgradeBtn = 'function',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillDetailPopup:init(t_dragon_data)
    self.m_tDragonData = t_dragon_data

    local vars = self:load('skill_detail_popup.ui')
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
    vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SkillDetailPopup:refresh()
    local t_dragon_data = self.m_tDragonData
    local vars = self.vars

    local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)

    local l_skill_icon = skill_mgr:getDragonSkillIconList()
    for i=0, MAX_DRAGON_EVOLUTION do
        vars['skillNode' .. i]:removeAllChildren()
        if l_skill_icon[i] then
            vars['skillNode' .. i]:addChild(l_skill_icon[i].root)

            -- 스킬 타입 label off
            l_skill_icon[i]:setSkillTypeVisible(false)

            -- 스킬 버튼 기능 off
            l_skill_icon[i]:setButtonEnabled(false)

            local t_skill = l_skill_icon[i].m_skillIndivisualInfo.m_tSkill
            local desc = IDragonSkillManager:getSkillDescPure(t_skill)
            
            -- 스킬 설명
            vars['skillInfoLabel' .. i]:setString(desc)

            -- 이름
            vars['skillNameLabel' .. i]:setString(t_skill['t_name'])

            -- 스킬 레벨
            vars['skillLevelLabel' .. i]:setString(Str('레벨 {1}', t_dragon_data['skill_' .. i]))
        end
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