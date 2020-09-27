local PARENT = GameState

-------------------------------------
-- class GameState_SecretDungeon_Relation
-------------------------------------
GameState_SecretDungeon_Relation = class(PARENT, {
    })

-------------------------------------
-- function init
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_SecretDungeon_Relation:init()
    self.m_bgmBoss = 'bgm_dungeon_boss'
end

-------------------------------------
-- function fight
-------------------------------------
function GameState_SecretDungeon_Relation:fight()
    -- 아군과 적군 전투 시작
    local world = self.m_world

    for i,dragon in ipairs(world:getDragonList()) do
        if (not dragon:isDead()) then
            dragon.m_bFirstAttack = true
            dragon:changeState('attackDelay')
        end
    end

    for i,enemy in pairs(world:getEnemyList()) do
        if (not enemy:isDead()) then
            enemy.m_bFirstAttack = false
            enemy:changeState('attackDelay')

            if enemy.m_hpNode then
                enemy.m_hpNode:setVisible(true)
            end
        end
    end
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_SecretDungeon_Relation:makeResultUI(is_success)
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
                
        UI_GameResult_SecretDungeon(stage_id,
            is_success,
            self.m_fightTimer,
            t_result_ref['default_gold'],
            t_result_ref['user_levelup_data'],
            t_result_ref['dragon_levelu_data_list'],
            t_result_ref['drop_reward_grade'],
            t_result_ref['drop_reward_list'])
    end

    -- 최초 실행
    func_network_game_finish()
    --func_ui_result()
end