local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

----------------------------------------------------------------------
-- class UI_DmgateScene
----------------------------------------------------------------------
UI_DmgateScene = class(PARENT, {
    m_stageItemGap = 'number',  -- 스테이지 버튼 사이 거리
    
    m_modeId = 'number',        -- 현재 모드 id (앙그라, 마누스, ...)
    m_chapterId = 'number',     -- 현재 챕터 id (상층, 하층)
    
    -- nodes from ui file
    m_dmgateNode = 'cc.Node',   -- UI_DmgateSceneItem의 UIC_TableView를 위한 상위 노드

    -- dmgate_scene.ui 챕터 버튼
    m_chapterButtons = 'List[UIC_Button]',          -- dmgate_scene.ui 의 chapterBtn1, chapterBtn2를 관리하기 위한 리스트
    m_chapterBgSprites = 'List[Animator]',          -- dmgate_scene.ui 의 chapterBgSprite1, chapterBgSprite2를 관리하기 위한 리스트
    m_chapterTableViews = 'List[UIC_TableView]',    -- chapter의 수만큼 UI_DmgateSceneItem의 UIC_TableView를 관리하기 위한 리스트

    -- 시즌 시간
    m_timeNode = 'cc.Node',         -- 시즌 시간 노드 for setVisible()
    m_timeLabel = 'UIC_LabelTTF',   -- 남은 시즌 시간 텍스트

    
    m_seasonBtn = 'UIC_Button',     -- 시즌 효과 버튼
    m_infoBtn = 'UIC_Button',       -- 도움말 버튼
    m_shopBtn = 'UIC_Button',       -- 상점 버튼    

    -- 스테이지 선택 메뉴
    m_stageMenu = 'cc.Menu',            -- 스테이지 선택 메뉴 전체 노드
    m_stageNameLabel = 'UIC_LabelTTF',  -- 스테이지 이름 텍스트 노드
    m_stageDescLabel = 'UIC_LabelTTF',  -- 스테이지 설명 텍스트 노드
    
    m_monstersNode = 'cc.Node',            -- 출현몬스터 테이블뷰를 위한 노드
    m_monstersTableView = 'UIC_TableView', -- 출현 몬스터 테이블뷰

    m_difficultyMenu = 'cc.Menu',            -- 난이도 선택 메뉴 노드
    m_difficultyNode = 'cc.Node',            -- 난이도 선택 테이블뷰를 위한 노드
    m_difficultyTableView = 'UIC_TableView', -- 난이도 선택 테이블뷰

    m_startBtn = 'UIC_Button',        -- 게임 준비 버튼
    m_manageDevBtn = 'UIC_Button',      -- 개발버튼

    m_stageBtnUI = 'UI_DmgateSceneItem',    -- 선택된 스테이지 버튼 UI
    m_stagePosNode = 'cc.Node',    -- 선택된 스테이지 버튼 ui의 translation을 위한 노드
})

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  Init functions
--////////////////////////////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------
-- function initParentVariable
-- @brief pure virtual function of ITopUserInfo_EventListener 
----------------------------------------------------------------------
function UI_DmgateScene:initParentVariable()
    self.m_uiName = 'UI_DmgateScene'
    self.m_titleStr = Str('차원문')
    self.m_subCurrency = 'medal_angra'  -- 상단 유저 재화 정보 중 서브 재화
    self.m_bVisible = true              
    self.m_bUseExitBtn = true           
end

----------------------------------------------------------------------
-- function init
-- @brief virtual function of UI
----------------------------------------------------------------------
function UI_DmgateScene:init(stage_id)
    local vars = self:load('dmgate_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DmgateScene')    
    self:doActionReset()
    self:doAction(nil, false)

    self:initMember(stage_id)
    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

----------------------------------------------------------------------
-- function initMember
----------------------------------------------------------------------
function UI_DmgateScene:initMember(stage_id)
    local vars = self.vars

    self.m_stageItemGap = 15 -- 스테이지 버튼 사이 거리
    self.m_modeId = DIMENSION_GATE_ANGRA
    
    if stage_id then
        self.m_chapterId = g_dmgateData:getChapterID(stage_id)
    else
        local clearedMaxStage_id = g_dmgateData:getClearedMaxStageInList(self.m_modeId)
        self.m_chapterId = g_dmgateData:getChapterID(clearedMaxStage_id)
    end

    -- init ui nodes
    self.m_dmgateNode = vars['dmgateNode']  -- UI_DmgateSceneItem의 UIC_TableView를 위한 상위 노드

    self.m_timeNode = vars['timeNode']      -- 시간 메뉴 for visible(true or false)
    self.m_timeLabel = vars['timeLabel']    -- 시간 텍스트 노드

    self.m_seasonBtn = vars['seasonBtn']    -- 시즌 효과 버튼
    self.m_infoBtn = vars['infoBtn']        -- 도움말 버튼
    self.m_shopBtn = vars['shopBtn']        -- 상점 버튼
 
    -- 스테이지 선택 메뉴
    self.m_stageMenu = vars['stageMenu']             -- 스테이지 선택 메뉴 전체 노드

    self.m_stageNameLabel = vars['stageNameLabel']   -- 스테이지 이름 텍스트 노드
    self.m_stageDescLabel = vars['stageDescLabel']   -- 스테이지 설명 텍스트 노드
    
    self.m_monstersNode = vars['monstersNode']       -- 출현몬스터 테이블뷰를 위한 노드

    self.m_difficultyMenu = vars['difficultyMenu']   -- 난이도 선택 메뉴 노드
    self.m_difficultyNode = vars['difficultyNode']   -- 난이도 선택 테이블뷰를 위한 노드

    self.m_stagePosNode = vars['stagePosNode']       -- 선택된 스테이지 버튼 ui의 translation을 위한 노드

    self.m_startBtn = vars['startBtn']               -- 게임 준비 버튼   

    self.m_manageDevBtn = vars['manageDevBtn']       -- 개발버튼 (현재 시즌효과 설정에 사용 중)   
    

    -- 챕터 관련 버튼, 배경 스프라이트, 테이블뷰
    self.m_chapterButtons = {}
    self.m_chapterBgSprites = {}
    self.m_chapterTableViews = {}
    local buttonNum = 1
    while(vars['chapterBtn' .. buttonNum] ~= nil) do
        self.m_chapterButtons[buttonNum] = vars['chapterBtn' .. buttonNum]
        self.m_chapterBgSprites[buttonNum] = vars['chapterBgSprite' .. buttonNum]
        buttonNum = buttonNum + 1
    end

    -- dmgate_scene.ui 파일에 있는 챕터 버튼의 수와 배경 수가 다르면 에러 발생
    if (#self.m_chapterButtons ~= #self.m_chapterBgSprites) then
        error('The number between chapter buttons, labels and bgSprites is not corresponded. Check .ui file.')
    end
end

----------------------------------------------------------------------
-- function initUI
-- @brief virtual function of UI
----------------------------------------------------------------------
function UI_DmgateScene:initUI()
    -- UI_DmgateSceneItem의 TableView 
    self:initTableView()
end

----------------------------------------------------------------------
-- function initButton
-- @brief virtual function of UI
----------------------------------------------------------------------
function UI_DmgateScene:initButton()
    -- 챕터 버튼 마다 script 등록
    for index, button in pairs(self.m_chapterButtons) do 
        button:registerScriptTapHandler(function() self:click_chapterBtn(index) end)
    end

    -- 현재 챕터 버튼 활성화
    self:click_chapterBtn(self.m_chapterId)

    -- TEMP (210414) : 하층만 열려있을 경우 챕터 버튼들 숨김 처리
    if (self.m_chapterId == 1) and (not g_dmgateData:isChapterCleared(self.m_modeId, self.m_chapterId)) then 
        for index, chapter_button in pairs(self.m_chapterButtons) do 
            chapter_button:setVisible(false)
        end
    end
        
    if IS_TEST_MODE() then
        self.m_manageDevBtn:setVisible(true)
    end

    -- 시즌 효과 버튼
    self.m_seasonBtn:registerScriptTapHandler(function() self:click_seasonBtn() end)
    -- 도움말 버튼
    self.m_infoBtn:registerScriptTapHandler(function() self:click_infoBtn() end)
    -- 상점 버튼
    self.m_shopBtn:registerScriptTapHandler(function() self:click_shopBtn() end)
    -- 시작 버튼
    self.m_startBtn:registerScriptTapHandler(function() self:click_startBtn() end)
    -- 개발 버튼
    self.m_manageDevBtn:registerScriptTapHandler(function() self:click_devBtn() end)
end

----------------------------------------------------------------------
-- function refresh
-- @brief virtual function of UI
----------------------------------------------------------------------
function UI_DmgateScene:refresh() 
    if self.m_chapterId ~= 1 then
        self.root:unscheduleUpdate()
        -- 시즌 타이머
        self.root:scheduleUpdateWithPriorityLua(function(dt) self:updateTimer(dt) end, 0)
    else
        self.root:unscheduleUpdate()
    end
end

----------------------------------------------------------------------
-- function updateTimer
----------------------------------------------------------------------
function UI_DmgateScene:updateTimer(dt)
    local str
    local is_season_ended
    str, is_season_ended = g_dmgateData:getTimeStatusText(self.m_modeId, self.m_chapterId)

    self.m_timeLabel:setString(str)

    if is_season_ended then 
        g_dmgateData:MakeSeasonEndedPopup()
        self.root:unscheduleUpdate()
    end
end

----------------------------------------------------------------------
-- function initTableView
-- brief : 챕터 버튼 별로 UIC_TableView 생성을 위한 help function
----------------------------------------------------------------------
function UI_DmgateScene:initTableView()

    -- 생성되는 UI_DmgateStageItem 가 가지고 있는 'stageBtn'에 UI_DmgateScene:click_stageBtn()을 등록
    create_callback = function(ui, data)
        ui.m_stageBtn:registerScriptTapHandler(function() self:click_stageBtn(ui, data) end)
        ui.root:setSwallowTouch(false)
    end

    -- 챕터 버튼 수 만큼 TableView 생성
    for i = 1, #self.m_chapterButtons do
        local tableview = UIC_TableView(self.m_dmgateNode)
        tableview:setAlignCenter(true)
        tableview:setCellSizeToNodeSize(true)
        tableview:setGapBtwCells(self.m_stageItemGap)
        tableview:setCellUIClass(UI_DmgateStageItem, create_callback)
        tableview:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        
        local list = g_dmgateData:getStageListByChapterId(self.m_modeId, i)
        
        if (list == nil) then   -- 
            error('there isn\'t any stage corresponding with mode_id \'' .. tostring(mode_id) .. '\' and chapter_id \'' .. tostring(i) .. '\'') 
        end

        tableview:setItemList(list, true)
        tableview:setScrollLock(true)
        tableview:setVisible(self.m_chapterId == i) -- 현재 활성화된 챕터

        self.m_chapterTableViews[i] = tableview
    end
end


----------------------------------------------------------------------
-- function onClose
-- @brief pure virtual function of ITopUserInfo_EventListener 
----------------------------------------------------------------------
function UI_DmgateScene:onClose() 
    self:releaseI_TopUserInfo_EventListener()
    g_currScene:removeBackKeyListener(self)
end

----------------------------------------------------------------------
-- function onFocus
-- @brief pure virtual function of ITopUserInfo_EventListener 
----------------------------------------------------------------------
function UI_DmgateScene:onFocus() 
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  click functions
--////////////////////////////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------
-- function click_exitBtn
-- @brief pure virtual function of ITopUserInfo_EventListener 
----------------------------------------------------------------------
function UI_DmgateScene:click_exitBtn()
    if self.m_stageBtnUI then
        self:closeStageNode()
    elseif (g_currScene.m_sceneName == 'SceneDmgate') then
        local is_use_loading = false
        local scene = SceneLobby(is_use_loading)
        scene:runScene()
    else
        self:close()
    end
end

-------------------------------------------------------------------------------------------------------------
-- function click_chapterBtn
-------------------------------------------------------------------------------------------------------------
function UI_DmgateScene:click_chapterBtn(chapter_id)

    -- 스테이지 선택 후 스테이지 정보 화면 닫음
    if (self.m_stageBtnUI) then
        self:closeStageNode()
    end

    self.m_chapterId = chapter_id

    -- TODO : 210408 기준 앙그라 2챕터 중에 1챕터는 시즌 효과을 숨기지만 조건이 달라질 수 있기에 변경 필요
    -- 벞 없으면 버튼 노출 X
    local isSeasonBtnActive = self.m_chapterId ~= 1
    local buff_list = g_dmgateData:getBuffList(DIMENSION_GATE_ANGRA)
    if (not buff_list) or (#buff_list <= 0) then isSeasonBtnActive = false end

    self.m_seasonBtn:setVisible(isSeasonBtnActive)
    self.m_timeNode:setVisible(isSeasonBtnActive)

    local isSameIndex
    for i = 1, #self.m_chapterButtons do
        isSameIndex = (i == chapter_id)
        self.m_chapterButtons[i]:setEnabled(not isSameIndex)
        self.m_chapterBgSprites[i]:setVisible(isSameIndex)
        self.m_chapterTableViews[i]:setVisible(isSameIndex)
    end

    self.m_chapterTableViews[chapter_id]:refreshAllItemUI()

    self:refresh()
end

----------------------------------------------------------------------------
-- function click_blessBtn
-- brief 시즌 효과 버튼 팝업
----------------------------------------------------------------------------
function UI_DmgateScene:click_seasonBtn()
    UI_DmgateBlessBtnPopup()
end

----------------------------------------------------------------------------
-- function click_infoBtn
-- breif 도움말 버튼 팝업
----------------------------------------------------------------------------
function UI_DmgateScene:click_infoBtn()
    UI_DmgateInfoBtnPopup()
end

----------------------------------------------------------------------------
-- function click_shopBtn
-- brief 상점 버튼 팝업
----------------------------------------------------------------------------
function UI_DmgateScene:click_shopBtn()
    local function finish_cb()
        local ui = UI_DmgateShop()
    end
    g_dmgateData:request_shopInfo(finish_cb)
end

----------------------------------------------------------------------------
-- function click_stageBtn
-- UI_DmgateStageItem의 'stageBtn'에 등록될 function
----------------------------------------------------------------------------
function UI_DmgateScene:click_stageBtn(target_ui, data)
    -- 
    if (self.m_stageBtnUI) then
        self:closeStageNode()
        return
    end

    local tableview = self.m_chapterTableViews[self.m_chapterId]

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

    self.m_stageBtnUI = target_ui

    cca.reserveFunc(self.m_stageMenu, 0.25, function() self:openStageNode(data) end)
end

----------------------------------------------------------------------------
-- function click_difficultyBtn
----------------------------------------------------------------------------
function UI_DmgateScene:click_difficultyBtn(itemUI)
    local vars = self.vars

    local item_stage_id = itemUI:getStageID()
    local target_stage_id = self.m_stageBtnUI:getStageID()
 
    if target_stage_id ~= item_stage_id then
        if not g_dmgateData:isStageOpened(item_stage_id) then
            UIManager:toastNotificationRed(Str('이전 스테이지를 클리어하세요.'))
            return 
        end

        self.m_stageBtnUI:setStageID(item_stage_id)
        self.m_stageBtnUI:refresh()
    else
        return
    end
    
    target_stage_id = self.m_stageBtnUI:getStageID()

    for _, item in ipairs(self.m_difficultyTableView.m_itemList) do
        local item_ui = item['ui']
        local item_id = item_ui:getStageID()

        
        item_ui.m_selectedBtn:setEnabled(target_stage_id ~= item_id)
    end
    
    self.m_monstersNode:removeAllChildren()
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

    local monster_table_view = UIC_TableView(self.m_monstersNode)
    monster_table_view:setCellUIClass(cb_monsterCardUI, create_callback)
    monster_table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    monster_table_view:setAlignCenter(true)
    --monster_table_view:setCellSize(true)
    --monster_table_view:setSrollLocl()
    monster_table_view:setItemList(monster_list, true)
    monster_table_view.m_scrollView:setTouchEnabled(false)

    self.m_monstersTableView = monster_table_view
end

----------------------------------------------------------------------------
-- function click_startBtn
----------------------------------------------------------------------------
function UI_DmgateScene:click_startBtn()
    local callback_func = function ()
        if self.m_stageBtnUI == nil then
            error('m_stageBtnUI is not initialized.')
        end

        local stage_id = self.m_stageBtnUI:getStageID()

        local function close_cb() self:sceneFadeInAction() end

        local ui = UI_ReadySceneNew(stage_id)
        ui:setCloseCB(close_cb)
    end

    self:sceneFadeOutAndCallFunc(callback_func)
end

----------------------------------------------------------------------------
-- function click_devBtn
----------------------------------------------------------------------------
function UI_DmgateScene:click_devBtn()
    local edit_box = UI_SimpleEditBoxPopup()
    edit_box:setPopupTitle(Str(''))
    edit_box:setPopupDsc(Str('시준효과 설정'))
    edit_box:setPlaceHolder(Str('스킬아이디를 세미콜론으로 구분하여 쭈우욱 입력하시오.'))
    edit_box:setMaxLength(100)

    local function confirm_cb(str)
        if (isNullOrEmpty(str) == false) then
            local buff_list = plSplit(str, ';')   
            local dragon_skill_table = TABLE:get('dragon_skill')
            local data
            for _, skill_id in pairs(buff_list) do
                data = dragon_skill_table[tonumber(skill_id)]

                if not data then
                    UIManager:toastNotificationRed('잘못된 스킬아이디 입력. sid :: ' .. tostring(skill_id))
                    return false
                end
            end
        end

        return true
    end

    edit_box:setConfirmCB(confirm_cb)

    local function close_cb()
        if (edit_box.m_retType == 'ok') then
            local buff_str = edit_box.m_str

            if (isNullOrEmpty(buff_str) == true) then
                UIManager:toastNotificationRed('입력한 데이터가 없어서 써버데이터를 사용합니다.')
            end

            if (confirm_cb(buff_str) == false) then return end

            g_dmgateData.m_testSeasonBuffList = buff_str
        end
    end

    edit_box:setCloseCB(close_cb)
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  private member functions
--////////////////////////////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------------
-- function openStageNode
----------------------------------------------------------------------------
function UI_DmgateScene:openStageNode(data)
    -- click_stageBtn 에서 target_ui 가 지정 안된 경우
    if (self.m_stageBtnUI == nil) then return end

    self.m_stageMenu:setVisible(true)

    local target_stage_id = self.m_stageBtnUI:getStageID()

    -- 스테이지 설명
    self.m_stageNameLabel:setString(g_dmgateData:getStageName(target_stage_id))
    self.m_stageDescLabel:setString(g_dmgateData:getStageDesc(target_stage_id))

    -- 출현 몬스터 테이블뷰 ------------------------------------------------------------------
    self.m_monstersNode:removeAllChildren()
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

    local monster_table_view = UIC_TableView(self.m_monstersNode)
    monster_table_view:setCellUIClass(cb_monsterCardUI, create_callback)
    monster_table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    monster_table_view:setAlignCenter(true)
    --monster_table_view:setCellSize(true)
    --monster_table_view:setSrollLocl()
    monster_table_view:setItemList(monster_list, true)
    monster_table_view.m_scrollView:setTouchEnabled(false)

    self.m_monstersTableView = monster_table_view

    -- 난이도 선택 테이블뷰  ------------------------------------------------------------------
    self.m_difficultyNode:removeAllChildren()

    self.m_difficultyMenu:setVisible(#data ~= 1)
    

    local function create_callback(ui, data)
        ui.m_selectedBtn:registerScriptTapHandler(function() self:click_difficultyBtn(ui) end)
        local isEnabled = (data['stage_id'] ~= target_stage_id) --g_dmgateData:isStageOpened(data['stage_id']) and (data['stage_id'] ~= target_stage_id)
        isEnabled = (isEnabled) and (g_dmgateData:checkStageTime(data['stage_id']))
        ui.m_selectedBtn:setEnabled(isEnabled)
        return true
    end

    local difficulty_table_view = UIC_TableView(self.m_difficultyNode)
    difficulty_table_view:setAlignCenter(true)
    difficulty_table_view:setCellSizeToNodeSize(true)
    difficulty_table_view:setGapBtwCells(15)
    difficulty_table_view:setCellUIClass(UI_DmgateDifficultyItem, create_callback)
    difficulty_table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)

    difficulty_table_view:setItemList(data, create_callback)
    difficulty_table_view:setScrollLock(true)

    self.m_difficultyTableView = difficulty_table_view
end

----------------------------------------------------------------------------
-- function closeStageNode
----------------------------------------------------------------------------
function UI_DmgateScene:closeStageNode()
    self.m_stageMenu:setVisible(false)

    local tableview = self.m_chapterTableViews[self.m_chapterId]

    local target_ui = self.m_stageBtnUI

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

    self.m_stageBtnUI = nil

    if(self.m_difficultyTableView ~= nil) then
        self.m_difficultyTableView:clearItemList()
    end
    self.m_difficultyTableView = nil
end

