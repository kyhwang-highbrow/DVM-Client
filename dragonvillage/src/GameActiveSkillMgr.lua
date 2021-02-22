local ACTIVE_SKILL_PRIORITY = {
    TAMER           = 1,    -- 테이머 스킬
    ALLY_TARGET     = 2,    -- 아군 대상 스킬
    ENEMY_TARGET    = 3,    -- 적군 대상 스킬
    DEFAULT         = 4
}

-------------------------------------
-- class GameActiveSkillMgr
-------------------------------------
GameActiveSkillMgr = class({
        m_world = 'GameWorld',

        m_lWork = 'table',      -- 작업 리스트
        m_mWork = 'table',

        m_bPauseWorld = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function GameActiveSkillMgr:init(world)
    self.m_world = world

    self.m_lWork = {}
    self.m_mWork = {}

    self.m_bPauseWorld = false
end

-------------------------------------
-- function update
-------------------------------------
function GameActiveSkillMgr:update(dt)
    if (self:isPossible()) then
        while (not table.isEmpty(self.m_lWork)) do
            local t_data = table.remove(self.m_lWork, 1)
            local unit = t_data['unit']

            self.m_mWork[unit] = nil

            local b, m_reason = unit:isPossibleActiveSkill()
            if (b) then
                if (self:doWork(t_data)) then break end
            end
        end
    end

    -- 만약 다음 프레임까지 일시정지 상태였다면 해제
    if (self.m_bPauseWorld) then
        self.m_bPauseWorld = false

        self.m_world:setTemporaryPause(false, nil, INGAME_PAUSE__NEXT_FRAME)
    end
end

-------------------------------------
-- function doWork
-- @brief 액티브 스킬 사용 처리
-------------------------------------
function GameActiveSkillMgr:doWork(t_data)
    local unit = t_data['unit']

    if (unit:getCharType() == 'tamer') then
        return self:doWork_tamer(t_data)
    else
        return self:doWork_dragon(t_data)
    end
end

-------------------------------------
-- function doWork_dragon
-------------------------------------
function GameActiveSkillMgr:doWork_dragon(t_data)
    local unit = t_data['unit']
    local pos_x = t_data['pos_x']
    local pos_y = t_data['pos_y']
    local input_type = t_data['input_type']
    local skill_indicator = unit:getSkillIndicator()

    --cclog('GameActiveSkillMgr:doWork : ' .. unit:getName() .. '(' .. unit.phys_idx .. ')')

    -- 스킬 사용 위치 설정
    if (pos_x and pos_y) then
        skill_indicator:setIndicatorTouchPos(pos_x, pos_y)
    else
        local is_arena = isExistValue(self.m_world.m_gameMode, GAME_MODE_ARENA, GAME_MODE_COLOSSEUM, GAME_MODE_CHALLENGE_MODE, GAME_MODE_ARENA_NEW)

        if (not SkillHelper:setIndicatorDataByAuto(unit, is_arena, input_type)) then
            return false
        end
    end

    -- 스킬 예약
    local active_skill_id = unit:getSkillID('active')
    unit:reserveSkill(active_skill_id)

    -- 크리티컬을 미리 판정하여 크리티컬 시에만 연출 보여줌
    local critical_chance = unit:getStat('cri_chance')
    local critical_avoid = 0
    local final_critical_chance = CalcCriticalChance(critical_chance, critical_avoid)
    local is_critical = (math_random(1, 1000) <= (final_critical_chance * 10))

    if (is_critical) then
        skill_indicator.m_critical = 1
    else
        skill_indicator.m_critical = 0
    end

    if (PLAYER_VERSUS_MODE[self.m_world.m_gameMode] == 'pvp' and g_settingData:get('colosseum_test_mode')) then
        -- 드래곤 스킬 시작
        unit:changeState('skillAppear')

    else
        -- 연출 시작
        self.m_world.m_gameDragonSkill:doPlay(unit, not is_critical)
    end

    return true
end


-------------------------------------
-- function doWork_tamer
-------------------------------------
function GameActiveSkillMgr:doWork_tamer(t_data)
    -- TODO: 차후 테이머 내부에서 처리되는 연출을 드래곤처럼 외부에서 처리하도록 수정해야할듯...

    local unit = t_data['unit']

    local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
    if (not skill_indivisual_info) then return false end
    
    -- 연출 시작
    self.m_world.m_gameDragonSkill:doPlay(unit)

    return true
end

-------------------------------------
-- function addWork
-- @brief 액티브 스킬 사용 등록
-------------------------------------
function GameActiveSkillMgr:addWork(unit, pos_x, pos_y, input_type)
    --cclog('GameActiveSkillMgr:addWork : ' .. unit:getName() .. '(' .. unit.phys_idx .. ')')

    local active_skill_id = unit:getSkillID('active')
    if (not active_skill_id) then return end

    -- 해당 유닛이 이미 리스트에 존재한다면 삭제
    local t_prev_data = self.m_mWork[unit]
    if (t_prev_data) then
        local idx = table.find(self.m_lWork, t_prev_data)
        if (idx) then
            table.remove(self.m_lWork, idx)
        end
        self.m_mWork[unit] = nil
    end

    -- 우선순위를 얻음
    local priority = ACTIVE_SKILL_PRIORITY.DEFAULT

    if (unit:getCharType() == 'tamer') then
        priority = ACTIVE_SKILL_PRIORITY.TAMER
    else
        local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
        local t_skill = skill_indivisual_info.m_tSkill

        if (string.find(t_skill['target_type'], 'ally')) then
            priority = ACTIVE_SKILL_PRIORITY.ALLY_TARGET
        else
            priority = ACTIVE_SKILL_PRIORITY.ENEMY_TARGET
        end
    end
        
    local t_data = { unit = unit, pos_x = pos_x, pos_y = pos_y, priority = priority, input_type = input_type }
    table.insert(self.m_lWork, t_data)

    -- 우선 순위대로 정렬
    table.sort(self.m_lWork, function(a, b) return a['priority'] < b['priority'] end)

    self.m_mWork[unit] = t_data

    -- 유저 입력으로부터 등록된 경우 다음 프레임까지 멈춘 상태가 되도록 처리
    if (input_type) then
        -- 일시 정지
        self.m_world:setTemporaryPause(true, nil, INGAME_PAUSE__NEXT_FRAME)

        self.m_bPauseWorld = true
    end
end

-------------------------------------
-- function cleanup
-------------------------------------
function GameActiveSkillMgr:cleanup()
    if (#self.m_lWork > 0) then
        self.m_lWork = {}
        self.m_mWork = {}
    end
end

-------------------------------------
-- function isPossible
-------------------------------------
function GameActiveSkillMgr:isPossible()
    local world = self.m_world

    -- 전투 중일 때에만
    if (not world.m_gameState:isFight()) then
        self:cleanup()
        return false
    end

    -- 액티브 스킬 연출 중일 경우
    if (world.m_gameDragonSkill:isPlaying()) then
        return false
    end

    return true
end