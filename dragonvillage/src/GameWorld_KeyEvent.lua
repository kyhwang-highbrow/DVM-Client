
MAP_KEY_FUNC = {}

MAP_KEY_FUNC[KEY_R] = 'wave_clear'
MAP_KEY_FUNC[KEY_C] = 'skill_charge'
MAP_KEY_FUNC[KEY_V] = 'mission_success'
MAP_KEY_FUNC[KEY_B] = 'mission_fail'

MAP_KEY_FUNC[KEY_M] = 'init_map'
MAP_KEY_FUNC[KEY_S] = 'visible_ingame_ui'

MAP_KEY_FUNC[KEY_O] = 'force_wait'
MAP_KEY_FUNC[KEY_I] = 'clear_wait'
MAP_KEY_FUNC[KEY_P] = 'game_pause'

MAP_KEY_FUNC[KEY_Z] = 'print_dragon_info'
MAP_KEY_FUNC[KEY_X] = 'print_enemy_info'
MAP_KEY_FUNC[KEY_E] = 'print_boss_pattern'
MAP_KEY_FUNC[KEY_W] = 'print_missile_range'

MAP_KEY_FUNC[KEY_K] = 'kill_skill'
MAP_KEY_FUNC[KEY_L] = 'kill_missile'
MAP_KEY_FUNC[KEY_J] = 'kill_dragon'
MAP_KEY_FUNC[KEY_D] = 'kill_ally_se'
MAP_KEY_FUNC[KEY_F] = 'kill_enemy_se'
MAP_KEY_FUNC[KEY_Y] = 'se_on_dragon'
MAP_KEY_FUNC[KEY_T] = 'se_on_monster'
MAP_KEY_FUNC[KEY_Q] = 'kill_boss'

MAP_KEY_FUNC[KEY_LEFT_BRACKET] = 'game_speed_down'
MAP_KEY_FUNC[KEY_RIGHT_BRACKET] = 'game_speed_up'

MAP_KEY_FUNC[KEY_F1] = 'set_invincible'
MAP_KEY_FUNC[KEY_F2] = 'set_physbox'
MAP_KEY_FUNC[KEY_F3] = 'add_dmg_yellow_font'

MAP_KEY_FUNC[KEY_A] = 'pause_on_off_auto'

MAP_KEY_FUNC[KEY_1] = 'tamer_active_skill'
MAP_KEY_FUNC[KEY_2] = 'print_tamer_skill'
MAP_KEY_FUNC[KEY_3] = 'print_total_damage_to_hero'
MAP_KEY_FUNC[KEY_4] = 'reload_skill_sound_table'

MAP_KEY_FUNC[KEY_G] = 'do_dragon_passive_1'
MAP_KEY_FUNC[KEY_H] = 'do_dragon_passive_2'
--[[
MAP_KEY_FUNC[KEY_LEFT_ARROW] = 'camera_move_left'
MAP_KEY_FUNC[KEY_RIGHT_ARROW] = 'camera_move_right'
MAP_KEY_FUNC[KEY_UP_ARROW] = 'camera_move_up'
MAP_KEY_FUNC[KEY_DOWN_ARROW] = 'camera_move_down'
]]--

-- 테스트
MAP_KEY_FUNC[KEY_5] = 'pause_dragon_1'
MAP_KEY_FUNC[KEY_6] = 'pause_dragon_2'
MAP_KEY_FUNC[KEY_7] = 'pause_dragon_3'
MAP_KEY_FUNC[KEY_8] = 'pause_dragon_4'
MAP_KEY_FUNC[KEY_9] = 'pause_dragon_5'

-------------------------------------
-- function onKeyReleased
-------------------------------------
function GameWorld:onKeyReleased(keyCode, event)
    
    -- 테스트 모드에서만 동작하도록 설정
    if (not IS_TEST_MODE()) then
        return
    end

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
    self:removeAllEnemy()
    self.m_waveMgr:clearDynamicWave()
end

-------------------------------------
-- function skill_charge
-- @brief 스킬 충전
-------------------------------------
function GameWorld:skill_charge()
    -- 테이머 스킬
    if (self.m_tamer) then
        self.m_tamer:resetActiveSkillCool()
    end

    -- 마나
    if (self.m_heroMana) then
        self.m_heroMana:addMana(10)
    end

    -- 쿨타임
    for i, v in ipairs(self:getDragonList()) do
        v:initActiveSkillCool()
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
-- function clear_wait
-------------------------------------
function GameWorld:clear_wait()
    for i,v in ipairs(self:getEnemyList()) do
        v:setWaitState(false)
    end

    for i,v in ipairs(self:getDragonList()) do
        v:setWaitState(false)
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

    --StatusEffectHelper:doStatusEffect(dragon_list[1], { dragon_list[1] }, 'stun', 'target', 1, 5, 100, 100)
    StatusEffectHelper:doStatusEffect(dragon_list[1], dragon_list, 'immunity_debuff', 'ally_none', 5, 9999, 100, 100)
end

-------------------------------------
-- function se_on_monster
-- @brief 적군에게 상태효과 강제 시전
-------------------------------------
function GameWorld:se_on_monster()
    for i,v in ipairs(self:getEnemyList()) do
        StatusEffectHelper:doStatusEffect(v, { v }, 'silence', 'target', 1, 99999, 100, 100)
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
-- function kill_enemy_se
-- @brief 적군의 모든 상태효과 제거
-------------------------------------
function GameWorld:kill_enemy_se()
    for i, v in ipairs(self:getEnemyList()) do
        for i2, v2 in pairs(v:getStatusEffectList()) do
            v2:changeState('end')
        end
        for i2, v2 in pairs(v:getHiddenStatusEffectList()) do
            v2:changeState('end')
        end
    end
end

-------------------------------------
-- function kill_ally_se
-- @brief 아군의 모든 상태효과 제거
-------------------------------------
function GameWorld:kill_ally_se()
    for i, v in ipairs(self:getDragonList()) do
        for i2, v2 in pairs(v:getStatusEffectList()) do
            v2:changeState('end')
        end
        for i2, v2 in pairs(v:getHiddenStatusEffectList()) do
            v2:changeState('end')
        end
    end
end

-------------------------------------
-- function game_pause
-- @brief pause/resume
-------------------------------------
function GameWorld:game_pause()
    if (g_gameScene.m_bPause) then
        g_gameScene:gameResume()
    else 
        g_gameScene:gamePause()
    end
end


-------------------------------------
-- function kill_dragon
-- @brief 아군 소멸
-------------------------------------
function GameWorld:kill_dragon()
    --self:removeAllHero()
    for i, v in ipairs(self:getDragonList()) do
        if (not v:isDead()) then
            v:doDie()
            break
        end
    end
end

-------------------------------------
-- function kill_boss
-- @brief 보스 소멸
-------------------------------------
function GameWorld:kill_boss()
    for i, v in ipairs(self:getEnemyList()) do
        if (not v:isDead() and v:isBoss()) then
            --v:doDie()
            local damage = v.m_maxHp * 0.2
            v:setDamage(nil, v, v.pos.x, v.pos.y, damage, nil)
        end
    end
end

-------------------------------------
-- function pause_on_off_auto
-- @brief 
-------------------------------------
function GameWorld:pause_on_off_auto()
    if (self.m_heroAuto:isActive()) then
        self.m_heroAuto:onEnd()
    else
        self.m_heroAuto:onStart()
    end
end

-------------------------------------
-- function print_boss_pattern
-- @brief 보스 패턴 확인
-------------------------------------
function GameWorld:print_boss_pattern()
    for i, v in ipairs(self:getEnemyList()) do
        if (not v:isDead()) then
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
-- function print_tamer_skill
-- @brief 테이머 스킬 보기
-------------------------------------
function GameWorld:print_tamer_skill()
    if (self.m_tamer) then
        self.m_tamer:printSkillManager()
    end
end

-------------------------------------
-- function print_total_damage_to_hero
-- @brief 아군이 받은 누적 피해량 표시(표시 후 리셋됨)
-------------------------------------
function GameWorld:print_total_damage_to_hero()
    local total_damage = self.m_logRecorder:getLog('total_damage_to_hero')
    cclog('아군이 받은 누적 피해량 : ' .. total_damage)
    
    self.m_logRecorder.m_totalDamageToHero = 0
    cclog('아군이 받은 누적 피해량 리셋')
end

-------------------------------------
-- function reload_skill_sound_table
-- @brief 스킬 사운드 테이블을 다시 가져옴(파일로부터)
-------------------------------------
function GameWorld:reload_skill_sound_table()
    TABLE:reloadSkillSoundTable()
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
-- function add_dmg_yellow_font
-- @brief
-------------------------------------
function GameWorld:add_dmg_yellow_font()
end

-------------------------------------
-- function resurrect_dragon
-- @brief 아군 부활
-------------------------------------
function GameWorld:resurrect_dragon(hp_rate)
    local died_hero = self.m_leftNonparticipants[1]
    if (not died_hero) then return end

    local hp_rate = hp_rate or 1

    died_hero:doRevive(hp_rate)

    self:addHero(died_hero)
end

-------------------------------------
-- function kill_one_dragon
-- @brief 아군 하나 죽이기
-------------------------------------
function GameWorld:kill_one_dragon(dragon)
    for i, v in ipairs(self:getDragonList()) do
        if (not v:isDead()) then
            v:doDie()
            break
        end
    end
end

-------------------------------------
-- function print_skill_info
-- @brief 아군들의 보유 스킬 정보를 로그로 표시
-------------------------------------
function GameWorld:print_skill_info()
    if (self.m_tamer) then
        self.m_tamer:printSkillInfo()
    end

    for i, hero in ipairs(self:getDragonList()) do
        hero:printSkillInfo()
    end
end

-------------------------------------
-- function camera_info
-------------------------------------
function GameWorld:camera_info()
    self.m_gameCamera:printInfo()
end

-------------------------------------
-- function auto_info
-------------------------------------
function GameWorld:auto_info()
    --self.m_enemyAuto:printInfo()
    self.m_shakeMgr:doShake(500, 500, 1)
end

-------------------------------------
-- function pause_dragon_1
-------------------------------------
function GameWorld:pause_dragon_1()
    local dragon = g_gameScene.m_gameWorld:getDragonList()[1]
    if (dragon.m_bWaitState) then
        dragon:setWaitState(false)
    else
        dragon:setWaitState(true)
    end
end

-------------------------------------
-- function pause_dragon_2
-------------------------------------
function GameWorld:pause_dragon_2()
    local dragon = g_gameScene.m_gameWorld:getDragonList()[2]
    if (dragon.m_bWaitState) then
        dragon:setWaitState(false)
    else
        dragon:setWaitState(true)
    end
end

-------------------------------------
-- function pause_dragon_3
-------------------------------------
function GameWorld:pause_dragon_3()
    local dragon = g_gameScene.m_gameWorld:getDragonList()[3]
    if (dragon.m_bWaitState) then
        dragon:setWaitState(false)
    else
        dragon:setWaitState(true)
    end
end

-------------------------------------
-- function pause_dragon_4
-------------------------------------
function GameWorld:pause_dragon_4()
    local dragon = g_gameScene.m_gameWorld:getDragonList()[4]
    if (dragon.m_bWaitState) then
        dragon:setWaitState(false)
    else
        dragon:setWaitState(true)
    end
end

-------------------------------------
-- function pause_dragon_5
-------------------------------------
function GameWorld:pause_dragon_5()
    local dragon = g_gameScene.m_gameWorld:getDragonList()[5]
    if (dragon.m_bWaitState) then
        dragon:setWaitState(false)
    else
        dragon:setWaitState(true)
    end
end

-------------------------------------
-- function do_dragon_passive_1
-------------------------------------
function GameWorld:do_dragon_passive_1()
    for i, v in ipairs(g_gameScene.m_gameWorld:getDragonList()) do
        if (not v.m_bWaitState) then
            local did = v.m_dragonID
            skill_id = TABLE:get('dragon')[did]['skill_1']
            v:doSkill(skill_id, 0, 0)
        end
    end
end

-------------------------------------
-- function do_dragon_passive_2
-------------------------------------
function GameWorld:do_dragon_passive_2()
    for i, v in ipairs(g_gameScene.m_gameWorld:getDragonList()) do
        if (not v.m_bWaitState) then
            local did = v.m_dragonID
            skill_id = TABLE:get('dragon')[did]['skill_2']
            v:doSkill(skill_id, 0, 0)
        end
    end
end