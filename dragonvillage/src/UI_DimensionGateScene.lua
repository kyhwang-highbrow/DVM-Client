local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

UI_DimensionGateScene = class(PARENT, {
    
    m_topTableView = '',
    m_bottomTableView = '',

    m_clickedNode = '',
    
    -- ui nodes
    m_topNode = '',
    m_bottomNode = '',

    -- ui buttons
    m_blessBtn = '',
    m_infoBtn = '',
    m_topBtn = '',
    m_bottomBtn = '',
    m_shopBtn = '',
})

-------------------------------------
-- function init
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateScene:init()
    local vars = self:load('dmgate_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DimensionGateScene')
    
    --self:doActionReset()
    --self:doAction(nil, false)
    self:initMemberVariable()
    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateScene:initUI()
    local table = self:getFakeData()

    self.m_topTableView = self:initTableView(self.m_topNode, table)
    self.m_bottomTableView = self:initTableView(self.m_bottomNode, table)

    
    self.m_topTableView:setVisible(false)
    self.m_bottomTableView:setVisible(false)
    self:click_bottomBtn()
end

-------------------------------------
-- function initButton
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateScene:initButton() 
    --local vars = self.vars
    self.m_shopBtn:registerScriptTapHandler(function() self:click_shopBtn() end)
    self.m_infoBtn:registerScriptTapHandler(function() self:click_infoBtn() end)
    self.m_blessBtn:registerScriptTapHandler(function() self:click_blessBtn() end)

    self.m_topBtn:registerScriptTapHandler(function() self:click_topBtn() end)
    self.m_bottomBtn:registerScriptTapHandler(function() self:click_bottomBtn() end)
end

-------------------------------------
-- function refresh
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateScene:refresh() 

end

-------------------------------------
-- function initParentVariable
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateScene:initMemberVariable()
    local vars = self.vars

    -- init ui nodes
    self.m_topNode = vars['topNode']
    self.m_bottomNode = vars['bottomNode']

    -- init ui buttons
    self.m_blessBtn = vars['blessBtn']
    self.m_infoBtn = vars['infoBtn']
    self.m_topBtn = vars['topBtn']
    self.m_bottomBtn = vars['bottomBtn']
    self.m_shopBtn = vars['shopBtn']


    self.m_clickedNode = nil
end


-------------------------------------
-- function initParentVariable
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateScene:initParentVariable()
    self.m_uiName = 'UI_DimensionGateScene'
    self.m_titleStr = Str('차원문')
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function onClose
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateScene:onClose() 
    self:releaseI_TopUserInfo_EventListener()
    g_currScene:removeBackKeyListener(self)
end
-------------------------------------
-- function onFocus
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateScene:onFocus() 

end


-------------------------------------
-- function click_exitBtn
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateScene:click_exitBtn()
   self:close()
end


-------------------------------------
-- function click_shopBtn
-- @brief 
-------------------------------------
function UI_DimensionGateScene:click_shopBtn()
    UI_DimensionGateShop()
end


-------------------------------------
-- function click_infoBtn
-- @brief 
-------------------------------------
function UI_DimensionGateScene:click_infoBtn()

end

-------------------------------------
-- function click_blessBtn
-- @brief 
-------------------------------------
function UI_DimensionGateScene:click_blessBtn()

end

function UI_DimensionGateScene:click_topBtn()
    if(self.m_clickedNode ~= self.m_topBtn) and (not self.m_topTableView:isVisible()) then
        cclog("clicked_topBtn")
        self.m_clickedNode = self.m_topBtn
        self.m_topTableView:setVisible(true)
        self.m_bottomTableView:setVisible(false)

        self.m_topTableView:refreshAllItemUI()
    end
end

function UI_DimensionGateScene:click_bottomBtn()
    if(self.m_clickedNode ~= self.m_bottomBtn) and (not self.m_bottomTableView:isVisible()) then
        cclog("clicked_bottomBtn")
        self.m_clickedNode = self.m_bottomBtn
        self.m_bottomTableView:setVisible(true)
        self.m_topTableView:setVisible(false)

        self.m_bottomTableView:refreshAllItemUI()
    end
end

function UI_DimensionGateScene:click_stageBtn()
    local vars = self.vars
    cclog('clicked')
end



-------------------------------------
-- function initParentVariable
-- @brief 
-------------------------------------
function UI_DimensionGateScene:initTableView(node, list)

    create_callback = function(ui, data)
        ui.vars['stageBtn']:registerScriptTapHandler(function() self:click_stageBtn(ui, data) end)
    end

    local table_view = UIC_TableView(node)
    --table_view.m_defaultCellSize = cc.size(195, 523)
    table_view:setAlignCenter(true)
    --table_view:setMakeLookingCellFirst(true)
    
    table_view:setCellSizeToNodeSize(true)
    --table_view:setGapBtwCells(0)
    table_view:setCellUIClass(UI_DimensionGateItem, create_callback)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    ccdump(list)
    table_view:setItemList(list, true)

    return table_view
end


function UI_DimensionGateScene:getFakeData()
   return g_nestDungeonData:getNestDungeonListForUIByType(NEST_DUNGEON_EVO_STONE)
end
