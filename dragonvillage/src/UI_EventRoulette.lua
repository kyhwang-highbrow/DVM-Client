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

    -- Middle Left
    m_startBtn = 'UIC_Button',      -- 시작 버튼
    m_stopBtn = 'UIC_Button',       -- 정지 버튼
    m_closeBtn = 'UIC_Button',      -- 닫기 버튼
    
    m_rouletteSprite = 'Animator',  -- 돌림판 Sprite

    -- Middle Right
    m_totalScoreLabel = 'UIC_LabelTTF', -- 누적점수
    m_rewardListNode = 'cc.Node',   -- 등장 가능 보상 테이블뷰를 위한 노드

    -- Bottom
    m_packageBtn = 'UIC_Button',    -- 패키지 연결 버튼
    m_ticketNumLabel = 'UIC_LabelTTF', -- 티켓 수량


    -- TEMP
    m_angular_vel = 'number',
    m_angular_accel = 'number',
    m_time = 'number',
    m_packageName = 'string',

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRoulette:init()
    self.m_uiName = 'UI_EventRoulette'
    local vars = self:load('event_roulette.ui')
    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRoulette')
    self:doActionReset()
    self:doAction(nil, false)

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
    self.m_angular_vel = 500
    self.m_angular_accel = -100
    self.m_time = 0

    -- TOP
    self.m_timeLabel = vars['timeLabel']   -- 남은 시간 텍스트
    self.m_rankBtn = vars['rankBtn']       -- 랭킹 버튼
    self.m_infoBtn = vars['infoBtn']       -- 도움말 버튼

    -- Middle Left
    self.m_startBtn = vars['startBtn']      -- 시작 버튼
    self.m_stopBtn = vars['stopBtn']       -- 정지 버튼
    self.m_closeBtn = vars['closeBtn']      -- 닫기 버튼
    
    self.m_rouletteSprite = vars['rouletteSprite']   -- 돌림판 Sprite

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
-- function initButton
----------------------------------------------------------------------
function UI_EventRoulette:initButton()
    self.m_startBtn:registerScriptTapHandler(function() 
        self:click_startBtn() 
    end)
    self.m_stopBtn:registerScriptTapHandler(function() 
        self:click_stopBtn() 
    end)

    self.m_closeBtn:registerScriptTapHandler(function() 
        self:close() 
    end)
    self.m_rankBtn:registerScriptTapHandler(function() 
        UI_EventRoulette.UI_RankPopup() 
    end)
    self.m_infoBtn:registerScriptTapHandler(function() 
        UI_EventRoulette.UI_InfoPopup() 
    end)
    self.m_packageBtn:registerScriptTapHandler(function() 
        PackageManager:getTargetUI(self.m_packageName, true)
    end)
end

-- 1. Start를 누름 (일정한 속도로 계속 돌아감) 

-- 2. Stop을 누름 (360 - 현재 각도) + 일정한 바퀴수 + rand()


----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_EventRoulette:refresh()
    self.m_ticketNumLabel:setString(g_eventRouletteData:getTicketNum())
    self.m_totalScoreLabel:setString(g_eventRouletteData:getTotalScore())
end

----------------------------------------------------------------------
-- function updateTimer
----------------------------------------------------------------------
function UI_EventRoulette:updateTimer(dt)

    local str = g_eventRouletteData:getTimeText()
    self.m_timeLabel:setString(str)
end




----------------------------------------------------------------------
-- function click_startBtn
----------------------------------------------------------------------
function UI_EventRoulette:click_startBtn()
    self.m_startBtn:setVisible(false)
    self.m_stopBtn:setVisible(true)

    self.m_rouletteSprite:setRotation(self.m_rouletteSprite:getRotation() % 360)
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:Test1(dt) end, 0)

    -- self.m_rouletteSprite:stopAllActions()
    -- self.m_rouletteSprite:setRotation(self.m_rouletteSprite:getRotation() % 360)
    -- ccdump(self.m_rouletteSprite:getRotation())
    -- local rand_angle = math.random(0, 360)
    -- local rot1 = cc.RotateBy:create(2, 2880 + rand_angle)
    -- self.m_rouletteSprite:runAction(rot1)
    --ccdump(self.m_rouletteSprite:getRotation())
end


----------------------------------------------------------------------
-- function click_stopBtn
----------------------------------------------------------------------
function UI_EventRoulette:click_stopBtn()
    self.m_stopBtn:setVisible(false)
    self.m_startBtn:setVisible(true)

    self.root:unscheduleUpdate()
    --self.m_rouletteSprite:setRotation(0)
    self.m_time = 0
    self.m_rouletteSprite:setRotation(self.m_rouletteSprite:getRotation() % 360)
    
    cclog('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@')
    cclog(self.m_rouletteSprite:getRotation())

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:Test2(dt) end, 0)
    --self:stopSpinningRoulette()
end








----------------------------------------------------------------------
-- function click_stopBtn
----------------------------------------------------------------------
function UI_EventRoulette:keepSpinningRoulette(dt)
    if self.m_rouletteSprite:getNumberOfRunningActions() == 0 then
    self.m_rouletteSprite:runAction(cc.RotateBy:create(0.7, 360))
    end
end

----------------------------------------------------------------------
-- function click_stopBtn
----------------------------------------------------------------------
function UI_EventRoulette:Test1(dt)
    self.m_angular_vel = 500
    local rot = self.m_rouletteSprite:getRotation()
    self.m_rouletteSprite:setRotation(rot + self.m_angular_vel * dt)
end

----------------------------------------------------------------------
-- function click_stopBtn
----------------------------------------------------------------------
function UI_EventRoulette:Test2(dt) 
    self.m_time = self.m_time + dt
    self.m_angular_vel = self.m_angular_vel + self.m_angular_accel * dt

    local rot = self.m_rouletteSprite:getRotation()
    self.m_rouletteSprite:setRotation(rot + self.m_angular_vel * dt)

    if (self.m_angular_vel <= 0) then
        ccdump('total : ' .. self.m_rouletteSprite:getRotation())
        ccdump('actual : ' .. self.m_rouletteSprite:getRotation() % 360)
        
        ccdump('time : ' .. self.m_time)
        self.root:unscheduleUpdate()
    end
end

----------------------------------------------------------------------
-- function click_stopBtn
----------------------------------------------------------------------
function UI_EventRoulette:stopSpinningRoulette(dt)
    --local cycle = 360 * 3
    self.m_rouletteSprite:setRotation(self.m_rouletteSprite:getRotation() % 360)
    self.m_rouletteSprite:stopAllActions()
    local angle = 360 - self.m_rouletteSprite:getRotation()
    self.m_rouletteSprite:runAction(cc.RotateBy:create(0.7, angle + 360 * 3 + 270))
    --ccdump(self.m_rouletteSprite:getRotation())

end


-- local rot1 = cc.RotateBy:create(2, -2880)
-- local rot2 = cc.RotateBy:create(3, -1800)
-- local rot3 = cc.RotateBy:create(3, -720)
-- local rot4 = cc.RotateBy:create(3, -270)
-- local test = cc.Sequence:create(cc.Sequence:create(cc.Sequence:create(rot1, rot2), rot3), rot4)
-- if vars['quickBtn'] ~= nil then
--     vars['quickBtn']:runAction(test)
-- end


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
--//  UI_EventRoulette.UI_RankPopup
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_EventRoulette.UI_RankPopup = class(UI, {
    m_dailyBtn = 'UIC_Button',
    m_dailyMenu = 'cc.Menu', 
    m_totalBtn = 'UIC_Button',
    m_totalMenu = 'cc.Menu', 
    m_sortBtn = 'UIC_Button',
})


----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRoulette.UI_RankPopup:init()
    local vars = self:load('event_roulette_ranking_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRoulette.UI_RankPopup')

    self.m_uiName = 'UI_EventRoulette.UI_RankPopup'

    self.m_dailyBtn = vars['dailyTabBtn']
    self.m_dailyMenu = vars['dailyMenu']
    self.m_totalBtn = vars['totalTabBtn']
    self.m_totalMenu = vars['totalMenu']
    self.m_sortBtn = vars['sortBtn']


    self:init_sortList()

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    self.m_dailyBtn:registerScriptTapHandler(function() self:click_dailyBtn() end)
    self.m_totalBtn:registerScriptTapHandler(function() self:click_totalBtn() end)
end

----------------------------------------------------------------------
-- function init_sortList
----------------------------------------------------------------------
function UI_EventRoulette.UI_RankPopup:init_sortList()
    local width, height = self.m_sortBtn:getNormalSize()
    local parent = self.m_sortBtn:getParent()
    local x, y = self.m_sortBtn:getPosition()

    local sort_list = UIC_SortList()

    sort_list.m_direction = UIC_SORT_LIST_TOP_TO_BOT
    sort_list:setNormalSize(width, height)
    sort_list:setPosition(x, y)
    sort_list:setDockPoint(self.m_sortBtn:getDockPoint())
    sort_list:setAnchorPoint(self.m_sortBtn:getAnchorPoint())
    sort_list:init_container()

    sort_list:setExtendButton(self.m_sortBtn)
    sort_list:setSortTypeLabel(self.vars['sortLabel'])

    parent:addChild(sort_list.m_node)


    sort_list:addSortType('my', Str('내 랭킹'))
    sort_list:addSortType('top', Str('최상위 랭킹'))
    sort_list:addSortType('friend', Str('친구 랭킹'))
    sort_list:addSortType('clan', Str('클랜원 랭킹'))

    sort_list:setSortChangeCB(function(sort_type) self:onChangeSortType(sort_type) end)
end

----------------------------------------------------------------------
-- function onChangeSortType
----------------------------------------------------------------------
function UI_EventRoulette.UI_RankPopup:onChangeSortType(sort_type)
    
    if (sort_type == 'clan' and g_clanData:isClanGuest()) then
        local msg = Str('소속된 클랜이 없습니다.')
        UIManager:toastNotificationRed(msg)
        return
    end
end

----------------------------------------------------------------------
-- function onChangeSortType
----------------------------------------------------------------------
function UI_EventRoulette.UI_RankPopup:click_dailyBtn()
    self.m_dailyMenu:setVisible(true)
    self.m_totalMenu:setVisible(false)

end

function UI_EventRoulette.UI_RankPopup:click_totalBtn()
    self.m_dailyMenu:setVisible(false)
    self.m_totalMenu:setVisible(true)

end