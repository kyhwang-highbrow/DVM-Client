local PARENT = GameState_NestDungeon

-------------------------------------
-- class GameState_NestDungeon_Tree
-------------------------------------
GameState_NestDungeon_Tree = class(PARENT, {})

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_NestDungeon_Tree:initState()
    PARENT.initState(self)
    self:addState(GAME_STATE_START, GameState_NestDungeon_Tree.update_start)
end


-------------------------------------
-- function update_start
-------------------------------------
function GameState_NestDungeon_Tree.update_start(self, dt)
    local world = self.m_world
    local map_mgr = world.m_mapManager

    if (self:getStep() == 0) then
        if (self:isBeginningStep()) then
            -- 드래곤들을 숨김
            for i,dragon in ipairs(world:getDragonList()) do
                if (not dragon:isDead()) and (dragon.m_charType == 'dragon') then
                    dragon.m_rootNode:setVisible(false)
                    dragon.m_hpNode:setVisible(false)
                    dragon:changeState('idle')
                end
            end

            -- 테이머 등장
            if (world.m_tamer) then
                world.m_tamer:changeState('appear')
            end

            --SoundMgr:playEffect('VOICE', 'vo_tamer_start')
        
	    elseif (self:isPassedStepTime(g_constant:get('INGAME', 'TAMER_APPEAR_TIME'))) then
		    self:nextStep()
        end

    elseif (self:getStep() == 1) then
        if (self:isBeginningStep()) then
            SoundMgr:playEffect('UI', 'ui_summon')
        
            world:dispatch('dragon_summon')

        elseif (self:isPassedStepTime(0.5)) then
            self:appearHero()

            -- 테이머 이동
            if (world.m_tamer) then
                world.m_tamer:runAction_MoveZ(1)
            end
            
        elseif (self:getStepTimer() >= 2) then
            world.m_tamer:initBarrier()

            self:nextStep()

        end

    elseif (self:getStep() == 2) then
        if (self:isBeginningStep()) then
            self:changeState(GAME_STATE_ENEMY_APPEAR)
        end

    end
end


-------------------------------------
-- function doDirectionForIntermission
-------------------------------------
function GameState_NestDungeon_Tree:doDirectionForIntermission()
    local world = self.m_world
    local map_mgr = world.m_mapManager

    local t_wave_data, is_final_wave = world.m_waveMgr:getNextWaveScriptData()
    local t_camera_info = t_wave_data['camera'] or {}
    local curCameraPosX, curCameraPosY = world.m_gameCamera:getHomePos()
		
	if (world.m_bDevelopMode == false) then
        -- 네스트 던전일 경우 웨이브 스크립트에 있는 카메라 정보로 설정
        t_camera_info['time'] = getInGameConstant("WAVE_INTERMISSION_TIME")

        -- 마지막 웨이브 시작 연출
        if is_final_wave then
            --SoundMgr:playEffect('VOICE', 'vo_gdragon_appear')
        end
    end
        
    -- 카메라 액션 설정
    world:changeCameraOption(t_camera_info)
    world:changeHeroHomePosByCamera()
end