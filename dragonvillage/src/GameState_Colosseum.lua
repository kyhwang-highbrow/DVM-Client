-------------------------------------
-- class GameState_Colosseum
-------------------------------------
GameState_Colosseum = class(GameState, {})

-------------------------------------
-- function init
-------------------------------------
function GameState_Colosseum:init(world)
    -- 상대편 드래곤들을 생성함
    
end

-------------------------------------
-- function update_start
-------------------------------------
function GameState_Colosseum:update_start(dt)
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
function GameState_Colosseum:update_fight(dt)
    self.m_fightTimer = self.m_fightTimer + dt
    local world = self.m_world

    local hero_count = #world:getDragonList()
    local enemy_count = #world:getEnemyList()

    -- 클리어 여부 체크
    --if (enemy_count <= 0) then
    if false then
        self:changeState(GAME_STATE_SUCCESS_WAIT)
    elseif hero_count <= 0 then
        self:changeState(GAME_STATE_FAILURE)
    end
end

-------------------------------------
-- function waveChange
-------------------------------------
function GameState_Colosseum:waveChange()
end

-------------------------------------
-- function doDirectionForIntermission
-------------------------------------
function GameState_Colosseum:doDirectionForIntermission()
end