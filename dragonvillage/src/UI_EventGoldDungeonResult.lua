-------------------------------------
-- class UI_EventGoldDungeonResult
-------------------------------------
UI_EventGoldDungeonResult = class(UI, {
        m_stageID = 'number',
        m_damage = 'number',

        m_workIdx = 'number',
        m_lWorkList = 'list',

        m_autoCount = 'boolean',

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
    self.m_autoCount = false

    local vars = self:load('event_gold_dungeon_result.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_EventGoldDungeonResult'

    self:doActionReset()
    self:doAction()

    -- TimeScale
    cc.Director:getInstance():getScheduler():setTimeScale(1)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_againBtn() end, 'UI_EventGoldDungeonResult')

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
    vars['homeBtn']:registerScriptTapHandler(function() self:click_homeBtn() end)
    vars['againBtn']:registerScriptTapHandler(function() self:click_againBtn() end)
    vars['eventBtn']:registerScriptTapHandler(function() self:click_eventBtn() end)
    vars['quickBtn']:registerScriptTapHandler(function() self:click_quickBtn() end)
    vars['statsBtn']:registerScriptTapHandler(function() self:click_statsBtn() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_screenBtn() end)
    if (vars['infoBtn']) then
        vars['infoBtn']:registerScriptTapHandler(function() self:click_statusInfo() end)
        vars['infoBtn']:setVisible(true)
    end
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

    local target_node = vars['rewardNode']
    target_node:setVisible(true)

    
    -- 드랍한 아이템 만큼 연출
    local reward_list = self.m_data['drop_reward_list']
    local l_pos = getSortPosList(150 * ITEM_CARD_SCALE, table.count(reward_list))
    for i, v in ipairs(reward_list) do
        local item_id = v[1]
        local count = v[2]  

        local item_card = UI_ItemCard(item_id, count)
        item_card.root:setScale(ITEM_CARD_SCALE)
        target_node:addChild(item_card.root)

        item_card.root:setPositionX(l_pos[i])
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
    vars['btnMenu']:setVisible(true)

    UI_GameResultNew.checkAutoPlay(self)
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
-- function startGame
-------------------------------------
function UI_EventGoldDungeonResult:startGame()
    local stage_id = EVENT_GOLD_STAGE_ID
	local deck_name = g_deckData:getSelectedDeckName()
    local combat_power = g_deckData:getDeckCombatPower(deck_name)

	local function finish_cb(game_key)
        -- 씬 전환을 두번 호출 하지 않도록 하기 위함
	    local block_ui = UI_BlockPopup()

        -- 연속 전투일 경우 횟수 증가
		if (g_autoPlaySetting:isAutoPlay()) then
			g_autoPlaySetting.m_autoPlayCnt = (g_autoPlaySetting.m_autoPlayCnt + 1)
		end

		local stage_name = 'stage_' .. stage_id
		local scene = SceneGame(game_key, stage_id, stage_name, false)
		scene:runScene()
	end

    g_stageData:requestGameStart(stage_id, deck_name, combat_power, finish_cb, fail_cb)
end

-------------------------------------
-- function click_homeBtn
-- @brief 로비 버튼
-------------------------------------
function UI_EventGoldDungeonResult:click_homeBtn()
	UINavigator:goTo('lobby')
end

-------------------------------------
-- function click_statusInfo
-------------------------------------
function UI_EventGoldDungeonResult:click_statusInfo()
    UI_HelpStatus()
end

-------------------------------------
-- function click_againBtn
-- @brief 다시하기 버튼
-------------------------------------
function UI_EventGoldDungeonResult:click_againBtn()
    local stage_id = self.m_stageID
    local function close_cb()
        if (GOLD_DUNGEON_ALWAYS_OPEN == true) then
            UINavigator:goTo('gold_dungeon')
        else
            UINavigator:goTo('event_gold_dungeon')
        end
    end

    UINavigator:goTo('battle_ready', stage_id, close_cb)
end

-------------------------------------
-- function click_quickBtn
-- @brief 바로재시작 버튼
-------------------------------------
function UI_EventGoldDungeonResult:click_quickBtn()
    local stamina_cnt = g_staminasData:getStaminaCount('event_st')
    -- 충전 불가능한 형태의 입장권
	if (stamina_cnt <= 0) then
        local msg = Str('입장권이 부족합니다.')
        g_autoPlaySetting:setAutoPlay(false) -- 연속 전투 해제
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end

    -- 씬 전환을 두번 호출 하지 않도록 하기 위함
	local quick_btn = self.vars['quickBtn']
	quick_btn:setEnabled(false)

    self:startGame()
end

-------------------------------------
-- function click_eventBtn
-- @brief 황금던전 버튼
-------------------------------------
function UI_EventGoldDungeonResult:click_eventBtn()
    if (GOLD_DUNGEON_ALWAYS_OPEN == true) then
        UINavigator:goTo('gold_dungeon')
        return
    end

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
        if (UI_GameResultNew.checkAutoPlayRelease(self)) then return end
        self[func_name](self)
    end
end

-------------------------------------
-- function checkAutoPlayCondition
-- @brief 이벤트 골드 던전은 연속 전투 멈추는 조건이 없음
-------------------------------------
function UI_EventGoldDungeonResult:checkAutoPlayCondition()
    local auto_play_stop = false
    local msg = nil
	return auto_play_stop, msg
end

-------------------------------------
-- function countAutoPlay
-- @brief 연속 전투일 경우 재시작 하기전 카운트 해줌
-------------------------------------
function UI_EventGoldDungeonResult:countAutoPlay()
    UI_GameResultNew.countAutoPlay(self)
end