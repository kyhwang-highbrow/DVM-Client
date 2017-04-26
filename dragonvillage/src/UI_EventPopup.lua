local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_EventPopup
-------------------------------------
UI_EventPopup = class(PARENT,{
        m_tableView = 'UIC_TableView',
        m_lContainerForEachType = 'list[node]', -- (tab)타입별 컨테이너
        m_mTabUI = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopup:init()
    local vars = self:load('event.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:closePopup() end, 'UI_EventPopup')

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
    vars['closeBtn']:registerScriptTapHandler(function() self:closePopup() end)
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

        local res
        if (data.m_type == 'birthday_calendar') then
            res = 'res/ui/event/icon_birthday_01.png'

        elseif (data.m_type == 'attendance_basic_newbie') then
            res = 'res/ui/event/icon_attendence_02.png'

        elseif (data.m_type == 'attendance_event_open_event') then
            res = 'res/ui/event/icon_attendence_01.png'

        elseif (data.m_type == 'attendance_basic_comebackl') then
            res = 'res/ui/event/icon_attendence_03.png'

        elseif (data.m_type == 'attendance_basic_normal') then
            res = 'res/ui/event/icon_attendence_04.png'

        end

        if res then
            local icon = cc.Sprite:create(res)
            icon:setDockPoint(cc.p(0.5, 0.5))
            ui.vars['iconNode']:removeAllChildren()
            ui.vars['iconNode']:addChild(icon)
        end

        
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(264, 104 + 5)
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
    for i,v in pairs(self.m_tableView.m_itemList) do
        local type = v['data'].m_type
        local ui = v['ui'] or v['generated_ui']

        local continer_node = cc.Node:create()
        continer_node:setDockPoint(cc.p(0.5, 0.5))
        continer_node:setAnchorPoint(cc.p(0.5, 0.5))
        vars['eventNode']:addChild(continer_node)
        self.m_lContainerForEachType[type] = continer_node

        self:addTab(type, ui.vars['listBtn'], continer_node, ui.vars['selectSprite'])

        if (not initial_tab) then
            initial_tab = type
        end
    end

    if (not self:checkNotiList()) then
        if self:existTab('attendance_basic_newbie') then
            self:setTab('attendance_basic_newbie')

        elseif self:existTab('attendance_basic_comeback') then
            self:setTab('attendance_basic_comeback')

        else
            self:setTab(initial_tab)
        end
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_EventPopup:onChangeTab(tab, first)
    if first then
        local container = self.m_lContainerForEachType[tab]
        local ui = self:makeEventPopupTab(tab)
        if ui then
            container:addChild(ui.root)
        end
    else
        self.m_mTabUI[tab]:onEnterTab()
    end

    local item = self.m_tableView:getItem(tab)
    if item and item['data'] then
        item['data'].m_hasNoti = false
    end
end

-------------------------------------
-- function makeEventPopupTab
-------------------------------------
function UI_EventPopup:makeEventPopupTab(tab)
    if (not self.m_mTabUI) then
        self.m_mTabUI = {}
    end

    local ui = nil

    local item = self.m_tableView:getItem(tab)
    local struct_event_popup_tab = item['data']

    -- 생일 탭
    if (tab == 'birthday_calendar') then
        ui = UI_EventPopupTab_Birthday(self, struct_event_popup_tab)

    -- 출석 (일반)
    elseif (tab == 'attendance_basic') then
        ui = UI_EventPopupTab_Attendance(self, struct_event_popup_tab)

    else
        -- 출석체크 이벤트
        ui = UI_EventPopupTab_EventAttendance(self, struct_event_popup_tab)
    end

    self.m_mTabUI[tab] = ui

    return ui
end

-------------------------------------
-- function closePopup
-------------------------------------
function UI_EventPopup:closePopup()
    if (not self:checkNotiList()) then
        self:close()
    end
end

-------------------------------------
-- function checkNotiList
-------------------------------------
function UI_EventPopup:checkNotiList()
    for i,v in pairs(self.m_tableView.m_itemList) do
        local type = v['data'].m_type

        if v['data'].m_hasNoti then
            v['data'].m_hasNoti = false
            self:setTab(type)
            return true
        end
    end

    return false
end

--@CHECK
UI:checkCompileError(UI_EventPopup)
