-------------------------------------
-- interface ITabUI
-- @brief
-------------------------------------
ITabUI = {
        m_bInitDefaultTab = 'boolean',
        m_prevTab = 'any_type',
        m_currTab = 'any_type',
        m_mTabData = 'map',
        m_cbChangeTab = 'function(tab, first)',
    }

-------------------------------------
-- function init
-------------------------------------
function ITabUI:init()
    self.m_bInitDefaultTab = false
    self.m_prevTab = nil
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
    t_tab_data['first'] = true
    t_tab_data['ui'] = nil

    self.m_mTabData[tab] = t_tab_data

    local function click()
        self:setTab(tab)
    end

    button:registerScriptTapHandler(click)

    return t_tab_data
end

-------------------------------------
-- function addTabWithLabel
-- @breif 탭 추가 : 버튼과 라벨 등록
-------------------------------------
function ITabUI:addTabWithLabel(tab, button, label, ...)
    local t_tab_data = self:addTab(tab, button, ...)
    t_tab_data['label'] = label
    return t_tab_data
end

-------------------------------------
-- function addTabAuto
-- @breif 탭 추가 : 버튼과 라벨을 자동으로 찾아옴
-------------------------------------
function ITabUI:addTabAuto(tab, vars, ...)
    self:addTab(tab, vars[tab .. 'TabBtn'], vars[tab .. 'TabLabel'], ...)
end

-------------------------------------
-- function addTabWidthTabUI
-- @breif 탭 추가 : 버튼과 TabUI 등록
-------------------------------------
function ITabUI:addTabWidthTabUI(tab, button, ui, ...)
    local t_tab_data = self:addTab(tab, button, ...)
    t_tab_data['ui'] = ui
    return t_tab_data
end

-------------------------------------
-- function addTabWidthTabUIAndLabel
-- @breif 탭 추가 : 버튼과 TabUI 및 라벨 등록
-------------------------------------
function ITabUI:addTabWidthTabUIAndLabel(tab, button, label, ui, ...)
    local t_tab_data = self:addTab(tab, button, ...)
    t_tab_data['ui'] = ui
    t_tab_data['label'] = label
    return t_tab_data
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

    self.m_prevTab = self.m_currTab
    self.m_currTab = tab

    local first = self.m_mTabData[self.m_currTab]['first']
    self:activate(tab, first)
    self.m_mTabData[self.m_currTab]['first'] = false

    self:onChangeTab(self.m_currTab, first)
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

    if (t_tab_data['label']) then
        t_tab_data['label']:setTextColor(cc.c4b(255, 255, 0, 255))
    end


    for i,v in ipairs(t_tab_data['tab_node_list']) do
        v:setVisible(false)
    end

    if t_tab_data['ui'] then
        t_tab_data['ui']:onExitTab()
        t_tab_data['ui']:setVisible(false)
    end
end

-------------------------------------
-- function activate
-------------------------------------
function ITabUI:activate(tab, first)
    if (not tab) then
        return
    end

    local t_tab_data = self.m_mTabData[tab]

    local button = t_tab_data['button']
    button:setEnabled(false)

    if (t_tab_data['label']) then
        t_tab_data['label']:setTextColor(cc.c4b(0, 255, 255, 255))
    end

    for i,v in ipairs(t_tab_data['tab_node_list']) do
        v:setVisible(true)
    end

    if t_tab_data['ui'] then
        t_tab_data['ui']:onEnterTab(first)
        t_tab_data['ui']:setVisible(true)
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function ITabUI:onChangeTab(tab, first)
    if self.m_cbChangeTab then
        self.m_cbChangeTab(tab, first)
    end
end

-------------------------------------
-- function setChangeTabCB
-- @brief cb function(tab, first)
-------------------------------------
function ITabUI:setChangeTabCB(cb)
    self.m_cbChangeTab = cb
end

-------------------------------------
-- function existTab
-- @brief
-------------------------------------
function ITabUI:existTab(tab)
    if self.m_mTabData[tab] then
        return true
    else
        return false
    end
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

















-------------------------------------
-- interface UI_IndivisualTab
-- @brief
-------------------------------------
UI_IndivisualTab = class(UI, {
        m_ownerUI = '',
        m_tabName = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_IndivisualTab:init(owner_ui, tab_name)
    self.m_ownerUI = owner_ui
    self.m_tabName = tab_name

    -- 아래의 형태로 사용하세요.
    --local vars = self:load('event_exchange.ui')
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_IndivisualTab:onEnterTab(first)
    cclog('## UI_IndivisualTab:onEnterTab(first)')
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_IndivisualTab:onExitTab()
    cclog('## UI_IndivisualTab:onExitTab()')
end

-------------------------------------
-- function setVisible
-------------------------------------
function UI_IndivisualTab:setVisible(visible)
    if (not self.root) then
        return
    end

    self.root:setVisible(visible)
end