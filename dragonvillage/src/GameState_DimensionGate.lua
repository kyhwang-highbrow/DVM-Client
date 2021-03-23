local PARENT = GameState

-------------------------------------
-- class GameState_DimensionGate
-------------------------------------
GameState_DimensionGate = class(PARENT, {

})


-------------------------------------
-- function init
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_DimensionGate:init()
    self.m_bgmBoss = 'bgm_dungeon_boss'
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_DimensionGate:makeResultUI(isSuccess)
    isSuccess = true
    -- 작업 함수들
    local func_network_game_finish
    local func_ui_result
    
    -- UI연출에 필요한 테이블들
    local result_table = {}
    result_table['user_levelup_data'] = {}
    result_table['dragon_levelu_data_list'] = {}
    result_table['drop_reward_grade'] = 'c'
    result_table['drop_reward_list'] = {}
    result_table['secret_dungeon'] = nil
    result_table['content_open'] = {}

    -- 1. 네트워크 통신
    func_network_game_finish = function()
        local param_table = self:makeGameFinishParam(isSuccess)
        g_gameScene:networkGameFinish(param_table, result_table, func_ui_result)
    end

    -- 2. UI 생성
    func_ui_result = function(ret)

        g_dimensionGateData:response_dimensionGateInfo(ret)
        
        local world = self.m_world
        local stage_id = world.m_stageID

        UI_GameResult_DimensionGate(stage_id,
        isSuccess,
        self.m_fightTimer,
        result_table['default_gold'],
        result_table['user_levelup_data'],
        result_table['dragon_levelu_data_list'],
        result_table['drop_reward_grade'],
        result_table['drop_reward_list'],
        result_table['secret_dungeon'],
        result_table['content_open'])
    end

    -- 최초 실행
    func_network_game_finish()
end