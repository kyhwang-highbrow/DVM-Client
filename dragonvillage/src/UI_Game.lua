-------------------------------------
-- class UI_Game
-------------------------------------
UI_Game = class(UI, {
        m_gameScene = '',
        m_buffBoard = 'UI_NotificationInfo',
        m_panelUI = '',

        -- 테이머 UI 정보
        m_bVisible_TamerUI = '',
        m_posX_TamerUI = '',
        m_posY_TamerUI = '',
     })

-------------------------------------
-- function getUIFileName
-------------------------------------
function UI_Game:getUIFileName()
    return 'ingame_scene.ui'
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
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Game:initUI()
	local vars = self.vars
    
    vars['goldLabel']:setString('0')
    vars['dragSkillLabel']:setString('0%')

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
end

-------------------------------------
-- function initInfoBoard
-------------------------------------
function UI_Game:initInfoBoard()
    local vars = self.vars
    local bestfriend_buff = self.m_gameScene.m_bestfriendOnlineBuff
    local soulmate_buff = self.m_gameScene.m_soulmateOnlineBuff
    local total_buff_list = self.m_gameScene.m_totalOnlineBuffList

    if (table.count(total_buff_list) <= 0) and (not g_friendBuff:isExistBuff()) then
        vars['buffBtn']:setVisible(false)
        return
    end

    vars['buffBtn']:setVisible(true)

    -- 보드 생성
    self.m_buffBoard = UI_NotificationInfo()
    self.m_buffBoard.root:setDockPoint(cc.p(1, 1))
    self.vars['buffNode']:addChild(self.m_buffBoard.root)

    -- 친구 사용 버프
    if (g_friendBuff:isExistBuff()) then
        local str = g_friendBuff:getBuffStr()      
    
        local buff_info = UI_NotificationInfoElement()
        buff_info:setTitleText('{@SKILL_NAME}[친구 드래곤 사용 버프]')
        buff_info:setDescText(str)
        self.m_buffBoard:addElement(buff_info)
    end

        -- 소울메이트 버프
    if soulmate_buff['info_title'] then
        local buff_info = UI_NotificationInfoElement()
        buff_info:setTitleText(soulmate_buff['info_title'])

        local info_str = nil
        for i,v in ipairs(soulmate_buff['info_list']) do
            if (not info_str) then
                info_str = v
            else
                info_str = info_str .. '\n' .. v
            end
        end
        buff_info:setDescText(info_str)
        
        self.m_buffBoard:addElement(buff_info)
    end

    -- 베스트프랜드 버프
    if bestfriend_buff['info_title'] then
        local buff_info = UI_NotificationInfoElement()
        buff_info:setTitleText(bestfriend_buff['info_title'])

        local info_str = nil
        for i,v in ipairs(bestfriend_buff['info_list']) do
            if (not info_str) then
                info_str = v
            else
                info_str = info_str .. '\n' .. v
            end
        end
        buff_info:setDescText(info_str)
        
        self.m_buffBoard:addElement(buff_info)
    end
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

    if (game_mode == GAME_MODE_NEST_DUNGEON) then
        UI_GamePause_NestDungeon(stage_id, start_cb, end_cb)
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        UI_GamePause_SecretDungeon(stage_id, start_cb, end_cb)
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

        g_autoPlaySetting:set('dragon_panel', self.m_panelUI.m_bVisible)
    end
end

-------------------------------------
-- function init_dpsUI
-- @brief 데미지 미터기 + 힐 미터기
-------------------------------------
function UI_Game:init_dpsUI()
    local world = self.m_gameScene.m_gameWorld

    local dps_ui = UI_GameDPS(world)
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

    vars['goldNode']:setVisible(true)

    -- 금화 갯수 이미지 폰트 생성
    vars['goldLabel'] = cc.Label:createWithBMFont('res/font/gold_dungeon_gold.fnt', tostring(0))
    vars['goldLabel']:setAnchorPoint(cc.p(1, 0.5))
    vars['goldLabel']:setDockPoint(cc.p(1, 0.5))
    vars['goldLabel']:setAlignment(cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    vars['goldLabel']:setAdditionalKerning(0)
    vars['goldNode']:addChild(vars['goldLabel'])
end

-------------------------------------
-- function init_timeUI
-------------------------------------
function UI_Game:init_timeUI(display_wave, time)
    local vars = self.vars

    vars['waveVisual']:setVisible(display_wave)
    vars['timeNode']:setVisible(true)

    -- 시간 이미지 폰트 생성
    vars['timeLabel'] = cc.Label:createWithBMFont('res/font/gold_dungeon_time.fnt', '00:00')
    vars['timeLabel']:setAnchorPoint(cc.p(1, 0.5))
    vars['timeLabel']:setDockPoint(cc.p(1, 0.5))
    vars['timeLabel']:setAlignment(cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    vars['timeLabel']:setAdditionalKerning(0)
    vars['timeNode']:addChild(vars['timeLabel'])

    if (time) then
        self:setTime(time)
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

    vars['goldLabel']:stopAllActions()
    vars['goldLabel']:runAction(tween_action)
end

-------------------------------------
-- function setTime
-------------------------------------
function UI_Game:setTime(sec, is_limit)
    local vars = self.vars

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
-- function setActiveSkillTime
-------------------------------------
function UI_Game:setActiveSkillTime(cur, max)
    local vars = self.vars

    local percentage

    if (max <= 0) then
        percentage = 100
    else
        percentage = math_floor((cur / max) * 100)
    end
    
    if (vars['dragSkillLabel']) then
        local func = function(value, node)
            node:setString(math_floor(value) .. '%')
        end
        local prev = vars['dragSkillGauge']:getPercentage()
        local tween_action = cc.ActionTweenForLua:create(0.5, prev, percentage, func)

        vars['dragSkillLabel']:stopAllActions()
        vars['dragSkillLabel']:runAction(tween_action)
    end

    if (vars['dragSkillGauge']) then
        vars['dragSkillGauge']:runAction(cc.ProgressTo:create(0.5, percentage))
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
    else
        -- 패널 UI 표시
        if (g_autoPlaySetting:get('dragon_panel')) then
            self:toggleVisibility_PanelUI(true)
        end

        -- 테이머 UI 표시
        self:toggleVisibility_TamerUI(true)
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
    local vars = self.vars

    if (not vars['tamerMenu']) then return end
    if (self.m_bVisible_TamerUI == b) then return end
    self.m_bVisible_TamerUI = b

    local duration = 0.3

    if (b) then
        vars['tamerMenu']:setVisible(true)
		local move_action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(self.m_posX_TamerUI, self.m_posY_TamerUI)), 2)
        vars['tamerMenu']:stopAllActions()
        vars['tamerMenu']:runAction(move_action)
    else
		local move_action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(self.m_posX_TamerUI, self.m_posY_TamerUI - 150)), 2)
		local seq_action = cc.Sequence:create(move_action, cc.Hide:create())
        vars['tamerMenu']:stopAllActions()
        vars['tamerMenu']:runAction(seq_action)
    end

    if (is_immediately) then
        vars['tamerMenu']:setVisible(b)
   end
end