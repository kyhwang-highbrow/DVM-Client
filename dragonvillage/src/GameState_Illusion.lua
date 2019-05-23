local PARENT = GameState_ClanRaid

-------------------------------------
-- class GameState_Illusion
-------------------------------------
GameState_Illusion = class(PARENT, {

    })

-------------------------------------
-- function init
-------------------------------------
function GameState_Illusion:init(world)

end

-------------------------------------
-- function makeResultUI
-------------------------------------
function GameState_Illusion:makeResultUI(is_success)
    self.m_world:setGameFinish()
     -- @LOG : 스테이지 성공 시 클리어 시간
	self.m_world.m_logRecorder:recordLog('lap_time', self.m_fightTimer)  
    
    local world = self.m_world
    local stage_id = world.m_stageID
    local damage = total_damage

    local t_result_ref = self:makeGameFinishParam(is_success)

    local ui = UI_GameResult_Illusion(stage_id,
        is_success,
        self.m_fightTimer,
        self:getTotalDamage()
        )
    
    --[[
    local total_damage = self:getTotalDamage()

    -- 작업 함수들
    local func_network_game_finish
    local func_ui_result

    -- UI연출에 필요한 테이블들
    local t_result_ref = {}
    t_result_ref['drop_reward_list'] = {}
    t_result_ref['mail_reward_list'] = {}

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
    --]]
end

-------------------------------------
-- function onEvent
-- @brief
-------------------------------------
function GameState_Illusion:onEvent(event_name, t_event, ...)
    PARENT.onEvent(self, event_name, t_event, ...)

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
