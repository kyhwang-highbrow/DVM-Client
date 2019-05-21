local PARENT = GameState_ClanRaid

-------------------------------------
-- class GameState_Illusion
-------------------------------------
GameState_Illusion = class(PARENT, {

    })

-------------------------------------
-- function init
-------------------------------------
function GameState_Illusion:init(world)

end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_Illusion:makeResultUI(is_success)
    self.m_world:setGameFinish()
     -- @LOG : 스테이지 성공 시 클리어 시간
	self.m_world.m_logRecorder:recordLog('lap_time', self.m_fightTimer)  
    
    local world = self.m_world
    local stage_id = world.m_stageID
    local damage = total_damage

    local t_result_ref = self:makeGameFinishParam(is_success)

    local ui = UI_GameResult_Illusion(stage_id,
        is_success,
        self.m_fightTimer,
        self:getTotalDamage()
        )
    
    --[[
    local total_damage = self:getTotalDamage()

    -- 작업 함수들
    local func_network_game_finish
    local func_ui_result

    -- UI연출에 필요한 테이블들
    local t_result_ref = {}
    t_result_ref['drop_reward_list'] = {}
    t_result_ref['mail_reward_list'] = {}

    -- 1. 네트워크 통신
    func_network_game_finish = function()
        local t_param = self:makeGameFinishParam(is_success)

        -- 총 데미지
        t_param['damage'] = total_damage
        g_gameScene:networkGameFinish(t_param, t_result_ref, func_ui_result)
    end

    -- 2. UI 생성
    func_ui_result = function()
        local world = self.m_world
        local stage_id = world.m_stageID
        local damage = total_damage

        local ui = UI_ClanRaidResult(stage_id,
            is_success,
            damage,
            t_result_ref)
    end

    -- 최초 실행
    func_network_game_finish()
    --]]
end
