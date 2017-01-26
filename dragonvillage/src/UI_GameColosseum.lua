-------------------------------------
-- class UI_GameColosseum
-------------------------------------
UI_GameColosseum = class(UI, {
        m_gameScene = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GameColosseum:init(game_scene)
    self.m_gameScene = game_scene

    local vars = self:load('ingame_colosseum.ui')
    UIManager:open(self, UIManager.NORMAL)

    vars['pauseButton']:registerScriptTapHandler(function() self:click_pauseButton() end)  
	vars['feverButton']:registerScriptTapHandler(function() self:click_feverButton() end)    
    vars['autoButton']:registerScriptTapHandler(function() self:click_autoButton() end)
    vars['speedButton']:registerScriptTapHandler(function() self:click_speedButton() end)

    local label = cc.Label:createWithBMFont('res/font/hit_font.fnt', tostring(999))
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(1, 0.5))
    --label:setAlignment(cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    vars['hitNode']:addChild(label)
    vars['hitLabel'] = label
    
    -- 2배속
    do
        vars['speedVisual']:setVisible(g_autoPlaySetting:get('quick_mode'))
    end

    -- 백키 지정
    --g_currScene:pushBackKeyListener(self, function() self:click_pauseButton() end, 'UI_GameColosseum')
    vars['pauseButton']:setVisible(false)
end

-------------------------------------
-- function setHeroHpGauge
-------------------------------------
function UI_GameColosseum:setHeroHpGauge(percentage)
    self.vars['hpGauge1']:runAction(cc.ProgressTo:create(0.2, percentage)) 
end

-------------------------------------
-- function setEnemyHpGauge
-------------------------------------
function UI_GameColosseum:setEnemyHpGauge(percentage)
    self.vars['hpGauge2']:runAction(cc.ProgressTo:create(0.2, percentage)) 
end

-------------------------------------
-- function click_pauseButton
-------------------------------------
function UI_GameColosseum:click_pauseButton()
    local stage_id = self.m_gameScene.m_stageID
    local game_mode = self.m_gameScene.m_gameMode

    local function start_cb()
        self.m_gameScene:gamePause()
    end

    local function end_cb()
        self.m_gameScene:gameResume()
    end

    if (game_mode == GAME_MODE_NEST_DUNGEON) then
        UI_GamePause_NestDungeon(stage_id, start_cb, end_cb)
    else
        UI_GamePause(stage_id, start_cb, end_cb)
    end
end

-------------------------------------
-- function click_feverButton
-------------------------------------
function UI_GameColosseum:click_feverButton()
	local game_fever = self.m_gameScene.m_gameWorld.m_gameFever
    if not game_fever:isActive() then
        game_fever:addFeverPoint(100)
    end
end

-------------------------------------
-- function click_autoButton
-------------------------------------
function UI_GameColosseum:click_autoButton()
    local gameAuto = self.m_gameScene.m_gameWorld.m_gameAuto

    self:setAutoMode(not gameAuto:isActive())
end

-------------------------------------
-- function click_speedButton
-------------------------------------
function UI_GameColosseum:click_speedButton()
	local gameTimeScale = self.m_gameScene.m_gameWorld.m_gameTimeScale

    if (gameTimeScale:getBase() >= QUICK_MODE_TIME_SCALE) then
        UIManager:toastNotificationGreen('빠른모드 비활성화')

        gameTimeScale:setBase(COLOSSEUM__TIME_SCALE)

         g_autoPlaySetting:set('quick_mode', false)
    else
        UIManager:toastNotificationGreen('빠른모드 활성화')

        gameTimeScale:setBase(COLOSSEUM__TIME_SCALE * QUICK_MODE_TIME_SCALE)

        g_autoPlaySetting:set('quick_mode', true)
    end

    self.vars['speedVisual']:setVisible((gameTimeScale:getBase() >= QUICK_MODE_TIME_SCALE))
end

-------------------------------------
-- function init_debugUI
-- @brief 인게임에서 실시간으로 각종 설정을 할 수 있도록 하는 UI생성
--        모든 기능은 UI_GameDebug안에서 구현
-------------------------------------
function UI_GameColosseum:init_debugUI()
    local debug_ui = UI_GameDebug()
    self.root:addChild(debug_ui.root)
end

-------------------------------------
-- function setGold
-- @brief 
-------------------------------------
function UI_GameColosseum:setGold(gold)    
    self.vars['goldLabel']:setString(comma_value(gold))

    local action_node = self.vars['goldNode']
    local x = -72
    local y = -2

    if self.m_gameScene.m_gameWorld:isOnFight() then
        action_node:stopAllActions()
        local start_action = cc.MoveTo:create(0.05, cc.p(x, y + 10))
        local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(0.5, cc.p(x, y)), 0.2)
        action_node:runAction(cc.Sequence:create(start_action, end_action))
    end
end

-------------------------------------
-- function setAutoMode
-- @brief 자동 모드 설정
-------------------------------------
function UI_GameColosseum:setAutoMode(b)
    local gameAuto = self.m_gameScene.m_gameWorld.m_gameAuto
    if (gameAuto:isActive() == b) then return end
    
    if (b) then
        UIManager:toastNotificationGreen('자동전투 활성화')

        gameAuto:onStart()

        g_autoPlaySetting:set('auto_mode', true)

    else
        UIManager:toastNotificationGreen('자동전투 비활성화')

        gameAuto:onEnd()

        g_autoPlaySetting:set('auto_mode', false)
    end
end