local PARENT = SceneGame

-------------------------------------
-- class SceneGameIllusion
-------------------------------------
SceneGameIllusion = class(PARENT, {
        m_realStartTime = 'number', -- 환상 던전 시작 시간
        m_realLiveTimer = 'number', -- 환상 던전 진행 시간 타이머
        m_enterBackTime = 'number', -- 백그라운드로 나갔을때 실제시간

        m_uiPopupTimeOut = 'UI',

        -- 서버 통신 관련
        m_bWaitingNet = 'boolean', -- 서버와 통신 중 여부
    })

-------------------------------------
-- function init
-------------------------------------
function SceneGameIllusion:init(game_key, stage_id, stage_name, develop_mode, friend_match)
    self.m_realStartTime = ServerTime:getInstance():getCurrentTimestampSeconds()
    self.m_realLiveTimer = 0
    self.m_enterBackTime = nil
    self.m_uiPopupTimeOut = nil
    self.m_bWaitingNet = false
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneGameIllusion:onEnter()
    g_gameScene = self
    PerpleScene.onEnter(self)
 
    self.m_inGameUI = UI_GameIllusion(self)
    self.m_resPreloadMgr = ResPreloadMgr()

    -- 절전모드 설정
    SetSleepMode(false)
end

-------------------------------------
-- function init_gameMode
-- @brief 스테이지 ID와 게임 모드 저장
-------------------------------------
function SceneGameIllusion:init_gameMode(stage_id)
    self.m_stageID = stage_id

    self.m_gameMode = GAME_MODE_EVENT_GOLD
    self.m_bgmName = 'bgm_dungeon'

    -- @E.T.
	g_errorTracker:set_lastStage(self.m_stageID)
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

end

-------------------------------------
-- function updateFightTimer
-------------------------------------
function SceneGameIllusion:updateFightTimer(dt)
    -- 전투 상태에서만 타임 계산
    if (not isExistValue(self.m_state, GAME_STATE_FIGHT)) then return end

    local has_limit = (self.m_limitTime > 0)
    local time = self.m_fightTimer

    -- 플레이 시간 계산
    self.m_fightTimer = self.m_fightTimer + dt

    if (has_limit) then
        -- 제한 시간이 있을 경우
        if (self.m_fightTimer >= self.m_limitTime) then
            self.m_fightTimer = self.m_limitTime

            -- 제한 시간이 넘었을 경우 처리
            self:processTimeOut()
        end

        -- 남은 제한 시간을 표시
        time = self:getRemainTime()
	else
        -- 제한시간이 없을 경우 플레이 시간 표시
        time = self.m_fightTimer
    end

    self.m_world.m_inGameUI:setTime(time, has_limit)
end

-------------------------------------
-- function networkGameFinish
-- @breif
-------------------------------------
function SceneGameIllusion:networkGameFinish(t_param, t_result_ref, next_func)
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
    local l_deck = g_illusionDungeonData:getDragonDeck()
    local my_dragon = g_illusionDungeonData:getParticiPantInfoByList(l_deck) -- 로컬에 저장된 환상던전 덱에 환상 드래곤이 있는지 판단
    if (my_dragon > 0) then
        my_dragon = 1 -- 환상 드래곤(나의 드래곤) 가지고 있을 경우 1로 표기하여 서버에 올려준다.
    elseif (my_dragon < 0) then
        my_dragon = 2 -- 환상 드래곤(빌린) 가지고 있을 경우 1로 표기하여 서버에 올려준다.
    else
        my_dragon = 0
    end

    local function success_cb(ret)
        -- 클리어 타입은 서버에서 안줌
        local is_success = (t_param['clear_type'] == 1) and true or false
        self:networkGameFinish_response(ret, t_result_ref, is_success)

        local struct_illusion = g_illusionDungeonData:getEventIllusionInfo()
        if (ret['last_stage']) then
            struct_illusion.last_stage = ret['last_stage']
        end
        
        -- 남은 토큰 값 갱신
        -- 패배했을 경우 토큰 변경이 없어서 아예 값이 내려오지 않음
        if (ret['remain_token']) then
            struct_illusion.remain_token = ret['remain_token']
        end
        
        struct_illusion.token = ret['token']
        g_serverData:applyServerData(ret['token'], 'user', 'event_illusion')

        -- 최고점수 갱신
        local diff_number = g_illusionDungeonData:parseStageID(self.m_stageID)
        local last_score = g_illusionDungeonData:getBestScoreByDiff(diff_number)
        local cur_score = t_param['score'] or 0
        if (last_score < cur_score) then
            g_illusionDungeonData:setBestScoreByDiff(diff_number, cur_score)
        end

        if next_func then
            next_func(ret)
        end
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    local function response_status_cb(ret)
        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)
        
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

    local api_url = ''
    api_url = '/game/illusion_dungeon/finish'


    local ui_network = UI_Network()

    -- 접속시간 저장
    local save_time = g_accessTimeData:getSaveTime()
    if (save_time) then
        ui_network:setParam('access_time', save_time)
    end
    
    ui_network:setUrl(api_url)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', self.m_stageID) 
    ui_network:setParam('illusion')      
    ui_network:setParam('clear_type', t_param['clear_type'])
    ui_network:setParam('exp_rate', t_param['exp_rate'])
    ui_network:setParam('score', t_param['score'] or 0)
    ui_network:setParam('gamekey', self.m_gameKey)
    ui_network:setParam('dungeon_number', 1)
    ui_network:setParam('is_mydragon', my_dragon)
    ui_network:setParam('deck_name', 'illusion')
    ui_network:setParam('check_time', g_accessTimeData:getCheckTime())

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
-- function getIllusionDragonContribution
-- @breif 환상 드래곤의 데미지 리턴 (환상드래곤이 1마리일 때만 가정한 상태)
-------------------------------------
function SceneGameIllusion:getIllusionDragonContribution()
    local l_my_dragon = self.m_gameWorld.m_myDragons
    for i, dragon in pairs(l_my_dragon) do
        if (g_illusionDungeonData:isIllusionDragonID(dragon.m_tDragonInfo)) then
            local log_recorder = dragon.m_charLogRecorder
	        local sum_value = log_recorder:getLog('damage')
            return sum_value
        end
    end

    return 0
end

-------------------------------------
-- function getRemainTimer
-------------------------------------
function SceneGameIllusion:getRemainTimer()
    if (not self.m_gameWorld.m_gameState)then
        return 0
    end

    return self.m_gameWorld.m_gameState:getRemainTime()
end