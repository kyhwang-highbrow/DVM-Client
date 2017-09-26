local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

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
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_EventPopup')

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
-- function initParentVariable
-- @brief
-------------------------------------
function UI_EventPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_EventPopup'
    self.m_titleStr = Str('이벤트')
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'amethyst'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopup:initUI()
    self:init_tableView()
    self:initTab()

    g_broadcastManager:setEnableNotice(false) -- 운영 공지는 비활성화 - 웹뷰때문에 뎁스 꼬임
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopup:initButton()
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
        local res = data:getTabIcon()
        if res then
            local icon = cc.Sprite:create(res)
            if icon then
                icon:setDockPoint(cc.p(0.5, 0.5))
                ui.vars['iconNode']:removeAllChildren()
                ui.vars['iconNode']:addChild(icon)
            end
        end
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(264, 104 + 5)
    table_view:setCellUIClass(UI_EventPopupTabButton, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    -- 테이블 뷰 아이템 바로 생성하고 정렬할 경우 애니메이션이 예쁘지 않음.
    -- 애니메이션 생략하고 바로 정렬하게 수정
    local function sort_func()
        table.sort(table_view.m_itemList, function(a, b)
            return a['data'].m_sortIdx < b['data'].m_sortIdx
        end)
    end
    table_view:setItemList3(l_item_list, sort_func)

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
        self:setTab(initial_tab)
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_EventPopup:onChangeTab(tab, first)
    --전면 웹뷰가 아닌 부분 웹뷰일때는 방송, 채팅 꺼줌
    do
        local enable = (tab ~= 'notice') and (tab ~= 'highbrow_shop')
        -- 공지, 하이브로 상점
        g_topUserInfo:setEnabledBraodCast(enable)
    end

    if first then
        local container = self.m_lContainerForEachType[tab]
        local ui = self:makeEventPopupTab(tab)
        if ui then
            container:addChild(ui.root)
        end
    else
        if (self.m_mTabUI[tab]) then
            self.m_mTabUI[tab]:onEnterTab()
        end
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

    -- 출석 (일반)
    if (tab == 'attendance_basic') then
        ui = UI_EventPopupTab_Attendance(self, struct_event_popup_tab)

    -- 출석체크 이벤트
    elseif (tab == 'attendance_event') then
        ui = UI_EventPopupTab_EventAttendance(self, struct_event_popup_tab)

    -- 접속시간 이벤트
    elseif (tab == 'access_time') then
        ui = UI_EventPopupTab_AccessTime(self)

    -- 하이브로 상점
    elseif (tab == 'highbrow_shop') then
        ui = UI_EventPopupTab_HBShop()
        self:addNodeToTabNodeList(tab, ui.m_webView)

    -- * shop, banner는 중복가능 (string.find로 처리해야함)
    -- 상점
    elseif (string.find(tab, 'shop')) then
        local product_id = struct_event_popup_tab.m_eventData['event_id']
        local l_item_list = g_shopDataNew:getProductList('package')
        local product = l_item_list[product_id]
        if (product) then
            ui = UI_EventPopupTab_Shop(product)
        end

    -- 배너
    elseif (string.find(tab, 'banner')) then
        ui = UI_EventPopupTab_Banner(self, struct_event_popup_tab)

    -- 업데이트 공지 
    elseif (tab == 'notice') then
        ui = UI_EventPopupTab_Notice(self, struct_event_popup_tab)
        self:addNodeToTabNodeList(tab, ui.m_webView)

    -- 성장 패키지 묶음 UI (slime_package, growth_package)
    elseif (string.find(tab, '_package')) then
        local product = {product_id = tab}
        ui = UI_EventPopupTab_Shop(product)

    -- 추석 이벤트
    elseif (string.find(tab, 'event_exchange')) then
        ui = UI_EventPopupTab_Scroll(self, struct_event_popup_tab)

    end

    self.m_mTabUI[tab] = ui

    return ui
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_EventPopup:click_exitBtn()
    if (not self:checkNotiList()) then
        self:close()

        -- 노티 정보를 갱신하기 위해서 호출
        g_highlightData:setLastUpdateTime()

        -- 방송 활성화
        g_topUserInfo:setEnabledBraodCast(true)

        -- 운영공지 활성화
        g_broadcastManager:setEnableNotice(true) 
    end
end

-------------------------------------
-- function checkNotiList
-------------------------------------
function UI_EventPopup:checkNotiList()
    for i,v in pairs(self.m_tableView.m_itemList) do
        local type = v['data'].m_type

        if v['data'].m_hasNoti then
            self:setTab(type)
            self.m_tableView:relocateContainerFromIndex(i, true)
            return true
        end

        local ui = v['ui'] or v['generated_ui']
        if ui then
            local is_noti = v['data'].m_hasNoti
            ui.vars['notiSprite']:setVisible(is_noti)
        end
    end

    return false
end

--@CHECK
UI:checkCompileError(UI_EventPopup)
