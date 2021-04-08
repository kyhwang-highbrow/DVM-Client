local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

----------------------------------------------------------------------
-- class UI_DimensionGateScene
----------------------------------------------------------------------
UI_DimensionGateScene = class(PARENT, {
    m_monsterInfoTableView = '',        -- 난이도 선택 팝업의 몬스터 정보
    
    -- nodes from ui file
    m_dmgateNode = '',

    -- ui buttons


    -- 리팩토링
    m_stageItemGap = 'number', -- 스테이지 버튼 사이 거리
    m_chapterButtons = '',
    m_chapterLabels = '',
    m_chapterBgSprites = '',
    m_chapterTableViews = '',

    -- Test
    m_selectedDimensionGateInfo = '',
    m_currChapter = '',
    m_currMode = '',

    -- 
    m_blessBtn = '',
    m_infoBtn = '',
    m_shopBtn = '',

    -- 스테이지 선택 메뉴
    m_stageMenu = '',       -- 스테이지 선택 메뉴 전체 노드
    m_stageLabel = '',      -- 스테이지 이름 텍스트 노드
    m_stageInfoLabel = '',  -- 스테이지 설명 텍스트 노드
    
    m_monsterListNode = '', -- 출현몬스터 테이블뷰를 위한 노드
    m_monsterInfoTableView = '', -- 출현 몬스터 테이블뷰

    m_difficultyMenu = '',  -- 난이도 선택 메뉴 노드
    m_stageItemNode = '',   -- 난이도 선택 테이블뷰를 위한 노드
    m_difficultyTableView = '', -- 난이도 선택 테이블뷰

    m_startBtn = '',        -- 게임 준비 버튼
    

    m_stagePosNode = '',
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

    self:initMemberVariable(stage_id)
    self:initUI()
    self:initButton(stage_id)
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateScene:initUI()
    self:initTableView()
end

-------------------------------------
-- function initButton
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateScene:initButton(stage_id) 
    for index, button in pairs(self.m_chapterButtons) do 
        button:registerScriptTapHandler(function() self:click_chapterBtn(index) end)
    end

    self:click_chapterBtn(self.m_currChapter)

    if (self.m_currChapter == 1) and (not g_dimensionGateData:isChapterCleared(self.m_currMode, self.m_currChapter)) then 
        for index, chapter_button in pairs(self.m_chapterButtons) do 
            chapter_button:setVisible(false)
        end
    end
        

    -- m
    self.m_startBtn:registerScriptTapHandler(function() self:click_startBtn() end)
    self.m_blessBtn:registerScriptTapHandler(function() self:click_blessBtn() end)
    self.m_infoBtn:registerScriptTapHandler(function() self:click_infoBtn() end)
    self.m_shopBtn:registerScriptTapHandler(function() self:click_shopBtn() end)

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
function UI_DimensionGateScene:initMemberVariable(stage_id)
    local vars = self.vars
    -- TODO : temp code
    self.m_currMode = DIMENSION_GATE_ANGRA
    self.m_stageItemGap = 15 -- 스테이지 버튼 사이 거리

    -- init ui nodes
    self.m_dmgateNode = vars['dmgateNode']

    

    --init ui buttons
    self.m_chapterButtons = {}
    self.m_chapterLabels = {}
    self.m_chapterBgSprites = {}
    self.m_chapterTableViews = {}
    local buttonNum = 1
    while(vars['chapterBtn' .. tostring(buttonNum)] ~= nil) do
        self.m_chapterButtons[buttonNum] = vars['chapterBtn' .. tostring(buttonNum)]
        self.m_chapterLabels[buttonNum] = vars['chapterLabel' .. tostring(buttonNum)]
        self.m_chapterBgSprites[buttonNum] = vars['chapterBgSprite' .. tostring(buttonNum)]
        buttonNum = buttonNum + 1
    end

    --
    if ((#self.m_chapterButtons ~= #self.m_chapterLabels)
        and (#self.m_chapterButtons ~= #self.m_chapterBgSprites)) then
        error('The number between chapter buttons, labels and bgSprites is not corresponded. Check .ui file.')
    end

    
    if stage_id then
        self.m_currChapter = g_dimensionGateData:getChapterID(stage_id)
    else
        local clearedMaxStage_id = g_dimensionGateData:getClearedMaxStageInList(self.m_currMode)
        self.m_currChapter = g_dimensionGateData:getChapterID(clearedMaxStage_id)
    end

    --
    
    self.m_blessBtn = vars['blessBtn']  -- 주간축복 버튼
    self.m_infoBtn = vars['infoBtn']    -- 도움말 버튼
    self.m_shopBtn = vars['shopBtn']    -- 상점 버튼

    
    -- 스테이지 선택 메뉴
    self.m_stageMenu = vars['stageMenu']             -- 스테이지 선택 메뉴 전체 노드
    self.m_stageLabel = vars['stageLabel']           -- 스테이지 이름 텍스트 노드
    self.m_stageInfoLabel = vars['stageInfoLabel']   -- 스테이지 설명 텍스트 노드
    
    self.m_monsterListNode = vars['monsterListNode'] -- 출현몬스터 테이블뷰를 위한 노드
    self.m_difficultyMenu = vars['difficultyMenu']   -- 난이도 선택 메뉴 노드
    self.m_stageItemNode = vars['stageItemNode']     -- 난이도 선택 테이블뷰를 위한 노드

    self.m_startBtn = vars['startBtn']               -- 게임 준비 버튼
    self.m_stagePosNode = vars['stagePosNode']
end

function UI_DimensionGateScene:initTableView()

    create_callback = function(ui, data)
        ui.m_stageBtn:registerScriptTapHandler(function() self:click_stageBtn(ui, data) end)
        --ui.m_stageBtn:registerScriptTapHandler(function() self:click_stageBtn(ui, data) end)
        ui.root:setSwallowTouch(false)
    end

    for i = 1, #self.m_chapterButtons do 
        local table_view = UIC_TableView(self.m_dmgateNode)
        table_view:setAlignCenter(true)
        table_view:setCellSizeToNodeSize(true)
        table_view:setGapBtwCells(self.m_stageItemGap)
        table_view:setCellUIClass(UI_DimensionGateItem, create_callback)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        
        local list = g_dimensionGateData:getStageListByChapter(self.m_currMode, i)
        
        if (list == nil) then error('there isn\'t any stage corresponding with mode_id \'' .. tostring(mode_id) .. '\' and chapter_id \'' .. tostring(i) .. '\'') end
        table_view:setItemList(list, true)

        table_view:setScrollLock(true)
        -- 
        table_view:setVisible(self.m_currChapter == i)

        self.m_chapterTableViews[i] = table_view
    end
end

-------------------------------------
-- function initParentVariable
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateScene:initParentVariable()
    self.m_uiName = 'UI_DimensionGateScene'
    self.m_titleStr = Str('차원문')
    self.m_subCurrency = 'medal_angra' -- 
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

----------------------------------------------------------------------------
-- function click_chapterBtn
----------------------------------------------------------------------------
function UI_DimensionGateScene:click_chapterBtn(index)
    
    --if(self.m_chapterButtons[index]:getEnableD
    --if(self.m_selectedChapter == self.m_chapterButtons[index]) then return end
    if (self.m_selectedDimensionGateInfo) then
        self:closeStageNode()
        
    end

    self.m_currChapter = index

    -- TODO : 210408 기준 앙그라 2챕터 중에 1챕터는 축복버튼을 숨기지만 조건이 달라질 수 있기에 변경 필요
    self.m_blessBtn:setVisible(self.m_currChapter ~= 1)

    local isSameIndex

    for i = 1, #self.m_chapterButtons do
        isSameIndex = (i == index)
        self.m_chapterButtons[i]:setEnabled(not isSameIndex)
        --self.m_chapterLabels
        self.m_chapterBgSprites[i]:setVisible(isSameIndex)

        self.m_chapterTableViews[i]:setVisible(isSameIndex)
    end

    self.m_chapterTableViews[index]:refreshAllItemUI()
end

----------------------------------------------------------------------------
-- function click_stageBtn
----------------------------------------------------------------------------
function UI_DimensionGateScene:click_stageBtn(target_ui, data)
    if (self.m_selectedDimensionGateInfo) then
        self:closeStageNode()
        return
    end

    local tableview = self.m_chapterTableViews[self.m_currChapter]

    for _, item in ipairs(tableview.m_itemList) do
        local item_ui = item['ui']
        if (item_ui ~= target_ui) then
            item_ui:setVisible(false)
        end
    end

    local node = target_ui.root

    node:retain()
    node:removeFromParent()
    self.m_dmgateNode:addChild(node)
    node:release()

    local target_pos = convertToAnoterNodeSpace(node, self.m_stagePosNode)
    target_ui:cellMoveTo(0.5, target_pos)

    self.m_selectedDimensionGateInfo = {ui = target_ui}

    cca.reserveFunc(self.m_stageMenu, 0.25, function() self:openStageNode(data) end)
end

----------------------------------------------------------------------------
-- function click_startBtn
----------------------------------------------------------------------------
function UI_DimensionGateScene:click_startBtn()
    local callback_func = function ()
        if self.m_selectedDimensionGateInfo == nil then
            error('m_selectedDimensionGateInfo is not initialized.')
        end

        local stage_id = self.m_selectedDimensionGateInfo.ui:getStageID()

        local function close_cb() self:sceneFadeInAction() end

        local ui = UI_ReadySceneNew(stage_id)
        ui:setCloseCB(close_cb)
    end

    self:sceneFadeOutAndCallFunc(callback_func)
end

----------------------------------------------------------------------------
-- function click_blessBtn
----------------------------------------------------------------------------
function UI_DimensionGateScene:click_blessBtn()
    UI_DimensionGateBlessPopup()
end

----------------------------------------------------------------------------
-- function click_infoBtn
----------------------------------------------------------------------------
function UI_DimensionGateScene:click_infoBtn()
    UI_DimensionGateInfoPopup()
end

----------------------------------------------------------------------------
-- function click_shopBtn
----------------------------------------------------------------------------
function UI_DimensionGateScene:click_shopBtn()
    UI_DimensionGateShop()
end

----------------------------------------------------------------------------
-- function click_difficultyBtn
----------------------------------------------------------------------------
function UI_DimensionGateScene:click_difficultyBtn(itemUI)
    local vars = self.vars

    local item_stage_id = itemUI:getStageID()

    local target_ui = self.m_selectedDimensionGateInfo.ui
    local target_stage_id = target_ui:getStageID()
 
    if target_stage_id ~= item_stage_id then
        if not g_dimensionGateData:isStageOpened(item_stage_id) then
            g_dimensionGateData:Test(item_stage_id)
            return 
        end

        target_ui:setStageID(item_stage_id)
        target_ui:refresh()
    else
        return
    end
    
    target_stage_id = target_ui:getStageID()

    for _, item in ipairs(self.m_difficultyTableView.m_itemList) do
        local item_ui = item['ui']
        local item_id = item_ui:getStageID()

        
        item_ui.m_selectedBtn:setEnabled(target_stage_id ~= item_id)

        -- local isEnabled = g_dimensionGateData:isStageOpened(item_id) and item_ui:getStageID() ~= target_ui:getStageID()
        -- item_ui.m_selectedBtn:setEnabled(isEnabled)
    end
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------------
-- function openStageNode
----------------------------------------------------------------------------
function UI_DimensionGateScene:openStageNode(data)
    -- click_stageBtn 에서 target_ui 가 지정 안된 경우
    if (self.m_selectedDimensionGateInfo == nil) then return end

    self.m_stageMenu:setVisible(true)

    local target_stage_id = self.m_selectedDimensionGateInfo.ui:getStageID()

    -- 스테이지 설명
    self.m_stageLabel:setString(g_dimensionGateData:getStageName(target_stage_id))
    self.m_stageInfoLabel:setString(g_dimensionGateData:getStageDesc(target_stage_id))

    -- 출현 몬스터 테이블뷰 ------------------------------------------------------------------
    self.m_monsterListNode:removeAllChildren()
    local monster_list = g_stageData:getMonsterIDList(target_stage_id)

    local function cb_monsterCardUI(data)
        local ui = UI_MonsterCard(data)
        ui:setStageID(target_stage_id)
        return ui
    end

    local function create_callback(ui, data)
        ui.root:setScale(0.6)
        ui.root:setSwallowTouch(false)
    end

    local monster_table_view = UIC_TableView(self.m_monsterListNode)
    monster_table_view:setCellUIClass(cb_monsterCardUI, create_callback)
    monster_table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    monster_table_view:setAlignCenter(true)
    --monster_table_view:setCellSize(true)
    --monster_table_view:setSrollLocl()
    monster_table_view:setItemList(monster_list, true)
    monster_table_view.m_scrollView:setTouchEnabled(false)

    self.m_monsterInfoTableView = monster_table_view

    -- 난이도 선택 테이블뷰  ------------------------------------------------------------------
    self.m_stageItemNode:removeAllChildren()

    self.m_difficultyMenu:setVisible(#data ~= 1)
    

    local function create_callback(ui, data)
        ui.m_selectedBtn:registerScriptTapHandler(function() self:click_difficultyBtn(ui) end)
        local isEnabled = (data['stage_id'] ~= target_stage_id) --g_dimensionGateData:isStageOpened(data['stage_id']) and (data['stage_id'] ~= target_stage_id)
        isEnabled = (isEnabled) and (g_dimensionGateData:checkStageTime(data['stage_id']))
        ui.m_selectedBtn:setEnabled(isEnabled)
        return true
    end

    local difficulty_table_view = UIC_TableView(self.m_stageItemNode)
    difficulty_table_view:setAlignCenter(true)
    difficulty_table_view:setCellSizeToNodeSize(true)
    difficulty_table_view:setGapBtwCells(15)
    difficulty_table_view:setCellUIClass(UI_DimensionGateSceneStageItem, create_callback)
    difficulty_table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)

    difficulty_table_view:setItemList(data, create_callback)
    difficulty_table_view:setScrollLock(true)

    -- for key, item in ipairs(difficulty_table_view.m_itemList) do
    --     local item_ui = item['ui']

    --     local isSame = item_ui['stage_id'] == target_stage_id
    --     item_ui.m_selectedBtn:setEnabled(not isSame)
    -- end
    

    self.m_difficultyTableView = difficulty_table_view
end

----------------------------------------------------------------------------
-- function closeStageNode
----------------------------------------------------------------------------
function UI_DimensionGateScene:closeStageNode()
    self.m_stageMenu:setVisible(false)

    local tableview = self.m_chapterTableViews[self.m_currChapter]

    local target_ui = self.m_selectedDimensionGateInfo.ui

    for _, item in ipairs(tableview.m_itemList) do
        local item_ui = item['ui']
        if item_ui ~= target_ui then
            item_ui:setVisible(true)
        end
    end

    local node = target_ui.root
    local container = tableview.m_scrollView:getContainer()

    node:retain()
    node:removeFromParent()
    container:addChild(node)
    node:release()

    tableview:setDirtyItemList()

    self.m_selectedDimensionGateInfo = nil

    if(self.m_difficultyTableView ~= nil) then
        self.m_difficultyTableView:clearItemList()
    end
    self.m_difficultyTableView = nil
end

