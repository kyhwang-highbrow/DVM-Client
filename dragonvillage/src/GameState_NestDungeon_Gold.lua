local PARENT = GameState_NestDungeon

-------------------------------------
-- class GameState_NestDungeon_Gold
-------------------------------------
GameState_NestDungeon_Gold = class(PARENT, {
    })

--[[
-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_NestDungeon_Gold:init()
    self.m_bgmBoss = 'bgm_dungeon_boss'

    -- 제한 시간 설정
    local t_drop = TableDrop():get(self.m_world.m_stageID)
    self.m_limitTime = t_drop['time_limit']
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_NestDungeon_Gold:initState()
    PARENT.initState(self)
    self:addState(GAME_STATE_SUCCESS, GameState_NestDungeon_Gold.update_success)
end

-------------------------------------
-- function update_success
-------------------------------------
function GameState_NestDungeon_Gold.update_success(self, dt)
    
    if (self.m_stateTimer == 0) then
        local world = self.m_world

        -- 모든 적들을 죽임
        world:removeAllEnemy()

        world:setWaitAllCharacter(false) -- 포즈 연출을 위해 wait에서 해제

        for i, hero in ipairs(world:getDragonList()) do
            if (hero.m_bDead == false) then
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
            self:makeResultUI(true)
            self.m_stateParam = false
        end
    end
end

-------------------------------------
-- function doDirectionForIntermission
-------------------------------------
function GameState_NestDungeon_Gold:doDirectionForIntermission()
    local world = self.m_world
    local map_mgr = world.m_mapManager

    local t_wave_data, is_final_wave = world.m_waveMgr:getNextWaveScriptData()
    local t_camera_info = t_wave_data['camera'] or {}
    local curCameraPosX, curCameraPosY = world.m_gameCamera:getHomePos()
		
	if (world.m_bDevelopMode == false) then
        -- 황금 던전일 경우 웨이브 스크립트에 있는 카메라 정보로 설정
        t_camera_info['pos_x'] = t_camera_info['pos_x'] * t_camera_info['scale']
		t_camera_info['pos_y'] = t_camera_info['pos_y'] * t_camera_info['scale']
		t_camera_info['time'] = getInGameConstant("WAVE_INTERMISSION_TIME")
    end

    -- 카메라 액션 설정
    world:changeCameraOption(t_camera_info)
    world:changeHeroHomePosByCamera()
end
]]