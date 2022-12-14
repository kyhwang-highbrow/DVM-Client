local PARENT = SceneGame

-------------------------------------
-- class SceneGameChallengeMode
-------------------------------------
SceneGameChallengeMode = class(PARENT, {
        m_bFriendMatch = 'boolean', -- Arena와 같은 형태가 필요해서 사용하지 않지만 추가

        -- 서버 통신 관련
        m_bSuccessNetForPlayStart = 'boolean', -- 게임 시작 직전 서버와 통신 성공 여부(활동력 차감을 위함)
    })

-------------------------------------
-- function init
-------------------------------------
function SceneGameChallengeMode:init(game_key, stage_id, stage_name, develop_mode)
    self.m_gameKey = game_key
    self.m_stageName = 'stage_challenge_mode'
    self.m_bDevelopMode = develop_mode
    self.m_bFriendMatch = false -- Arena와 같은 형태가 필요해서 사용하지 않지만 추가

    self.m_sceneName = 'SceneGameChallengeMode'

    -- UI_ReadySceneNew.lua checkDeckProper() 함수와 통일해야함
    g_deckData:setSelectedDeck(DECK_CHALLENGE_MODE)

    self.m_bSuccessNetForPlayStart = false
end

-------------------------------------
-- function init_gameMode
-- @brief 스테이지 ID와 게임 모드 저장
-------------------------------------
function SceneGameChallengeMode:init_gameMode()
    self.m_stageID = CHALLENGE_MODE_STAGE_ID
    self.m_gameMode = GAME_MODE_CHALLENGE_MODE
    self.m_bgmName = 'bgm_colosseum'

    -- @E.T.
	g_errorTracker:set_lastStage(self.m_stageID)
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneGameChallengeMode:onEnter()
    g_gameScene = self
    PerpleScene.onEnter(self)

    SoundMgr:playBGM(self.m_bgmName)
    
    -- 챌린지 모드는 별도의 연속 전투가 없음
    --g_autoPlaySetting:setMode(AUTO_COLOSSEUM)
    g_autoPlaySetting:setAutoPlay(false)
    
    self.m_inGameUI = UI_GameChallengeMode(self)
    self.m_resPreloadMgr = ResPreloadMgr()

    -- 절전모드 설정
    SetSleepMode(false)
end

-------------------------------------
-- function onExit
-------------------------------------
function SceneGameChallengeMode:onExit()
    PARENT.onExit(self)

    -- 절전모드 설정
    SetSleepMode(true)
end

-------------------------------------
-- function makeLoadingUI
-- @brief scene전환 중 로딩화면 생성
-------------------------------------
function SceneGameChallengeMode:makeLoadingUI()
    return UI_LoadingChallengeMode(self)
end

-------------------------------------
-- function prepare
-------------------------------------
function SceneGameChallengeMode:prepare()
    -- 테이블 리로드(메모리 보안을 위함)
    self:addLoading(function()
        TABLE:reloadForGame()
    end)

    self:addLoading(function()

        -- 레이어 생성
        self:init_layer()
        local b_friend_match = false
        self.m_gameWorld = GameWorldArena(self.m_gameMode, self.m_stageID, self.m_worldLayer, self.m_gameNode1, self.m_gameNode2, self.m_gameNode3, self.m_inGameUI, self.m_bDevelopMode, b_friend_match)
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
function SceneGameChallengeMode:prepareAfter()
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
-- function networkGamePlayStart
-- @breif 게임 플레이 시작 시 요청
-------------------------------------
function SceneGameChallengeMode:networkGamePlayStart(next_func)
    -- 백그라운드로 한번만 요청하면서 다음 스텝으로 진행시킴
    local function success_cb(ret)
        if (ret['status'] ~= 0) then return end

        self:networkGamePlayStart_response(ret)
    end

    local t_request = {}
    t_request['url'] = '/game/challenge/play'
    t_request['method'] = 'POST'
    t_request['data'] = { uid = g_userData:get('uid'), stage = 1 }
    t_request['success'] = success_cb
    
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
function SceneGameChallengeMode:networkGamePlayStart_response(ret)
    -- 활동력 갱신
    g_serverData:networkCommonRespone(ret)
end


-------------------------------------
-- function prepareDone
-------------------------------------
function SceneGameChallengeMode:prepareDone()
    self.m_scheduleNode = cc.Node:create()
    self.m_scene:addChild(self.m_scheduleNode)
    self.m_scheduleNode:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
    
    self.m_gameWorld.m_gameState:changeState(GAME_STATE_START)
end

-------------------------------------
-- function makeGameState
-- @brief
-------------------------------------
function SceneGameChallengeMode:makeGameState(game_world)
    return GameState_ChallengeMode(game_world)
end

-------------------------------------
-- function getStructUserInfo_Player
-- @brief 플레이어 유저 정보
-- @return StructUserInfo
-------------------------------------
function SceneGameChallengeMode:getStructUserInfo_Player()
    local user_info = g_challengeMode:getPlayerArenaUserInfo()
    return user_info
end

-------------------------------------
-- function getStructUserInfo_Opponent
-- @brief 상대방 유저 정보
-- @return StructUserInfo
-------------------------------------
function SceneGameChallengeMode:getStructUserInfo_Opponent()
    -- 개발 모드일 경우
    if (self.m_bDevelopMode == true) then
    end

    local user_info = g_challengeMode:getMatchUserInfo()
    return user_info
end

-------------------------------------
-- function getStartOption_Opponent
-- @brief 상대방 드래곤들의 시작 버프
-------------------------------------
function SceneGameChallengeMode:getStartOption_Opponent()
    
    -- DIFFICULTY enum
    local difficulty = g_challengeMode:getSelectedDifficulty()

    -- table_option.csv의 key를 type으로 사용 가능
    local l_buff_list = {}

    -- 쉬움
    if (difficulty == DIFFICULTY.EASY) then
        -- 피해량 증가 : 주는 피해량 +{1}%
        table.insert(l_buff_list, {type='final_dmg_rate_multi', value=-80})

        -- 받는 피해량 감소 : 받는 피해량 -{1}%
        table.insert(l_buff_list, {type='dmg_adj_rate_multi', value=80})

        -- 치유량 감소 : 주는 치유량 -{1}%
        table.insert(l_buff_list, {type='final_heal_rate_multi_debuff', value=-80})

    -- 보통
    elseif (difficulty == DIFFICULTY.NORMAL) then

    -- 어려움
    elseif (difficulty == DIFFICULTY.HARD) then
        -- 피해량 증가 : 주는 피해량 +{1}%
        table.insert(l_buff_list, {type='final_dmg_rate_multi', value=20})

        -- 받는 피해량 감소 : 받는 피해량 -{1}%
        table.insert(l_buff_list, {type='dmg_adj_rate_multi', value=-20})

        -- 치유량 감소 : 주는 치유량 -{1}%
        table.insert(l_buff_list, {type='final_heal_rate_multi_debuff', value=15})
    
    -- 지옥
    elseif (difficulty == DIFFICULTY.HELL) then
        -- 피해량 증가 : 주는 피해량 +{1}%
        table.insert(l_buff_list, {type='final_dmg_rate_multi', value=35})

        -- 받는 피해량 감소 : 받는 피해량 -{1}%
        table.insert(l_buff_list, {type='dmg_adj_rate_multi', value=-35})

        -- 치유량 감소 : 주는 치유량 -{1}%
        table.insert(l_buff_list, {type='final_heal_rate_multi_debuff', value=20})

    else
        error('difficulty : ' .. tostring(difficulty))
    end


    return l_buff_list
end