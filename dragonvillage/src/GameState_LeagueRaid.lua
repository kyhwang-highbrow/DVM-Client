local PARENT = GameState

-------------------------------------
-- class GameState_LeagueRaid
-------------------------------------
GameState_LeagueRaid = class(PARENT, {
    m_deckTable = 'table',

    m_currentDeckIndex = 'number',
})


-------------------------------------
-- function init
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_LeagueRaid:init()
    self.m_bgmBoss = 'bgm_dungeon_boss'
    self.m_currentDeckIndex = 1
    g_deckData:setSelectedDeck(self:getDeckName())

end

-------------------------------------
-- function getDeckName
-------------------------------------
function GameState_LeagueRaid:getDeckName()
    g_deckData:setSelectedDeck('league_raid_' .. tostring(self.m_currentDeckIndex))

end


-------------------------------------
-- function checkWaveClear
-------------------------------------
function GameState_LeagueRaid:checkWaveClear(dt)
    local world = self.m_world
    local hero_count = #world:getDragonList()
    local enemy_count = world:getEnemyCount()

    -- 벤치마크 중 60초를 넘어가면 웨이브 종료
    if (g_benchmarkMgr and g_benchmarkMgr:isActive()) then
        local time = g_benchmarkMgr.m_waveTime

        if (self.m_world.m_waveMgr:isFinalWave()) then
            time = g_benchmarkMgr.m_lastWaveTime
        end
        
        if (self.m_stateTimer >= time) then
            self.m_world:removeAllEnemy()

            if (not self.m_world.m_waveMgr:isFinalWave()) then
		        self:changeState(GAME_STATE_WAVE_INTERMISSION_WAIT)
		    else
                cclog('GAME_STATE_SUCCESS_WAIT')
			    self:changeState(GAME_STATE_SUCCESS_WAIT)
		    end
            return
        end
    end

    -- 패배 여부 체크
    if (self.m_currentDeckIndex < 3 and hero_count <= 0) then
        self.m_currentDeckIndex = self.m_currentDeckIndex + 1
        g_deckData:setSelectedDeck(self:getDeckName())

        self.m_world:makeHeroDeck()
        self:changeState(GAME_STATE_START)
        return false

    elseif(hero_count <= 0) then
        self:changeState(GAME_STATE_FAILURE)
        return true

    -- 클리어 여부 체크
    elseif (enemy_count <= 0 or self:checkToDieHighestRariry()) then
        self.m_waveClearTimer = self.m_waveClearTimer + dt

        if (self.m_waveClearTimer > 0.5) then
            self.m_waveClearTimer = 0

            if (world.m_waveMgr:isFinalWave()) then
                self:changeState(GAME_STATE_SUCCESS_WAIT)
            else
		        self:changeState(GAME_STATE_WAVE_INTERMISSION_WAIT)			    
		    end
            return true
        end

    else
        self.m_waveClearTimer = 0
    end

    return false
end


-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_LeagueRaid:makeResultUI(isSuccess)
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
        local world = self.m_world
        local stage_id = world.m_stageID

        -- UI_GameResult_Dmgate(stage_id,
        -- isSuccess,
        -- self.m_fightTimer,
        -- result_table['default_gold'],
        -- result_table['user_levelup_data'],
        -- result_table['dragon_levelu_data_list'],
        -- result_table['drop_reward_grade'],
        -- result_table['drop_reward_list'],
        -- result_table['secret_dungeon'],
        -- result_table['content_open'])
        UI_GameResult_LeagueRaid(stage_id, isSuccess, result_table)

        -- 나중에 팝업띄우고 싶으면 수석풀고 기능 완성시킴
        --if (isSuccess) then self:showChapterOpenPopup() end
    end

    -- 최초 실행
    func_network_game_finish()
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_LeagueRaid:showChapterOpenPopup()
    -- 새로운 시즌 팝업은 별도 위에서 체크하고 리턴

    -- 다음 스테이지 id 받아오고
    local next_stage_id = g_dmgateData:getNextStageID(tonumber(g_gameScene.m_stageID))

    if (not next_stage_id) then return end

    -- 그 스테이지가 마침 상층 1스테이지며
    local chapter_id = g_dmgateData:getChapterID(next_stage_id)
    local stage_id = g_dmgateData:getStageID(next_stage_id)
    if (not chapter_id or chapter_id < 2 or stage_id ~= 1) then return end

    -- 언락 연출을 보여줘야 한다면
    --local is_first_unlock = g_dmgateData:checkInUnlockList(next_stage_id)
    
    --if (is_first_unlock) then UI_DmgateChapterOpenPopup() end
end