local PARENT = UI

-------------------------------------
-- class UI_IngameDragonPanel
-------------------------------------
UI_IngameDragonPanel = class(PARENT, {
        m_world = 'GameWorld',
        m_lPanelItemList = 'list',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IngameDragonPanel:init(world)
    self.m_world = world
	local vars = self:load('ingame_dragon_panel.ui')

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IngameDragonPanel:initUI()
    local vars = self.vars
    local world = self.m_world
    self.m_lPanelItemList = {}
    for i=1, 10 do
        local dragon = world.m_myDragons[i]
        if dragon then
            local dragon_idx = i
            self:insertPanelItem(dragon, dragon_idx)
        end
    end

    if world.m_friendDragon then
        local dragon = world.m_friendDragon
        local dragon_idx = 999
        self:insertPanelItem(dragon, dragon_idx)
    end


    local interval = 160
    local count = #self.m_lPanelItemList
    local l_pos_list = getSortPosList(interval, count)

    for i,v in ipairs(self.m_lPanelItemList) do
        v.root:setPositionX(l_pos_list[i])
    end
end

-------------------------------------
-- function insertPanelItem
-------------------------------------
function UI_IngameDragonPanel:insertPanelItem(dragon, dragon_idx)
    local vars = self.vars
    local world = self.m_world

    local ui = UI_IngameDragonPanelItem(world, dragon, dragon_idx)
    vars['panelMenu']:addChild(ui.root)
    table.insert(self.m_lPanelItemList, ui)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_IngameDragonPanel:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_IngameDragonPanel:refresh()
end