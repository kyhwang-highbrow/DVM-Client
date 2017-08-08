local PARENT = GameState

local HERO_TAMER_POS_X = 320 - 50
local ENEMY_TAMER_POS_X = 960 + 50
local TAMER_POS_Y = -450

-------------------------------------
-- class GameState_Colosseum
-------------------------------------
GameState_Colosseum = class(PARENT, {
        m_bWin = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function GameState_Colosseum:init(world)
    -- 콜로세움은 제한시간 5분으로 고정
    self.m_limitTime = 300
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_Colosseum:initState()
    PARENT.initState(self)

    self:addState(GAME_STATE_START, GameState_Colosseum.update_start)
    self:addState(GAME_STATE_WAVE_INTERMISSION, GameState_Colosseum.update_wave_intermission)
    self:addState(GAME_STATE_SUCCESS, GameState_Colosseum.update_success)
    self:addState(GAME_STATE_FAILURE, GameState_Colosseum.update_failure)
    self:addState(GAME_STATE_RESULT, GameState_Colosseum.update_result)
end

-------------------------------------
-- function update_start
-------------------------------------
function GameState_Colosseum.update_start(self, dt)
    local world = self.m_world
    local map_mgr = world.m_mapManager

    if (self:getStep() == 0) then
        if (self:isBeginningStep()) then
            -- 아군 적군 드래곤들을 모두 숨김
            self:disappearAllDragon()

            -- 카메라 초기화
            world.m_gameCamera:reset()

        elseif (self:isPassedStepTime(0.5)) then
            
            -- 카메라 줌인
            world:changeCameraOption({
                pos_x = 0,
                pos_y = -300,
                scale = 1,
                time = 2,
                cb = function()
                    self:nextStep()
                end
            })

            world:changeHeroHomePosByCamera(0, 100, 0, true)
            world:changeEnemyHomePosByCamera(0, 100, 0, true)
	    
        end

    elseif (self:getStep() == 1) then
        if (self:isBeginningStep()) then
            -- 아군 드래곤 소환
            world.m_tamer.m_animator.m_node:resume()
            
            -- 적군 드래곤 소환
            world.m_enemyTamer.m_animator.m_node:resume()
            
        elseif (self:isPassedStepTime(1)) then
            self:appearHero()
            self:appearEnemy()

            SoundMgr:playEffect('UI', 'ui_summon')

            world:dispatch('dragon_summon')

        elseif (self:isPassedStepTime(3)) then
            self:nextStep()

        end

    elseif (self:getStep() == 2) then
        if (self:isBeginningStep()) then
            -- 카메라 초기화
            world:changeCameraOption({
                pos_x = 0,
                pos_y = 0,
                scale = 1,
                time = 2,
                cb = function()
                    self:nextStep()
                end
            })

            self.m_world.m_tamer:initBarrier()
            self.m_world.m_enemyTamer:initBarrier()
        end

    elseif (self:getStep() == 3) then
        if (self:isBeginningStep()) then
            
            if (world.m_tamer) then
                world.m_tamer:setAnimatorScale(0.5)
                world.m_tamer.m_barrier:setVisible(true)
            end

            if (world.m_enemyTamer) then
                world.m_enemyTamer:setAnimatorScale(0.5)
                world.m_enemyTamer.m_barrier:setVisible(true)
            end

            self:changeState(GAME_STATE_WAVE_INTERMISSION)
        end
    end
end

-------------------------------------
-- function update_wave_intermission
-------------------------------------
function GameState_Colosseum.update_wave_intermission(self, dt)
    local world = self.m_world
		
    if (self.m_stateTimer == 0) then
        -- 연출(카메라)
        self:doDirectionForIntermission()
    end
    	
	if (self.m_stateTimer > getInGameConstant("WAVE_INTERMISSION_TIME")) then
        world:dispatch('game_start')

        -- 패시브 효과 적용
        world:passiveActivate_Left()
		world:passiveActivate_Right()

        -- AI 초기화
        world.m_gameAutoHero:prepare(world:getDragonList())
        world.m_gameAutoEnemy:prepare(world:getEnemyList())

        world.m_inGameUI:doAction()

        self:fight()

		self:changeState(GAME_STATE_FIGHT)
	end
end

-------------------------------------
-- function update_success
-------------------------------------
function GameState_Colosseum.update_success(self, dt)
    
    if (self.m_stateTimer == 0) then
        local world = self.m_world

        -- 모든 적들을 죽임
        world:removeAllEnemy()
        world.m_enemyTamer:changeState('dying')

        -- 기본 배속으로 변경
        world.m_gameTimeScale:setBase(1)

        --world:setWaitAllCharacter(false) -- 포즈 연출을 위해 wait에서 해제

        for i, hero in ipairs(world:getDragonList()) do
            if (not hero:isDead()) then
                hero:killStateDelegate()
                hero.m_animator:changeAni('pose_1', true)
            end
        end

        world.m_inGameUI:doActionReverse(function()
            world.m_inGameUI.root:setVisible(false)
        end)

        self.m_stateParam = true

        self.m_world:dispatch('stage_clear')

    elseif (self.m_stateTimer >= 3.5) then
        if self.m_stateParam then
            self.m_stateParam = false
            self.m_bWin = true
            self:changeState(GAME_STATE_RESULT)
        end
    end
end

-------------------------------------
-- function update_failure
-------------------------------------
function GameState_Colosseum.update_failure(self, dt)
    local world = self.m_world

    if (self:getStep() == 0) then
        if (self:isBeginningStep()) then
            if (world.m_tamer) then
                world.m_tamer:changeState('dying')
            end

        elseif (self:isPassedStepTime(1.5)) then
            if world.m_skillIndicatorMgr then
                world.m_skillIndicatorMgr:clear(true)
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
        else
            -- 적군 상태 체크
            local b = true

            for _, enemy in pairs(world:getEnemyList()) do
                if (not enemy:isDead() and enemy.m_state ~= 'wait') then
                    b = false
                end
            end

            if (b or self:getStepTimer() >= 4) then
                self:nextStep()
            end
        end
    
    elseif (self:getStep() == 1) then
        if (self:isBeginningStep()) then
            for i,enemy in ipairs(world:getEnemyList()) do
                if (not enemy:isDead()) then
                    enemy:killStateDelegate()
                    enemy.m_animator:changeAni('pose_1', true)
                end
            end
        
        elseif (self:getStepTimer() >= 3.5) then
            self.m_bWin = false
            self:changeState(GAME_STATE_RESULT)
        end
    end
end

-------------------------------------
-- function update_result
-------------------------------------
function GameState_Colosseum.update_result(self, dt)
    if (self.m_stateTimer == 0) then
        self:makeResultUI(self.m_bWin)
    end
end

-------------------------------------
-- function disappearAllDragon
-------------------------------------
function GameState_Colosseum:disappearAllDragon()
    local disappearDragon = function(dragon)
        if (not dragon:isDead()) then
            dragon.m_rootNode:setVisible(false)
            dragon.m_hpNode:setVisible(false)
            dragon:changeState('idle')
        end
    end
    
    for i, dragon in ipairs(self.m_world:getDragonList()) do
        disappearDragon(dragon)
    end

    for i, dragon in ipairs(self.m_world:getEnemyList()) do
        disappearDragon(dragon)
    end
end

-------------------------------------
-- function appearEnemy
-------------------------------------
function GameState_Colosseum:appearEnemy()
    -- 드래곤들을 등장
    local world = self.m_world
    for i,dragon in ipairs(world:getEnemyList()) do
        dragon:doAppear()
    end
end

-------------------------------------
-- function fight
-------------------------------------
function GameState_Colosseum:fight()
    PARENT.fight(self)

    if (self.m_world.m_enemyTamer) then
        self.m_world.m_enemyTamer:changeState('roam')
    end
end

-------------------------------------
-- function checkWaveClear
-------------------------------------
function GameState_Colosseum:checkWaveClear(dt)
    local world = self.m_world
    local enemy_count = #world:getEnemyList()

    -- 클리어 여부 체크
    if (enemy_count <= 0) then
        self.m_waveClearTimer = self.m_waveClearTimer + dt

        if (self.m_waveClearTimer > 0.5) then
            self.m_waveClearTimer = 0

            self:changeState(GAME_STATE_SUCCESS_WAIT)
            return true
        end
    else
        self.m_waveClearTimer = 0
    end

    return false
end

-------------------------------------
-- function doDirectionForIntermission
-------------------------------------
function GameState_Colosseum:doDirectionForIntermission()
    local t_camera_info = {}
    	
    t_camera_info['pos_x'] = 0
	t_camera_info['pos_y'] = 300
	t_camera_info['time'] = getInGameConstant("WAVE_INTERMISSION_TIME")
        
    -- 카메라 액션 설정
    self.m_world:changeCameraOption(t_camera_info)

    self.m_world:changeHeroHomePosByCamera()
    self.m_world:changeEnemyHomePosByCamera()
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_Colosseum:makeResultUI(is_win)
    if (self.m_world.m_bDevelopMode) then
        local t_data = { added_rp = 0, added_honor = 0 }
        UI_ColosseumResult(is_win, t_data)

    else
        -- 작업 함수들
        local func_network_game_finish
        local func_ui_result

        -- 1. 네트워크 통신
        func_network_game_finish = function()
            g_colosseumData:request_colosseumFinish(is_win, func_ui_result)
        end

        -- 2. UI 생성
        func_ui_result = function(ret)
            local t_data = ret
            UI_ColosseumResult(is_win, t_data)
        end

        -- 최초 실행
        func_network_game_finish()
    end
end