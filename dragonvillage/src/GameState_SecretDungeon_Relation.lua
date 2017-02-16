local PARENT = GameState

-------------------------------------
-- class GameState_SecretDungeon_Relation
-------------------------------------
GameState_SecretDungeon_Relation = class(PARENT, {
    })

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_SecretDungeon_Relation:init()
    self.m_bgmBoss = 'bgm_nest_boss'
end

-------------------------------------
-- function fight
-------------------------------------
function GameState_SecretDungeon_Relation:fight()
    -- 아군과 적군 전투 시작
    local world = self.m_world

    for i,dragon in ipairs(world:getDragonList()) do
        if (dragon.m_bDead == false) then
            dragon.m_bFirstAttack = true
            dragon:changeState('attackDelay')
        end
    end

    for i,enemy in pairs(world:getEnemyList()) do
        if (enemy.m_bDead == false) then
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
            world.m_gold,
            t_result_ref['user_levelup_data'],
            t_result_ref['dragon_levelu_data_list'],
            t_result_ref['drop_reward_grade'],
            t_result_ref['drop_reward_list'])
    end

    -- 최초 실행
    --func_network_game_finish()
    func_ui_result()
end


-------------------------------------
-- function waveChange
-------------------------------------
function GameState_SecretDungeon_Relation:waveChange()

    local world = self.m_world
    local map_manager = world.m_mapManager
    local t_wave_data = world.m_waveMgr:getNextWaveScriptData()

    -- 다음 웨이브가 없을 경우 클리어
    if (not t_wave_data) then
        self:changeState(GAME_STATE_SUCCESS)
        return true
    end
    
    self.m_nextWaveDirectionType = t_wave_data['direction']
    if (not self.m_nextWaveDirectionType) and is_final_wave then
        self.m_nextWaveDirectionType = 'final_wave'
    end

    -- 다음 웨이브 생성
    world.m_waveMgr:newScenario()

    self.m_nAppearedEnemys = 0

    -- 아무런 연출이 없을 경우 GAME_STATE_FIGHT 상태를 유지
    if (self.m_nextWaveDirectionType == nil) and (t_bg_data == nil) then
        return false

    -- 웨이브 연출만 있을 경우
    elseif (self.m_nextWaveDirectionType) and (not t_bg_data) then
        return self:applyWaveDirection()

    -- 배경 전환이 있을 경우 (GAME_STATE_FIGHT_WAIT상태에서 웨이브 연출을 확인함)
    elseif (t_bg_data) then
        local changeNextState = function()
            if (not self:applyWaveDirection()) then
                self:changeState(GAME_STATE_ENEMY_APPEAR)
            end
        end

        if map_manager:applyWaveScript(t_bg_data) then
            map_manager.m_finishCB = function()
                if (not self:applyWaveDirection()) then
                    changeNextState()
                end
            end
            self:changeState(GAME_STATE_FIGHT_WAIT)
            return true
        else
            map_manager.m_finishCB = nil
            changeNextState()
        end

    else
        error()

    end
end


-------------------------------------
-- function checkWaveClear
-------------------------------------
function GameState_SecretDungeon_Relation:checkWaveClear()
    local world = self.m_world
    local enemy_count = #world:getEnemyList()

    -- 클리어 여부 체크
    if (enemy_count <= 0) then
        -- 스킬 다 날려 버리자
        world:cleanupSkill()
        world:removeHeroDebuffs()
		    
		if (not world.m_waveMgr:isFinalWave()) then
		    self:changeState(GAME_STATE_WAVE_INTERMISSION_WAIT)
		else
			self:changeState(GAME_STATE_SUCCESS_WAIT)
		end

    -- 마지막 웨이브라면 해당 웨이브의 최고 등급 적이 존재하지 않을 경우 클리어 처리
    elseif (world.m_waveMgr:isBossWave()) then
        local highestRariry = world.m_waveMgr:getHighestRariry()
        local bExistBoss = false
            
        for _, enemy in ipairs(world:getEnemyList()) do
            if (enemy.m_tDragonInfo['lv'] == highestRariry) then
                bExistBoss = true
                break
            end
        end

        if (not bExistBoss) then
            -- 스킬 다 날려 버리자
		    world:cleanupSkill()
            world:removeHeroDebuffs()

            -- 모든 적들을 죽임
            world:killAllEnemy()

            if (not world.m_waveMgr:isFinalWave()) then
		        self:changeState(GAME_STATE_WAVE_INTERMISSION_WAIT)
		    else
			    self:changeState(GAME_STATE_SUCCESS_WAIT)
		    end
        end
    end
end

-------------------------------------
-- function setWave
-------------------------------------
function GameState_SecretDungeon_Relation:setWave(wave)
    g_gameScene.m_inGameUI.vars['waveVisual']:setVisual('wave', string.format('10wave_%02d', wave))
end