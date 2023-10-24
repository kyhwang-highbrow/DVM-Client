local PARENT = GameState

-------------------------------------
-- class GameState_DealkingEvent
-------------------------------------
GameState_DealkingEvent = class(PARENT, {
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
function GameState_DealkingEvent:init(world)
    self.m_orgBossHp = SecurityNumberClass(0, false)
    self.m_bossHp = SecurityNumberClass(0, false)
    self.m_bossMaxHp = SecurityNumberClass(0, false)
    self.m_accumDamage = SecurityNumberClass(0, false)
    self.m_finalDamage = 0
    self.m_finalSkillId = nil
    self.m_limitTime = ServerData_EventDealking.GAME_TIME['LIMIT']
    self.m_uiBossHp = nil
    self.m_isFeverTime = false
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_DealkingEvent:initState()
    PARENT.initState(self)
    self:addState(GAME_STATE_START, GameState_DealkingEvent.update_start)
    self:addState(GAME_STATE_FIGHT, GameState_DealkingEvent.update_fight)
    self:addState(GAME_STATE_RESULT, GameState_DealkingEvent.update_result)
end

-------------------------------------
-- function update_start
-------------------------------------
function GameState_DealkingEvent.update_start(self, dt)
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
function GameState_DealkingEvent:doDirectionForIntermission()
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
function GameState_DealkingEvent.update_fight(self, dt)
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
function GameState_DealkingEvent.update_result(self, dt)
    if (self.m_stateTimer == 0) then
        if (self.m_world.m_bDevelopMode) then
            UINavigator:goTo('adventure')
        else
            self:makeResultUI(true)
        end
    end
end


-------------------------------------
-- function makeBossHp
-------------------------------------
function GameState_DealkingEvent:makeBossHp()
    local world = self.m_world
    local boss = world.m_waveMgr.m_lBoss[1]
--[[     self.m_orgBossHp:set(hp)
    self.m_bossHp:set(hp)
    self.m_bossMaxHp:set(max_hp) ]]

    -- 체력 게이지 UI 생성
    if (not self.m_uiBossHp) then
        local parent = world.m_inGameUI.root
        local ui = UI_IngameSharedBossHp(parent, world.m_waveMgr.m_lBoss, false)
        local attr = boss:getAttribute()
        DragonInfoIconHelper.setDragonAttrBtn(attr, ui.vars['attrNode'])

        ui.vars['bossHpGauge1']:setVisible(false)
        ui.vars['bossHpGauge2']:setVisible(false)

        ui.vars['hpInfiniteLabel']:setVisible(true)
        self.m_uiBossHp = ui
    end
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_DealkingEvent:makeResultUI(is_success)
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
        local boss = world.m_waveMgr.m_lBoss[1]

        local ui = UI_EventDealkingResult(stage_id,
            boss,
            damage,
            t_result_ref)
    end

    -- 최초 실행
    func_network_game_finish()
end

-------------------------------------
-- function makeGameFinishParam
-------------------------------------
function GameState_DealkingEvent:makeGameFinishParam(is_success)
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
function GameState_DealkingEvent:disappearAllDragon()
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
function GameState_DealkingEvent:onEvent(event_name, t_event, ...)
    PARENT.onEvent(self, event_name, t_event, ...)

    -- 보스 체력 공유 처리
    if (event_name == 'acc_damage') then
        local damage = t_event['damage']
        -- 누적 데미지 갱신(정확히는 체력을 깍은 양)
        local accum_damage = self.m_accumDamage:get() + damage
        accum_damage = math_floor(math_max(accum_damage, 0))
        self.m_accumDamage:set(accum_damage)
        -- UI 갱신
        self.m_world.m_inGameUI:setTotalDamage(accum_damage)
    end
end

-------------------------------------
-- function processTimeOut
-------------------------------------
function GameState_DealkingEvent:processTimeOut()
    self.m_bTimeOut = true
    self:changeState(GAME_STATE_RESULT)
end

-------------------------------------
-- function getTotalDamage
-------------------------------------
function GameState_DealkingEvent:getTotalDamage()
    local accum_damage = self.m_accumDamage:get()
    local final_damage = self.m_finalDamage
    local total_damage = accum_damage + final_damage
    return total_damage
end

-------------------------------------
-- function updateFightTimer
-------------------------------------
function GameState_DealkingEvent:updateFightTimer(dt)
    PARENT.updateFightTimer(self, dt)
    -- 님은 시간이 피버타임 이하면 스킬 발동
    if self:getRemainTime() <= ServerData_EventDealking.GAME_TIME['FEVER'] then
        if self.m_isFeverTime == false then
            self.m_isFeverTime = true
            local world = self.m_world
            for _, v in ipairs(world.m_waveMgr.m_lBoss) do
                local struct_status_effect = StructStatusEffect({
                    type = 'cldg_dmg_add',
                    target_type = 'self',
                    target_count = 1,
                    trigger = 'skill_idle',
                    duration = 999,
                    rate = 100,
                    value = 250,
                    source = '',
                })
                StatusEffectHelper:doStatusEffectByStruct(v, {v}, {struct_status_effect})
            end
        end
    end
end