local PARENT = GameState

-------------------------------------
-- class GameState_NestDungeon
-------------------------------------
GameState_NestDungeon = class(PARENT, {
    })

-------------------------------------
-- function init
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_NestDungeon:init()
    self.m_bgmBoss = 'bgm_dungeon_boss'
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
    t_result_ref['secret_dungeon'] = nil
    t_result_ref['content_open'] = {}

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
            t_result_ref['default_gold'],
            t_result_ref['user_levelup_data'],
            t_result_ref['dragon_levelu_data_list'],
            t_result_ref['drop_reward_grade'],
            t_result_ref['drop_reward_list'],
            t_result_ref['secret_dungeon'],
            t_result_ref['content_open'])
    end

    -- 최초 실행
    func_network_game_finish()
end