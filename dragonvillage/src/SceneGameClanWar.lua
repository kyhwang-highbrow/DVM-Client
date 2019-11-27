local PARENT = SceneGameArena

-------------------------------------
-- class SceneGameClanWar
-------------------------------------
SceneGameClanWar = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function SceneGameClanWar:init(game_key, stage_id, stage_name, develop_mode, friend_match)
    self.m_stageName = 'stage_clanwar'
    self.m_bDevelopMode = develop_mode
    self.m_bFriendMatch = friend_match or false
    self.m_gameKey = game_key

    self.m_sceneName = 'SceneGameClanWar'

    g_deckData:setSelectedDeck('clanwar')
end

-------------------------------------
-- function init_gameMode
-- @brief 스테이지 ID와 게임 모드 저장
-------------------------------------
function SceneGameClanWar:init_gameMode()
    self.m_stageID = CLAN_WAR_STAGE_ID
    self.m_gameMode = GAME_MODE_ARENA
    self.m_bgmName = 'bgm_colosseum'

    -- @E.T.
	g_errorTracker:set_lastStage(self.m_stageID)
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneGameClanWar:onEnter()
    g_gameScene = self
    PerpleScene.onEnter(self)

    SoundMgr:playBGM(self.m_bgmName)
    
    g_autoPlaySetting:setMode(AUTO_CLAN_WAR)

    if (IS_ARENA_AUTOPLAY()) then -- 테스트 모드에서 연속전투 활성화
    else
        g_autoPlaySetting:setAutoPlay(false)
    end
    
    self.m_inGameUI = UI_GameArena(self)
    self.m_resPreloadMgr = ResPreloadMgr()

    -- 절전모드 설정
    SetSleepMode(false)
end

-------------------------------------
-- function onExit
-------------------------------------
function SceneGameClanWar:onExit()
    PARENT.onExit(self)

    -- 절전모드 설정
    SetSleepMode(true)
end

-------------------------------------
-- function networkGamePlayStart
-- @brief 로딩 끝난 후 요청
-- @brief 기회 차감은 start가 아니라 play에서함 (비정상 종료 판단을 위해)
-------------------------------------
function SceneGameClanWar:networkGamePlayStart(next_func)
    -- 백그라운드로 한번만 요청하면서 다음 스텝으로 진행시킴
    local function success_cb(ret)
        if (ret['status'] ~= 0) then return end
        self:networkGamePlayStart_response(ret)
    end

    local enemy_struct_info = g_clanWarData:getEnemyUserInfo()
    local enemy_uid = enemy_struct_info.m_uid

    local t_param = {}
    t_param['uid'] = g_userData:get('uid')
    t_param['enemy_uid'] = enemy_uid
    t_param['day'] = g_clanWarData.m_clanWarDay
    t_param['season'] = g_clanWarData.m_season
    t_param['gamekey'] = g_clanWarData.m_gameKey

    local t_request = {}
    t_request['url'] = '/clanwar/play'
    t_request['method'] = 'POST'
    t_request['data'] = t_param
    t_request['success'] = success_cb
    
    Network:HMacRequest(t_request)

    -- @E.T.
	g_errorTracker:appendAPI(t_request['url'])

    if (next_func) then
        next_func()
    end
end

-------------------------------------
-- function makeLoadingUI
-- @brief scene전환 중 로딩화면 생성
-------------------------------------
function SceneGameClanWar:makeLoadingUI()
    return UI_LoadingClanWar(self)
end

-------------------------------------
-- function makeGameState
-- @brief
-------------------------------------
function SceneGameClanWar:makeGameState(game_world)
    return GameState_ClanWar(game_world)
end

-------------------------------------
-- function prepare
-------------------------------------
function SceneGameClanWar:prepare()
    -- 테이블 리로드(메모리 보안을 위함)
    self:addLoading(function()
        TABLE:reloadForGame()
    end)

    self:addLoading(function()

        -- 레이어 생성
        self:init_layer()
        self.m_gameWorld = GameWorldArena(self.m_gameMode, self.m_stageID, self.m_worldLayer, self.m_gameNode1, self.m_gameNode2, self.m_gameNode3, self.m_inGameUI, self.m_bDevelopMode, self.m_bFriendMatch)
        self.m_gameWorld:initGame(self.m_stageName)
        
        -- 스크린 사이즈 초기화
        self:sceneDidChangeViewSize()
    end)

    self:addLoading(function()
        -- 리소스 프리로드
        self.m_resPreloadMgr:resCaching('res/ui/a2d/colosseum_result/colosseum_result.vrp')

        Translate:a2dTranslate('ui/a2d/ingame_enemy/ingame_enemy.vrp')

        local ret = self.m_resPreloadMgr:loadForColosseum()
        return ret
    end)

    self:addLoading(function()
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
    end)
end

-------------------------------------
-- function prepareAfter
-------------------------------------
function SceneGameClanWar:prepareAfter()
    if (not self.m_bSuccessNetForPlayStart) then
        if (self.m_bDevelopMode) then
            self.m_bSuccessNetForPlayStart = true

        else
            -- play 통신에서 기회를 차감
            self:networkGamePlayStart(function()
                self.m_bSuccessNetForPlayStart = true
            end)
        end
    end

    return self.m_bSuccessNetForPlayStart
end

-------------------------------------
-- function getStructUserInfo_Opponent
-- @brief 상대방 유저 정보
-- @return StructUserInfo
-------------------------------------
function SceneGameClanWar:getStructUserInfo_Opponent()
    local user_info = g_clanWarData:getEnemyUserInfo()
    return user_info
end

-------------------------------------
-- function getStructUserInfo_Player
-- @brief 플레이어 유저 정보
-- @return StructUserInfo
-------------------------------------
function SceneGameClanWar:getStructUserInfo_Player()
    local user_info = g_clanWarData:getStructUserInfo_Player()
    return user_info
end
