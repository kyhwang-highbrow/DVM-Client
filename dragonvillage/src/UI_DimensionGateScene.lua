local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

----------------------------------------------------------------------
-- class UI_DimensionGateScene
----------------------------------------------------------------------
UI_DimensionGateScene = class(PARENT, {
    m_bottomTableView = '',             -- 하위층 TableView
    m_topTableView = '',                -- 상위층 TableView 

    m_monsterInfoTableView = '',        -- 난이도 선택 팝업의 몬스터 정보
    m_diffLevelTableView = '',          -- 난이도 선택 팝업의 difficulty TableView from dmgate_scene_stage_item.ui

    m_selectedChapter = '',             -- 상위층, 하위층 선택 버튼 구분을 위한 포인터
    m_selectedDimensionGateInfo = '',   -- 선택된 챕터의 테이블 정보
    
    -- nodes from ui file
    m_dmgateNode = '',
    m_bottomSprite = '',                -- 하위층 배경
    m_topSprite = '',                   -- 상위층 배경
    
    m_stagePosNode = '',                -- 스테이지 선택시 이동할 위치

    -- 난이도 선택
    m_stageNode = '',                   -- 스테이지 선택 전체 메뉴
    m_stageMonsterListNode = '',        -- 출현 몬스터
    m_stageTopMenu = '',                -- 난이도 선택 메뉴
    m_stageItemNode = '',               -- 난이도 선택 노드
    m_stageInfoLabel = '',
    m_stageLabel = '',

    -- ui buttons
    m_bottomBtn = '',                   -- 하위 챕터 버튼
    m_topBtn = '',                      -- 상위 챕터 버튼
    m_blessBtn = '',                    -- 축복 정보 버튼
    m_infoBtn = '',                     -- 모드 정보 버튼
    
    m_shopBtn = '',                     -- 상점 버튼

    m_startBtn = '',                    -- 난이도 팝업 게임 시작 버튼
})

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  Virtual functions of UI class
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

-------------------------------------
-- function init
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateScene:init(stage_id)
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
    local lhsTemp = g_dimensionGateData:GetTempLowChapterList()
    local rhsTemp =  g_dimensionGateData:GetTempHighChapterList()

    self.m_bottomTableView = self:initTableView(self.m_dmgateNode, lhsTemp)
    self.m_topTableView = self:initTableView(self.m_dmgateNode, rhsTemp)
    
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

    self.m_startBtn:registerScriptTapHandler(function() self:click_startBtn() end)
end

-------------------------------------
-- function refresh
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateScene:refresh() 
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  Virtual functions of ITopUserInfo_EventListener class
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

-------------------------------------
-- function initParentVariable
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateScene:initMemberVariable()
    local vars = self.vars

    -- init ui nodes
    self.m_dmgateNode = vars['dmgateNode']

    self.m_stageNode = vars['stageMenu']

    self.m_stageTopMenu = vars['topMenu']

    self.m_stageMonsterListNode = vars['monsterListNode']
    self.m_stageItemNode = vars['stageItemNode']

    self.m_stageInfoLabel = vars['stageInfoLabel']
    self.m_stageLabel = vars['stageInfoLabel']
    
    self.m_stagePosNode = vars['stagePosNode']
    

    -- init ui buttons
    self.m_blessBtn = vars['blessBtn']
    self.m_infoBtn = vars['infoBtn']
    self.m_topBtn = vars['topBtn']
    self.m_bottomBtn = vars['bottomBtn']
    self.m_shopBtn = vars['shopBtn']

    self.m_topSprite = vars['topSprite']
    self.m_bottomSprite = vars['bottomSprite']

    self.m_startBtn = vars['startBtn']
    self.m_selectedChapter = self.m_topBtn
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
        --self:closeStageNode()
        self:closeStageNode()
    elseif (g_currScene.m_sceneName == 'SceneDimensionGate') then
        local is_use_loading = false
        local scene = SceneLobby(is_use_loading)
        scene:runScene()
    else
        self:close()
    end
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

-------------------------------------
-- function initParentVariable
-- @brief 
-------------------------------------
function UI_DimensionGateScene:initTableView(node, list)

    create_callback = function(ui, data)
        --ui.m_stageBtn:registerScriptTapHandler(function() self:click_stageBtn(ui, data) end)
        ui.m_stageBtn:registerScriptTapHandler(function() self:click_stageBtn(ui, data) end)
        ui.root:setSwallowTouch(false)
    end

    local table_view = UIC_TableView(node)
    table_view:setAlignCenter(true)
    --table_view:setMakeLookingCellFirst(true)
    table_view:setCellSizeToNodeSize(true)
    table_view:setGapBtwCells(15)
    table_view:setCellUIClass(UI_DimensionGateItem, create_callback)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    
    table_view:setItemList(list, true)
    
    table_view:setScrollLock(true)
    

    return table_view
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  Click events
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

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
    UI_DimensionGateInfoPopup()
end

-------------------------------------
-- function click_blessBtn
-- @brief 
-------------------------------------
function UI_DimensionGateScene:click_blessBtn()
    UI_DimensionGateBlessPopup()
end

-------------------------------------
-- function click_topBtn
-- @brief 
-------------------------------------
function UI_DimensionGateScene:click_topBtn()
    if(self.m_selectedChapter ~= self.m_topBtn) and self.m_selectedDimensionGateInfo == nil then
        self.m_topSprite:setVisible(true)
        self.m_bottomSprite:setVisible(false)

        self.m_selectedChapter:setEnabled(true)
        self.m_selectedChapter = self.m_topBtn
        self.m_selectedChapter:setEnabled(false)
        
        
        self.m_topTableView:setVisible(true)
        self.m_bottomTableView:setVisible(false)

        self.m_topTableView:refreshAllItemUI()
    end
end

-------------------------------------
-- function click_bottomBtn
-- @brief 
-------------------------------------
function UI_DimensionGateScene:click_bottomBtn()
    if(self.m_selectedChapter ~= self.m_bottomBtn)  and self.m_selectedDimensionGateInfo == nil then
        self.m_bottomSprite:setVisible(true)
        self.m_topSprite:setVisible(false)

        self.m_selectedChapter:setEnabled(true)
        self.m_selectedChapter = self.m_bottomBtn
        self.m_selectedChapter:setEnabled(false)

        
        self.m_bottomTableView:setVisible(true)
        self.m_topTableView:setVisible(false)

        self.m_bottomTableView:refreshAllItemUI()
    end
end



-------------------------------------
-- function click_difficultyLevelBtn
-- @brief 
-------------------------------------
function UI_DimensionGateScene:click_difficultyLevelBtn(ui, data)
    local vars = self.vars

    local target_stage_id = tonumber(data['stage_id'])
    local target_ui = self.m_selectedDimensionGateInfo.ui

    -- if target_ui:getStageID() ~= target_stage_id then
    --     target_ui:setStageID(target_stage_id)
    --     target_ui:refresh()
    -- end

    -- self:closeStageNode()
end

-------------------------------------
-- function click_startBtn
-- @brief 
-------------------------------------
function UI_DimensionGateScene:click_startBtn()
    local callback_func = function()
        if self.m_selectedDimensionGateInfo == nil then
            error('m_selectedDimensionGateInfo is not initialized.')
        end

        local stage_id = self.m_selectedDimensionGateInfo.ui:getStageID()
        --UI_AdventureStageInfo(stage_id)

        local function close_cb()
            self:sceneFadeInAction()
        end

        local ui = UI_ReadySceneNew(stage_id)
        ui:setCloseCB(close_cb)
    end

    self:sceneFadeOutAndCallFunc(callback_func)
end


-------------------------------------
-- function click_stageBtn
-- @brief callback function of UI_DimensionGateItem
-- @param target_ui 
-- @param data 
-------------------------------------
function UI_DimensionGateScene:click_stageBtn(target_ui, data)
    local vars = self.vars
    
    -- 스테이지 팝업 상태에서 클릭시 팝업 닫고 tableview 다시 보여주기
    if self.m_selectedDimensionGateInfo then
        self:closeStageNode()
        return
    end

    -- Chapter에 따라 해당하는 tableview를 선택
    local target_tableView
    if self.m_selectedChapter == self.m_bottomBtn then
        target_tableView = self.m_bottomTableView
    else
        target_tableView = self.m_topTableView
    end
    --target_tableView:setScrollLock(true)

    for i,v in ipairs(target_tableView.m_itemList) do
        local temp_ui = v['ui']
        if temp_ui ~= target_ui then
            temp_ui:setVisible(false)
        end
    end

    local node = target_ui.root
    --local node_pos = convertToAnoterParentSpace(node, self.m_dmgateNode)
    

    node:retain()
    node:removeFromParent()
    --node:setPosition(node_pos['x'], node_pos['y'])
    self.m_dmgateNode:addChild(node)
    node:release()

    local target_pos = convertToAnoterNodeSpace(node, self.m_stagePosNode)
    target_ui:cellMoveTo(0.5, target_pos)

    self.m_selectedDimensionGateInfo = {ui = target_ui}


    cca.reserveFunc(self.m_stageNode, 0.25, 
    function() self:PopupStageNode(data) end)
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

-------------------------------------
-- function closeStageNode
-- @brief 
-------------------------------------
function UI_DimensionGateScene:closeStageNode()
    self.m_stageNode:setVisible(false)

    -- Chapter에 따라 해당하는 tableview를 선택
    local target_tableView
    if self.m_selectedChapter == self.m_bottomBtn then
        target_tableView = self.m_bottomTableView
    else
        target_tableView = self.m_topTableView
    end

    local target_ui = self.m_selectedDimensionGateInfo.ui
    
    for i,v in ipairs(target_tableView.m_itemList) do
        local temp_ui = v['ui']
        if temp_ui ~= target_ui then
            temp_ui:setVisible(true)
        end
    end
    
    local node = target_ui.root
    local container = target_tableView.m_scrollView:getContainer()
    
    node:retain()
    node:removeFromParent()

    container:addChild(node)
    node:release()

    
    target_tableView:setDirtyItemList()
    --target_tableView:setScrollLock(true)

    self.m_selectedDimensionGateInfo = nil
    --self.m_topBtn:setTouchEnabled(true)
    --self.m_bottomBtn:setTouchEnabled(true)
    if(self.m_diffLevelTableView ~= nil) then
        self.m_diffLevelTableView:clearItemList()
    end
    self.m_diffLevelTableView = nil
end

-------------------------------------
-- function PopupStageNode
-- @brief 
-------------------------------------
function UI_DimensionGateScene:PopupStageNode(data)
    self.m_stageNode:setVisible(true)
    -- block to touch 
    --self.m_topBtn:setTouchEnabled(false)
    --self.m_bottomBtn:setTouchEnabled(false)
    local stage_id =  self.m_selectedDimensionGateInfo.ui.m_stageID

    -- 스테이지 설명 ---------------------------------------------
    self.m_stageLabel:setString(g_stageData:getStageName(stage_id))
    self.m_stageInfoLabel:setString(g_stageData:getStageDesc(stage_id))


   
    -- 출현 몬스터 테이블뷰---------------------------------------------
    --self.m_stageMonsterListNode
    self.m_stageMonsterListNode:removeAllChildren()

    local monsterIDList = g_stageData:getMonsterIDList(stage_id)

    local function cb_monsterCardUI(data)
        local ui = UI_MonsterCard(data)
        ui:setStageID(stage_id)
        return ui
    end

    local size = self.m_stageMonsterListNode:getContentSize()
    local function create_callback(ui, data)
        
        --ui.root:setNormalSize(size['height'], size['height'])
        ui.root:setScale(0.6)
        ui.root:setSwallowTouch(false)
    end

    local table_view = UIC_TableView(self.m_stageMonsterListNode)
    --table_view:setCellSizeToNodeSize(true)
    table_view:setCellUIClass(cb_monsterCardUI, create_callback)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setAlignCenter(true)
    
    table_view:setItemList(monsterIDList)
    table_view.m_scrollView:setTouchEnabled(false)

    self.m_monsterInfoTableView = table_view

    -- 난이도 ---------------------------------------------
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
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(data, create_callback)
    table_view:setAlignCenter(true)

    self.m_diffLevelTableView = table_view
end



--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

