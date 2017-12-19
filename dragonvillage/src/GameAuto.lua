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
PRIORITY_AI_ATTR[TEAM_STATE.DEBUFF][4] = SKILL_AI_ATTR__ATTACK

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
function GameAuto:init(world, game_mana)
    self.m_world = world
    self.m_gameMana = game_mana
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
    self.m_teamState = 0

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

        if ((unit.m_hp / unit.m_maxHp) < 0.6) then
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
    if (not self.m_curUnit or self.m_curUnit:isDead()) then
        self.m_curUnit = nil

        local list = self.m_lUnitListPerPriority[self.m_curPriority]
        local count = #list
        if (count > 0) then
            local list = randomShuffle(list)
               
            -- 스킬 사용 가능한 랜덤한 대상을 선택
            for _, unit in ipairs(list) do
                if (unit:isPossibleActiveSkill()) then
                    self.m_curUnit = unit
                    break
                end
            end
            
            if (not self.m_curUnit) then
                self.m_curUnit = list[1]
            end
        end
    end

    local used = true
    
    if (self.m_curUnit) then
        used = self:doWork_skill(self.m_curUnit, self.m_curPriority)
    end

    if (used) then
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
    local t_skill
    local b, m_reason = unit:isPossibleActiveSkill()
    local is_prepared = false

    if (b) then
        local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
        t_skill = skill_indivisual_info:getSkillTable()

        is_prepared = self:prepareSkill(unit, t_skill)

    elseif (self.m_teamState == TEAM_STATE.DANGER and self.m_gameMana:getCurrMana() > 3) then
        -- 위급상황에서 마나가 3이상일때 스킬 사용을 못하는 경우 랜덤 대상의 스킬을 대신 사용
        self.m_curUnit = self:getRandomSkillUnit()
        return false

    elseif (priority == 1) then
        -- 1 순위 스킬의 경우
        if (self.m_teamState == TEAM_STATE.DANGER) then
            -- 위급 상태면 마나 부족과 쿨타임은 기다림
            m_reason[REASON_TO_DO_NOT_USE_SKILL.MANA_LACK] = nil
            m_reason[REASON_TO_DO_NOT_USE_SKILL.COOL_TIME] = nil

            if (table.isEmpty(m_reason)) then
                return false
            end
        else
            -- 그외 상태면 마나 부족만 기다림
            m_reason[REASON_TO_DO_NOT_USE_SKILL.MANA_LACK] = nil

            if (table.isEmpty(m_reason)) then
                return false
            end
        end
    else
        m_reason[REASON_TO_DO_NOT_USE_SKILL.MANA_LACK] = nil

        if (table.isEmpty(m_reason)) then
            return false
        end
    end

    if (is_prepared) then
        --cclog('doSkill priority = ' .. priority)
        self:doSkill(unit, t_skill)
    end

    return true
end


-------------------------------------
-- function prepareSkill
-------------------------------------
function GameAuto:prepareSkill(unit, t_skill)
    -- 대상을 찾는다
    local l_target, fixed_target = self:findTarget(unit, t_skill)
    if (#l_target == 0) then return false end

    -- 인디케이터 정보를 설정
    return unit.m_skillIndicator:setIndicatorDataByAuto(l_target, fixed_target)
end

-------------------------------------
-- function findTarget
-------------------------------------
function GameAuto:findTarget(unit, t_skill)
    local target_type = t_skill['target_type']
	--local target_count = t_skill['target_count']
    local target_count = nil
    local target_formation = t_skill['target_formation']
    local ai_division = t_skill['ai_division']

    local l_target = {}
    local fixed_target = nil

    -- 공격형
    if (string.find(target_type, 'enemy')) then
        l_target = unit:getTargetListByType(target_type, target_count, target_formation)

    else
        -- AI 대상으로 변경
        target_type = SKILL_AI_ATTR_TARGET[ai_division]

        if (not target_type) then
            error('invalid ai_division : ' .. ai_division)
        end

        l_target = unit:getTargetListByType(target_type, target_count, target_formation)
        fixed_target = l_target[1]
    end

    return l_target, fixed_target
end

-------------------------------------
-- function doSkill
-- @brief 스킬 사용
-------------------------------------
function GameAuto:doSkill(unit, t_skill)
    -- 경직 중이라면 즉시 해제
    unit:setSpasticity(false)

    unit:reserveSkill(t_skill['sid'])

    unit:changeState('skillAppear')
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
    local t_idx = {}

    for i, unit in ipairs(self.m_lUnitList) do
        local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
        if (skill_indivisual_info and unit:isPossibleActiveSkill()) then
            table.insert(t_idx, i)
        end
    end

    if (#t_idx > 1) then
        t_idx = randomShuffle(t_idx)
    end
    
    local idx = t_idx[1]
    if (not idx) then return end
    
    return self.m_lUnitList[idx]
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
    for i = 1, 4 do
        local list = self.m_lUnitListPerPriority[i]
        cclog(string.format('- %d : %d', i, #list))
    end
    cclog('=======================================================')
end