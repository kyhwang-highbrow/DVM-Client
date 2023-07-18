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

        -- 누적 데미지 연출
        m_stackableDamageUI = '',

        m_dpsUI = '',
        -- 
        m_tooltip = '',

     })
-------------------------------------
-- function getUIFileName
-------------------------------------
function UI_Game:getUIFileName()
    return 'ingame.ui'
end

-------------------------------------
-- function reinitialze
-------------------------------------
function UI_Game:reinitialze()
    self.m_panelUI.root:setVisible(false)
    self.m_dpsUI.root:setVisible(false)


    self:initManaUI()
    self:init_dpsUI()
    self:init_panelUI()
end

-------------------------------------
-- function init
-------------------------------------
function UI_Game:init(game_scene)
    self.m_gameScene = game_scene

    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_btn/ingame_btn.plist')
    --cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_damage/ingame_damage.plist')
    Translate:a2dTranslate('ui/a2d/ingame_damage/ingame_damage.plist')

    local vars = self:load(self:getUIFileName(), false, true, true) -- param : url, is_permanent, keep_z_order, use_sprite_frames
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
    local world = self.m_gameScene.m_gameWorld
    --vars['goldLabel']:setString('0')
    
    -- 스테이지명 지정
    local stage_name = g_stageData:getStageName(self.m_gameScene.m_stageID)
    vars['stageLabel']:setString(stage_name)
    
    -- 연속 전투 정보
    do
        self:setAutoPlayUI()
    end

    do -- 일일 드랍아이템 획득량 툴팁 ui 생성
        self:createAutoItemPickUI()
    end

    -- 버프 정보
    do
        --self:initInfoBoard()
    end
    
    -- 하단 패널
    vars['panelBgSprite']:setLocalZOrder(-1)

    self:initManaUI()
    self:initHotTimeUI()

    -- ochoi TODO
    -- initRaidUI
    if (g_gameScene.m_gameMode == GAME_MODE_LEAGUE_RAID) then
        self.m_stackableDamageUI = UI_LeagueRaidDamageInfo(self)
        self.root:addChild(self.m_stackableDamageUI.root)
    end
end

-- @jsbae 2020.06.26부터 HOTTIME_UI_INFO의 키는 Fevertime의 핫타임 타입으로 설정한다.
local HOTTIME_UI_INFO = {
	['gold'] = {
		['button'] = 'hotTimeGoldBtn',
		['label'] = 'hotTimeGoldLabel',
		['format'] = '+%s%%',
	},
	['exp'] = {
		['button'] = 'hotTimeExpBtn',
		['label'] = 'hotTimeExpLabel',
		['format'] = '+%s%%',
	},
	['stamina'] = {
		['button'] = 'hotTimeStBtn',
		['label'] = 'hotTimeStLabel',
		['format'] = '-%s%%',
	},
    ['dg_gd_item_up'] = {
        ['button'] = 'hotTimeGdBtn',
		['label'] = 'hotTimeGdLabel',
		['format'] = '+%s%%',
    },
    ['dg_gt_item_up'] = {
        ['button'] = 'hotTimeGtBtn',
		['label'] = 'hotTimeGtLabel',
		['format'] = '+%s%%',
    },
    ['pvp_honor_up'] = {
		['button'] = 'hotTimeHonorBtn',
		['label'] = 'hotTimeHonorLabel',
		['format'] = '+%s%%',
	},
    ['dg_rune_legend_up'] = {
		['button'] = 'hotTimeRuneLegendBtn',
		['label'] = 'hotTimeRuneLegendLabel',
		['format'] = '+%s%%',
	},
    ['dg_rune_up'] = {
		['button'] = 'hotTimeRuneBtn',
		['label'] = 'hotTimeRuneLabel',
		['format'] = '+%s%%',
	},
    ['dg_ar_st_dc'] = {
		['button'] = 'hotTimeDgArStBtn',
		['label'] = 'hotTimeDgArStLabel',
		['format'] = '-%s%%',
	},
    ['dg_rg_st_dc'] = {
		['button'] = 'hotTimeDgRgStBtn',
		['label'] = 'hotTimeDgRgStLabel',
		['format'] = '-%s%%',
	},
    ['dg_nm_st_dc'] = {
		['button'] = 'hotTimeDgNmStBtn',
		['label'] = 'hotTimeDgNmStLabel',
		['format'] = '-%s%%',
	},
    ['dg_gt_st_dc'] = {
		['button'] = 'hotTimeDgGtStBtn',
		['label'] = 'hotTimeDgGtStLabel',
		['format'] = '-%s%%',
	},
    ['dg_gd_st_dc'] = {
		['button'] = 'hotTimeDgGdStBtn',
		['label'] = 'hotTimeDgGdStLabel',
		['format'] = '-%s%%',
	},
    ['raid_up'] = {
		['button'] = 'hotTimeDgArStBtn',
		['label'] = 'hotTimeDgArStLabel',
		['format'] = '-500',
	},
}
-------------------------------------
-- function initHotTimeUI
-- @brief 적용된 핫타임
-------------------------------------
function UI_Game:initHotTimeUI()
    local vars = self.vars
    local game_key = self.m_gameScene.m_gameKey
	local game_mode = self.m_gameScene.m_gameMode

    for i,v in pairs(HOTTIME_UI_INFO) do
        -- 핫타임 종류별 버튼 초기화
        local btn_luaname = v['button']
        local btn = vars[btn_luaname]
        if (btn) then
            btn:setVisible(false)
        end

        -- 핫타임 종류별 라벨 초기화
        local label_luaname = v['label']
        local label = vars[label_luaname]
        if (label) then
            label:setString('')
        end
    end

    local l_item_ui = {}
    local l_hottime = g_hotTimeData:getIngameHotTimeList(game_key) or {}
    local t_hottime_calc_value = {}
    for key,_ in pairs(HOTTIME_UI_INFO) do
        t_hottime_calc_value[key] = 0
    end

	-- 모험 모드, 거목 던전, 거대용 던전에서 핫타임 계산
    -- 입장권 핫타임(날개 핫타임)은 모험, 거목 던전, 거대용 던전 각각임. 추후 추가될 악몽 던전, 고대 유적 던전, 룬 수호자 던전도 모두 각각임
    -- 모험 모드
	if (game_mode == GAME_MODE_ADVENTURE) then
		-- 골드
        local type = 'gold'
        local is_active, value = g_hotTimeData:getActiveHotTimeInfo_gold()
        t_hottime_calc_value[type] = (t_hottime_calc_value[type] + value)
        
        -- 경험치
        local type = 'exp'
        local is_active, value = g_hotTimeData:getActiveHotTimeInfo_exp()
        t_hottime_calc_value[type] = (t_hottime_calc_value[type] + value)

        -- 입장권
        local type = 'stamina'
        local is_active, value = g_hotTimeData:getActiveHotTimeInfo_stamina()
        t_hottime_calc_value[type] = (t_hottime_calc_value[type] + value)

    -- 거대용, 거목 던전
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        -- 거대용 던전
        if (g_gameScene.m_dungeonMode == NEST_DUNGEON_EVO_STONE) then
            -- 진화 재료
            local type = 'dg_gd_item_up'
            self:applyFevertime(type, t_hottime_calc_value)

            -- 거대용 던전 날개 할인
            local type = 'dg_gd_st_dc'
            self:applyFevertime(type, t_hottime_calc_value)

        -- 거목 던전
        elseif (g_gameScene.m_dungeonMode == NEST_DUNGEON_TREE) then
            -- 친밀도 열매
            local type = 'dg_gt_item_up'
            self:applyFevertime(type, t_hottime_calc_value)

            -- 거목 던전 날개 할인
            local type = 'dg_gt_st_dc'
            self:applyFevertime(type, t_hottime_calc_value)

        -- 악몽 던전
        elseif (g_gameScene.m_dungeonMode == NEST_DUNGEON_NIGHTMARE) then
            -- 전설 등급 룬 확률 증가
            local type = 'dg_rune_legend_up'
            self:applyFevertime(type, t_hottime_calc_value)

            -- 룬 추가 획득
            local type = 'dg_rune_up'
            self:applyFevertime(type, t_hottime_calc_value)

            -- 룬 추가 획득
            local type = 'dg_nm_st_dc'
            self:applyFevertime(type, t_hottime_calc_value)
        end
    
    -- 고대 유적 던전
    elseif (game_mode == GAME_MODE_ANCIENT_RUIN) then
        -- 전설 등급 룬 확률 증가
        local type = 'dg_rune_legend_up'
        self:applyFevertime(type, t_hottime_calc_value)
        
        -- 룬 추가 획득
        local type = 'dg_rune_up'
        self:applyFevertime(type, t_hottime_calc_value)

        -- 고대 유적 던전 날개 할인
        local type = 'dg_ar_st_dc'
        self:applyFevertime(type, t_hottime_calc_value)

    -- 레이드
    elseif (game_mode == GAME_MODE_LEAGUE_RAID) then
        -- 레이드 스태미나 감소
        local type = 'raid_up'
        self:applyFevertime(type, t_hottime_calc_value)

    -- 룬 수호자 던전
    elseif (game_mode == GAME_MODE_RUNE_GUARDIAN) then
        -- 전설 등급 룬 확률 증가
        local type = 'dg_rune_legend_up'
        self:applyFevertime(type, t_hottime_calc_value)

        -- 룬 추가 획득
        local type = 'dg_rune_up'
        self:applyFevertime(type, t_hottime_calc_value)

        -- 룬 수호자 던전 날개 할인
        local type = 'dg_rg_st_dc'
        self:applyFevertime(type, t_hottime_calc_value)

    -- 콜로세움
	elseif (game_mode == GAME_MODE_ARENA) then
        -- 친선전 등 game_mode를 GAME_MODE_ARENA로 공유하는 모드가 많아서 stage_id까지 체크해야 한다.
        local stage_id = self.m_gameScene.m_stageID
        if (stage_id == ARENA_STAGE_ID) then
            -- 친선전 체크
            if (self.m_gameScene.m_bFriendMatch == false) then
                local type = 'pvp_honor_up'
                local is_active, value = g_fevertimeData:isActiveFevertimeByType(type)
                value = value * 100 -- fevertime에서는 1이 100%이기 때문에 100을 곱해준다.
                t_hottime_calc_value[type] = (t_hottime_calc_value[type] + value)
            end
        end
    -- 신규 콜로세움
	elseif (game_mode == GAME_MODE_ARENA_NEW) then
        local stage_id = self.m_gameScene.m_stageID
        if (stage_id == ARENA_NEW_STAGE_ID) then
            -- 친선전 체크
            if (self.m_gameScene.m_bFriendMatch == false) then
                local type = 'pvp_honor_up'
                local is_active, value = g_fevertimeData:isActiveFevertimeByType(type)
                value = value * 100 -- fevertime에서는 1이 100%이기 때문에 100을 곱해준다.
                t_hottime_calc_value[type] = (t_hottime_calc_value[type] + value)
            end
        end

    end


	-- start 통신에서 받아온 따끈한 핫타임 정보로 활성화 버프 수치 계산
    --for i, hot_key in pairs(l_hottime) do
    --    local t_info = g_hotTimeData:getHottimeInfo(hot_key)
	--	if (t_info) then
	--		t_hottime_calc_value[t_info['type']] = t_hottime_calc_value[t_info['type']] + t_info['value']
	--	end
    --end

	-- 계산한 버프 수치에 클랜 버프 추가하고 UI 처리하기 위한 데이터 생성
	for hottime_type, value in pairs(t_hottime_calc_value) do
		-- 클랜 버프 추가 -- 위쪽 코드에서 포함되도록 수정 20200608
		--if (not g_clanData:isClanGuest()) then
		--	value = value + g_clanData:getClanStruct():getClanBuffByType(CLAN_BUFF_TYPE[hottime_type:upper()])
		--end

		-- UI 처리용 데이터
		if (value > 0) then
			local t_ui_info = HOTTIME_UI_INFO[hottime_type]
			
			local btn_name = t_ui_info['button']
			vars[btn_name]:registerScriptTapHandler(function() g_hotTimeData:makeHotTimeToolTip(hottime_type, vars[btn_name]) end)
			
			local label_name = t_ui_info['label']
			vars[label_name]:setString(string.format(t_ui_info['format'], value))
			
			table.insert(l_item_ui, 1, btn_name)
		end
	end

    -- 자동 줍기 버튼은 가장 오른쪽에 배치하고 visible을 off로 설정 showAutoItemPickUI() 함수를 통해 visible을 켠다.
    table.insert(l_item_ui, 'hotTimeMarbleBtn')

    -- 버튼 정렬
    self:arrangeItemUI(l_item_ui)

    -- visible을 off로 설정 showAutoItemPickUI() 함수를 통해 visible을 켠다.
    if vars['hotTimeMarbleBtn'] then
        vars['hotTimeMarbleBtn']:setVisible(false)
    end
end

-------------------------------------
-- function applyFevertime
-- @param type 피버타임 타입
-- @param store_table 저장할 테이블
-- @brief 피버타임 type에 해당하는 값을 % 형식으로 store_table에 저장한다. -- ServerData_Fevertime으로 옮겨서 추후 커밋
-------------------------------------
function UI_Game:applyFevertime(type, store_table)
    local is_active, value = g_fevertimeData:isActiveFevertimeByType(type)
    value = value * 100 -- fevertime에서는 1이 100%이기 때문에 100을 곱해준다.
    store_table[type] = (store_table[type] + value)
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
        local ui = UI_AutoPlaySettingPopup(game_mode, true) -- game_mode, is_ingame
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
    elseif (game_mode == GAME_MODE_ARENA_NEW) then
        self.m_pauseUI = UI_GamePause_Arena(stage_id, gamekey, start_cb, end_cb)
    elseif (game_mode == GAME_MODE_CHALLENGE_MODE) then
        --self.m_pauseUI = UI_GamePause_ChallengeMode(stage_id, gamekey, start_cb, end_cb)
        self.m_pauseUI = UI_GamePause_Arena(stage_id, gamekey, start_cb, end_cb)
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
    local vars = self.vars
    local world = self.m_gameScene.m_gameWorld
    if (not world) then return end
    
    local max_time_scale_step = world.m_gameTimeScale:getMaxTimeScaleStep()
    local cur_timescale_step = world.m_gameTimeScale:increaseTimeScaleStep()

    if vars['speedVisual'] ~= nil then
        vars['speedVisual']:setVisible(cur_timescale_step == 2)
    end

    if vars['speedVisual2'] ~= nil then
        vars['speedVisual2']:setVisible(cur_timescale_step == 3)
    end

    if vars['speedUpVisual'] ~= nil then
        vars['speedUpVisual']:setVisible(max_time_scale_step > 2 and cur_timescale_step == 2)
    end
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
    self.m_dpsUI = dps_ui

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

    -- 룬 수호자 던전은 패널 비활성화
    local game_mode = self.m_gameScene.m_gameMode
    if (game_mode == GAME_MODE_RUNE_GUARDIAN) then
        self.m_panelUI:setPanelInActive()
    end

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
-- function setSnowParticle
-- @brief 게임 배경에 눈 내리는 파티클 추가
-------------------------------------
function UI_Game:setSnowParticle()
	local particle = cc.ParticleSystemQuad:create('res/ui/particle/dv_snow.plist')
	particle:setAnchorPoint(CENTER_POINT)
	particle:setDockPoint(CENTER_POINT)
	self.root:addChild(particle)
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
-- function init_speedUI
-------------------------------------
function UI_Game:init_speedUI()
    local vars = self.vars
    local world = self.m_gameScene.m_gameWorld
    if (world ~= nil) then
        local gameTimeScale = world.m_gameTimeScale 
        local cur_timescale_step = gameTimeScale:getTimeScaleStep()
        local max_time_scale_step = gameTimeScale:getMaxTimeScaleStep()

        if vars['speedVisual'] ~= nil then
            vars['speedVisual']:setVisible(cur_timescale_step == 2)
        end

        if vars['speedVisual2'] ~= nil then
            vars['speedVisual2']:setVisible(cur_timescale_step == 3)
        end

        if vars['speedUpVisual'] ~= nil then
            vars['speedUpVisual']:setVisible(max_time_scale_step > 2 and cur_timescale_step == 2)
        end
    end
end

-------------------------------------
-- function init_timeUI
-------------------------------------
function UI_Game:init_timeUI(display_wave, time)
    local vars = self.vars
    if (g_gameScene.m_gameMode == GAME_MODE_LEAGUE_RAID) then
        vars['timeNode']:setVisible(false)
        vars['waveVisual']:setVisible(false)

        self.m_timeLabel = vars['clanRaidtimeLabel']

        if (time) then
            self.m_timeLabel:setVisible(true)
            self:setTime(time)
        end

        return
    end

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
    local off_list = {'autoStartButton', 'autoButton', 'speedButton', 
                      'hottimeNode', 'chatBtn', 'pauseButton',
                      'effectBtn', 'buffBtn', 'dpsInfoNode',
                      'autoVisual'}

    for i, v in ipairs(off_list) do
        if (vars[v]) then
            vars[v]:setVisible(false)
        end
    end

    -- 인트로 전투에만 스킵 버튼 추가
    vars['skipBtn']:setVisible(true)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_skip() end)
end


-------------------------------------
-- function createAutoItemPickUI
-- @brief
-------------------------------------
function UI_Game:createAutoItemPickUI()
    local ui = UI_TooltipAutoItem()

    ui.vars['tooltipMenu']:setAnchorPoint(TOP_LEFT)
    ui.vars['tooltipMenu']:setDockPoint(TOP_LEFT)
    ui.vars['tooltipMenu']:setPosition(10, -170)
    self.m_tooltip = ui
    self.m_tooltip:setVisible(false)
end

-------------------------------------
-- function showAutoItemPickUI
-- @brief
-------------------------------------
function UI_Game:showAutoItemPickUI()
    local vars = self.vars

    if (not self.m_tooltip) then return end

    -- 클릭 시 툴팁 처리
    local function click_btn()
        if self.m_tooltip then
            if (not self.m_tooltip.m_isTouchLayerActivated) then
                local is_visible = self.m_tooltip:isVisible()
                self.m_tooltip:setVisible(not is_visible)
            end
        end
    end

    vars['hotTimeMarbleBtn']:registerScriptTapHandler(click_btn)
    vars['hotTimeMarbleBtn']:setVisible(true)
end

-------------------------------------
-- function arrangeItemUI
-- @brief itemUI들을 정렬한다!
-------------------------------------
function UI_Game:arrangeItemUI(l_hottime)
    for i, ui_name in pairs(l_hottime) do
        local ui = self.vars[ui_name]
        if (ui ~= nil) then
            ui:setVisible(true)
            local pos_x = 10 + ((i-1) * 72)
            ui:setPositionX(pos_x)
        end
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

-------------------------------------
-- function click_skip
-- @jhakim 190702 현재 인트로 전투에서만 사용
-------------------------------------
function UI_Game:click_skip()
    g_gameScene:showSkipPopup()
end

-------------------------------------
-- function offAutoStart
-------------------------------------
function UI_Game:offAutoStart()
    local vars = self.vars
    vars['autoStartButton']:setVisible(false)
    vars['autoStartNode']:setVisible(false)
    vars['autoStartNumberLabel']:setVisible(false)
    vars['autoStartVisual']:setVisible(false)
end

-------------------------------------
-- function lockAutoButton
-------------------------------------
function UI_Game:lockAutoButton()
    local vars = self.vars

	local is_auto_mode = false
    
	vars['autoButton']:setEnabled(false)
    vars['autoButton']:setVisible(true)
    vars['autoVisual']:setVisible(false)
    vars['autoLockSprite']:setVisible(true)

    -- 연속 전투 UI off
    vars['autoStartButton']:setVisible(false)
end

