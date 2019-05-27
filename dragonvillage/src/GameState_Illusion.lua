local PARENT = GameState_ClanRaid

-------------------------------------
-- class GameState_Illusion
-------------------------------------
GameState_Illusion = class(PARENT, {
        m_isWin = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function GameState_Illusion:init(world)

end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_Illusion:initState()
    PARENT.initState(self)

    self:addState(GAME_STATE_START, GameState_Illusion.update_start)
    self:addState(GAME_STATE_FIGHT, GameState_Illusion.update_fight)
    self:addState(GAME_STATE_SUCCESS_WAIT, GameState_Illusion.update_success_wait)
    self:addState(GAME_STATE_SUCCESS, GameState_Illusion.update_success)
    self:addState(GAME_STATE_FAILURE, GameState_Illusion.update_failure)
    self:addState(GAME_STATE_RESULT, GameState_Illusion.update_result)
end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_Illusion:makeResultUI(is_success)
    self.m_world:setGameFinish()
    local score_calc = IllusionScoreCalc()

       -- UI연출에 필요한 테이블들
    local t_result_ref = {}
    t_result_ref['user_levelup_data'] = {}
    t_result_ref['dragon_levelu_data_list'] = {}
    t_result_ref['drop_reward_grade'] = 'c'
    t_result_ref['drop_reward_list'] = {}
    t_result_ref['secret_dungeon'] = nil
    t_result_ref['content_open'] = {}

    -- 1. 네트워크 통신
    func_network_game_finish = function()
        local t_param = self:makeGameFinishParam(is_success)    
        -- 경험치 보정치 ( 실패했을 경우 사용 ) ex : 66% 인경우 66
        if is_success then
            t_param['exp_rate'] = 100
        else
            local wave_rate = ((self.m_world.m_waveMgr.m_currWave - 1) / self.m_world.m_waveMgr.m_maxWave)
            wave_rate = math_floor(wave_rate * 100)
            t_param['exp_rate'] = math_clamp(wave_rate, 0, 100)
        end
           
        do -- 점수 계산
            score_calc:calcDamageBonus(self:getTotalDamage())
            score_calc:calcClearTimeBonus(self.m_fightTimer, is_success)

            local world = self.m_world
            local stage_id = world.m_stageID
            score_calc:calcDiffBonus(stage_id)
            score_calc:calcParticipantBonus()
            
            local final_score = score_calc:calcFinalScore()
            t_param['score'] = final_score
        end
        -- 총 데미지
        g_gameScene:networkGameFinish(t_param, t_result_ref, func_ui_result)
    end

    -- 2. UI 생성
    func_ui_result = function(ret)
        -- @LOG : 스테이지 성공 시 클리어 시간
	    self.m_world.m_logRecorder:recordLog('lap_time', self.m_fightTimer)  
        
        local world = self.m_world
        local stage_id = world.m_stageID
        local t_result_ref = self:makeGameFinishParam(is_success)

        local ui = UI_GameResult_Illusion(stage_id,
            is_success,
            self.m_fightTimer,
            self:getTotalDamage(),
            nil,
            ret['added_items'],
            score_calc)
    end

    -- 최초 실행
    func_network_game_finish()
end

-------------------------------------
-- function update_success
-------------------------------------
function GameState_Illusion.update_success(self, dt)
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
            self.m_isWin = true
            self:changeState(GAME_STATE_RESULT)
        end
    end
end

-------------------------------------
-- function update_failure
-------------------------------------
function GameState_Illusion.update_failure(self, dt)
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
            self.m_isWin = false
            self:changeState(GAME_STATE_RESULT)
        end
    end
end

-------------------------------------
-- function update_result
-------------------------------------
function GameState_Illusion.update_result(self, dt)
    if (self.m_stateTimer == 0) then
        self:makeResultUI(self.m_isWin)
    end
end

-------------------------------------
-- function onEvent
-- @brief
-------------------------------------
function GameState_Illusion:onEvent(event_name, t_event, ...)
    -- 보스 체력 공유 처리
    if (event_name == 'character_set_hp') then
        local prev_hp = t_event['prev_hp']
        local new_hp = t_event['hp']

        -- 이미 타임 아웃된 경우 점수 처리 하지 않음
        if (self.m_bTimeOut) then return end

        --[[
        -- 이전 체력이 동일한지 검사
        local safed_hp = self.m_bossHp:get()
        if (math_floor(prev_hp) ~= math_floor(safed_hp)) then
            -- 값이 동일하지 않을 경우 해킹인 것으로 간주해서 체력을 깍지 않음
            new_hp = safed_hp
        end
        --]]
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

        -- GameState_ClanRaid의 character_set_hp는 동작하지 않도록 초기화
        event_name = ''

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

    PARENT.onEvent(self, event_name, t_event, ...)
end
