local PARENT = GameState

-------------------------------------
-- class GameState_NestDungeon_Dragon
-------------------------------------
GameState_NestDungeon_Dragon = class(PARENT, {
    })

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_NestDungeon_Dragon:initState()
    PARENT.initState(self)
    self:addState(GAME_STATE_START, GameState_NestDungeon_Dragon.update_start)
end

-------------------------------------
-- function update_start
-------------------------------------
function GameState_NestDungeon_Dragon.update_start(self, dt)
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
            
            local speed = map_mgr.m_speed + (MAP_SCROLL_SPEED_DOWN_ACCEL * dt)
            if (speed >= -300) then
                speed = -300

                -- 등장 완료일 경우
                if self.m_bAppearDragon then
                    self:nextStep()
                end
            end
            map_mgr:setSpeed(speed)
        end

    elseif (self:getStep() == 2) then
        -- 화면 흔들림 & 포효
        if (self:isBeginningStep()) then
            world.m_shakeMgr:doShake(50, 50, 1)

            SoundMgr:playEffect('EFFECT', 'gdragon_appear')

        elseif (self:getStepTimer() >= 2) then
            self:nextStep()
        end

    elseif (self:getStep() == 3) then
        -- 화면 흔들림 & 드래곤이 지나감
        if (self:isBeginningStep()) then
            world:dispatch('nest_dragon_start', function() self:nextStep() end)

        elseif (self:isPassedStepTime(0.6)) then
            world.m_shakeMgr:doShake(50, 50, 1)

            SoundMgr:playEffect('EFFECT', 'gdragon_appear')
        end

    elseif (self:getStep() == 4) then
        if (self:isBeginningStep()) then
            self:changeState(GAME_STATE_ENEMY_APPEAR)
        end
    end
end


-------------------------------------
-- function doDirectionForIntermission
-------------------------------------
function GameState_NestDungeon_Dragon:doDirectionForIntermission()
    local world = self.m_world
    local map_mgr = world.m_mapManager

    local t_wave_data, is_final_wave = world.m_waveMgr:getNextWaveScriptData()
    local t_camera_info = t_wave_data['camera'] or {}
    local curCameraPosX, curCameraPosY = world.m_gameCamera:getHomePos()
		
	if (world.m_bDevelopMode == false) then
        -- 네스트 던전일 경우 웨이브 스크립트에 있는 카메라 정보로 설정
        t_camera_info['pos_x'] = t_camera_info['pos_x'] * t_camera_info['scale']
		t_camera_info['pos_y'] = t_camera_info['pos_y'] * t_camera_info['scale']
		t_camera_info['time'] = getInGameConstant(WAVE_INTERMISSION_TIME)

        -- 마지막 웨이브 시작 연출
        if is_final_wave then
            world:dispatch('nest_dragon_final_wave')

            SoundMgr:playEffect('EFFECT', 'gdragon_appear')
        end
    end
        
    -- 카메라 액션 설정
    world:changeCameraOption(t_camera_info)
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_NestDungeon_Dragon:makeResultUI(is_success)
    -- 작업 함수들
    local func_network_game_finish
    local func_ui_result

    -- UI연출에 필요한 테이블들
    local t_result_ref = {}
    t_result_ref['user_levelup_data'] = {}
    t_result_ref['dragon_levelu_data_list'] = {}
    t_result_ref['drop_reward_grade'] = 'c'
    t_result_ref['drop_reward_list'] = {}

    -- 1. 네트워크 통신
    func_network_game_finish = function()
        local t_param = self:makeGameFinishParam(is_success)
        g_gameScene:networkGameFinish(t_param, t_result_ref, func_ui_result)
    end

    -- 2. UI 생성
    func_ui_result = function()
        local world = self.m_world
        local stage_id = world.m_stageID
                
        UI_GameResult_NestDungeon(stage_id,
            is_success,
            self.m_fightTimer,
            world.m_gold,
            t_result_ref['user_levelup_data'],
            t_result_ref['dragon_levelu_data_list'],
            t_result_ref['drop_reward_grade'],
            t_result_ref['drop_reward_list'])
    end

    -- 최초 실행
    func_network_game_finish()
end