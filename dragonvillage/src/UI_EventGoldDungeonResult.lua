-------------------------------------
-- class UI_EventGoldDungeonResult
-------------------------------------
UI_EventGoldDungeonResult = class(UI, {
        m_stageID = 'number',
        m_damage = 'number',

        m_workIdx = 'number',
        m_lWorkList = 'list',

        m_data = '',
     })

local ITEM_CARD_SCALE = 0.65
-------------------------------------
-- function init
-------------------------------------
function UI_EventGoldDungeonResult:init(stage_id, damage, t_data)
    self.m_stageID = stage_id
    self.m_damage = damage
    self.m_data = t_data

    local vars = self:load('event_gold_dungeon_result.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_EventGoldDungeonResult'

    self:doActionReset()
    self:doAction()

    -- TimeScale
    cc.Director:getInstance():getScheduler():setTimeScale(1)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_okBtn() end, 'UI_EventGoldDungeonResult')

    self:initUI()
    self:initButton()

    self:setWorkList()
    self:doNextWork()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventGoldDungeonResult:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventGoldDungeonResult:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['statsBtn']:registerScriptTapHandler(function() self:click_statsBtn() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_screenBtn() end)
end

-------------------------------------
-- function setWorkList
-------------------------------------
function UI_EventGoldDungeonResult:setWorkList()
    self.m_workIdx = 0
    self.m_lWorkList = {}

    table.insert(self.m_lWorkList, 'direction_start')
    table.insert(self.m_lWorkList, 'direction_showScore')
    table.insert(self.m_lWorkList, 'direction_showReward')
    table.insert(self.m_lWorkList, 'direction_end')
end

-------------------------------------
-- function direction_showTamer
-------------------------------------
function UI_EventGoldDungeonResult:direction_showTamer()
end

-------------------------------------
-- function direction_showTamer_click
-------------------------------------
function UI_EventGoldDungeonResult:direction_showTamer_click()
end

-------------------------------------
-- function direction_hideTamer
-------------------------------------
function UI_EventGoldDungeonResult:direction_hideTamer()
end

-------------------------------------
-- function direction_hideTamer_click
-------------------------------------
function UI_EventGoldDungeonResult:direction_hideTamer_click()
end

-------------------------------------
-- function direction_start
-- @brief 시작 연출
-------------------------------------
function UI_EventGoldDungeonResult:direction_start()
    local vars = self.vars
    local visual_node = vars['resultVisual']
    visual_node:setVisible(true)

    local appear_name = 'result_appear'
    local idle_name = 'result_idle'

    SoundMgr:playBGM('bgm_dungeon_victory', false)    
    visual_node:changeAni(appear_name, false)
    visual_node:addAniHandler(function()
        visual_node:changeAni(idle_name, true)
    end)

    self:doNextWorkWithDelayTime(0.8)
end

-------------------------------------
-- function direction_start_click
-------------------------------------
function UI_EventGoldDungeonResult:direction_start_click()
end

-------------------------------------
-- function direction_showScore
-- @brief 점수 연출
-------------------------------------
function UI_EventGoldDungeonResult:direction_showScore()
    local vars = self.vars

    local total_score = cc.Label:createWithBMFont('res/font/tower_score.fnt', '')
    total_score:setAnchorPoint(cc.p(0.5, 0.5))
    total_score:setDockPoint(cc.p(0.5, 0.5))
    total_score:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    total_score:setAdditionalKerning(0)
    vars['scoreNode']:addChild(total_score)

    local new_score = NumberLabel(total_score, 0, 0.3)
    new_score:setNumber(self.m_damage, false)

    self:doNextWorkWithDelayTime(0.8)
end

-------------------------------------
-- function direction_showScore_click
-------------------------------------
function UI_EventGoldDungeonResult:direction_showScore_click()
end

-------------------------------------
-- function direction_showReward
-- @brief 보상 연출
-------------------------------------
function UI_EventGoldDungeonResult:direction_showReward()
    local vars = self.vars
    local reward_list = self.m_data['drop_reward_list']
    local box_visual = vars['boxVisual']

    local ani_1 
    local ani_2
    local result
    
    -- 박스 연출
    ani_1 = function()
        box_visual:setVisible(true)
        box_visual:changeAni('box_01', false)
        box_visual:addAniHandler(function()
            ani_2()
        end)
    end

    ani_2 = function()
        box_visual:changeAni('box_03', false)
        box_visual:addAniHandler(function()
            box_visual:setVisible(false)
            self:show_item_reward()
        end)
    end

    ani_1()
end

-------------------------------------
-- function show_item_reward
-------------------------------------
function UI_EventGoldDungeonResult:show_item_reward()
    local vars = self.vars

    -- 드랍한 아이템 만큼 연출
    local reward_list = self.m_data['drop_reward_list']
    for i, v in ipairs(reward_list) do
        local item_id = v[1]
        local count = v[2]  

        local item_card = UI_ItemCard(item_id, count)
        item_card.root:setScale(ITEM_CARD_SCALE)
        local target_node = vars['rewardNode']
        target_node:addChild(item_card.root)
    end

    self:doNextWork() 
end

-------------------------------------
-- function direction_showReward_click
-------------------------------------
function UI_EventGoldDungeonResult:direction_showReward_click()
end

-------------------------------------
-- function direction_end
-- @brief 종료 연출
-------------------------------------
function UI_EventGoldDungeonResult:direction_end()
    local vars = self.vars
    local stamina_type = 'event_st'
    local st_ad = g_staminasData:getStaminaCount(stamina_type)
    vars['energyLabel']:setString(Str('{1}', comma_value(st_ad)))

    local icon = IconHelper:getStaminaInboxIcon(stamina_type)
    vars['energyIconNode']:addChild(icon)

    vars['energyNode']:setVisible(true)
    vars['okBtn']:setVisible(true)
    vars['statsBtn']:setVisible(true)
end

-------------------------------------
-- function direction_end_click
-------------------------------------
function UI_EventGoldDungeonResult:direction_end_click()
end

-------------------------------------
-- function doNextWork
-------------------------------------
function UI_EventGoldDungeonResult:doNextWork()
    self.m_workIdx = (self.m_workIdx + 1)
    local func_name = self.m_lWorkList[self.m_workIdx]

    if func_name and (self[func_name]) then
        self[func_name](self)
        return
    end
end

-------------------------------------
-- function doNextWorkWithDelayTime
-------------------------------------
function UI_EventGoldDungeonResult:doNextWorkWithDelayTime(second)
    local second = second or 1
    self.root:stopAllActions()
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(second), cc.CallFunc:create(function() self:doNextWork() end)))
end

-------------------------------------
-- function click_okBtn
-- @brief "확인" 버튼
-------------------------------------
function UI_EventGoldDungeonResult:click_okBtn()
	UINavigator:goTo('event_gold_dungeon')
end

-------------------------------------
-- function click_statsBtn
-------------------------------------
function UI_EventGoldDungeonResult:click_statsBtn()
	-- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
	UI_StatisticsPopup(g_gameScene.m_gameWorld)
end

-------------------------------------
-- function click_screenBtn
-------------------------------------
function UI_EventGoldDungeonResult:click_screenBtn()
    if (not self.m_lWorkList[self.m_workIdx]) then
        return
    end

    local func_name = self.m_lWorkList[self.m_workIdx] .. '_click'
    if func_name and (self[func_name]) then
        self[func_name](self)
    end
end