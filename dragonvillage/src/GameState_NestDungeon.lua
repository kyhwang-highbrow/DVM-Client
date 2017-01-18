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
function GameState_NestDungeon:initState()
    PARENT.initState(self)
    self:addState(GAME_STATE_BOSS_WAVE, GameState_NestDungeon.update_boss_wave)
end

-------------------------------------
-- function update_boss_wave
-- @brief 보스 웨이브 연출
-------------------------------------
function GameState_NestDungeon.update_boss_wave(self, dt)
    if (self:isBeginningStep(0)) then
        self.m_waveEffect:setVisible(true)
        self.m_waveEffect:changeAni('boss_warning_width_720', false)
        self.m_waveEffect:addAniHandler(function()
            self:nextStep()
        end)

        SoundMgr:stopBGM()
    

    elseif (self:isBeginningStep(1)) then
        self.m_waveEffect:setVisible(true)
        self.m_waveEffect:changeAni('boss_appear', false)
        self.m_waveEffect:addAniHandler(function()
            self:nextStep()
        end)

        self.m_world:dispatch('boss_wave')

    elseif (self:isBeginningStep(2)) then
        self.m_waveEffect:setVisible(true)
        self.m_waveEffect:changeAni('boss_disappear', false)
        self.m_waveEffect:addAniHandler(function()
            self.m_waveEffect:setVisible(false)
            self:changeState(GAME_STATE_ENEMY_APPEAR)
        end)

        -- 보스 배경음
        SoundMgr:playBGM('bgm_nest_boss')

        -- 웨이브 표시 숨김
        g_gameScene.m_inGameUI.vars['waveVisual']:setVisible(false)

    end
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