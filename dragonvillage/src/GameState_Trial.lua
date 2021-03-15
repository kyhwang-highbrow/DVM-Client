local PARENT = GameState
--[[
GAME_STATE_NONE = 0

GAME_STATE_LOADING = 1  -- Scene전환 후 첫 상태
GAME_STATE_START = 2  -- 테이머 등장 및 아군 소환

GAME_STATE_WAVE_INTERMISSION = 90 -- wave 인터미션
GAME_STATE_WAVE_INTERMISSION_WAIT = 91

GAME_STATE_ENEMY_APPEAR = 99  -- 적 등장

GAME_STATE_FIGHT = 100
GAME_STATE_FIGHT_WAIT = 101

-- 파이널 웨이브 연출
GAME_STATE_FINAL_WAVE = 201

-- 보스 웨이브 연출
GAME_STATE_BOSS_WAVE = 211

GAME_STATE_SUCCESS_WAIT = 300
GAME_STATE_SUCCESS = 301
GAME_STATE_FAILURE = 302

GAME_STATE_RESULT = 400
]]

-- 스테이지코드 : 게임코드 뒤에 01, 02 붙인다
GAME_STATE_ENEMY_PREPARATION = 3001 -- 싸우기 전 연출

-------------------------------------
-- class GameState_NestDungeon_Tree
-------------------------------------
GameState_Trial = class(PARENT, {})

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_Trial:initState()
    PARENT.initState(self)

    self:addState(GAME_STATE_ENEMY_APPEAR,          GameState_Trial.update_enemy_appear)
    self:addState(GAME_STATE_ENEMY_PREPARATION,     GameState_Trial.update_enemy_Preparation)
end

-------------------------------------
-- function update_enemy_appear
-------------------------------------
function GameState_Trial.update_enemy_appear(self, dt)
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
            self.m_waveNum:setVisual('tag', tostring(world.m_waveMgr.m_currWave))
            self.m_waveMaxNum:setVisual('tag', tostring(world.m_waveMgr.m_maxWave))

            local duration = self.m_waveNoti:getDuration()
            self.m_waveNoti:runAction(cc.Sequence:create(
                cc.DelayTime:create(duration),
                cc.CallFunc:create(function(node)
                    node:setVisible(false)
                    self:changeState(GAME_STATE_ENEMY_PREPARATION)
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
-- function update_enemy_appear
-------------------------------------
function GameState_Trial.update_enemy_Preparation(self, dt)
    self:startFight()
end

-------------------------------------
-- function update_enemy_appear
-------------------------------------
function GameState_Trial:startFight()
    self:fight()
    self:changeState(GAME_STATE_FIGHT)
end