local CHECK_INTERVAL_TIME = 1
local WORK_INTERVAL_TIME = 0.5

-- AI에서 구분하는 현재 상태
local TEAM_STATE = {
    NORMAL  = 1,
    DEBUFF  = 2,
    DANGER  = 3,
}

-- 상태별 우선순위 AI 속성
local PRIORITY_AI_ATTR = {}
PRIORITY_AI_ATTR[TEAM_STATE.NORMAL] = {}
PRIORITY_AI_ATTR[TEAM_STATE.NORMAL][1] = SKILL_AI_ATTR__BUFF
PRIORITY_AI_ATTR[TEAM_STATE.NORMAL][2] = SKILL_AI_ATTR__DEBUFF
PRIORITY_AI_ATTR[TEAM_STATE.NORMAL][3] = SKILL_AI_ATTR__ATTACK

PRIORITY_AI_ATTR[TEAM_STATE.DEBUFF] = {}
PRIORITY_AI_ATTR[TEAM_STATE.DEBUFF][1] = SKILL_AI_ATTR__DISPELL
PRIORITY_AI_ATTR[TEAM_STATE.DEBUFF][2] = SKILL_AI_ATTR__BUFF
PRIORITY_AI_ATTR[TEAM_STATE.DEBUFF][3] = SKILL_AI_ATTR__DEBUFF

PRIORITY_AI_ATTR[TEAM_STATE.DANGER] = {}
PRIORITY_AI_ATTR[TEAM_STATE.DANGER][1] = SKILL_AI_ATTR__HEAL
PRIORITY_AI_ATTR[TEAM_STATE.DANGER][2] = SKILL_AI_ATTR__GUARDIAN
PRIORITY_AI_ATTR[TEAM_STATE.DANGER][3] = SKILL_AI_ATTR__RECOVERY


-------------------------------------
-- class GameAuto
-------------------------------------
GameAuto = class(IEventListener:getCloneClass(), {
        m_world = 'GameWorld',
        m_bActive = 'boolean',

        m_teamState = 'TEAM_STATE',
        m_totalHp = 'number',
        m_totalMaxHp = 'number',
        m_mDebuffCount = 'table',       -- 아군들에게 현재 적용 중인 디버프별 수

        m_lUnitList = 'table',
        m_mHoldingSkill = 'table',      -- 유닛별 보유중인 스킬 AI 속성 맵
        m_lUnitListPerPriority = 'table',

        m_checkTimer = 'number',        -- 주기적으로 상태 체크를 위한 타이머
        m_workTimer = 'number',

        m_curPriority = 'number',       -- 현재 진행 중인 우선순위 단계(1->2->3->1로 반복)
        m_curUnit = '',                 -- 현재 스킬 사용을 위해 대기중인 유닛
     })

-------------------------------------
-- function init
-------------------------------------
function GameAuto:init(world)
    self.m_world = world
    self.m_bActive = false

    self.m_teamState = 0
    self.m_totalHp = 0
    self.m_totalMaxHp = 0
    self.m_mDebuffCount = {}

    self.m_lUnitList = {}
    self.m_mHoldingSkill = {}
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

    -- 유닛별로 해당 유닛의 드래그 스킬의 AI 속성을 맵형태로 저장
    for i, unit in ipairs(self.m_lUnitList) do
        local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
        if (skill_indivisual_info) then
            local t_skill = skill_indivisual_info:getSkillTable()
            local aiAttr = t_skill['ai_division']
            if (aiAttr and aiAttr ~= '') then
                self.m_mHoldingSkill[unit] = {}
                self.m_mHoldingSkill[unit][aiAttr] = true
            else
                local t_aiAttr = SkillHelper:makeAiAttrMap(t_skill)
                self.m_mHoldingSkill[unit] = t_aiAttr
            end

            --cclog('self.m_mHoldingSkill[' .. unit.m_charTable['t_name'] ..'] = ' .. luadump(self.m_mHoldingSkill[unit]))
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
    local debuffUnitCount = 0

    for i, unit in ipairs(self.m_lUnitList) do
        totalHp = unit.m_hp
        totalMaxHp = unit.m_maxHp

        if ((unit.m_hp / unit.m_maxHp) < 0.5) then
            nextState = TEAM_STATE.DANGER
            break

        elseif (unit:hasHarmfulStatusEffect()) then
            debuffUnitCount = debuffUnitCount + 1

        end
    end

    if (nextState ~= TEAM_STATE.DANGER) then
        if ((totalHp / totalMaxHp) < 0.6) then
            nextState = TEAM_STATE.DANGER
        elseif (debuffUnitCount >= 2) then
            nextState = TEAM_STATE.DEBUFF
        end
    end

    -- 상태가 갱신되었으면
    if (self.m_teamState ~= nextState) then
        self.m_teamState = nextState

        -- 상태에 맞는 우선순위의 스킬에 따른 유닛 리스트 테이블을 생성
        self.m_lUnitListPerPriority = self:makeUnitListSortedByPriority(nextState)

        local count = 0
        for i = 1, 3 do
            count = count + #self.m_lUnitListPerPriority[i]
        end

        -- 만약 1~3우선순위의 리스트가 하나도 없을 경우 모든 유닛으로 설정(우선 순위에 상관없이 모든 유닛 중 랜덤)
        if (count == 0) then
            for i = 1, 3 do
                for unit, _ in pairs(self.m_mHoldingSkill) do
                    table.insert(self.m_lUnitListPerPriority[i], unit)
                end
            end
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

    for priority = 1, 3 do
        list[priority] = {}

        local attr = PRIORITY_AI_ATTR[state][priority]
        if (attr) then
            for _, unit in ipairs(self.m_lUnitList) do
                if (not temp[unit]) then
                    -- 해당 AI 속성을 가지고 있는지 확인
                    if (self.m_mHoldingSkill[unit] and self.m_mHoldingSkill[unit][attr]) then
                        table.insert(list[priority], unit)

                        temp[unit] = true
                    end
                end
            end
        end
    end

    return list
end

-------------------------------------
-- function doWork
-------------------------------------
function GameAuto:doWork(dt)
    if (not self.m_curUnit) then
        local list = self.m_lUnitListPerPriority[self.m_curPriority]
        local count = #list
        if (count > 0) then
            local unit = randomShuffle(list)[1]
            self.m_curUnit = unit
        end
    end

    local do_next = true
    
    if (self.m_curUnit) then
        do_next = self:doWork_skill(self.m_curUnit, self.m_curPriority)
    end

    if (do_next) then
        self.m_curUnit = nil

        if (self.m_curPriority >= 3) then
            self.m_curPriority = 1
        else
            self.m_curPriority = self.m_curPriority + 1
        end
    end
end

-------------------------------------
-- function doWork_skill
-------------------------------------
function GameAuto:doWork_skill(unit, priority)
    local target
    local t_skill

    local b, reason = unit:isPossibleSkill()

    if (b) then
        local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
        t_skill = skill_indivisual_info:getSkillTable()

        -- 대상을 찾는다
        target = self:findTarget(unit, t_skill)

    elseif (priority == 1) then
        if (reason == REASON_TO_DO_NOT_USE_SKILL.MANA_LACK or reason == REASON_TO_DO_NOT_USE_SKILL.COOL_TIME) then
            return false
        end
    else
        if (reason == REASON_TO_DO_NOT_USE_SKILL.MANA_LACK) then
            return false
        end
    end

    if (target) then
        --cclog('doSkill priority = ' .. priority)
        self:doSkill(unit, t_skill, target)
    end

    return true
end

-------------------------------------
-- function findTarget
-------------------------------------
function GameAuto:findTarget(unit, t_skill)
    local target_type = t_skill['target_type']
	local target_count = t_skill['target_count']
    local target_formation = t_skill['target_formation']
    local ai_division = t_skill['ai_division']

    if (not string.find(target_type, 'enemy')) then
        target_type = SKILL_AI_ATTR_TARGET[ai_division]

        if (not target_type) then
            error('invalid ai_division : ' .. ai_division)
        end
    end

    local l_target = unit:getTargetListByType(target_type, target_count, target_formation)
    return l_target[1]
end

-------------------------------------
-- function doSkill
-- @brief 스킬 사용
-------------------------------------
function GameAuto:doSkill(unit, t_skill, target)
    -- 인디게이터에 스킬 사용 정보 설정
    unit.m_skillIndicator:setIndicatorDataByChar(target)
                    
    -- 경직 중이라면 즉시 해제
    unit:setSpasticity(false)

    unit:reserveSkill(t_skill['sid'])

    if (t_skill['casting_time'] > 0) then
        unit:changeState('casting')
    else
        unit:changeState('skillAppear')
    end
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
-- function printInfo
-------------------------------------
function GameAuto:printInfo()
    cclog('-------------------------------------------------------')
    cclog('STATE = ' .. self.m_teamState)
    cclog('## SKILL ATTR PER UNIT ##')
    for unit, v in pairs(self.m_mHoldingSkill) do
        cclog(string.format('- %s : %s', unit.m_charTable['t_name'], luadump(v)))
    end
    cclog('## SKILL COUNT PER PRIORITY ##')
    for i = 1, 3 do
        local list = self.m_lUnitListPerPriority[i]
        cclog(string.format('- %d : %d', i, #list))
    end
    cclog('=======================================================')
end