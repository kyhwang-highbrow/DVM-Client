local PARENT = UI

-------------------------------------
-- class UI_DragonChanceUp
-------------------------------------
UI_DragonChanceUp = class(PARENT,{
        m_map_target_dragons = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonChanceUp:init()
    local map_target_dragons = g_eventData:getChanceUpDragons()
    if (not map_target_dragons) then
        return
    end

    self:load('event_chanceup.ui')

    self.m_map_target_dragons = map_target_dragons

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonChanceUp:initUI()
    local vars = self.vars
    local map_target_dragons = self.m_map_target_dragons

    local total_cnt = #table.MapToList(map_target_dragons)
    local idx = 0
    local width = 455

    for k, did in pairs(map_target_dragons) do
        idx = idx + 1
        local ui = UI_DragonChanceUpListItem(did)
        local pos_x = UIHelper:getNodePosXWithScale(total_cnt, idx, width)
        ui.root:setPositionX(pos_x)
        vars['itemNode']:addChild(ui.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonChanceUp:initButton()
    local vars = self.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_DragonChanceUp:onEnterTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonChanceUp:refresh()
end

--@CHECK
UI:checkCompileError(UI_DragonChanceUp)
