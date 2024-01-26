local PARENT = GameState_WorldRaid
-------------------------------------
--- @class GameState_WorldRaid_Linger
-------------------------------------
GameState_WorldRaid_Linger = class(PARENT, {    
    m_currentDeckIndex = 'number',
    })


-------------------------------------
-- function init
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_WorldRaid_Linger:init()
    self.m_bgmBoss = 'bgm_dungeon_boss'
    local cur_deck_name = g_deckData:getSelectedDeckName()
    local deck_number = pl.stringx.replace(cur_deck_name, 'world_raid_', '')

    self.m_currentDeckIndex = tonumber(deck_number)
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_WorldRaid_Linger:initState()
    self:addState(GAME_STATE_NONE,                   function(self, dt) end)
    self:addState(GAME_STATE_START, GameState_WorldRaid.update_start)
    self:addState(GAME_STATE_FIGHT, GameState_WorldRaid.update_fight)
    self:addState(GAME_STATE_RESULT, GameState_WorldRaid.update_result)

    self:addState(GAME_STATE_ENEMY_APPEAR, GameState_WorldRaid_Linger.update_enemy_appear)
    self:addState(GAME_STATE_FIGHT_WAIT,   GameState_WorldRaid_Linger.update_fight_wait)

    self:addState(GAME_STATE_RAID_WAVE,   GameState_WorldRaid_Linger.update_raid_wave)  -- 레이드 웨이브 연출
    self:addState(GAME_STATE_SUCCESS_WAIT,GameState_WorldRaid_Linger.update_success_wait)

    self:addState(GAME_STATE_SUCCESS,  GameState_WorldRaid.update_result)
    self:addState(GAME_STATE_FAILURE,  GameState_WorldRaid.update_result)
end

-------------------------------------
-- function getDeckName
-------------------------------------
function GameState_WorldRaid_Linger:getDeckName()
    local cur_deck_name = g_deckData:getSelectedDeckName()
    return cur_deck_name
end

-------------------------------------
-- function checkWaveClear
-------------------------------------
function GameState_WorldRaid_Linger:checkWaveClear(dt)
    local world = self.m_world
    local hero_count = #world:getDragonList()
    local enemy_count = world:getEnemyCount()

    -- 패배 여부 체크
    if (self.m_currentDeckIndex < 3 and hero_count <= 0) then        
        if (self.m_currentDeckIndex == 1) then
            g_worldRaidData.m_attackedChar_A = clone(world.m_myDragons)
        else
            g_worldRaidData.m_attackedChar_B = clone(world.m_myDragons)
        end
        
        self.m_currentDeckIndex = self.m_currentDeckIndex + 1
        g_worldRaidData.m_curDeckIndex = self.m_currentDeckIndex
        g_deckData:setSelectedDeck('world_raid_' .. tostring(g_worldRaidData.m_curDeckIndex))
       
        
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
        g_worldRaidData.m_attackedChar_C = clone(world.m_myDragons)
        return true

    else
        self.m_waveClearTimer = 0
    end

    return false
end

-------------------------------------
-- function update_enemy_appear
-------------------------------------
function GameState_WorldRaid_Linger.update_enemy_appear(self, dt)
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
-- function update_success
-------------------------------------
function GameState_WorldRaid_Linger.update_success(self, dt)
    if (self.m_stateTimer == 0) then
        if (self.m_currentDeckIndex == 1) then
            g_worldRaidData.m_attackedChar_A = clone(self.m_world.m_myDragons)
        elseif (self.m_currentDeckIndex == 2) then
            g_worldRaidData.m_attackedChar_B = clone(self.m_world.m_myDragons)
        else
            g_worldRaidData.m_attackedChar_C = clone(self.m_world.m_myDragons)
        end
    end

    PARENT.update_success(self, dt)

    local world = self.m_world
    cclog(debug.traceback())
end


-------------------------------------
-- function update_failure
-------------------------------------
function GameState_WorldRaid_Linger.update_failure(self, dt)
    local world = self.m_world
    cclog(debug.traceback())
    --while true do end

    if (self.m_stateTimer == 0) then
        world:setGameFinish()
        if (world.m_tamer) then
            world.m_tamer:changeState('dying')
        end

        if (self.m_currentDeckIndex == 1) then
            g_worldRaidData.m_attackedChar_A = clone(world.m_myDragons)
        elseif (self.m_currentDeckIndex == 2) then
            g_worldRaidData.m_attackedChar_B = clone(world.m_myDragons)
        elseif (self.m_currentDeckIndex == 3) then
            g_worldRaidData.m_attackedChar_C = clone(world.m_myDragons)
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

        UINavigator:goTo('league_raid')
        --self:makeResultUI(false)
    end
end
