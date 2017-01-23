-------------------------------------
-- interface ITabUI
-- @brief
-------------------------------------
ITabUI = {
        m_bInitDefaultTab = 'boolean',
        m_currTab = 'any_type',
        m_tabDataMap = 'amp',
    }

-------------------------------------
-- function init
-------------------------------------
function ITabUI:init()
    self.m_bInitDefaultTab = false
    self.m_currTab = nil
    self.m_tabDataMap = {}
end

-------------------------------------
-- function addTab
-------------------------------------
function ITabUI:addTab(tab, button, tab_node, tab_node2)
    local t_tab_data = {}
    t_tab_data['tab'] = tab
    t_tab_data['button'] = button
    t_tab_data['tab_node'] = tab_node
    t_tab_data['tab_node2'] = tab_node2

    self.m_tabDataMap[tab] = t_tab_data

    button:registerScriptTapHandler(function() self:setTab(tab) end)
end

-------------------------------------
-- function setTab
-------------------------------------
function ITabUI:setTab(tab, force)
    if (not force) and (self.m_currTab == tab) then
        return
    end

    if (self.m_bInitDefaultTab == false) then
        for i,v in pairs(self.m_tabDataMap) do
            if (i ~= tab) then
                self:deactivate(i)
            end
        end
        self.m_bInitDefaultTab = true
    else
        if self.m_currTab then
            self:deactivate(self.m_currTab)
        end
    end

    self.m_currTab = tab

    self:activate(tab)

    self:onChangeTab(self.m_currTab)
end

-------------------------------------
-- function refreshCurrTab
-------------------------------------
function ITabUI:refreshCurrTab()
    local force = true
    self:setTab(self.m_currTab, force)
end

-------------------------------------
-- function deactivate
-------------------------------------
function ITabUI:deactivate(tab)
    local t_tab_data = self.m_tabDataMap[tab]

    local button = t_tab_data['button']
    button:setEnabled(true)

    if t_tab_data['tab_node'] then
        t_tab_data['tab_node']:setVisible(false)
    end

    if t_tab_data['tab_node2'] then
        t_tab_data['tab_node2']:setVisible(false)
    end
end

-------------------------------------
-- function activate
-------------------------------------
function ITabUI:activate(tab)
    if (not tab) then
        return
    end

    local t_tab_data = self.m_tabDataMap[tab]

    local button = t_tab_data['button']
    button:setEnabled(false)

    if t_tab_data['tab_node'] then
        t_tab_data['tab_node']:setVisible(true)
    end

    if t_tab_data['tab_node2'] then
        t_tab_data['tab_node2']:setVisible(true)
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function ITabUI:onChangeTab(tab)
    
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