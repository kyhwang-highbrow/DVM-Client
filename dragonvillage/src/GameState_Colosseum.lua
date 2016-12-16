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
            if not self.m_bAppearDragon then
                self:appearDragon()
            end

            local speed = map_mgr.m_speed + (MAP_SCROLL_SPEED_DOWN_ACCEL * dt)
            if (speed >= -300) then
                speed = -300

                -- 등장 완료일 경우
                if self.m_bAppearDragon then
                    self:changeState(GAME_STATE_ENEMY_APPEAR)
                end
            end
            map_mgr:setSpeed(speed)
        end
    end
end