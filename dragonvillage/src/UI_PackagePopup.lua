local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_PackagePopup
-------------------------------------
UI_PackagePopup = class(PARENT,{
        m_tableView = 'UIC_TableView',
        m_lContainerForEachType = 'list[node]', -- (tab)타입별 컨테이너
        m_mTabUI = 'map',
        m_initial_tab = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PackagePopup:init(initial_tab)
    self.m_initial_tab = initial_tab

    local vars = self:load('shop_package.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_PackagePopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_PackagePopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_PackagePopup'
    self.m_titleStr = Str('패키지')
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'amethyst'
    self.m_addSubCurrency = 'fp'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_PackagePopup:initUI()
    self:init_tableView()
    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PackagePopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PackagePopup:refresh()
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_PackagePopup:init_tableView()
    local node = self.vars['listNode']

    local l_item_list = TablePackageBundle:getTableViewMap()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(264, 104 + 5)
    table_view:setCellUIClass(UI_PackageTabButton)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    -- 테이블 뷰 아이템 바로 생성하고 정렬할 경우 애니메이션이 예쁘지 않음.
    -- 애니메이션 생략하고 바로 정렬하게 수정
    local function sort_func()
        table.sort(table_view.m_itemList, function(a, b)
            return a['data']['m_uiPriority'] > b['data']['m_uiPriority']
        end)
    end
    table_view:setItemList3(l_item_list, sort_func)

    self.m_tableView = table_view
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_PackagePopup:initTab()
    local vars = self.vars

    self.m_lContainerForEachType = {}

    local initial_tab = self.m_initial_tab
    for i,v in pairs(self.m_tableView.m_itemList) do
        local pid = v['data']['product_id']
        local ui = v['ui'] or v['generated_ui']

        local continer_node = cc.Node:create()
        continer_node:setDockPoint(cc.p(0.5, 0.5))
        continer_node:setAnchorPoint(cc.p(0.5, 0.5))
        vars['eventNode']:addChild(continer_node)
        self.m_lContainerForEachType[pid] = continer_node
        self:addTab(pid, ui.vars['listBtn'], continer_node, ui.vars['selectSprite'])

        if (not initial_tab) then
            initial_tab = pid
        end
    end

    self:setTab(initial_tab)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_PackagePopup:onChangeTab(tab, first)
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
end

-------------------------------------
-- function makeEventPopupTab
-------------------------------------
function UI_PackagePopup:makeEventPopupTab(tab)
    if (not self.m_mTabUI) then
        self.m_mTabUI = {}
    end

    local ui = nil
    local item = self.m_tableView:getItem(tab)
    self.m_mTabUI[tab] = item

    local package_name = TablePackageBundle:getPackageNameWithPid(tab)
    if (TablePackageBundle:checkBundleWithName(package_name)) then
        ui = UI_EventPopupTab_Package(package_name)
    end

    return ui
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_PackagePopup:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_PackagePopup)
