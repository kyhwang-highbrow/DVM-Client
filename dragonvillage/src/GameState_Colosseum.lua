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