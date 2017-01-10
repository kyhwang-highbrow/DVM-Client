-- 스킬 타입 분류
GAME_AUTO_AI_SKILL__ATTACK  = 0
GAME_AUTO_AI_SKILL__HEAL    = 1
GAME_AUTO_AI_SKILL__ETC     = 2

-- 스킬 사용 방식
GAME_AUTO_AI_USE__COOLTIME    = 0
GAME_AUTO_AI_USE__ENEMY_SKILL = 1

-- 타겟 설정 방식
GAME_AUTO_AI_TARGET__ALLY   = 0
GAME_AUTO_AI_TARGET__ENEMY  = 1
GAME_AUTO_AI_TARGET__ALL    = 2


-------------------------------------
-- class GameAuto
-------------------------------------
GameAuto = class(IEventListener:getCloneClass(), IEventDispatcher:getCloneTable(), {
        m_world = 'GameWorld',
        
        m_bActive = 'boolean',

        m_skillType = 'number', -- 스킬 타입
        m_useType = 'number',   -- 사용 타입
        m_targetType = 'number',-- 타겟 타입
     })

-------------------------------------
-- function init
-------------------------------------
function GameAuto:init(world)
    self.m_world = world
    self.m_bActive = false

    self.m_skillType = GAME_AUTO_AI_SKILL__ATTACK
    self.m_useType = GAME_AUTO_AI_USE__COOLTIME
    self.m_targetType = GAME_AUTO_AI_TARGET__ALLY

    self:addListener('auto_start', self.m_world)
    self:addListener('auto_end', self.m_world)
end

-------------------------------------
-- function update
-------------------------------------
function GameAuto:update(dt)
    if (not self.m_bActive) then return end

    for i, dragon in ipairs(self.m_world:getDragonList()) do
        -- 스킬 사용 조건 체크
        if (self:checkSkill(dragon)) then
            -- 대상 조건 체크
            local target = self:findTarget(dragon)
            if (target) then
                -- 스킬 사용
                owner.m_skillIndicator:getIndicatorData()

                -- 경직 중이라면 즉시 해제
                self.m_selectHero:setSpasticity(false)

                self.m_selectHero:resetActiveSkillCoolTime()

                local active_skill_id = self.m_selectHero:getSkillID('active')
                local t_skill = TABLE:get('dragon_skill')[active_skill_id]

                if t_skill['casting_time'] > 0 then
                    self.m_selectHero:changeState('casting')
                else
                    self.m_selectHero:changeState('skillAttack')
                end
            end
        end

    end
end

-------------------------------------
-- function checkSkill
-- @brief 스킬 사용 여부를 확인
-------------------------------------
function GameAuto:checkSkill(dragon)
    if (not dragon:isPossibleSkill()) then return false end

    if (self.m_useType == GAME_AUTO_AI_USE__COOLTIME) then
        -- 쿨타임만 된다면 즉시 스킬 사용
        return true

    elseif (self.m_useType == GAME_AUTO_AI_USE__ENEMY_SKILL) then
        -- 캐스팅 중인 적 존재 여부에 따라 스킬 사용
        -- 적 스킬 캐스팅 이벤트로 체크
    end

    return false
end

-------------------------------------
-- function findTarget
-- @brief 타겟을 찾는다
-------------------------------------
function GameAuto:findTarget(dragon)
    local target

    if (self.m_useType == GAME_AUTO_AI_USE__COOLTIME) then
        -- 기본 대상을 선택
        if (not dragon.m_targetChar) then
            local skill_id = dragon:getSkillID('active')
            local t_skill = dragon:getLevelingSkillById(skill_id)
            
            if dragon:checkTarget(t_skill) then
                target = dragon.m_targetChar
            end
        else
            target = dragon.m_targetChar
        end

    elseif (self.m_useType == GAME_AUTO_AI_USE__ENEMY_SKILL) then
        -- 스킬 캐스팅 중인 적을 선택

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
        if (not self.m_bActive) then return end

    elseif (event_name == 'enemy_casting_start') then
        if (not self.m_bActive) then return end

        local arg = {...}
        local enemy = arg[1]

    end
end