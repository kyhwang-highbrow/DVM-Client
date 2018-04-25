local PARENT = GameState

local HERO_TAMER_POS_X = 320 - 50
local ENEMY_TAMER_POS_X = 960 + 50

local FURY_EFFECT_START_TIME_FROM_BUFF_TIME = 4

-------------------------------------
-- class GameState_Colosseum
-------------------------------------
GameState_Colosseum = class(PARENT, {
        m_bWin = 'boolean',

        m_bgEffect = '',            -- 배경 연출(광폭화)
        m_bgEffectStartTime = '',   -- 배경 연출 시작 시간
    })

-------------------------------------
-- function init
-------------------------------------
function GameState_Colosseum:init(world)
    -- 콜로세움은 제한시간 5분으로 고정
    self.m_limitTime = 300

    self.m_bgEffectStartTime = 0
end

-------------------------------------
-- function initBuffByFightTime
-------------------------------------
function GameState_Colosseum:initBuffByFightTime()
    PARENT.initBuffByFightTime(self)

    -- 실제 버프 시간보다 이전에 연출되어야하는 것들을 처리하기 위한 하드코딩...
    self.m_nextBuffTime = self.m_nextBuffTime - FURY_EFFECT_START_TIME_FROM_BUFF_TIME
    self.m_nextBuffTime = math_max(self.m_nextBuffTime, 1)
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
                pos_y = -280,
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

        elseif (self:getStepTimer() >= 3) then
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
        world:prepareAuto()

        world.m_inGameUI:doAction()

        self:fight()

        -- 배경 연출 시작
        world.m_mapManager:setDirecting('floating_colosseum')

		self:changeState(GAME_STATE_FIGHT)
	end
end

-------------------------------------
-- function update_success
-------------------------------------
function GameState_Colosseum.update_success(self, dt)
    
    if (self.m_stateTimer == 0) then
        local world = self.m_world
        world:setGameFinish()

        -- 모든 적들을 죽임
        world:removeAllEnemy()
        world:removeMissileAndSkill()

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
            world:setGameFinish()
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

            -- 드래곤을 모두 죽임
            world:removeAllHero()

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
-- function checkToDieHighestRariry
-- @brief 가장 높은 등급의 적(보스)가 죽었은지 체크
-------------------------------------
function GameState_Colosseum:checkToDieHighestRariry()
    return false
end

-------------------------------------
-- function doDirectionForIntermission
-------------------------------------
function GameState_Colosseum:doDirectionForIntermission()
    local t_camera_info = {}
    	
    t_camera_info['pos_x'] = 0
	t_camera_info['pos_y'] = 280
	t_camera_info['time'] = getInGameConstant("WAVE_INTERMISSION_TIME")
        
    -- 카메라 액션 설정
    self.m_world:changeCameraOption(t_camera_info)

    self.m_world:changeHeroHomePosByCamera()
    self.m_world:changeEnemyHomePosByCamera()
end

-------------------------------------
-- function processTimeOut
-------------------------------------
function GameState_Colosseum:processTimeOut()
    self.m_bTimeOut = true

    local inGameUi = self.m_world.m_inGameUI

    local hero_hp = inGameUi:getHeroHpGaugePercentage()
    local enemy_hp = inGameUi:getEnemyHpGaugePercentage()

    if (hero_hp < enemy_hp) then
        self:changeState(GAME_STATE_FAILURE)
    else
        self:changeState(GAME_STATE_SUCCESS_WAIT)
    end
end

-------------------------------------
-- function pause
-------------------------------------
function GameState_Colosseum:pause()
    PARENT.pause(self)

    if (self.m_bgEffect) then
        self.m_bgEffect.m_node:pause()
    end
end

-------------------------------------
-- function resume
-------------------------------------
function GameState_Colosseum:resume()
    PARENT.resume(self)

    if (self.m_bgEffect) then
        self.m_bgEffect.m_node:resume()
    end
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_Colosseum:makeResultUI(is_win)
    if (self.m_world.m_bDevelopMode) then
        local t_data = { added_rp = 0, added_honor = 0 }
        UI_ColosseumResult(is_win, t_data)

    elseif (self.m_world.m_bFriendMatch) then
        UI_FriendMatchResult(is_win)

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


-------------------------------------
-- function applyBuffByFightTime
-- @brief 주기시간에 따른 추가 버프를 적용
-------------------------------------
function GameState_Colosseum:applyBuffByFightTime()
    if (self.m_bgEffectStartTime == self.m_nextBuffTime) then return end
    self.m_bgEffectStartTime = self.m_nextBuffTime

    -- 연출 먼저 시작 후 중간에 버프 적용
    if (not self.m_bgEffect) then
        local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()

        self.m_bgEffect = MakeAnimator('res/bg/colosseum_2/colosseum_2.vrp')
        self.m_bgEffect:setPosition(cameraHomePosX + (CRITERIA_RESOLUTION_X / 2), cameraHomePosY)
        self.m_bgEffect:setDockPoint(cc.p(0.5, 0.5))
		self.m_bgEffect:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_world.m_worldNode:addChild(self.m_bgEffect.m_node, WORLD_Z_ORDER.FRONT_EFFECT)
    end

    self.m_bgEffect:changeAni('change', false)
    self.m_bgEffect:runAction(cc.Sequence:create(cc.DelayTime:create(FURY_EFFECT_START_TIME_FROM_BUFF_TIME), cc.CallFunc:create(function()
        if (self:isFight()) then
            PARENT.applyBuffByFightTime(self)

            -- 실제 버프 시간보다 이전에 연출되어야하는 것들을 처리하기 위한 하드코딩...
            self.m_nextBuffTime = self.m_nextBuffTime - FURY_EFFECT_START_TIME_FROM_BUFF_TIME
            self.m_nextBuffTime = math_max(self.m_nextBuffTime, 1)
        end
    end)))

    -- 배경 흔들림
    local level = self.m_buffCount + 1
    self.m_world.m_mapManager:setDirecting('colosseum_fury_' .. level)
end