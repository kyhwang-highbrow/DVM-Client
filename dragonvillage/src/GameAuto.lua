-- 공격 스킬 사용 방식
GAME_AUTO_AI_ATTACK__COOLTIME    = 'at_cool'
GAME_AUTO_AI_ATTACK__ENEMY_SKILL = 'at_event'

-- 치유 스킬 사용 방식
GAME_AUTO_AI_HEAL__COOLTIME = 'at_cool'
GAME_AUTO_AI_HEAL__LOW_HP   = 'at_event'

-- 타겟 설정 방식
GAME_AUTO_AI_TAMER__SKILL_1 = 1
GAME_AUTO_AI_TAMER__SKILL_2 = 2
GAME_AUTO_AI_TAMER__SKILL_3 = 3

local GAME_AUTO_AI_DELAY_TIME = 2

-------------------------------------
-- class GameAuto
-------------------------------------
GameAuto = class(IEventListener:getCloneClass(), {
        m_world = 'GameWorld',
        m_bActive = 'boolean',
        m_lRandomAllyList = 'table',    -- 스킬 사용 순서대로 정렬된 아군 리스트
        m_aiDelayTime = 'number',       -- 스킬 사용 직후 일정 시간 뒤 다음 스킬을 사용하도록 하기 위한 딜레이 시간
     })

-------------------------------------
-- function init
-------------------------------------
function GameAuto:init(world)
    self.m_world = world

    self.m_bActive = false

    self.m_aiDelayTime = self:getAiDelayTime()

    self.m_lRandomAllyList = {}
end

-------------------------------------
-- function update
-------------------------------------
function GameAuto:update(dt)
    self:update_fight(dt)
end

-------------------------------------
-- function update_fight
-------------------------------------
function GameAuto:update_fight(dt)
    if (self.m_aiDelayTime > 0) then
        self.m_aiDelayTime = self.m_aiDelayTime - dt

        if (self.m_aiDelayTime < 0) then
            self.m_aiDelayTime = 0
        end

    else
        local b = false

        -- 테이머
        if (not b) then
            --b = self:proccess_tamer()
        end
        
        -- 드래곤
        if (not b) then
            b = self:proccess_dragon()
        end
    end
end

-------------------------------------
-- function proccess_tamer
-------------------------------------
function GameAuto:proccess_tamer()
    return false
end

-------------------------------------
-- function proccess_dragon
-------------------------------------
function GameAuto:proccess_dragon()
    if (not self:isActive()) then return end

    local dragon = self.m_lRandomAllyList[1]
    if (not dragon) then
        local allyList = self:getUnitList()
        if (#allyList == 0) then return end

        -- 해당 유닛 리스트를 랜덤하게 섞음
        self.m_lRandomAllyList = self:getRandomList(allyList)
        
        dragon = self.m_lRandomAllyList[1]
    end

    if (dragon and not dragon:isDead()) then
        -- 드래그 스킬
        local skill_id = dragon:getSkillID('active')
        if (skill_id == 0) then
            -- 해당 드래곤의 드래그 스킬이 없을 경우 리스트에서 삭제
            table.pop(self.m_lRandomAllyList)
            return
        end

        local t_skill = dragon:getLevelingSkillById(skill_id)
        local isPossibleSkill = false
        local target = nil
            
        -- 스킬 사용 여부 체크
        isPossibleSkill, target = self:checkSkill(dragon, t_skill)

        if (isPossibleSkill) then
            if (not target) then
                -- 대상을 찾는다
                target = self:findTarget(dragon, t_skill)
            end

            if (target) then
                -- 스킬 사용
                self:doSkill(dragon, t_skill, target)

                -- AI 딜레이 시간 설정
                self.m_aiDelayTime = self:getAiDelayTime()

                -- 해당 드래곤을 랜덤 리스트에서 삭제
                table.pop(self.m_lRandomAllyList)
            end
        end
    else
        -- 해당 드래곤의 드래그 스킬이 없을 경우 리스트에서 삭제
        table.pop(self.m_lRandomAllyList)

        self.m_aiDelayTime = 1
    end
end

-------------------------------------
-- function checkSkill
-- @brief 스킬 사용 여부를 확인
-------------------------------------
function GameAuto:checkSkill(owner, t_skill, aiAttack, aiHeal)
    if (not owner:isPossibleSkill()) then return false end

    local target_type = t_skill['target_type']
    --local aiAttack = aiAttack or g_autoPlaySetting:get('dragon_atk_skill')
    --local aiHeal = aiHeal or g_autoPlaySetting:get('dragon_heal_skill')
    local aiAttack = GAME_AUTO_AI_ATTACK__COOLTIME
    local aiHeal = GAME_AUTO_AI_HEAL__COOLTIME

    if startsWith(target_type, 'ally_') then
        -- 회복형
        if (aiHeal == GAME_AUTO_AI_HEAL__COOLTIME) then
            -- 쿨타임만 된다면 즉시 사용
            return true

        elseif (aiHeal == GAME_AUTO_AI_HEAL__LOW_HP) then
            -- HP가 75%이하인 아군이 있다면 사용
            local allyList = self:getUnitList()

            for i, ally in pairs(allyList) do
                if (not ally:isDead()) then
                    local hpRate = ally.m_hp / ally.m_maxHp
                    if (hpRate <= 0.75) then
                        return true, ally
                    end
                end
            end
        end

    elseif startsWith(target_type, 'enemy_') then
        -- 쿨타임만 된다면 즉시 사용
        return true

    elseif startsWith(target_type, 'all_') then
        -- 쿨타임만 된다면 즉시 사용
        return true

    end

    return false
end

-------------------------------------
-- function doSkill
-- @brief 스킬 사용
-------------------------------------
function GameAuto:doSkill(dragon, t_skill, target)
    if (not target) then
        target = self:findTarget(dragon, t_skill)
    end

    if (not target) then return end

    -- 인디게이터에 스킬 사용 정보 설정
    dragon.m_skillIndicator:setIndicatorDataByChar(target)
                    
    -- 경직 중이라면 즉시 해제
    dragon:setSpasticity(false)

    dragon:reserveSkill(t_skill['sid'])

    if (t_skill['casting_time'] > 0) then
        dragon:changeState('casting')
    else
        dragon:changeState('skillAppear')
    end
end

-------------------------------------
-- function findTarget
-- @brief 타겟을 찾는다
-------------------------------------
function GameAuto:findTarget(dragon, t_skill)
    local target_type = t_skill['target_type']
    local aiAttackType = g_autoPlaySetting:get('dragon_atk_skill')
    local aiHealType = g_autoPlaySetting:get('dragon_heal_skill')

    local target

    if startsWith(target_type, 'ally_') then
        -- 회복형

        -- HP가 가장 낮은 아군에게 사용
        local allyList = self:getUnitList()
        local lowest = 100

        for i, ally in pairs(allyList) do
            if (not ally:isDead()) then
                local hpRate = ally.m_hp / ally.m_maxHp
                
                if (hpRate < lowest) then
                    lowest = hpRate
                    target = ally
                end
            end
        end

    elseif startsWith(target_type, 'enemy_') or startsWith(target_type, 'all_') then
        -- 공격형
        if (aiAttackType == GAME_AUTO_AI_ATTACK__COOLTIME) then
            -- 기본 대상을 선택
            if dragon:checkTarget(t_skill) then
                target = dragon.m_targetChar
            end
            
        elseif (aiAttackType == GAME_AUTO_AI_ATTACK__ENEMY_SKILL) then
            -- 스킬 캐스팅 중인 적을 선택
            -- 스킬 사용 조건 체크중 이미 통과됨...
        end

    end

    return target
end

-------------------------------------
-- function getRandomList
-------------------------------------
function GameAuto:getRandomList(allyList)
    local l_ret = {}

    for i, ally in ipairs(allyList) do
        local count = #l_ret
        local idx = 1

        if (count > 0) then
            idx = math_random(1, count)
        end

        table.insert(l_ret, idx, ally)
    end

    return l_ret
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
function GameAuto:getUnitList()
    return {}
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
end

-------------------------------------
-- function getAiDelayTime
-------------------------------------
function GameAuto:getAiDelayTime()
    return GAME_AUTO_AI_DELAY_TIME
end