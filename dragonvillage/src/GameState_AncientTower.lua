local PARENT = GameState

-------------------------------------
-- class GameState_AncientTower
-------------------------------------
GameState_AncientTower = class(PARENT, {
        m_uiBossHp = 'UI_IngameBossHp',
    })

-------------------------------------
-- function init
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_AncientTower:init()
    self.m_bgmBoss = 'bgm_dungeon_boss'
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_AncientTower:initState()
    PARENT.initState(self)
    
    self:addState(GAME_STATE_WAVE_INTERMISSION, GameState_AncientTower.update_wave_intermission)
    self:addState(GAME_STATE_FIGHT, GameState_AncientTower.update_fight)
    self:addState(GAME_STATE_FINAL_WAVE, GameState_AncientTower.update_final_wave)
end

-------------------------------------
-- function update_wave_intermission
-------------------------------------
function GameState_AncientTower.update_wave_intermission(self, dt)
	local world = self.m_world
	local map_mgr = world.m_mapManager
    local intermissionTime = getInGameConstant("WAVE_INTERMISSION_TIME")
	local speed = 0

    if (self.m_stateTimer == 0) then
        -- 스킬 및 미사일을 날린다
	    world:removeMissileAndSkill()
        world:removeHeroDebuffs()

        -- 연출(카메라)
        self:doDirectionForIntermission()
                
        -- 변경된 카메라 위치에 맞게 아군 홈 위치 변경 및 이동
        for i, v in ipairs(world:getDragonList()) do
            if (not v:isDead()) then
                v:changeStateWithCheckHomePos('idle')
            end
        end
    end

	-- 1. 전환 시간 2/3 지점까지 비교적 완만하게 빨라짐
	if (self.m_stateTimer < intermissionTime * 2 / 3) then
		speed = map_mgr.m_speed - (g_constant:get('INGAME', 'WAVE_INTERMISSION_MAP_SPEED') * dt)
		map_mgr:setSpeed(speed)

	-- 2. 전환 시간 까지 비교적 빠르게 느려짐
	elseif (self.m_stateTimer > intermissionTime * 2 / 3) then
		speed = map_mgr.m_speed + (g_constant:get('INGAME', 'WAVE_INTERMISSION_MAP_SPEED') * 1.9 * dt)
		map_mgr:setSpeed(speed)
	end
	
	-- 3. 전환 시간 이후 속도 고정시키고 전환
	if (self.m_stateTimer >= intermissionTime) then
        map_mgr:setSpeed(-300)

        self:changeState(GAME_STATE_ENEMY_APPEAR)
	end
end

-------------------------------------
-- function update_fight
-------------------------------------
function GameState_AncientTower.update_fight(self, dt)
    local world = self.m_world
    
    if (self.m_stateTimer == 0) then
        if (world.m_waveMgr:isFinalWave()) then
            if (not self.m_uiBossHp) then
                local parent = world.m_inGameUI.root
                local boss_list = world.m_waveMgr.m_lBoss

                self.m_uiBossHp = UI_IngameBossHp(parent, boss_list)
                self.m_uiBossHp:refresh()
            end
        end
    end

    PARENT.update_fight(self, dt)
end

-------------------------------------
-- function update_final_wave
-------------------------------------
function GameState_AncientTower.update_final_wave(self, dt)
    PARENT.update_final_wave(self, dt)

    if (self:isBeginningStep(0)) then
        -- 웨이브 표시 숨김
        self.m_world.m_inGameUI.vars['waveVisual']:setVisible(false)
    end
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_AncientTower:makeResultUI(is_success)
    -- @LOG : 스테이지 성공 시 클리어 시간
	self.m_world.m_logRecorder:recordLog('lap_time', self.m_fightTimer)

    -- 작업 함수들
    local func_network_game_finish
    local func_ui_result
    
    -- 고대의 탑 점수 계산
    local score_calc

    -- UI연출에 필요한 테이블들
    local t_result_ref = {}
    t_result_ref['user_levelup_data'] = {}
    t_result_ref['dragon_levelu_data_list'] = {}
    t_result_ref['drop_reward_grade'] = 'c'
    t_result_ref['drop_reward_list'] = {}
    t_result_ref['secret_dungeon'] = nil
    t_result_ref['content_open'] = {}

    -- 1. 네트워크 통신
    func_network_game_finish = function()
        local t_param 
        t_param = self:makeGameFinishParam(is_success)
        local world = self.m_world
        local stage_id = world.m_stageID

        local recorder = clone(self.m_world.m_logRecorder)
        score_calc = AncientTowerScoreCalc(recorder, stage_id)

        -- 스테이지 클리어시 최종 점수 추가로 보냄
        if (t_param['clear_type'] == 1) then 
            t_param['score'] = score_calc:getFinalScore()
        end

        g_gameScene:networkGameFinish(t_param, t_result_ref, func_ui_result)
    end

    -- 2. UI 생성
    func_ui_result = function()
        local world = self.m_world
        local stage_id = world.m_stageID
        
        local ex_score = 99999 -- 최고점 갱신되지 않도록 높은 점수로 초기화
        if (g_ancientTowerData) then
            local is_attr = g_ancientTowerData:isAttrChallengeMode()        
            if (not is_attr) then
                -- finish 통신 직후, 베스트 팀 점수 로컬에 저장, 이전 기록 반환
                ex_score = self:saveBestTeamScore(stage_id, is_success, score_calc:getFinalScore())
            end
        end

        UI_GameResult_AncientTower(stage_id,
            is_success,
            self.m_fightTimer,
            t_result_ref['default_gold'],
            t_result_ref['user_levelup_data'],
            t_result_ref['dragon_levelu_data_list'],
            t_result_ref['drop_reward_grade'],
            t_result_ref['drop_reward_list'],
            t_result_ref['secret_dungeon'],
            t_result_ref['content_open'],
            score_calc,
            ex_score)
    end

    -- 최초 실행
    func_network_game_finish()
end

-------------------------------------
-- function checkToDieHighestRariry
-- @brief 가장 높은 등급의 적(보스)가 죽었은지 체크
-------------------------------------
function GameState_AncientTower:checkToDieHighestRariry()
    local world = self.m_world

    if (world.m_bDevelopMode) then return false end
        
    return world.m_waveMgr:checkToDieHighestRariry_ancient()
end

-------------------------------------
-- function doDirectionForIntermission
-------------------------------------
function GameState_AncientTower:doDirectionForIntermission()
    local world = self.m_world
    local map_mgr = world.m_mapManager

    local t_wave_data, is_final_wave = world.m_waveMgr:getNextWaveScriptData()
    local t_camera_info = t_wave_data['camera'] or {}
    local curCameraPosX, curCameraPosY = world.m_gameCamera:getHomePos()

    t_camera_info['pos_x'] = curCameraPosX
    t_camera_info['pos_y'] = curCameraPosY
    t_camera_info['time'] = getInGameConstant("WAVE_INTERMISSION_TIME")
        
    -- 카메라 액션 설정
    world:changeCameraOption(t_camera_info)
    world:changeHeroHomePosByCamera()

    -- 인터미션 시작 시 획득하지 않은 아이템 삭제
    world:cleanupItem()
end

-------------------------------------
-- function saveBestTeamScore
-------------------------------------
function GameState_AncientTower:saveBestTeamScore(stage_id, is_success, final_score)
    local ex_score = 999999 -- 기존 기록을  디폴트로 높게 잡아 팝업뜨지 않도록 설정
    if (not is_success) then
        return ex_score
    end

    if (not g_settingDeckData) then
        return ex_score
    end

    -- 기존 기록보다 높은경우에만 기록
    ex_score = tonumber(g_settingDeckData:getAncientStageScore(stage_id)) or 0
    if (final_score <= ex_score) then
        return ex_score
    end

    -- 성공했을 경우에만 기록
    if (is_success) then
        local l_deck, formation, deck_name, leader, tamer_id = g_deckData:getDeck('ancient')
        g_settingDeckData:saveAncientTowerDeck(l_deck, formation, leader, tamer_id, final_score, stage_id) -- l_deck, formation, leader, tamer_id, score
        return ex_score
    end

    return ex_score 
end

