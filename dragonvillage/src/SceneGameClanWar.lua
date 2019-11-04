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

    self.m_sceneName = 'SceneGameClanWar'

    g_deckData:setSelectedDeck('clan_war')
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
    
    g_autoPlaySetting:setMode(AUTO_COLOSSEUM)

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
-- function makeLoadingUI
-- @brief scene전환 중 로딩화면 생성
-------------------------------------
function SceneGameClanWar:makeLoadingUI()
    return UI_LoadingArena(self)
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
    -- 콜로세움은 어뷰징 이슈로 playstart 요청을 하지 않음
    return true
end

-------------------------------------
-- function getStructUserInfo_Opponent
-- @brief 상대방 유저 정보
-- @return StructUserInfo
-------------------------------------
function SceneGameClanWar:getStructUserInfo_Opponent()
    local user_info = g_arenaData:getPlayerArenaUserInfo() -- 임의로 자기자신과 결투
    return user_info
end

-------------------------------------
-- function getStructUserInfo_Player
-- @brief 플레이어 유저 정보
-- @return StructUserInfo
-------------------------------------
function SceneGameClanWar:getStructUserInfo_Player()
    local user_info = g_arenaData:getPlayerArenaUserInfo() -- 임의로 자기자신
    return user_info
end