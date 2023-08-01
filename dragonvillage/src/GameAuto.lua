local CHECK_INTERVAL_TIME = 1
local WORK_INTERVAL_TIME = 0.5

-- AI에서 구분하는 현재 상태
TEAM_STATE = {
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

        m_mSkillListPerUnit = 'table',  -- 유닛별 보유중인 스킬 리스트
        m_lSkillInfoListPerPriority = 'table',

        m_checkTimer = 'number',        -- 주기적으로 상태 체크를 위한 타이머
        m_workTimer = 'number',

        m_curPriority = 'number',       -- 현재 진행 중인 우선순위 단계(1->2->3->1로 반복)
        m_curSkill = 'StructAiSkillInfo',-- 현재 사용 대기중인 스킬
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

    self.m_mSkillListPerUnit = {}
    self.m_lSkillInfoListPerPriority = {}

    self.m_checkTimer = 0
    self.m_workTimer = 0

    self.m_curPriority = 1
    self.m_curSkill = nil
end

-------------------------------------
-- function prepare
-------------------------------------
function GameAuto:prepare(unit_list)
    self.m_lUnitList = unit_list
    self.m_teamState = 0

    local registActiveSkill = function(unit, skill_indivisual_info)
        local t_skill = skill_indivisual_info:getSkillTable()
        local aiAttr = t_skill['ai_division']

        if (not self.m_mSkillListPerUnit[unit]) then
            self.m_mSkillListPerUnit[unit] = {}
        end

        -- 스킬 정보를 담기위한 테이블 생성
        local struct_skill_info = StructAiSkillInfo(unit, skill_indivisual_info:getSkillID())
        
        -- AI 속성 설정
        if (aiAttr and aiAttr ~= '') then
            struct_skill_info.m_mAiAttr[aiAttr] = true
        else
            struct_skill_info.m_mAiAttr = SkillHelper:makeAiAttrMap(t_skill)
        end

        -- 공격 수치 설정
        if (PLAYER_VERSUS_MODE[self.m_world.m_gameMode] == 'pvp') then
            struct_skill_info.m_aiAtk = SkillHelper:calcAiAtk(unit, t_skill)
        end

        table.insert(self.m_mSkillListPerUnit[unit], struct_skill_info)
    end

    -- 유닛별로 해당 유닛의 드래그 스킬의 AI 속성을 맵형태로 저장
    for i, unit in ipairs(self.m_lUnitList) do
        self.m_mUsedCount[unit] = 0

        local skill_indivisual_info = unit:getActiveSkillIndivisualInfoBeforeMetamorphosis()
        if (skill_indivisual_info) then
            registActiveSkill(unit, skill_indivisual_info)

            local metamorphosis_skill_info = skill_indivisual_info.m_metamorphosisSkillInfo
            if (metamorphosis_skill_info) then
                registActiveSkill(unit, metamorphosis_skill_info)
            end
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
        self.m_curSkill = nil

        -- 상태에 맞는 우선순위의 스킬에 따른 유닛 리스트 테이블을 생성
        self.m_lSkillInfoListPerPriority = self:makeSkillInfoListSortedByPriority(nextState)

        local count = 0
        for i = 1, 4 do
            count = count + #self.m_lSkillInfoListPerPriority[i]
        end

        -- 만약 1~4우선순위의 리스트가 하나도 없을 경우 모든 유닛으로 설정(우선 순위에 상관없이 모든 유닛 중 랜덤)
        if (count == 0) then
            self.m_lSkillInfoListPerPriority = self:makeSkillInfoListSortedByPriority(TEAM_STATE.NORMAL)
        end
    end

    self.m_totalHp = totalHp
    self.m_totalMaxHp = totalMaxHp
end

-------------------------------------
-- function makeSkillInfoListSortedByPriority
-- @brief state 상태에서의 우선순위별 해당하는 스킬 정보 리스트를 만듬
-------------------------------------
function GameAuto:makeSkillInfoListSortedByPriority(state)
    local list = {}
    local temp = {}

    for priority = 1, 4 do
        list[priority] = {}

        -- pvp모드의 일반 상태일때 힐 스킬만 제외하고 모두 추가
        if (PLAYER_VERSUS_MODE[self.m_world.m_gameMode] == 'pvp' and state == TEAM_STATE.NORMAL ) then
            for _, unit in ipairs(self.m_lUnitList) do
                local l_skill = self.m_mSkillListPerUnit[unit]
                if (l_skill) then
                    for _, struct_skill_info in ipairs(l_skill) do                       
                        local mAiAttr = struct_skill_info.m_mAiAttr or {}
                        if (not mAiAttr[SKILL_AI_ATTR__HEAL]) then
                            table.insert(list[priority], struct_skill_info)
                        end
                    end
                end
            end

            list[priority] = randomShuffle(list[priority])
        else
            -- 해당 우선순위의 AI 속성을 가지고 있는 스킬만 추가
            local attr = PRIORITY_AI_ATTR[state][priority]
            if (attr) then
                for _, unit in ipairs(self.m_lUnitList) do
                    local l_skill = self.m_mSkillListPerUnit[unit]
                    if (l_skill) then
                        for _, struct_skill_info in ipairs(l_skill) do                            
                            local mAiAttr = struct_skill_info.m_mAiAttr or {}
                            if (mAiAttr[attr]) then
                                table.insert(list[priority], struct_skill_info)
                            end
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
    local need_to_select_skill = false

    if (self.m_curSkill) then
        local struct_skill_info = self.m_curSkill
        local unit = struct_skill_info.m_unit
        local skill_id = struct_skill_info.m_skillId
        local skill_indivisual_info = unit:findSkillInfoByID(skill_id)

        if (unit:isDead()) then
            need_to_select_skill = true
        elseif (not skill_indivisual_info) then
            need_to_select_skill = true
        elseif (not skill_indivisual_info:isEnabled()) then
            need_to_select_skill = true
        end
    else
        need_to_select_skill = true
    end

    if (need_to_select_skill) then
        self.m_curSkill = nil

        local list = self.m_lSkillInfoListPerPriority[self.m_curPriority]
        local count = #list
        if (count > 0) then
            -- 사용횟수를 고려하여 뽑음
            table.sort(list, function(a, b)
                local unit_a = a.m_unit
                local unit_b = b.m_unit

                if (self.m_mUsedCount[unit_a] == self.m_mUsedCount[unit_b]) then
                    return a.m_aiAtk > b.m_aiAtk
                else
                    return self.m_mUsedCount[unit_a] < self.m_mUsedCount[unit_b]
                end
            end)
                
            -- 스킬 사용 가능한 랜덤한 대상을 선택
            for _, struct_skill_info in ipairs(list) do
                local unit = struct_skill_info.m_unit
                local skill_id = struct_skill_info.m_skillId
                local skill_indivisual_info = unit:findSkillInfoByID(skill_id)

                if (skill_indivisual_info and skill_indivisual_info:isEnabled()) then
                    local b, m_reason = unit:isPossibleActiveSkill()

                    if (PLAYER_VERSUS_MODE[self.m_world.m_gameMode] == 'pvp') then
                        -- 콜로세움에서 쿨타임이 3초이하로 남은 경우는 기다림
                        local timer = skill_indivisual_info:getCoolTimeForGauge()
                        if (timer <= 3) then
                            m_reason[REASON_TO_DO_NOT_USE_SKILL.COOL_TIME] = nil
                        end

                        -- 마나 부족은 항상 기다림
                        m_reason[REASON_TO_DO_NOT_USE_SKILL.MANA_LACK] = nil
                    end

                    -- 드래그 스킬 잠금
                    if self:isAutoDragSkillLocked(unit, struct_skill_info) == true then
                        m_reason[REASON_TO_DO_NOT_USE_SKILL.LOCK] = true
                    end

                    if (table.isEmpty(m_reason)) then
                        self.m_curSkill = struct_skill_info
                        break
                    end
                end
            end

            if (not self.m_curSkill) then
                if (PLAYER_VERSUS_MODE[self.m_world.m_gameMode] == 'pvp') then
                    if (self.m_teamState == TEAM_STATE.DANGER) then
                        self.m_curSkill = list[1]
                    end
                else
                    self.m_curSkill = list[1]
                end
            
                -- 드래그 스킬 잠금
                if self.m_curSkill and self:isAutoDragSkillLocked(self.m_curSkill.m_unit, self.m_curSkill) == true then
                    self.m_curSkill = nil
                end
            end
        end
    end

    local do_next = true
    
    if (self.m_curSkill) then
        do_next = self:doWork_skill(self.m_curSkill, self.m_curPriority)
    end

    if (do_next) then
        self.m_curSkill = nil

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
function GameAuto:doWork_skill(struct_skill_info, priority)
    local unit = struct_skill_info.m_unit
    local skill_id = struct_skill_info.m_skillId
    local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
    local b, m_reason = unit:isPossibleActiveSkill()

    -- 해당 스킬이 유닛의 현재 액티브 스킬과 다르면 사용하지 못하게 함
    if (skill_id ~= skill_indivisual_info:getSkillID()) then
        b = false
        m_reason[REASON_TO_DO_NOT_USE_SKILL.NO_ENABLE] = true
    end

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
            self.m_curSkill = self:getRandomSkill()

            m_reason = {}
        else
            -- 항상 마나 부족과 쿨타임은 기다림
            m_reason[REASON_TO_DO_NOT_USE_SKILL.MANA_LACK] = nil
            m_reason[REASON_TO_DO_NOT_USE_SKILL.COOL_TIME] = nil
        end
    else
        if (self.m_teamState == TEAM_STATE.DANGER and self.m_gameMana:getCurrMana() > 3) then
            -- 위급상황에서 마나가 3이상일때 스킬 사용을 못하는 경우 랜덤 대상의 스킬을 대신 사용
            self.m_curSkill = self:getRandomSkill()

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
-- function getRandomSkill
-- @breif 사용 가능한 스킬 구조체(StructAiSkillInfo)를 리턴
-------------------------------------
function GameAuto:getRandomSkill()
    local ret

    -- 사용횟수를 고려하여 뽑음
    local l_temp = {}
    for i, unit in ipairs(self.m_lUnitList) do
        if (unit:isDragon() and unit:isPossibleActiveSkill()) then           
            table.insert(l_temp, unit)
            if (not self.m_mUsedCount[unit]) then
                self.m_mUsedCount[unit] = 0
            end
        end
    end

    table.sort(l_temp, function(a, b)
        return self.m_mUsedCount[a] < self.m_mUsedCount[b]
    end)

    for i, unit in ipairs(l_temp) do
        local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
        if (skill_indivisual_info and skill_indivisual_info:isEnabled()) then
            ret = StructAiSkillInfo(unit, skill_indivisual_info:getSkillID())
            break
        end
    end
    
    return ret
end

-------------------------------------
-- function isAutoDragSkillLocked
-------------------------------------
function GameAuto:isAutoDragSkillLocked(unit, t_skill_info)
    return false
end

-------------------------------------
-- function printInfo
-------------------------------------
function GameAuto:printInfo()
    cclog('-------------------------------------------------------')
    cclog('STATE = ' .. self.m_teamState)
    cclog('## SKILL ATTR PER UNIT ##')

    for unit, l_skill in pairs(self.m_mSkillListPerUnit) do
        for _, struct_skill_info in ipairs(l_skill) do
            local unit = struct_skill_info.m_unit
            local mAiAttr = struct_skill_info.m_mAiAttr

            cclog(string.format('- %s : %s', unit:getName(), luadump(mAiAttr)))
        end
    end

    cclog('## SKILL COUNT PER PRIORITY ##')
    for i = 1, 4 do
        local list = self.m_lSkillInfoListPerPriority[i]
        local count = (list and #list or 0)
        cclog(string.format('- %d : %d', i, count))
    end
    cclog('=======================================================')
end