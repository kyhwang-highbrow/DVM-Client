
MAP_KEY_FUNC = {}

MAP_KEY_FUNC[KEY_R] = 'wave_clear'
MAP_KEY_FUNC[KEY_C] = 'skill_charge'
MAP_KEY_FUNC[KEY_V] = 'mission_success'
MAP_KEY_FUNC[KEY_B] = 'mission_fail'

MAP_KEY_FUNC[KEY_M] = 'init_map'
MAP_KEY_FUNC[KEY_S] = 'visible_ingame_ui'

MAP_KEY_FUNC[KEY_O] = 'force_wait'
MAP_KEY_FUNC[KEY_P] = 'clear_wait'

MAP_KEY_FUNC[KEY_Z] = 'print_dragon_info'
MAP_KEY_FUNC[KEY_X] = 'print_enemy_info'
MAP_KEY_FUNC[KEY_E] = 'print_boss_pattern'
MAP_KEY_FUNC[KEY_W] = 'print_missile_range'

MAP_KEY_FUNC[KEY_K] = 'kill_skill'
MAP_KEY_FUNC[KEY_L] = 'kill_missile'
MAP_KEY_FUNC[KEY_J] = 'kill_dragon'
MAP_KEY_FUNC[KEY_D] = 'kill_boss'

MAP_KEY_FUNC[KEY_Y] = 'se_on_dragon'
MAP_KEY_FUNC[KEY_T] = 'se_on_monster'

MAP_KEY_FUNC[KEY_LEFT_BRACKET] = 'game_speed_down'
MAP_KEY_FUNC[KEY_RIGHT_BRACKET] = 'game_speed_up'
MAP_KEY_FUNC[KEY_F1] = 'set_invincible'
MAP_KEY_FUNC[KEY_F2] = 'set_physbox'

MAP_KEY_FUNC[KEY_A] = 'pause_on_off_auto'

MAP_KEY_FUNC[KEY_1] = 'tamer_active_skill'
MAP_KEY_FUNC[KEY_2] = 'tamer_event_skill'

MAP_KEY_FUNC[KEY_LEFT_ARROW] = 'camera_move_left'
MAP_KEY_FUNC[KEY_RIGHT_ARROW] = 'camera_move_right'
MAP_KEY_FUNC[KEY_UP_ARROW] = 'camera_move_up'
MAP_KEY_FUNC[KEY_DOWN_ARROW] = 'camera_move_down'

-- 테스트
MAP_KEY_FUNC[KEY_5] = 'resurrect_dragon'
MAP_KEY_FUNC[KEY_6] = 'kill_one_dragon'

-------------------------------------
-- function onKeyReleased
-------------------------------------
function GameWorld:onKeyReleased(keyCode, event)
	local key_func_name = MAP_KEY_FUNC[keyCode]
	if (key_func_name) then
		self[key_func_name](self)
	end
end

-------------------------------------
-- function wave_clear
-- @brief 현재 웨이브를 클리어
-------------------------------------
function GameWorld:wave_clear()
    self:killAllEnemy()
    self.m_waveMgr:clearDynamicWave()
end

-------------------------------------
-- function skill_charge
-- @brief 스킬 충전
-------------------------------------
function GameWorld:skill_charge()
    -- 테이머 스킬
    if (self.m_tamer) then
        self.m_tamer:increaseActiveSkillCool(100)
    end
end

-------------------------------------
-- function mission_success
-- @brief 미션 성공
-------------------------------------
function GameWorld:mission_success()
	self.m_gameState:changeState(GAME_STATE_SUCCESS)
end

-------------------------------------
-- function mission_fail
-- @brief 미션 실패
-------------------------------------
function GameWorld:mission_fail()
    self.m_gameState:changeState(GAME_STATE_FAILURE)
end

-------------------------------------
-- function wave_clear
-- @brief 현재 웨이브를 클리어
-------------------------------------
function GameWorld:mission_fail()
    self:killAllEnemy()
    self.m_waveMgr:clearDynamicWave()
end

-------------------------------------
-- function init_map
-- @brief 배경 초기화
-------------------------------------
function GameWorld:init_map()
    self:initBG(self.m_waveMgr)
end

-------------------------------------
-- function force_wait
-- @brief 강제로 wait 상태로 걸어버림
-------------------------------------
function GameWorld:force_wait()
    for i,v in ipairs(self:getEnemyList()) do
        v:setWaitState(true)
    end

    for i,v in ipairs(self:getDragonList()) do
        v:setWaitState(true)
    end
end

-------------------------------------
-- function print_dragon_info
-- @brief 아군 드래곤의 상태, 버프, 디버프 및 패시브 적용 확인
-------------------------------------
function GameWorld:print_dragon_info()
    for _,v in ipairs(self:getDragonList()) do
		v:printAllInfomation()
    end
end

-------------------------------------
-- function print_enemy_info
-- @brief 적군의 상태, 버프, 디버프 및 패시브 적용 확인
-------------------------------------
function GameWorld:print_enemy_info()
    for _, v in ipairs(self:getEnemyList()) do
		v:printAllInfomation()
    end
end

-------------------------------------
-- function visible_ingame_ui
-- @brief 적군의 상태, 버프, 디버프 및 패시브 적용 확인
-------------------------------------
function GameWorld:visible_ingame_ui()
    self.m_inGameUI.root:runAction(cc.ToggleVisibility:create())
end

-------------------------------------
-- function se_on_dragon
-- @brief 아군에게 상태효과 강제 시전
-------------------------------------
function GameWorld:se_on_dragon()
	local dragon_list = self:getDragonList()
    local enemy_list = self:getEnemyList()

    --StatusEffectHelper:doStatusEffect(enemy_list[1], dragon_list, 'stun', 'target', 1, 5, 100, 100)
    StatusEffectHelper:doStatusEffect(enemy_list[1], dragon_list, 'darknix', 'target', 1, 5, 100, 100)
end

-------------------------------------
-- function se_on_monster
-- @brief 적군에게 상태효과 강제 시전
-------------------------------------
function GameWorld:se_on_monster()
    for i,v in ipairs(self:getEnemyList()) do
		if (i < 5) then 
			local test_res = g_constant:get('ART', 'STATUS_EFFECT_RES')
			StatusEffectHelper:invokeStatusEffectForDev(v, test_res)
		end
    end
end

-------------------------------------
-- function kill_skill
-- @brief 스킬 전부 죽이기
-------------------------------------
function GameWorld:kill_skill()
	self:cleanupSkill()
end

-------------------------------------
-- function kill_missile
-- @brief 미사일 전부 죽이기
-------------------------------------
function GameWorld:kill_missile()
	for _, missile in pairs(self.m_lMissileList) do
		missile:changeState('dying')
	end
end

-------------------------------------
-- function kill_dragon
-- @brief 아군 소멸
-------------------------------------
function GameWorld:kill_dragon()
    self:killAllHero()
end

-------------------------------------
-- function kill_boss
-- @brief 보스 소멸
-------------------------------------
function GameWorld:kill_boss()
    for i, v in ipairs(self:getEnemyList()) do
        if not v.m_bDead then
            if v:isBoss() then
                v:setDead()
                v:setEnableBody(false)
                v:changeState('dying')
            end
        end
    end
end

-------------------------------------
-- function pause_on_off_auto
-- @brief 
-------------------------------------
function GameWorld:pause_on_off_auto()
    if (self.m_gameAutoHero:isActive()) then
        self.m_gameAutoHero:onEnd()
    else
        self.m_gameAutoHero:onStart()
    end
end

-------------------------------------
-- function print_boss_pattern
-- @brief 보스 패턴 확인
-------------------------------------
function GameWorld:print_boss_pattern()
    for i, v in ipairs(self:getEnemyList()) do
        if not v.m_bDead then
            if (isInstanceOf(v, MonsterLua_Boss)) then
                v:printCurBossPatternList()
            end
        end
    end
end

-------------------------------------
-- function tamer_active_skill
-- @brief 테이머 스킬 강제 시전 - 액티브
-------------------------------------
function GameWorld:tamer_active_skill()
    if (self.m_tamer) then
        self.m_tamer:changeState('active')
    end
end

-------------------------------------
-- function tamer_event_skill
-- @brief 테이머 스킬 강제 시전 - 액티브
-------------------------------------
function GameWorld:tamer_event_skill()
    if (self.m_tamer) then
		self.m_tamer:changeState('event')
    end
end

-------------------------------------
-- function print_missile_range
-- @brief 미사일 범위 확인
-------------------------------------
function GameWorld:print_missile_range()
	ccdump(self.m_missileRange)
end

-------------------------------------
-- function camera_move_ooo
-- @brief 카메라 이동 상하좌우
-------------------------------------
function GameWorld:camera_move_left()
    local curCameraPosX, curCameraPosY = self.m_gameCamera:getPosition()
        
    self:changeCameraOption({
        pos_x = curCameraPosX - 300,
        pos_y = curCameraPosY
    }, true)
end
function GameWorld:camera_move_right()
    local curCameraPosX, curCameraPosY = self.m_gameCamera:getPosition()
        
    self:changeCameraOption({
        pos_x = curCameraPosX + 300,
        pos_y = curCameraPosY
    }, true)
end
function GameWorld:camera_move_up()
    local curCameraPosX, curCameraPosY = self.m_gameCamera:getPosition()
                
    self:changeCameraOption({
        pos_x = curCameraPosX,
        pos_y = curCameraPosY + 300
    }, true)
        
    self:changeHeroHomePosByCamera()
end
function GameWorld:camera_move_down()
	local curCameraPosX, curCameraPosY = self.m_gameCamera:getPosition()
                
	self:changeCameraOption({
		pos_x = curCameraPosX,
		pos_y = curCameraPosY - 300
	}, true)
        
	self:changeHeroHomePosByCamera()
end

-------------------------------------
-- function game_speed_oo
-- @brief 게임 속도 제어
-------------------------------------
function GameWorld:game_speed_up()
	local scale = self.m_gameTimeScale:getBase() + 0.1
    self.m_gameTimeScale:setBase(scale)
	ccdisplay('게임 속도 ' .. scale)
end
function GameWorld:game_speed_down()
	local scale = self.m_gameTimeScale:getBase() - 0.1
    self.m_gameTimeScale:setBase(scale)
	ccdisplay('게임 속도 ' .. scale)
end

-------------------------------------
-- function set_invincible
-- @brief 피아 모두 무적
-------------------------------------
function GameWorld:set_invincible()
	local b1 = g_constant:get('DEBUG', 'PLAYER_INVINCIBLE')
	g_constant:set(not b1, 'DEBUG', 'PLAYER_INVINCIBLE')
	
	local b2 = g_constant:get('DEBUG', 'ENEMY_INVINCIBLE')
	g_constant:set(not b2, 'DEBUG', 'ENEMY_INVINCIBLE')
	
	if (b1) then 
		ccdisplay('무적 off')
	else
		ccdisplay('무적 on')
	end
end

-------------------------------------
-- function set_physbox
-- @brief 피격박스 on/off
-------------------------------------
function GameWorld:set_physbox()
    local phys_world = self.m_physWorld
    local debug = (not phys_world.m_bDebug)
    phys_world:setDebug(debug)
end

-------------------------------------
-- function resurrect_dragon
-- @brief 아군 부활
-------------------------------------
function GameWorld:resurrect_dragon()
    for _, v in pairs(self.m_mHeroList) do
        if (v.m_bDead) then
            local hp_rate = 0.2
            v:doRevive(hp_rate)

            self:participationHero(v)
        end
    end
end

-------------------------------------
-- function kill_one_dragon
-- @brief 아군 하나 죽이기
-------------------------------------
function GameWorld:kill_one_dragon()
    for i, v in ipairs(self:getDragonList()) do
        if not v.m_bDead then
            v:setDamage(nil, v, v.pos.x, v.pos.y, 999999)
            break
        end
    end
end