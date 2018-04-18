local PARENT = DragonSkillIndivisualInfo

-------------------------------------
-- class DragonSkillIndivisualInfoInGame
-- @TODO Individual로 수정 예정
-------------------------------------
DragonSkillIndivisualInfoInGame = class(PARENT, {
        m_tOrgSkill = 'table',  -- 스킬 레벨까지 적용된 테이블(인게임에선 실시간 변경사항은 적용되지 않음)

        m_bIgnoreCC = 'boolean',-- 스킬 사용 불가 상태효과를 무시하고 발동되는지 여부
        m_bDirtyBuff = 'boolean',
        m_lBuff = 'table',

        m_turnCount = 'number', -- 턴 공격 횟수 저장용
        m_timer = 'number',     -- 타임 공격 저장용
        m_cooldownTimer = 'number', -- 쿨타임 시간 저장용
        m_hpRate = 'number',    -- 체력 조건 저장용

        m_recentReducedCoolRate = 'number', -- 현재 감소된 쿨타임 %에 따른 dt 배율(여러번 연산되는걸 막기 위해 임시 저장 용도)
        m_reducedCoolPercentage = 'number', -- 감소될 쿨타임 %
    })

-------------------------------------
-- function init
-------------------------------------
function DragonSkillIndivisualInfoInGame:init(char_type, skill_type, skill_id, skill_level)
    self.m_className = 'DragonSkillIndivisualInfoInGame'

    self.m_bIgnoreCC = false
    self.m_bDirtyBuff = false
    self.m_lBuff = {}

    self.m_turnCount = 0
    self.m_timer = 0
    self.m_cooldownTimer = 0
    self.m_hpRate = 100

    self.m_recentReducedCoolRate = 1
    self.m_reducedCoolPercentage = 0

    self:initRuntimeInfo()
end

-------------------------------------
-- function initRuntimeInfo
-- @brief 인게임 진행에 관련된 정보들을 초기화
-------------------------------------
function DragonSkillIndivisualInfoInGame:initRuntimeInfo()
    local skill_id = self.m_skillID
    local t_skill = self.m_tSkill or GetSkillTable(self.m_charType):get(skill_id)

    if (self.m_skillType == 'indie_time' or self.m_skillType == 'indie_time_short') then
        -- 특정 스킬 아이디는 적용 시키지 않음(팀보너스, 고대룬 세트 효과)
        local key = math_floor(skill_id / 100000)

        if (key == 4) then
            -- 팀보너스인 경우
                    
        elseif (key == 5) then
            -- 고대룬 세트 효과인 경우
            self.m_timer = t_skill['chance_value']

        else
            -- indie_time 타입의 스킬은 해당 값만큼 먼저 기다리도록 초기값 설정
            self.m_timer = t_skill['chance_value'] * math_random(50, 100) / 100
        end

    elseif (self.m_skillType == 'hp_rate' or self.m_skillType == 'hp_rate_short') then
        self.m_hpRate = t_skill['chance_value']
    
    elseif (self.m_skillType == 'hp_rate_per' or self.m_skillType == 'hp_rate_per_short') then
        -- hp_rate_per 타입의 스킬은 초기 조건 설정
        self.m_hpRate = 100 - t_skill['chance_value']

        if (self.m_hpRate <= 0 and self.m_hpRate >= 100) then
            error('hp_rate_per skill error : invalid chance_value(' .. t_skill['chance_value'] .. ')')
        end
    end
end

-------------------------------------
-- function applySkillLevel
-------------------------------------
function DragonSkillIndivisualInfoInGame:applySkillLevel(old_skill_info)
    PARENT.applySkillLevel(self, old_skill_info)
    
    self:initRuntimeInfo()

    -- 원본 테이블 저장
    self.m_tOrgSkill = clone(self.m_tSkill)
end

-------------------------------------
-- function update
-------------------------------------
function DragonSkillIndivisualInfoInGame:update(dt, reduced_cool)
    -- 쿨타임 감소 % 적용(모든 패시브 쿨감 + 특정 스킬 쿨감)
    local reduced_cool = reduced_cool + self.m_reducedCoolPercentage
    if (reduced_cool and reduced_cool ~= 0) then
        reduced_cool = math_min(reduced_cool, 80)   -- 최대 80%까지만 적용

        local rate = 1 + (reduced_cool / (100 - reduced_cool))
        self.m_recentReducedCoolRate = math_max(rate , 0.5)    -- 쿨타임 증가는 2배까지만 적용

        dt = dt * self.m_recentReducedCoolRate
    else
        self.m_recentReducedCoolRate = 1
    end

    -- 타이머 갱신
    self:updateTimer(dt)

    -- 버프 적용
    if (self.m_bDirtyBuff) then
        self:applyBuff()
    end
end

-------------------------------------
-- function updateTimer
-------------------------------------
function DragonSkillIndivisualInfoInGame:updateTimer(dt)
    -- indie_time 타이머
    if (self.m_timer > 0) then
        self.m_timer = self.m_timer - dt

        if (self.m_timer <= 0) then
            self.m_timer = 0
        end
    end
    
    -- 스킬 쿨타임
    if (self.m_cooldownTimer > 0) then
        self.m_cooldownTimer = self.m_cooldownTimer - dt

        if (self.m_cooldownTimer <= 0) then
            self.m_cooldownTimer = 0
        end
    end
end

-------------------------------------
-- function startCoolTime
-------------------------------------
function DragonSkillIndivisualInfoInGame:startCoolTime()
    if (not self.m_tSkill['cooldown'] or self.m_tSkill['cooldown'] == '') then
        self.m_cooldownTimer = 0
    else
        self.m_cooldownTimer = tonumber(self.m_tSkill['cooldown'])
    end

    if (self.m_skillType == 'indie_time' or self.m_skillType == 'indie_time_short') then
        self.m_timer = self.m_tSkill['chance_value']
    end

    self.m_turnCount = 0
end


-------------------------------------
-- function startCoolTimeByCasting
-- @brief 캐스팅을 시작하면 cooldown을 제외한 나머지만 시작시킴
-------------------------------------
function DragonSkillIndivisualInfoInGame:startCoolTimeByCasting()
    if (self.m_skillType == 'indie_time' or self.m_skillType == 'indie_time_short') then
        self.m_timer = self.m_tSkill['chance_value']
    end

    self.m_turnCount = 0
end

-------------------------------------
-- function isEndCoolTime
-------------------------------------
function DragonSkillIndivisualInfoInGame:isEndCoolTime()
    if (self.m_skillType == 'indie_time' or self.m_skillType == 'indie_time_short') then
        return (self.m_cooldownTimer == 0 and self.m_timer == 0)
    else
        return (self.m_cooldownTimer == 0)
    end
end

-------------------------------------
-- function getCoolTime
-------------------------------------
function DragonSkillIndivisualInfoInGame:getCoolTimeForGauge()
    local cooldown = tonumber(self.m_tSkill['cooldown'])

    local timer = self.m_cooldownTimer / self.m_recentReducedCoolRate
    local percentage

    if (cooldown <= 0) then
        percentage = 100
    else
        percentage = (cooldown - self.m_cooldownTimer) / cooldown * 100
    end

    return timer, percentage
end

-------------------------------------
-- function resetCoolTime
-------------------------------------
function DragonSkillIndivisualInfoInGame:resetCoolTime()
    self.m_timer = 0
    self.m_cooldownTimer = 0
    self.m_turnCount = 0
end

-------------------------------------
-- function applyBuff
-------------------------------------
function DragonSkillIndivisualInfoInGame:applyBuff()
    if (not self.m_bDirtyBuff) then return end

    -- 원본 테이블로 부터 다시 계산
    local m_multi = {}
    local m_add = {}

    for i, v in ipairs(self.m_lBuff) do
        local col = v['col']
        local val = v['val']

        if (not m_multi[col]) then
            m_multi[col] = 0
        end
        if (not m_add[col]) then
            m_add[col] = 0
        end

        if (v['action'] == 'multi') then
            m_multi[col] = m_multi[col] + val

        elseif (v['action'] == 'add') then 
            m_add[col] = m_add[col] + val

        end
    end

    for col, _ in pairs(m_multi) do
        local multi = m_multi[col]
        local add = m_add[col]

        if (type(self.m_tOrgSkill[col]) == 'number') then
            self.m_tSkill[col] = self.m_tOrgSkill[col] + (self.m_tOrgSkill[col] * multi) + add
        else
            cclog('failed to apply skill buff(skill id : ' .. self.m_skillID .. ', column : ' .. col .. ')')
        end
    end
    
    self.m_bDirtyBuff = false
end

-------------------------------------
-- function addBuff
-------------------------------------
function DragonSkillIndivisualInfoInGame:addBuff(column, value, action, immediately)
    local data = {
        col = column,
        val = value or 0,
        action = action or 'add'
    }

    table.insert(self.m_lBuff, data)

    self.m_bDirtyBuff = true

    if (immediately) then
        self:applyBuff()
    end
end

-------------------------------------
-- function removeBuff
-------------------------------------
function DragonSkillIndivisualInfoInGame:removeBuff(column, value, action)
    for i, v in ipairs(self.m_lBuff) do
        if (v['col'] == column and v['val'] == value and v['action'] == action) then
            table.remove(self.m_lBuff, i)
            return
        end
    end

    self.m_bDirtyBuff = true
end

-------------------------------------
-- function setToIgnoreCC
-------------------------------------
function DragonSkillIndivisualInfoInGame:setToIgnoreCC(b)
    self.m_bIgnoreCC = b
end

-------------------------------------
-- function isIgnoreCC
-------------------------------------
function DragonSkillIndivisualInfoInGame:isIgnoreCC()
    return self.m_bIgnoreCC
end