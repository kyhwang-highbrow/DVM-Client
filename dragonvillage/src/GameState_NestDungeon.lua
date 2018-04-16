local PARENT = GameState

-------------------------------------
-- class GameState_NestDungeon
-------------------------------------
GameState_NestDungeon = class(PARENT, {
    })

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_NestDungeon:init()
    self.m_bgmBoss = 'bgm_dungeon_boss'
end

-------------------------------------
-- function initBuffByFightTime
-------------------------------------
function GameState_NestDungeon:initBuffByFightTime()
    self.m_tBuffInfoByFightTime = {}

    local t_constant = g_constant:get('INGAME', 'FIGHT_BY_TIME_BUFF')
    if (not t_constant['ENABLE']) then return end

    local stage_id = self.m_world.m_stageID
    local t_dungeon = g_nestDungeonData:parseNestDungeonID(stage_id)
    local dungeonMode = t_dungeon['dungeon_mode']
    local detail_mode = t_dungeon['detail_mode']

    local str_dungeonMode

    if (not str_dungeonMode) then
        if (detail_mode == NEST_DUNGEON_SUB_MODE_JEWEL) then
            str_dungeonMode = 'JEWEL'
        else
            str_dungeonMode = 'GIANT_DRAGON'
        end
    else
        str_dungeonMode = NEST_MODE[dungeonMode]
    end

    local t_info = t_constant[str_dungeonMode]
    if (not t_info) then return end

    self.m_tBuffInfoByFightTime['start_time'] = t_info['START_TIME'] or 3
    self.m_tBuffInfoByFightTime['random_time'] = t_info['RANDOM_TIME'] or 0
    self.m_tBuffInfoByFightTime['interval_time'] = t_info['INTERVAL_TIME']
    self.m_tBuffInfoByFightTime['cur_buff'] = {}   -- 현재까지 부여된 버프 정보
    self.m_tBuffInfoByFightTime['add_buff'] = {}   -- 시간마다 부여될 버프 정보

    local list = t_info['BUFF'] or {}

    for i, v in ipairs(list) do
        local l_str = seperate(v, ';')
        local buff_type = l_str[1]
        local buff_value = l_str[2]

        self.m_tBuffInfoByFightTime['add_buff'][buff_type] = buff_value
    end

    self.m_nextBuffTime = self.m_tBuffInfoByFightTime['start_time']
    
    -- 랜덤 시간 적용
    local random_time = self.m_tBuffInfoByFightTime['random_time']
    if (random_time > 0) then
        local random = math_random(1, random_time)
        self.m_nextBuffTime = self.m_nextBuffTime + (random - random_time / 2)
        self.m_nextBuffTime = math_max(self.m_nextBuffTime, 0)
    end

    self.m_buffCount = 0
    self.m_maxBuffCount = t_info['REPEAT_COUNT'] or 9999

    --cclog('self.m_tBuffInfoByFightTime = ' .. luadump(self.m_tBuffInfoByFightTime))
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