local PARENT = GameState

-------------------------------------
-- class GameState_SecretDungeon_Gold
-------------------------------------
GameState_SecretDungeon_Gold = class(PARENT, {
    })

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_SecretDungeon_Gold:init()
    self.m_bgmBoss = 'bgm_nest_boss'

    -- 제한 시간 설정
    local t_dungeon = TableSecretDungeon():get(self.m_world.m_stageID)
    self.m_limitTime = t_dungeon['playable_time']
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_SecretDungeon_Gold:initState()
    PARENT.initState(self)
    self:addState(GAME_STATE_WAVE_INTERMISSION, GameState_SecretDungeon_Gold.update_wave_intermission)
end

-------------------------------------
-- function update_wave_intermission
-------------------------------------
function GameState_SecretDungeon_Gold.update_wave_intermission(self, dt)
	local world = self.m_world
	
    return PARENT.update_wave_intermission(self, dt)
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_SecretDungeon_Gold:makeResultUI(is_success)
    -- 작업 함수들
    local func_network_game_finish
    local func_ui_result

    -- UI연출에 필요한 테이블들
    local t_result_ref = {}
    t_result_ref['user_levelup_data'] = {}
    t_result_ref['dragon_levelu_data_list'] = {}
    t_result_ref['drop_reward_grade'] = 'c'
    t_result_ref['drop_reward_list'] = {}

    -- 1. 네트워크 통신
    func_network_game_finish = function()
        local t_param = self:makeGameFinishParam(is_success)
        g_gameScene:networkGameFinish(t_param, t_result_ref, func_ui_result)
    end

    -- 2. UI 생성
    func_ui_result = function()
        local world = self.m_world
        local stage_id = world.m_stageID
                
        UI_GameResult_NestDungeon(stage_id,
            is_success,
            self.m_fightTimer,
            world.m_gold,
            t_result_ref['user_levelup_data'],
            t_result_ref['dragon_levelu_data_list'],
            t_result_ref['drop_reward_grade'],
            t_result_ref['drop_reward_list'])
    end

    -- 최초 실행
    func_network_game_finish()
end

-------------------------------------
-- function doDirectionForIntermission
-------------------------------------
function GameState_SecretDungeon_Gold:doDirectionForIntermission()
    local world = self.m_world
    local map_mgr = world.m_mapManager

    local t_wave_data, is_final_wave = world.m_waveMgr:getNextWaveScriptData()
    local t_camera_info = t_wave_data['camera'] or {}
    local curCameraPosX, curCameraPosY = world.m_gameCamera:getHomePos()
		
	if (world.m_bDevelopMode == false) then
        -- 황금 던전일 경우 웨이브 스크립트에 있는 카메라 정보로 설정
        t_camera_info['pos_x'] = t_camera_info['pos_x'] * t_camera_info['scale']
		t_camera_info['pos_y'] = t_camera_info['pos_y'] * t_camera_info['scale']
		t_camera_info['time'] = getInGameConstant(WAVE_INTERMISSION_TIME)

        -- 마지막 웨이브 시작 연출
        if is_final_wave then
            world:dispatch('gold_boss_bg')
        end
    end

    -- 카메라 액션 설정
    world:changeCameraOption(t_camera_info)
    world:changeHeroHomePosByCamera()
end