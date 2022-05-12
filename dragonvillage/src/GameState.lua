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

-- 레이드 웨이브 연출
GAME_STATE_RAID_WAVE = 221

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
        m_bTimeOut = 'boolean',

        m_stateParam = 'boolean',
        m_fightTimer = 'number',
        m_limitTime = 'number',     -- 제한 시간
        m_waveClearTimer = 'number',-- 웨이브 클리어 조건 유지시간(클리어 조건 달성시 일정시간 대기시키기 위함)
        
        m_bAppearHero = 'boolean',
        m_nAppearedEnemys = 'number',

        m_waveEffect = 'Animator',
        m_bossTextVisual = 'Animator',
        m_nextWaveDirectionType = 'string',

		m_bgmBoss = 'string',

        -- 웨이브
        m_waveNoti = 'Animator',
        m_waveNum = 'Animator',
        m_waveMaxNum = 'Animator',

        m_lBossLabel = 'table',
        m_bossNode = '',
        
        -- 광폭화 정보
        m_bEnableEnrage = 'boolean',
        m_tEnrageInfo = 'table',
        m_nAccumEnrage = 'number',  -- 현재까지 누적된 광폭화 카운트
        m_mAccumEnrage = 'table',   -- 현재까지 누적된 광폭화 정보(중간에 난입하는 경우 누적된 광폭화 버프를 적용하기 위함)
        m_enrageDirector = 'GameEnrageDirector',
    })

-------------------------------------
-- function init
-------------------------------------
function GameState:init(world)
    self.m_world = world
    self.m_bPause = false
    self.m_bTimeOut = false
    self.m_state = GAME_STATE_LOADING
    self.m_stateTimer = -1
    self.m_fightTimer = 0
    self.m_limitTime = 0
    self.m_waveClearTimer = 0
    
    self.m_bAppearHero = false
    self.m_nAppearedEnemys = 0

	self.m_bgmBoss = 'bgm_dungeon_boss'

    self.m_bEnableEnrage = false
    self.m_tEnrageInfo = {}
    self.m_nAccumEnrage = 0
    self.m_mAccumEnrage = {}

    self:initUI()
    self:initEnrage()
    self:initState()
end

-------------------------------------
-- function initUI
-------------------------------------
function GameState:initUI()
    -- 보스 등장시 연출
    self.m_waveEffect = MakeAnimator('res/ui/a2d/ingame_text/ingame_text.vrp')
    self.m_waveEffect:changeAni('boss', false)
    self.m_waveEffect:setVisible(false)
    self.m_world.m_inGameUI.root:addChild(self.m_waveEffect.m_node, 109)

    self.m_bossTextVisual = MakeAnimator('res/ui/a2d/ingame_text/ingame_text.vrp')
    self.m_bossTextVisual:changeAni('boss_text', false)
    self.m_bossTextVisual:setVisible(false)
    self.m_world.m_inGameUI.root:addChild(self.m_bossTextVisual.m_node, 110)

    -- 보스 이름
    do
        self.m_lBossLabel = {}

        for i = 1, 5 do
            local rich_label = UIC_RichLabel()
            rich_label.m_defaultColor = cc.c3b(255, 255, 255)
            rich_label:setString('')
            rich_label:setFontSize(40)
            rich_label:setDimension(1000, 800)
            rich_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
            rich_label:enableOutline(cc.c4b(0, 0, 0, 255), 2)

            local socket_node = self.m_bossTextVisual.m_node:getSocketNode('ingame_text_boss_name_' .. i)
            socket_node:addChild(rich_label.m_node)

            doAllChildren(socket_node, function(node) node:setCascadeOpacityEnabled(true) end)

            table.insert(self.m_lBossLabel, rich_label)
        end
    end

    -- 보스 노드
    do
        self.m_bossNode = self.m_waveEffect.m_node:getSocketNode('ingame_text_boss')
    end

    -- 웨이브
    self.m_waveNoti = MakeAnimator('res/ui/a2d/ingame_text/ingame_text.vrp')
    self.m_waveNoti:setVisible(false)
    g_gameScene.m_containerLayer:addChild(self.m_waveNoti.m_node)

    self.m_waveNum = MakeAnimator('res/ui/a2d/ingame_text/ingame_text.vrp')
    self.m_waveNoti.m_node:bindVRP('number', self.m_waveNum.m_node)
                
    self.m_waveMaxNum = MakeAnimator('res/ui/a2d/ingame_text/ingame_text.vrp')
    self.m_waveNoti.m_node:bindVRP('max_number', self.m_waveMaxNum.m_node)

    -- 광폭화 연출
    self.m_enrageDirector = GameEnrageDirector()
end

-------------------------------------
-- function initEnrage
-- @brief 광폭화 관련 초기화값 설정
-------------------------------------
function GameState:initEnrage()
    local t_constant = g_constant:get('INGAME', 'FIGHT_BY_TIME_BUFF')
    local game_mode = self.m_world.m_gameMode
    local str_game_mode = IN_GAME_MODE[game_mode]
    local t_info = t_constant[str_game_mode] or t_constant['DEFAULT']

    if (not t_info) then return end
    if (not t_constant['ENABLE']) then return end

    self.m_bEnableEnrage = true

    for time, l_str_buff in pairs(t_info) do
        local data = {
            time = time,
            buff = {}
        }

        for _, str_buff in ipairs(l_str_buff) do
            local l_str = seperate(str_buff, ';')
            local buff_type = l_str[1]
            local buff_value = l_str[2]

            data['buff'][buff_type] = buff_value
        end

        table.insert(self.m_tEnrageInfo, data)
    end

    -- 시간으로 소팅
    if (#self.m_tEnrageInfo > 1) then
        table.sort(self.m_tEnrageInfo, function(a, b)
            return a['time'] < b['time']
        end)
    end
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
    self:addState(GAME_STATE_RAID_WAVE,              GameState.update_raid_wave)  -- 레이드 웨이브 연출
    self:addState(GAME_STATE_SUCCESS_WAIT,           GameState.update_success_wait)
    self:addState(GAME_STATE_SUCCESS,                GameState.update_success)
    self:addState(GAME_STATE_FAILURE,                GameState.update_failure)
end

-------------------------------------
-- function update
-------------------------------------
function GameState:update(dt)
    if (self.m_bPause) then
        dt = 0
    end

    self:updateFightTimer(dt)

    if (not self.m_bPause) then
        return PARENT.update(self, dt)
    end
end

-------------------------------------
-- function updateFightTimer
-------------------------------------
function GameState:updateFightTimer(dt)
    -- 전투 상태에서만 타임 계산
    if (not isExistValue(self.m_state, GAME_STATE_FIGHT)) then return end

    local has_limit = (self.m_limitTime > 0)
    local time = self.m_fightTimer

    -- 플레이 시간 계산
    self.m_fightTimer = self.m_fightTimer + dt

    if (has_limit) then
        -- 제한 시간이 있을 경우
        if (self.m_fightTimer >= self.m_limitTime) then
            self.m_fightTimer = self.m_limitTime

            -- 제한 시간이 넘었을 경우 처리
            self:processTimeOut()
        end

        -- 남은 제한 시간을 표시
        time = self:getRemainTime()
	else
        -- 제한시간이 없을 경우 플레이 시간 표시
        time = self.m_fightTimer
    end

    self.m_world.m_inGameUI:setTime(time, has_limit)
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
                if (not hero:isDead()) then
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

			-- 테이머가 등장하며 카메라 줌
            if (self.m_world.m_gameMode == GAME_MODE_ANCIENT_RUIN) then
                self.m_world.m_gameCamera:setAction({
                    pos_x = -CRITERIA_RESOLUTION_X/4,
                    pos_y = 0,
                    scale = 0.8,
                    time = 1
                })
            else
			    self.m_world.m_gameCamera:setAction({
                    pos_x = -CRITERIA_RESOLUTION_X/4,
                    pos_y = 0,
                    scale = 1.4,
                    time = 1
                })
            end

            --SoundMgr:playEffect('VOICE', 'vo_tamer_start')
        
	    elseif (self:isPassedStepTime(g_constant:get('INGAME', 'TAMER_APPEAR_TIME'))) then
		    self:nextStep()
        end

    elseif (self:getStep() == 1) then
        if (self:isBeginningStep()) then
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
					-- 등장 완료후 카메라 원복
					self.m_world.m_gameCamera:reset()

					self.m_world.m_tamer:initBarrier()

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
    if (self.m_stateTimer == 0) then
        if (g_gameScene.m_bDevelopStage) then
            for k, v in pairs (self.m_world:getEnemyList()) do
                v:setWaitState(true)
            end
            for k, v in pairs (self.m_world:getDragonList()) do
                v:setWaitState(true)
            end
        end
    end
    local world = self.m_world

    if (world.m_waveMgr) then
        world.m_waveMgr:update(dt)
    end
        
    -- 자동AI 및 마나
    do
        world:updateUnitGroupMgr(dt)
    end

    if (world.m_enemyMovementMgr) then
        world.m_enemyMovementMgr:update(dt)
    end

    do -- 아군 스킬 쿨타임 증가
        for _ ,dragon in pairs(world:getDragonList()) do
            dragon:updateActiveSkillTimer(dt)
        end
    end

    do -- 적군 스킬 쿨타임 증가
        for _, enemy in pairs(self.m_world:getEnemyList()) do
            if (isInstanceOf(enemy, Dragon)) then
                enemy:updateActiveSkillTimer(dt)
            end
        end
    end

    -- 전투 시간에 따른 버프
    if (self:checkEnrage()) then
        self:applyEnrage()
    end
    
    -- 클리어 여부 체크
    self:checkWaveClear(dt)
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
        world:removeHeroDebuffs()
        
        -- 변경된 카메라 위치에 맞게 아군 홈 위치 변경 및 이동
        for i, v in ipairs(world:getDragonList()) do
            if (not v:isDead()) then
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
            if (not dragon:isDead()) then
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
        world:removeAllEnemy()

    end

    -- 드래곤 상태 체크
    local b = true

    for _,dragon in pairs(world:getDragonList()) do
        if (not dragon:isDead() and dragon.m_state ~= 'wait') then
            b = false
        end
    end

    if (world.m_gameDragonSkill:isPlaying()) then
        b = false
    end

    -- 드랍된 아이템이 존재하고 1초가 지나지 않았을 경우 대기
    --if (world.m_dropItemMgr) then
    --    local item_count = world.m_dropItemMgr:getItemCount()
    --    if (0 < item_count) and (self.m_stateTimer <= 1) then
    --        b = false
    --    end
    --end
    -- 대표님 의견으로 무조건 3초 후 웨이브 이동하도록 변경 (sgkim 2017.06.16)
    if (self.m_stateTimer < 2.5) then
        b = false
    end

    if (b or self.m_stateTimer >= 3) then
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

            -- 아군 AI 초기화
            world:prepareAuto()
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

            self:setWave(world.m_waveMgr.m_currWave, world.m_waveMgr.m_maxWave)
            
			-- 웨이브 시작 이벤트 전달
            world:dispatch('wave_start')

			-- 적 패시브 발동
			world:passiveActivate_Right()

			SoundMgr:playEffect('UI', 'ui_wave_start')
        end

        -- 적 이동패턴 정보 초기화
        if (world.m_enemyMovementMgr) then
            world.m_enemyMovementMgr:reset()
        end

        -- 적 AI 초기화
        world:prepareEnemyAuto()
        
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
        if (g_gameScene.m_bDevelopStage) then
            for k, v in pairs (self.m_world:getEnemyList()) do
                v:setWaitState(true)
            end
        end
    end
end

-------------------------------------
-- function update_final_wave
-- @brief 파이널 웨이브 연출
-------------------------------------
function GameState.update_final_wave(self, dt)
    if (self:isBeginningStep(0)) then
        self.m_bossTextVisual:setVisible(true)
        self.m_bossTextVisual:changeAni('leader', false)
        self.m_bossTextVisual:addAniHandler(function()
            self.m_bossTextVisual:setVisible(false)
            self:changeState(GAME_STATE_ENEMY_APPEAR)
        end)

        -- 보스 이름
        local is_incarnation_of_sins = g_eventIncarnationOfSinsData:isPlaying()
        local l_boss_name = self:getBossNameList()
        for i, boss_name in ipairs(l_boss_name) do
            if (self.m_lBossLabel[i]) then
                self.m_lBossLabel[i]:setString(boss_name)

                --죄악의 화신의 경우 보스 이름을 하나만 표기
                if (is_incarnation_of_sins) then
                    break
                end
            end
        end
        	
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
        self.m_waveEffect:setFrame(0)
        self.m_waveEffect:addAniHandler(function()
            self.m_waveEffect:setVisible(false)
        end)

        self.m_bossTextVisual:setVisible(true)
        self.m_bossTextVisual:changeAni('boss_text', false)
        self.m_bossTextVisual:addAniHandler(function()
            self.m_bossTextVisual:setVisible(false)
            self.m_bossNode:removeAllChildren(true)

            self:changeState(GAME_STATE_ENEMY_APPEAR)
        end)

        local duration = self.m_waveEffect:getDuration()
        local getFadeAction = function()
            local fade_in = cc.FadeIn:create(duration / 4)
            local delay = cc.DelayTime:create(duration / 2)
            local fade_out = cc.FadeOut:create(duration / 4)
            return cc.Sequence:create(fade_in, delay, fade_out)
        end

        -- 보스 이미지
        local boss_animator = self:getBossAnimator()
        if (boss_animator) then
            self.m_bossNode:removeAllChildren(true)
            self.m_bossNode:addChild(boss_animator.m_node)

            boss_animator:runAction(getFadeAction())
        end

        -- 보스 이름
        local l_boss_name = self:getBossNameList()
        for i, boss_name in ipairs(l_boss_name) do
            if (self.m_lBossLabel[i]) then
                self.m_lBossLabel[i]:setString(boss_name)
            end
        end

        -- 보스 배경음
        SoundMgr:playBGM(self.m_bgmBoss)

        self.m_world:dispatch('boss_wave')

        -- 웨이브 표시 숨김
        self.m_world.m_inGameUI.vars['waveVisual']:setVisible(false)
    end
end


-------------------------------------
-- function update_boss_wave
-- @brief 보스 웨이브 연출
-------------------------------------
function GameState.update_raid_wave(self, dt)
    if (self:isBeginningStep(0)) then
        self.m_waveEffect:setVisible(true)
        self.m_waveEffect:setFrame(0)
        self.m_waveEffect:addAniHandler(function()
            self.m_waveEffect:setVisible(false)
        end)

        self.m_bossTextVisual:setVisible(true)
        self.m_bossTextVisual:changeAni('boss_text', false)
        self.m_bossTextVisual:addAniHandler(function()
            self.m_bossTextVisual:setVisible(false)
            self.m_bossNode:removeAllChildren(true)

            self:changeState(GAME_STATE_ENEMY_APPEAR)
        end)

        local duration = self.m_waveEffect:getDuration()
        local getFadeAction = function()
            local fade_in = cc.FadeIn:create(duration / 4)
            local delay = cc.DelayTime:create(duration / 2)
            local fade_out = cc.FadeOut:create(duration / 4)
            return cc.Sequence:create(fade_in, delay, fade_out)
        end

        -- 보스 이미지
        local boss_animator = self:getBossAnimator()
        if (boss_animator) then
            self.m_bossNode:removeAllChildren(true)
            self.m_bossNode:addChild(boss_animator.m_node)

            boss_animator:runAction(getFadeAction())
        end

        -- 보스 이름
        local l_boss_name = self:getBossNameList()
        for i, boss_name in ipairs(l_boss_name) do
            if (self.m_lBossLabel[i]) then
                self.m_lBossLabel[i]:setString(boss_name)
            end
        end

        -- 보스 배경음
        SoundMgr:playBGM(self.m_bgmBoss)

        self.m_world:dispatch('boss_wave')

        -- 웨이브 표시 숨김
        self.m_world.m_inGameUI.vars['waveVisual']:setVisible(false)
    end
end


-------------------------------------
-- function update_success_wait
-------------------------------------
function GameState.update_success_wait(self, dt)
    local world = self.m_world

    if (self.m_stateTimer == 0) then
        world:setGameFinish()
        if world.m_skillIndicatorMgr then
            world.m_skillIndicatorMgr:clear(true)
        end

        -- 스킬 다 날려 버리자
		world:removeMissileAndSkill()
        world:removeHeroDebuffs()

        -- 모든 적들을 죽임
        world:removeAllEnemy()
        
		-- @LOG : 스테이지 성공 시 클리어 시간
		self.m_world.m_logRecorder:recordLog('lap_time', self.m_fightTimer)
    end

    -- 드래곤 상태 체크
    local b = true

    for _,dragon in pairs(world:getDragonList()) do
        if (not dragon:isDead() and dragon.m_state ~= 'wait') then
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

        -- 벤치마크 중
        if g_benchmarkMgr and g_benchmarkMgr:isActive() then
            g_benchmarkMgr:finishStage(g_gameScene.m_fpsMeter)
            self:pause() -- update를 멈추기 위해
            return
        end
        self:changeState(GAME_STATE_SUCCESS)
    end    
end

-------------------------------------
-- function update_success
-------------------------------------
function GameState.update_success(self, dt)
    
    if (self.m_stateTimer == 0) then
        local world = self.m_world
        world:setGameFinish()

        -- 모든 적들을 죽임
        world:removeAllEnemy()

        -- 스킬과 미사일도 다 날려 버리자
	    world:removeMissileAndSkill()
        world:removeEnemyDebuffs()
        world:cleanupItem()

        -- 기본 배속으로 변경
        world.m_gameTimeScale:setBase(1)

        world:setWaitAllCharacter(false) -- 포즈 연출을 위해 wait에서 해제

        for i,dragon in ipairs(world:getDragonList()) do
            if (not dragon:isDead()) then
                dragon:killStateDelegate()
                dragon:changeState('success_pose') -- 포즈 후 오른쪽으로 사라짐
            end
        end

        if (world.m_tamer) then
            world.m_tamer:changeState('success_pose')
        end

        -- 모든 아이템 획득
        if world.m_dropItemMgr then
            world.m_dropItemMgr:setImmediatelyObtain()
        end

        for i,enemy in ipairs(world:getEnemyList()) do
            if (not enemy:isDead()) then
                enemy:changeState('idle', true)
            end
        end

        world.m_inGameUI:doActionReverse(function()
            world.m_inGameUI.root:setVisible(false)
        end)

        self.m_stateParam = true

    elseif (self.m_stateTimer >= 3.5) then
        if self.m_stateParam then
            self.m_stateParam = false

            local function cb_func()
                self:makeResultUI(true)
            end
            -- 시나리오 체크 및 시작
            g_gameScene:startIngameScenario('snro_finish', cb_func)        
        end
    end
end

-------------------------------------
-- function update_failure
-------------------------------------
function GameState.update_failure(self, dt)
    local world = self.m_world

    if (self.m_stateTimer == 0) then
        world:setGameFinish()
        if (world.m_tamer) then
            world.m_tamer:changeState('dying')
        end

    elseif (self:isPassedStepTime(1.5)) then
        for i,dragon in ipairs(world:getDragonList()) do
            if (not dragon:isDead()) then
                dragon:changeState('idle')
            end
        end

        for i,enemy in ipairs(world:getEnemyList()) do
            if (not enemy:isDead()) then
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
    -- 이미 Result상태가 되었을 때 상태를 변경할 수 없도록 처리
    if (self.m_state == GAME_STATE_RESULT) then
        return
    end

    -- 이미 Success, Failure상태가 되었을 때 Result상태를 제외하고 상태를 변경할 수 없도록 처리
    if (isExistValue(self.m_state, GAME_STATE_SUCCESS, GAME_STATE_FAILURE) and (state ~= GAME_STATE_RESULT)) then
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
    
	SoundMgr:playEffect('UI', 'ui_summon')

    self.m_bAppearHero = true
end

-------------------------------------
-- function fight
-------------------------------------
function GameState:fight()
    -- 아군과 적군 전투 시작
    local world = self.m_world

    for i,dragon in ipairs(world:getDragonList()) do
        if (not dragon:isDead()) then
            dragon.m_bFirstAttack = true
            dragon:syncAniAndPhys()
            dragon:changeState('attackDelay')
        end
    end

    for i,enemy in pairs(world:getEnemyList()) do
        if (not enemy:isDead()) then
            enemy.m_bFirstAttack = true
            enemy:syncAniAndPhys()
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
-- function isFightWait
-------------------------------------
function GameState:isFightWait()
    return (self.m_state == GAME_STATE_FIGHT_WAIT)
end


-------------------------------------
-- function isEnemyAppear
-------------------------------------
function GameState:isEnemyAppear()
    return (self.m_state == GAME_STATE_ENEMY_APPEAR)
end

-------------------------------------
-- function isWaveInterMission
-------------------------------------
function GameState:isWaveInterMission()
    return (self.m_state == GAME_STATE_WAVE_INTERMISSION)
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState:makeResultUI(is_success)
    self.m_world:setGameFinish()

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
        local world = self.m_world
        if (world.m_bDevelopMode) then
            UINavigator:goTo('lobby')
        else
            g_gameScene:networkGameFinish(t_param, t_result_ref, func_ui_result)
        end
    end

    -- 2. UI 생성
    func_ui_result = function()
        local world = self.m_world
        local stage_id = world.m_stageID
        
		-- GameState는 Adventure모드를 기본으로 한다. 다른 모드는 상속을 받아서 처리한다.
        local ui = UI_GameResult_Adventure(stage_id,
            is_success,
            self.m_fightTimer,
            t_result_ref['default_gold'],
            t_result_ref['user_levelup_data'],
            t_result_ref['dragon_levelu_data_list'],
            t_result_ref['drop_reward_grade'],
            t_result_ref['drop_reward_list'],
            t_result_ref['secret_dungeon'])

        local l_hottime = t_result_ref['hottime']
        ui:setHotTimeInfo(l_hottime)
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
        local clear_wave = is_success and self.m_world.m_waveMgr.m_maxWave or (self.m_world.m_waveMgr.m_currWave - 1) -- @jhakim 190415 서버에서 clear_wave 비례해서 경험치값을 주기때문에 마이너스로 내려가지 않도록 수정 
        t_param['clear_wave'] = math.max(clear_wave, 0)
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
        t_param['bonus_items'] = self.m_world.m_dropItemMgr:makeObtainedDropItemStr()
    end

    -- 클리어 타임
    do
        t_param['clear_time'] = self.m_world.m_logRecorder.m_lapTime
    end

    -- 룬 자동 판매
    do
        local sell_value = 0
        if (g_autoPlaySetting:isRuneAutoSell() == true) then
            sell_value = g_autoPlaySetting:getRuneAutoSellValue()
        end
        t_param['rune_autosell'] = sell_value
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

    -- 미사일 레이어 클리어
    world.m_missileFactory:clearMissileDepthMap()

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

    -- 적 마나 초기화
    world:resetEnemyMana()
    
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
function GameState:checkWaveClear(dt)
    local world = self.m_world
    local hero_count = #world:getDragonList()
    local enemy_count = world:getEnemyCount()

    -- 벤치마크 중 60초를 넘어가면 웨이브 종료
    if (g_benchmarkMgr and g_benchmarkMgr:isActive()) then
        local time = g_benchmarkMgr.m_waveTime

        if (self.m_world.m_waveMgr:isFinalWave()) then
            time = g_benchmarkMgr.m_lastWaveTime
        end
        
        if (self.m_stateTimer >= time) then
            self.m_world:removeAllEnemy()

            if (not self.m_world.m_waveMgr:isFinalWave()) then
		        self:changeState(GAME_STATE_WAVE_INTERMISSION_WAIT)
		    else
                cclog('GAME_STATE_SUCCESS_WAIT')
			    self:changeState(GAME_STATE_SUCCESS_WAIT)
		    end
            return
        end
    end

    -- 패배 여부 체크
    if(hero_count <= 0) then
        self:changeState(GAME_STATE_FAILURE)
        return true

    -- 클리어 여부 체크
    elseif (enemy_count <= 0 or self:checkToDieHighestRariry()) then
        self.m_waveClearTimer = self.m_waveClearTimer + dt

        if (self.m_waveClearTimer > 0.5) then
            self.m_waveClearTimer = 0

            if (world.m_waveMgr:isFinalWave()) then
                self:changeState(GAME_STATE_SUCCESS_WAIT)
            else
		        self:changeState(GAME_STATE_WAVE_INTERMISSION_WAIT)			    
		    end
            return true
        end

    else
        self.m_waveClearTimer = 0
    end

    return false
end

-------------------------------------
-- function checkToDieHighestRariry
-- @brief 가장 높은 등급의 적(보스)가 죽었은지 체크
-------------------------------------
function GameState:checkToDieHighestRariry()
    local world = self.m_world

    if (world.m_bDevelopMode) then return false end
    if (not world.m_waveMgr:isFinalWave()) then return false end
    
    return world.m_waveMgr:checkToDieHighestRariry()
end

-------------------------------------
-- function doDirectionForIntermission
-------------------------------------
function GameState:doDirectionForIntermission()
    local world = self.m_world

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

    -- 카메라 스케일이 0.8이하일 경우 가운데로 고정시킴
    if (t_camera_info['scale'] and t_camera_info['scale'] <= 0.8) then
        t_camera_info['pos_y'] = 0
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
        SoundMgr:playEffect('UI', 'ui_boss_warning')
        self:changeState(GAME_STATE_FINAL_WAVE)

    elseif (self.m_nextWaveDirectionType == 'boss_wave') then
        SoundMgr:playEffect('UI', 'ui_boss_warning')
        self:changeState(GAME_STATE_BOSS_WAVE)

    elseif (self.m_nextWaveDirectionType == 'raid_wave') then
        SoundMgr:playEffect('UI', 'ui_boss_warning')
        self:changeState(GAME_STATE_RAID_WAVE)

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
-- @brief
-- @param wave number 현재 웨이브
-- @param max_wave number 현재 스테이지의 최대 웨이브
-------------------------------------
function GameState:setWave(wave, max_wave)
    local max_wave = (max_wave or 3) -- max_wave가 나중에 추가된 개념이라 오류 방지 차원에서 기본값 설정
    local visual_name = string.format('%02dwave_%02d', max_wave, wave)
    self.m_world.m_inGameUI.vars['waveVisual']:setVisual('group', visual_name)
end

-------------------------------------
-- function processTimeOut
-------------------------------------
function GameState:processTimeOut()
    self.m_bTimeOut = true

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

-------------------------------------
-- function getBossNameList
-------------------------------------
function GameState:getBossNameList()
    local l_ret = {}

    for i, v in ipairs(self.m_world.m_waveMgr:getBossInfoList()) do
        local boss_id = v['cid']
        local name

        if (isMonster(boss_id)) then
            name = TableMonster():getMonsterName(boss_id)
        elseif (isDragon(boss_id)) then
            name = TableDragon():getDragonName(boss_id)
        end

        if (name) then
            table.insert(l_ret, name)
        end
    end

    return l_ret
end

-------------------------------------
-- function getBossAnimator
-------------------------------------
function GameState:getBossAnimator()
    local boss_id, evolution = self.m_world.m_waveMgr:getBossId()
    local animator
    local scale = 1

    if (isMonster(boss_id)) then
        local res_name = TableMonster():getMonsterRes(boss_id)
        local attr = TableMonster():getValue(boss_id, 'attr')
        local type = TableMonster():getValue(boss_id, 'type')
        animator = AnimatorHelper:makeMonsterAnimator(res_name, attr)
        scale = TableMonster():getValue(boss_id, 'scale')

        -- 거대용
        if (type == 'giantdragon') then
            scale = scale * 0.5

        -- 보석 거대용 보스
        elseif (type == 'jeweldragon') then
            animator:setPositionX(-150)
            scale = scale * 0.5

        -- 거목 던전 보스
        elseif (type == 'treant') then
            animator:setPositionX(50)
            scale = scale * 0.7

        -- 악몽 던전 보스
        elseif (string.find(type, 'nightmare_dragon')) then
            animator:setPositionX(50)
            scale = scale * 0.7

        end

    elseif (isDragon(boss_id)) then
        local res_name = TableDragon():getDragonRes(boss_id, evolution)
        local attr = TableDragon():getValue(boss_id, 'attr')
        animator = AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
        scale = TableDragon():getValue(boss_id, 'scale')

    else
        return
    end

    animator:setScale(scale)
    animator:setFlip(true)

    animator.m_node:setCascadeOpacityEnabled(true)

    return animator
end


-------------------------------------
-- function checkEnrage
-- @brief 광폭화 적용 여부 확인
-------------------------------------
function GameState:checkEnrage()
    if (not self.m_bEnableEnrage) then return false end
    if (table.isEmpty(self.m_tEnrageInfo)) then return false end

    -- 적용 시간이 되었는지 체크
    local t_info = self.m_tEnrageInfo[1]
    if (self.m_fightTimer < t_info['time']) then return false end

    return true
end

-------------------------------------
-- function applyEnrage
-- @brief 광폭화 적용
-------------------------------------
function GameState:applyEnrage(t_info)
    local t_info = t_info or table.remove(self.m_tEnrageInfo, 1)
    if (not t_info) then return false end

    local world = self.m_world

    for type, value in pairs(t_info['buff']) do
        local status, action = TableOption():parseOptionKey(type)
        local str_buff_name = TableOption():getValue(type, 't_name')
        
        -- 아군 버프 적용(콜로세움일 경우만)
        --if (world.m_gameMode == GAME_MODE_COLOSSEUM or world.m_gameMode == GAME_MODE_ARENA) then
        if isExistValue(world.m_gameMode, GAME_MODE_ARENA, GAME_MODE_ARENA_NEW, GAME_MODE_COLOSSEUM, GAME_MODE_CHALLENGE_MODE, GAME_MODE_EVENT_ARENA) then
            for i, v in ipairs(world.m_leftParticipants) do
                if (v.m_statusCalc) then
                    v.m_statusCalc:addOption(action, status, value)
                    world:addPassiveStartEffect(v, str_buff_name)
                end
            end
            for i, v in ipairs(world.m_leftNonparticipants) do
                if (v.m_statusCalc) then
                    v.m_statusCalc:addOption(action, status, value)
                end
            end
        end

        -- 적군 버프 적용
        do
            for i, v in ipairs(world.m_rightParticipants) do
                if (v.m_statusCalc) then
                    v.m_statusCalc:addOption(action, status, value)
                    world:addPassiveStartEffect(v, str_buff_name)
                end
            end
            for i, v in ipairs(world.m_rightNonparticipants) do
                if (v.m_statusCalc) then
                    v.m_statusCalc:addOption(action, status, value)
                end
            end
        end

        -- 광폭화 버프 누적 정보에 추가
        do
            if (not self.m_mAccumEnrage[type]) then
                self.m_mAccumEnrage[type] = 0
            end

            self.m_mAccumEnrage[type] = self.m_mAccumEnrage[type] + value
        end
    end

    -- 광폭화 버프 누적 카운트 갱신
    self.m_nAccumEnrage = self.m_nAccumEnrage + 1

    -- 연출
    if (self.m_enrageDirector) then
        self.m_enrageDirector:doWork()
    end

    return true
end

-------------------------------------
-- function applyAccumEnrage
-- @brief 현재까지 누적된 광폭화 버프를 적용
-------------------------------------
function GameState:applyAccumEnrage(unit)
    local accum_buff = self.m_mAccumEnrage
    if (not accum_buff) then return end

    for type, value in pairs(accum_buff) do
        local status, action = TableOption:parseOptionKey(type)
        unit.m_statusCalc:addOption(action, status, value)
    end
end

-------------------------------------
-- function isTimeOut
-------------------------------------
function GameState:isTimeOut()
    return self.m_bTimeOut
end

-------------------------------------
-- function getRemainTime
-------------------------------------
function GameState:getRemainTime()
    return (self.m_limitTime - self.m_fightTimer)
end