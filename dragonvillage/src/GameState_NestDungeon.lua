-------------------------------------
-- class GameState_NestDungeon
-------------------------------------
GameState_NestDungeon = class(GameState, {})

-------------------------------------
-- function doDirectionForIntermission
-------------------------------------
function GameState_NestDungeon:doDirectionForIntermission()
    local world = self.m_world
    local map_mgr = world.m_mapManager

    local t_wave_data, is_final_wave = world.m_waveMgr:getNextWaveScriptData()
    local t_camera_info = t_wave_data['camera'] or {}
    local curCameraPosX, curCameraPosY = world.m_gameCamera:getHomePos()
		
	if (world.m_waveMgr.m_bDevelopMode == false) then
        -- 네스트 던전일 경우 웨이브 스크립트에 있는 카메라 정보로 설정
        t_camera_info['pos_x'] = t_camera_info['pos_x'] * t_camera_info['scale']
		t_camera_info['pos_y'] = t_camera_info['pos_y'] * t_camera_info['scale']
		t_camera_info['time'] = WAVE_INTERMISSION_TIME

        -- 네스트 던전별 연출
        local dungeon_mode = g_nestDungeonData:parseNestDungeonID(stage_id)
        if dungeon_mode == NEST_DUNGEON_DRAGON then
            if is_final_wave then
                world:dispatch('nest_dragon_final_wave')
            end
        end
    end
        
    -- 카메라 액션 설정
    world:changeCameraOption(t_camera_info)
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_NestDungeon:makeResultUI(is_success)
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