GAME_STATE_NONE = 0

GAME_STATE_LOADING = 1  -- Scene전환 후 첫 상태
GAME_STATE_START_1 = 2  -- 테이머 등장
GAME_STATE_START_2 = 3  -- 테이머 등장

GAME_STATE_WAVE_INTERMISSION = 90 -- wave 인터미션
GAME_STATE_WAVE_INTERMISSION_WAIT = 91

GAME_STATE_ENEMY_APPEAR = 99  -- 적 등장

GAME_STATE_FIGHT = 100
GAME_STATE_FIGHT_WAIT = 101
GAME_STATE_FIGHT_DRAGON_SKILL = 102 -- 드래곤 스킬
GAME_STATE_FIGHT_TAMER_SKILL = 103  -- 테이머 스킬
GAME_STATE_FIGHT_FEVER = 104        -- 피버모드

-- 파이널 웨이브 연출
GAME_STATE_FINAL_WAVE = 201
GAME_STATE_FINAL_WAVE2 = 202

-- 보스 웨이브 연출
GAME_STATE_BOSS_WAVE = 211
GAME_STATE_BOSS_WAVE2 = 212
GAME_STATE_BOSS_WAVE3 = 213

GAME_STATE_SUCCESS_WAIT = 300
GAME_STATE_SUCCESS = 301
GAME_STATE_FAILURE = 302

-------------------------------------
-- class GameState
-------------------------------------
GameState = class(IEventListener:getCloneClass(), {
        m_world = '',

        m_state = '',

        m_stateParam = 'boolean',
        m_stateTimer = '',
        m_fightTimer = '',

        m_bAppearDragon = 'boolean',
        m_nAppearedEnemys = 'number',

        m_waveEffect = 'Animator',
        m_nextWaveDirectionType = 'string',

        m_skillDescEffect = 'Animator',
        m_skillNameLabel = 'cc.Label',
        m_skillDescLabel = 'cc.Label',
    })

-------------------------------------
-- function init
-------------------------------------
function GameState:init(world)
    self.m_world = world
    self.m_state = GAME_STATE_LOADING
    self.m_stateTimer = -1
    self.m_fightTimer = 0
    self.m_bAppearDragon = false

    self.m_waveEffect = MakeAnimator('res/ui/a2d/ui_boss_warning/ui_boss_warning.vrp')
    self.m_waveEffect:setVisible(false)
    g_gameScene.m_containerLayer:addChild(self.m_waveEffect.m_node)

    -- 스킬 설명
    self.m_skillDescEffect = MakeAnimator('res/ui/a2d/ingame_dragon_skill/ingame_dragon_skill.vrp')
    self.m_skillDescEffect:setPosition(0, -200)
    self.m_skillDescEffect:changeAni('skill', false)
    self.m_skillDescEffect:setVisible(false)
    g_gameScene.m_containerLayer:addChild(self.m_skillDescEffect.m_node)

    local titleNode = self.m_skillDescEffect.m_node:getSocketNode('skill_title')
    local descNode = self.m_skillDescEffect.m_node:getSocketNode('skill_dsc')
    
    self.m_skillNameLabel = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 60, 3, cc.size(800, 200), 1, 1)
    self.m_skillNameLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_skillNameLabel:setDockPoint(cc.p(0, 0))
	self.m_skillNameLabel:setColor(cc.c3b(84,244,87))
    self.m_skillNameLabel:enableShadow(cc.c4b(0,0,0,255), cc.size(-3, 3), 0)
    titleNode:addChild(self.m_skillNameLabel)

    self.m_skillDescLabel = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 30, 3, cc.size(800, 200), 1, 1)
    self.m_skillDescLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_skillDescLabel:setDockPoint(cc.p(0, 0))
	self.m_skillDescLabel:setColor(cc.c3b(220,220,220))
    self.m_skillDescLabel:enableShadow(cc.c4b(0,0,0,255), cc.size(-3, 3), 0)
    descNode:addChild(self.m_skillDescLabel)
end

-------------------------------------
-- function update
-------------------------------------
function GameState:update(dt)
    if (self.m_stateTimer == -1) then
        self.m_stateTimer = 0
    else
        self.m_stateTimer = self.m_stateTimer + dt
    end
    
    if (self.m_state == GAME_STATE_NONE) then
    elseif (self.m_state == GAME_STATE_START_1) then    self:update_start1(dt)
    elseif (self.m_state == GAME_STATE_START_2) then    self:update_start2(dt)
    elseif (self.m_state == GAME_STATE_WAVE_INTERMISSION) then self:update_wave_intermission(dt)
    elseif (self.m_state == GAME_STATE_WAVE_INTERMISSION_WAIT) then self:update_wave_intermission_wait(dt)
    elseif (self.m_state == GAME_STATE_ENEMY_APPEAR) then self:update_enemy_appear(dt)
    elseif (self.m_state == GAME_STATE_FIGHT) then      self:update_fight(dt)
    elseif (self.m_state == GAME_STATE_FIGHT_DRAGON_SKILL) then self:update_fight_dragon_skill(dt)
    elseif (self.m_state == GAME_STATE_FIGHT_TAMER_SKILL) then self:update_fight_tamer_skill(dt)
    elseif (self.m_state == GAME_STATE_FIGHT_WAIT) then self:update_fight_wait(dt)

    elseif (self.m_state == GAME_STATE_FIGHT_FEVER) then      self:update_fight_fever(dt)

    -- 마지막 웨이브 연출
    elseif (self.m_state == GAME_STATE_FINAL_WAVE) then self:update_final_wave(dt)
    elseif (self.m_state == GAME_STATE_FINAL_WAVE2) then self:update_final_wave2(dt)

    -- 보스 웨이브 연출
    elseif (self.m_state == GAME_STATE_BOSS_WAVE) then self:update_boss_wave(dt)
    elseif (self.m_state == GAME_STATE_BOSS_WAVE2) then self:update_boss_wave2(dt)
    elseif (self.m_state == GAME_STATE_BOSS_WAVE3) then self:update_boss_wave3(dt)

    elseif (self.m_state == GAME_STATE_SUCCESS_WAIT) then    self:update_success_wait(dt)
    elseif (self.m_state == GAME_STATE_SUCCESS) then    self:update_success(dt)
    elseif (self.m_state == GAME_STATE_FAILURE) then    self:update_failure(dt)
    end
end

-------------------------------------
-- function update_start1
-------------------------------------
function GameState:update_start1(dt)
    if (self.m_stateTimer == 0) then
        -- 드래곤들을 숨김
        local world = self.m_world
        for i,dragon in ipairs(world.m_participants) do
            if (dragon.m_bDead == false) and (dragon.m_charType == 'dragon') then
                dragon.m_rootNode:setVisible(false)
                dragon.m_hpNode:setVisible(false)
                dragon:changeState('idle')
            end
        end

        -- 화면을 빠르게 스크롤
        world.m_mapManager:setSpeed(-1000)  

        SoundMgr:playEffect('VOICE', 'vo_tamer_start')
        
	elseif (self.m_stateTimer >= DRAGON_APPEAR_TIME) then
		self:changeState(GAME_STATE_START_2)
    end

end

-------------------------------------
-- function update_start2
-------------------------------------
function GameState:update_start2(dt)
    local world = self.m_world
    local map_mgr = world.m_mapManager
    
	if (self.m_stateTimer == 0) then
        SoundMgr:playEffect('EFFECT', 'summon')
        
        world:dispatch('dragon_summon')

    elseif (self.m_stateTimer >= 0.5) then
        if not self.m_bAppearDragon then
            self:appearDragon()
        end

        local speed = map_mgr.m_speed + (MAP_SCROLL_SPEED_DOWN_ACCEL * dt)
        if speed >= -300 then
            speed = -300

            -- 등장 완료일 경우
            if self.m_bAppearDragon then
                self:changeState(GAME_STATE_ENEMY_APPEAR)
            end
        end
        map_mgr:setSpeed(speed)
    end
end

-------------------------------------
-- function appearDragon
-------------------------------------
function GameState:appearDragon()
    -- 드래곤들을 등장
    local world = self.m_world
    for i,dragon in ipairs(world.m_participants) do
        if (dragon.m_bDead == false) then
            dragon.m_rootNode:setVisible(true)
            dragon.m_hpNode:setVisible(true)

            local effect = MakeAnimator('res/effect/tamer_magic_1/tamer_magic_1.vrp')
            effect:setPosition(dragon.pos.x, dragon.pos.y)
            effect:changeAni('bomb', false)
            effect:setScale(0.8)
            local duration = effect:getDuration()
            effect:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(function() effect:release() end)))
            world.m_missiledNode:addChild(effect.m_node)
        end
    end
    
    self.m_bAppearDragon = true
end

-------------------------------------
-- function fight
-------------------------------------
function GameState:fight()
    -- 아군과 적군 전투 시작
    local world = self.m_world

    for i,dragon in ipairs(world.m_participants) do
        if (dragon.m_bDead == false) then
            dragon.m_bFirstAttack = true
            dragon:changeState('attackDelay')
        end
    end

    for i,enemy in pairs(world.m_tEnemyList) do
        if (enemy.m_bDead == false) then
            enemy.m_bFirstAttack = true
            enemy:changeState('attackDelay')
        end
    end
end

-------------------------------------
-- function update_enemy_appear
-------------------------------------
function GameState:update_enemy_appear(dt)
    local world = self.m_world
	
    if (self.m_stateTimer == 0) then
        for i,dragon in ipairs(world.m_participants) do
            if (dragon.m_bDead == false) then
                dragon:changeStateWithCheckHomePos('idle')
            end
        end

        local enemy_count = #world.m_tEnemyList
        local dynamic_wave = #world.m_waveMgr.m_lDynamicWave

        if (enemy_count <= 0) and (dynamic_wave <= 0) then
            self:waveChange()
        end
    
    -- 모든 적들이 등장이 끝났는지 확인
    elseif world.m_waveMgr:isEmptyDynamicWaveList() and self.m_nAppearedEnemys >= #world.m_tEnemyList then

        -- 전투 최초 시작시
        if world.m_waveMgr:isFirstWave() then
            world:dispatch('game_start')
            world:buffActivateAtStartup()
            world.m_inGameUI:doAction()
        end

        -- 웨이브 알림
        do
            local waveNoti = MakeAnimator('res/ui/a2d/ingame_text/ingame_text.vrp')
            waveNoti:changeAni('wave', false)
            g_gameScene.m_containerLayer:addChild(waveNoti.m_node)

            local waveNum = MakeAnimator('res/ui/a2d/ingame_text/ingame_text.vrp')
            waveNum:setVisual('tag', tostring(world.m_waveMgr.m_currWave))
            waveNoti.m_node:bindVRP('number', waveNum.m_node)
                
            local maxWaveNum = MakeAnimator('res/ui/a2d/ingame_text/ingame_text.vrp')
            maxWaveNum:setVisual('tag', tostring(world.m_waveMgr.m_maxWave))
            waveNoti.m_node:bindVRP('max_number', maxWaveNum.m_node)

            local duration = waveNoti:getDuration()
            waveNoti:runAction(cc.Sequence:create(
                cc.DelayTime:create(duration),
                cc.CallFunc:create(function()
                    self:fight()
                    self:changeState(GAME_STATE_FIGHT)
                end),
                cc.RemoveSelf:create()
            ))

            g_gameScene.m_inGameUI.vars['waveVisual']:setVisual('wave', string.format('%02d', world.m_waveMgr.m_currWave))

			-- 웨이브 시작 이벤트 전달
            world:dispatch('wave_start')
			for _, dragon in pairs(world.m_lDragonList) do
				dragon:dispatch('wave_start')
			end
        end

        self:changeState(GAME_STATE_FIGHT_WAIT)
    end
    
    -- 웨이브 매니져 업데이트
    if (not world.m_bDoingTamerSkill) then
        world.m_waveMgr:update(dt)
    end
end

-------------------------------------
-- function update_fight
-------------------------------------
function GameState:update_fight(dt)
    self.m_fightTimer = self.m_fightTimer + dt
    local world = self.m_world

    local enemy_count = #world.m_tEnemyList
    local dynamic_wave = #world.m_waveMgr.m_lDynamicWave

    if (not world.m_bDoingTamerSkill) and (enemy_count <= 0) and (dynamic_wave <= 0) then
        
        -- 스킬 다 날려 버리자
		for _, skill in pairs(world.m_lSkillList) do
			skill:changeState('dying')
		end

		if world.m_waveMgr:getNextWaveScriptData() then 
		    self:changeState(GAME_STATE_WAVE_INTERMISSION_WAIT)
		else
			self:changeState(GAME_STATE_SUCCESS_WAIT)
		end
        return
    end
    
    if world.m_skillIndicatorMgr then
        world.m_skillIndicatorMgr:update(dt)
    end

    if world.m_tamerSkillSystem then
        world.m_tamerSkillSystem:update(dt)
    end

    if world.m_gameFever then
        world.m_gameFever:update(dt)
    end

    do -- 드래곤 액티브 스킬 쿨타임 증가
        for _,dragon in pairs(world.m_lDragonList) do
            dragon:updateActiveSkillCoolTime(dt)
        end
    end
end

-------------------------------------
-- function update_wave_intermission
-------------------------------------
function GameState:update_wave_intermission(dt)
	local world = self.m_world
	local map_mgr = world.m_mapManager
	local speed = 0

    if (self.m_stateTimer == 0) then
        for _,dragon in pairs(world.m_lDragonList) do
            if (not dragon.m_bDead) then
                dragon:setAfrerImage(true)
            end
        end
    end

	-- 1. 전환 시간 2/3 지점까지 비교적 완만하게 빨라짐
	if (self.m_stateTimer < WAVE_INTERMISSION_TIME * 2 / 3) then
		speed = map_mgr.m_speed - (WAVE_INTERMISSION_MAP_SPEED * dt)
		map_mgr:setSpeed(speed)

	-- 2. 전환 시간 까지 비교적 빠르게 느려짐
	elseif (self.m_stateTimer > WAVE_INTERMISSION_TIME * 2 / 3) then
		speed = map_mgr.m_speed + (WAVE_INTERMISSION_MAP_SPEED * 1.9 * dt)
		map_mgr:setSpeed(speed)
	end
	
	-- 3. 전환 시간 이후 속도 고정시키고 전환
	if (self.m_stateTimer >= WAVE_INTERMISSION_TIME) then
        map_mgr:setSpeed(-300)

        for _,dragon in pairs(world.m_lDragonList) do
            if (not dragon.m_bDead) then
                dragon:setAfrerImage(false)
            end
        end

		self:changeState(GAME_STATE_ENEMY_APPEAR)
	end
end

-------------------------------------
-- function update_wave_intermission_wait
-------------------------------------
function GameState:update_wave_intermission_wait(dt)
    local world = self.m_world

    if (self.m_stateTimer == 0) then
        if world.m_skillIndicatorMgr then
            world.m_skillIndicatorMgr:clear()
        end
    end

    -- 드래곤 상태 체크
    local b = true

    for _,dragon in pairs(world.m_lDragonList) do
        if (not dragon.m_bDead and dragon.m_state ~= 'wait') then
            b = false
        end
    end

    if (b or self.m_stateTimer >= 4) then
        self:changeState(GAME_STATE_WAVE_INTERMISSION)
    end
end

-------------------------------------
-- function update_fight_dragon_skill
-------------------------------------
function GameState:update_fight_dragon_skill(dt)
    local dragon = self.m_world.m_currFocusingDragon
    local timeScale = 0.1
    local delayTime = 1
    
    if (self.m_stateTimer == 0) then
        -- 게임 조작 막음
        self.m_world.m_bPreventControl = true

        -- 슬로우
        g_gameScene:setTimeScaleAction(timeScale, delayTime)

        -- 드래곤 승리 애니메이션
        dragon.m_animator:changeAni('pose_1', false)

        local duration = dragon:getAniDuration()
        dragon.m_animator:setTimeScale(duration / (timeScale * delayTime))
        
        -- 카메라 줌인
        self.m_world.m_gameCamera:setTarget(dragon, {time = timeScale / 8})

        -- 스킬 이름 및 설명 문구를 표시
        do
            local active_skill_id = dragon:getSkillID('active')
            local t_skill = TABLE:get('dragon_skill')[active_skill_id]

            self.m_skillDescEffect.m_node:setFrame(0)
            self.m_skillDescEffect:setVisible(true)
            self.m_skillDescEffect:setTimeScale(duration / (timeScale * delayTime))

            self.m_skillNameLabel:setString(Str(t_skill['t_name']))
            self.m_skillDescLabel:setString(IDragonSkillManager:getSkillDescPure(t_skill))
        end

        -- 스킬 사용 직전 이펙트
        do
            local attr = dragon.m_charTable['attr']
            local animator = MakeAnimator('res/effect/effect_skillcasting_dragon/effect_skillcasting_dragon.vrp')
            animator:changeAni('idle_' .. attr, false)
            animator:setPosition(0, 80)
            g_gameScene.m_containerLayer:addChild(animator.m_node)

            local duration = animator:getDuration() * delayTime
            animator:setTimeScale(duration / (timeScale * delayTime))
            animator:addAniHandler(function() animator:runAction(cc.RemoveSelf:create()) end)
        end

        -- 효과음
        SoundMgr:playEffect('EFFECT', 'skill_ready')
    end

    if (self.m_stateTimer >= timeScale * delayTime) then
        -- 게임 조작 막음 해제
        self.m_world.m_bPreventControl = false

        -- 드래곤 스킬 애니메이션
        dragon:changeState('skillAttack2')
        dragon.m_animator:setTimeScale(1)

        -- 카메라 줌아웃
        self.m_world.m_gameCamera:reset()
        
        self:changeState(GAME_STATE_FIGHT)
    end
end

-------------------------------------
-- function update_fight_tamer_skill
-------------------------------------
function GameState:update_fight_tamer_skill(dt)
    local world = self.m_world

    if (self.m_stateTimer == 0) then
        for i,v in ipairs(world.m_participants) do
            v:setWaitState(false)
            v:changeState('idle')
        end
    end
end

-------------------------------------
-- function update_fight_fever
-------------------------------------
function GameState:update_fight_fever(dt)
    local world = self.m_world
        
    if (self.m_stateTimer == 0) then
        -- 인디케이터 삭제
        if world.m_skillIndicatorMgr then
            world.m_skillIndicatorMgr:clear()
        end

        -- 아군 드래곤 모든 행동 정지 및 자기 위치로 이동
        for _, skill in pairs(world.m_lSkillList) do
            if isInstanceOf(skill, Skill) and skill.m_owner and skill.m_owner.m_bLeftFormation then
                skill:changeState('dying')
            end
		end

        -- 적군은 계속 공격하도록 함
        for i, enemy in ipairs(world.m_tEnemyList) do
            enemy:setWaitState(false)
        end
                        
        -- 피버 모드 시작
        world.m_gameFever:onStart()
    end

    if world.m_gameFever then
        world.m_gameFever:update(dt)
    end
end

-------------------------------------
-- function update_fight_wait
-------------------------------------
function GameState:update_fight_wait(dt)
    if (self.m_stateTimer == 0) then
    end
end

-------------------------------------
-- function update_final_wave
-- @brief 파이널 웨이브 연출
-------------------------------------
function GameState:update_final_wave(dt)
    if (self.m_stateTimer == 0) then
        self.m_waveEffect:setVisible(true)
        self.m_waveEffect:changeAni('final_appear', false)
        self.m_waveEffect:addAniHandler(function()
            self:changeState(GAME_STATE_FINAL_WAVE2)
        end)
    end
end

-------------------------------------
-- function update_final_wave2
-- @brief 파이널 웨이브 연출 2
-------------------------------------
function GameState:update_final_wave2(dt)
    if (self.m_stateTimer == 0) then
        self.m_waveEffect:setVisible(true)
        self.m_waveEffect:changeAni('final_disappear', false)
        self.m_waveEffect:addAniHandler(function()
            self.m_waveEffect:setVisible(false)
            self:changeState(GAME_STATE_ENEMY_APPEAR)
        end)
    end
end

-------------------------------------
-- function update_boss_wave
-- @brief 보스 웨이브 연출
-------------------------------------
function GameState:update_boss_wave(dt)
    if (self.m_stateTimer == 0) then
        self.m_waveEffect:setVisible(true)
        self.m_waveEffect:changeAni('boss_warning_width_720', false)
        self.m_waveEffect:addAniHandler(function()
            self:changeState(GAME_STATE_BOSS_WAVE2)
        end)

        SoundMgr:stopBGM()
    end
end

-------------------------------------
-- function update_boss_wave2
-- @brief 보스 웨이브 연출 2
-------------------------------------
function GameState:update_boss_wave2(dt)
    if (self.m_stateTimer == 0) then
        self.m_waveEffect:setVisible(true)
        self.m_waveEffect:changeAni('boss_appear', false)
        self.m_waveEffect:addAniHandler(function()
            self:changeState(GAME_STATE_BOSS_WAVE3)
        end)

        self.m_world:dispatch('boss_wave')
    end
end

-------------------------------------
-- function update_boss_wave3
-- @brief 보스 웨이브 연출 3
-------------------------------------
function GameState:update_boss_wave3(dt)
    if (self.m_stateTimer == 0) then
        self.m_waveEffect:setVisible(true)
        self.m_waveEffect:changeAni('boss_disappear', false)
        self.m_waveEffect:addAniHandler(function()
            self.m_waveEffect:setVisible(false)
            self:changeState(GAME_STATE_ENEMY_APPEAR)
        end)

        -- 보스 배경음
        SoundMgr:playBGM('bgm_boss')
    end
end

-------------------------------------
-- function update_success_wait
-------------------------------------
function GameState:update_success_wait(dt)
    local world = self.m_world

    if (self.m_stateTimer == 0) then
        if world.m_skillIndicatorMgr then
            world.m_skillIndicatorMgr:clear()
        end
    end

    -- 드래곤 상태 체크
    local b = true

    for _,dragon in pairs(world.m_participants) do
        if (not dragon.m_bDead and dragon.m_state ~= 'wait') then
            b = false
        end
    end

    if (b or self.m_stateTimer >= 4) then
        self:changeState(GAME_STATE_SUCCESS)
    end    
end

-------------------------------------
-- function update_success
-------------------------------------
function GameState:update_success(dt)
    
    if (self.m_stateTimer == 0) then
        local world = self.m_world

        -- 모든 적들을 죽임
        world:killAllEnemy()

        world:setWaitAllCharacter(false) -- 포즈 연출을 위해 wait에서 해제

        for i,dragon in ipairs(world.m_participants) do
            if (dragon.m_bDead == false) then
                dragon:killStateDelegate()
                dragon:changeState('success_pose') -- 포즈 후 오른쪽으로 사라짐
            end
        end

        for i,enemy in ipairs(world.m_tEnemyList) do
            if (enemy.m_bDead == false) then
                enemy:changeState('idle', true)
            end
        end

        -- 한번에 골드 획득
        world:clearGold()

        g_adventureData:clearStage(g_gameScene.m_stageID, 1)
        g_gameScene.m_inGameUI:doActionReverse(function()
            g_gameScene.m_inGameUI.root:setVisible(false)
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
-- function update_failure
-------------------------------------
function GameState:update_failure(dt)
    if (self.m_stateTimer == 0) then

        local world = self.m_world
        for i,dragon in ipairs(world.m_participants) do
            if (dragon.m_bDead == false) then
                dragon:changeState('idle')
            end
        end

        for i,enemy in ipairs(world.m_tEnemyList) do
            if (enemy.m_bDead == false) then
                enemy:changeState('idle', true)
            end
        end

        g_gameScene.m_inGameUI:doActionReverse(function()
            g_gameScene.m_inGameUI.root:setVisible(false)
        end)
        self:makeResultUI(false)
    end
end

-------------------------------------
-- function changeState
-------------------------------------
function GameState:changeState(state)
    -- 이미 Success, Failure상태가 되었을 때 상태를 변경할 수 없도록 처리
    if isExistValue(self.m_state, GAME_STATE_SUCCESS, GAME_STATE_FAILURE) then
        return
    end

    local prev_state = self.m_state
    self.m_state = state
    self.m_stateTimer = -1

    if (prev_state == GAME_STATE_FIGHT) then
         self.m_world:setWaitAllCharacter(true)
    end

    if (self.m_state == GAME_STATE_FIGHT or self.m_state == GAME_STATE_FIGHT_DRAGON_SKILL) then
        self.m_world:setWaitAllCharacter(false)
    end
end

-------------------------------------
-- function isFight
-------------------------------------
function GameState:isFight()
    return (self.m_state == GAME_STATE_FIGHT)
end


-------------------------------------
-- function dropItem
-------------------------------------
function GameState:dropItem(finish_cb)
    local stage_id = self.m_world.m_stageID
    local drop_helper = DropHelper(stage_id)
    local box_grade, l_drop_item = drop_helper:dropItem()

    --cclog(luadump(l_drop_item))

    for i,v in ipairs(l_drop_item) do
        local item_id = v[1]
        local count = v[2]
        --g_userDataOld:optainItem(item_id, count)
    end

    -- 네트워크 통신
    self:dropItem_network(l_drop_item, finish_cb)

    return box_grade, l_drop_item
end

-------------------------------------
-- function dropItem_network
-------------------------------------
function GameState:dropItem_network(l_drop_item, finish_cb)
    local uid = g_userData:get('uid')
    local l_drop_item = clone(l_drop_item)

    local do_work

    local ui_network = UI_Network()
    ui_network:setReuse(true)

    do_work = function(ret)
        self:dropItem_networkResponse(ret)

        ui_network:softReset()

        local t_drop_data = l_drop_item[1]
        if t_drop_data then
            table.remove(l_drop_item, 1)

            local item_id = t_drop_data[1]
            local count = t_drop_data[2]

            self:dropItem_networkSetRequest(ui_network, item_id, count)
            ui_network:request()
        else
            ui_network:close()
            finish_cb()
        end
    end

    ui_network:setSuccessCB(do_work)
    do_work()
end

-------------------------------------
-- function dropItem_networkSetRequest
-------------------------------------
function GameState:dropItem_networkSetRequest(ui_network, item_id, count)
    local table_item = TABLE:get('item')
    local t_item = table_item[item_id]

    local type = t_item['type']
    local val_1 = t_item['val_1']
    local uid = g_userData:get('uid')

    if (type == 'gold') then
        ui_network:setUrl('/users/update')
        ui_network:setParam('uid', uid)
        ui_network:setParam('act', 'increase')
        ui_network:setParam('gold', (count * val_1))

    elseif (type == 'cash') then
        ui_network:setUrl('/users/update')
        ui_network:setParam('uid', uid)
        ui_network:setParam('act', 'increase')
        ui_network:setParam('cash', (count * val_1))

    elseif (type == 'dragon') then
        local did = t_item['val_1']
        local evolution = t_item['rarity']
        ui_network:setUrl('/dragons/add')
        ui_network:setParam('uid', uid)
        ui_network:setParam('did', did)
        ui_network:setParam('evolution', evolution or 1)

    elseif (type == 'fruit') then
        local fruit_id = t_item['item']
        ui_network:setUrl('/users/manage')
        ui_network:setParam('uid', uid)
        ui_network:setParam('act', 'increase')
        ui_network:setParam('key', 'fruits')
        ui_network:setParam('value', tostring(fruit_id) .. ',' .. (count * val_1))

    elseif (type == 'evolution_stone') then
        local evolution_stone_id = t_item['item']
        ui_network:setUrl('/users/manage')
        ui_network:setParam('uid', uid)
        ui_network:setParam('act', 'increase')
        ui_network:setParam('key', 'evolution_stones')
        ui_network:setParam('value', tostring(evolution_stone_id) .. ',' .. (count * val_1))
    end
end

-------------------------------------
-- function dropItem_networkResponse
-------------------------------------
function GameState:dropItem_networkResponse(ret)
    if (not ret) then
        return
    end

    -- 획득한 재화 추가 (골드, 캐시, 열매, 진화석)
    if ret['user'] then
        g_serverData:applyServerData(ret['user'], 'user')
    end

    -- 획득한 드래곤 추가
    if (ret['dragons']) then
        for _,t_dragon in pairs(ret['dragons']) do
            g_dragonsData:applyDragonData(t_dragon)
        end
    end
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState:makeResultUI(is_success)
    -- 웨이브 진행 정도(클리어 시 100%)
    local wave_rate = ((self.m_world.m_waveMgr.m_currWave - 1) / self.m_world.m_waveMgr.m_maxWave)
    if is_success then
        wave_rate = 1
    end

    local l_dragon_list = {}
    local stage_id = self.m_world.m_stageID

    -- 테이머 경험치 상승
    local t_tamer_levelup_data = g_userDataOld:addTamerExpAtStage(stage_id, wave_rate)

    local table_drop = TABLE:get('drop')
    local t_drop = table_drop[stage_id]
    local add_exp = t_drop and t_drop['dragon_exp'] or 0
    add_exp = math_floor(add_exp * wave_rate)

    -- 경험치 상승
    local l_deck = g_deckData:getDeck('1')
    local table_dragon = TABLE:get('dragon')
    for i,v in pairs(l_deck) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(v)
        local t_dragon = table_dragon[t_dragon_data['did']]
        local t_levelup_data = CalcDragonExp(t_dragon_data, add_exp)
        table.insert(l_dragon_list, {user_data=t_dragon_data, table_data=t_dragon, levelup_data=t_levelup_data})
    end

    local world = self.m_world


    local func_drop
    local func_exp
    local func_ui_result

    local box_grade = 'c'
    local l_drop_item_list = {}

    -- 1. 아이템 드랍
    func_drop = function()
        if is_success then
            box_grade, l_drop_item_list = self:dropItem(func_exp)
        else
            func_exp()
        end
    end

    -- 2. 경험치 상승
    func_exp = function()
        self:tempNetwork(l_dragon_list, func_ui_result)
    end

    -- 3. UI 생성
    func_ui_result = function()
        local stage_id = self.m_world.m_stageID
        UI_GameResultNew(stage_id, is_success, self.m_fightTimer, world.m_gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list)
    end

    -- 최초 실행
    func_drop()
end

-------------------------------------
-- function tempNetwork
-- @brief 임시 네트워크 통신
-------------------------------------
function GameState:tempNetwork(l_dragon_list, finish_cb)
    local t_dragon_list = clone(l_dragon_list)

    local do_work

    local uid = g_userData:get('uid')

    local ui_network = UI_Network()
    ui_network:setReuse(true)
    ui_network:setUrl('/dragons/update')
    ui_network:setParam('uid', uid)
    ui_network:setParam('act', 'update')

    do_work = function(ret)
        local t_data = t_dragon_list[1]

        if t_data then
            table.remove(t_dragon_list, 1)
            local unique_id = t_data['user_data']['id']
            local lv = t_data['user_data']['lv']
            local exp = t_data['user_data']['exp']
            ui_network:setParam('did', unique_id)
            ui_network:setParam('lv', lv)
            ui_network:setParam('exp', exp)
            ui_network:request()
        else
            ui_network:close()
            finish_cb()
        end

        if ret and ret['dragon'] then
            g_dragonsData:applyDragonData(ret['dragon'])
        end
    end
    ui_network:setSuccessCB(do_work)
    
    
    do_work()
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
function GameState:onEvent(event_name, ...)
    
    -- 테이머 등장 (테이머가 화면 중앙까지 진출)
    if (event_name == 'tamer_appear') then
        self:changeState(GAME_STATE_START_2)

    -- 테이머가 전투 위치로 도착
    elseif (event_name == 'tamer_appear_done') then
        self:appearDragon()

    -- 적군이 전투 위치로 도착
    elseif (event_name == 'enemy_appear_done') then
        if (self.m_state == GAME_STATE_FIGHT) then
            -- 잔투중 소환된 경우
            local arg = {...}
            local enemy = arg[1]
            enemy:changeState('attackDelay')
        else
            self.m_nAppearedEnemys = self.m_nAppearedEnemys + 1
        end

    -- 액티브 스킬 사용 이벤트
    elseif (event_name == 'active_skill') then
        self.m_world.m_gameCamera:reset()

    -- 테이머 스킬 사용 이벤트
    elseif (event_name == 'tamer_special_skill') then
        self:changeState(GAME_STATE_FIGHT_TAMER_SKILL)
    
    end
end