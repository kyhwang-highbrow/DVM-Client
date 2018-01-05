local PARENT = GameState

local TOP_DECK_OFFSET_X = 0
local TOP_DECK_OFFSET_Y = 180
local BOTTOM_DECK_OFFSET_X = 0
local BOTTOM_DECK_OFFSET_Y = -180

-------------------------------------
-- class GameState_ClanRaid
-------------------------------------
GameState_ClanRaid = class(PARENT, {
        m_bossHp = 'number',
        m_bossMaxHp = 'number',

        m_bossHpCount = 'number',
        m_bossMaxHpCount = 'number',

        m_totalDamage = 'number',

        m_uiBossHp = 'UI_IngameBossHp',
    })

-------------------------------------
-- function init
-------------------------------------
function GameState_ClanRaid:init(world)
    self.m_bgmBoss = 'bgm_dungeon_boss'
    --self.m_limitTime = 300

    -- 체력 설정
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    self.m_bossMaxHp = struct_raid:getMaxHp()
    self.m_bossHp = struct_raid:getHp() 

    self.m_bossMaxHpCount = 0
    self.m_bossHpCount = 0

    self.m_totalDamage = 0
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_ClanRaid:initState()
    PARENT.initState(self)

    self:addState(GAME_STATE_START, GameState_ClanRaid.update_start)
    self:addState(GAME_STATE_FIGHT, GameState_ClanRaid.update_fight)
    self:addState(GAME_STATE_SUCCESS, GameState_ClanRaid.update_success)
    self:addState(GAME_STATE_FAILURE, GameState_ClanRaid.update_failure)
    self:addState(GAME_STATE_RESULT, GameState_ClanRaid.update_result)
end

-------------------------------------
-- function updateFightTimer
-------------------------------------
function GameState_ClanRaid:updateFightTimer(dt)
    -- 게임 씬에서 처리
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
        if (not self.m_uiBossHp) then
            self.m_uiBossHp = UI_IngameBossHpForClanRaid(world, world.m_waveMgr.m_lBoss)
                
            world.m_inGameUI.root:addChild(self.m_uiBossHp.root, 102)
        end
    end

    PARENT.update_fight(self, dt)
end

-------------------------------------
-- function update_success
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

        --world:setWaitAllCharacter(false) -- 포즈 연출을 위해 wait에서 해제

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

        self.m_world:dispatch('stage_clear')

    elseif (self.m_stateTimer >= 3.5) then
        if self.m_stateParam then
            self.m_stateParam = false
            --self:changeState(GAME_STATE_RESULT)
            self:makeResultUI(true)
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
            --self:changeState(GAME_STATE_RESULT)
            self:makeResultUI(false)
        end
    end
end


-------------------------------------
-- function update_result
-------------------------------------
function GameState_ClanRaid.update_result(self, dt)
    if (self.m_stateTimer == 0) then
    end
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_ClanRaid:makeResultUI(is_success)
    self.m_world:setGameFinish()

    local total_damage = math_floor(self.m_totalDamage)

    -- 작업 함수들
    local func_network_game_finish
    local func_ui_result

    -- UI연출에 필요한 테이블들
    local t_result_ref = {}
    t_result_ref['drop_reward_list'] = {}

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
        -- 데미지 임의
        local damage = total_damage

        local ui = UI_ClanRaidResult(stage_id,
            is_success,
            damage,
            t_result_ref['drop_reward_list'])
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

    for i, dragon in ipairs(self.m_world:getEnemyList()) do
        disappearDragon(dragon)
    end
end

-------------------------------------
-- function checkWaveClear
-------------------------------------
function GameState_ClanRaid:checkWaveClear(dt)
    local world = self.m_world
    local enemy_count = #world:getEnemyList()

    -- 클리어 여부 체크
    if (enemy_count <= 0) then
        self.m_waveClearTimer = self.m_waveClearTimer + dt

        if (self.m_waveClearTimer > 0.5) then
            self.m_waveClearTimer = 0

            self:changeState(GAME_STATE_SUCCESS_WAIT)
            return true
        end    
    else
        self.m_waveClearTimer = 0
    end
    
    return false
end

-------------------------------------
-- function checkWaveClear
-------------------------------------
function GameState_ClanRaid:checkWaveClear(dt)
    if (self.m_bossHp <= 0) then
        self.m_waveClearTimer = self.m_waveClearTimer + dt

        if (self.m_waveClearTimer > 0.5) then
            self.m_waveClearTimer = 0

            self:changeState(GAME_STATE_SUCCESS_WAIT)

            return true
        end
    else
        self.m_waveClearTimer = 0
    end

    return false
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
-- function setBossHp
-------------------------------------
function GameState_ClanRaid:setBossHp(hp_count, hp)
    -- 임시... 총 데미지 계산
    if (self.m_bossHp > hp) then
        self.m_totalDamage = self.m_totalDamage + self.m_bossHp - hp
    end

    self.m_bossHpCount = hp_count
    self.m_bossHp = hp

    for _, boss in ipairs(self.m_world.m_waveMgr.m_lBoss) do
        boss:syncHp(hp_count, hp)
    end
end