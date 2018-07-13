local CHECK_INTERVAL_TIME = 1
local WORK_INTERVAL_TIME = 0.5

-- AI에서 구분하는 현재 상태
local TEAM_STATE = {
    NORMAL  = 1,
    DANGER  = 2,
}

-- 상태별 우선순위 AI 속성
local PRIORITY_AI_ATTR = {}
PRIORITY_AI_ATTR[TEAM_STATE.NORMAL] = {}
PRIORITY_AI_ATTR[TEAM_STATE.NORMAL][1] = SKILL_AI_ATTR__BUFF
PRIORITY_AI_ATTR[TEAM_STATE.NORMAL][2] = SKILL_AI_ATTR__DEBUFF
PRIORITY_AI_ATTR[TEAM_STATE.NORMAL][3] = SKILL_AI_ATTR__ATTACK

PRIORITY_AI_ATTR[TEAM_STATE.DANGER] = {}
PRIORITY_AI_ATTR[TEAM_STATE.DANGER][1] = SKILL_AI_ATTR__HEAL
PRIORITY_AI_ATTR[TEAM_STATE.DANGER][2] = SKILL_AI_ATTR__GUARDIAN
PRIORITY_AI_ATTR[TEAM_STATE.DANGER][3] = SKILL_AI_ATTR__RECOVERY


-------------------------------------
-- class GameAuto
-------------------------------------
GameAuto = class(IEventListener:getCloneClass(), {
        m_world = 'GameWorld',
        m_gameMana = 'GameMana',
        m_bActive = 'boolean',

        m_teamState = 'TEAM_STATE',
        m_totalHp = 'number',
        m_totalMaxHp = 'number',
        
        m_mUsedCount = 'table',         -- 드래그 스킬을 사용한 횟수
        m_mDebuffCount = 'table',       -- 아군들에게 현재 적용 중인 디버프별 수

        m_lUnitList = 'table',
        m_mSkillAiAttr = 'table',       -- 유닛별 보유중인 스킬 AI 속성 맵
        m_mSkillAiAtk = 'table',        -- 유닛별 보유중인 스킬 AI 공격수치
        m_lUnitListPerPriority = 'table',

        m_checkTimer = 'number',        -- 주기적으로 상태 체크를 위한 타이머
        m_workTimer = 'number',

        m_curPriority = 'number',       -- 현재 진행 중인 우선순위 단계(1->2->3->1로 반복)
        m_curUnit = '',                 -- 현재 스킬 사용을 위해 대기중인 유닛
     })

-------------------------------------
-- function init
-------------------------------------
function GameAuto:init(world, game_mana)
    self.m_world = world
    self.m_gameMana = game_mana
    self.m_bActive = false

    self.m_teamState = 0
    self.m_totalHp = 0
    self.m_totalMaxHp = 0
    self.m_mUsedCount = {}
    self.m_mDebuffCount = {}

    self.m_lUnitList = {}
    self.m_mSkillAiAttr = {}
    self.m_mSkillAiAtk = {}
    self.m_lUnitListPerPriority = {}

    self.m_checkTimer = 0
    self.m_workTimer = 0

    self.m_curPriority = 1
    self.m_curUnit = nil
end

-------------------------------------
-- function prepare
-------------------------------------
function GameAuto:prepare(unit_list)
    self.m_lUnitList = unit_list
    self.m_teamState = 0

    -- 유닛별로 해당 유닛의 드래그 스킬의 AI 속성을 맵형태로 저장
    for i, unit in ipairs(self.m_lUnitList) do
        self.m_mUsedCount[unit] = 0

        local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
        if (skill_indivisual_info) then
            local t_skill = skill_indivisual_info:getSkillTable()
            local aiAttr = t_skill['ai_division']

            -- AI 속성
            if (aiAttr and aiAttr ~= '') then
                self.m_mSkillAiAttr[unit] = {}
                self.m_mSkillAiAttr[unit][aiAttr] = true
            else
                local t_aiAttr = SkillHelper:makeAiAttrMap(t_skill)
                self.m_mSkillAiAttr[unit] = t_aiAttr
            end

            -- 공격 수치
            do
                local aiAtk = 0

                if (PLAYER_VERSUS_MODE[self.m_world.m_gameMode] == 'pvp') then
                    aiAtk = SkillHelper:calcAiAtk(unit, t_skill)
                end

                self.m_mSkillAiAtk[unit] = math_floor(aiAtk)
            end

            --cclog('self.m_mSkillAiAttr[' .. unit.m_charTable['t_name'] ..'] = ' .. luadump(self.m_mSkillAiAttr[unit]))
            --cclog('self.m_mSkillAiAtk[' .. unit.m_charTable['t_name'] ..'] = ' .. self.m_mSkillAiAtk[unit])
        end
    end
end

-------------------------------------
-- function update
-------------------------------------
function GameAuto:update(dt)
    if (not self:isActive()) then return end

    -- 상태 검사
    if (self.m_checkTimer <= 0) then
        self.m_checkTimer = CHECK_INTERVAL_TIME
        self.m_workTimer = 0
        
        self:doCheck()
    else
        self.m_checkTimer = self.m_checkTimer - dt
    end

    -- 스킬 수행
    if (self.m_workTimer <= 0) then
        self:setWorkTimer()

        self:doWork(dt)
    else
        self.m_workTimer = self.m_workTimer - dt
    end
end

-------------------------------------
-- function doCheck
-- @brief 현재 상태를 검사함
-------------------------------------
function GameAuto:doCheck()
    local nextState = TEAM_STATE.NORMAL
    local totalHp = 0
    local totalMaxHp = 0
    local totalHpRate = 0
    local debuffUnitCount = 0

    for i, unit in ipairs(self.m_lUnitList) do
        if (not unit:isDead() and not unit.m_isZombie) then
            totalHp = totalHp + unit.m_hp
            totalMaxHp = totalMaxHp + unit.m_maxHp

            if (unit:getHpRate() < 0.6) then
                nextState = TEAM_STATE.DANGER
                break
            end
        end

        if (unit:hasHarmfulStatusEffect()) then
            debuffUnitCount = debuffUnitCount + 1

        end
    end

    totalHpRate = totalHp / totalMaxHp

    if (nextState ~= TEAM_STATE.DANGER) then
        if (totalHpRate < 0.6) then
            nextState = TEAM_STATE.DANGER
        end
    end

    -- pvp모드일 경우 
    -- 남은 시간이 5초 이하이고 남은 아군의 전체 생명력이 100%가 아닐때 회복 스킬 우선 사용
    if (PLAYER_VERSUS_MODE[self.m_world.m_gameMode] == 'pvp') then
        if (self.m_world.m_gameState:getRemainTime() <= 5 and totalHpRate < 1) then
            nextState = TEAM_STATE.DANGER
        end
    end

    -- 상태가 갱신되었으면
    if (self.m_teamState ~= nextState) then
        self.m_teamState = nextState
        self.m_curUnit = nil

        -- 상태에 맞는 우선순위의 스킬에 따른 유닛 리스트 테이블을 생성
        self.m_lUnitListPerPriority = self:makeUnitListSortedByPriority(nextState)

        local count = 0
        for i = 1, 4 do
            count = count + #self.m_lUnitListPerPriority[i]
        end

        -- 만약 1~4우선순위의 리스트가 하나도 없을 경우 모든 유닛으로 설정(우선 순위에 상관없이 모든 유닛 중 랜덤)
        if (count == 0) then
            self.m_lUnitListPerPriority = self:makeUnitListSortedByPriority(TEAM_STATE.NORMAL)
        end
    end

    self.m_totalHp = totalHp
    self.m_totalMaxHp = totalMaxHp
end

-------------------------------------
-- function makeUnitListSortedByPriority
-- @brief state 상태에서의 우선순위별 해당하는 스킬 보유자 리스트를 만듬
-------------------------------------
function GameAuto:makeUnitListSortedByPriority(state)
    local list = {}
    local temp = {}

    for priority = 1, 4 do
        list[priority] = {}

        -- pvp모드의 일반 상태일때 힐 스킬을 제외하고 분류해서 처리하지 않도록 막음
        if ( PLAYER_VERSUS_MODE[self.m_world.m_gameMode] == 'pvp' and state == TEAM_STATE.NORMAL ) then
            -- 해당 AI 속성을 가지고 있는지 확인
            for _, unit in ipairs(self.m_lUnitList) do
                if (self.m_mSkillAiAttr[unit] and not self.m_mSkillAiAttr[unit][SKILL_AI_ATTR__HEAL]) then
                    table.insert(list[priority], unit)
                end
            end

            list[priority] = randomShuffle(list[priority])
        else
            local attr = PRIORITY_AI_ATTR[state][priority]
            if (attr) then
                for _, unit in ipairs(self.m_lUnitList) do
                    if (not temp[unit]) then
                        -- 해당 AI 속성을 가지고 있는지 확인
                        if (self.m_mSkillAiAttr[unit] and self.m_mSkillAiAttr[unit][attr]) then
                            table.insert(list[priority], unit)

                            temp[unit] = true
                        end
                    end
                end

                list[priority] = randomShuffle(list[priority])
            end
        end
    end
    
    return list
end

-------------------------------------
-- function doWork
-------------------------------------
function GameAuto:doWork(dt)
    if (not self.m_curUnit or self.m_curUnit:isDead()) then
        self.m_curUnit = nil

        local list = self.m_lUnitListPerPriority[self.m_curPriority]
        local count = #list
        if (count > 0) then
            -- 사용횟수를 고려하여 뽑음
            table.sort(list, function(a, b)
                if (self.m_mUsedCount[a] == self.m_mUsedCount[b]) then
                    return self.m_mSkillAiAtk[a] > self.m_mSkillAiAtk[b]
                else
                    return self.m_mUsedCount[a] < self.m_mUsedCount[b]
                end
            end)
                           
            -- 스킬 사용 가능한 랜덤한 대상을 선택
            for _, unit in ipairs(list) do
                local b, m_reason = unit:isPossibleActiveSkill()

                if (PLAYER_VERSUS_MODE[self.m_world.m_gameMode] == 'pvp') then
                    -- 콜로세움에서 쿨타임이 3초이하로 남은 경우는 기다림
                    local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
                    if (skill_indivisual_info) then
                        local timer = skill_indivisual_info:getCoolTimeForGauge()
                        if (timer <= 3) then
                            m_reason[REASON_TO_DO_NOT_USE_SKILL.COOL_TIME] = nil
                        end
                    end

                    -- 마나 부족은 항상 기다림
                    m_reason[REASON_TO_DO_NOT_USE_SKILL.MANA_LACK] = nil
                end

                if (table.isEmpty(m_reason)) then
                    self.m_curUnit = unit
                    break
                end
            end

            if (PLAYER_VERSUS_MODE[self.m_world.m_gameMode] == 'pvp') then
                if (self.m_teamState == TEAM_STATE.DANGER) then
                    if (not self.m_curUnit) then
                        self.m_curUnit = list[1]
                    end
                end
            else
                if (not self.m_curUnit) then
                    self.m_curUnit = list[1]
                end
            end
        end
    end

    local do_next = true
    
    if (self.m_curUnit) then
        do_next = self:doWork_skill(self.m_curUnit, self.m_curPriority)
    end

    if (do_next) then
        self.m_curUnit = nil

        if (self.m_curPriority >= 4) then
            self.m_curPriority = 1
        else
            self.m_curPriority = self.m_curPriority + 1
        end
    end
end

-------------------------------------
-- function doWork_skill
-- @brief 리턴값이  true일 경우 다음 우선순위의 대상 스킬을 사용하게 됨
-------------------------------------
function GameAuto:doWork_skill(unit, priority)
    local b, m_reason = unit:isPossibleActiveSkill()

    -------------------------------------
    -- 스킬 사용 처리
    if (b) then
        local l_target = SkillHelper:getTargetToUseActiveSkill(unit)
        if (#l_target > 0) then
            self.m_world.m_gameActiveSkillMgr:addWork(unit)

            if (not self.m_mUsedCount[unit]) then
                self.m_mUsedCount[unit] = 0
            end

            -- 사용 횟수 카운트 증가
            self.m_mUsedCount[unit] = self.m_mUsedCount[unit] + 1
        end

        return true
    end

	-- 쫄작 중에는 스킬 사용 못하면 넘김
	if (self.m_world:isDragonFarming()) then
		return true
	end

    -------------------------------------
    -- 스킬을 사용할 수 없는 경우 처리
    if (PLAYER_VERSUS_MODE[self.m_world.m_gameMode] == 'pvp') then
        if (self.m_teamState == TEAM_STATE.DANGER and self.m_gameMana:getCurrMana() > 3) then
            -- 위급상황에서 마나가 3이상일때 스킬 사용을 못하는 경우 랜덤 대상의 스킬을 대신 사용
            self.m_curUnit = self:getRandomSkillUnit()

            m_reason = {}
        else
            -- 항상 마나 부족과 쿨타임은 기다림
            m_reason[REASON_TO_DO_NOT_USE_SKILL.MANA_LACK] = nil
            m_reason[REASON_TO_DO_NOT_USE_SKILL.COOL_TIME] = nil
        end
    else
        if (self.m_teamState == TEAM_STATE.DANGER and self.m_gameMana:getCurrMana() > 3) then
            -- 위급상황에서 마나가 3이상일때 스킬 사용을 못하는 경우 랜덤 대상의 스킬을 대신 사용
            self.m_curUnit = self:getRandomSkillUnit()

            m_reason = {}

        elseif (self.m_teamState == TEAM_STATE.DANGER and priority == 1) then
            -- 위급상황에서 1순위 스킬의 경우 마나 부족과 쿨타임은 기다림
            m_reason[REASON_TO_DO_NOT_USE_SKILL.MANA_LACK] = nil
            m_reason[REASON_TO_DO_NOT_USE_SKILL.COOL_TIME] = nil
        else
            -- 나머지 상황에선 마나 부족만 기다림
            m_reason[REASON_TO_DO_NOT_USE_SKILL.MANA_LACK] = nil
        end
    end

    if (table.isEmpty(m_reason)) then
        return false
    end

    return true
end

-------------------------------------
-- function onStart
-------------------------------------
function GameAuto:onStart()
    self.m_bActive = true
end

-------------------------------------
-- function onEnd
-------------------------------------
function GameAuto:onEnd()
    self.m_bActive = false
end

-------------------------------------
-- function isActive
-------------------------------------
function GameAuto:isActive()
    return self.m_bActive
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameAuto:onEvent(event_name, t_event, ...)
    if (event_name == 'get_debuff') then
        local status_effect_name = t_event['status_effect_name']

        if (not self.m_mDebuffCount[status_effect_name]) then
            self.m_mDebuffCount[status_effect_name] = 0
        end

        self.m_mDebuffCount[status_effect_name] = self.m_mDebuffCount[status_effect_name] + 1

    elseif (event_name == 'release_debuff') then
        local status_effect_name = t_event['status_effect_name']

        if (self.m_mDebuffCount[status_effect_name]) then
            self.m_mDebuffCount[status_effect_name] = self.m_mDebuffCount[status_effect_name] - 1

            if (self.m_mDebuffCount[status_effect_name] <= 0) then
                self.m_mDebuffCount[status_effect_name] = nil
            end
        end
    end
end

-------------------------------------
-- function setWorkTimer
-------------------------------------
function GameAuto:setWorkTimer()
    self.m_workTimer = WORK_INTERVAL_TIME
end

-------------------------------------
-- function getRandomSkillUnit
-- @breif 스킬 사용 가능한 랜덤한 유닛을 가져옴
-------------------------------------
function GameAuto:getRandomSkillUnit()
    local ret

    -- 사용횟수를 고려하여 뽑음
    local l_temp = {}

    for i, unit in ipairs(self.m_lUnitList) do
        table.insert(l_temp, unit)

        if (not self.m_mUsedCount[unit]) then
            self.m_mUsedCount[unit] = 0
        end
    end

    table.sort(l_temp, function(a, b)
        return self.m_mUsedCount[a] < self.m_mUsedCount[b]
    end)

    for i, unit in ipairs(l_temp) do
        local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
        if (skill_indivisual_info and unit:isPossibleActiveSkill()) then
            ret = unit
            break
        end
    end
    
    return ret
end

-------------------------------------
-- function printInfo
-------------------------------------
function GameAuto:printInfo()
    cclog('-------------------------------------------------------')
    cclog('STATE = ' .. self.m_teamState)
    cclog('## SKILL ATTR PER UNIT ##')
    for unit, v in pairs(self.m_mSkillAiAttr) do
        cclog(string.format('- %s : %s', unit:getName(), luadump(v)))
    end
    cclog('## SKILL COUNT PER PRIORITY ##')
    for i = 1, 4 do
        local list = self.m_lUnitListPerPriority[i]
        local count = (list and #list or 0)
        cclog(string.format('- %d : %d', i, count))
    end
    cclog('=======================================================')
end