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
        
        -- 방송 라벨
        m_broadcastLabel = 'UIC_BroadcastLabel',

        -- 채팅 라벨 (추가)
        m_chatBroadcastLabel = 'UIC_BroadcastLabel',

        -- 시간 라벨
        m_timeLabel = '',

        -- 일시 정지
        m_pauseUI = '',
     })

-------------------------------------
-- function getUIFileName
-------------------------------------
function UI_Game:getUIFileName()
    return 'ingame.ui'
end

-------------------------------------
-- function init
-------------------------------------
function UI_Game:init(game_scene)
    self.m_gameScene = game_scene

    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_btn/ingame_btn.plist')
    --cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_damage/ingame_damage.plist')
    Translate:a2dTranslate('ui/a2d/ingame_damage/ingame_damage.plist')

    local vars = self:load(self:getUIFileName(), false, true, true)
    UIManager:open(self, UIManager.NORMAL)

	 -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_pauseButton() end, 'UI_Game')

    self:initUI()
	self:initButton()

    self.m_broadcastLabel = UIC_BroadcastLabel:create(vars['noticeBroadcastNode'], vars['noticeBroadcastLabel'])
    self.m_chatBroadcastLabel = UIC_BroadcastLabel:create(vars['chatBroadcastNode'], vars['chatBroadcastLabel'])
    self.m_timeLabel = nil
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Game:initUI()
	local vars = self.vars
    local game_mode = self.m_gameScene.m_gameMode
    
    --vars['goldLabel']:setString('0')
    
    -- 스테이지명 지정
    local stage_name = g_stageData:getStageName(self.m_gameScene.m_stageID)
    vars['stageLabel']:setString(stage_name)
    
    -- 연속 전투 정보
    do
        self:setAutoPlayUI()
    end

    -- 2배속
    do
        local b = g_autoPlaySetting:get('quick_mode')

        if (game_mode == GAME_MODE_INTRO) then
            b = true
        end
        
        vars['speedVisual']:setVisible(b)
    end

    -- 버프 정보
    do
        --self:initInfoBoard()
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
    vars['hotTimeStLabel']:setString('')
    vars['hotTimeGoldLabel']:setString('')
    vars['hotTimeExpLabel']:setString('')

    local l_hottime = g_hotTimeData:getIngameHotTimeList(game_key) or {}
    local t_ui_name = {
        ['stamina_50p'] = 'hotTimeStBtn',
        ['gold_1_5x'] = 'hotTimeGoldBtn',
        ['gold_2x'] = 'hotTimeGoldBtn',
        ['exp_1_5x'] = 'hotTimeExpBtn',
        ['exp_2x'] = 'hotTimeExpBtn',

        ['buff_gold2x'] = 'hotTimeGoldBtn',
        ['buff_exp2x'] = 'hotTimeExpBtn',
    }

    local t_ui_label_name = {
        ['stamina_50p'] = {'hotTimeStLabel', '50'},
        ['gold_1_5x'] = {'hotTimeGoldLabel', '50'},
        ['gold_2x'] = {'hotTimeGoldLabel', '100'},
        ['exp_1_5x'] = {'hotTimeExpLabel', '50'},
        ['exp_2x'] = {'hotTimeExpLabel', '100'},

        ['buff_gold2x'] = {'hotTimeGoldLabel', '100'},
        ['buff_exp2x'] = {'hotTimeExpLabel', '100'},
    }

    -- hottime key를 ui name으로 변환
    local l_item_ui = {}
    for i, hot_key in pairs(l_hottime) do
        if (t_ui_name[hot_key]) then

            -- 툴팁 버튼 기능 추가
            local btn_lua_name = t_ui_name[hot_key]
            local btn = vars[btn_lua_name]

            local hottime_type 
            if (string.find(hot_key, 'gold')) then
                hottime_type = 'gold'

            elseif (string.find(hot_key, 'exp')) then
                hottime_type = 'exp'

            elseif (string.find(hot_key, 'stamina')) then
                hottime_type = 'stamina'
            end

            if (hottime_type) then
                btn:registerScriptTapHandler(function() g_hotTimeData:makeHotTimeToolTip(hottime_type, btn) end)
            end
            
            local t_label_info = t_ui_label_name[hot_key]
            local ui_name = t_label_info[1]
            local value = t_label_info[2]
            local target_label = vars[ui_name]

            -- 골드, 경험치는 핫타임과 버프아이템 중복가능
            if ( string.find(ui_name, 'Gold') or string.find(ui_name, 'Exp') ) then
                local curr_value = target_label:getString()
                if (curr_value == '') then
                    target_label:setString(value)
                else
                    local new_value = tonumber(curr_value) + tonumber(value)
                    target_label:setString(tostring(new_value))
                end
            else
                target_label:setString(value)
            end
        end
    end

    -- 날개, 골드, 경험치 핫타임 string format 다름
    function apply_hottime_string(ui_name, str_format)
        local label = vars[ui_name]
        local value = label:getString()
        if (value ~= '') then
            label:setString(string.format(str_format, value))

            -- 버튼 활성화
            local visible_ui_name = string.gsub(ui_name, 'Label', 'Btn')
            table.insert(l_item_ui, 1, visible_ui_name)
        end
    end

    apply_hottime_string('hotTimeStLabel', '1/2')
    apply_hottime_string('hotTimeGoldLabel', '+%s%%')
    apply_hottime_string('hotTimeExpLabel', '+%s%%')

    self:arrangeItemUI(l_item_ui)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Game:initButton()
	local vars = self.vars
    
    vars['pauseButton']:registerScriptTapHandler(function() self:click_pauseButton() end)  
    vars['autoButton']:registerScriptTapHandler(function() self:click_autoButton() end)
    vars['speedButton']:registerScriptTapHandler(function() self:click_speedButton() end)
    vars['effectBtn']:registerScriptTapHandler(function() self:click_effectBtn() end)
    vars['chatBtn']:registerScriptTapHandler(function() self:click_chatBtn() end)

    if (vars['autoStartButton']) then
        vars['autoStartButton']:registerScriptTapHandler(function() self:click_autoStartButton() end)
    end

    -- 연출 버튼 이미지
    do
        local skip_mode = g_autoPlaySetting:get('skip_mode') or false

        self.m_effectBtnIcon1 = cc.Sprite:createWithSpriteFrameName('ingame_btn_effect_0101.png')
        if (self.m_effectBtnIcon1) then
            self.m_effectBtnIcon1:setDockPoint(CENTER_POINT)
            self.m_effectBtnIcon1:setAnchorPoint(CENTER_POINT)
            vars['effectBtn']:addChild(self.m_effectBtnIcon1)
        end

        self.m_effectBtnIcon2 = cc.Sprite:createWithSpriteFrameName('ingame_btn_effect_0102.png')
        if (self.m_effectBtnIcon2) then
            self.m_effectBtnIcon2:setDockPoint(CENTER_POINT)
            self.m_effectBtnIcon2:setAnchorPoint(CENTER_POINT)
            vars['effectBtn']:addChild(self.m_effectBtnIcon2)
        end

        self.m_effectBtnIcon1:setVisible(skip_mode)
        self.m_effectBtnIcon2:setVisible(not skip_mode)
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
-- @brief 연속 전투 .. 자동 아님
-------------------------------------
function UI_Game:click_autoStartButton()
	-- 튜토리얼 진행 중 block
	local stage_id = self.m_gameScene.m_stageID
	if (TutorialManager.getInstance():blockIngamePause(stage_id)) then
		UIManager:toastNotificationRed(Str('튜토리얼 진행 중입니다.'))
		return
	end

    local world = self.m_gameScene.m_gameWorld
    if (not world) then return end

    if (world.m_skillIndicatorMgr and world.m_skillIndicatorMgr:isControlling()) then
        world.m_skillIndicatorMgr:clear()
    end

    self.m_gameScene:gamePause()

    local function close_cb()
        -- 자동모드 여부(연속전투 활성화시 같이 활성화 시킴)
        local is_auto_mode = g_autoPlaySetting:get('auto_mode')

        -- 설정된 정보로 UI 변경
        self:setAutoPlayUI()
        self:setAutoMode(is_auto_mode)

        if (is_auto_mode) then
			world:dispatch('auto_start')
        else
			world:dispatch('auto_end')
        end

        self.m_gameScene:gameResume()
    end

    local is_auto = g_autoPlaySetting:isAutoPlay()

    -- 바로 해제
    if (is_auto) then
        g_autoPlaySetting:setAutoPlay(false)
		world:dispatch('farming_changed')
        close_cb()
    else
		local game_mode = self.m_gameScene.m_gameMode
        local ui = UI_AutoPlaySettingPopup(game_mode)
        ui:setCloseCB(close_cb)
    end
end

-------------------------------------
-- function click_pauseButton
-------------------------------------
function UI_Game:click_pauseButton()
	-- 튜토리얼 진행 중 block
	local stage_id = self.m_gameScene.m_stageID
	if (TutorialManager.getInstance():blockIngamePause(stage_id)) then
		UIManager:toastNotificationRed(Str('튜토리얼 진행 중입니다.'))
		return
	end

    local world = self.m_gameScene.m_gameWorld
    if (not world) then return end
    
    if (world.m_skillIndicatorMgr and world.m_skillIndicatorMgr:isControlling()) then
        world.m_skillIndicatorMgr:clear()
    end
    

    local stage_id = self.m_gameScene.m_stageID
    local game_mode = self.m_gameScene.m_gameMode
    local gamekey = self.m_gameScene.m_gameKey

    local function start_cb()
        self.m_gameScene:gamePause()
    end

    local function end_cb()
        self.m_gameScene:gameResume()
    end

    if (game_mode == GAME_MODE_INTRO) then
        -- 인트로 스테이지에서는 백키를 동작시키지 않음
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        self.m_pauseUI = UI_GamePause_NestDungeon(stage_id, gamekey, start_cb, end_cb)
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        self.m_pauseUI = UI_GamePause_SecretDungeon(stage_id, gamekey, start_cb, end_cb)
    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        self.m_pauseUI = UI_GamePause_AncientTower(stage_id, gamekey, start_cb, end_cb)
    elseif (game_mode == GAME_MODE_COLOSSEUM) then
        self.m_pauseUI = UI_GamePause_Colosseum(stage_id, gamekey, start_cb, end_cb)
    elseif (game_mode == GAME_MODE_ARENA) then
        self.m_pauseUI = UI_GamePause_Arena(stage_id, gamekey, start_cb, end_cb)
    elseif (game_mode == GAME_MODE_CHALLENGE_MODE) then
        self.m_pauseUI = UI_GamePause_ChallengeMode(stage_id, gamekey, start_cb, end_cb)
    elseif (game_mode == GAME_MODE_CLAN_RAID) then
        self.m_pauseUI = UI_GamePause_ClanRaid(stage_id, gamekey, start_cb, end_cb)
    elseif (game_mode == GAME_MODE_EVENT_GOLD) then
        self.m_pauseUI = UI_GamePause_EventGoldDungeon(stage_id, gamekey, start_cb, end_cb)
    else
        self.m_pauseUI = UI_GamePause(stage_id, gamekey, start_cb, end_cb)
    end
end

-------------------------------------
-- function closePauseUI
-------------------------------------
function UI_Game:closePauseUI()
    if (self.m_pauseUI) then
        self.m_pauseUI:click_continueButton()
        self.m_pauseUI = nil
    end
end

-------------------------------------
-- function click_autoButton
-------------------------------------
function UI_Game:click_autoButton()
    local world = self.m_gameScene.m_gameWorld
    if (not world) then return end

    local b = (not world:isAutoPlay())

    -- 자동 여부 저장
    g_autoPlaySetting:setWithoutSaving('auto_mode', b)

    -- UI
    self:setAutoMode(b)

    -- 자동 모드 ON
    if (b) then
        world:getAuto():onStart()
    else
        world:getAuto():onEnd()
    end
end

-------------------------------------
-- function click_speedButton
-------------------------------------
function UI_Game:click_speedButton()
    if (not self.m_gameScene.m_gameWorld) then return end

    local game_mode = self.m_gameScene.m_gameMode
	local gameTimeScale = self.m_gameScene.m_gameWorld.m_gameTimeScale
	local quick_time_scale = g_constant:get('INGAME', 'QUICK_MODE_TIME_SCALE')

    if (gameTimeScale:getBase() >= quick_time_scale) then
        UIManager:toastNotificationGreen(Str('빠른모드 비활성화'))

        gameTimeScale:setBase(1)

        if (game_mode ~= GAME_MODE_INTRO) then
            g_autoPlaySetting:setWithoutSaving('quick_mode', false)
        end
    else
        UIManager:toastNotificationGreen(Str('빠른모드 활성화'))

        gameTimeScale:setBase(quick_time_scale)

        if (game_mode ~= GAME_MODE_INTRO) then
            g_autoPlaySetting:setWithoutSaving('quick_mode', true)
        end
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
-- function click_effectBtn
-------------------------------------
function UI_Game:click_effectBtn()
    local skip_mode = g_autoPlaySetting:get('skip_mode') or false
    local new_skip_mode = (not skip_mode)

    if (new_skip_mode) then
        UIManager:toastNotificationGreen(Str('연출 스킵'))
    else
        UIManager:toastNotificationGreen(Str('연출 표시'))
    end

    g_autoPlaySetting:setWithoutSaving('skip_mode', new_skip_mode)

    if (self.m_effectBtnIcon1) then
        self.m_effectBtnIcon1:setVisible(new_skip_mode)
    end
    if (self.m_effectBtnIcon2) then
        self.m_effectBtnIcon2:setVisible(not new_skip_mode)
    end
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
end

-------------------------------------
-- function initTamerUI
-- @brief 테이머 패널 UI
-------------------------------------
function UI_Game:initTamerUI(tamer)
    if (not tamer:getSkillIndivisualInfo('active')) then return end

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

    vars['timeNode']:setVisible(true)
    vars['waveVisual']:setVisible(display_wave)
    
    self.m_timeLabel = vars['timeLabel']
    
    if (time) then
        self.m_timeLabel:setVisible(true)

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
    self.m_timeLabel:setString(str)

	-- 제한시간이 있는 경우에 색상 부여
	if (is_limit) then
		-- 20초이하인 경우 붉은색으로 색상 변경
		if (sec <= 20) then
			self.m_timeLabel:setColor(cc.c3b(255, 0, 0))
		-- 이상은 초록색
		else
			self.m_timeLabel:setColor(cc.c3b(0, 255, 0))
		end
	end
end

-------------------------------------
-- function setAutoMode
-- @brief 자동 모드 설정
-------------------------------------
function UI_Game:setAutoMode(b, no_noti)
    local vars = self.vars

    if (b == vars['autoVisual']:isVisible()) then return end

    if (b) then
        vars['autoVisual']:setVisible(true)

        if (not no_noti) then
            UIManager:toastNotificationGreen(Str('자동전투 활성화'))
        end
    else
        vars['autoVisual']:setVisible(false)

        if (not no_noti) then
            UIManager:toastNotificationGreen(Str('자동전투 비활성화'))
        end
    end
end

-------------------------------------
-- function setAutoPlayUI
-- @brief 연속 전투 정보 UI
-------------------------------------
function UI_Game:setAutoPlayUI()
    local vars = self.vars

    vars['autoStartNode']:setVisible(g_autoPlaySetting:isAutoPlay())
    vars['autoStartNumberLabel']:setString(Str('{1}회 반복중', g_autoPlaySetting:getAutoPlayCnt()))
    vars['autoStartVisual']:setVisible(g_autoPlaySetting:isAutoPlay())
end

-------------------------------------
-- function setTemporaryPause
-------------------------------------
function UI_Game:setTemporaryPause(pause)
    local vars = self.vars

    if (self.m_tamerUI) then
        self.m_tamerUI:setTemporaryPause(pause)
    end
    --[[
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
        self:toggleVisibility_PanelUI(true)
        
        -- 테이머 UI 표시
        self:toggleVisibility_TamerUI(true)

        -- 마나 UI 표시
        self:toggleVisibility_ManaUI(true)

        -- 하단 프레임
        vars['panelBgSprite']:setVisible(true)
    end
    ]]--
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
-- function chatBroadcast
-------------------------------------
function UI_Game:chatBroadcast(t_data)
    local vars = self.vars

    local msg = t_data['message']
    local nickname = t_data['nickname']
    local uid = t_data['uid']

    if (not msg) or (not nickname) or (not uid) then
        return
    end

    local rich_str = '{@SKILL_NAME}[' .. nickname .. '] {@SKILL_DESC}' .. msg
    self.m_chatBroadcastLabel:setString(rich_str)
end

-------------------------------------
-- function initIntroFight
-- @brief 인트로 전투 - 필요없는 UI 비지블 꺼줌
-------------------------------------
function UI_Game:initIntroFight()
    local vars = self.vars
    local off_list = {'autoStartButton', 'autoButton', --'speedButton', 
                      'hottimeNode', 'chatBtn', 'pauseButton',
                      'effectBtn', 'buffBtn', 'dpsInfoNode',
                      'autoVisual'}

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

    if vars['hotTimeExpBtn']:isVisible() then
        table.insert(l_hottime, 'hotTimeExpBtn')
    end

    if vars['hotTimeGoldBtn']:isVisible() then
        table.insert(l_hottime, 'hotTimeGoldBtn')
    end

    if vars['hotTimeStBtn']:isVisible() then
        table.insert(l_hottime, 'hotTimeStBtn')
    end

    table.insert(l_hottime, 'hotTimeMarbleBtn')
    self:arrangeItemUI(l_hottime)
end

-------------------------------------
-- function arrangeItemUI
-- @brief itemUI들을 정렬한다!
-------------------------------------
function UI_Game:arrangeItemUI(l_hottime)
    for i, ui_name in pairs(l_hottime) do
        local ui = self.vars[ui_name]

        ui:setVisible(true)
        local pos_x = -108 + ((i-1) * 72)
        ui:setPositionX(pos_x)
    end
end

-------------------------------------
-- function bindPanelGuide
-------------------------------------
function UI_Game:bindPanelGuide(unit, guide_node)
    local list = self.m_panelUI.m_lPanelItemList
    local panel
    
    -- 해당 드래곤의 패널을 찾음...
    for i, v in pairs(list) do
        if (unit == v.m_dragon) then
            panel = v
            break
        end
    end

    if (panel) then
        local x, y = panel.root:getPosition()
        guide_node:setPosition(x, y)
        self.m_panelUI.vars['panelMenu']:addChild(guide_node)
    end
end
