local PARENT = GameState

-------------------------------------
-- class GameState_AncientRuin
-------------------------------------
GameState_AncientRuin = class(PARENT, {})

-------------------------------------
-- function init
-------------------------------------
function GameState_AncientRuin:init(world)
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_AncientRuin:makeResultUI(is_success)
    self.m_world:setGameFinish()

    -- 작업 함수들
    local func_network_game_finish
    local func_ui_result

    -- UI연출에 필요한 테이블들
    local t_result_ref = {}
    t_result_ref['user_levelup_data'] = {}
    t_result_ref['dragon_levelu_data_list'] = {}
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
        local game_mode = world.m_gameMode

		-- GameState는 Adventure모드를 기본으로 한다. 다른 모드는 상속을 받아서 처리한다.
        local ui = UI_GameResult_AncientRuin(stage_id,
            is_success,
            self.m_fightTimer,
            t_result_ref['default_gold'],
            t_result_ref['user_levelup_data'],
            t_result_ref['dragon_levelu_data_list'],
            t_result_ref['drop_reward_grade'],
            t_result_ref['drop_reward_list'],
            t_result_ref['secret_dungeon'])

        local l_hottime = t_result_ref['hottime']
        ui:setHotTimeInfo(l_hottime)
    end

    -- 최초 실행
    func_network_game_finish()
end