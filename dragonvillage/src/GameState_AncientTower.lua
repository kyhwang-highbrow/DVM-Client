local PARENT = GameState

-------------------------------------
-- class GameState_AncientTower
-------------------------------------
GameState_AncientTower = class(PARENT, {
    })

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_AncientTower:init()
    self.m_bgmBoss = 'bgm_nest_boss'
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_AncientTower:initState()
    PARENT.initState(self)
    
    self:addState(GAME_STATE_WAVE_INTERMISSION,      GameState_AncientTower.update_wave_intermission)
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
        -- 연출(카메라)
        self:doDirectionForIntermission()

        -- 0. 스킬 및 미사일을 날린다
	    world:removeMissileAndSkill()
        
        -- 변경된 카메라 위치에 맞게 아군 홈 위치 변경 및 이동
        for i, v in ipairs(world:getDragonList()) do
            if (v.m_bDead == false) then
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

        cclog('GAME_STATE_ENEMY_APPEAR')
		self:changeState(GAME_STATE_ENEMY_APPEAR)
	end
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_AncientTower:makeResultUI(is_success)
    -- 작업 함수들
    local func_network_game_finish
    local func_ui_result

    -- UI연출에 필요한 테이블들
    local t_result_ref = {}
    t_result_ref['user_levelup_data'] = {}
    t_result_ref['dragon_levelu_data_list'] = {}
    t_result_ref['drop_reward_grade'] = 'c'
    t_result_ref['drop_reward_list'] = {}
    t_result_ref['secret_dungeon'] = nil

    -- 1. 네트워크 통신
    func_network_game_finish = function()
        local t_param = self:makeGameFinishParam(is_success)
        g_gameScene:networkGameFinish(t_param, t_result_ref, func_ui_result)
    end

    -- 2. UI 생성
    func_ui_result = function()
        local world = self.m_world
        local stage_id = world.m_stageID
                
        UI_GameResult_AncientTower(stage_id,
            is_success,
            self.m_fightTimer,
            t_result_ref['default_gold'],
            t_result_ref['user_levelup_data'],
            t_result_ref['dragon_levelu_data_list'],
            t_result_ref['drop_reward_grade'],
            t_result_ref['drop_reward_list'],
            t_result_ref['secret_dungeon'])
    end

    -- 최초 실행
    func_network_game_finish()
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