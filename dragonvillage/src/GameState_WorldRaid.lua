local PARENT = GameState
-------------------------------------
--- @class GameState_WorldRaid
-------------------------------------
GameState_WorldRaid = class(PARENT, {
        m_orgBossHp = 'number',
        m_bossHp = 'number',
        m_bossMaxHp = 'number',
        m_accumDamage = 'number',   -- 누적 데미지(정확히는 체력을 깍은 양)
        m_finalDamage = 'number',   -- 막타 데미지
        m_finalSkillId = 'number',   -- 막타 스킬 아이디

        m_uiBossHp = 'UI_IngameSharedBossHp',
        m_isFeverTime = 'boolean',
        
    })

-------------------------------------
-- function init
-------------------------------------
function GameState_WorldRaid:init(world)
    self.m_orgBossHp = SecurityNumberClass(0, false)
    self.m_bossHp = SecurityNumberClass(0, false)
    self.m_bossMaxHp = SecurityNumberClass(0, false)
    self.m_accumDamage = SecurityNumberClass(0, false)
    self.m_finalDamage = 0
    self.m_finalSkillId = nil
    self.m_uiBossHp = nil
    self.m_isFeverTime = false
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_WorldRaid:initState()
    PARENT.initState(self)
    self:addState(GAME_STATE_START, GameState_WorldRaid.update_start)
    self:addState(GAME_STATE_FIGHT, GameState_WorldRaid.update_fight)
    self:addState(GAME_STATE_RESULT, GameState_WorldRaid.update_result)
    --self:addState(GAME_STATE_FAILURE,  GameState_WorldRaid.update_failure)
end

-------------------------------------
-- function update_start
-------------------------------------
function GameState_WorldRaid.update_start(self, dt)
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
-- function doDirectionForIntermission
-------------------------------------
function GameState_WorldRaid:doDirectionForIntermission()
    local t_camera_info = {}
    	
    t_camera_info['pos_x'] = 0
	t_camera_info['pos_y'] = 0
	t_camera_info['time'] = getInGameConstant("WAVE_INTERMISSION_TIME")
        
    -- 카메라 액션 설정
    self.m_world:changeCameraOption(t_camera_info)

    self.m_world:changeHeroHomePosByCamera()
end

-------------------------------------
-- function update_fight
-------------------------------------
function GameState_WorldRaid.update_fight(self, dt)
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
-- function update_result
-------------------------------------
function GameState_WorldRaid.update_result(self, dt)
    local world = self.m_world
    if (self.m_stateTimer == 0) then
        if (self.m_world.m_bDevelopMode) then
            UINavigator:goTo('world_raid')
        else

            if (world.m_tamer) then
                world.m_tamer:changeState('dying')
            end

            world:setGameFinish()
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

        self:makeResultUI(true)
    end
end

-------------------------------------
-- function update_failure
-------------------------------------
function GameState_WorldRaid.update_failure(self, dt)
    local world = self.m_world
    
    --while true do end

    if (self.m_stateTimer == 0) then
        
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

        UINavigator:goTo('world_raid')
        --self:makeResultUI(false)
    end
end

-------------------------------------
-- function makeBossHp
-------------------------------------
function GameState_WorldRaid:makeBossHp()
    local world = self.m_world
    local boss = world.m_waveMgr.m_lBoss[1]

    -- 체력 게이지 UI 생성
    if (not self.m_uiBossHp) then
        local parent = world.m_inGameUI.root
        local ui = UI_IngameSharedBossHp(parent, world.m_waveMgr.m_lBoss, false)
        local attr = 'none'
        DragonInfoIconHelper.setDragonAttrBtn(attr, ui.vars['attrNode'])

        ui.vars['bossHpGauge1']:setVisible(true)
        ui.vars['bossHpGauge2']:setVisible(true)
        ui.vars['hpInfiniteSprite']:setVisible(true)
        self.m_uiBossHp = ui
    end
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_WorldRaid:makeResultUI(is_success)


        -- @LOG : 스테이지 성공 시 클리어 시간
    self.m_world.m_logRecorder:recordLog('lap_time', self.m_fightTimer)

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
    func_ui_result = function(ret)
        local world = self.m_world
        local stage_id = world.m_stageID
        local damage = total_damage
        local boss = world.m_waveMgr.m_lBoss[1]

        local ui = UI_WorldRaidResult(
            stage_id,
            boss,
            damage,
            t_result_ref,
            ret)
    end

    -- 최초 실행
    func_network_game_finish()
end

-------------------------------------
-- function disappearAllDragon
-------------------------------------
function GameState_WorldRaid:disappearAllDragon()
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
-- function onEvent
-- @brief
-------------------------------------
function GameState_WorldRaid:onEvent(event_name, t_event, ...)
    PARENT.onEvent(self, event_name, t_event, ...)

    -- 보스 체력 공유 처리
    if (event_name == 'acc_damage') then
        local damage = t_event['damage']
        -- 누적 데미지 갱신(정확히는 체력을 깍은 양)
        local accum_damage = self.m_accumDamage:get() + damage
        accum_damage = math_max(accum_damage, 0)
        self.m_accumDamage:set(accum_damage)
        -- UI 갱신
        self.m_world.m_inGameUI:setTotalDamage(math_floor(accum_damage))
    end
end

-------------------------------------
-- function getTotalDamage
-------------------------------------
function GameState_WorldRaid:getTotalDamage()
    local accum_damage = self.m_accumDamage:get()
    local final_damage = self.m_finalDamage
    local total_damage = accum_damage + final_damage

    if g_worldRaidData.m_testScoreFix ~= nil then
        if g_worldRaidData.m_testScoreFix > 0 and isWin32() then
            return g_worldRaidData.m_testScoreFix
        end
    end

    return total_damage
end


-------------------------------------
--- @function getRemainFeverTime
--- @return integer
-------------------------------------
function GameState_WorldRaid:getRemainFeverTime()
    return self.m_feverRemainTime
end


-------------------------------------
-- function updateFightTimer
-------------------------------------
function GameState_WorldRaid:updateFightTimer(dt)
    PARENT.updateFightTimer(self, dt)

end
