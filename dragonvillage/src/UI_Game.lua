local PARENT = class(UI, IEventListener:getCloneTable())

-------------------------------------
-- class UI_Game
-------------------------------------
UI_Game = class(PARENT, {
        m_gameScene = '',
        m_buffBoard = 'UI_NotificationInfo',
        
        m_panelUI = '',
        m_tamerUI = '',

        -- 테이머 UI 정보
        m_bVisible_TamerUI = '',
        m_posX_TamerUI = '',
        m_posY_TamerUI = '',

        -- 마나 UI 정보
        m_bVisible_ManaUI = '',
        m_posX_ManaUI = '',
        m_posY_ManaUI = '',

        -- 패널 버튼 이미지
        m_panelBtnIcon1 = '',
        m_panelBtnIcon2 = '',

        -- 연출 버튼 이미지
        m_effectBtnIcon1 = '',
        m_effectBtnIcon2 = '',
        m_effectBtnIcon3 = '',

        -- 방송 라벨
        m_broadcastLabel = 'UIC_BroadcastLabel',
     })

-------------------------------------
-- function getUIFileName
-------------------------------------
function UI_Game:getUIFileName()
    return 'ingame_new.ui'
end

-------------------------------------
-- function init
-------------------------------------
function UI_Game:init(game_scene)
    self.m_gameScene = game_scene
	
	local vars = self:load(self:getUIFileName())
    UIManager:open(self, UIManager.NORMAL)

	 -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_pauseButton() end, 'UI_Game')

    self:initUI()
	self:initButton()

    self.m_broadcastLabel = UIC_BroadcastLabel:create(vars['noticeBroadcastNode'], vars['noticeBroadcastLabel'])
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Game:initUI()
	local vars = self.vars
    
    --vars['goldLabel']:setString('0')
    
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
        self:initInfoBoard()
    end
    
    -- 하단 패널
    vars['panelBgSprite']:setLocalZOrder(-1)

    self:initManaUI()
    self:initHotTimeUI()
end

-------------------------------------
-- function initHotTimeUI
-- @brief 적용된 핫타임
-------------------------------------
function UI_Game:initHotTimeUI()
    local vars = self.vars
    local game_key = self.m_gameScene.m_gameKey

    vars['hotTimeStBtn']:setVisible(false)
    vars['hotTimeGoldBtn']:setVisible(false)
    vars['hotTimeExpBtn']:setVisible(false)
    vars['hotTimeMarbleBtn']:setVisible(false)

    vars['hotTimeStBtn']:registerScriptTapHandler(function() g_hotTimeData:makeHotTimeToolTip('stamina_50p', vars['hotTimeStBtn']) end)
    vars['hotTimeGoldBtn']:registerScriptTapHandler(function() g_hotTimeData:makeHotTimeToolTip('gold_2x', vars['hotTimeGoldBtn']) end)
    vars['hotTimeExpBtn']:registerScriptTapHandler(function() g_hotTimeData:makeHotTimeToolTip('exp_2x', vars['hotTimeExpBtn']) end)

    local l_hottime = g_hotTimeData:getIngameHotTimeList(game_key)
    local t_ui_name = {}
    t_ui_name['stamina_50p'] = 'hotTimeStBtn'
    t_ui_name['gold_2x'] = 'hotTimeGoldBtn'
    t_ui_name['exp_2x'] = 'hotTimeExpBtn'

    do -- 처리되지 않은 타입 제거
        local l_remove = {}
        for i,v in ipairs(l_hottime) do
            if (not t_ui_name[v]) then
                table.insert(l_remove, 1, i)
            end
        end

        for i,v in ipairs(l_remove) do
            table.remove(l_hottime, v)
        end
    end

    for i,v in pairs(l_hottime) do
        local ui_name = t_ui_name[v]
        local ui = vars[ui_name]

        ui:setVisible(true)
        local pos_x = -97 + ((i-1) * 50)
        ui:setPositionX(pos_x)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Game:initButton()
	local vars = self.vars
    vars['autoStartButton']:registerScriptTapHandler(function() self:click_autoStartButton() end)
    vars['pauseButton']:registerScriptTapHandler(function() self:click_pauseButton() end)  
    vars['autoButton']:registerScriptTapHandler(function() self:click_autoButton() end)
    vars['speedButton']:registerScriptTapHandler(function() self:click_speedButton() end)
    vars['buffBtn']:registerScriptTapHandler(function() self:click_buffButton() end)
    vars['panelBtn']:registerScriptTapHandler(function() self:click_panelBtn() end)
    vars['effectBtn']:registerScriptTapHandler(function() self:click_effectBtn() end)
    vars['chatBtn']:registerScriptTapHandler(function() self:click_chatBtn() end)

    -- 패널 버튼 이미지
    do
        local b = g_autoPlaySetting:get('dragon_panel') or false

        self.m_panelBtnIcon1 = MakeAnimator('res/ui/buttons/ingame_top_panel_0101.png')
        self.m_panelBtnIcon1:setVisible(not b)
        vars['panelBtn']:addChild(self.m_panelBtnIcon1.m_node)

        self.m_panelBtnIcon2 = MakeAnimator('res/ui/buttons/ingame_top_panel_0102.png')
        self.m_panelBtnIcon2:setVisible(b)
        vars['panelBtn']:addChild(self.m_panelBtnIcon2.m_node)
    end

    -- 연출 버튼 이미지
    do
        local level = g_autoPlaySetting:get('skip_level') or 0

        self.m_effectBtnIcon1 = MakeAnimator('res/ui/buttons/ingame_top_effect_0103.png')
        self.m_effectBtnIcon1:setVisible((level == 0))
        vars['effectBtn']:addChild(self.m_effectBtnIcon1.m_node)

        self.m_effectBtnIcon2 = MakeAnimator('res/ui/buttons/ingame_top_effect_0102.png')
        self.m_effectBtnIcon2:setVisible((level == 1))
        vars['effectBtn']:addChild(self.m_effectBtnIcon2.m_node)

        self.m_effectBtnIcon3 = MakeAnimator('res/ui/buttons/ingame_top_effect_0101.png')
        self.m_effectBtnIcon3:setVisible((level == 2))
        vars['effectBtn']:addChild(self.m_effectBtnIcon3.m_node)

        -- 임시 처리... 연출 버튼 숨김
        vars['effectBtn']:setVisible(false)
    end
end

-------------------------------------
-- function initInfoBoard
-------------------------------------
function UI_Game:initInfoBoard()
    local vars = self.vars
    vars['buffBtn']:setVisible(false)

    -- 보드 생성
    self.m_buffBoard = UI_NotificationInfo()
    self.m_buffBoard.root:setDockPoint(cc.p(1, 1))
    self.vars['buffNode']:addChild(self.m_buffBoard.root)
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
    local world = self.m_gameScene.m_gameWorld
    if (not world) then return end

    if (world.m_skillIndicatorMgr) then
        if (world.m_skillIndicatorMgr:isControlling()) then return end
    end

    local stage_id = self.m_gameScene.m_stageID
    local game_mode = self.m_gameScene.m_gameMode

    local function start_cb()
        self.m_gameScene:gamePause()
    end

    local function end_cb()
        self.m_gameScene:gameResume()
    end

    if (game_mode == GAME_MODE_INTRO) then
        -- 인트로 스테이지에서는 백키를 동작시키지 않음
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        UI_GamePause_NestDungeon(stage_id, start_cb, end_cb)
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        UI_GamePause_SecretDungeon(stage_id, start_cb, end_cb)
    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        UI_GamePause_AncientTower(stage_id, start_cb, end_cb)
    else
        UI_GamePause(stage_id, start_cb, end_cb)
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
	local quick_time_scale = g_constant:get('INGAME', 'QUICK_MODE_TIME_SCALE')

    if (gameTimeScale:getBase() >= quick_time_scale) then
        UIManager:toastNotificationGreen('빠른모드 비활성화')

        gameTimeScale:setBase(1)

         g_autoPlaySetting:set('quick_mode', false)
    else
        UIManager:toastNotificationGreen('빠른모드 활성화')

        gameTimeScale:setBase(quick_time_scale)

        g_autoPlaySetting:set('quick_mode', true)
    end

    self.vars['speedVisual']:setVisible((gameTimeScale:getBase() >= quick_time_scale))
end

-------------------------------------
-- function click_buffButton
-------------------------------------
function UI_Game:click_buffButton()
    self.m_buffBoard:show()
end

-------------------------------------
-- function click_panelBtn
-------------------------------------
function UI_Game:click_panelBtn()
    if self.m_panelUI then
        self.m_panelUI:toggleVisibility()

        self.m_panelBtnIcon1:setVisible(not self.m_panelUI.m_bVisible)
        self.m_panelBtnIcon2:setVisible(self.m_panelUI.m_bVisible)

        g_autoPlaySetting:set('dragon_panel', self.m_panelUI.m_bVisible)

        if (self.m_panelUI.m_bVisible) then
            UIManager:toastNotificationGreen('하단 UI 표시')
        else
            UIManager:toastNotificationGreen('하단 UI 숨김')
        end
    end
end

-------------------------------------
-- function click_effectBtn
-------------------------------------
function UI_Game:click_effectBtn()
    g_autoPlaySetting:setNextSkipLevel()

    local skip_level = g_autoPlaySetting:get('skip_level') or 0

    self.m_effectBtnIcon1:setVisible((skip_level == 0))
    self.m_effectBtnIcon2:setVisible((skip_level == 1))
    self.m_effectBtnIcon3:setVisible((skip_level == 2))

    local gameDragonSkill = self.m_gameScene.m_gameWorld.m_gameDragonSkill
    gameDragonSkill:setSkipLevel(skip_level)

    local gameHighlight = self.m_gameScene.m_gameWorld.m_gameHighlight
    gameHighlight:setSkipLevel(skip_level)

    UIManager:toastNotificationGreen('연출 단계 ' .. (skip_level + 1))
end

-------------------------------------
-- function click_chatBtn
-------------------------------------
function UI_Game:click_chatBtn()
    g_chatManager:toggleChatPopup()
end

-------------------------------------
-- function init_dpsUI
-- @brief 데미지 미터기 + 힐 미터기
-------------------------------------
function UI_Game:init_dpsUI()
    local world = self.m_gameScene.m_gameWorld

    local dps_ui = UI_GameDPSPopup(world)
    self.vars['dpsInfoNode']:addChild(dps_ui.root)
end

-------------------------------------
-- function init_panelUI
-- @brief 아군 스킬 패널 UI
-------------------------------------
function UI_Game:init_panelUI()
	local world = self.m_gameScene.m_gameWorld
    local panel = UI_IngameDragonPanel(world)
    self.m_panelUI = panel
    self.root:addChild(panel.root)

	-- 액션 등록
    self:addAction(panel.root, UI_ACTION_TYPE_BOTTOM, 0, 0.5)
    self:doActionReset()

    if (not g_autoPlaySetting:get('dragon_panel')) then
        self:toggleVisibility_PanelUI(false, true)
    end
end

-------------------------------------
-- function initTamerUI
-- @brief 테이머 패널 UI
-------------------------------------
function UI_Game:initTamerUI(tamer)
	local world = self.m_gameScene.m_gameWorld
    local panel = UI_IngameTamerPanelItem(world, tamer)
    self.m_tamerUI = panel
    self.root:addChild(panel.root)

    -- 액션 등록
    self:addAction(panel.root, UI_ACTION_TYPE_LEFT, 0, 0.5)
    self:doActionReset()
end

-------------------------------------
-- function init_debugUI
-- @brief 인게임에서 실시간으로 각종 설정을 할 수 있도록 하는 UI생성
--        모든 기능은 UI_GameDebug안에서 구현
-------------------------------------
function UI_Game:init_debugUI()
    local debug_ui = UI_GameDebug(self.m_gameScene.m_gameWorld)
    self.root:addChild(debug_ui.root)
end

-------------------------------------
-- function init_goldUI
-------------------------------------
function UI_Game:init_goldUI()
    local vars = self.vars

    -- UI파일에서 금화노드 정리됨(17/08/02)
    --[[
    vars['goldNode']:setVisible(true)

    -- 금화 갯수 이미지 폰트 생성
    vars['goldLabel'] = cc.Label:createWithBMFont('res/font/gold_dungeon_gold.fnt', tostring(0))
    vars['goldLabel']:setAnchorPoint(cc.p(1, 0.5))
    vars['goldLabel']:setDockPoint(cc.p(1, 0.5))
    vars['goldLabel']:setAlignment(cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    vars['goldLabel']:setAdditionalKerning(0)
    vars['goldNode']:addChild(vars['goldLabel'])
    ]]--
end

-------------------------------------
-- function init_timeUI
-------------------------------------
function UI_Game:init_timeUI(display_wave, time)
    local vars = self.vars

    vars['waveVisual']:setVisible(display_wave)
    
    if (time) then
        vars['timeNode']:setVisible(true)
        self:setTime(time)
    else
        vars['timeNode']:setVisible(false)
    end
end

-------------------------------------
-- function setGold
-------------------------------------
function UI_Game:setGold(gold, prev_gold)
    local vars = self.vars
    
    local func = function(value, node)
        node:setString(comma_value(math_floor(value)))
    end
    local tween_action = cc.ActionTweenForLua:create(1, prev_gold, gold, func)

    --vars['goldLabel']:stopAllActions()
    --vars['goldLabel']:runAction(tween_action)
end

-------------------------------------
-- function setTime
-------------------------------------
function UI_Game:setTime(sec, is_limit)
    local vars = self.vars

    local sec = math_floor(sec)

    local m = math_floor(sec / 60)
    local s = sec % 60
    local str = string.format('%02d:%02d', m, s)
    vars['timeLabel']:setString(str)

	-- 제한시간이 있는 경우에 색상 부여
	if (is_limit) then
		-- 20초이하인 경우 붉은색으로 색상 변경
		if (sec <= 20) then
			vars['timeLabel']:setColor(cc.c3b(255, 0, 0))
		-- 이상은 초록색
		else
			vars['timeLabel']:setColor(cc.c3b(0, 255, 0))
		end
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

    local game_mode = self.m_gameScene.m_gameMode
    local is_auto_mode = not (game_mode == GAME_MODE_ANCIENT_TOWER) 
    vars['autoStartButton']:setVisible(is_auto_mode)

    vars['autoStartNode']:setVisible(g_autoPlaySetting:isAutoPlay())
    vars['autoStartNumberLabel']:setString(Str('{1}회 반복중', g_autoPlaySetting:getAutoPlayCnt()))
    vars['autoStartVisual']:setVisible(g_autoPlaySetting:isAutoPlay())
end

-------------------------------------
-- function setTemporaryPause
-------------------------------------
function UI_Game:setTemporaryPause(pause)
    local vars = self.vars

    if (pause) then
        -- 패널 UI 숨김
        self:toggleVisibility_PanelUI(false)

        -- 테이머 UI 숨김
        self:toggleVisibility_TamerUI(false)

        -- 마나 UI 숨김
        self:toggleVisibility_ManaUI(false)

        -- 하단 프레임
        vars['panelBgSprite']:setVisible(false)
    else
        -- 패널 UI 표시
        if (g_autoPlaySetting:get('dragon_panel')) then
            self:toggleVisibility_PanelUI(true)
        end

        -- 테이머 UI 표시
        self:toggleVisibility_TamerUI(true)

        -- 마나 UI 표시
        self:toggleVisibility_ManaUI(true)

        -- 하단 프레임
        vars['panelBgSprite']:setVisible(true)
    end
end

-------------------------------------
-- function toggleVisibility_PanelUI
-------------------------------------
function UI_Game:toggleVisibility_PanelUI(b, is_immediately)
   if (not self.m_panelUI) then return end
   if (b == self.m_panelUI.m_bVisible) then return end

   self.m_panelUI:toggleVisibility()

   if (is_immediately) then
        self.m_panelUI.vars['panelMenu']:setVisible(b)
   end
end

-------------------------------------
-- function toggleVisibility_TamerUI
-------------------------------------
function UI_Game:toggleVisibility_TamerUI(b, is_immediately)
    if (not self.m_tamerUI) then return end
   if (b == self.m_tamerUI.m_bVisible) then return end

   self.m_tamerUI:toggleVisibility()

   if (is_immediately) then
        self.m_tamerUI.vars['panelMenu']:setVisible(b)
   end
end

-------------------------------------
-- function toggleVisibility_ManaUI
-------------------------------------
function UI_Game:toggleVisibility_ManaUI(b, is_immediately)
    local vars = self.vars

    if (not vars['manaVisual'] or self.m_bVisible_ManaUI == nil) then return end
    if (self.m_bVisible_ManaUI == b) then return end
    self.m_bVisible_ManaUI = b

    local duration = 0.3

    if (b) then
        vars['manaSprite']:setVisible(true)
        vars['manaVisual']:setVisible(true)

        do
		    local move_action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(vars['manaSprite']:getPositionX(), self.m_posY_ManaUI + 32)), 2)
            vars['manaSprite']:stopAllActions()
            vars['manaSprite']:runAction(move_action)
        end
        do
            local move_action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(self.m_posX_ManaUI, self.m_posY_ManaUI)), 2)
            vars['manaVisual']:stopAllActions()
            vars['manaVisual']:runAction(move_action)
        end
    else
        do
		    local move_action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(vars['manaSprite']:getPositionX(), self.m_posY_ManaUI - 150 + 32)), 2)
		    local seq_action = cc.Sequence:create(move_action, cc.Hide:create())
            vars['manaSprite']:stopAllActions()
            vars['manaSprite']:runAction(seq_action)
        end
        do
            local move_action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(self.m_posX_ManaUI, self.m_posY_ManaUI - 150)), 2)
		    local seq_action = cc.Sequence:create(move_action, cc.Hide:create())
            vars['manaVisual']:stopAllActions()
            vars['manaVisual']:runAction(seq_action)
        end
    end

    if (is_immediately) then
        vars['manaSprite']:setVisible(b)
        vars['manaVisual']:setVisible(b)
   end
end

-------------------------------------
-- function noticeBroadcast
-------------------------------------
function UI_Game:noticeBroadcast(msg, duration)
    self.m_broadcastLabel:setString(msg)
end

-------------------------------------
-- function initIntroFight
-- @brief 인트로 전투 - 필요없는 UI 비지블 꺼줌
-------------------------------------
function UI_Game:initIntroFight()
    local vars = self.vars
    local off_list = {'autoStartButton', 'autoButton', 'speedButton', 
                      'hottimeNode', 'chatBtn', 'pauseButton',
                      'panelBtn', 'buffBtn', 'dpsInfoNode'}

    for i, v in ipairs(off_list) do
        if (vars[v]) then
            vars[v]:setVisible(false)
        end
    end
end

-------------------------------------
-- function showAutoItemPickUI
-- @brief
-------------------------------------
function UI_Game:showAutoItemPickUI()
    local vars = self.vars

    -- 클릭 시 툴팁 처리
    local function click_btn()
        local str = '{@SKILL_NAME} ' .. Str('보너스 기능') .. '\n {@SKILL_DESC}' .. Str('아이템을 자동으로 획득')
        local tooltip = UI_Tooltip_Skill(0, 0, str)

        if (tooltip) then
            tooltip:autoPositioning(vars['hotTimeMarbleBtn'])
        end
    end
    vars['hotTimeMarbleBtn']:registerScriptTapHandler(click_btn)
    
    -- 핫타임 UI들과의 정렬
    local l_hottime = {}

    if vars['hotTimeStBtn']:isVisible() then
        table.insert(l_hottime, 'hotTimeStBtn')
    end

    if vars['hotTimeGoldBtn']:isVisible() then
        table.insert(l_hottime, 'hotTimeGoldBtn')
    end

    if vars['hotTimeExpBtn']:isVisible() then
        table.insert(l_hottime, 'hotTimeExpBtn')
    end

    table.insert(l_hottime, 'hotTimeMarbleBtn')

    for i,ui_name in pairs(l_hottime) do
        local ui = vars[ui_name]

        ui:setVisible(true)
        local pos_x = -97 + ((i-1) * 50)
        ui:setPositionX(pos_x)
    end

end