-- 공격 스킬 사용 방식
local GAME_AUTO_AI_ATTACK__COOLTIME    = 'at_cool'
local GAME_AUTO_AI_ATTACK__ENEMY_SKILL = 'at_event'

-- 치유 스킬 사용 방식
local GAME_AUTO_AI_HEAL__COOLTIME = 'at_cool'
local GAME_AUTO_AI_HEAL__LOW_HP   = 'at_event'

-- 타겟 설정 방식
local GAME_AUTO_AI_TAMER__SKILL_1 = 1
local GAME_AUTO_AI_TAMER__SKILL_2 = 2
local GAME_AUTO_AI_TAMER__SKILL_3 = 3

local AI_DELAY_TIME = 3

-------------------------------------
-- class GameAuto
-------------------------------------
GameAuto = class(IEventListener:getCloneClass(), IEventDispatcher:getCloneTable(), {
        m_world = 'GameWorld',
        
        m_bLeftFormation = 'boolean',
        m_bActive = 'boolean',

        m_aiDelayTime = 'number',       -- 스킬 사용 직후 일정 시간 뒤 다음 스킬을 사용하도록 하기 위한 딜레이 시간

        m_tCastingEnemyList = 'table',  -- 시전 중인 적 리스트
     })

-------------------------------------
-- function init
-------------------------------------
function GameAuto:init(world, bLeftFormation)
    self.m_world = world
    self.m_bLeftFormation = (bLeftFormation ~= nil) and bLeftFormation or true

    self.m_bActive = false

    self.m_aiDelayTime = AI_DELAY_TIME

    self.m_tCastingEnemyList = {}

    self:addListener('auto_start', self.m_world)
    self:addListener('auto_end', self.m_world)
end

-------------------------------------
-- function update
-------------------------------------
function GameAuto:update(dt)
    if (not self.m_bActive) then return end

    if (self.m_aiDelayTime > 0) then
        self.m_aiDelayTime = self.m_aiDelayTime - dt

        if (self.m_aiDelayTime < 0) then
            self.m_aiDelayTime = 0
        end

    else
        for i, dragon in ipairs(self.m_world:getDragonList()) do
            local skill_id = dragon:getSkillID('active')
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
                    -- 인디게이터에 스킬 사용 정보 설정
                    dragon.m_skillIndicator:setIndicatorDataByChar(target)
                    
                    -- 경직 중이라면 즉시 해제
                    dragon:setSpasticity(false)

                    -- 스킬 쿹타임 초기상태로
                    dragon:resetActiveSkillCoolTime()

                    local active_skill_id = dragon:getSkillID('active')
                    local t_skill = TABLE:get('dragon_skill')[active_skill_id]

                    dragon:reserveSkill(t_skill['sid'])

                    if (t_skill['casting_time'] > 0) then
                        dragon:changeState('casting')
                    else
                        dragon:changeState('skillAttack')
                    end

                    -- AI 딜레이 시간 설정
                    self.m_aiDelayTime = AI_DELAY_TIME

                    -- 해당 대상을 리스트에서 제외시킴(한 대상에게 여러번 스킬 사용이 되지 않도록 하기 위함)
                    local idx = table.find(self.m_tCastingEnemyList, target)
                    if (idx) then
                        table.remove(self.m_tCastingEnemyList, idx)
                    end

                    break
                end
            end

        end
    end
end

-------------------------------------
-- function checkSkill
-- @brief 스킬 사용 여부를 확인
-------------------------------------
function GameAuto:checkSkill(dragon, t_skill)
    if (not dragon:isPossibleSkill()) then return false end

    local target_type = t_skill['target_type']
    local aiAttack = g_autoPlaySetting:get('dragon_atk_skill')
    local aiHeal = g_autoPlaySetting:get('dragon_heal_skill')

    if startsWith(target_type, 'ally_') then
        -- 회복형
        if (aiHeal == GAME_AUTO_AI_HEAL__COOLTIME) then
            -- 쿨타임만 된다면 즉시 사용
            return true

        elseif (aiHeal == GAME_AUTO_AI_HEAL__LOW_HP) then
            -- HP가 75%이하인 아군이 있다면 사용
            local heroList = self.m_world:getDragonList()

            for i, hero in pairs(heroList) do
                if (not hero.m_bDead) then
                    local hpRate = hero.m_hp / hero.m_maxHp
                    if (hpRate <= 0.75) then
                        return true, hero
                    end
                end
            end
        end

    elseif startsWith(target_type, 'enemy_') then
        -- 공격형
        if (aiAttack == GAME_AUTO_AI_ATTACK__COOLTIME) then
            -- 쿨타임만 된다면 즉시 사용
            return true

        elseif (aiAttack == GAME_AUTO_AI_ATTACK__ENEMY_SKILL) then
            -- 캐스팅 중인 적 존재 여부에 따라 사용
            local enemyList = self.m_tCastingEnemyList
            local target = nil
            local t_remove = {}
                        
            for i, enemy in ipairs(enemyList) do
                if (not enemy.m_bDead and enemy:isCasting()) then
                    target = enemy
                    break
                else
                    table.insert(t_remove, i)
                end
            end

            if #t_remove > 1 then
                table.sort(t_remove, function(a, b) return a > b end)
            end

            for i, idx in ipairs(t_remove) do
                table.remove(enemyList, idx)
            end

            if (target) then
                return true, target
            end
        end

    elseif startsWith(target_type, 'all_') then
        -- 쿨타임만 된다면 즉시 사용
        return true

    end

    return false
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
        local heroList = self.m_world:getDragonList()
        local lowest = 100

        for i, hero in pairs(heroList) do
            if (not hero.m_bDead) then
                local hpRate = hero.m_hp / hero.m_maxHp
                
                if (hpRate < lowest) then
                    lowest = hpRate
                    target = hero
                end
            end
        end

    elseif startsWith(target_type, 'enemy_') then
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

    elseif startsWith(target_type, 'all_') then
        -- 랜덤 대상에게 사용(?)
        -- 아군과 적군 포함해서 랜덤인지 여부 확인 필요...

    end

    return target
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
function GameAuto:onEvent(event_name, ...)
    if (event_name == 'auto_start') then
        self:onStart()

    elseif (event_name == 'auto_end') then
        self:onEnd()

    elseif (event_name == 'hero_casting_start') then
               
    elseif (event_name == 'enemy_casting_start') then
        local arg = {...}
        local enemy = arg[1]

        table.insert(self.m_tCastingEnemyList, enemy)

    elseif (event_name == 'hero_active_skill') then
        self.m_aiDelayTime = AI_DELAY_TIME

    elseif (event_name == 'enemy_active_skill') then

    end
end