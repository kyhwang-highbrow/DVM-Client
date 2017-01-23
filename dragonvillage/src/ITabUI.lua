-------------------------------------
-- interface ITabUI
-- @brief
-------------------------------------
ITabUI = {
        m_bInitDefaultTab = 'boolean',
        m_currTab = 'any_type',
        m_mTabData = 'map',
    }

-------------------------------------
-- function init
-------------------------------------
function ITabUI:init()
    self.m_bInitDefaultTab = false
    self.m_currTab = nil
    self.m_mTabData = {}
end

-------------------------------------
-- function addTab
-- @breif 탭 추가
-- @param tab       탭의 이름
-- @param button    탭으로 사용될 버튼
-- @param ...       탭 전환 시 on/off될 UI들
-------------------------------------
function ITabUI:addTab(tab, button, ...)
    local t_tab_data = {}
    t_tab_data['tab'] = tab
    t_tab_data['button'] = button
    t_tab_data['tab_node_list'] = {...}

    self.m_mTabData[tab] = t_tab_data

    button:registerScriptTapHandler(function() self:setTab(tab) end)
end

-------------------------------------
-- function setTab
-------------------------------------
function ITabUI:setTab(tab, force)
    if (not force) and (self.m_currTab == tab) then
        return
    end
    
    -- 기본 탭이 설정되어있지 않은 경우 초기화
    if (self.m_bInitDefaultTab == false) then
        for i,v in pairs(self.m_mTabData) do
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
    local t_tab_data = self.m_mTabData[tab]

    local button = t_tab_data['button']
    button:setEnabled(true)

    for i,v in ipairs(t_tab_data['tab_node_list']) do
        v:setVisible(false)
    end
end

-------------------------------------
-- function activate
-------------------------------------
function ITabUI:activate(tab)
    if (not tab) then
        return
    end

    local t_tab_data = self.m_mTabData[tab]

    local button = t_tab_data['button']
    button:setEnabled(false)

    for i,v in ipairs(t_tab_data['tab_node_list']) do
        v:setVisible(true)
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