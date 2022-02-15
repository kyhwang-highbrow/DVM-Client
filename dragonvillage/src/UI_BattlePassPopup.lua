local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

UI_BattlePassPopup = class(PARENT, {
    m_tableView = 'UIC_TableView',
    m_containerList = '',
    m_tabUIList = '',
    -- m_lContainerForEachType = 'list[node]', -- (tab)타입별 컨테이너
    -- m_tabUIMap = 'map',

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
function UI_BattlePassPopup:init()
    local vars = self:load('shop_battle_pass.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_BattlePassPopup')

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.3)
    self:doActionReset()
    self:doAction(nil, false)

    self:initMember()
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


-------------------------------------
-- function initParentVariable
-- ITopUserInfo_EventListener
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_BattlePassPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_BattlePassPopup'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
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
function UI_BattlePassPopup:initMember()
    local vars = self.vars

    -- base class variables
    self.m_uiName = 'UI_BattlePassPopup'
    self.m_titleStr = Str('배틀패스')
    self.m_bUseExitBtn = true

    self.m_containerList = {}


    -- Inherited class variables

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
    local item_list = g_shopDataNew:getProductList('pass')
    
    local tabList = {}
    for product_id, v in pairs(item_list) do
        if (g_levelUpPackageData:checkPackage(product_id) == true) then
            if (g_levelUpPackageData:isButtonVisible(product_id) == true) then
                table.insert(tabList, v)
            end
        elseif (g_adventureBreakthroughPackageData:checkPackage(product_id) == true) then
            if (g_adventureBreakthroughPackageData:isButtonVisible(product_id) == true) then
                table.insert(tabList, v)
            end
        elseif g_dmgatePackageData:checkProductInTable(product_id) then
            if (not g_contentLockData:isContentLock('dmgate')) and g_dmgatePackageData:isPackageVisible(product_id) then
                table.insert(tabList, v)
            end

        else
            table.insert(tabList, v)
        end
    end

    local tableView = UIC_TableView(self.m_listNode)
    -- TODO (YOUNGJIN) : ui 파일에서 노드 생성후 사이즈 적용으로 바꾸기
    tableView.m_defaultCellSize = cc.size(264, 104 + 5)
    tableView:setCellUIClass(UI_BattlePassTabButton)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    local function sort_func()
        table.sort(tableView.m_itemList, function(a, b)
            if a['data']['m_uiPriority'] == b['data']['m_uiPriority']  then
                return a['data']['product_id'] < b['data']['product_id']
            else
                return a['data']['m_uiPriority'] > b['data']['m_uiPriority']
            end
        end)
    end

    tableView:setItemList3(tabList, sort_func)
    self.m_tableView = tableView
end


--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePassPopup:initTab()
    local vars = self.vars
    local init_tab

    for i , v in pairs(self.m_tableView.m_itemList) do
        local node = cc.Node:create()
        node:setDockPoint(cc.p(0.5, 0.5))
        node:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_eventNode:addChild(node)

        local pid = v['unique_id']
        local ui = v['ui']

        self.m_containerList[pid] = node

        self:addTab(pid, ui.m_listBtn, node, ui.m_selectSprite)
        if not init_tab then init_tab = pid end
    end

    self:setTab(init_tab)
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
function UI_BattlePassPopup:onChangeTab(tab_id, first)
    -- if first then
    --     local container = self.m_lContainerForEachType[tab]
    --     local ui = self:makeEventPopupTab(tab)
    --     if ui then
    --         container:addChild(ui.root)
    --     end
    -- else
    --     if (self.m_tabUIMap[tab]) then
    --         self.m_tabUIMap[tab]:onEnterTab()
    --     end
    -- end
    if first then
        local containerNode = self.m_containerList[tab_id]
        local ui = self:makeEventPopupTab(tab_id)
        if ui then containerNode:addChild(ui.root) end
    else   
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
function UI_BattlePassPopup:makeEventPopupTab(tab_id)

    local item = self.m_tableView:getItem(tab_id)
    local struct_product = item['data']
    local package_res = item['data']['package_res']
    local product_id = item['data']['product_id']
    local package_name = TablePackageBundle:getPackageNameWithPid(product_id)

    local ui = UI_EventPopupTab_Package(struct_product)
    return ui
end



