local PARENT = UI

-------------------------------------
-- class UI_DragonMasteryBoard
-------------------------------------
UI_DragonMasteryBoard = class(PARENT,{
        m_varsMap = '',
        m_uiMap = '',
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

    self:makeTierBoard(1)
    self:makeTierBoard(2)
    self:makeTierBoard(3)
    self:makeTierBoard(4)
    
    -- boardMenu
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMasteryBoard:refresh()
end

-------------------------------------
-- function makeTierBoard
-------------------------------------
function UI_DragonMasteryBoard:makeTierBoard(tier)
    local vars = self.vars

    local ui = UI()
    ui:load('dragon_mastery_skill_item.ui')
    vars['boardMenu']:addChild(ui.root)

    -- dragon_mastery_skill_item.ui 높이 : 273
    -- dragon_mastery_board.ui 높이 : 1092

    local pos_y = (1092 / 2) - (273 / 2)
    pos_y = pos_y - ((tier - 1) * 273)
    ui.root:setPositionY(pos_y)
    self.m_uiMap[tier] = ui

    for index=1, 3 do
        local _vars = self.m_varsMap[tier][index]
        _vars['masteryskillNode'] = ui.vars['masteryskillNode' .. index]
        _vars['skillInfoLabel'] = ui.vars['skillInfoLabel' .. index]
        _vars['notOpen'] = ui.vars['notOpen' .. index]
        _vars['skillNode'] = ui.vars['skillNode' .. index]
    end
end