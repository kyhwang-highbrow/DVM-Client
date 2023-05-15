local PARENT = GameState

-------------------------------------
-- class GameState_ClanRaid
-------------------------------------
GameState_ClanRaid = class(PARENT, {
        m_orgBossHp = 'number',
        m_bossHp = 'number',
        m_bossMaxHp = 'number',
        m_accumDamage = 'number',   -- 누적 데미지(정확히는 체력을 깍은 양)
        m_finalDamage = 'number',   -- 막타 데미지
        m_finalSkillId = 'number',   -- 막타 스킬 아이디

        m_uiBossHp = 'UI_IngameSharedBossHp',
    })

-------------------------------------
-- function init
-------------------------------------
function GameState_ClanRaid:init(world)
    self.m_orgBossHp = SecurityNumberClass(0, false)
    self.m_bossHp = SecurityNumberClass(0, false)
    self.m_bossMaxHp = SecurityNumberClass(0, false)
    self.m_accumDamage = SecurityNumberClass(0, false)
    self.m_finalDamage = 0
    self.m_finalSkillId = nil
    self.m_uiBossHp = nil
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_ClanRaid:initState()
    PARENT.initState(self)

    self:addState(GAME_STATE_START, GameState_ClanRaid.update_start)
    self:addState(GAME_STATE_FIGHT, GameState_ClanRaid.update_fight)
    self:addState(GAME_STATE_SUCCESS_WAIT, GameState_ClanRaid.update_success_wait)
    self:addState(GAME_STATE_SUCCESS, GameState_ClanRaid.update_success)
    self:addState(GAME_STATE_FAILURE, GameState_ClanRaid.update_failure)
    self:addState(GAME_STATE_RESULT, GameState_ClanRaid.update_result)
end

-------------------------------------
-- function updateFightTimer
-------------------------------------
function GameState_ClanRaid:updateFightTimer(dt)
    if (not isExistValue(self.m_state, GAME_STATE_FIGHT)) then return end

    -- 플레이 시간 계산
    self.m_fightTimer = self.m_fightTimer + dt

    -- 제한 시간은 게임 씬에서 처리함(일시정지에 영향을 받지 않는 시간이기 때문)
end

-------------------------------------
-- function update_start
-------------------------------------
function GameState_ClanRaid.update_start(self, dt)
    local world = self.m_world
    local map_mgr = world.m_mapManager

    if (self:getStep() == 0) then
        if (self:isBeginningStep()) then
            -- 아군 적군 드래곤들을 모두 숨김
            self:disappearAllDragon()

            -- 카메라 초기화
            world.m_gameCamera:reset()

            -- 테이머 등장
            world.m_tamer:changeState('appear')
            
            self:nextStep()
        end

    elseif (self:getStep() == 1) then
        if (self:isBeginningStep()) then
            world:dispatch('dragon_summon')
            
        elseif (self:isPassedStepTime(0.5)) then
            self:appearHero()

            -- 테이머 이동
            if (world.m_tamer) then
                world.m_tamer:runAction_MoveZ(1)
            end
            
            self:nextStep()
        end

    elseif (self:getStep() == 2) then
        if (self:isBeginningStep()) then
            self.m_world.m_tamer:initBarrier()

            self:nextStep()
        end

    elseif (self:getStep() == 3) then
        if (self:isBeginningStep()) then
            
            if (world.m_tamer) then
                world.m_tamer:setAnimatorScale(0.5)
                world.m_tamer.m_barrier:setVisible(true)
            end

            self:doDirectionForIntermission()

            self:changeState(GAME_STATE_ENEMY_APPEAR)
        end
    end
end

-------------------------------------
-- function update_fight
-------------------------------------
function GameState_ClanRaid.update_fight(self, dt)
    local world = self.m_world
    
    if (self.m_stateTimer == 0) then
        if (world.m_waveMgr:isFinalWave()) then
            -- 보스 체력 게이지
            self:makeBossHp()
        end
    end

    PARENT.update_fight(self, dt)
end

-------------------------------------
-- function update_success_wait
-------------------------------------
function GameState_ClanRaid.update_success_wait(self, dt)
    if (self.m_stateTimer == 0) then
        if (self.m_uiBossHp) then
            self.m_uiBossHp.root:removeFromParent(true)
            self.m_uiBossHp = nil
        end
    end

    PARENT.update_success_wait(self, dt)
end

-------------------------------------
-- function update_success
-------------------------------------
function GameState_ClanRaid.update_success(self, dt)
    
    if (self.m_stateTimer == 0) then
        local world = self.m_world

        -- 모든 적들을 죽임
        world:removeAllEnemy()
        world:removeMissileAndSkill()

        -- 기본 배속으로 변경
        world.m_gameTimeScale:setBase(1)

        for i, hero in ipairs(world:getDragonList()) do
            if (not hero:isDead()) then
                hero:killStateDelegate()
                hero.m_animator:changeAni('pose_1', true)
            end
        end

        world.m_inGameUI:doActionReverse(function()
            world.m_inGameUI.root:setVisible(false)
        end)

        self.m_stateParam = true

    elseif (self.m_stateTimer >= 3.5) then
        if self.m_stateParam then
            self.m_stateParam = false
            self:changeState(GAME_STATE_RESULT)
        end
    end
end

-------------------------------------
-- function update_failure
-------------------------------------
function GameState_ClanRaid.update_failure(self, dt)
    local world = self.m_world

    if (self:getStep() == 0) then
        if (self:isBeginningStep()) then
            if (world.m_tamer) then
                world.m_tamer:changeState('dying')
            end

        elseif (self:isPassedStepTime(1.5)) then
            if world.m_skillIndicatorMgr then
                world.m_skillIndicatorMgr:clear(true)
            end

            -- 스킬과 미사일도 다 날려 버리자
	        world:removeMissileAndSkill()
            world:removeEnemyDebuffs()
            world:cleanupItem()

            -- 드래곤을 모두 죽임
            world:removeAllHero()

            -- 기본 배속으로 변경
            world.m_gameTimeScale:setBase(1)

            world.m_inGameUI:doActionReverse(function()
                world.m_inGameUI.root:setVisible(false)
            end)
        else
            -- 적군 상태 체크
            local b = true

            for _, enemy in pairs(world:getEnemyList()) do
                if (not enemy:isDead() and enemy.m_state ~= 'wait') then
                    b = false
                end
            end

            if (b or self:getStepTimer() >= 4) then
                self:nextStep()
            end
        end
    
    elseif (self:getStep() == 1) then
        if (self:isBeginningStep()) then
            for i,enemy in ipairs(world:getEnemyList()) do
                if (not enemy:isDead()) then
                    enemy:killStateDelegate()
                    enemy.m_animator:changeAni('pose_1', true)
                end
            end
        
        elseif (self:getStepTimer() >= 3.5) then
            self:changeState(GAME_STATE_RESULT)
        end
    end
end

-------------------------------------
-- function update_result
-------------------------------------
function GameState_ClanRaid.update_result(self, dt)
    if (self.m_stateTimer == 0) then
        if (self.m_world.m_bDevelopMode) then
            UINavigator:goTo('adventure')
        else
            self:makeResultUI(true)
        end
    end
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_ClanRaid:makeResultUI(is_success)
    self.m_world:setGameFinish()

    local total_damage = self:getTotalDamage()

    -- 작업 함수들
    local func_network_game_finish
    local func_ui_result

    -- UI연출에 필요한 테이블들
    local t_result_ref = {}
    t_result_ref['drop_reward_list'] = {}
    t_result_ref['mail_reward_list'] = {}
    t_result_ref['event_goods_list'] = {}

    -- 1. 네트워크 통신
    func_network_game_finish = function()
        local t_param = self:makeGameFinishParam(is_success)

        -- 총 데미지
        t_param['damage'] = total_damage
        g_gameScene:networkGameFinish(t_param, t_result_ref, func_ui_result)
    end

    -- 2. UI 생성
    func_ui_result = function()
        local world = self.m_world
        local stage_id = world.m_stageID
        local damage = total_damage

        local ui = UI_ClanRaidResult(stage_id,
            is_success,
            damage,
            t_result_ref)
    end

    -- 최초 실행
    func_network_game_finish()
end

-------------------------------------
-- function makeGameFinishParam
-------------------------------------
function GameState_ClanRaid:makeGameFinishParam(is_success)
    local t_param = {}

    do-- 클리어 했는지 여부 ( 0 이면 실패, 1이면 성공)
        t_param['clear_type'] = is_success and (1 or 0)
    end

    do-- 미션 성공 여부 (성공시 1, 실패시 0)
		if (self.m_world.m_missionMgr) then
			local t_mission = self.m_world.m_missionMgr:getCompleteClearMission()
			for i = 1, 3 do
				t_param['clear_mission_' .. i] = (is_success and t_mission['mission_' .. i])
			end
		end
    end

    do-- 사용한 덱 이름
        t_param['deck_name'] = g_deckData:getSelectedDeckName()
    end

    return t_param
end

-------------------------------------
-- function disappearAllDragon
-------------------------------------
function GameState_ClanRaid:disappearAllDragon()
    local disappearDragon = function(dragon)
        if (not dragon:isDead()) then
            dragon.m_rootNode:setVisible(false)
            dragon.m_hpNode:setVisible(false)
            dragon:changeState('idle')
        end
    end
    
    for i, dragon in ipairs(self.m_world:getDragonList()) do
        disappearDragon(dragon)
    end
end

-------------------------------------
-- function doDirectionForIntermission
-------------------------------------
function GameState_ClanRaid:doDirectionForIntermission()
    local t_camera_info = {}
    	
    t_camera_info['pos_x'] = 0
	t_camera_info['pos_y'] = 0
	t_camera_info['time'] = getInGameConstant("WAVE_INTERMISSION_TIME")
        
    -- 카메라 액션 설정
    self.m_world:changeCameraOption(t_camera_info)

    self.m_world:changeHeroHomePosByCamera()
end

-------------------------------------
-- function makeBossHp
-------------------------------------
function GameState_ClanRaid:makeBossHp()
    local world = self.m_world
    local boss = world.m_waveMgr.m_lBoss[1]
    local max_hp = boss.m_maxHp
    local hp = boss.m_hp
    
    self.m_orgBossHp:set(hp)
    self.m_bossHp:set(hp)
    self.m_bossMaxHp:set(max_hp)

    -- 체력 게이지 UI 생성
    if (not self.m_uiBossHp) then
        local parent = world.m_inGameUI.root

        self.m_uiBossHp = UI_IngameSharedBossHp(parent, world.m_waveMgr.m_lBoss, true)
    end

    self.m_uiBossHp:refresh(hp, max_hp)
end

-------------------------------------
-- function setBossHp
-------------------------------------
function GameState_ClanRaid:setBossHp(hp)
    self.m_bossHp:set(hp)

    for _, boss in ipairs(self.m_world.m_waveMgr.m_lBoss) do
        boss:syncHp(hp)
    end
end

-------------------------------------
-- function onEvent
-- @brief
-------------------------------------
function GameState_ClanRaid:onEvent(event_name, t_event, ...)
    PARENT.onEvent(self, event_name, t_event, ...)

    -- 보스 체력 공유 처리
    if (event_name == 'character_set_hp') then
        local prev_hp = t_event['prev_hp']
        local new_hp = t_event['hp']

        -- 이미 타임 아웃된 경우 점수 처리 하지 않음
        if (self.m_bTimeOut) then return end

        -- 이전 체력이 동일한지 검사
        local safed_hp = self.m_bossHp:get()
        if (math_floor(prev_hp) ~= math_floor(safed_hp)) then
            -- 값이 동일하지 않을 경우 해킹인 것으로 간주해서 체력을 깍지 않음
            new_hp = safed_hp
        end

        -- 현재 체력 정보 갱신
        self:setBossHp(new_hp)

        -- 누적 데미지 갱신(정확히는 체력을 깍은 양)
        local accum_damage = self.m_orgBossHp:get() - new_hp
        accum_damage = math_floor(math_max(accum_damage, 0))
        self.m_accumDamage:set(accum_damage)
        
        -- UI 갱신
        local final_damage = self.m_finalDamage
        local total_damage = accum_damage + final_damage

        self.m_world.m_inGameUI:setTotalDamage(total_damage)

    -- 보스 막타 데미지
    elseif (event_name == 'clan_boss_final_damage') then
        local damage = t_event['damage']
        local skill_id = t_event['skill_id']

        -- 이미 타임 아웃된 경우 점수 처리 하지 않음
        if (self.m_bTimeOut) then return end

        if (not self.m_finalSkillId) then
            self.m_finalSkillId = skill_id
        elseif (self.m_finalSkillId ~= skill_id) then
            return
        end

        -- 막타 데미지 갱신
        self.m_finalDamage = self.m_finalDamage + math_floor(damage)

        -- UI 갱신
        local accum_damage = self.m_accumDamage:get()
        local final_damage = self.m_finalDamage
        local total_damage = accum_damage + final_damage

        self.m_world.m_inGameUI:setTotalDamage(total_damage)
    end
end

-------------------------------------
-- function processTimeOut
-------------------------------------
function GameState_ClanRaid:processTimeOut()
    self.m_bTimeOut = true

    -- 타임 아웃이 되었을때 무적처리를 위함
    for _, v in ipairs(self.m_world:getEnemyList()) do
        if (isInstanceOf(v, Monster_ClanRaidBoss)) then
            v:onTimeOut()
        end
    end
end

-------------------------------------
-- function getTotalDamage
-------------------------------------
function GameState_ClanRaid:getTotalDamage()
    local accum_damage = self.m_accumDamage:get()
    local final_damage = self.m_finalDamage
    local total_damage = accum_damage + final_damage

    return total_damage
end
