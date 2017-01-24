local PARENT = GameState

-------------------------------------
-- class GameState_Colosseum
-------------------------------------
GameState_Colosseum = class(PARENT, {
    m_gameAutoEnemy = 'GameAuto_Colosseum'
})

-------------------------------------
-- function init
-------------------------------------
function GameState_Colosseum:init(world)
    -- 상대편 드래곤들을 생성함
    self.m_gameAutoEnemy = GameAuto_Colosseum(world, false)
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_Colosseum:initState()
    PARENT.initState(self)
    self:addState(GAME_STATE_START, GameState_Colosseum.update_start)
    self:addState(GAME_STATE_FIGHT, GameState_Colosseum.update_fight)
    self:addState(GAME_STATE_SUCCESS, GameState_Colosseum.update_success)
    self:addState(GAME_STATE_FAILURE, GameState_Colosseum.update_failure)
end

-------------------------------------
-- function update_start
-------------------------------------
function GameState_Colosseum.update_start(self, dt)
    local world = self.m_world
    local map_mgr = world.m_mapManager

    if (self:getStep() == 0) then
        if (self:isBeginningStep()) then
            -- 드래곤들을 숨김
            for i,dragon in ipairs(world:getDragonList()) do
                if (dragon.m_bDead == false) and (dragon.m_charType == 'dragon') then
                    dragon.m_rootNode:setVisible(false)
                    dragon.m_hpNode:setVisible(false)
                    dragon:changeState('idle')
                end
            end

            -- 화면을 빠르게 스크롤
            if map_mgr then
                map_mgr:setSpeed(-1000)  
            end

            SoundMgr:playEffect('VOICE', 'vo_tamer_start')
        
	    elseif (self:isPassedStepTime(DRAGON_APPEAR_TIME)) then
		    self:nextStep()
        end

    elseif (self:getStep() == 1) then
        if (self:isBeginningStep()) then
            SoundMgr:playEffect('EFFECT', 'summon')
        
            world:dispatch('dragon_summon')

        elseif (self:getStepTimer() >= 0.5) then
            self:appearDragon()

            self:nextStep()
        end

    elseif (self:getStep() == 2) then
        if (self:isBeginningStep()) then
        elseif (self:getStepTimer() >= 1) then
            world:dispatch('game_start')
            world:buffActivateAtStartup()
            world.m_inGameUI:doAction()

            self:fight()
            self:changeState(GAME_STATE_FIGHT)
        end

    end
end

-------------------------------------
-- function update_fight
-------------------------------------
function GameState_Colosseum.update_fight(self, dt)
    GameState.update_fight(self, dt)
    
    if self.m_gameAutoEnemy then
        self.m_gameAutoEnemy:update(dt) 
    end

    do -- 적군 액티브 스킬 쿨타임 증가
        for _, enemy in pairs(self.m_world:getEnemyList()) do
            enemy:updateActiveSkillCoolTime(dt)
        end
    end
end

-------------------------------------
-- function update_fight_fever
-------------------------------------
function GameState_Colosseum.update_fight_fever(self, dt)
    PARENT.update_fight_fever(self, dt)

    if self.m_gameAutoEnemy then
        self.m_gameAutoEnemy:update(dt) 
    end
end

-------------------------------------
-- function update_success
-------------------------------------
function GameState_Colosseum.update_success(self, dt)
    
    if (self.m_stateTimer == 0) then
        local world = self.m_world

        -- 모든 적들을 죽임
        world:killAllEnemy()

        world:setWaitAllCharacter(false) -- 포즈 연출을 위해 wait에서 해제

        for i,dragon in ipairs(world:getDragonList()) do
            if (dragon.m_bDead == false) then
                dragon:killStateDelegate()
                dragon:changeState('success_pose') -- 포즈 후 오른쪽으로 사라짐
            end
        end

        g_gameScene.m_inGameUI:doActionReverse(function()
            g_gameScene.m_inGameUI.root:setVisible(false)
        end)

        self.m_stateParam = true

        self.m_world:dispatch('stage_clear')

    elseif (self.m_stateTimer >= 3.5) then
        if self.m_stateParam then
            self.m_stateParam = false

            local scene = SceneAdventure()
            scene:runScene()
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
            if world.m_skillIndicatorMgr then
                world.m_skillIndicatorMgr:clear()
            end

            g_gameScene.m_inGameUI:doActionReverse(function()
                g_gameScene.m_inGameUI.root:setVisible(false)
            end)

            -- 스킬과 미사일도 다 날려 버리자
	        world:removeMissileAndSkill()
            world:removeEnemyDebuffs()
        end
        
        -- 적군 상태 체크
        local b = true

        for _, enemy in pairs(world:getEnemyList()) do
            if (not enemy.m_bDead and enemy.m_state ~= 'wait') then
                b = false
            end
        end

        if (b or self:getStepTimer() >= 4) then
            self:nextStep()
        end
    
    elseif (self:getStep() == 1) then
        if (self:isBeginningStep()) then
            for i,enemy in ipairs(world:getEnemyList()) do
                if (enemy.m_bDead == false) then
                    enemy:killStateDelegate()
                    enemy.m_animator:changeAni('pose_1', true)
                end
            end
        
        elseif (self:getStepTimer() >= 3.5) then
            local scene = SceneAdventure()
            scene:runScene()

        end
    end
end
