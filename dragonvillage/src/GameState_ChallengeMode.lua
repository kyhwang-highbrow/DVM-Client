local PARENT = GameState_Arena

-------------------------------------
-- class GameState_ChallengeMode
-------------------------------------
GameState_ChallengeMode = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function GameState_ChallengeMode:init(world)
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_ChallengeMode:makeResultUI(is_win)
    -- 작업 함수들
    local func_network_game_finish
    local func_ui_result

    -- 1. 네트워크 통신
    func_network_game_finish = function()
        g_challengeMode:request_challengeModeFinish(is_win, self.m_fightTimer, func_ui_result)
    end

    -- 2. UI 생성
    func_ui_result = function(ret, stage)
        UI_ChallengeModeResult(is_win, ret, stage)
    end

    -- 최초 실행
    func_network_game_finish()
end