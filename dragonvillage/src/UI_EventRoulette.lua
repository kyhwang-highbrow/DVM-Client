local PARENT = UI

----------------------------------------------------------------------
-- class UI_EventRoulette
-- @brief 
----------------------------------------------------------------------
UI_EventRoulette = class(PARENT, {
    m_currStep = 'number',                  -- 현재 step
    m_packageName = 'string',               -- 패키지 버튼에 연결될 패키지 이름

    -- 2022.04.14 @ksjang
    m_coroutineHelper = 'CoroutineHelper',  -- 연속 회전을 위한 코루틴 헬퍼
    m_bIsAuto = 'boolean',                  -- 자동인지 체크
    m_bIsShowRewardPopup = 'boolean',       -- 우편 발송 확인 UI 띄울지 않띄울지
    m_bIsTapBlockPopup = 'boolean',         -- 자동 돌림판 멈추기 위해 화면을 탭 했는지
    m_lAutoResult = 'table',                -- 자동 돌림판 결과 아이템 저장 리스트
    m_autoResultTableview = 'tableview',    -- 자동 돌림판 결과 아이템 TableView
    -----------------

    -- vars for skip
    m_blockUI = 'UI_BlockPopup',                    -- 스탑 버튼 이후 결과가 나오기 전까지 다른 액션을 막기 위한 ui
    m_eventDispatcher = 'EventDispatcher',          -- m_blockUI의 eventDispathcer
    m_eventListener = 'EventListenerTouchOneByOne', -- m_blockUI의 eventListener
    m_bIsSkipped = 'boolean',

    m_targetAngle = 'number',

    -- TOP
    m_timeLabel = 'UIC_LabelTTF',   -- 남은 시간 텍스트
    m_rewardLabel = 'UIC_LabelTTF', -- 보상 테이블 제목 라벨
    m_rankBtn = 'UIC_Button',       -- 랭킹 버튼
    m_infoBtn = 'UIC_Button',       -- 도움말 버튼
    m_closeBtn = 'UIC_Button',      -- 닫기 버튼
    m_autoBtn = 'UIC_Button',       -- 자동 뽑기 설정 버튼
    m_ingMenu = 'UIC_Node',         -- 진행도 Menu
    m_ingLabel = 'UIC_LabelTTF',    -- 진행도 라벨

    -- Middle Left
    m_rouletteMenues = 'List[cc.Menu]', -- 
    m_startBtns = 'List[UIC_Button]',   -- 시작 버튼
    m_stopBtn = 'UIC_Button',           -- 정지 버튼
    m_wheel = 'cc.Menu',                -- 돌림판 Sprite & nodes
    m_rouletteVisual = 'AnimatorVrp',   -- 돌림판 Sprite
    m_appearVisual = 'AnimatorVrp',     -- 연출 Animation

    m_itemUIList = 'List[UI_EventRoulette.UI_RouletteItem]', -- 돌림판 위에 상품 표기를 위한 Item UI 리스트
    m_itemNodeList = 'List[cc.Node]',                        -- 돌림판 위에 상품 표기를 위한 Item Node 리스트

    m_rewardItemInfo = 'cc.Node',           -- 2단계 상품의 상세 확률 표시를 위한 그룹 노드 (메뉴로 바꾸는게 좋을 듯)
    m_infoItemNodes = 'List[cc.Node]',      -- 2단계 상품의 상세 확률 표시를 위한 노드 리스트
    m_infoItemLabels = 'List[UIC_LabelTTF', -- 2단계 상품의 상세 확률 표시를 위한 텍스트 리스트
    m_arrowSprite = 'Animator',             -- 2단계 상세 확률을 가리키는 Sprite
    m_targetGroupIndex = 'number',          -- 현재 보여주고 있는 2단계 상품의 그룹 index

    -- Middle Right
    m_totalScoreLabel = 'UIC_LabelTTF', -- 누적점수
    m_rewardListNode = 'cc.Node',       -- 등장 가능 보상 테이블뷰를 위한 노드

    -- Bottom
    m_packageBtn = 'UIC_Button',        -- 패키지 연결 버튼
    m_ticketNumLabel = 'UIC_LabelTTF',  -- 티켓 수량
})

----------------------------------------------------------------------
-- function getCurrStep
-- @brief 현재 step 얻기, 코드 길어져서 별도 local 메서드 만듦
----------------------------------------------------------------------
local function getCurrStep()
    return g_eventRouletteData:getCurrStep()
end

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRoulette:init(is_popup)
    local vars = self:load('event_roulette.ui')

    -- 이벤트 페이지를 통한 접근이 아닐 시 팝업
    if is_popup then
        UIManager:open(self, UIManager.POPUP)
        g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRoulette')

        self:doActionReset()
        self:doAction(nil, false)
    end

    self:initMember()
    self:initUI(is_popup)
    self:initButton()
    self:refresh()

    -- UI 진입 시 랭킹 팝업 오픈
    g_eventRouletteData:MakeRankingRewardPopup()
    SoundMgr:playBGM('bgm_event_roulette')

    local function event_update(event)   
        if (event == 'exit') then
            SoundMgr:stopAllEffects()    
            SoundMgr:playBGM('bgm_lobby')
        end        
    end

    self.root:registerScriptHandler(event_update)
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_EventRoulette:initMember()
    local vars = self.vars
    
    self.m_uiName = 'UI_EventRoulette'
    self.m_packageName = 'package_roulette'

    -- auto Roulette
    self.m_bIsAuto = false
    self.m_bIsShowRewardPopup = true
    self.m_bIsTapBlockPopup = false
    self.m_lAutoResult = {}

    -- TOP
    self.m_rewardLabel = vars['rewardLabel'] -- 우측 '등장 가능 보상' 라벨
    self.m_timeLabel = vars['timeLabel']     -- 남은 시간 텍스트
    self.m_rankBtn = vars['rankBtn']         -- 랭킹 버튼
    self.m_infoBtn = vars['infoBtn']         -- 도움말 버튼
    self.m_closeBtn = vars['closeBtn']       -- 닫기 버튼
    self.m_autoBtn = vars['grindAutoBtn']    -- 자동 돌림판 설정 버튼
    self.m_ingMenu = vars['ingMenu']    -- 진행도 Menu
    self.m_ingLabel = vars['ingLabel']   -- 진행도 라벨


    -- Middle Left
    self.m_stopBtn = vars['stopBtn']
    self.m_wheel = vars['wheelMenu'] -- 돌림판 Sprite
    self.m_rouletteVisual = vars['rouletteVisual'] -- 돌림판 Sprite
    self.m_appearVisual = vars['appearVisual'] -- 연출 Animation
    self.m_appearVisual:setTimeScale(2) 
    
    self.m_rouletteMenues = {}
    self.m_startBtns = {}
    self.m_itemNodeList = {}
    self.m_itemUIList = {}

    self.m_infoItemNodes = {}
    self.m_infoItemLabels = {}

    local step = 1

    while(vars['rouletteMenu' .. step]) do
        self.m_rouletteMenues[step] = vars['rouletteMenu' .. step] -- 룰렛
        self.m_startBtns[step] = vars['startBtn' .. step]    -- 시작 버튼
        step = step + 1
    end

    local node_index = 1

    while(vars['itemNode' .. tostring(node_index)] and node_index <= 6) do
        -- 돌림판
        self.m_itemNodeList[node_index] = vars['itemNode' .. tostring(node_index)]

        local ui = UI_EventRouletteItem(node_index)
        self.m_itemUIList[node_index] = ui

        self.m_itemNodeList[node_index]:addChild(ui.root)
        self.m_itemNodeList[node_index]:setRotation(g_eventRouletteData:getAngle(node_index))

        -- 보상 리스트
        self.m_infoItemNodes[node_index] = vars['infoItemNode' .. tostring(node_index)]
        self.m_infoItemLabels[node_index] = vars['infoItemLabel' .. tostring(node_index)]

        node_index = node_index + 1
    end
    self.m_arrowSprite = vars['arrowSprite']
    self.m_rewardItemInfo = vars['rewardInfoNode'] -- 누르면 나오는 보상 목록

    -- Middle Right
    self.m_totalScoreLabel = vars['scoreLabel']  -- 누적점수
    self.m_rewardListNode = vars['rewardListNode']    -- 등장 가능 보상 테이블뷰를 위한 노드

    -- Bottom
    self.m_packageBtn = vars['packageBtn']    -- 패키지 연결 버튼
    self.m_ticketNumLabel = vars['numberLabel']  -- 티켓 수량
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_EventRoulette:initUI(is_popup)
    -- 이벤트 페이지로 이동 시 닫기 버튼 비활성화
    self.m_closeBtn:setVisible(is_popup)
    
    -- 남은 시간 타이머 등록
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:updateTimer(dt) end, 0)    

    local vars = self.vars
    local mileage = g_eventRouletteData:getMileage()

    if (mileage > -1) then
        vars['ceilingMenu']:setVisible(true)
        vars['ceilingBtn']:registerScriptTapHandler(function() self:click_ceilingBtn() end)
    else
        vars['ceilingMenu']:setVisible(false)
    end
end

----------------------------------------------------------------------
-- function click_ceilingBtn
----------------------------------------------------------------------
function UI_EventRoulette:click_ceilingBtn()
    local item_id = g_eventRouletteData:getItemId(2, 'group_1', 1)
    local did = TableItem:getDidByItemId(item_id)
	local birth_grade = TableDragon():getBirthGrade(did)

    if did and birth_grade then
       local ui = UI_BookDetailPopup.openWithFrame(did, birth_grade, 1, 0.8, true)
    end
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_EventRoulette:initButton()
    local step = 1

    while(self.m_rouletteMenues[step]) do
        self.m_startBtns[step]:registerScriptTapHandler(function() self:click_startBtn() end)
        step = step + 1
    end

    self.m_stopBtn:registerScriptTapHandler    (function() self:click_stopBtn   () end)
    self.m_closeBtn:registerScriptTapHandler   (function() self:close           () end)
    self.m_rankBtn:registerScriptTapHandler    (function() self:click_rankBtn   () end)
    self.m_infoBtn:registerScriptTapHandler    (function() self:click_infoBtn   () end)
    self.m_autoBtn:registerScriptTapHandler    (function() self:click_autoBtn   () end)
    self.m_packageBtn:registerScriptTapHandler (function() self:click_packageBtn() end)
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_EventRoulette:refresh()
    self.m_currStep = getCurrStep()

    self:refreshTicketNum()
    self:refreshTotalScore()
    self:refreshRoulette()

    -- 좌측 누르면 나오는 보상 리스트 비활성화 
    self.m_rewardItemInfo:setVisible(false)

    -- 하나씩 뽑기 할 경우 우측 보상 테이블 생성
    if(self.m_bIsAuto == false and self.m_bIsTapBlockPopup == false) then
        cclog("re!!!")
        self:refreshRewardTableview()
    end

    cclog('set false')
    self.m_bIsTapBlockPopup = false
    self.m_bIsSkipped = false

    self.m_stopBtn:setEnabled(true)
    self.m_stopBtn:setVisible(false)

    self.m_wheel:setRotation(0)

    self:refreshCeilingMenu()
    self:refreshAutoButton()
end

----------------------------------------------------------------------
-- function setAutoButtonVisible
-- @brief 자동 설정 버튼 활성화/비활성화 설정
----------------------------------------------------------------------
function UI_EventRoulette:setAutoButtonVisible(bVisible)
    self.m_autoBtn:setVisible(bVisible)
end

----------------------------------------------------------------------
-- function setIngMenuVisible
-- @brief 자동 돌림판 진행도 표시 UI visible 설정
-- @param bVisible visible 설정
----------------------------------------------------------------------
function UI_EventRoulette:setIngMenuVisible(bVisible)
    local ingMenu = self.m_ingMenu
    ingMenu:setVisible(bVisible)
end

----------------------------------------------------------------------
-- function setIngLabel
-- @brief 자동 돌림판 진행도 표시 UI Label 설정
-- @param cur_num 현재 시행 차수
-- @param total_num 전체 시행 횟수 
----------------------------------------------------------------------
function UI_EventRoulette:setIngLabel(cur_num, total_num)
    local ingLabel = self.m_ingLabel
    ingLabel:setString(Str('{1}/{2}회 진행 중', tostring(cur_num), tostring(total_num) ))
end

----------------------------------------------------------------------
-- function refreshRewardLabel
-- @brief '등장 가능 보상' label refresh
----------------------------------------------------------------------
function UI_EventRoulette:refreshRewardLabel()
    local rewardLabel = self.m_rewardLabel
    local bIsAuto = self.m_bIsAuto

    if (bIsAuto == true or getCurrStep() == 2) then
        self.m_rewardLabel:setString(Str('획득한 {1}', Str('보상')))
    else
        self.m_rewardLabel:setString(Str('등장 가능 보상'))
    end
end

----------------------------------------------------------------------
-- function refreshTicketNum
-- @brief 티켓 수 refresh
----------------------------------------------------------------------
function UI_EventRoulette:refreshTicketNum()
    local ticketNum = g_eventRouletteData:getTicketNum()
    self.m_ticketNumLabel:setString(ticketNum)
end

----------------------------------------------------------------------
-- function refreshTotalScore
-- @brief 누적 점수 refresh
----------------------------------------------------------------------
function UI_EventRoulette:refreshTotalScore()
    local totalScore = g_eventRouletteData:getTotalScore()
    self.m_totalScoreLabel:setString(Str('{1}점', totalScore))
end

----------------------------------------------------------------------
-- function refreshRoulette
-- @brief 돌림판, 돌림판 아이템, 돌림판 애니메이션 refresh
----------------------------------------------------------------------
function UI_EventRoulette:refreshRoulette()
    local rouletteMenues = self.m_rouletteMenues
    local startBtns = self.m_startBtns
    local itemUIList = self.m_itemUIList
    local rouletteVisual = self.m_rouletteVisual
    local currStep = self.m_currStep

    -- 각 스텝에 맞는 룰렛 메뉴와 버튼 활성화
    local step = 1
    while(rouletteMenues[step]) do
        rouletteMenues[step]:setVisible(currStep == step)
        startBtns[step]:setVisible(currStep == step)
        step = step + 1
    end

    -- 룰렛 위 아이템 refresh
    local index = 1
    while(itemUIList[index]) do
        itemUIList[index]:refresh()
        index = index + 1
    end

    rouletteVisual:changeAni('roulette_' .. tostring(currStep), true)
end

----------------------------------------------------------------------
-- function refreshCeilingMenu
-- @brief 드래곤 마일리지(천장) 메뉴 refresh
----------------------------------------------------------------------
function UI_EventRoulette:refreshCeilingMenu()
    local vars = self.vars
    local mileage = g_eventRouletteData:getMileage()

    if (vars['ceilingMenu']:isVisible()) then
        local item_id = g_eventRouletteData:getItemId(2, 'group_1', 1)
        local did = TableItem():getDidByItemId(item_id)
        local item_name = did and TableDragon:getChanceUpDragonName(did)
        local ceiling_str = Str('{1}\n확정 획득까지 {@yellow}{2}{@default}회', item_name, mileage)
        local is_definite_reward = mileage == 0
        vars['ceilingVisualMenu']:setVisible(is_definite_reward)

        if (is_definite_reward) then
            ceiling_str = Str('{1}\n{@default}확정 소환', item_name)
        end

        vars['ceilingLabel']:setString(ceiling_str)
    end
end

----------------------------------------------------------------------
-- function refreshAutoButton
-- @brief 1단계 : 버튼 보임, 2단계 : 버튼 안보임 refresh
----------------------------------------------------------------------
function UI_EventRoulette:refreshAutoButton()
    local currStep =  getCurrStep()
    local bIsAuto = self.m_bIsAuto

    self.m_autoBtn:setVisible(bIsAuto == false and currStep == 1)
end

----------------------------------------------------------------------
-- function refreshRewardTableview
-- @breif 수동 일때 우측 보상 tableview refresh
----------------------------------------------------------------------
function UI_EventRoulette:refreshRewardTableview()
    self.m_rewardListNode:removeAllChildren()
    self.m_rewardLabel:setString(Str('등장 가능 보상'))

    local target_list = g_eventRouletteData:getItemList()

    local function create_callback(ui, data)
        ui.vars['itemBtn']:registerScriptTapHandler(function() 
            local world_pos = convertToWorldSpace(ui.vars['itemNode'])
            local node_space = convertToNodeSpace(self.m_rewardItemInfo, world_pos)
            self.m_arrowSprite:setPositionY(node_space['y'])

            self:click_rewardItemBtn(ui.m_key)
        end)

        local cell_index = ui:getCellIndex()

        if (not cell_index) then cell_index = data ~= nil and data['cell_idx'] or nil end
        if (not cell_index) then return end

        local icon = g_eventRouletteData:getIcon(cell_index, true)

        ui.vars['itemNode']:addChild(icon)
        ui.m_key = cell_index
    end

    local tableview = UIC_TableView(self.m_rewardListNode)
    tableview:setCellUIClass(UI_EventRouletteRewardItem, create_callback)
    tableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableview:setCellSizeToNodeSize(true)
    tableview:setItemList(target_list, true, true)
end

----------------------------------------------------------------------
-- function createCard
-- @breif 자동화 룰렛 결과 아이템 표시를 위한 UI_ItemCard 생성 메서드
----------------------------------------------------------------------
function UI_EventRoulette:createCard(t_data)
    local item_id = t_data.item_id
    local count = t_data.count
    return UI_ItemCard(item_id, count)
end

----------------------------------------------------------------------
-- function makeAutoResultTable
-- @brief autoResultList를 기반으로 tableviewTD를 생성합니다.
----------------------------------------------------------------------
function UI_EventRoulette:makeAutoResultTable()
    self.m_rewardLabel:setString(Str('획득한 {1}', Str('보상')))

    local rewardListNode = self.m_rewardListNode
    local autoResultList = self.m_lAutoResult

    rewardListNode:removeAllChildren()

    local function make_func(t_data)
        return self:createCard(t_data)
    end

    local function create_func(ui, data)
        ui.root:setScale(0.386)
    end

    local tableviewTD = UIC_TableViewTD(rewardListNode)
    self.m_autoResultTableview = tableviewTD

    tableviewTD.m_cellSize = cc.size(63, 63)
    tableviewTD.m_nItemPerCell = 5
    tableviewTD:setCellCreateInterval(0)
    tableviewTD:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    tableviewTD:setCellCreatePerTick(5)
    tableviewTD:setCellUIClass(make_func, create_func)
    tableviewTD:setItemList(autoResultList)
end

----------------------------------------------------------------------
-- function mergeAutoResultTable
-- @brief 테이블에 리스트를 합친다.
----------------------------------------------------------------------
function UI_EventRoulette:mergeAutoResultTable()
    self.m_autoResultTableview:mergeItemList(self.m_lAutoResult)
end

----------------------------------------------------------------------
-- function addItemToAutoResultList
-- @brief 자동 돌림판 결과 아이템 정보를 리스트에 추가합니다.
----------------------------------------------------------------------
function UI_EventRoulette:addItemToAutoResultList(item_id, count)
    table.insert(self.m_lAutoResult, {item_id = item_id, count = count})
end

----------------------------------------------------------------------
-- function resetAutoResultList
-- @brief 자동 돌림판 결과 아이템 리스트를 초기화 합니다.
----------------------------------------------------------------------
function UI_EventRoulette:resetAutoResultList()
    self.m_lAutoResult = {}
end

----------------------------------------------------------------------
-- function onEnterTab
-- @brief UI_EventPopup에서 onChangeTab마다 불리게 될 function
----------------------------------------------------------------------
function UI_EventRoulette:onEnterTab()
    self:reset_start()
    self:refresh()
end

----------------------------------------------------------------------
-- function updateTimer
----------------------------------------------------------------------
function UI_EventRoulette:updateTimer(dt)
    local str = g_eventRouletteData:getTimeText()
    self.m_timeLabel:setString(str)
end

----------------------------------------------------------------------
-- function createBlockPopup
----------------------------------------------------------------------
function UI_EventRoulette:createBlockPopup()
    local block_ui = UI_BlockPopup()

    self.m_blockUI = nil
    self.m_eventDispatcher = nil
    self.m_eventListener = nil

    local function touch_func(touch, event)
        if self.m_bIsAuto then
            self.m_bIsAuto = false
            cclog('set true')
            self.m_bIsTapBlockPopup = true
        else
            self:skipRoulette()
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()

    if listener and block_ui then
        listener:registerScriptHandler(function() return true end, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(touch_func, cc.Handler.EVENT_TOUCH_ENDED)

        local eventDispatcher = block_ui.root:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, block_ui.root)
        self.m_eventDispatcher = eventDispatcher
        self.m_eventListener = listener

        self.m_bIsSkipped = false
        self.m_blockUI = block_ui
    end
end

----------------------------------------------------------------------
-- function destroyBlockPopup
-- blockPopup 파괴
----------------------------------------------------------------------
function UI_EventRoulette:destroyBlockPopup()
    if self.m_eventDispatcher and self.m_eventListener then
        self.m_eventDispatcher:removeEventListener(self.m_eventListener)
    end

    if self.m_blockUI then
        self.m_blockUI:close()
    end
end

----------------------------------------------------------------------
-- function reset_start
----------------------------------------------------------------------
function UI_EventRoulette:reset_start()
    if (not self.m_startBtns[self.m_currStep]:isVisible())
            and self.m_stopBtn:isVisible() then
        SoundMgr:stopAllEffects()

        self.m_startBtns[self.m_currStep]:setVisible(true)
        self.m_stopBtn:setVisible(false)
        self.m_wheel:setRotation(0)
        self.root:unscheduleUpdate()
    end
end

----------------------------------------------------------------------
-- function autoRoulette
-- @ksjang 2022.04.15
-- @brief 자동 돌림판 시작
-- @param count 돌림판 반복 횟수 (1단계 + 2단계 -> 1회)
----------------------------------------------------------------------
function UI_EventRoulette:autoRoulette(count)
    local function coroutine_function()
        self.m_coroutineHelper = CoroutineHelper()
        self.m_bIsAuto = true
        self.m_bIsTapBlockPopup = false

        local co = self.m_coroutineHelper
        local loop_count = 0

        self:setAutoButtonVisible(false)
        self:makeAutoResultTable()
        self:setIngMenuVisible(true)

        repeat
            self.m_bIsShowRewardPopup = false

            if(getCurrStep() == 1) then
                self:setIngLabel(loop_count + 1, count)
            end

            co:work()

            self:click_startBtn()
            self:click_stopBtn()

            co:waitWork()
            co:work()

            self:skipRoulette()

            if (getCurrStep() == 1) then
                loop_count = loop_count + 1
                local item_id, item_count = g_eventRouletteData:getItemIdAndCount()
                self:addItemToAutoResultList(item_id, item_count)
                self:mergeAutoResultTable()
            end

            co:work()
            co:waitWork()
        until (loop_count == count or (self.m_bIsAuto == false and getCurrStep() == 1))

        UI_ToastPopup(Str('연속 뽑기가 완료되었습니다.'))

        self.m_bIsAuto = false

        self:setAutoButtonVisible(true)
        self:resetAutoResultList()
        self:setIngMenuVisible(false)

        co:close()
        self.m_coroutineHelper = nil
    end

    Coroutine(coroutine_function, 'Roulette start')
end

----------------------------------------------------------------------
-- function click_startBtn
----------------------------------------------------------------------
function UI_EventRoulette:click_startBtn()
    if (self:checkRemainTicket() == false) then
        local msg = Str('이벤트 아이템이 부족합니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg, ok_callback)
        return
    end

    self:setAutoButtonVisible(false)

    SoundMgr:playEffect('EFFECT', 'fever')
    SoundMgr:playEffect('UI', 'ui_target', true)

    self.m_startBtns[self.m_currStep]:setVisible(false)
    self.m_stopBtn:setVisible(true)
    UIHelper:CreateParticle(self.m_stopBtn.m_node)

    local angle = self.m_wheel:getRotation() % 360
    self.m_wheel:setRotation(angle)

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:keepRotateRoulette(dt) end, 0)
end

----------------------------------------------------------------------
-- function click_stopBtn
----------------------------------------------------------------------
function UI_EventRoulette:click_stopBtn()
    
    SoundMgr:playEffect('UI', 'ui_in_item_get')

    -- 패킷 요청 완료 콜백
    local function finish_callback()
        self.root:unscheduleUpdate()
        UIManager:blockBackKey(true)
        self:createBlockPopup()

        self.m_stopBtn:setEnabled(false)

        local current_angle = self.m_wheel:getRotation()
        local rand_cycle = math.random(1, 2)

        local rotate_action = cc.RotateBy:create(2, 3 * 360 + (360 - current_angle))
        self.m_wheel:runAction(rotate_action)

        self.root:scheduleUpdateWithPriorityLua(function(dt) self:adjustRoulette(dt) end, 0)

        if self.m_coroutineHelper then
            local create_cb = function() self.m_coroutineHelper.NEXT() end
            local action = cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(create_cb))
            
            self.root:runAction(action)
        end
    end

    -- 실패 시 팝업 띄우고 로비로 돌아감
    local function fail_cb(ret)
        MakeSimplePopup(POPUP_TYPE.OK, Str('일시적인 오류입니다.\n잠시 후에 다시 시도 해주세요.'), function() UINavigator:goTo('lobby') end)
    end
    
    g_eventRouletteData:request_rouletteStart(
        finish_callback,
        fail_cb
    )
end

----------------------------------------------------------------------
-- function click_autoBtn
-- 룰렛 자동 뽑기 설정 화면 버튼
----------------------------------------------------------------------
function UI_EventRoulette:click_autoBtn()
    -- 인자로 현재 가지고 있는 티켓수, 자동 돌림판 시작 콜백 넣어준다.
    local start_cb = function(count) self:autoRoulette(count) end
    UI_EventRouletteAutoSetting(g_eventRouletteData:getTicketNum(), start_cb)
end

----------------------------------------------------------------------
-- function checkRemainTicket
-- 남은 티켓 확인, return true : 남은 티켓 있음, return false 남은 티켓 없음
----------------------------------------------------------------------
function UI_EventRoulette:checkRemainTicket()
    local currStep = getCurrStep()
    local ticketNum = g_eventRouletteData:getTicketNum()

    return not((currStep == 1) and (ticketNum <= 0))
end

----------------------------------------------------------------------
-- function keepRotateRoulette
-- 룰렛 회전
----------------------------------------------------------------------
function UI_EventRoulette:keepRotateRoulette(dt)
    if (self.m_wheel:getNumberOfRunningActions() == 0) then
        local angle = self.m_wheel:getRotation() % 360
        self.m_wheel:setRotation(angle)
        self.m_wheel:runAction(cc.RotateBy:create(0.5, 360))
    end
end

----------------------------------------------------------------------
-- function stopRoulette
----------------------------------------------------------------------
function UI_EventRoulette:stopRoulette(dt)
    if (self.m_wheel:getNumberOfRunningActions() == 0) then

        SoundMgr:stopAllEffects()
        
        local function disappear_cb()
            self:refresh()
            self.m_appearVisual:changeAni('roulette_disappear', false)
            
            if(self.m_bIsShowRewardPopup == true) then
                g_eventRouletteData:MakeRewardPopup()
            else
                self.m_bIsShowRewardPopup = true
            end

            UIManager:blockBackKey(false)
            self:destroyBlockPopup()

            if self.m_currStep == 2 then
                SoundMgr:playEffect('UI', 'ui_game_start')  -- 바뀔 때
                UIHelper:CreateParticle(self.m_startBtns[self.m_currStep].m_node)
            else
                SoundMgr:playEffect('UI', 'ui_grow_result')
            end

            if (self.m_coroutineHelper) then
                self.m_coroutineHelper.NEXT()
            end
        end

        self.m_itemUIList[g_eventRouletteData:getPickedItemIndex()]:setVisibleReceiveSprite()
        
        local callback = cc.CallFunc:create(function()
            self.m_appearVisual:setVisible(true)
            self.m_appearVisual:changeAni('roulette_appear')
            self.m_appearVisual:addAniHandler(function() disappear_cb() end)
        end)

        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), callback))

    
        self.root:unscheduleUpdate()
    end
end

----------------------------------------------------------------------
-- function skipRoulette
----------------------------------------------------------------------
function UI_EventRoulette:skipRoulette()
    if (self.m_stopBtn:isEnabled() == false) and (self.m_bIsSkipped == false) 
        and (self.m_blockUI) and (self.m_eventListener) then
        self.m_bIsSkipped = true
        self.root:unscheduleUpdate()
        self.m_wheel:stopAllActions()

        local index = g_eventRouletteData:getPickedItemIndex()

        local elementNum = 6
        local gap = 2
        local time = 2

        local angle = 360 / elementNum
        local rand_angle = math.random(0 + gap, angle - gap)

        local target_angle = angle * (index - 1) + rand_angle - angle / 2

        self.m_wheel:setRotation(target_angle)
        self:stopRoulette()

        if (self.m_coroutineHelper) then
            self.m_coroutineHelper:NEXT()
        end
    end
end

----------------------------------------------------------------------
-- function adjustRoulette
----------------------------------------------------------------------
function UI_EventRoulette:adjustRoulette(dt)
    if (self.m_wheel:getNumberOfRunningActions() == 0) then
        self.m_wheel:setRotation(0)
        self.root:unscheduleUpdate()
        local index = g_eventRouletteData:getPickedItemIndex()
        local elementNum = 6
        local gap = 2
        local time = 2

        local angle = 360 / elementNum
        local rand_angle = math.random(0 + gap, angle - gap)

        local target_angle = angle * (index - 1) + rand_angle - angle / 2
        if target_angle <= 180 then 
            target_angle = target_angle + 360 * 2
        else
            target_angle = target_angle + 360
        end
        
        self.m_wheel:runAction(cc.RotateBy:create(time, target_angle))
        self.root:scheduleUpdateWithPriorityLua(function(dt) self:stopRoulette(dt) end, 0)
    end
end

----------------------------------------------------------------------
-- function click_rankBtn
----------------------------------------------------------------------
function UI_EventRoulette:click_rankBtn()
    self:reset_start()
    UI_EventRouletteRankPopup() 
end

----------------------------------------------------------------------
-- function click_infoBtn
----------------------------------------------------------------------
function UI_EventRoulette:click_infoBtn()
    self:reset_start()
    UI_EventRouletteInfoPopup() 
end

----------------------------------------------------------------------
-- function click_packageBtn
----------------------------------------------------------------------
function UI_EventRoulette:click_packageBtn()
    if (not PackageManager:isExist(self.m_packageName)) then
        UIManager:toastNotificationRed(Str('판매가 종료되었습니다.'))
        return
    end
    
    self:reset_start()

    local target_ui = PackageManager:getTargetUI(self.m_packageName, true)
    
    local function buy_cb()
        UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.ITEM, 
        function() 
            g_eventRouletteData:request_rouletteInfo(false, false, function() self:refresh() end)
        end)
    end

    if target_ui then
        target_ui:setBuyCB(buy_cb)
    end
end

----------------------------------------------------------------------
-- function click_rewardItemBtn
----------------------------------------------------------------------
function UI_EventRoulette:click_rewardItemBtn(index)
    if getCurrStep() == 2 then return end
    
    if self.m_targetGroupIndex then
        if (self.m_targetGroupIndex == index) and self.m_rewardItemInfo:isVisible() then
            self.m_rewardItemInfo:setVisible(false)
            self.m_targetGroupIndex = nil
            return
        end
    end

    self.m_rewardItemInfo:setVisible(true)

    self.m_targetGroupIndex = index
    local group_code = g_eventRouletteData:getGroupCodeFromIndex(index)

    local icon
    local count
    local prob
    -- 보상 리스트
    local node_index = 1
    while(self.m_infoItemNodes[node_index]) do
        self.m_infoItemNodes[node_index]:removeAllChildren()

        icon, count, prob = g_eventRouletteData:getRewardIcon(2, group_code, node_index)

        self.m_infoItemNodes[node_index]:addChild(icon)

        self.m_infoItemLabels[node_index]:setString(string.format('%7d', count) .. string.format('%13s', prob))

        node_index = node_index + 1
    end

    -- self.m_infoItemNodes
    -- self.m_infoItemLabels
end