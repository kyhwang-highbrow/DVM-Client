-------------------------------------
-- class UI_DragonMasteryBoardNew
-------------------------------------
UI_DragonMasteryBoardNew = class({
        vars = 'table',
        m_masterySkillUIMap = 'table[tier][num]',
        m_masterySkillPlusBtnCB = 'function(tier, num)',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMasteryBoardNew:init(vars, dragon_obj)
    self.vars = vars

    self:initUI()

    self:refresh(dragon_obj)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonMasteryBoardNew:initUI()
    local vars = self.vars
    self.m_masterySkillUIMap = {}

    local max_tier = 4
    local max_num = 3

    for tier=1, max_tier do
        
        if (not self.m_masterySkillUIMap[tier]) then
            self.m_masterySkillUIMap[tier] = {}
        end

        for num=1, max_num do

            local ui = UI()
            ui:load('dragon_mastery_skill_item_new.ui')
            ui.vars['plusBtn']:registerScriptTapHandler(function() self:click_plusBtn(tier, num) end)

            local index = ((tier - 1) * max_num) + num
            vars['skillItemNode' .. index]:addChild(ui.root)

            self.m_masterySkillUIMap[tier][num] = ui
        end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMasteryBoardNew:refresh(dragon_obj)
    if (not dragon_obj) then
        return
    end

    local vars = self.vars

    
    local max_tier = 4
    local max_num = 3

    for tier=1, max_tier do
        for num=1, max_num do
            self:refreshMasterySkillUI(tier, num, dragon_obj)

            -- 연출
            local index = ((tier - 1) * max_num) + num
            local ui = self.m_masterySkillUIMap[tier][num]
            cca.fruitReact_MasterySkillIcon(ui.root, index, 0.5) -- node, idx_factor, start_scale
        end

        local tier_state_str = MasteryHelper:getMasteryTierStateStr(dragon_obj, tier, true) -- dragon_obj, tier, is_rich_text
        vars['conditionLabel' .. tier]:setString(tier_state_str)
    end

end

-------------------------------------
-- function refreshMasterySkillUI
-------------------------------------
function UI_DragonMasteryBoardNew:refreshMasterySkillUI(tier, num, dragon_obj)
    local rarity_str = dragon_obj:getRarity()
    local role_str = dragon_obj:getRole()

    local skill_ui = self.m_masterySkillUIMap[tier][num]
    local _vars = skill_ui.vars

    -- 특성 스킬 ID
    local mastery_skill_id = TableMasterySkill:makeMasterySkillID(rarity_str, role_str, tier, num)

    -- 특성 스킬 LV
    local mastery_skill_lv = dragon_obj:getMasterySkilLevel(mastery_skill_id)

    -- 스킬 아이콘
    _vars['skillIconNode']:removeAllChildren()
    --local icon = UI_DragonMasterySkillCard(mastery_skill_id, mastery_skill_lv)
    local res_name = TableMasterySkill():getValue(mastery_skill_id, 'icon')
    local icon = IconHelper:getIcon(res_name)
    _vars['skillIconNode']:addChild(icon)

    -- 스킬 이름
    --local desc = TableMasterySkill:getMasterySkillOptionDesc(mastery_skill_id, math_max(mastery_skill_lv, 1), true)
    local name = TableMasterySkill:getMasterySkillName(mastery_skill_id)
    if (1 <= mastery_skill_lv) then
        name = name .. '{@SKILL_VALUE_MOD} +' .. tostring(mastery_skill_lv)
    end
    _vars['skillLabel1']:setString('{@DESC}' .. (name or ''))

    local step_desc = TableMasterySkill:getMasterySkillStepDesc(mastery_skill_id, mastery_skill_lv, true)
    _vars['skillLabel2']:setString(step_desc or '')

    -- 특성 스킬이 1레벨 이상인 경우 추가 표시
    if (1 <= mastery_skill_lv) then
        _vars['selectSprite']:setVisible(true)
    else
        _vars['selectSprite']:setVisible(false)
    end

    -- 잠금 표시 (스킬 레벨업 가능 상태가 아니고 0레벨일 경우 표시)
    local tier_state = MasteryHelper:getMasteryTierState(dragon_obj, tier)
    _vars['lockNode']:setVisible((tier_state ~= 0) and (mastery_skill_lv == 0))
    _vars['lockIconNode']:setVisible(tier_state == -1)

    _vars['plusBtn']:setVisible(tier_state == 0)
end

-------------------------------------
-- function click_plusBtn
-- @brief
-------------------------------------
function UI_DragonMasteryBoardNew:click_plusBtn(tier, num)
    self.m_masterySkillPlusBtnCB(tier, num)
end


-------------------------------------
-- function setMasterySkillPlusBtnCB
-- @brief
-------------------------------------
function UI_DragonMasteryBoardNew:setMasterySkillPlusBtnCB(func)
    self.m_masterySkillPlusBtnCB = func
end
