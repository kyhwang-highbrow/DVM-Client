local PARENT = UI

----------------------------------------------------------------------
-- class UI_EventRoulette
-- @brief 
----------------------------------------------------------------------
UI_EventRoulette = class(PARENT, {

    -- TOP
    m_timeLabel = 'UIC_LabelTTF',   -- 남은 시간 텍스트
    m_rankBtn = 'UIC_Button',       -- 랭킹 버튼
    m_infoBtn = 'UIC_Button',       -- 도움말 버튼
    m_closeBtn = 'UIC_Button',      -- 닫기 버튼

    -- Middle Left
    m_rouletteMenues = 'List[cc.Menu]',
    m_startBtns = 'List[UIC_Button]',   -- 시작 버튼
    m_stopBtn = 'UIC_Button',-- 정지 버튼
    m_wheel = 'cc.Menu', -- 돌림판 Sprite & nodes
    m_rouletteVisual = 'AnimatorVrp', -- 돌림판 Sprite
    m_appearVisual = 'AnimatorVrp', -- 연출 Animation
    m_receiveSprite = 'Animator', -- 당첨 표시용 Sprite

    m_itemNodes = 'List[cc.Node]', -- 돌림판 위에 상품 아이콘을 위한 노드

    -- Middle Right
    m_totalScoreLabel = 'UIC_LabelTTF', -- 누적점수
    m_rewardListNode = 'cc.Node',   -- 등장 가능 보상 테이블뷰를 위한 노드

    -- Bottom

    m_packageBtn = 'UIC_Button',    -- 패키지 연결 버튼
    m_ticketNumLabel = 'UIC_LabelTTF', -- 티켓 수량


    -- TEMP
    m_currStep = 'number', -- 현재 step

    m_angular_vel = 'number',
    m_origin_angular_vel = 'number',
    m_angular_accel = 'number',
    m_time = 'number',
    m_packageName = 'string',

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRoulette:init(is_popup)
    local vars = self:load('event_roulette.ui')
    if is_popup == nil or is_popup == false then
        vars['closeBtn']:setVisible(false)
    else
        self.m_uiName = 'UI_EventRoulette'
        UIManager:open(self, UIManager.POPUP)

        g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRoulette')

        self:doActionReset()
        self:doAction(nil, false)
    end

    self:initMember()
    self:initUI()
    self:initButton()
    self:refresh()
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_EventRoulette:initMember()
    local vars = self.vars
    
    self.m_packageName = 'package_roulette'
    self.m_origin_angular_vel = 1000
    self.m_angular_accel = -500
    self.m_time = 0

    -- TOP
    self.m_timeLabel = vars['timeLabel']   -- 남은 시간 텍스트
    self.m_rankBtn = vars['rankBtn']       -- 랭킹 버튼
    self.m_infoBtn = vars['infoBtn']       -- 도움말 버튼
    self.m_closeBtn = vars['closeBtn']      -- 닫기 버튼

    -- Middle Left
    self.m_stopBtn = vars['stopBtn']
    self.m_wheel = vars['wheelMenu'] -- 돌림판 Sprite
    self.m_rouletteVisual = vars['rouletteVisual'] -- 돌림판 Sprite
    self.m_appearVisual = vars['appearVisual'] -- 연출 Animation
    self.m_receiveSprite = vars['receiveSprite'] -- 당첨 표시용 Sprite
    
    self.m_rouletteMenues = {}
    self.m_startBtns = {}
    self.m_itemNodes = {}

    local step = 1
    while(vars['rouletteMenu' .. step]) do
        self.m_rouletteMenues[step] = vars['rouletteMenu' .. step] -- 룰렛
        self.m_startBtns[step] = vars['startBtn' .. step]    -- 시작 버튼
        step = step + 1
    end

    local node_index = 1
    while(vars['itemNode' .. tostring(node_index)]) do
        self.m_itemNodes[node_index] = vars['itemNode' .. tostring(node_index)]
        self.m_itemNodes[node_index]:setRotation(g_eventRouletteData:getAngle(node_index))
        node_index = node_index + 1
    end
    

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
function UI_EventRoulette:initUI()
    -- event_roulette_item.ui
    
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:updateTimer(dt) end, 0)
end

----------------------------------------------------------------------
-- function initRewardTableView
----------------------------------------------------------------------
-- function UI_EventRoulette:initRewardTableView()

--     self.m_rewardListNode:removeAllChildren()

--     local function create_callback(ui, data)

--     end

--     local tableview = UIC_TableView(self.m_rewardListNode)
--     tableview:setCellUIClass(UI_EventRoulette.UI_RewardItem, create_callback)
--     tableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
--     --tableview:set
--     tableview:setItemList(, true)
-- end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_EventRoulette:initButton()

    local step = 1
    while(self.m_rouletteMenues[step]) do 
        self.m_startBtns[step]:registerScriptTapHandler(function()
            self:click_startTest()     
        end)

        step = step + 1
    end

    self.m_stopBtn:registerScriptTapHandler(function()
        self:click_stopTest()     
    end)
    self.m_closeBtn:registerScriptTapHandler(function() 
        self:close() 
    end)
    self.m_rankBtn:registerScriptTapHandler(function() 
        UI_EventRouletteRankPopup() 
    end)
    self.m_infoBtn:registerScriptTapHandler(function() 
        UI_EventRoulette.UI_InfoPopup() 
    end)
    
    self.m_packageBtn:registerScriptTapHandler(function() self:click_packageBtn() end)
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_EventRoulette:refresh()
    self.m_ticketNumLabel:setString(g_eventRouletteData:getTicketNum())
    self.m_totalScoreLabel:setString(g_eventRouletteData:getTotalScore())

    
    self.m_currStep = g_eventRouletteData:getCurrStep()

    local step = 1
    while(self.m_rouletteMenues[step]) do
        self.m_rouletteMenues[step]:setVisible(self.m_currStep == step)
        self.m_startBtns[step]:setVisible(self.m_currStep == step)

        step = step + 1
    end

    local index = 1
    while(self.m_itemNodes[index]) do
        self.m_itemNodes[index]:removeAllChildren()
        local icon = g_eventRouletteData:getIcon(index)
        self.m_itemNodes[index]:addChild(icon)

        index = index + 1
    end

    self.m_receiveSprite:setVisible(false)
    self.m_rouletteVisual:changeAni('roulette_' .. tostring(self.m_currStep), true)

    self:refresh_rewradList()
    self.m_stopBtn:setEnabled(true)
    self.m_stopBtn:setVisible(false)
    self.m_startBtns[self.m_currStep]:setEnabled(true)
end

function UI_EventRoulette:refresh_TextLabels()
    
end

function UI_EventRoulette:refresh_roulette()

end


function UI_EventRoulette:refresh_rewradList()
    
    
    self.m_rewardListNode:removeAllChildren()
    local target_list = g_eventRouletteData:getItemList()

    local function create_callback(ui, data)

    end
    
    local tableview = UIC_TableView(self.m_rewardListNode)
    tableview:setCellUIClass(UI_EventRoulette.UI_RewardItem, create_callback)
    tableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableview:setCellSizeToNodeSize()
    --tableview:setAlignCenter(true)
    tableview:setItemList(target_list, true)
end

----------------------------------------------------------------------
-- function updateTimer
----------------------------------------------------------------------
function UI_EventRoulette:updateTimer(dt)

    local str = g_eventRouletteData:getTimeText()
    self.m_timeLabel:setString(str)
end


----------------------------------------------------------------------
-- function keepRotateRoulette
----------------------------------------------------------------------
function UI_EventRoulette:keepRotateRoulette(dt)
    if (self.m_wheel:getNumberOfRunningActions() == 0) then
        local angle = self.m_wheel:getRotation() % 360
        self.m_wheel:setRotation(angle)
        self.m_wheel:runAction(cc.RotateBy:create(0.7, 360))
    end
end

----------------------------------------------------------------------
-- function AdjustRoulette
----------------------------------------------------------------------
function UI_EventRoulette:AdjustRoulette(dt)
    if (self.m_wheel:getNumberOfRunningActions() == 0) then
        self.m_wheel:setRotation(0)
        self.root:unscheduleUpdate()
        local index = g_eventRouletteData:getPickedItemIndex()
        local elementNum = 8
        local gap = 2

        local angle = 360 / elementNum
        local rand_angle = math.random(0 + gap, angle - gap)

        local target_angle = angle * (index - 1) + rand_angle + 360
        self.m_wheel:runAction(cc.RotateBy:create(3, target_angle))

        
        cclog('index : ' .. tostring(index))
        cclog('angle : ' .. tostring(target_angle))
        cclog('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@')
        self.root:scheduleUpdateWithPriorityLua(function(dt) self:StopRoulette(dt) end, 0)
    end
end

----------------------------------------------------------------------
-- function StopRoulette
----------------------------------------------------------------------
function UI_EventRoulette:StopRoulette(dt)
    if (self.m_wheel:getNumberOfRunningActions() == 0) then
        self.m_receiveSprite:setVisible(true)

        function disappear_cb()
            self.m_appearVisual:changeAni('roulette_disappear', false)
            
        end
        self.m_appearVisual:setVisible(true)
        self.m_appearVisual:changeAni('roulette_appear')
        self.m_appearVisual:addAniHandler(function() disappear_cb() end)

        -- local cb = cc.CallFunc:create(function() 
        --     g_eventRouletteData:MakeRewardPopup()
        --     self:refresh()
        --     self.root:unscheduleUpdate()
        -- end)
        g_eventRouletteData:MakeRewardPopup()
        self:refresh()
        self.root:unscheduleUpdate()

        -- cc.CallFunc:create()
        
        -- cc.Sequence()
    end
end


----------------------------------------------------------------------
-- function click_startTest
----------------------------------------------------------------------
function UI_EventRoulette:click_startTest()
    
    -- 첫번째 룰렛에서 재료가 모자른 경우
    if (g_eventRouletteData:getCurrStep() == 1) and (g_eventRouletteData:getTicketNum() <= 0) then
        local msg = Str('이벤트 아이템이 부족합니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg, ok_callback)
        return
    end

    self.m_startBtns[self.m_currStep]:setVisible(false)
    self.m_stopBtn:setVisible(true)

    local angle = self.m_wheel:getRotation() % 360
    self.m_wheel:setRotation(angle)

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:keepRotateRoulette(dt) end, 0)
end

----------------------------------------------------------------------
-- function click_startTest
----------------------------------------------------------------------
function UI_EventRoulette:click_stopTest()
    local function finish_callback()
        self.m_stopBtn:setEnabled(false)

        self.root:unscheduleUpdate()

        local current_angle = self.m_wheel:getRotation()
        local rand_cycle = math.random(1, 2)
        cclog('rand_cycle : ' .. tostring(rand_cycle))
        cclog('adjust angle : ' .. tostring(rand_cycle * 360 + (360 - current_angle)))
        local rotate_action = cc.RotateBy:create(2, rand_cycle * 360 + (360 - current_angle))
        self.m_wheel:runAction(rotate_action)

        self.root:scheduleUpdateWithPriorityLua(function(dt) self:AdjustRoulette(dt) end, 0)
    end

    local function fail_cb(ret)
        UINavigator:goTo('lobby')
    end
    
    g_eventRouletteData:request_rouletteStart(
        finish_callback,
        fail_cb
    )
   -- finish_callback()
end


----------------------------------------------------------------------
-- function click_packageBtn
----------------------------------------------------------------------
function UI_EventRoulette:click_packageBtn()

    local target_ui = PackageManager:getTargetUI(self.m_packageName, true)
    local function buy_cb()
        UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.ITEM, 
        function() 
            g_eventRouletteData:request_rouletteInfo(false, false, function() self:refresh() end)
        end)
    end
    target_ui:setBuyCB(buy_cb)

end






--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  class UI_EventRoulette.UI_RewardItem
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_EventRoulette.UI_RewardItem = class(class(UI, ITableViewCell:getCloneTable()), {

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRoulette.UI_RewardItem:init(data)
    local vars = self:load('event_roulette_item.ui')

    --local icon = g_eventRouletteData:getIcon()
    --vars['itemNode']

    if (data['val'] == nil) or (data['val'] == '') then
        vars['countLabel']:setString(Str(data['item_name']))
    else
        vars['countLabel']:setString(Str(comma_value(data['val'])))
    end
    
    vars['probLabel']:setString(Str(data['real_weight']))
    
    -- vars['itemMenu']
    -- vars['itemNode']
    -- vars['countLabel']
    -- vars['probLabel']
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  UI_EventRoulette.UI_InfoPopup
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_EventRoulette.UI_InfoPopup = class(UI, {

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRoulette.UI_InfoPopup:init()
    local vars = self:load('event_roulette_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRoulette.UI_InfoPopup')    

    self.m_uiName = 'UI_EventRoulette.UI_InfoPopup'  

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

