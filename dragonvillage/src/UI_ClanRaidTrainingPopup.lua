local PARENT = class(UI)

-------------------------------------
-- class UI_ClanRaidTrainingPopup
-------------------------------------
UI_ClanRaidTrainingPopup = class(PARENT, {
        m_cur_stage_id = 'number',
     })


-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidTrainingPopup:init(stage_id)
    local vars = self:load('clan_raid_training.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_cur_stage_id = stage_id

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanRaidTrainingPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    
    self:refresh(true)

end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidTrainingPopup:initUI()
    local vars = self.vars
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaidTrainingPopup:initButton()
    local vars = self.vars
    for i=1,5 do
        vars['attrBtn'..i]:registerScriptTapHandler(function() self:click_attrBtn(i) end)
    end

    vars['okBtn']:registerScriptTapHandler(function() self:click_applyBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaidTrainingPopup:refresh(force)
    
end

-------------------------------------
-- function click_attrBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_attrBtn(ind)
    
end

-------------------------------------
-- function click_applyBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_applyBtn()
    UI_ReadySceneNew(self.m_cur_stage_id, 'training') 
end

--@CHECK
UI:checkCompileError(UI_ClanRaidTrainingPopup)







