local PARENT = GameState

-------------------------------------
-- class GameState_Intro
-------------------------------------
GameState_Intro = class(PARENT, {
    })

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_Intro:init()
    self.m_bgmBoss = 'bgm_dungeon_boss'
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_Intro:initState()
    PARENT.initState(self)
    
    self:addState(GAME_STATE_WAVE_INTERMISSION, GameState_Intro.update_wave_intermission)
end

-------------------------------------
-- function update_wave_intermission
-------------------------------------
function GameState_Intro.update_wave_intermission(self, dt)
	local world = self.m_world
	local map_mgr = world.m_mapManager
    local intermissionTime = getInGameConstant("WAVE_INTERMISSION_TIME")
	local speed = 0

    if (self.m_stateTimer == 0) then
        -- 연출(카메라)
        self:doDirectionForIntermission()

        -- 0. 스킬 및 미사일을 날린다
	    world:removeMissileAndSkill()
        
        -- 변경된 카메라 위치에 맞게 아군 홈 위치 변경 및 이동
        for i, v in ipairs(world:getDragonList()) do
            if (v.m_bDead == false) then
                v:changeStateWithCheckHomePos('idle')
            end
        end
    end

	-- 1. 전환 시간 2/3 지점까지 비교적 완만하게 빨라짐
	if (self.m_stateTimer < intermissionTime * 2 / 3) then
		speed = map_mgr.m_speed - (g_constant:get('INGAME', 'WAVE_INTERMISSION_MAP_SPEED') * dt)
		map_mgr:setSpeed(speed)

	-- 2. 전환 시간 까지 비교적 빠르게 느려짐
	elseif (self.m_stateTimer > intermissionTime * 2 / 3) then
		speed = map_mgr.m_speed + (g_constant:get('INGAME', 'WAVE_INTERMISSION_MAP_SPEED') * 1.9 * dt)
		map_mgr:setSpeed(speed)
	end
	
	-- 3. 전환 시간 이후 속도 고정시키고 전환
	if (self.m_stateTimer >= intermissionTime) then
        map_mgr:setSpeed(-300)

        self:changeState(GAME_STATE_ENEMY_APPEAR)
	end
end


