local PARENT = UI

-------------------------------------
-- class UI_DragonMasteryBoard
-------------------------------------
UI_DragonMasteryBoard = class(PARENT,{
        m_varsMap = '',
        m_uiMap = '',

        m_selectedTier = 'number',
        m_selectedIndex = 'number',

        m_masterySkillSelectCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMasteryBoard:init(doid)
    local vars = self:load('dragon_mastery_board.ui')

    self.m_uiMap = {}

    self.m_varsMap = {}
    for tier=1, 4 do
        self.m_varsMap[tier] = {}
        for index=1, 3 do
            self.m_varsMap[tier][index] = {}
        end
    end

    self:initUI()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonMasteryBoard:initUI()
    local vars = self.vars

    -- 특성은 티어가 4개. 한 티어에 3개의 스킬.
    self:makeTierBoard(1)
    self:makeTierBoard(2)
    self:makeTierBoard(3)
    self:makeTierBoard(4)
    
    -- boardMenu
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMasteryBoard:refresh(dragon_obj)
    if (not dragon_obj) then
        return
    end

    -- 드래곤 희귀도, 역할
    for tier=1, 4 do
        for index=1, 3 do
            self:refreshMasterySkillUI(tier, index, dragon_obj)
        end
    end

    self:setSelectedMasterySkill(self.m_selectedTier, self.m_selectedIndex)
end

-------------------------------------
-- function refreshMasterySkillUI
-------------------------------------
function UI_DragonMasteryBoard:refreshMasterySkillUI(tier, index, dragon_obj)
    if (not dragon_obj) then
        return
    end

    local rarity_str = dragon_obj:getRarity()
    local role_str = dragon_obj:getRole()

    local _vars = self.m_varsMap[tier][index]

    -- 특성 스킬 ID
    local mastery_skill_id = TableMasterySkill:makeMasterySkillID(rarity_str, role_str, tier, index)

    -- 특성 스킬 LV
    local mastery_skill_lv = dragon_obj:getMasterySkilLevel(mastery_skill_id)

    -- 스킬 아이콘
    _vars['skillNode']:removeAllChildren()
    local icon = UI_DragonMasterySkillCard(mastery_skill_id, mastery_skill_lv)
    _vars['skillNode']:addChild(icon.root)

    -- 스킬 설명
    local desc = TableMasterySkill:getMasterySkillOptionDesc(mastery_skill_id, math_max(mastery_skill_lv, 1))
    _vars['skillInfoLabel']:setString(desc or '')
end

-------------------------------------
-- function makeTierBoard
-------------------------------------
function UI_DragonMasteryBoard:makeTierBoard(tier)
    local vars = self.vars

    local ui = UI()
    ui:load('dragon_mastery_skill_item.ui')
    vars['boardMenu']:addChild(ui.root)
    ui.vars['swallowTouchMenu']:setSwallowTouch(false)

    -- dragon_mastery_skill_item.ui 높이
    -- dragon_mastery_board.ui 높이
    local board_height = 1092
    local skill_item_height = 273

    local pos_y = (board_height / 2) - (skill_item_height / 2)
    pos_y = pos_y - ((tier - 1) * skill_item_height)
    ui.root:setPositionY(pos_y)
    self.m_uiMap[tier] = ui

    -- 특성은 티어가 4개. 한 티어에 3개의 스킬.
    for index=1, 3 do
        local _vars = self.m_varsMap[tier][index]
        _vars['masteryskillBtn'] = ui.vars['masteryskillBtn' .. index]
        _vars['skillInfoLabel'] = ui.vars['skillInfoLabel' .. index]
        _vars['notOpen'] = ui.vars['notOpen' .. index]
        _vars['skillNode'] = ui.vars['skillNode' .. index]
        _vars['selectedSkill'] = ui.vars['selectedSkill' .. index]
        _vars['masteryskillBtn']:registerScriptTapHandler(function() self:click_masterySkillIcon(tier, index) end)
    end
end

-------------------------------------
-- function click_masterySkillIcon
-- @brief
-------------------------------------
function UI_DragonMasteryBoard:click_masterySkillIcon(tier, index)
    self:setSelectedMasterySkill(tier, index)
end

-------------------------------------
-- function setSelectedMasterySkill
-- @brief
-------------------------------------
function UI_DragonMasteryBoard:setSelectedMasterySkill(tier, index)
    local prev_tier = self.m_selectedTier
    local prev_index = self.m_selectedIndex
    if (prev_tier and prev_index) then
        local _vars = self.m_varsMap[prev_tier][prev_index]
        _vars['selectedSkill']:setVisible(false)
    end

    self.m_selectedTier = tier
    self.m_selectedIndex = index

    if (tier and index) then
        local _vars = self.m_varsMap[tier][index]
        _vars['selectedSkill']:setVisible(true)
    end

    if self.m_masterySkillSelectCB then
        self.m_masterySkillSelectCB(tier, index)
    end
end


-------------------------------------
-- function setMasterySkillSelectCB
-- @brief
-- @param function(tier, index) end
-------------------------------------
function UI_DragonMasteryBoard:setMasterySkillSelectCB(func)
    self.m_masterySkillSelectCB = func
end

-------------------------------------
-- function getSelectedTierAndIndex
-- @brief 현재 선택된 tier와 index 리턴
-------------------------------------
function UI_DragonMasteryBoard:getSelectedTierAndIndex()
    return self.m_selectedTier, self.m_selectedIndex
end