local PARENT = UI

-------------------------------------
-- class UI_SkillDetailPopup
-------------------------------------
UI_SkillDetailPopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SkillDetailPopup:init(t_dragon_data)
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
    --[[
skillNode4
skillNameLabel2
skillInfoLabel2
skillTypeLabel4
--]]
end

-------------------------------------
-- function click_upgradeBtn
-------------------------------------
function UI_SkillDetailPopup:click_upgradeBtn()
    self:close()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SkillDetailPopup:click_closeBtn()
    self:close()
end

--@CHECK