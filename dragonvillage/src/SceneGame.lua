-- g_gameScene = nil

-------------------------------------
-- class SceneGame
-------------------------------------
SceneGame = class(PerpleScene, {
        m_stageName = '',
        m_stageID = '',
        m_stageParam = '',              -- 스테이지 정보 관련한 추가 파라미터(비밀던전에서 던전 고유 아이디)

        m_gameMode = 'GAME_MODE',
        m_dungeonMode = 'NEST_DUNGEON_MODE',
        m_dungeonSubMode = 'NEST_DUNGEON_SUB_MODE',

        m_bgmName = '',

        m_scheduleNode = 'cc.Node',
        m_gameWorld = 'GameWorld',

        -- 절전 모드 시간 계산을 위한 노드
        m_sleepModeNode = 'cc.Node',

        -- 레이어 관련 변수
        m_containerLayer = 'cc.Node',   -- (UI, 화면 연출에 관여)
        m_viewLayer = 'cc.Node',
        m_shakeLayer = 'cc.Node',       -- 화면 떨림 레이어
        m_cameraLayer = 'cc.Node',
        m_worldLayer = 'cc.Node',       -- 월드 레이어 (줌인, 줌아웃 관여)
        m_gameNode1 = 'cc.Node',        -- 게임 레이어 (배경, 유닛, 미사일 영역)
        m_gameNode2 = 'cc.Node',        -- 게임 레이어 (이펙트 및 폰트 영역)
        m_gameNode3 = 'cc.Node',        -- 게임 레이어 (pause, resume 제외하는 이펙트 및 폰트 영역)
        m_gameIndicatorNode = 'cc.Node',
        m_gameHighlightNode = 'cc.Node',    -- 하이라이트 레이어
        
        m_colorLayerForSkill = 'cc.LayerColor', -- 암전 레이어

        m_colorLayerTamerSkill = 'cc.LayerColor', -- 암전 레이어

        m_bStop = '',
        m_bPause = '',

        m_inGameUI = '',

        m_bDevelopMode = 'boolean',
        m_bDevelopStage = 'boolean',

        m_gameKey = 'number', -- 서버에서 넘어오는 고유 Key
        m_resPreloadMgr = 'ResPreloadMgr',
        m_fpsMeter = 'FpsMeter',

        -- 서버 통신 관련
        m_bSuccessNetForPlayStart = 'boolean', -- 게임 시작 직전 서버와 통신 성공 여부(활동력 차감을 위함)

        m_matchRule = 'string', -- 대전 룰  콜로세움과 친선전에서 사용

        m_uiDebug = 'boolean', -- 인게임 ui 확인
    })

-------------------------------------
-- function init
-------------------------------------
function SceneGame:init(game_key, stage_id, stage_name, develop_mode, stage_param)

	-- 벤치마크가 활성화 되었을 때 stage_id가 유효한지 체크
    if g_benchmarkMgr and g_benchmarkMgr:isActive() then
        g_benchmarkMgr:checkStageID(stage_id)
    end

    self.m_gameKey = game_key
    self.m_stageName = stage_name
    self.m_stageParam = stage_param

	self.m_sceneName = 'SceneGame'

    self.m_bUseLoadingUI = true
    self.m_bRemoveCache = true

    self.m_bStop = false
    self.m_bPause = false
    self.m_bDevelopMode = develop_mode or false
    self.m_bDevelopStage = false
    self.m_bShowTopUserInfo = false
    self.m_bSuccessNetForPlayStart = false

    self:init_gameMode(stage_id)
	self:init_loadingGuideType()
end

-------------------------------------
-- function init_gameMode
-- @brief 스테이지 ID와 게임 모드 저장
-------------------------------------
function SceneGame:init_gameMode(stage_id)
    self.m_stageID = stage_id

    -- game mode
    if (self.m_stageID == DEV_STAGE_ID) then
        self.m_gameMode = GAME_MODE_LEAGUE_RAID--GAME_MODE_ADVENTURE
        self.m_bDevelopStage = self.m_bDevelopMode
    else
        self.m_gameMode = g_stageData:getGameMode(self.m_stageID)
        if (self.m_gameMode == GAME_MODE_NEST_DUNGEON) then
            local t_dungeon = g_nestDungeonData:parseNestDungeonID(self.m_stageID)
            self.m_dungeonMode = t_dungeon['dungeon_mode']
            self.m_dungeonSubMode = t_dungeon['detail_mode']
        end
    end

    -- bgm
    if (self.m_gameMode == GAME_MODE_NEST_DUNGEON) then
        if (self.m_dungeonSubMode == NEST_DUNGEON_SUB_MODE_JEWEL) then
            self.m_bgmName = 'bgm_dungeon_boss'
        else
            self.m_bgmName = 'bgm_dungeon_special'
        end
            	
	elseif (self.m_gameMode == GAME_MODE_SECRET_DUNGEON) then
        self.m_bgmName = 'bgm_dungeon_special'

	elseif (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
		self.m_bgmName = 'bgm_dungeon_special'

    elseif (self.m_gameMode == GAME_MODE_EVENT_GOLD) then
		self.m_bgmName = 'bgm_dungeon_special'

    elseif (self.m_gameMode == GAME_MODE_ANCIENT_RUIN) then
		self.m_bgmName = 'bgm_dungeon_special'

    elseif (self.m_gameMode == GAME_MODE_RUNE_GUARDIAN) then
        self.m_bgmName = 'bgm_dungeon_special'

    else
        self.m_bgmName = 'bgm_dungeon'
    end

    -- @E.T.
	g_errorTracker:set_lastStage(self.m_stageID)
end

-------------------------------------
-- function init_loadingGuideType
-- @brief 로딩가이드 타입
-------------------------------------
function SceneGame:init_loadingGuideType()
	if (self.m_gameMode == GAME_MODE_ADVENTURE) then
		self.m_loadingGuideType = 'in_adventure'

	elseif (self.m_gameMode == GAME_MODE_NEST_DUNGEON) then
		if (self.m_dungeonMode == NEST_DUNGEON_EVO_STONE) then
			self.m_loadingGuideType = 'in_nest_es' -- in nest evolution stone

		elseif (self.m_dungeonMode == NEST_DUNGEON_NIGHTMARE) then
			self.m_loadingGuideType = 'in_nest_nm'

		elseif (self.m_dungeonMode == NEST_DUNGEON_TREE) then
			self.m_loadingGuideType = 'in_nest_tr'

        -- @ TODO 골드 던전 삭제
		elseif (self.m_dungeonMode == NEST_DUNGEON_GOLD) then
			self.m_loadingGuideType = 'in_nest_go'
		end

	elseif (self.m_gameMode == GAME_MODE_SECRET_DUNGEON) then
		self.m_loadingGuideType = 'in_adventure'

	elseif (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
		self.m_loadingGuideType = 'in_adventure'

    elseif (self.m_gameMode == GAME_MODE_EVENT_GOLD) then
		self.m_loadingGuideType = 'all'

    -- 고대 유적 던전
    elseif (self.m_gameMode == GAME_MODE_ANCIENT_RUIN) then
        self.m_loadingGuideType = 'in_nest_ar'

	else
        self.m_loadingGuideType = 'all'
    end
end

-------------------------------------
-- function init_layer
-- @brief 레이어 초기화
-------------------------------------
function SceneGame:init_layer()

    -- 일시정지 시 sleep mode를 관리하기 위한 코드
    self.m_sleepModeNode = cc.Node:create()
    self.m_scene:addChild(self.m_sleepModeNode)

    -- Scene에 최초로 add되는 레이어 (UI, 화면 연출에 관여)
    self.m_containerLayer = cc.Node:create()
    self.m_scene:addChild(self.m_containerLayer)

    do -- 뷰 레이어
        self.m_viewLayer = cc.Node:create()
        self.m_containerLayer:addChild(self.m_viewLayer)

        do -- 화면 떨림 레이어
            self.m_shakeLayer = cc.Node:create()
            self.m_viewLayer:addChild(self.m_shakeLayer)

			do -- 카메라 레이어
				self.m_cameraLayer = cc.Node:create()
				self.m_shakeLayer:addChild(self.m_cameraLayer)

				do -- 월드 레이어 (줌인, 줌아웃 관여)
					self.m_worldLayer = cc.Node:create()
					self.m_cameraLayer:addChild(self.m_worldLayer)

					do -- 게임 레이어 (배경, 유닛, 미사일 용)
						self.m_gameNode1 = cc.Node:create()
						self.m_worldLayer:addChild(self.m_gameNode1)

						-- 게임 레이어 (이펙트 및 폰트 용)
						self.m_gameNode2 = cc.Node:create()
						self.m_worldLayer:addChild(self.m_gameNode2)

						-- 게임 레이어 (pause 제외 이펙트 및 폰트 용)
						self.m_gameNode3 = cc.Node:create()
						self.m_worldLayer:addChild(self.m_gameNode3)

						-- 암전용 레이어
						self.m_colorLayerForSkill = cc.LayerColor:create()
						self.m_colorLayerForSkill:setColor(cc.c3b(0, 0, 0))
						self.m_colorLayerForSkill:setOpacity(100)
						self.m_colorLayerForSkill:setAnchorPoint(cc.p(0.5, 0.5))
						self.m_colorLayerForSkill:setDockPoint(cc.p(0, 0.5))
						self.m_colorLayerForSkill:setNormalSize(4000, 2000)
						self.m_colorLayerForSkill:setVisible(false)
						self.m_worldLayer:addChild(self.m_colorLayerForSkill)

						-- 하일라이트 레이어
						self.m_gameHighlightNode = cc.Node:create()
						self.m_worldLayer:addChild(self.m_gameHighlightNode)
                        
                        -- 스킬 인디케이터 레이어
						self.m_gameIndicatorNode = cc.Node:create()
						self.m_worldLayer:addChild(self.m_gameIndicatorNode, 99)
					end
				end
			end
        end
    end

	-- 암전용 레이어 (카메라 등의 영향 제외)
    self.m_colorLayerTamerSkill = cc.LayerColor:create()
    self.m_colorLayerTamerSkill:setColor(cc.c3b(255, 255, 255))
    self.m_colorLayerTamerSkill:setOpacity(0)
    self.m_colorLayerTamerSkill:setNormalSize(4000, 2000)
    self.m_colorLayerTamerSkill:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_colorLayerTamerSkill:setDockPoint(cc.p(0.5, 0.5))
    self.m_scene:addChild(self.m_colorLayerTamerSkill)
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneGame:onEnter()
    g_gameScene = self
    PerpleScene.onEnter(self)
    
    g_autoPlaySetting:setMode(AUTO_NORMAL)

    if (self.m_gameMode == GAME_MODE_EVENT_GOLD) then
        self.m_inGameUI = UI_GameEventGold(self)
    else
        self.m_inGameUI = UI_Game(self)
    end

    self.m_resPreloadMgr = ResPreloadMgr()

    -- 절전모드 설정
    SetSleepMode(false)
end

-------------------------------------
-- function onExit
-------------------------------------
function SceneGame:onExit()
    -- retain 된 Entity 들 해제 위하여 호출
    self:getGameWorld():cleanupUnit()
    self:getGameWorld():cleanupSkill()
    self:getGameWorld():cleanupItem()

    ScriptCache:clear()
    g_autoPlaySetting:save()
	g_gameScene = nil
    PerpleScene.onExit(self)

    -- 절전모드 설정
    SetSleepMode(true)
end

-------------------------------------
-- function prepare
-------------------------------------
function SceneGame:prepare()
    -- 테이블 리로드(메모리 보안을 위함)
    self:addLoading(function()
        TABLE:reloadForGame()
    end)

    self:addLoading(function()

        -- 레이어 생성
        self:init_layer()

        if (self.m_gameMode == GAME_MODE_ANCIENT_RUIN) then
            self.m_gameWorld = GameWorldForDoubleTeam(self.m_gameMode, self.m_stageID, self.m_worldLayer, self.m_gameNode1, self.m_gameNode2, self.m_gameNode3, self.m_inGameUI, self.m_bDevelopMode)
        
        elseif (self.m_gameMode == GAME_MODE_LEAGUE_RAID) then
            self.m_gameWorld = GameWorldLeagueRaid(self.m_gameMode, self.m_stageID, self.m_worldLayer, self.m_gameNode1, self.m_gameNode2, self.m_gameNode3, self.m_inGameUI, self.m_bDevelopMode)
        else
            self.m_gameWorld = GameWorld(self.m_gameMode, self.m_stageID, self.m_worldLayer, self.m_gameNode1, self.m_gameNode2, self.m_gameNode3, self.m_inGameUI, self.m_bDevelopMode)
        end
        self.m_gameWorld:initGame(self.m_stageName)
        
        -- 스크린 사이즈 초기화
        self:sceneDidChangeViewSize()
    end)

    self:addLoading(function()
        -- 리소스 프리로드
        Translate:a2dTranslate('ui/a2d/ingame_enemy/ingame_enemy.vrp')

        local ret = self.m_resPreloadMgr:loadFromStageId(self.m_stageID)
        return ret
    end)

    self:addLoading(function()
        -- UI 프리로드
        UILoader.cache('ingame_result.ui')
        UILoader.cache('ingame_pause.ui')
        return true
    end)

    self:addLoading(function()
		-- 테스트 모드에서만 디버그패널 on
		if (IS_TEST_MODE()) then
			self.m_inGameUI:init_debugUI()
		end

		self.m_inGameUI:init_dpsUI()
		self.m_inGameUI:init_panelUI()

        -- fps 미터기
        if (g_benchmarkMgr and g_benchmarkMgr:isActive()) or
            (g_settingData and g_settingData:get('fps')) then
            local fps_meter = FpsMeter()
            fps_meter:init_physWolrd(self.m_gameWorld.m_physWorld)
            self.m_fpsMeter = fps_meter
        end
    end)
end

-------------------------------------
-- function prepareAfter
-------------------------------------
function SceneGame:prepareAfter()
    if (not self.m_bSuccessNetForPlayStart) then
        if (self.m_bDevelopMode) then
            self.m_bSuccessNetForPlayStart = true

        else
            -- 활동력 차감을 위한 서버 통신
            self:networkGamePlayStart(function()
                self.m_bSuccessNetForPlayStart = true
            end)
        end
    end

    return self.m_bSuccessNetForPlayStart
end

-------------------------------------
-- function prepareDone
-------------------------------------
function SceneGame:prepareDone()
    local function cb_func()
        -- scenario 종료후 사운드 재생
        if (self.m_bgmName) then
            SoundMgr:playBGM(self.m_bgmName)
        end

        self.m_scheduleNode = cc.Node:create()
        self.m_scene:addChild(self.m_scheduleNode)
        self.m_scheduleNode:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
    
        self.m_gameWorld.m_gameState:changeState(GAME_STATE_START)
    end
    
    -- 시나리오 체크 및 시작
    self:startIngameScenario('snro_start', cb_func)     
end

-------------------------------------
-- function appearDone
-------------------------------------
function SceneGame:appearDone()
end

-------------------------------------
-- function update
-------------------------------------
function SceneGame:update(dt)
    if self.m_bStop then
        return
    end

    if self.m_bPause then
        return
    end
        
    local function func()
        self.m_gameWorld:updateBefore(dt)
		self.m_gameWorld:update(dt)
        self.m_gameWorld:updateAfter(dt)
    end

    local status, msg = xpcall(func, __G__TRACKBACK__)
    if not status then
        self.m_bStop = true
    end
end

-------------------------------------
-- function gamePause
-------------------------------------
function SceneGame:gamePause()
    if (not self.m_viewLayer) then return end

    self.m_bPause = true

    local function f_pause(node)
        node:pause()
    end
	
    doAllChildren(self.m_viewLayer, f_pause)

    -- 절전모드 설정
    self.m_sleepModeNode:removeAllChildren()
    SetSleepMode_After(self.m_sleepModeNode, 60) -- parent, seconds
end

-------------------------------------
-- function gameResume
-------------------------------------
function SceneGame:gameResume()
    if (not self.m_viewLayer) then return end

    self.m_bPause = false

    local function f_resume(node)
        node:resume()
    end

    doAllChildren(self.m_viewLayer, f_resume)

    -- 절전모드 설정
    self.m_sleepModeNode:removeAllChildren()
    SetSleepMode(false)
end

-------------------------------------
-- function sceneDidChangeViewSize
-------------------------------------
function SceneGame:sceneDidChangeViewSize()
    PerpleScene.sceneDidChangeViewSize(self)

    -- 스크린 사이즈 초기화
    local scr_size = cc.Director:getInstance():getWinSize()

    do -- 컨테이너 레이어를 항상 센터 위치로 이동
        local pos_x = scr_size['width']/2
        local pos_y = scr_size['height']/2
        --self.m_containerLayer:setPosition(pos_x, pos_y)
        self.m_containerLayer:stopAllActions()
        local scale_action = cc.MoveTo:create(0.2, cc.p(pos_x, pos_y))
        local ease_action = cc.EaseIn:create(scale_action, 2)
        self.m_containerLayer:runAction(ease_action)
    end

    do
        -- 뷰를 현재 해상도로 조정
        local scale = scr_size['width'] / CRITERIA_RESOLUTION_X
        if (scr_size['width'] > CRITERIA_RESOLUTION_X) then
            scale = scr_size['height'] / CRITERIA_RESOLUTION_Y
        end
        if is_ui_toggle then
            scale = scale * 0.95
        end
        self.m_viewLayer:stopAllActions()
        local scale_action = cc.ScaleTo:create(0.2, scale)
        local ease_action = cc.EaseIn:create(scale_action, 2)
        self.m_viewLayer:runAction(ease_action)
    end
end

-------------------------------------
-- function flashInOut
-- @brief 테이머 스킬 칼라 레이어를 페이드인
-------------------------------------
function SceneGame:flashInOut(tParam)
    local tParam = tParam or {}
	local cbEnd = tParam['cbEnd']
	local time = tParam['time'] or 0.5
	local color = tParam['color'] or cc.c3b(255, 255, 255)
    local opacity = tParam['opacity'] or 255

    local layer = self.m_colorLayerTamerSkill
	layer:setColor(color)
	layer:setOpacity(0)
	layer:runAction(cc.Sequence:create(
		--cc.FadeIn:create(time),
        cc.FadeTo:create(time, opacity),
        cc.FadeOut:create(time),
		cc.CallFunc:create(function(node)
			if cbEnd then
				cbEnd()
			end
		end)
	))
end

-------------------------------------
-- function flashIn
-- @brief 테이머 스킬 칼라 레이어를 페이드인
-------------------------------------
function SceneGame:flashIn(tParam)
	local tParam = tParam or {}
	local cbEnd = tParam['cbEnd']
	local time = tParam['time'] or 0.5
	local color = tParam['color'] or cc.c3b(255, 255, 255)
    local opacity = tParam['opacity'] or 255

    local layer = self.m_colorLayerTamerSkill
	layer:setColor(color)
	layer:setOpacity(0)
	layer:runAction(cc.Sequence:create(
		--cc.FadeIn:create(time),
        cc.FadeTo:create(time, opacity),
		cc.CallFunc:create(function(node)
			if cbEnd then
				cbEnd()
			end
		end)
	))
end

-------------------------------------
-- function flashOut
-- @brief 테이머 스킬 칼라 레이어를 페이드아웃
-------------------------------------
function SceneGame:flashOut(tParam)
	local tParam = tParam or {}
	local cbEnd = tParam['cbEnd']
	local time = tParam['time'] or 0.5
	
	local layer = self.m_colorLayerTamerSkill
	layer:runAction(cc.Sequence:create(
		cc.FadeOut:create(time),
		cc.CallFunc:create(function(node)
			if cbEnd then
				cbEnd()
			end
		end)
	))
end

-------------------------------------
-- function networkGamePlayStart
-- @breif 게임 플레이 시작 시 요청
-------------------------------------
function SceneGame:networkGamePlayStart(next_func)
    -- 백그라운드로 한번만 요청하면서 다음 스텝으로 진행시킴
    local function success_cb(ret)
        if (ret['status'] ~= 0) then return end

        self:networkGamePlayStart_response(ret)
    end


    cclog('start')
    local t_request = {}
    t_request['url'] = '/game/stage/play'
    t_request['method'] = 'POST'
    t_request['data'] = { uid = g_userData:get('uid'), stage = self.m_stageID }
    t_request['success'] = success_cb

    local game_mode = self.m_gameMode

    -- 룬 수호자 던전은 별도 API 사용
    if (game_mode == GAME_MODE_RUNE_GUARDIAN) then
        t_request['url'] = '/game/rune_guardian/play'
    end
    
    Network:HMacRequest(t_request)

    -- @E.T.
	g_errorTracker:appendAPI(t_request['url'])

    if (next_func) then
        next_func()
    end
end

-------------------------------------
-- function networkGamePlayStart_response
-- @breif
-------------------------------------
function SceneGame:networkGamePlayStart_response(ret)
    -- 활동력 갱신
    g_serverData:networkCommonRespone(ret)
end

-------------------------------------
-- function networkGameFinish
-- @breif
-------------------------------------
function SceneGame:networkGameFinish(t_param, t_result_ref, next_func)
    if (self.m_stageID == DEV_STAGE_ID) then
        if next_func then
            next_func()
        end
        return
    end

    local uid = g_userData:get('uid')
    local oid
    local send_score = false
    local attr
    local multi_deck_mgr -- 멀티덱 모드
    local auto -- 온전한 연속 전투인지 판단

    local function success_cb(ret)
        -- 클리어 타입은 서버에서 안줌
        local is_success = (t_param['clear_type'] == 1) and true or false
        self:networkGameFinish_response(ret, t_result_ref, is_success)



        if next_func then
            if ret['stage'] == nil then
                ret['stage'] = self.m_stageID
            end
            next_func(ret)
        end
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    local function response_status_cb(ret)
        -- invalid season
        if (ret['status'] == -1364) then
            -- 로비로 이동
            local function ok_cb()
                UINavigator:goTo('lobby')
            end 
            MakeSimplePopup(POPUP_TYPE.OK, Str('시즌이 종료되었습니다.'), ok_cb)
            return true
        end
        return false
    end

    -- 모드별 API 주소 분기처리
    local api_url = ''
    local game_mode = self.m_gameMode
    local ui_network = UI_Network()

    if (game_mode == GAME_MODE_ADVENTURE) then
        api_url = '/game/stage/finish'

    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        api_url = '/game/nest/finish'
        auto = g_autoPlaySetting:getSequenceAutoPlay() and 1 or 0

    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        api_url = '/game/secret/finish'

        -- 던전 objectId
        local t_dungeon_info = g_secretDungeonData:getSelectedSecretDungeonInfo()
        oid = t_dungeon_info['id']

    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        send_score = true

        local _attr = g_attrTowerData:getSelAttr()
        -- 시험의 탑
        if (_attr) then
            attr = _attr
            api_url = '/game/attr_tower/finish'

        -- 고대의 탑
        else
            api_url = '/game/ancient/finish'
        end

    -- 이벤트 황금 던전
    elseif (game_mode == GAME_MODE_EVENT_GOLD) then
        api_url = '/game/event_dungeon/finish'

    -- 고대 유적 던전
    elseif (game_mode == GAME_MODE_ANCIENT_RUIN) then
        api_url = '/game/ruin/finish'
        multi_deck_mgr = MultiDeckMgr(MULTI_DECK_MODE.ANCIENT_RUIN)
        auto = g_autoPlaySetting:getSequenceAutoPlay() and 1 or 0

    -- 룬 수호자 던전
    elseif (game_mode == GAME_MODE_RUNE_GUARDIAN) then
        api_url = '/game/rune_guardian/finish'

    elseif (game_mode == GAME_MODE_DIMENSION_GATE) then
        api_url = '/dmgate/finish'

    elseif (game_mode == GAME_MODE_LEAGUE_RAID) then
        -- 클리어 타입은 서버에서 안줌
        local is_success = (t_param['clear_type'] == 1) and true or false

        api_url = is_success and '/raid/finish' or '/raid/fail'

        total_damage = math_floor(g_leagueRaidData.m_currentDamage)
        ui_network:setParam('score', total_damage)
    end

    
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', self.m_stageID)
    ui_network:setParam('oid', oid)
    -- 멀티덱 사용한 경우 - 덱네임 2개 보냄 (상단, 하단)
    if (multi_deck_mgr) then
        ui_network:setParam('deck_name1', multi_deck_mgr:getDeckName('up'))
        ui_network:setParam('deck_name2', multi_deck_mgr:getDeckName('down'))
    else
        ui_network:setParam('deck_name', t_param['deck_name'])
    end
    ui_network:setParam('clear_type', t_param['clear_type'])
    ui_network:setParam('clear_wave', t_param['clear_wave'])
    ui_network:setParam('exp_rate', t_param['exp_rate'])
    ui_network:setParam('clear_mission_1', t_param['clear_mission_1'] and 1 or 0)
    ui_network:setParam('clear_mission_2', t_param['clear_mission_2'] and 1 or 0)
    ui_network:setParam('clear_mission_3', t_param['clear_mission_3'] and 1 or 0)
    ui_network:setParam('gold', t_param['gold'])
    ui_network:setParam('gold_rate', t_param['gold_rate'])
    ui_network:setParam('gamekey', self.m_gameKey)
    ui_network:setParam('bonus_items', t_param['bonus_items'])
    ui_network:setParam('clear_time', t_param['clear_time'])
    ui_network:setParam('check_time', g_accessTimeData:getCheckTime())
    ui_network:setParam('rune_autosell', t_param['rune_autosell'])
    

    if (attr) then
        ui_network:setParam('attr', attr)
    end

    -- 접속시간 저장
    local save_time = g_accessTimeData:getSaveTime()
    if (save_time) then
        ui_network:setParam('access_time', save_time)
    end

    if (send_score) then
        ui_network:setParam('score', t_param['score'])
    end

    -- 온전한 연속 전투 로그를 위해 보냄
    if (auto ~= nil) then
        ui_network:setParam('auto', auto)
    end

    -- 연속 전투의 경우 네트워크 에러 시 잠시 대기후 재요청보냄
    if (g_autoPlaySetting:isAutoPlay()) then
        ui_network:setRetryCount_forGameFinish()
    end

    ui_network:setRevocable(false) -- 게임 종료 통신은 취소를 하지 못함
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function networkGameFinish_response
-- @breif
-- @param t_result_ref 결과화면에서 사용하기 위한 각종 정보들 저장
--        t_result_ref['user_levelup_data'] = {}
--        t_result_ref['dragon_levelu_data_list'] = {}
-------------------------------------
function SceneGame:networkGameFinish_response(ret, t_result_ref, is_success)
    -- 스테이지 관련 통계 (증가된 재화 체크 하기 위해 networkCommonRespone 앞에 호출!)
    self:networkGameFinish_response_analytics(ret, is_success)

    -- server_info, staminas 정보를 갱신
    g_serverData:networkCommonRespone(ret)
    g_serverData:networkCommonRespone_addedItems(ret)

    -- 유저 정보 변경사항 적용 (레벨, 경험치)
    self:networkGameFinish_response_user_info(ret, t_result_ref)

    -- 변경된 드래곤 적용
    self:networkGameFinish_response_modified_dragons(ret, t_result_ref)

    -- 드랍 정보 drop_reward
    self:networkGameFinish_response_drop_reward(ret, t_result_ref)

    -- 발견된 비밀 던전
    self:networkGameFinish_response_secret_dungeon(ret, t_result_ref)

    -- 스테이지 클리어 정보 stage_clear_info
    self:networkGameFinish_response_stage_clear_info(ret)

    -- 모험모드 챕터 업적
    self:networkGameFinish_response_chapter_achievement_info(ret)

    -- 적용된 핫타임 항목 리스트 (모험 모드에서만 사용 170704)
    t_result_ref['hottime'] = ret['hottime'] or {}

    -- 스테이지 클리어하면 잠금해제되는 컨텐츠 리스트 갱신
    if (ret['content_unlock_list']) then
        g_contentLockData:applyContentLockByStage(ret['content_unlock_list'])
    end

	-- 깜짝 출현 이벤트에서만 사용
	if (ret['xmas_daily_egg_info']) then
        g_eventAdventData:responseDailyAdventEggInfo(ret['xmas_daily_egg_info'])
    end

    -- 할로윈 룬 축제(할로윈 이벤트)
	if (ret['rune_festival_info']) then
        g_eventRuneFestival:applyRuneFestivalInfo(ret['rune_festival_info'])
    end

    -- 자동 줍기으로 획득한 누적 아이템 수량 갱신
    g_subscriptionData:response_ingameDropInfo(ret)

    -- 일일 드랍 아이템 획득량 갱신
    g_userData:response_ingameDropInfo(ret)
end

-------------------------------------
-- function networkGameFinish_response_user_info
-- @breif 유저 정보 변경사항 적용 (레벨, 경험치)
-------------------------------------
function SceneGame:networkGameFinish_response_user_info(ret, t_result_ref)
    local user_levelup_data = t_result_ref['user_levelup_data']

    -- 이전 레벨과 경험치
    user_levelup_data['prev_lv'] = g_userData:get('lv')
    user_levelup_data['prev_exp'] = g_userData:get('exp')

    do -- 서버에서 넘어온 레벨과 경험치 적용
        if ret['lv'] then
            g_userData:applyServerData(ret['lv'], 'lv')

            -- 채팅 서버에 변경사항 적용
            g_lobbyChangeMgr:globalUpdatePlayerUserInfo()
        end

        if ret['exp'] then
            g_userData:applyServerData(ret['exp'], 'exp')
        end
    end

    -- 현재 레벨과 경험치
    user_levelup_data['curr_lv'] = g_userData:get('lv')
    user_levelup_data['curr_exp'] = g_userData:get('exp')

    -- 현재 레벨의 최대 경험치
    local table_user_level = TableUserLevel()
    local lv = g_userData:get('lv')
    local curr_max_exp = table_user_level:getReqExp(lv)
    user_levelup_data['curr_max_exp'] = curr_max_exp

    -- 최대 레벨 여부
    user_levelup_data['is_max_level'] = (curr_max_exp == 0)

    do -- 추가 경험치 총량
        local low_lv = user_levelup_data['prev_lv']
        local low_lv_exp = user_levelup_data['prev_exp']
        local high_lv = user_levelup_data['curr_lv']
        local high_lv_exp = user_levelup_data['curr_exp']
        user_levelup_data['add_exp'] = table_user_level:getBetweenExp(low_lv, low_lv_exp, high_lv, high_lv_exp)
    end    

    -- 레벨이 아닌 다른 컨텐츠 오픈 조건
    local t_content_open = t_result_ref['content_open']
    if (t_content_open) then
        do -- 시험의 탑 오픈 정보
            local open = ret['attr_tower_open']
            if (open and open == true) then
                t_content_open['open'] = open
                g_userData:applyServerData(open, 'attr_tower_open')
            end
        end

        do -- 고대 유적 던전 오픈 정보
            local open = ret['ruin_open']
            if (open and open == true) then
                t_content_open['open'] = open
            end
        end
    end

    -- 레벨이 변경되었을 경우 Tapjoy유저 레벨 정보를 갱신하기 위해 호출
    if (user_levelup_data['prev_lv'] ~= user_levelup_data['curr_lv']) then
        -- @analytics (Tapjoy)
        Analytics:userInfo()

        -- @mskim 20.09.14 레벨업 패키지 출력에도 사용함
        g_personalpackData:push(PACK_LV_UP, user_levelup_data['curr_lv'])
    end
end

-------------------------------------
-- function networkGameFinish_response_modified_dragons
-- @breif 드래곤 변경사항 적용 (레벨, 경험치)
-------------------------------------
function SceneGame:networkGameFinish_response_modified_dragons(ret, t_result_ref)
    if (not ret['modified_dragons']) then
        return
    end

    local dragon_levelu_data_list = t_result_ref['dragon_levelu_data_list']
    local table_dragon = TableDragon()

    for _,t_dragon in ipairs(ret['modified_dragons']) do
        local udid = t_dragon['id']
        local did = t_dragon['did']
            
        -- 변경 전 드래곤 정보
        local t_prev_dragon_data = g_dragonsData:getDragonDataFromUid(udid)

        -- 서버에서 넘어온 드래곤 정보 저장
        g_dragonsData:applyDragonData(t_dragon)

        -- 변경 후 드래곤 정보
        local t_next_dragon_data = g_dragonsData:getDragonDataFromUid(udid)

        -- 드래곤 레벨업 연출을 위한 데이터
        local levelup_data = {}
        do
             levelup_data['prev_lv'] = t_prev_dragon_data['lv']
             levelup_data['prev_exp'] = t_prev_dragon_data['exp']
             levelup_data['curr_lv'] = t_next_dragon_data['lv']
             levelup_data['curr_exp'] = t_next_dragon_data['exp']

             local max_level = dragonMaxLevel(t_next_dragon_data['grade'])
             local is_max_level = (t_next_dragon_data['lv'] >= max_level)
             levelup_data['is_max_level'] = is_max_level
        end

        -- t_data에 정보를 담음
        local t_data = {}
        t_data['levelup_data'] = levelup_data
        t_data['user_data'] = t_next_dragon_data
        t_data['table_data'] = table_dragon:get(did)

        -- 레퍼런스 테이블에 insert
        table.insert(dragon_levelu_data_list, t_data)
    end
end

-------------------------------------
-- function networkGameFinish_response_drop_reward
-- @breif 드랍 보상 데이터 처리
-------------------------------------
function SceneGame:networkGameFinish_response_drop_reward(ret, t_result_ref)
    if (not ret['added_items']) then
        return
    end

    local items_list = ret['added_items']['items_list']

    if (not items_list) then
        return
    end

    local drop_reward_list = t_result_ref['drop_reward_list']

    -- 드랍 아이템에 의한 보너스
    local l_bonus_item = {}
    for i,v in ipairs(items_list) do
        local item_id = v['item_id']
        local count = v['count']
        local from = v['from']
        local data = nil

        
        if v['oids'] then
            -- Object는 하나만 리턴한다고 가정 (dragon or rune)
            local oid = v['oids'][1]
            if oid then
                -- 드래곤에서 정보 검색
                for _,obj_data in ipairs(ret['added_items']['dragons']) do
                    if (obj_data['id'] == oid) then
                        data = StructDragonObject(obj_data)
                        break
                    end
                end

                -- 룬에서 정보 검색
                if (not data) then
                    for _,obj_data in ipairs(ret['added_items']['runes']) do
                        if (obj_data['id'] == oid) then
                            data = StructRuneObject(obj_data)
                            break
                        end
                    end
                end
            end
        end

        -- 기본으로 주는 골드도 표기하기로 결정함
        if (from == 'drop') then
            
            -- 하이브로 캡슐은 한국서버에서만 드랍 처리
            if (item_id == TableItem:getItemIDFromItemType('capsule')) then
                if g_localData:isShowHighbrowShop() then
                    local t_data = {item_id, count, from, data}
                    table.insert(drop_reward_list, t_data)
                end            
            else
                local t_data = {item_id, count, from, data}
                table.insert(drop_reward_list, t_data)
            end

        -- 스테이지에서 기본으로 주는 골드 량
        elseif (from == 'default') then
            local t_data = {item_id, count, from, data}
            table.insert(drop_reward_list, t_data)

        -- 드랍 아이템에 의한 보너스
        elseif (from == 'bonus') then
            if (not l_bonus_item[item_id]) then
                l_bonus_item[item_id] = 0
            end
            l_bonus_item[item_id] = l_bonus_item[item_id] + count

        -- 이벤트 아이템 (ex:송편)
        elseif (from == 'event') or (from == 'event_bingo') then
            local t_data = {item_id, count, from, data}
            table.insert(drop_reward_list, t_data)

        -- 첫 클리어 보상, 반복 보상(고대의 탑, 시험의 탑에서 사용)
        elseif (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
            local attr = g_attrTowerData:getSelAttr()
            if (attr) then
                if (from == 'reward_first_'..attr) or (from == 'reward_repeat_'..attr) then
                    local t_data = {item_id, count, from, data}
                    table.insert(drop_reward_list, t_data)
                end

            else
                if (from == 'reward_first') or (from == 'reward_repeat') then
                    local t_data = {item_id, count, from, data}
                    table.insert(drop_reward_list, t_data)
                end
            end
        end
    end

    -- 보너스 아이템 추가
    for i,v in pairs(l_bonus_item) do
        local t_data = {i, v, 'bonus'}
        table.insert(drop_reward_list, t_data)
    end
end

-------------------------------------
-- function networkGameFinish_response_secret_dungeon
-- @breif 발견된 비밀 던전 데이터 처리
-------------------------------------
function SceneGame:networkGameFinish_response_secret_dungeon(ret, t_result_ref)
    if (not ret['secret_dungeon']) then
        return
    end

    t_result_ref['secret_dungeon'] = ret['secret_dungeon']

    g_secretDungeonData:setFindSecretDungeon(ret['secret_dungeon'])
end

-------------------------------------
-- function networkGameFinish_response_stage_clear_info
-- @breif
-------------------------------------
function SceneGame:networkGameFinish_response_stage_clear_info(ret)

    -- 고대의 탑 클리어 최고층 저장
    if (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
        if ret['ancient_clear_stage'] then
            g_ancientTowerData:setClearStage(ret['ancient_clear_stage'])
        end
    end

    if (not ret['stage_clear_info']) then
        return
    end

    -- 리스트 형태로 넘어와서 한개만 추출
    local stage_clear_info = table.getFirst(ret['stage_clear_info'])
    local stage_id = ret['stage']
   
    if (self.m_gameMode == GAME_MODE_ADVENTURE) then
        
        -- 스테이지 정보 갱신이 필요한 경우 설정
        g_adventureData:setDirtyStageList()

        if (stage_clear_info) then
            local stage_info = g_adventureData:getStageInfo(stage_id)
            stage_info:applyTableData(stage_clear_info)

             -- @mskim 20.09.14 챕터 클리어 시 모험돌파 패키지 출력
            g_personalpackData:push(PACK_ADVENTURE, stage_clear_info, stage_id)
        end

        -- 스테이지 클리어 통계
        do
            local difficulty, chapter, stage = parseAdventureID(stage_id)
            local save_key = Str('{1}_{2}', chapter, stage)
            local msg

            if (chapter == 1) then
                msg = string.format('Stage_%s_Finish', save_key)

            elseif (chapter == 2) then
                msg = string.format('Stage_%s_Finish', save_key)
                
            end
            
            if (msg) then
                -- @analytics
                Analytics:firstTimeExperience(msg)
            end

            --adjust
            if difficulty == 1 then
                if chapter == 1 and stage == 2 then
                    Adjust:trackEvent(Adjust.EVENT.TUTORIAL_FINISH_1_2)
                elseif chapter == 1 and stage == 7 then
                    Adjust:trackEvent(Adjust.EVENT.STAGE_FINISH_1_7)
                end
            end
        end

    elseif (self.m_gameMode == GAME_MODE_NEST_DUNGEON or self.m_gameMode == GAME_MODE_ANCIENT_RUIN) then
        g_nestDungeonData:applyNestStageClearCnt(stage_id, stage_clear_info['cl_cnt'])

    elseif (self.m_gameMode == GAME_MODE_SECRET_DUNGEON) then

    elseif (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
        if (stage_id == ANCIENT_TOWER_STAGE_ID_START + 1) then
            -- @analytics
            Analytics:firstTimeExperience('AncientTower_1_Clear')
        end

    -- 차원문
    elseif (self.m_gameMode == GAME_MODE_DIMENSION_GATE) then

        
    end
end

-------------------------------------
-- function networkGameFinish_response_chapter_achievement_info
-- @breif
-------------------------------------
function SceneGame:networkGameFinish_response_chapter_achievement_info(ret)
    if (not ret['chapter_list']) then
        return
    end

    -- 리스트 형태로 넘어와서 한개만 추출
    local data = table.getFirst(ret['chapter_list'])
    if (not data) then
        return
    end

    if (self.m_gameMode == GAME_MODE_ADVENTURE) then
        local chapter_id = data['chapter_id']
        local chapter_achieve_info = g_adventureData:getChapterAchieveInfo(chapter_id)
        chapter_achieve_info:applyTableData(data)
    end
end

-------------------------------------
-- function networkGameFinish_response_analytics
-- @breif
-------------------------------------
function SceneGame:networkGameFinish_response_analytics(ret, is_success)
    -- @analytics
    local added_items = ret['added_items']
    if (not added_items) then return end

    Analytics:trackGetGoodsWithRet(ret, '인게임 드랍', 'bonus')

    local stage_id = self.m_stageID

    if (self.m_gameMode == GAME_MODE_ADVENTURE) then
        local desc = string.format('모험 : %d', stage_id)
        Analytics:trackGetGoodsWithRet(ret, desc, 'default')
        Analytics:trackGetGoodsWithRet(ret, desc, 'drop')

        -- 도전 / 클리어
        local difficulty, chapter, stage = parseAdventureID(stage_id)
        local str_difficulty = ''
        if (difficulty == 1) then
            str_difficulty = 'easy'

        elseif (difficulty == 2) then
            str_difficulty = 'normal'

        elseif (difficulty == 3) then
            str_difficulty = 'hard'
        end
        local desc = string.format('%s %d-%d', str_difficulty, chapter, stage)
        Analytics:trackEvent(CUS_CATEGORY.PLAY, CUS_EVENT.TRY_ADV, 1, desc)
        if (is_success) then
            Analytics:trackEvent(CUS_CATEGORY.PLAY, CUS_EVENT.CLR_ADV, 1, desc)
        end

    elseif (self.m_gameMode == GAME_MODE_NEST_DUNGEON) then
        local t_dungeon = g_nestDungeonData:parseNestDungeonID(stage_id)
        local dungeonMode = t_dungeon['dungeon_mode']

        local desc 
        if (dungeonMode == NEST_DUNGEON_EVO_STONE) then
            desc = string.format('거대용 : %d', stage_id)
        elseif (dungeonMode == NEST_DUNGEON_NIGHTMARE) then
            desc = string.format('악몽 : %d', stage_id)
        elseif (dungeonMode == NEST_DUNGEON_TREE) then
            desc = string.format('거목 : %d', stage_id)
        end

        Analytics:trackGetGoodsWithRet(ret, desc, 'default')
        Analytics:trackGetGoodsWithRet(ret, desc, 'drop')

        Analytics:trackEvent(CUS_CATEGORY.PLAY, CUS_EVENT.TRY_DGN, 1, desc)
        if (is_success) then
            Analytics:trackEvent(CUS_CATEGORY.PLAY, CUS_EVENT.CLR_DGN, 1, desc)
        end

    elseif (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
        local desc = string.format('고대의 탑 : %d', stage_id)
        Analytics:trackGetGoodsWithRet(ret, desc)

        Analytics:trackEvent(CUS_CATEGORY.PLAY, CUS_EVENT.TRY_DGN, 1, desc)
        if (is_success) then
            Analytics:trackEvent(CUS_CATEGORY.PLAY, CUS_EVENT.CLR_DGN, 1, desc)
        end
    end
end

-------------------------------------
-- function startIngameScenario
-- @breif 여기서 주관하는게 맞을까
-------------------------------------
function SceneGame:startIngameScenario(scenario_type, cb_func)
    -- 콜백
    local function start()
        self.m_containerLayer:setVisible(true)
        if (cb_func) then
            cb_func()
        end
    end
    
    -- 스테이지 id와 시나리오 타입(start or finish)로 시나리오를 찾아와 있으면 재생
    local stage_id = self.m_stageID
    local scenario_name = TableStageDesc:getScenarioName(stage_id, scenario_type)
    if scenario_name then
        local ui = g_scenarioViewingHistory:playScenario(scenario_name)
        if ui then
			
			-- 자동 전투 중 시나리오 플레이된다면 해제시켜줌
			if (g_autoPlaySetting:isAutoPlay()) then
				self.m_inGameUI:click_autoStartButton()
			end

            self.m_containerLayer:setVisible(false)
            ui:setCloseCB(start)
            ui:next()
            return 
        end
    end

    -- 시나리오를 재생 못하고 콜백 콜
    start()       
end

-------------------------------------
-- function applicationDidEnterBackground
-------------------------------------
function SceneGame:applicationDidEnterBackground()
    if (not self.m_bPause) and (self.m_gameWorld) and (not self.m_gameWorld:isFinished()) then
        if (self.m_gameWorld.m_skillIndicatorMgr) then
            self.m_gameWorld.m_skillIndicatorMgr:clear()
        end
        self.m_inGameUI:click_pauseButton()
    end
end

-------------------------------------
-- function applicationWillEnterForeground
-------------------------------------
function SceneGame:applicationWillEnterForeground()
    -- 앱이 백그라운드로 왔다리 갔다리 할 때 pause가 풀릴 때도 있어서
    -- 예상못한 시간의 흐름을 방지하기 위해 아무것도 하지 않는게 좋다
    --if (self.m_inGameUI) then
    --    self.m_inGameUI:closePauseUI()
    --end
end

-------------------------------------
-- function getGameWorld
-------------------------------------
function SceneGame:getGameWorld()
    return self.m_gameWorld
end

-------------------------------------
-- function showSkipPopup
-------------------------------------
function SceneGame:showSkipPopup()
end