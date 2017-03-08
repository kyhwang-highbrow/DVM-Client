local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_EventPopup
-------------------------------------
UI_EventPopup = class(PARENT,{
        m_tableView = 'UIC_TableView',
        m_lContainerForEachType = 'list[node]', -- (tab)타입별 컨테이너
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopup:init()
    local vars = self:load('event_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopup:initUI()
    self:init_tableView()
    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopup:refresh()
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_EventPopup:init_tableView()
    local node = self.vars['listNode']
    --node:removeAllChildren()

    local l_item_list = g_eventData:getEventPopupTabList()

    -- 생성 콜백
    local function create_func(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(250, 110 + 5)
    table_view:setCellUIClass(UI_EventPopupTabButton, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    local make_item = true
    table_view:setItemList(l_item_list, make_item)
    --table_view_td:makeDefaultEmptyDescLabel(Str(''))

    
    self.m_tableView = table_view
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_EventPopup:initTab()
    local vars = self.vars

    self.m_lContainerForEachType = {}

    local initial_tab = nil
    for i,v in ipairs(self.m_tableView.m_itemList) do
        local type = v['data'].m_type
        local ui = v['ui'] or v['generated_ui']

        local continer_node = cc.Node:create()
        continer_node:setDockPoint(cc.p(0.5, 0.5))
        continer_node:setAnchorPoint(cc.p(0.5, 0.5))
        vars['eventNode']:addChild(continer_node)
        self.m_lContainerForEachType[type] = continer_node

        self:addTab(type, ui.vars['listBtn'], continer_node)

        if (not initial_tab) then
            initial_tab = type
        end
    end

    self:setTab(initial_tab)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_EventPopup:onChangeTab(tab, first)
    if first then
        local container = self.m_lContainerForEachType[tab]
        if (tab == 'birthday_calendar') then
            local ui = UI_EventPopupTab_Birthday(self)
            container:addChild(ui.root)
        end
    end
end

--@CHECK
UI:checkCompileError(UI_EventPopup)
