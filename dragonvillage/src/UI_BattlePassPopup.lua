local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

UI_BattlePassPopup = class(PARENT, {
    m_tableView = 'UIC_TableView',
    m_initTab = '',
    m_lContainerForEachType = 'list[node]', -- (tab)타입별 컨테이너
    m_tabUIMap = 'map',

    -- Nodes in ui file
    m_contentsNode = '',
    m_listNode = '',
    m_eventNode = '',
})


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// pure virtual functions
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassPopup:init(init_tab)
    local vars = self:load('shop_battle_pass.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_BattlePassPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initMember(init_tab)
    self:initUI()
    self:initButton()
    self:refresh()
end


--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassPopup:initUI()
    self:initTableView()
    self:initTab()
end


--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassPopup:initButton()
end


--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassPopup:refresh()
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Init Helper Functions (local)
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassPopup:initMember(init_tab)
    local vars = self.vars

    -- base class variables
    self.m_uiName = 'UI_BattlePassPopup'
    self.m_titleStr = Str('배틀패스')
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'amethyst'
    self.m_addSubCurrency = 'fp'


    -- Inherited class variables

    self.m_initTab = init_tab

    -- Nodes in ui files
    self.m_contentsNode = vars['contentsNode']
    self.m_listNode = vars['listNode']
    self.m_eventNode = vars['eventNode']
end

--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassPopup:initTableView()
    
    -- TODO (YOUNGJIN) : 
    local l_item_list = g_battlePassData.m_battlePassTable:getInfoMap()
    --TablePackageBundle():getTableViewMap()

    local tableView = UIC_TableView(self.m_listNode)
    -- TODO (YOUNGJIN) : ui 파일에서 노드 생성후 사이즈 적용으로 바꾸기
    tableView.m_defaultCellSize = cc.size(264, 104 + 5)
    tableView:setCellUIClass(UI_BattlePassTabButton)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)


    -- 테이블 뷰 아이템 바로 생성하고 정렬할 경우 애니메이션이 예쁘지 않음.
    -- 애니메이션 생략하고 바로 정렬하게 수정
    -- TODO (YOUNGJIN) : 애니메이션 발생 원인 찾고 해결하기.
    -- local function sort_func()
    --     table.sort(tableView.m_itemList, function(a, b)
    --         return a['product']['product_id'] > b['product']['product_id']
    --     end)
    -- end

    tableView:setItemList3(l_item_list)--, sort_func)
    self.m_tableView = tableView
end


--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassPopup:initTab()
    local vars = self.vars
    
    self.m_lContainerForEachType = {}

    local initial_tab = self.m_initTab

    for i,v in pairs(self.m_tableView.m_itemList) do
        local pid = v['data']['product_id']
        local ui = v['ui'] or v['generated_ui']

        local container_node = cc.Node:create()
        container_node:setDockPoint(cc.p(0.5, 0.5))
        container_node:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_eventNode:addChild(container_node)
        self.m_lContainerForEachType[pid] = container_node
        self:addTab(pid, ui.m_listBtn, container_node, ui.m_selectSprite)

        if (not initial_tab) then
            initial_tab = pid
        end
    end

    -- TODO (YOUNGJIN) : PARENT:setTab 으로 바꾸기
    self:setTab(initial_tab)
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Button Click Actions
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassPopup:click_exitBtn()
    self:close()
end

--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassPopup:onChangeTab(tab, first)
    if first then
        local container = self.m_lContainerForEachType[tab]
        local ui = self:makeEventPopupTab(tab)
        if ui then
            container:addChild(ui.root)
        end
    else
        if (self.m_tabUIMap[tab]) then
            self.m_tabUIMap[tab]:onEnterTab()
        end
    end
end



--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Local
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassPopup:makeEventPopupTab(tab)
    if (not self.m_tabUIMap) then
        self.m_tabUIMap = {}
    end

    local ui = nil
    local item = self.m_tableView:getItem(tab)
    self.m_tabUIMap[tab] = ui

    -- TODO (YOUNGJIN) : Need to change
    local package_name = TablePackageBundle:getPackageNameWithPid(tab)
    if (TablePackageBundle:checkBundleWithName(package_name)) then
        ui = UI_EventPopupTab_Package(package_name)
    end

    return ui
end