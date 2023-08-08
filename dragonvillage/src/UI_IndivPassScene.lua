local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

UI_IndivPassScene = class(PARENT, {
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

--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_IndivPassScene:init()
    local vars = self:load('shop_battle_pass.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_IndivPassScene')

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
function UI_IndivPassScene:initUI()
    self:initTableView()
    self:initTab()
end


-------------------------------------
-- function initParentVariable
-- ITopUserInfo_EventListener
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_IndivPassScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_IndivPassScene'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_IndivPassScene:initButton()
end


--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_IndivPassScene:refresh()
end

--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_IndivPassScene:initMember()
    local vars = self.vars

    -- base class variables
    self.m_uiName = 'UI_IndivPassScene'
    self.m_titleStr = Str('개인 패스')
    self.m_bUseExitBtn = true

    self.m_containerList = {}

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
function UI_IndivPassScene:initTableView()
    local tabList = g_indivPassData:getEventRepresentProductList()

    local tableView = UIC_TableView(self.m_listNode)
    tableView.m_defaultCellSize = cc.size(264, 104 + 5)
    tableView:setCellUIClass(UI_BattlePassTabButton)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setItemList3(tabList)
    self.m_tableView = tableView
end

--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_IndivPassScene:initTab()
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

--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_IndivPassScene:click_exitBtn()
    self:close()
end

--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_IndivPassScene:onChangeTab(tab_id, first)
    if first then
        local containerNode = self.m_containerList[tab_id]
        local ui = self:makeEventPopupTab(tab_id)
        if ui then containerNode:addChild(ui.root) end
    else   
    end
end

--------------------------------------------------------------------------
-- @function  
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_IndivPassScene:makeEventPopupTab(tab_id)

    local item = self.m_tableView:getItem(tab_id)
    local struct_product = item['data']
    local package_res = item['data']['package_res']
    local product_id = item['data']['product_id']
    local package_name = TablePackageBundle:getPackageNameWithPid(product_id)

    local ui = UI_EventPopupTab_Package(struct_product)
    return ui
end

--------------------------------------------------------------------------
-- @function  
--------------------------------------------------------------------------
function UI_IndivPassScene.open()

end

