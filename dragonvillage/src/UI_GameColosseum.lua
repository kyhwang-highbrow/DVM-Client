local PARENT = UI_Game

-------------------------------------
-- class UI_GameColosseum
-------------------------------------
UI_GameColosseum = class(PARENT, {
    m_orgEnemyTamerGaugeScaleX = 'number'
})

-------------------------------------
-- function getUIFileName
-------------------------------------
function UI_GameColosseum:getUIFileName()
    return 'colosseum_ingame.ui'
end

-------------------------------------
-- function init
-------------------------------------
function UI_GameColosseum:init(game_scene)
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_pauseButton() end, 'UI_GameColosseum')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameColosseum:initUI()
    local vars = self.vars

    self.m_orgEnemyTamerGaugeScaleX = vars['tamerGauge']:getScaleX()

    -- 2배속
    do
        vars['speedVisual']:setVisible(g_autoPlaySetting:get('quick_mode'))
    end

    -- 닉네임
    do
        local user_info = g_colosseumData.m_playerUserInfo
        vars['userNameLabel1']:setString(user_info.m_nickname)

        if (self.m_gameScene.m_bDevelopMode) then
            vars['userNameLabel2']:setString(user_info.m_nickname)
        else
            user_info = g_colosseumData:getMatchUserInfo()
            vars['userNameLabel2']:setString(user_info.m_nickname)
        end
    end

    -- 하단 패널
    vars['panelBgSprite']:setLocalZOrder(-1)

    self:initManaUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GameColosseum:initButton()
	local vars = self.vars

    vars['pauseButton']:registerScriptTapHandler(function() self:click_pauseButton() end)  
    vars['autoButton']:registerScriptTapHandler(function() self:click_autoButton() end)
    vars['speedButton']:registerScriptTapHandler(function() self:click_speedButton() end)
    vars['effectBtn']:registerScriptTapHandler(function() self:click_effectBtn() end)
    vars['chatBtn']:registerScriptTapHandler(function() self:click_chatBtn() end)

    -- 연출 버튼 이미지
    do
        local skip_mode = g_autoPlaySetting:get('skip_mode') or false

        self.m_effectBtnIcon1 = MakeAnimator('res/ui/buttons/ingame_top_effect_0101.png')
        vars['effectBtn']:addChild(self.m_effectBtnIcon1.m_node)

        self.m_effectBtnIcon2 = MakeAnimator('res/ui/buttons/ingame_top_effect_0102.png')
        vars['effectBtn']:addChild(self.m_effectBtnIcon2.m_node)

        self.m_effectBtnIcon1:setVisible(skip_mode)
        self.m_effectBtnIcon2:setVisible(not skip_mode)
    end
end

-------------------------------------
-- function initTamerUI
-------------------------------------
function UI_GameColosseum:initTamerUI(hero_tamer, enemy_tamer)
    local vars = self.vars

    local makeTamerReadyIcon = function(tamer_id)
        local table_tamer = TableTamer()
        local type = table_tamer:getValue(tamer_id, 'type')
        local res = string.format('res/ui/icons/tamer/colosseum_ready_%s.png', type)

        local icon = cc.Sprite:create(res)
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))

        return icon
    end

    do
        local sprite = makeTamerReadyIcon(hero_tamer.m_tamerID)
        vars['tamerNode1']:addChild(sprite, 1)
    end

    do
        local sprite = makeTamerReadyIcon(enemy_tamer.m_tamerID)
        vars['tamerNode2']:addChild(sprite, 1)
    end
end

-------------------------------------
-- function setHeroHpGauge
-------------------------------------
function UI_GameColosseum:setHeroHpGauge(percentage)
    self.vars['hpGauge1']:runAction(cc.ProgressTo:create(0.2, percentage)) 
end

-------------------------------------
-- function getHeroHpGaugePercentage
-------------------------------------
function UI_GameColosseum:getHeroHpGaugePercentage()
    return self.vars['hpGauge1']:getPercentage()
end

-------------------------------------
-- function setEnemyHpGauge
-------------------------------------
function UI_GameColosseum:setEnemyHpGauge(percentage)
    self.vars['hpGauge2']:runAction(cc.ProgressTo:create(0.2, percentage)) 
end

-------------------------------------
-- function getEnemyHpGaugePercentage
-------------------------------------
function UI_GameColosseum:getEnemyHpGaugePercentage()
    return self.vars['hpGauge2']:getPercentage()
end

-------------------------------------
-- function setEnemyTamerGauge
-------------------------------------
function UI_GameColosseum:setEnemyTamerGauge(percentage)
    local scaleX = percentage * self.m_orgEnemyTamerGaugeScaleX / 100

    self.vars['tamerGauge']:setScaleX(scaleX)
end

-------------------------------------
-- function click_autoStartButton
-------------------------------------
function UI_GameColosseum:click_autoStartButton()
end

-------------------------------------
-- function click_pauseButton
-------------------------------------
function UI_GameColosseum:click_pauseButton()
    local stage_id = self.m_gameScene.m_stageID
    local game_mode = self.m_gameScene.m_gameMode
    local gamekey = self.m_gameScene.m_gameKey

    local function start_cb()
        self.m_gameScene:gamePause()
    end

    local function end_cb()
        self.m_gameScene:gameResume()
    end

    UI_GamePause_Colosseum(stage_id, gamekey, start_cb, end_cb)
end

-------------------------------------
-- function click_chatBtn
-------------------------------------
function UI_GameColosseum:click_chatBtn()
    g_chatManager:toggleChatPopup()
end

-------------------------------------
-- function click_speedButton
-------------------------------------
function UI_GameColosseum:click_speedButton()
	local gameTimeScale = self.m_gameScene.m_gameWorld.m_gameTimeScale
	local quick_time_scale = g_constant:get('INGAME', 'QUICK_MODE_TIME_SCALE')

    if (gameTimeScale:getBase() >= quick_time_scale) then
        UIManager:toastNotificationGreen('빠른모드 비활성화')

        gameTimeScale:setBase(COLOSSEUM__TIME_SCALE)

         g_autoPlaySetting:set('quick_mode', false)
    else
        UIManager:toastNotificationGreen('빠른모드 활성화')

        gameTimeScale:setBase(COLOSSEUM__TIME_SCALE * quick_time_scale)

        g_autoPlaySetting:set('quick_mode', true)
    end

    self.vars['speedVisual']:setVisible((gameTimeScale:getBase() >= quick_time_scale))
end

-------------------------------------
-- function init_goldUI
-------------------------------------
function UI_GameColosseum:init_goldUI()
end

-------------------------------------
-- function init_timeUI
-------------------------------------
function UI_GameColosseum:init_timeUI(display_wave, time)
    if (time) then
        self:setTime(time)
    end
end

-------------------------------------
-- function setGold
-------------------------------------
function UI_GameColosseum:setGold(gold, prev_gold)
end

-------------------------------------
-- function setTime
-------------------------------------
function UI_GameColosseum:setTime(sec)
    local vars = self.vars

    vars['timeLabel']:setVisible(true)
    vars['timeLabel']:setString(math_floor(sec))
    
    -- 20초이하인 경우 붉은색으로 색상 변경
    if (sec <= 20) then
        vars['timeLabel']:setColor(cc.c3b(255, 0, 0))
    else
        vars['timeLabel']:setColor(cc.c3b(0, 255, 0))
    end
end

-------------------------------------
-- function setAutoPlayUI
-- @brief 연속 전투 정보 UI
-------------------------------------
function UI_GameColosseum:setAutoPlayUI()
end