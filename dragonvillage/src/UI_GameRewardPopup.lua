local PARENT = UI

-------------------------------------
-- class UI_GameRewardPopup
-------------------------------------
UI_GameRewardPopup = class(PARENT, {
        m_currStep = 'number',
        m_timer = 'number',
        m_lDropItemList = 'list',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GameRewardPopup:init(l_drop_item_list)
    self.m_currStep = 0
    self.m_timer = 3
    self.m_lDropItemList = l_drop_item_list

    local vars = self:load('ingame_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    --self:doActionReset()
    --self:doAction()

    vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end)
    vars['retryBtn']:registerScriptTapHandler(function() self:click_retryBtn() end)
    vars['backBtn']:registerScriptTapHandler(function() self:click_backBtn() end)

    vars['boxBtn']:registerScriptTapHandler(function() self:step2() end)

    self:step1()

    --  업데이트 스케쥴러 등록
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backBtn() end, 'UI_GameRewardPopup')
end


-------------------------------------
-- function update
-------------------------------------
function UI_GameRewardPopup:update(dt)
    if (self.m_currStep == 1) then
        self.m_timer = (self.m_timer - dt)

        if (self.m_timer <= 0) then
            self:step2()
        else
            local str = math_floor(self.m_timer + 0.5)
            self.vars['timeLabel']:setString(Str('{1}초 후 상자 자동 개봉', str))
        end
    end
end

-------------------------------------
-- function step1
-------------------------------------
function UI_GameRewardPopup:step1()
    if (0 ~= self.m_currStep) then
        return
    end
    self.m_currStep = 1

    local vars = self.vars

    vars['rewardNode1']:setVisible(false)
    vars['rewardNode2']:setVisible(false)
    vars['rewardNode3']:setVisible(false)

    vars['nextBtn']:setVisible(false)
    vars['retryBtn']:setVisible(false)
    vars['backBtn']:setVisible(false)

    vars['skipLabel']:setVisible(true)
    vars['timeLabel']:setVisible(true)
    vars['boxVisual']:setVisible(true)    

    vars['boxVisual']:setVisual('group', 'ui_box_rainbow_idle')
    vars['boxVisual']:setRepeat(true)
    --ui_box_rainbow_idle
    --ui_box_rainbow_open
end

-------------------------------------
-- function step2
-------------------------------------
function UI_GameRewardPopup:step2()
    if (1 ~= self.m_currStep) then
        return
    end
    self.m_currStep = 2

    local vars = self.vars
    vars['boxVisual']:setVisual('group', 'ui_box_rainbow_open')
    vars['boxVisual']:setRepeat(false)

    vars['boxVisual']:registerScriptLoopHandler(function() self:step3() end)

    vars['skipLabel']:setVisible(false)
    vars['timeLabel']:setVisible(false)
end

-------------------------------------
-- function step3
-------------------------------------
function UI_GameRewardPopup:step3()
    if (2 ~= self.m_currStep) then
        return
    end
    self.m_currStep = 3

    local vars = self.vars

    for i,v in ipairs(self.m_lDropItemList) do
        self:makeRewardItem(i, v)
    end

    SoundMgr:playEffect('EFFECT', 'reward')

    vars['boxVisual']:unregisterScriptLoopHandler()
    vars['boxVisual']:setVisible(false)

    vars['nextBtn']:setVisible(true)
    vars['retryBtn']:setVisible(true)
    vars['backBtn']:setVisible(true)
end

-------------------------------------
-- function makeRewardItem
-------------------------------------
function UI_GameRewardPopup:makeRewardItem(i, v)
    local vars = self.vars

    local item_id = v[1]
    local count = v[2]

    local item_card = UI_ItemCard(item_id, 0)
    item_card:setRarityVisibled(true)

    local icon = item_card.root--DropHelper:getItemIconFromIID(item_id)
    vars['rewardNode' .. i]:setVisible(true)
    vars['rewardIconNode' .. i]:addChild(icon)

    local table_item = TABLE:get('item')
    local t_item = table_item[item_id]
    
    vars['rewardLabel' .. i]:setString(t_item['t_name'] .. '\nX ' .. count)
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameRewardPopup:click_nextBtn()
    local scene = SceneAdventure()
    scene:runScene()
end

-------------------------------------
-- function click_retryBtn
-------------------------------------
function UI_GameRewardPopup:click_retryBtn()
    -- 현재 g_currScene은 SceneGame이어야 한다
    local stage_name = g_currScene.m_stageName

    local scene = SceneGame(g_currScene.m_stageID, stage_name)
    scene:runScene()
end

-------------------------------------
-- function click_backBtn
-------------------------------------
function UI_GameRewardPopup:click_backBtn()
    local scene = SceneLobby()
    scene:runScene()
end
