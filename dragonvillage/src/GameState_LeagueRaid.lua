local PARENT = GameState


local LEAGUE_RAID_BUFF = 'all;0;atk_multi;15,all;0;hit_rate_add;5'
local LEAGUE_RAID_DEBUFF = 'all;0;recovery_power_add;-5,all;0;dmg_adj_rate_multi;10'

local LEAGUE_RAID_TIMER_GAP = 10
local LEAGUE_RAID_TIMER_DEBUFF = 'all;0;recovery_power_add;-5,all;0;dmg_adj_rate_multi;10'


-------------------------------------
-- class GameState_LeagueRaid
-------------------------------------
GameState_LeagueRaid = class(PARENT, {
    m_deckTable = 'table',

    m_currentDeckIndex = 'number',

    m_buffList = 'table',

    m_curLv = 'number',

    m_debuffTimer = 'number',
})


-------------------------------------
-- function init
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_LeagueRaid:init()
    self.m_bgmBoss = 'bgm_dungeon_boss'
    self.m_curLv = 0

    local cur_deck_name = g_deckData:getSelectedDeckName()
    local deck_number = pl.stringx.replace(cur_deck_name, 'league_raid_', '')

    self.m_currentDeckIndex = tonumber(deck_number)
    self.m_buffList = clone(g_leagueRaidData.m_leagueRaidData)
end


-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_LeagueRaid:initState()
    self:addState(GAME_STATE_NONE,                   function(self, dt) end)
    self:addState(GAME_STATE_START,                  GameState_LeagueRaid.update_start)
    self:addState(GAME_STATE_WAVE_INTERMISSION,      GameState_LeagueRaid.update_wave_intermission)
    self:addState(GAME_STATE_WAVE_INTERMISSION_WAIT, GameState_LeagueRaid.update_wave_intermission_wait)
    self:addState(GAME_STATE_ENEMY_APPEAR,           GameState_LeagueRaid.update_enemy_appear)
    self:addState(GAME_STATE_FIGHT,                  GameState_LeagueRaid.update_fight)
    self:addState(GAME_STATE_FIGHT_WAIT,             GameState_LeagueRaid.update_fight_wait)
    self:addState(GAME_STATE_FINAL_WAVE,             GameState_LeagueRaid.update_final_wave) -- 마지막 웨이브 연출
    self:addState(GAME_STATE_BOSS_WAVE,              GameState_LeagueRaid.update_boss_wave)  -- 보스 웨이브 연출
    self:addState(GAME_STATE_RAID_WAVE,              GameState_LeagueRaid.update_raid_wave)  -- 레이드 웨이브 연출
    self:addState(GAME_STATE_SUCCESS_WAIT,           GameState_LeagueRaid.update_success_wait)
    self:addState(GAME_STATE_SUCCESS,                GameState_LeagueRaid.update_success)
    self:addState(GAME_STATE_FAILURE,                GameState_LeagueRaid.update_failure)
end


-------------------------------------
-- function getDeckName
-------------------------------------
function GameState_LeagueRaid:getDeckName()
    local cur_deck_name = g_deckData:getSelectedDeckName()

    return cur_deck_name

end


-------------------------------------
-- function checkWaveClear
-------------------------------------
function GameState_LeagueRaid:checkWaveClear(dt)
    local world = self.m_world
    local hero_count = #world:getDragonList()
    local enemy_count = world:getEnemyCount()

    -- 일단 여기에 넣음
    self:applyEnemyBuff()

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
        local my_info = g_leagueRaidData:getMyInfo()
        local stage_id = my_info['stage']
        local stage_name = 'stage_' .. stage_id

        if (self.m_currentDeckIndex == 1) then
            g_leagueRaidData.m_attackedChar_A = clone(world.m_myDragons)
        else
            g_leagueRaidData.m_attackedChar_B = clone(world.m_myDragons)
        end
        
        self.m_currentDeckIndex = self.m_currentDeckIndex + 1
        g_leagueRaidData.m_curDeckIndex = self.m_currentDeckIndex
        g_deckData:setSelectedDeck('league_raid_' .. tostring(g_leagueRaidData.m_curDeckIndex))
       
        
        if (world.m_tamer) then
            world.m_tamer:changeState('dying')
        end

        for i,enemy in ipairs(world:getEnemyList()) do
            if (not enemy:isDead()) then
                enemy:changeState('idle', true)
            end
        end

        -- 스킬과 미사일도 다 날려 버리자
	    world:removeMissileAndSkill()
        world:removeEnemyDebuffs()
        world:cleanupItem()

        --[[
        -- 기본 배속으로 변경
        world.m_gameTimeScale:setBase(1)

        world.m_inGameUI:doActionReverse(function()
            world.m_inGameUI.root:setVisible(false)
        end)

        g_gameScene.m_scheduleNode:unscheduleUpdate()
        g_gameScene:onExit()

        local scene = SceneGame(g_leagueRaidData.m_curStageData, stage_id, stage_name, true)
        scene:runScene()]]

        -- 스킬 조작계 초기화
        do
            --world.m_skillIndicatorMgr = SkillIndicatorMgr(world)
            --world.m_gameHighlight = GameHighlightMgr(world, world.m_darkLayer)
            --world.m_gameActiveSkillMgr = GameActiveSkillMgr(world)
        end



        -- 테이머 생성
        self.m_world:initTamer()

        self.m_world:makeHeroDeck()

        -- 초기 쿨타임 설정
        self.m_world:initActiveSkillCool(self.m_world:getDragonList())
    
        -- 초기 마나 설정
        self.m_world.m_mUnitGroup[PHYS.HERO]:getMana():addMana(START_MANA)

        do -- 진형 시스템 초기화
            self.m_world:setBattleZone(self.m_world.m_deckFormation, true)
        end

        self.m_debuffTimer = -1

        self.m_world.m_inGameUI:reinitialze()
        self.m_world:resetMyMana()
        --self.m_world.m_inGameUI:doActionReset()
        --self.m_world:initGame(g_gameScene.m_stageName)
        self.m_bAppearHero = false
        self:appearHero()

        self:changeState(GAME_STATE_ENEMY_APPEAR)
        return false

    elseif(hero_count <= 0) then
        self:changeState(GAME_STATE_SUCCESS_WAIT)
        g_leagueRaidData.m_attackedChar_C = clone(world.m_myDragons)
        return true

    -- 클리어 여부 체크
    elseif (enemy_count <= 0 or self:checkToDieHighestRariry()) then
        self.m_waveClearTimer = self.m_waveClearTimer + dt

        if (self.m_currentDeckIndex == 1) then
            g_leagueRaidData.m_attackedChar_A = clone(world.m_myDragons)
        elseif (self.m_currentDeckIndex == 2) then
            g_leagueRaidData.m_attackedChar_B = clone(world.m_myDragons)
        else
            g_leagueRaidData.m_attackedChar_C = clone(world.m_myDragons)
        end


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
-- function update_failure
-------------------------------------
function GameState_LeagueRaid.update_failure(self, dt)
    local cur_deck_name = g_deckData:getSelectedDeckName()
    local deck_number = pl.stringx.replace(cur_deck_name, 'league_raid_', '')
    deck_number = tonumber(deck_number)
    cclog(self.m_currentDeckIndex)
    if (self.m_currentDeckIndex == 1) then
        g_leagueRaidData.m_attackedChar_A = clone(world.m_myDragons)
    elseif (self.m_currentDeckIndex == 2) then
        g_leagueRaidData.m_attackedChar_B = clone(world.m_myDragons)
    elseif (self.m_currentDeckIndex == 3) then
        g_leagueRaidData.m_attackedChar_C = clone(world.m_myDragons)
    end

    PARENT.update_failure(self, dt)
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
    end

    -- 최초 실행
    func_network_game_finish()
end






-------------------------------------
-- function update_success
-------------------------------------
function GameState_LeagueRaid.update_success(self, dt)
    
    if (self.m_stateTimer == 0) then
        if (self.m_currentDeckIndex == 1) then
            g_leagueRaidData.m_attackedChar_A = clone(self.m_world.m_myDragons)
        elseif (self.m_currentDeckIndex == 2) then
            g_leagueRaidData.m_attackedChar_B = clone(self.m_world.m_myDragons)
        else
            g_leagueRaidData.m_attackedChar_C = clone(self.m_world.m_myDragons)
        end
    end

    PARENT.update_success(self, dt)

end









-------------------------------------
-- function update_boss_wave
-- @brief 보스 웨이브 연출
-------------------------------------
function GameState_LeagueRaid.update_boss_wave(self, dt)
    -- 패배 여부 체크
    if (self.m_currentDeckIndex > 1) then
        self:changeState(GAME_STATE_ENEMY_APPEAR)
        return
    end

    PARENT.update_boss_wave(self, dt)
end






-------------------------------------
-- function update_enemy_appear
-------------------------------------
function GameState_LeagueRaid.update_enemy_appear(self, dt)
    local world = self.m_world
    local enemy_count = #world:getEnemyList()

    if (self.m_stateTimer == 0) then
        local dynamic_wave = #world.m_waveMgr.m_lDynamicWave

        if (enemy_count <= 0) and (dynamic_wave <= 0) then
            self:waveChange()
        end
    
    -- 모든 적들이 등장이 끝났는지 확인
    elseif world.m_waveMgr:isEmptyDynamicWaveList() and self.m_nAppearedEnemys >= enemy_count then
        
        -- 전투 최초 시작시
        if world.m_waveMgr:isFirstWave() then
            world:dispatch('game_start')
            world.m_inGameUI:doAction()
			-- 아군 패시브 효과 적용
			world:passiveActivate_Left()

            -- 아군 AI 초기화
            world:prepareAuto()
        end
        
        -- 웨이브 알림
        do
            self.m_waveNoti:setVisible(true)
            self.m_waveNoti:changeAni('wave', false)


            self.m_waveNum:setVisual('tag', tostring(self.m_currentDeckIndex))
            self.m_waveMaxNum:setVisual('tag', tostring(3))

            local duration = self.m_waveNoti:getDuration()
            self.m_waveNoti:runAction(cc.Sequence:create(
                cc.DelayTime:create(duration),
                cc.CallFunc:create(function(node)
                    node:setVisible(false)
                    self:fight()
                    self:changeState(GAME_STATE_FIGHT)
                end)
            ))

            self:setWave(world.m_waveMgr.m_currWave, world.m_waveMgr.m_maxWave)
            
			-- 웨이브 시작 이벤트 전달
            world:dispatch('wave_start')

			-- 적 패시브 발동
			world:passiveActivate_Right()

			SoundMgr:playEffect('UI', 'ui_wave_start')
        end

        -- 적 이동패턴 정보 초기화
        if (world.m_enemyMovementMgr) then
            world.m_enemyMovementMgr:reset()
        end

        -- 적 AI 초기화
        world:prepareEnemyAuto()
        
        self:changeState(GAME_STATE_FIGHT_WAIT)
    end
    
    -- 웨이브 매니져 업데이트
    world.m_waveMgr:update(dt, true)
end










-------------------------------------
-- function update_failure
-------------------------------------
function GameState_LeagueRaid.update_failure(self, dt)
    local world = self.m_world

    if (self.m_stateTimer == 0) then
        world:setGameFinish()
        if (world.m_tamer) then
            world.m_tamer:changeState('dying')
        end

    elseif (self:isPassedStepTime(1.5)) then
        for i,dragon in ipairs(world:getDragonList()) do
            if (not dragon:isDead()) then
                dragon:changeState('idle')
            end
        end

        for i,enemy in ipairs(world:getEnemyList()) do
            if (not enemy:isDead()) then
                enemy:changeState('idle', true)
            end
        end

        -- 스킬과 미사일도 다 날려 버리자
	    world:removeMissileAndSkill()
        world:removeEnemyDebuffs()
        world:cleanupItem()
        
        -- 기본 배속으로 변경
        world.m_gameTimeScale:setBase(1)

        world.m_inGameUI:doActionReverse(function()
            world.m_inGameUI.root:setVisible(false)
        end)
        self:makeResultUI(false)
    end
end



--    {
--        {
--                ['option']='hp_multi';
--                ['value']='5';
--        };
--        {
--                ['option']='atk_multi';
--                ['value']='5';
--        };
--    }

--    "all;0,atk_dmg_adj_rate_add;50"


-------------------------------------
-- function applyEnrage
-- @brief 광폭화 적용
-------------------------------------
function GameState:applyEnemyBuff()
    local cur_lv, data = g_leagueRaidData:getCurrentDamageLevel()
    local lv_cnt = #g_leagueRaidData.m_leagueRaidData
    local buff_data_list = self.m_buffList
    local world = self.m_world

    --cur_lv = math_max(cur_lv - 1, 0)

    -- 버프, 디버프, 시간별 디버프, 10초마다 발동
    -- LEAGUE_RAID_BUFF = 'all;0;atk_multi;10,all;0;hit_rate_add;5,all;0;resistance_add;5,all;0;avoid_add;2,all;0;cri_chance_add;3'
    -- LEAGUE_RAID_DEBUFF = 'all;0;recovery_power_add;-10,all;0;dmg_adj_rate_multi;10'
    -- LEAGUE_RAID_TIMER_DEBUFF = 'all;0;recovery_power_add;-10,all;0;dmg_adj_rate_multi;10'
    -- LEAGUE_RAID_TIMER_GAP = 10

    -- 시간 버프 적용
    do
        -- 당장은 LEAGUE_RAID_DEBUFF와 같은 값을 써야 한다
        LEAGUE_RAID_TIMER_DEBUFF = LEAGUE_RAID_DEBUFF

        local cur_time = os.time()
        -- self.m_stateTimer
        -- 현재시간 & 기록시간 gap 10초 확인
        if (not self.m_debuffTimer or self.m_debuffTimer <= 0) then
            self.m_debuffTimer = cur_time + LEAGUE_RAID_TIMER_GAP
        end


	    if (cur_time >= self.m_debuffTimer) then
            for i, v in ipairs(world.m_leftParticipants) do
                if (v.m_statusCalc) then
                    v.m_statusCalc:applyAdditionalOptions(LEAGUE_RAID_TIMER_DEBUFF)
                    if (v.m_specialStatusIcon and not v:isDead()) then
                        v.m_specialStatusIcon:setOverlabLabel(v.m_specialStatusIcon.m_overlabCount + 1)
                    else
                        v.m_specialStatusIcon = v:addStatusIcon_direct('curse')
                        v.m_specialStatusIcon:setVisible(true)
                    end
                end
            end

            for i, v in ipairs(world.m_leftNonparticipants) do
                if (v.m_statusCalc) then
                    v.m_statusCalc:applyAdditionalOptions(LEAGUE_RAID_TIMER_DEBUFF)
                    v:addStatusIcon_direct('curse')
                    if (v.m_specialStatusIcon and not v:isDead()) then
                        v.m_specialStatusIcon:setOverlabLabel(v.m_specialStatusIcon.m_overlabCount + 1)
                    else
                        v.m_specialStatusIcon = v:addStatusIcon_direct('curse')
                        v.m_specialStatusIcon:setVisible(true)
                    end
                end
            end

            self.m_debuffTimer = cur_time + 10
        end
    end





    local buff_count = cur_lv - self.m_curLv

    if (cur_lv <= self.m_curLv) then return end

    for lv = 1, buff_count do
        -- 적군 버프 적용
        do
            for i, v in ipairs(world.m_rightParticipants) do
                if (v.m_statusCalc) then
                    v.m_statusCalc:applyAdditionalOptions(LEAGUE_RAID_BUFF)
                    --world:addPassiveStartEffect(v, str_buff_name)
                end
            end

            for i, v in ipairs(world.m_rightNonparticipants) do
                if (v.m_statusCalc) then
                    v.m_statusCalc:applyAdditionalOptions(LEAGUE_RAID_BUFF)
                end
            end
        end

        -- 아군 버프/디버프 적용
        do
            for i, v in ipairs(world.m_leftParticipants) do
                if (v.m_statusCalc) then
                    v.m_statusCalc:applyAdditionalOptions(LEAGUE_RAID_DEBUFF)
                    if (v.m_specialStatusIcon and not v:isDead()) then
                        v.m_specialStatusIcon:setOverlabLabel(v.m_specialStatusIcon.m_overlabCount + 1)
                    else
                        v.m_specialStatusIcon = v:addStatusIcon_direct('curse')
                        v.m_specialStatusIcon:setVisible(true)
                    end
                end
            end

            for i, v in ipairs(world.m_leftNonparticipants) do
                if (v.m_statusCalc) then
                    v.m_statusCalc:applyAdditionalOptions(LEAGUE_RAID_DEBUFF)
                    if (v.m_specialStatusIcon and not v:isDead()) then
                        v.m_specialStatusIcon:setOverlabLabel(v.m_specialStatusIcon.m_overlabCount + 1)
                    else
                        v.m_specialStatusIcon = v:addStatusIcon_direct('curse')
                        v.m_specialStatusIcon:setVisible(true)
                    end
                end
            end
        end
    end

    self.m_curLv = cur_lv
end


