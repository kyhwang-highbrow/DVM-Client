local PARENT = SceneGame

-------------------------------------
-- class SceneGameIntro
-------------------------------------
SceneGameIntro = class(PARENT, {
        m_bActionWait = 'boolean',
        m_bCheckAction = 'boolean'
    })

-------------------------------------
-- function init
-------------------------------------
function SceneGameIntro:init(game_key, stage_id, stage_name, develop_mode)
    -- 핫타임 관련 빈값으로 셋팅해줘야함 (통신하고 시작하는게 아님)
    g_hotTimeData:setIngameHotTimeList(game_key, {})

    self.m_stageName = 'stage_' .. INTRO_STAGE_ID
    self.m_bDevelopMode = true
    self.m_bCheckAction = false
end

-------------------------------------
-- function init_gameMode
-- @brief 스테이지 ID와 게임 모드 저장
-------------------------------------
function SceneGameIntro:init_gameMode()
    self.m_stageID = INTRO_STAGE_ID
    self.m_gameMode = GAME_MODE_INTRO
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneGameIntro:onEnter()
    g_gameScene = self
    PerpleScene.onEnter(self)

    SoundMgr:playBGM('bgm_colosseum')

    self.m_inGameUI = UI_Game(self)
    self.m_resPreloadMgr = ResPreloadMgr()
end

-------------------------------------
-- function prepare
-------------------------------------
function SceneGameIntro:prepare()
    self:addLoading(function()

        -- 레이어 생성
        self:init_layer()
        self.m_gameWorld = GameWorldIntro(self.m_gameMode, self.m_stageID, self.m_worldLayer, self.m_gameNode1, self.m_gameNode2, self.m_gameNode3, self.m_inGameUI, self.m_bDevelopMode)
        self.m_gameWorld:initGame(self.m_stageName)
        
        -- 스크린 사이즈 초기화
        self:sceneDidChangeViewSize()
    end)

    self:addLoading(function()
        -- 리소스 프리로드
        local ret = self.m_resPreloadMgr:loadForColosseum()
        return ret
    end)

    self:addLoading(function()
        -- FGT 에서는 디버그 기능을 제한한다
		if (not (TARGET_SERVER == 'FGT')) then 
			self.m_inGameUI:init_debugUI()
		end

		self.m_inGameUI:init_dpsUI()
		self.m_inGameUI:init_panelUI()
    end)
end

-------------------------------------
-- function update
-------------------------------------
function SceneGameIntro:update(dt)
    if (self.m_bPause) then return end

    -- 시전자가 최초 평타 어택시 시나리오 시작!
    local recorder = self.m_gameWorld.m_logRecorder
    --[[ 
    if (recorder:getLog('basic_attack_cnt') > 1) then
        self:gamePause()
        -- 대사 출력
    end 
    ]]--
    

    return PARENT.update(self, dt)
end

-------------------------------------
-- function networkGameFinish
-------------------------------------
function SceneGameIntro:networkGameFinish(t_param, t_result_ref, next_func)
    cclog('인트로 스테이지 종료')
    SceneLobby():runScene()
end

-------------------------------------
-- function init_loadingGuideType
-- @brief 로딩가이드 타입 - 인트로 전투일때 어떤 로딩?
-------------------------------------
function SceneGameIntro:init_loadingGuideType()
	self.m_loadingGuideType = 'in_adventure'
end	
