local PARENT = GameState

-------------------------------------
-- class GameState_EventGold
-------------------------------------
GameState_EventGold = class(PARENT, {
        m_accumDamage = 'number',   -- 누적 데미지(정확히는 체력을 깍은 양)
    })

-------------------------------------
-- function init
-------------------------------------
function GameState_EventGold:init(world)
    self.m_bgmBoss = 'bgm_dungeon_boss'

    -- 제한시간 1분으로 고정
    self.m_limitTime = 60

    self.m_accumDamage = SecurityNumberClass(0, false)
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_EventGold:initState()
    PARENT.initState(self)

    self:addState(GAME_STATE_SUCCESS_WAIT,  GameState_EventGold.update_success_wait)
    self:addState(GAME_STATE_SUCCESS,       GameState_EventGold.update_success)
end

-------------------------------------
-- function processTimeOut
-------------------------------------
function GameState_EventGold:processTimeOut()
    self.m_bTimeOut = true

    self:changeState(GAME_STATE_SUCCESS_WAIT)
end

-------------------------------------
-- function onEvent
-- @brief
-------------------------------------
function GameState_EventGold:onEvent(event_name, t_event, ...)
    PARENT.onEvent(self, event_name, t_event, ...)

    -- 보스 체력 공유 처리
    if (event_name == 'character_set_damage') then
        local damage = t_event['damage']

        -- 누적 데미지 갱신(정확히는 체력을 깍은 양)
        local accum_damage = self.m_accumDamage:get() + damage
        accum_damage = math_floor(math_max(accum_damage, 0))
        self.m_accumDamage:set(accum_damage)
        
        -- UI 갱신
        self.m_world.m_inGameUI:setTotalDamage(accum_damage)

        t_event['accum_damage'] = accum_damage
    end
end

-------------------------------------
-- function update_success_wait
-------------------------------------
function GameState_EventGold.update_success_wait(self, dt)
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

        -- 기본 배속으로 변경
        world.m_gameTimeScale:setBase(1)
        
		-- @LOG : 스테이지 성공 시 클리어 시간
		self.m_world.m_logRecorder:recordLog('lap_time', self.m_fightTimer)
    end

    local enemy_count = #world:getEnemyList()
    local item_count = world.m_dropItemMgr:getItemCount()

    -- 보스가 죽은 이후 드랍아이템이 모두 루팅 되었거나 일정시간이 지나면 종료
    if (enemy_count == 0) then
        if (item_count == 0 or self.m_stateTimer > 30) then
            self:changeState(GAME_STATE_SUCCESS)
        end
    end
end

-------------------------------------
-- function update_success
-------------------------------------
function GameState_EventGold.update_success(self, dt)
    if (self.m_stateTimer == 0) then
        local world = self.m_world
        world:setGameFinish()
        world:cleanupItem()
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
        if (world.m_dropItemMgr) then
            world.m_dropItemMgr:setImmediatelyObtain()
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
-- function makeResultUI
-------------------------------------
function GameState_EventGold:makeResultUI(is_success)
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
        local world = self.m_world
        if (world.m_bDevelopMode) then
            UINavigator:goTo('lobby')
            return
        end

        local t_param = self:makeGameFinishParam(is_success)
        g_gameScene:networkGameFinish(t_param, t_result_ref, func_ui_result)
    end

    -- 2. UI 생성
    func_ui_result = function()
        local world = self.m_world
        local stage_id = world.m_stageID      
        local damage = self.m_accumDamage:get()  
        local ui = UI_EventGoldDungeonResult(stage_id, damage, t_result_ref)
    end

    -- 최초 실행
    func_network_game_finish()
end

-------------------------------------
-- function makeGameFinishParam
-------------------------------------
function GameState_EventGold:makeGameFinishParam(is_success)
    local t_param = {}

    do-- 클리어 했는지 여부 ( 0 이면 실패, 1이면 성공)
        t_param['clear_type'] = 1
    end

    do-- 클리어한 웨이브 수
        local clear_wave = self.m_world.m_waveMgr.m_maxWave -- @jhakim 190415 서버에서 clear_wave 비례해서 경험치값을 주기때문에 마이너스로 내려가지 않도록 수정 
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

    -- 획득 골드
    if self.m_world.m_dropItemMgr then
        t_param['gold'] = self.m_world.m_dropItemMgr:getObtainedGold()
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

    return t_param
end