-------------------------------------
-- class UI_Game
-------------------------------------
UI_Game = class(UI, {
        m_gameScene = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Game:init(game_scene)
    self.m_gameScene = game_scene

    local vars = self:load('ingame_scene_new.ui')
    UIManager:open(self, UIManager.NORMAL)

    vars['autoStartButton']:registerScriptTapHandler(function() self:click_autoStartButton() end)
    vars['pauseButton']:registerScriptTapHandler(function() self:click_pauseButton() end)  
	vars['feverButton']:registerScriptTapHandler(function() self:click_feverButton() end)    
    vars['autoButton']:registerScriptTapHandler(function() self:click_autoButton() end)
    vars['speedButton']:registerScriptTapHandler(function() self:click_speedButton() end)
    vars['buffBtn']:registerScriptTapHandler(function() self:click_buffButton() end)

    local label = cc.Label:createWithBMFont('res/font/hit_font.fnt', tostring(999))
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(1, 0.5))
    --label:setAlignment(cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    vars['hitNode']:addChild(label)
    vars['hitLabel'] = label
    vars['goldLabel']:setString('0')

    -- 스테이지명 지정
    local stage_name = g_stageData:getStageName(self.m_gameScene.m_stageID)
    vars['stageLabel']:setString(stage_name)
    
    -- 연속 전투 정보
    do
        vars['autoStartVisual'].m_node:setLocalZOrder(1)
        vars['autoVisual'].m_node:setLocalZOrder(1)
        vars['speedVisual'].m_node:setLocalZOrder(1)

        self:setAutoPlayUI()
    end

    -- 2배속
    do
        vars['speedVisual']:setVisible(g_autoPlaySetting:get('quick_mode'))
    end

    -- 버프 정보
    do
        vars['buffBtn']:setVisible(g_friendBuff:isExistBuff())
    end
    
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_pauseButton() end, 'UI_Game')
end

-------------------------------------
-- function click_autoStartButton
-------------------------------------
function UI_Game:click_autoStartButton()
    self.m_gameScene:gamePause()

    local function close_cb()
        -- 설정된 정보로 UI 변경
        self:setAutoMode(g_autoPlaySetting:get('auto_mode'))
        self:setAutoPlayUI()

        self.m_gameScene:gameResume()
    end

    local ui = UI_AutoPlaySettingPopup()
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_pauseButton
-------------------------------------
function UI_Game:click_pauseButton()
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
function UI_Game:click_feverButton()
	local game_fever = self.m_gameScene.m_gameWorld.m_gameFever
    if not game_fever:isActive() then
        game_fever:addFeverPoint(100)
    end
end

-------------------------------------
-- function click_autoButton
-------------------------------------
function UI_Game:click_autoButton()
    local gameAuto = self.m_gameScene.m_gameWorld.m_gameAutoHero

    self:setAutoMode(not gameAuto:isActive())
end

-------------------------------------
-- function click_speedButton
-------------------------------------
function UI_Game:click_speedButton()
	local gameTimeScale = self.m_gameScene.m_gameWorld.m_gameTimeScale

    if (gameTimeScale:getBase() >= QUICK_MODE_TIME_SCALE) then
        UIManager:toastNotificationGreen('빠른모드 비활성화')

        gameTimeScale:setBase(1)

         g_autoPlaySetting:set('quick_mode', false)
    else
        UIManager:toastNotificationGreen('빠른모드 활성화')

        gameTimeScale:setBase(QUICK_MODE_TIME_SCALE)

        g_autoPlaySetting:set('quick_mode', true)
    end

    self.vars['speedVisual']:setVisible((gameTimeScale:getBase() >= QUICK_MODE_TIME_SCALE))
end

-------------------------------------
-- function click_buffButton
-------------------------------------
function UI_Game:click_buffButton()
    if (not g_friendBuff) then return end

    local str = g_friendBuff:getBuffStr()

    local tool_tip = UI_Tooltip_Buff(0, 0, str, true)

    -- 자동 위치 지정
    tool_tip:autoPositioning(self.vars['buffBtn'])

    tool_tip:autoRelease(3)
end

-------------------------------------
-- function init_debugUI
-- @brief 인게임에서 실시간으로 각종 설정을 할 수 있도록 하는 UI생성
--        모든 기능은 UI_GameDebug안에서 구현
-------------------------------------
function UI_Game:init_debugUI()
    local debug_ui = UI_GameDebug()
    self.root:addChild(debug_ui.root)
end

-------------------------------------
-- function init_goldUI
-------------------------------------
function UI_Game:init_goldUI()
    local vars = self.vars

    vars['waveVisual']:setVisible(false)
    vars['goldNode']:setVisible(true)

    -- 금화 갯수 이미지 폰트 생성
    vars['goldLabel'] = cc.Label:createWithBMFont('res/font/fever_gauge.fnt', tostring(0))
    vars['goldLabel']:setAnchorPoint(cc.p(0.5, 0.5))
    vars['goldLabel']:setDockPoint(cc.p(0.5, 0.5))
    vars['goldLabel']:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    vars['goldLabel']:setAdditionalKerning(0)
    vars['goldNode']:addChild(vars['goldLabel'])
end

-------------------------------------
-- function setGold
-- @brief 
-------------------------------------
function UI_Game:setGold(gold)
    local gold = math_floor(gold)

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
function UI_Game:setAutoMode(b)
    local gameAuto = self.m_gameScene.m_gameWorld.m_gameAutoHero
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

-------------------------------------
-- function setAutoPlayUI
-- @brief 연속 전투 정보 UI
-------------------------------------
function UI_Game:setAutoPlayUI()
    local vars = self.vars

    vars['autoStartNode']:setVisible(g_autoPlaySetting:isAutoPlay())
    vars['autoStartNumberLabel']:setString(Str('{1}/20', g_autoPlaySetting:getAutoPlayCnt()))
    vars['autoStartVisual']:setVisible(g_autoPlaySetting:isAutoPlay())
end