local PARENT = SceneGame


local LIMIT_TIME = 15
-------------------------------------
-- class SceneGameIllusion
-------------------------------------
SceneGameIllusion = class(PARENT, {
        m_realStartTime = 'number', -- 클랜 던전 시작 시간
        m_realLiveTimer = 'number', -- 클랜 던전 진행 시간 타이머
        m_enterBackTime = 'number', -- 백그라운드로 나갔을때 실제시간

        m_uiPopupTimeOut = 'UI',

        -- 서버 통신 관련
        m_bWaitingNet = 'boolean', -- 서버와 통신 중 여부
    })

-------------------------------------
-- function init
-------------------------------------
function SceneGameIllusion:init(game_key, stage_id, stage_name, develop_mode, friend_match)
    self.m_realStartTime = Timer:getServerTime()
    self.m_realLiveTimer = 0
    self.m_enterBackTime = nil
    self.m_uiPopupTimeOut = nil
    self.m_bWaitingNet = false
end

-------------------------------------
-- function prepare
-------------------------------------
function SceneGameIllusion:prepare()
    -- 테이블 리로드(메모리 보안을 위함)
    self:addLoading(function()
        TABLE:reloadForGame()
    end)

    self:addLoading(function()

        -- 레이어 생성
        self:init_layer()
        self.m_gameWorld = GameWorld_Illusion(self.m_gameMode, self.m_stageID, self.m_worldLayer, self.m_gameNode1, self.m_gameNode2, self.m_gameNode3, self.m_inGameUI, self.m_bDevelopMode)
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
-- function update
-------------------------------------
function SceneGameIllusion:update(dt)
    PARENT.update(self, dt)

    self:updateRealTimer(dt)
end

-------------------------------------
-- function updateRealTimer
-------------------------------------
function SceneGameIllusion:updateRealTimer(dt)
    local world = self.m_gameWorld
    local game_state = self.m_gameWorld.m_gameState
    
    -- 실제 진행 시간을 계산(배속에 영향을 받지 않도록 함)
    local bUpdateRealLiveTimer = false

    if (not world:isPause() or self.m_bPause) then
        bUpdateRealLiveTimer = true
    end

    if (bUpdateRealLiveTimer) then
        self.m_realLiveTimer = self.m_realLiveTimer + (dt / self.m_timeScale)
    end

    -- 시간 제한 체크 및 처리
    if (self.m_realLiveTimer > LIMIT_TIME and not world:isFinished()) then
        if (self.m_bPause) then
            -- 일시 정지 상태인 경우 즉시 점수 저장 후 종료
            world:setGameFinish()

            local t_param = game_state:makeGameFinishParam(false)

            -- 총 데미지
            t_param['damage'] = game_state:getTotalDamage()

            self:networkGameFinish(t_param, {}, function()
                self:showTimeOutPopup()
            end)
        else
            if (game_state and game_state:isTimeOut() == false) then
                game_state:processTimeOut()
            end
        end
    end

    -- UI 시간 표기 갱신
    local remain_time = self:getRemainTimer()
    self.m_inGameUI:setTime(remain_time, true)
end

-------------------------------------
-- function getRemainTimer
-------------------------------------
function SceneGameIllusion:getRemainTimer()
    local remain_time = math_max(LIMIT_TIME - self.m_realLiveTimer, 0)
    return remain_time
end