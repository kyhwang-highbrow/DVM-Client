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

    -- �۾� �Լ���
    local func_network_game_finish
    local func_ui_result

    -- UI���⿡ �ʿ��� ���̺��
    local t_result_ref = {}
    t_result_ref['user_levelup_data'] = {}
    t_result_ref['dragon_levelu_data_list'] = {}
    t_result_ref['drop_reward_list'] = {}
    t_result_ref['secret_dungeon'] = nil

    -- 1. ��Ʈ��ũ ���
    func_network_game_finish = function()
        local t_param = self:makeGameFinishParam(is_success)
        g_gameScene:networkGameFinish(t_param, t_result_ref, func_ui_result)
    end

    -- 2. UI ����
    func_ui_result = function()
        local world = self.m_world
        local stage_id = world.m_stageID
        local game_mode = world.m_gameMode

		-- GameState�� Adventure��带 �⺻���� �Ѵ�. �ٸ� ���� ����� �޾Ƽ� ó���Ѵ�.
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

    -- ���� ����
    func_network_game_finish()
end