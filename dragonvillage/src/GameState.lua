local PARENT = class(IEventListener:getCloneClass(), IStateHelper:getCloneTable())

GAME_STATE_NONE = 0

GAME_STATE_LOADING = 1  -- Scene전환 후 첫 상태
GAME_STATE_START = 2  -- 테이머 등장 및 아군 소환

GAME_STATE_WAVE_INTERMISSION = 90 -- wave 인터미션
GAME_STATE_WAVE_INTERMISSION_WAIT = 91

GAME_STATE_ENEMY_APPEAR = 99  -- 적 등장

GAME_STATE_FIGHT = 100
GAME_STATE_FIGHT_WAIT = 101

-- 파이널 웨이브 연출
GAME_STATE_FINAL_WAVE = 201

-- 보스 웨이브 연출
GAME_STATE_BOSS_WAVE = 211

GAME_STATE_SUCCESS_WAIT = 300
GAME_STATE_SUCCESS = 301
GAME_STATE_FAILURE = 302

GAME_STATE_RESULT = 400

-------------------------------------
-- class GameState
-------------------------------------
GameState = class(PARENT, {
        m_world = '',
        m_bPause = 'boolean',

        m_stateParam = 'boolean',
        m_fightTimer = '',
        m_limitTime = 'number',     -- 제한 시간
        
        m_bAppearHero = 'boolean',
        m_nAppearedEnemys = 'number',

        m_waveEffect = 'Animator',
        m_nextWaveDirectionType = 'string',

		m_bgmBoss = 'string',

        -- 웨이브
        m_waveNoti = 'Animator',
        m_waveNum = 'Animator',
        m_waveMaxNum = 'Animator',
    })

-------------------------------------
-- function init
-------------------------------------
function GameState:init(world)
    self.m_world = world
    self.m_bPause = false
    self.m_state = GAME_STATE_LOADING
    self.m_stateTimer = -1
    self.m_fightTimer = 0
    self.m_limitTime = 0
    
    self.m_bAppearHero = false

	self.m_bgmBoss = 'bgm_dungeon_boss'

    self:initUI()
    self:initState()
end

-------------------------------------
-- function initUI
-------------------------------------
function GameState:initUI()
    self.m_waveEffect = MakeAnimator('res/ui/a2d/ui_boss_warning/ui_boss_warning.vrp')
    self.m_waveEffect:setVisible(false)
    --g_gameScene.m_containerLayer:addChild(self.m_waveEffect.m_node)
    self.m_world.m_inGameUI.root:addChild(self.m_waveEffect.m_node, 9)

    -- 웨이브
    self.m_waveNoti = MakeAnimator('res/ui/a2d/ingame_text/ingame_text.vrp')
    self.m_waveNoti:setVisible(false)
    g_gameScene.m_containerLayer:addChild(self.m_waveNoti.m_node)

    self.m_waveNum = MakeAnimator('res/ui/a2d/ingame_text/ingame_text.vrp')
    self.m_waveNoti.m_node:bindVRP('number', self.m_waveNum.m_node)
                
    self.m_waveMaxNum = MakeAnimator('res/ui/a2d/ingame_text/ingame_text.vrp')
    self.m_waveNoti.m_node:bindVRP('max_number', self.m_waveMaxNum.m_node)
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState:initState()
    self:addState(GAME_STATE_NONE,                   function(self, dt) end)
    self:addState(GAME_STATE_START,                  GameState.update_start)
    self:addState(GAME_STATE_WAVE_INTERMISSION,      GameState.update_wave_intermission)
    self:addState(GAME_STATE_WAVE_INTERMISSION_WAIT, GameState.update_wave_intermission_wait)
    self:addState(GAME_STATE_ENEMY_APPEAR,           GameState.update_enemy_appear)
    self:addState(GAME_STATE_FIGHT,                  GameState.update_fight)
    self:addState(GAME_STATE_FIGHT_WAIT,             GameState.update_fight_wait)
    self:addState(GAME_STATE_FINAL_WAVE,             GameState.update_final_wave) -- 마지막 웨이브 연출
    self:addState(GAME_STATE_BOSS_WAVE,              GameState.update_boss_wave)  -- 보스 웨이브 연출
    self:addState(GAME_STATE_SUCCESS_WAIT,           GameState.update_success_wait)
    self:addState(GAME_STATE_SUCCESS,                GameState.update_success)
    self:addState(GAME_STATE_FAILURE,                GameState.update_failure)
end

-------------------------------------
-- function update
-------------------------------------
function GameState:update(dt)
    if (self.m_bPause) then return end

    -- 특정 상태에서만 타임 계산
    if (isExistValue(self.m_state, GAME_STATE_FIGHT)) then
        -- 플레이 시간 계산
        self.m_fightTimer = self.m_fightTimer + dt
        
        -- 제한 시간이 있을 경우 체크
        if (self.m_limitTime > 0) then
            if (self.m_fightTimer >= self.m_limitTime) then
                self.m_fightTimer = self.m_limitTime

                self:processTimeOut()
            end

			local is_limit = true
            self.m_world.m_inGameUI:setTime(self.m_limitTime - self.m_fightTimer, is_limit)
		
		-- 제한시간이 없을 경우 플레이 시간 표시
		else
			local is_limit = false
			self.m_world.m_inGameUI:setTime(self.m_fightTimer, is_limit)
        end
    end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function update_start
-------------------------------------
function GameState.update_start(self, dt)
    local world = self.m_world
    local map_mgr = world.m_mapManager

    if (self:getStep() == 0) then
        if (self:isBeginningStep()) then
            -- 드래곤들을 숨김
            for i, hero in ipairs(world:getDragonList()) do
                if (hero.m_bDead == false) then
                    hero.m_rootNode:setVisible(false)
                    hero.m_hpNode:setVisible(false)
                    hero:changeState('idle')
                end
            end

            -- 테이머 등장
            if (world.m_tamer) then
                world.m_tamer:changeState('appear')
            end

            -- 화면을 빠르게 스크롤
            if map_mgr then
                map_mgr:setSpeed(-1000)  
            end

            --SoundMgr:playEffect('VOICE', 'vo_tamer_start')
        
	    elseif (self:isPassedStepTime(g_constant:get('INGAME', 'TAMER_APPEAR_TIME'))) then
		    self:nextStep()
        end

    elseif (self:getStep() == 1) then
        if (self:isBeginningStep()) then
            SoundMgr:playEffect('UI', 'ui_summon')
        
            world:dispatch('dragon_summon')

        elseif (self:getStepTimer() >= 0.5) then
            self:appearHero()

            -- 테이머 이동
            if (world.m_tamer) then
                world.m_tamer:runAction_MoveZ(1)
            end

            local speed_down_factor = g_constant:get('INGAME', 'MAP_SCROLL_SPEED_DOWN_ACCEL')
            local speed = map_mgr.m_speed + (speed_down_factor * dt)
            if (speed >= -300) then
                speed = -300

                -- 등장 완료일 경우
                if self.m_bAppearHero then
                    self:changeState(GAME_STATE_ENEMY_APPEAR)
                end
            end
            map_mgr:setSpeed(speed)
        end
    end
end

-------------------------------------
-- function update_fight
-------------------------------------
function GameState.update_fight(self, dt)
    local world = self.m_world

    -- 클리어 여부 체크
    if (not self:checkWaveClear()) then
        world.m_waveMgr:update(dt)
    end
    
    if (world.m_skillIndicatorMgr) then
        world.m_skillIndicatorMgr:update(dt)
    end

    if (world.m_gameAutoHero) then
        world.m_gameAutoHero:update(dt)
    end

    if (world.m_gameAutoEnemy) then
        world.m_gameAutoEnemy:update(dt)
    end

    if (world.m_enemyMovementMgr) then
        world.m_enemyMovementMgr:update(dt)
    end

    -- 아군 마나
    if (world.m_heroMana) then
        world.m_heroMana:update(dt)
    end

    do -- 아군 스킬 쿨타임 증가
        for _,dragon in pairs(world:getDragonList()) do
            dragon:updateActiveSkillCool(dt)
        end
    end

    do -- 적군 스킬 쿨타임 증가
        for _, enemy in pairs(self.m_world:getEnemyList()) do
            if (isInstanceOf(enemy, Dragon)) then
                enemy:updateActiveSkillCool(dt)
            end
        end
    end
end

-------------------------------------
-- function update_wave_intermission
-------------------------------------
function GameState.update_wave_intermission(self, dt)
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
                
                -- 잔상 연출 활성화
                v:setMovingAfterImage(true)
            end
        end

        if (world.m_tamer) then
            world.m_tamer:setMovingAfterImage(true)
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

        for _,dragon in pairs(world:getDragonList()) do
            if (not dragon.m_bDead) then
                dragon:setMovingAfterImage(false)
            end
        end

        if (world.m_tamer) then
            world.m_tamer:setMovingAfterImage(false)
        end

		self:changeState(GAME_STATE_ENEMY_APPEAR)
	end
end

-------------------------------------
-- function update_wave_intermission_wait
-------------------------------------
function GameState.update_wave_intermission_wait(self, dt)
    local world = self.m_world

    if (self.m_stateTimer == 0) then
        if (world.m_skillIndicatorMgr) then
            world.m_skillIndicatorMgr:clear(true)
        end

        -- 스킬 다 날려 버리자
        world:removeMissileAndSkill()
        world:removeHeroDebuffs()

        -- 모든 적들을 죽임
        world:killAllEnemy()

    end

    -- 드래곤 상태 체크
    local b = true

    for _,dragon in pairs(world:getDragonList()) do
        if (not dragon.m_bDead and dragon.m_state ~= 'wait') then
            b = false
        end
    end

    if (world.m_gameDragonSkill:isPlaying()) then
        b = false
    end

    -- 드랍된 아이템이 존재하고 1초가 지나지 않았을 경우 대기
    if (world.m_dropItemMgr) then
        local item_count = world.m_dropItemMgr:getItemCount()
        if (0 < item_count) and (self.m_stateTimer <= 1) then
            b = false
        end
    end

    if (b or self.m_stateTimer >= 4) then
        self:changeState(GAME_STATE_WAVE_INTERMISSION)
    end
end

-------------------------------------
-- function update_enemy_appear
-------------------------------------
function GameState.update_enemy_appear(self, dt)
    local world = self.m_world
    local enemy_count = #world:getEnemyList()
	
    if (self.m_stateTimer == 0) then
        local dynamic_wave = #world.m_waveMgr.m_lDynamicWave

        if (enemy_count <= 0) and (dynamic_wave <= 0) then
            self:waveChange()
        end
    
    -- 모든 적들이 등장이 끝났는지 확인
    elseif world.m_waveMgr:isEmptyDynamicWaveList() and self.m_nAppearedEnemys >= enemy_count then
        
        -- 전투 최초 시작시
        if world.m_waveMgr:isFirstWave() then
            world:dispatch('game_start')
            world.m_inGameUI:doAction()
			-- 아군 패시브 효과 적용
			world:passiveActivate_Left()
        end
        
        -- 웨이브 알림
        do
            self.m_waveNoti:setVisible(true)
            self.m_waveNoti:changeAni('wave', false)
            self.m_waveNum:setVisual('tag', tostring(world.m_waveMgr.m_currWave))
            self.m_waveMaxNum:setVisual('tag', tostring(world.m_waveMgr.m_maxWave))

            local duration = self.m_waveNoti:getDuration()
            self.m_waveNoti:runAction(cc.Sequence:create(
                cc.DelayTime:create(duration),
                cc.CallFunc:create(function(node)
                    node:setVisible(false)
                    self:fight()
                    self:changeState(GAME_STATE_FIGHT)
                end)
            ))

            self:setWave(world.m_waveMgr.m_currWave)
            
			-- 웨이브 시작 이벤트 전달
            world:dispatch('wave_start')

			-- 적 패시브 발동
			world:passiveActivate_Right()
        end

        -- 적 이동패턴 정보 초기화
        if (world.m_enemyMovementMgr) then
            world.m_enemyMovementMgr:reset()
        end
                
        self:changeState(GAME_STATE_FIGHT_WAIT)
    end
    
    -- 웨이브 매니져 업데이트
    world.m_waveMgr:update(dt, true)
end

-------------------------------------
-- function update_fight_wait
-------------------------------------
function GameState.update_fight_wait(self, dt)
    if (self.m_stateTimer == 0) then
    end
end

-------------------------------------
-- function update_final_wave
-- @brief 파이널 웨이브 연출
-------------------------------------
function GameState.update_final_wave(self, dt)
    if (self:isBeginningStep(0)) then
        self.m_waveEffect:setVisible(true)
        self.m_waveEffect:changeAni('final_appear', false)
        self.m_waveEffect:addAniHandler(function()
            self:nextStep()
        end)
		
		SoundMgr:stopBGM()

    elseif (self:isBeginningStep(1)) then
        self.m_waveEffect:setVisible(true)
        self.m_waveEffect:changeAni('final_disappear', false)
        self.m_waveEffect:addAniHandler(function()
            self.m_waveEffect:setVisible(false)
            self:changeState(GAME_STATE_ENEMY_APPEAR)
        end)

		-- 엘리트 배경음
        SoundMgr:playBGM('bgm_dungeon_midboss')
    end
end

-------------------------------------
-- function update_boss_wave
-- @brief 보스 웨이브 연출
-------------------------------------
function GameState.update_boss_wave(self, dt)
    if (self:isBeginningStep(0)) then
        self.m_waveEffect:setVisible(true)
        self.m_waveEffect:changeAni('boss_warning_width_720', false)
        self.m_waveEffect:addAniHandler(function()
            self:nextStep()
        end)

        SoundMgr:stopBGM()

        -- 웨이브 표시 숨김
        self.m_world.m_inGameUI.vars['waveVisual']:setVisible(false)

    elseif (self:isBeginningStep(1)) then
        self.m_waveEffect:setVisible(true)
        self.m_waveEffect:changeAni('boss_appear', false)
        self.m_waveEffect:addAniHandler(function()
            self:nextStep()
        end)

        self.m_world:dispatch('boss_wave')

    elseif (self:isBeginningStep(2)) then
        self.m_waveEffect:setVisible(true)
        self.m_waveEffect:changeAni('boss_disappear', false)
        self.m_waveEffect:addAniHandler(function()
            self.m_waveEffect:setVisible(false)
            self:changeState(GAME_STATE_ENEMY_APPEAR)
        end)

        -- 보스 배경음
        SoundMgr:playBGM(self.m_bgmBoss)

    end
end

-------------------------------------
-- function update_success_wait
-------------------------------------
function GameState.update_success_wait(self, dt)
    local world = self.m_world

    if (self.m_stateTimer == 0) then
        if world.m_skillIndicatorMgr then
            world.m_skillIndicatorMgr:clear(true)
        end

        -- 스킬 다 날려 버리자
		world:removeMissileAndSkill()
        world:removeHeroDebuffs()

        -- 모든 적들을 죽임
        world:killAllEnemy()
        
		-- @LOG : 스테이지 성공 시 클리어 시간
		self.m_world.m_logRecorder:recordLog('lap_time', self.m_fightTimer)
    end

    -- 드래곤 상태 체크
    local b = true

    for _,dragon in pairs(world:getDragonList()) do
        if (not dragon.m_bDead and dragon.m_state ~= 'wait') then
            b = false
        end
    end

    if (world.m_gameDragonSkill:isPlaying()) then
        b = false
    end

    local enemy_count = #world:getEnemyList()
    if (enemy_count > 0) then
        b = false
    end

    if (b or self.m_stateTimer >= 8) then
        self:changeState(GAME_STATE_SUCCESS)
    end    
end

-------------------------------------
-- function update_success
-------------------------------------
function GameState.update_success(self, dt)
    
    if (self.m_stateTimer == 0) then
        local world = self.m_world

        -- 모든 적들을 죽임
        world:killAllEnemy()

        -- 기본 배속으로 변경
        world.m_gameTimeScale:setBase(1)

        world:setWaitAllCharacter(false) -- 포즈 연출을 위해 wait에서 해제

        for i,dragon in ipairs(world:getDragonList()) do
            if (dragon.m_bDead == false) then
                dragon:killStateDelegate()
                dragon:changeState('success_pose') -- 포즈 후 오른쪽으로 사라짐
            end
        end

        world.m_tamer:changeState('success_pose')

        -- 모든 아이템 획득
        if world.m_dropItemMgr then
            world.m_dropItemMgr:setImmediatelyObtain()
        end

        for i,enemy in ipairs(world:getEnemyList()) do
            if (enemy.m_bDead == false) then
                enemy:changeState('idle', true)
            end
        end

        world.m_inGameUI:doActionReverse(function()
            world.m_inGameUI.root:setVisible(false)
        end)

        self.m_stateParam = true

        self.m_world:dispatch('stage_clear')

    elseif (self.m_stateTimer >= 3.5) then
        if self.m_stateParam then
            self.m_stateParam = false

            local function start()
                --world.m_containerLayer:setVisible(true)
                self:makeResultUI(true)
            end
    
            -- 임시 시나리오
            local world = self.m_world
            local stage_id = world.m_stageID
            local scenario_name = TableStageDesc:getScenarioName(stage_id, 'snro_finish')
            if scenario_name then
                local ui = g_scenarioViewingHistory:playScenario(scenario_name)
                if ui then
                    --world.m_containerLayer:setVisible(false)
                    ui:setCloseCB(start)
                    return 
                end
            end

            start()            
        end
    end
end

-------------------------------------
-- function update_failure
-------------------------------------
function GameState.update_failure(self, dt)
    local world = self.m_world

    if (self.m_stateTimer == 0) then
        world.m_tamer:changeState('dying')

    elseif (self:isPassedStepTime(1.5)) then
        for i,dragon in ipairs(world:getDragonList()) do
            if (dragon.m_bDead == false) then
                dragon:changeState('idle')
            end
        end

        for i,enemy in ipairs(world:getEnemyList()) do
            if (enemy.m_bDead == false) then
                enemy:changeState('idle', true)
            end
        end

        -- 스킬과 미사일도 다 날려 버리자
	    world:removeMissileAndSkill()
        world:removeEnemyDebuffs()
        world:cleanupItem()
        
        -- 기본 배속으로 변경
        world.m_gameTimeScale:setBase(1)

        world.m_inGameUI:doActionReverse(function()
            world.m_inGameUI.root:setVisible(false)
        end)
        self:makeResultUI(false)
    end
end

-------------------------------------
-- function changeState
-------------------------------------
function GameState:changeState(state)
    -- 이미 Success, Failure상태가 되었을 때 상태를 변경할 수 없도록 처리
    if isExistValue(self.m_state, GAME_STATE_SUCCESS, GAME_STATE_FAILURE) and (state ~= GAME_STATE_RESULT) then
        return
    end
    
    local prev_state = self.m_state
    PARENT.changeState(self, state)

    if (prev_state == GAME_STATE_FIGHT) then
         self.m_world:setWaitAllCharacter(true)
    end

    if (self.m_state == GAME_STATE_FIGHT) then
        self.m_world:setWaitAllCharacter(false)
    end
end

-------------------------------------
-- function appearHero
-------------------------------------
function GameState:appearHero()
    if self.m_bAppearHero then return end

    -- 드래곤들을 등장
    local world = self.m_world
    for i,dragon in ipairs(world:getDragonList()) do
        dragon:doAppear()
    end
    
    self.m_bAppearHero = true
end

-------------------------------------
-- function fight
-------------------------------------
function GameState:fight()
    -- 아군과 적군 전투 시작
    local world = self.m_world

    for i,dragon in ipairs(world:getDragonList()) do
        if (dragon.m_bDead == false) then
            dragon.m_bFirstAttack = true
            dragon:changeState('attackDelay')
        end
    end

    for i,enemy in pairs(world:getEnemyList()) do
        if (enemy.m_bDead == false) then
            enemy.m_bFirstAttack = true
            enemy:changeState('attackDelay')

            if enemy.m_hpNode then
                enemy.m_hpNode:setVisible(true)
            end
        end
    end

    if (world.m_tamer) then
        world.m_tamer:changeState('roam')
    end
end

-------------------------------------
-- function isFight
-------------------------------------
function GameState:isFight()
    return (self.m_state == GAME_STATE_FIGHT)
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState:makeResultUI(is_success)
    -- 작업 함수들
    local func_network_game_finish
    local func_ui_result

    -- UI연출에 필요한 테이블들
    local t_result_ref = {}
    t_result_ref['user_levelup_data'] = {}
    t_result_ref['dragon_levelu_data_list'] = {}
    t_result_ref['drop_reward_list'] = {}
    t_result_ref['secret_dungeon'] = nil

    -- 1. 네트워크 통신
    func_network_game_finish = function()
        local t_param = self:makeGameFinishParam(is_success)
        g_gameScene:networkGameFinish(t_param, t_result_ref, func_ui_result)
    end

    -- 2. UI 생성
    func_ui_result = function()
        local world = self.m_world
        local stage_id = world.m_stageID
        
		-- GameState는 Adventure모드를 기본으로 한다. 다른 모드는 상속을 받아서 처리한다.
        UI_GameResult_Adventure(stage_id,
            is_success,
            self.m_fightTimer,
            t_result_ref['default_gold'],
            t_result_ref['user_levelup_data'],
            t_result_ref['dragon_levelu_data_list'],
            t_result_ref['drop_reward_grade'],
            t_result_ref['drop_reward_list'],
            t_result_ref['secret_dungeon'])
    end

    -- 최초 실행
    func_network_game_finish()
end

-------------------------------------
-- function makeGameFinishParam
-------------------------------------
function GameState:makeGameFinishParam(is_success)
    local t_param = {}

    do-- 클리어 했는지 여부 ( 0 이면 실패, 1이면 성공)
        t_param['clear_type'] = is_success and (1 or 0)
    end

    do-- 클리어한 웨이브 수
        t_param['clear_wave'] = is_success and self.m_world.m_waveMgr.m_maxWave or (self.m_world.m_waveMgr.m_currWave - 1)
    end

    -- 경험치 보정치 ( 실패했을 경우 사용 ) ex : 66% 인경우 66
    if is_success then
        t_param['exp_rate'] = 100
    else
        local wave_rate = ((self.m_world.m_waveMgr.m_currWave - 1) / self.m_world.m_waveMgr.m_maxWave)
        wave_rate = math_floor(wave_rate * 100)
        t_param['exp_rate'] = math_clamp(wave_rate, 0, 100)
    end

    do-- 미션 성공 여부 (성공시 1, 실패시 0)
		if (self.m_world.m_missionMgr) then
			local t_mission = self.m_world.m_missionMgr:getCompleteClearMission()
			for i = 1, 3 do
				t_param['clear_mission_' .. i] = (is_success and t_mission['mission_' .. i])
			end
		end
    end

    do-- 획득 골드
        t_param['gold'] = self.m_world:getGold()
        t_param['gold_rate'] = 100
    end

    do-- 사용한 덱 이름
        t_param['deck_name'] = g_deckData:getSelectedDeckName()
    end

    -- 드랍 아이템
    if self.m_world.m_dropItemMgr then
        t_param['bonus_items'] = self.m_world.m_dropItemMgr:makeOptainedDropItemStr()
    end

    -- 클리어 타임
    do
        t_param['clear_time'] = self.m_world.m_logRecorder.m_lapTime
    end

    return t_param
end

-------------------------------------
-- function waveChange
-------------------------------------
function GameState:waveChange()

    local world = self.m_world
    local map_manager = world.m_mapManager
    local t_wave_data, is_final_wave = world.m_waveMgr:getNextWaveScriptData()

    -- 다음 웨이브가 없을 경우 클리어
    if (not t_wave_data) then
        self:changeState(GAME_STATE_SUCCESS)
        return true
    end
    
    local t_bg_data = t_wave_data['bg']
    self.m_nextWaveDirectionType = t_wave_data['direction']
    if (not self.m_nextWaveDirectionType) and is_final_wave then
        self.m_nextWaveDirectionType = 'final_wave'
    end

    -- 다음 웨이브 생성
    world.m_waveMgr:newScenario()

    self.m_nAppearedEnemys = 0

    -- 아무런 연출이 없을 경우 GAME_STATE_FIGHT 상태를 유지
    if (self.m_nextWaveDirectionType == nil) and (t_bg_data == nil) then
        return false

    -- 웨이브 연출만 있을 경우
    elseif (self.m_nextWaveDirectionType) and (not t_bg_data) then
        return self:applyWaveDirection()

    -- 배경 전환이 있을 경우 (GAME_STATE_FIGHT_WAIT상태에서 웨이브 연출을 확인함)
    elseif (t_bg_data) then
        local changeNextState = function()
            if (not self:applyWaveDirection()) then
                self:changeState(GAME_STATE_ENEMY_APPEAR)
            end
        end

        if map_manager:applyWaveScript(t_bg_data) then
            map_manager.m_finishCB = function()
                if (not self:applyWaveDirection()) then
                    changeNextState()
                end
            end
            self:changeState(GAME_STATE_FIGHT_WAIT)
            return true
        else
            map_manager.m_finishCB = nil
            changeNextState()
        end

    else
        error()

    end
end

-------------------------------------
-- function checkWaveClear
-------------------------------------
function GameState:checkWaveClear()
    local world = self.m_world
    local enemy_count = #world:getEnemyList()

    -- 클리어 여부 체크
    if (enemy_count <= 0) then
        if world.m_waveMgr:isFinalWave() == false then
		    self:changeState(GAME_STATE_WAVE_INTERMISSION_WAIT)
		else
			self:changeState(GAME_STATE_SUCCESS_WAIT)
		end
        return true

    -- 마지막 웨이브라면 해당 웨이브의 최고 등급 적이 존재하지 않을 경우 클리어 처리
    elseif ( not world.m_bDevelopMode and world.m_waveMgr:isFinalWave() ) then
        local highestRariry = world.m_waveMgr:getHighestRariry()
        local bExistBoss = false
            
        for _, enemy in ipairs(world:getEnemyList()) do
            if (enemy.m_charTable['rarity'] == highestRariry) then
                if (not enemy.m_bDead) then
                    bExistBoss = true
                end
                break
            end
        end

        if (not bExistBoss) then
            self:changeState(GAME_STATE_SUCCESS_WAIT)
            return true
        end
    end

    return false
end

-------------------------------------
-- function doDirectionForIntermission
-------------------------------------
function GameState:doDirectionForIntermission()
    local world = self.m_world
    local map_mgr = world.m_mapManager

    local t_wave_data, is_final_wave = world.m_waveMgr:getNextWaveScriptData()
    local t_camera_info = t_wave_data['camera'] or {}
    local curCameraPosX, curCameraPosY = world.m_gameCamera:getHomePos()
    local scr_size = cc.Director:getInstance():getWinSize()
    local scr_ratio = math_max(scr_size['width'], scr_size['height']) / math_min(scr_size['width'], scr_size['height'])
    local moveY = 300

    if (scr_ratio < (16 / 9)) then
        moveY = 180
    end
		
	if (world.m_bDevelopMode == false) then
        local tRandomY = {}
        for _, v in pairs({-moveY, 0, moveY}) do
            if v ~= curCameraPosY then
                table.insert(tRandomY, v)
            end
        end

        t_camera_info['pos_x'] = curCameraPosX
		t_camera_info['pos_y'] = tRandomY[math_random(1, #tRandomY)]
		t_camera_info['time'] = getInGameConstant("WAVE_INTERMISSION_TIME")
        
    end
        
    -- 카메라 액션 설정
    world:changeCameraOption(t_camera_info)
    world:changeHeroHomePosByCamera()

    -- 인터미션 시작 시 획득하지 않은 아이템 삭제
    world:cleanupItem()
end

-------------------------------------
-- function applyWaveDirection
-- @brief
-- @return true를 리턴하면 내부에서 State를 변경했다는 뜻
-------------------------------------
function GameState:applyWaveDirection()
    if (not self.m_nextWaveDirectionType) then
        return false
    end

    if (self.m_nextWaveDirectionType == 'final_wave') then
        SoundMgr:playEffect('EFFECT', 'boss_warning')
        self:changeState(GAME_STATE_FINAL_WAVE)

    elseif (self.m_nextWaveDirectionType == 'boss_wave') then
        SoundMgr:playEffect('EFFECT', 'boss_warning')
        self:changeState(GAME_STATE_BOSS_WAVE)

    end

    self.m_nextWaveDirectionType = nil
    return true
end

-------------------------------------
-- function onEvent
-- @brief
-------------------------------------
function GameState:onEvent(event_name, t_event, ...)
    
    -- 적군이 전투 위치로 도착
    if (event_name == 'enemy_appear_done') then
        if (self.m_state == GAME_STATE_FIGHT) then
            -- 잔투중 소환된 경우
            local arg = {...}
            local enemy = arg[1]
            enemy:changeState('attackDelay')
        else
            self.m_nAppearedEnemys = self.m_nAppearedEnemys + 1
        end
    end
end

-------------------------------------
-- function setWave
-------------------------------------
function GameState:setWave(wave)
    self.m_world.m_inGameUI.vars['waveVisual']:setVisual('wave', string.format('%02d', wave))
end

-------------------------------------
-- function processTimeOut
-------------------------------------
function GameState:processTimeOut()
    -- 게임 실패 처리
    self:changeState(GAME_STATE_FAILURE)
end

-------------------------------------
-- function pause
-------------------------------------
function GameState:pause()
    self.m_bPause = true
end

-------------------------------------
-- function resume
-------------------------------------
function GameState:resume()
    self.m_bPause = false
end