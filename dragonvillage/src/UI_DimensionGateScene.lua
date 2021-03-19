local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

UI_DimensionGateScene = class(PARENT, {
    m_topTableView = '',
    m_bottomTableView = '',
    m_diffLevelTableView = '',

    m_clickedNode = '',

    m_selectedDimensionGateInfo = '',
    
    -- ui nodes
    m_topNode = '',
    m_bottomNode = '',

    m_stageNode = '',
    m_stageTopMenu = '',
    m_stageItemNode = '',

    m_topSprite = '',
    m_bottomSprite = '',

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

    local lhsTemp = g_dimensionGateData:GetTempLowChapterList()
    local rhsTemp =  g_dimensionGateData:GetTempHighChapterList()

    self.m_bottomTableView = self:initTableView(self.m_bottomNode, lhsTemp)
    self.m_topTableView = self:initTableView(self.m_topNode, rhsTemp)
    
    self.m_bottomTableView:setVisible(false)
    self.m_topTableView:setVisible(false)
    
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

    self.m_stageNode = vars['stageNode']
    self.m_stageTopMenu = vars['topMenu']
    self.m_stageItemNode = vars['stageItemNode']

    -- init ui buttons
    self.m_blessBtn = vars['blessBtn']
    self.m_infoBtn = vars['infoBtn']
    self.m_topBtn = vars['topBtn']
    self.m_bottomBtn = vars['bottomBtn']
    self.m_shopBtn = vars['shopBtn']

    self.m_topSprite = vars['topSprite']
    self.m_bottomSprite = vars['bottomSprite']


    self.m_clickedNode = self.m_topBtn
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

    if self.m_selectedDimensionGateInfo then
        self:closeStageNode()
    else
        self:close()
    end
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
    if(self.m_clickedNode ~= self.m_topBtn) then
        cclog("clicked_topBtn")
        self.m_topSprite:setVisible(true)
        self.m_bottomSprite:setVisible(false)

        self.m_clickedNode:setEnabled(true)
        self.m_clickedNode = self.m_topBtn
        self.m_clickedNode:setEnabled(false)
        
        self.m_topTableView:setVisible(true)
        self.m_bottomTableView:setVisible(false)

        self.m_topTableView:refreshAllItemUI()
    end
end

function UI_DimensionGateScene:click_bottomBtn()
    if(self.m_clickedNode ~= self.m_bottomBtn) then
        cclog("clicked_bottomBtn")
        self.m_bottomSprite:setVisible(true)
        self.m_topSprite:setVisible(false)

        self.m_clickedNode:setEnabled(true)
        self.m_clickedNode = self.m_bottomBtn
        self.m_clickedNode:setEnabled(false)

        self.m_bottomTableView:setVisible(true)
        self.m_topTableView:setVisible(false)

        self.m_bottomTableView:refreshAllItemUI()
    end
end


-------------------------------------
-- function initParentVariable
-- @brief 
-------------------------------------
function UI_DimensionGateScene:initTableView(node, list)

    create_callback = function(ui, data)
        ui.m_stageBtn:registerScriptTapHandler(function() self:click_stageBtn(ui, data) end)
    end

    local table_view = UIC_TableView(node)
    --table_view.m_defaultCellSize = cc.size(195, 523)
    table_view:setAlignCenter(true)
    --table_view:setMakeLookingCellFirst(true)
    --table_view:setScrollLock(true)
    table_view:setCellSizeToNodeSize(true)
    --table_view:setGapBtwCells(0)
    table_view:setCellUIClass(UI_DimensionGateItem, create_callback)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    
    table_view:setItemList(list, true)

    table_view:setScrollLock(true)
    

    return table_view
end

-- ['level']=1;
-- ['dm_id']=3010000;
-- ['reset_unlock']=1;
-- ['condition_stage_id']='';
-- ['start_date']=20213115;
-- ['reset_reward']=0;
-- ['end_date']=29211231;
-- ['type']=1;
-- ['item']='700901;10';
-- ['stage_id']=3011001;
-- ['grade']=0;
function UI_DimensionGateScene:click_stageBtn(ui, data)
    local vars = self.vars

    
    if self.m_selectedDimensionGateInfo then
        self:closeStageNode()
        return
    end

    local key = data['stage_id']

    self.m_selectedDimensionGateInfo = {ui = ui, key = key, data = data}

    self.m_stageNode:stopAllActions()
    cca.reserveFunc(self.m_stageNode, 0.25, 
    function() self:PopupStageNode(data) end)



    local node = ui.root

    --local target_pos = convertToAnotherNodeSpace(node, self.vars[''])
end

function UI_DimensionGateScene:click_difficultyLevelBtn(ui, data)
    local vars = self.vars

    local target_stage_id = tonumber(data['stage_id'])
    local target_ui = self.m_selectedDimensionGateInfo.ui

    if target_ui:getStageID() ~= target_stage_id then
        target_ui:setStageID(target_stage_id)
        target_ui:refresh()
    end

    self:closeStageNode()
end

function UI_DimensionGateScene:PopupStageNode(data)
    self.m_stageNode:setVisible(true)
    -- block to touch 
    --self.m_topBtn:setTouchEnabled(false)
    --self.m_bottomBtn:setTouchEnabled(false)

    if #data == 0 or #data == nil then 
        self.m_stageTopMenu:setVisible(false)
        return
    else
        self.m_stageTopMenu:setVisible(true)
    end

    local function create_callback(ui, data)
        ui.m_selectedBtn:registerScriptTapHandler(function() self:click_difficultyLevelBtn(ui, data) end)
        return true
    end

    local table_view = UIC_TableView(self.m_stageItemNode)
    table_view:setCellSizeToNodeSize(true)
    table_view:setCellUIClass(UI_DimensionGateSceneStageItem, create_callback)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(data, create_callback)
    self.m_diffLevelTableView = table_view



end

function UI_DimensionGateScene:closeStageNode()
    self.m_stageNode:setVisible(false)
    --self.m_topBtn:setTouchEnabled(true)
    --self.m_bottomBtn:setTouchEnabled(true)
    self.m_selectedDimensionGateInfo = nil
    if(self.m_diffLevelTableView ~= nil) then
        self.m_diffLevelTableView:clearItemList()
    end
    self.m_diffLevelTableView = nil

end


function UI_DimensionGateScene:getFakeData()
   return g_nestDungeonData:getNestDungeonListForUIByType(NEST_DUNGEON_EVO_STONE)
end


