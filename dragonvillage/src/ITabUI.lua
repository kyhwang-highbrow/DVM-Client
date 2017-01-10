-------------------------------------
-- interface ITabUI
-- @brief
-------------------------------------
ITabUI = {
        m_currTab = 'number',
        m_tabDataMap = 'amp',
    }

-------------------------------------
-- function init
-------------------------------------
function ITabUI:init()
    self.m_currTab = nil
    self.m_tabDataMap = {}
end

-------------------------------------
-- function addTab
-------------------------------------
function ITabUI:addTab(tab, button, tab_node)
    local t_tab_data = {}
    t_tab_data['tab'] = tab
    t_tab_data['button'] = button
    t_tab_data['tab_node'] = tab_node

    self.m_tabDataMap[tab] = t_tab_data

    button:registerScriptTapHandler(function() self:setTab(tab) end)
end

-------------------------------------
-- function setTab
-------------------------------------
function ITabUI:setTab(tab)
    if (self.m_currTab == tab) then
        return
    end

    if self.m_currTab then
        self:deactivate(self.m_currTab)
    else
        for i,v in pairs(self.m_tabDataMap) do
            if (i ~= tab) then
                self:deactivate(i)
            end
        end
    end

    self.m_currTab = tab

    self:activate(tab)
end

-------------------------------------
-- function deactivate
-------------------------------------
function ITabUI:deactivate(tab)
    local t_tab_data = self.m_tabDataMap[tab]

    local button = t_tab_data['button']
    button:setEnabled(true)

    local tab_node = t_tab_data['tab_node']
    tab_node:setVisible(false)
end

-------------------------------------
-- function activate
-------------------------------------
function ITabUI:activate(tab)
    local t_tab_data = self.m_tabDataMap[tab]

    local button = t_tab_data['button']
    button:setEnabled(false)

    local tab_node = t_tab_data['tab_node']
    tab_node:setVisible(true)
end

-------------------------------------
-- function getCloneTable
-------------------------------------
function ITabUI:getCloneTable()
	return clone(ITabUI)
end

-------------------------------------
-- function getCloneClass
-------------------------------------
function ITabUI:getCloneClass()
	return class(clone(ITabUI))
end