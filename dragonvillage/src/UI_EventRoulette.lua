local PARENT = UI

----------------------------------------------------------------------
-- class UI_EventRoulette
-- @brief 
----------------------------------------------------------------------
UI_EventRoulette = class(PARENT, {
    m_blockUI = 'UI_BlockPopup', 
    m_targetAngle = 'number',
    m_bIsSkipped = 'boolean',

    -- TOP
    m_timeLabel = 'UIC_LabelTTF',   -- 남은 시간 텍스트
    m_rankBtn = 'UIC_Button',       -- 랭킹 버튼
    m_infoBtn = 'UIC_Button',       -- 도움말 버튼
    m_closeBtn = 'UIC_Button',      -- 닫기 버튼

    -- Middle Left
    m_rouletteMenues = 'List[cc.Menu]', -- 
    m_startBtns = 'List[UIC_Button]',   -- 시작 버튼
    m_stopBtn = 'UIC_Button',-- 정지 버튼
    m_wheel = 'cc.Menu', -- 돌림판 Sprite & nodes
    m_rouletteVisual = 'AnimatorVrp', -- 돌림판 Sprite
    m_appearVisual = 'AnimatorVrp', -- 연출 Animation

    m_itemUIList = 'List[UI_EventRoulette.UI_RouletteItem]', -- 돌림판 위에 상품 표기를 위한 Item UI 리스트
    m_itemNodeList = 'List[cc.Node]', -- 돌림판 위에 상품 표기를 위한 Item Node 리스트

    m_rewardItemInfo = 'cc.Node', -- 2단계 상품의 상세 확률 표시를 위한 그룹 노드 (메뉴로 바꾸는게 좋을 듯)
    m_infoItemNodes = 'List[cc.Node]', -- 2단계 상품의 상세 확률 표시를 위한 노드 리스트
    m_infoItemLabels = 'List[UIC_LabelTTF', -- 2단계 상품의 상세 확률 표시를 위한 텍스트 리스트
    m_arrowSprite = 'Animator', -- 2단계 상세 확률을 가리키는 Sprite
    m_targetGroupIndex = 'number', -- 현재 보여주고 있는 2단계 상품의 그룹 index

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
    m_eventDispatcher = '',
    m_eventListener = '',

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRoulette:init(is_popup)
    local vars = self:load('event_roulette.ui')

    if (not is_popup) then
        vars['closeBtn']:setVisible(false)
    else
        self.m_uiName = 'UI_EventRoulette'
        UIManager:open(self, UIManager.POPUP)

        g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRoulette')

        self:doActionReset()
        self:doAction(nil, false)
    end

    self:initMember(is_popup)
    self:initUI()
    self:initButton()
    self:refresh()

    --SoundMgr:playEffect('UI', 'ui_in_item_get') -- 버튼
    --SoundMgr:playEffect('UI', 'ui_eat') -- 애매. 부글부글

    --SoundMgr:playEffect('EFFECT', 'fever')
    --SoundMgr:playEffect('UI', 'ui_dragon_level_up')


    
    --SoundMgr:playEffect('UI', 'ui_game_start')  -- 바뀔 때
    
    --SoundMgr:playEffect('UI', 'ui_grow_result') -- 보상 획득
    g_eventRouletteData:MakeRankingRewardPopup()

    SoundMgr:playBGM('bgm_event_roulette')

    local function onNodeEvent(event)   
        
        if event == 'exit' then
            self:onDestroy()
        end        
    end

    self.root:registerScriptHandler(onNodeEvent)
end

function UI_EventRoulette:createBlockPopup(is_popup)
    if not self.m_blockUI then
        local masking_ui = UI_BlockPopup()
        local function touch_func(touch, event)
            self:SkipRoulette()
        end
        
        if (is_popup) then
            g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_BlockPopup')
        end

        local layer = cc.Layer:create()
        masking_ui.root:addChild(layer, -100)

        local listener = cc.EventListenerTouchOneByOne:create()

        listener:registerScriptHandler(function() return true end, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(touch_func, cc.Handler.EVENT_TOUCH_ENDED)

        local eventDispatcher = layer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
        self.m_eventDispatcher = eventDispatcher
        self.m_eventListener = listener
        masking_ui:setVisible(false)
        self.m_blockUI = masking_ui
        self.m_bIsSkipped = false
    end
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_EventRoulette:initMember(is_popup)
    local vars = self.vars
    
    self.m_packageName = 'package_roulette'
    self.m_origin_angular_vel = 1000
    self.m_angular_accel = -500
    self.m_time = 0

    --self.m_blockUI = UI_BlockPopup()
    -- 팝업 이름이 덮어씌워지는 현상 수정
    --self.m_blockUI.m_uiName = 'UI_EventRoulette'

    --self.m_blockUI = UI_BlockPopup()
    self:createBlockPopup(is_popup)


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
    self.m_appearVisual:setTimeScale(2)
    
    self.m_rouletteMenues = {}
    self.m_startBtns = {}

    -- self.m_itemNodes = {}
    -- self.m_itemLabels = {}
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
    while(vars['itemNode' .. tostring(node_index)]) do
        -- 돌림판
        self.m_itemNodeList[node_index] = vars['itemNode' .. tostring(node_index)]

        local ui = UI_EventRoulette.UI_Item(node_index)
        self.m_itemUIList[node_index] = ui

        self.m_itemNodeList[node_index]:addChild(ui.root)
        self.m_itemNodeList[node_index]:setRotation(g_eventRouletteData:getAngle(node_index))

        -- 보상 리스트
        self.m_infoItemNodes[node_index] = vars['infoItemNode' .. tostring(node_index)]
        self.m_infoItemLabels[node_index] = vars['infoItemLabel' .. tostring(node_index)]

        node_index = node_index + 1
    end
    self.m_arrowSprite = vars['arrowSprite']
    self.m_rewardItemInfo = vars['rewardInfoNode']
    

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
            self:click_startBtn()     
            --self:test_stopBtn()
        end)

        step = step + 1
    end

    self.m_stopBtn:registerScriptTapHandler(function()
        self:click_stopBtn()     
        --self:test_stopBtn()
    end)
    self.m_closeBtn:registerScriptTapHandler(function() 
        self:close() 
    end)
    self.m_rankBtn:registerScriptTapHandler(function() 
        self:reset_start()
        UI_EventRouletteRankPopup() 
    end)
    self.m_infoBtn:registerScriptTapHandler(function() 
        self:reset_start()
        UI_EventRoulette.UI_InfoPopup() 
    end)

    self.m_packageBtn:registerScriptTapHandler(function() self:click_packageBtn() end)
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_EventRoulette:refresh()
    self.m_ticketNumLabel:setString(g_eventRouletteData:getTicketNum())
    self.m_totalScoreLabel:setString(Str('{1}점', g_eventRouletteData:getTotalScore()))

    
    self.m_currStep = g_eventRouletteData:getCurrStep()

    local step = 1
    while(self.m_rouletteMenues[step]) do
        self.m_rouletteMenues[step]:setVisible(self.m_currStep == step)
        self.m_startBtns[step]:setVisible(self.m_currStep == step)

        step = step + 1
    end

    local index = 1
    while(self.m_itemUIList[index]) do
        self.m_itemUIList[index]:refresh()
        
        index = index + 1
    end

    self.m_rewardItemInfo:setVisible(false)
    self.m_rouletteVisual:changeAni('roulette_' .. tostring(self.m_currStep), true)

    self:refresh_rewradList()
    self.m_stopBtn:setEnabled(true)
    self.m_bIsSkipped = false
    self.m_stopBtn:setVisible(false)
    self.m_startBtns[self.m_currStep]:setEnabled(true)

    self.m_wheel:setRotation(0)
end

function UI_EventRoulette:refresh_TextLabels()
    
end

function UI_EventRoulette:refresh_roulette()

end


function UI_EventRoulette:refresh_rewradList()
    
    
    self.m_rewardListNode:removeAllChildren()
    local target_list = g_eventRouletteData:getItemList()

    local function create_callback(ui, data)
        ui.vars['itemBtn']:registerScriptTapHandler(function() 
            local world_pos = convertToWorldSpace(ui.vars['itemNode'])
            local node_space = convertToNodeSpace(self.m_rewardItemInfo, world_pos)
            self.m_arrowSprite:setPositionY(node_space['y'])

            self:click_rewardItemBtn(ui.m_key) 
        end)
    end
    
    local tableview = UIC_TableView(self.m_rewardListNode)
    tableview:setCellUIClass(UI_EventRoulette.UI_RewardItem, create_callback)
    tableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableview:setCellSizeToNodeSize(true)
    --tableview:setAlignCenter(true)
    tableview:setItemList(target_list, true)
end


-------------------------------------
-- function onDestroyUI
-- @brief
-------------------------------------
function UI_EventRoulette:onDestroy()
    SoundMgr:playBGM('bgm_lobby')
    SoundMgr:stopAllEffects()
    
    self.m_eventDispatcher:removeEventListener(self.m_eventListener)
    
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventRoulette:onEnterTab()
    self:refresh()
end

----------------------------------------------------------------------
-- function updateTimer
----------------------------------------------------------------------
function UI_EventRoulette:updateTimer(dt)

    local str = g_eventRouletteData:getTimeText()
    self.m_timeLabel:setString(str)
end

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
-- function click_startBtn
----------------------------------------------------------------------
function UI_EventRoulette:click_startBtn()
   
    -- 첫번째 룰렛에서 재료가 모자른 경우
    if (g_eventRouletteData:getCurrStep() == 1) and (g_eventRouletteData:getTicketNum() <= 0) then
        local msg = Str('이벤트 아이템이 부족합니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg, ok_callback)
        return
    end

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
-- function keepRotateRoulette
----------------------------------------------------------------------
function UI_EventRoulette:keepRotateRoulette(dt)
    if (self.m_wheel:getNumberOfRunningActions() == 0) then
        local angle = self.m_wheel:getRotation() % 360
        self.m_wheel:setRotation(angle)
        self.m_wheel:runAction(cc.RotateBy:create(0.5, 360))
    end
end

----------------------------------------------------------------------
-- function click_stopBtn
----------------------------------------------------------------------
function UI_EventRoulette:click_stopBtn()

    SoundMgr:playEffect('UI', 'ui_in_item_get')

    local function finish_callback()
        self.root:unscheduleUpdate()

        self.m_blockUI:setVisible(true)

        UIManager:blockBackKey(true)
        self.m_stopBtn:setEnabled(false)

        local current_angle = self.m_wheel:getRotation()
        local rand_cycle = math.random(1, 2)

        local rotate_action = cc.RotateBy:create(2, 3 * 360 + (360 - current_angle))
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
end

function UI_EventRoulette:SkipRoulette()
    if self.m_stopBtn:isEnabled() == false and self.m_bIsSkipped == false then
        self.m_bIsSkipped = true
        self.root:unscheduleUpdate()
        self.m_wheel:stopAllActions()

        local index = g_eventRouletteData:getPickedItemIndex()
        -- local step = g_eventRouletteData:getCurrStep()
        -- local key = g_eventRouletteData.m_rouletteInfo['picked_id']
        -- local index = g_eventRouletteData.m_probIndexKeyList[key]

        local elementNum = 8
        local gap = 2
        local time = 2

        local angle = 360 / elementNum
        local rand_angle = math.random(0 + gap, angle - gap)

        local target_angle = angle * (index - 1) + rand_angle - angle / 2

        self.m_wheel:setRotation(target_angle)
        self:StopRoulette()
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
        self.root:scheduleUpdateWithPriorityLua(function(dt) self:StopRoulette(dt) end, 0)
    end
end

----------------------------------------------------------------------
-- function StopRoulette
----------------------------------------------------------------------
function UI_EventRoulette:StopRoulette(dt)
    if (self.m_wheel:getNumberOfRunningActions() == 0) then

        SoundMgr:stopAllEffects()
        
        local function disappear_cb()
            self:refresh()
            self.m_appearVisual:changeAni('roulette_disappear', false)
            g_eventRouletteData:MakeRewardPopup()
            
            self.m_blockUI:setVisible(false)

            UIManager:blockBackKey(false)

            if self.m_currStep == 2 then
                SoundMgr:playEffect('UI', 'ui_game_start')  -- 바뀔 때
                UIHelper:CreateParticle(self.m_startBtns[self.m_currStep].m_node)
            else
                SoundMgr:playEffect('UI', 'ui_grow_result')
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
    if g_eventRouletteData:getCurrStep() == 2 then return end
    
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


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  class UI_EventRoulette.UI_Item
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_EventRoulette.UI_Item = class(UI, {
    m_index = 'number',
    m_receiveSprite = 'Animator',
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRoulette.UI_Item:init(index)
    local vars = self:load('event_roulette_reward_item.ui')
    self.m_index = index
    self.m_receiveSprite = vars['receiveSprite']

    self:refresh()
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_EventRoulette.UI_Item:refresh()
    self.vars['itemNode']:removeAllChildren()
    self.m_receiveSprite:setVisible(false)

    local count
    local icon 
    icon, count = g_eventRouletteData:getIcon(self.m_index)
    if (g_eventRouletteData:getCurrStep() == 1) then
        icon:setColor(cc.c3b(150, 150, 150))
    end

    --icon:setContentSize(self.vars['itemNode']:getContentSize())
    --icon:setContentSize(0.5)
    

    self.vars['itemNode']:addChild(icon)
    self.vars['itemLabel']:setString(tostring(count))
end

----------------------------------------------------------------------
-- function setVisibleReceiveSprite
----------------------------------------------------------------------
function UI_EventRoulette.UI_Item:setVisibleReceiveSprite(isVisible)
    if (not isVisible) then isVisible = true end
    self.m_receiveSprite:setVisible(isVisible)
end




--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  class UI_EventRoulette.UI_RewardItem
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_EventRoulette.UI_RewardItem = class(class(UI, ITableViewCell:getCloneTable()), {
    m_key = 'number',
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRoulette.UI_RewardItem:init(data, key)
    self.m_key = key
    local vars = self:load('event_roulette_item.ui')

    local icon = g_eventRouletteData:getIcon(key, true)

    vars['itemNode']:addChild(icon)

    if (data['val'] == nil) or (data['val'] == '') then
        vars['countLabel']:setString(Str(data['item_name']))
    else
        vars['countLabel']:setString(Str(string.format('%5d', data['val'])))
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




--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  UI_EventRoulette.UI_RewardPopup
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_EventRoulette.UI_RewardPopup = class(UI, {

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRoulette.UI_RewardPopup:init(reward_table)
    local vars = self:load('event_roulette_popup_reward.ui')
    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRoulette.UI_RewardPopup')    

    self.m_uiName = 'UI_EventRoulette.UI_RewardPopup'  

    vars['okBtn']:registerScriptTapHandler(function() self:close() end)    


    if (reward_table) then
        local msg
        -- score
        if reward_table['bonus_score'] and (reward_table['bonus_score'] ~= '') then
            msg = Str('대박 점수: {1}점', reward_table['bonus_score'])
        elseif reward_table['score'] and (reward_table['score'] ~= '') then
            msg = Str('점수: {1}점', reward_table['score'])
        else
            msg = ''
        end

        -- item
        if reward_table['mail_item_info'] then
            local id = reward_table['mail_item_info']['item_id']
            local count = reward_table['mail_item_info']['count']
            local item_card = UI_ItemCard(id, count)

            if item_card then
                vars['itemNode']:addChild(item_card.root)
            end
        end

        vars['scoreLabel']:setString(msg)

        g_highlightData:setHighlightMail()

    end
end

