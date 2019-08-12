local PARENT = UI

-------------------------------------
-- class UI_IngameDragonPanel
-------------------------------------
UI_IngameDragonPanel = class(PARENT, {
        m_world = 'GameWorld',
        m_lPanelItemList = 'list',
        m_bVisible = '',
        
        m_menuPosY = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IngameDragonPanel:init(world)
    self.m_world = world
	local vars = self:load('ingame_dragon_panel.ui')
    self.m_bVisible = true
    
    self.m_menuPosY = vars['panelMenu']:getPositionY()

    self:initUI()
	self:initButton()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IngameDragonPanel:initUI()
    local vars = self.vars
    local world = self.m_world
    self.m_lPanelItemList = {}
    for i=1, 5 do
        local dragon = world.m_myDragons[i]
        if dragon then
            local dragon_idx = i
            self:insertPanelItem(dragon, dragon_idx)
        end
    end
    
    local start_pos = 122
    local interval = 132
    local count = #self.m_lPanelItemList
    local l_pos_list = getSortPosList(interval, count)

    for i,v in ipairs(self.m_lPanelItemList) do
        v.root:setPositionX(start_pos + l_pos_list[i])
    end
end

-------------------------------------
-- function insertPanelItem
-------------------------------------
function UI_IngameDragonPanel:insertPanelItem(dragon, dragon_idx)
    local vars = self.vars
    local world = self.m_world

    local ui = UI_IngameDragonPanelItem(world, dragon, dragon_idx)
    ui.root:setDockPoint(cc.p(0.5, 0))
    ui.root:setAnchorPoint(cc.p(0.5, 0))
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

-------------------------------------
-- function toggleVisibility
-------------------------------------
function UI_IngameDragonPanel:toggleVisibility()
    local vars = self.vars
    self.m_bVisible = (not self.m_bVisible)

    local duration = 0.3

    if self.m_bVisible then
        vars['panelMenu']:setVisible(true)
		local move_action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(0, self.m_menuPosY)), 2)
        vars['panelMenu']:stopAllActions()
        vars['panelMenu']:runAction(move_action)
    else
		local move_action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(0, -150)), 2)
		local seq_action = cc.Sequence:create(move_action, cc.Hide:create())
        vars['panelMenu']:stopAllActions()
        vars['panelMenu']:runAction(seq_action)
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_IngameDragonPanel:update(dt)
    local possible = self.m_world:isPossibleControl()

    for i,v in ipairs(self.m_lPanelItemList) do
        v:update(dt, possible)
    end
end

-------------------------------------
-- function setPanelInActive
-------------------------------------
function UI_IngameDragonPanel:setPanelInActive()
    for i,v in ipairs(self.m_lPanelItemList) do
        v:setPanelInActive()
    end
end