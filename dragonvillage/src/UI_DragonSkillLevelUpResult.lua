local PARENT = UI

-------------------------------------
-- class UI_DragonSkillLevelUpResult
-------------------------------------
UI_DragonSkillLevelUpResult = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkillLevelUpResult:init(dragon_skill_mgr, skill_index)
    local vars = self:load('dragon_skill_levelup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonSkillLevelUpResult')

    self:initUI(dragon_skill_mgr, skill_index)
    self:initButton()
    self:refresh()

    SoundMgr:playEffect('EFFECT', 'success_starup')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSkillLevelUpResult:initUI(dragon_skill_mgr, skill_index)
    local vars = self.vars
    local icon = dragon_skill_mgr:makeSkillIcon_usingIndex(skill_index)
    vars['skillNode']:addChild(icon.root)





    -- 스킬 타입 label off
    icon:setSkillTypeVisible(false)

    -- 스킬 버튼 기능 off
    icon:setButtonEnabled(false)

    local t_skill = icon.m_skillIndivisualInfo.m_tSkill
    local desc = IDragonSkillManager:getSkillDescPure(t_skill)
            
    -- 스킬 설명
    vars['skillInfoLabel']:setString(desc)

    -- 이름
    vars['skillNameLabel']:setString(t_skill['t_name'])

    -- 스킬 레벨
    vars['skillLevelLabel']:setString(Str('레벨 {1}', icon.m_skillIndivisualInfo.m_skillLevel))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonSkillLevelUpResult:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSkillLevelUpResult:refresh()
    local vars = self.vars
end


-------------------------------------
-- function checkSkillLevelUp
-- @brief 이전 드래곤 정보와 현재 드래곤 정보를 기반으로
--        스킬 레벨이 변경되었는지 체크 후 팝업을 순차적으로 띄움
-------------------------------------
function UI_DragonSkillLevelUpResult:checkSkillLevelUp(t_prev_dragon_data, t_dragon_data)

    -- 스킬 레벨이 변경된 index를 수집
    local l_levelup_skills = {}
    for i=0, 3 do
        local key = 'skill_' .. i
        if (t_prev_dragon_data[key] < t_dragon_data[key]) then
            table.insert(l_levelup_skills, i)
        end
    end
    
    -- 레벨업된 스킬의 갯수가 0개일 경우 리턴
    if (#l_levelup_skills <= 0) then
        return
    end

    -- 스킬 매니저 생성
    local dragon_skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)

    if (not l_levelup_skills[1]) then
        return
    end

    local skill_index = l_levelup_skills[1]
    local ui = UI_DragonSkillLevelUpResult(dragon_skill_mgr, skill_index)
    return ui

    --[[
    -- 순차적으로 팝업을 띄우는 함수 생성
    local pop_ui
    pop_ui = function()
        if (not l_levelup_skills[1]) then
            return
        end

        local skill_index = l_levelup_skills[1]
        local ui = UI_DragonSkillLevelUpResult(dragon_skill_mgr, skill_index)
        ui:setCloseCB(pop_ui)

        table.remove(l_levelup_skills, 1)
    end

    pop_ui()
    --]]
end


--@CHECK
UI:checkCompileError(UI_DragonSkillLevelUpResult)
