local PARENT = DragonSkillIndivisualInfo

local CHANCE_VALUE_TYPE = {
    COUNT   = 1,
    TIMER   = 2,
    HP_RATE = 3
}

-------------------------------------
-- class DragonSkillIndivisualInfoInGame
-- @TODO Individual로 수정 예정
-------------------------------------
DragonSkillIndivisualInfoInGame = class(PARENT, {
        m_owner = 'Character',
        m_tOrgSkill = 'table',  -- 스킬 레벨까지 적용된 테이블(인게임에선 실시간 변경사항은 적용되지 않음)

        m_bEnabled = 'boolean',
        m_bIgnoreCC = 'boolean',        -- 스킬 사용 불가 상태효과를 무시하고 발동되는지 여부
        m_bIgnoreReducedCool = 'boolean',-- 쿨타임 감소 효과 무시 여부
        m_bDirtyBuff = 'boolean',
        m_lBuff = 'table',              -- 해당 스킬에 적용중인 버프 리스트

        m_mIgnore = 'table',            -- 스킬 무시 속성(방어력 무시, 부활 금지...)

        m_cooldownTimer = 'number',     -- 현재 남은 쿨타임 시간
        m_chanceValueType = 'number',   -- 스킬 발동 조건값 타입(CHANCE_VALUE_TYPE)
        m_curChanceValue = 'number',    -- 스킬 발동을 위한 현재 값

        m_recentReducedCoolRate = 'number', -- 현재 감소된 쿨타임 %에 따른 dt 배율(여러번 연산되는걸 막기 위해 임시 저장 용도)
        m_reducedCoolPercentage = 'number', -- 감소될 쿨타임 %

        m_indicator = 'SkillIndicator',

        m_usedCount = 'number',         -- 실제 스킬 발동 횟수
        m_triedCount = 'number',        -- cc기 등으로 발동 안된 경우도 포함한 발동 횟수
    })

-------------------------------------
-- function init
-------------------------------------
function DragonSkillIndivisualInfoInGame:init(char_type, skill_type, skill_id, skill_level, owner)
    self.m_className = 'DragonSkillIndivisualInfoInGame'

    self.m_owner = owner

    self.m_bEnabled = true
    self.m_bIgnoreCC = false
    self.m_bIgnoreReducedCool = false
    self.m_bDirtyBuff = false
    self.m_lBuff = {}

    self.m_mIgnore = {}

    self.m_cooldownTimer = 0
    
    self.m_chanceValueType = CHANCE_VALUE_TYPE.COUNT
    self.m_curChanceValue = 0

    self.m_recentReducedCoolRate = 1
    self.m_reducedCoolPercentage = 0

    self.m_usedCount = 0
    self.m_triedCount = 0

    self:initRuntimeInfo()
end

-------------------------------------
-- function initRuntimeInfo
-- @brief 인게임 진행에 관련된 정보들을 초기화
-------------------------------------
function DragonSkillIndivisualInfoInGame:initRuntimeInfo()
    local skill_id = self.m_skillID
    local t_skill = self.m_tSkill or GetSkillTable(self.m_charType):get(skill_id)

    --if (self.m_skillType == 'indie_time' or self.m_skillType == 'indie_time_short' or self.m_skillType == 'indie_time_fix') then
    if (string.find(self.m_skillType, 'indie_time')) then
        self.m_chanceValueType = CHANCE_VALUE_TYPE.TIMER

        -- 특정 스킬 아이디는 적용 시키지 않음(팀보너스, 고대룬 세트 효과)
        if (SkillHelper:isTeamBonusSkill(skill_id)) then
            -- 팀보너스인 경우
                    
        elseif (SkillHelper:isAncientRuneSetSkill(skill_id)) then
            -- 고대룬 세트 효과인 경우
            self.m_curChanceValue = self:getChanceValue()

        elseif (t_skill['skill_type'] == 'skill_metamorphosis') then
            -- 변신 스킬의 경우
            self.m_curChanceValue = self:getChanceValue()

        elseif (string.find(self.m_skillType, 'fix')) then
            -- 픽스값인 경우
            self.m_curChanceValue = self:getChanceValue()

        else
            -- indie_time 타입의 스킬은 해당 값만큼 먼저 기다리도록 초기값 설정
            self.m_curChanceValue = self:getChanceValue() * math_random(50, 100) / 100
        end

    elseif (string.find(self.m_skillType, 'hp_rate')) then
        -- 체력 비율의 경우는 curChanceValue값은 사용되지 않음(현재 체력 비율값을 사용)
        self.m_chanceValueType = CHANCE_VALUE_TYPE.HP_RATE
    end
end

-------------------------------------
-- function syncRuntimeInfo
-- @brief 인게임 진행에 관련된 정보들을 파라미터의 것과 동기화
-- @param skill_indivisual_info : DragonSkillIndivisualInfoInGame
-------------------------------------
function DragonSkillIndivisualInfoInGame:syncRuntimeInfo(skill_indivisual_info)
    self.m_cooldownTimer = skill_indivisual_info.m_cooldownTimer
    
    if (self.m_chanceValueType == skill_indivisual_info.m_chanceValueType) then
        self.m_curChanceValue = skill_indivisual_info.m_curChanceValue
    else
        error('invalid chance value type : ' .. self.m_skillID)
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

    -- 무시 속성 정보 맵형태로 저장
    if (self.m_tSkill['ignore'] and self.m_tSkill['ignore'] ~= '') then
        local l_str = plSplit(self.m_tSkill['ignore'], ';')
        for _, v in pairs(l_str) do
	        self.m_mIgnore[v] = true
        end
    end
end

-------------------------------------
-- function update
-------------------------------------
function DragonSkillIndivisualInfoInGame:update(dt, reduced_cool)
    if (not self.m_bEnabled) then return end

    local reduced_cool = reduced_cool or 0

    if (not self:isIgnoreReducedCool()) then
        -- 쿨타임 감소 % 적용 = 스텟 쿨감(cool_actu or drag_cool) + 특정 스킬 쿨감
        reduced_cool = reduced_cool + self.m_reducedCoolPercentage
    end

    if (reduced_cool ~= 0) then
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
    if (self.m_chanceValueType == CHANCE_VALUE_TYPE.TIMER) then
        if (self.m_curChanceValue > 0) then
            self.m_curChanceValue = self.m_curChanceValue - dt

            if (self.m_curChanceValue <= 0) then
                self.m_curChanceValue = 0
            end
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
function DragonSkillIndivisualInfoInGame:startCoolTime(is_used)
    if (not self.m_tSkill['cooldown'] or self.m_tSkill['cooldown'] == '') then
        self.m_cooldownTimer = 0
    else
        self.m_cooldownTimer = tonumber(self.m_tSkill['cooldown'])
    end

    if (self.m_chanceValueType ==  CHANCE_VALUE_TYPE.COUNT) then
        self.m_curChanceValue = 0
    elseif (self.m_chanceValueType ==  CHANCE_VALUE_TYPE.TIMER) then
        self.m_curChanceValue = self:getChanceValue()
    end

    if (is_used) then
        self.m_usedCount = self.m_usedCount + 1
        self.m_triedCount = self.m_triedCount + 1
    end
end


-------------------------------------
-- function startCoolTimeByCasting
-- @brief 캐스팅을 시작하면 cooldown을 제외한 나머지만 시작시킴
-------------------------------------
function DragonSkillIndivisualInfoInGame:startCoolTimeByCasting()
    if (isExistValue(self.m_chanceValueType, CHANCE_VALUE_TYPE.COUNT, CHANCE_VALUE_TYPE.TIMER)) then
        self.m_curChanceValue = 0
    end
end

-------------------------------------
-- function isEndCoolTime
-------------------------------------
function DragonSkillIndivisualInfoInGame:isEndCoolTime()
    if (not self.m_bEnabled) then return end

    if (self.m_chanceValueType == CHANCE_VALUE_TYPE.TIMER) then
        return (self.m_cooldownTimer == 0 and self.m_curChanceValue == 0)
    else
        return (self.m_cooldownTimer == 0)
    end
end

-------------------------------------
-- function getCoolTimeForGauge
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
    self.m_cooldownTimer = 0

    if (isExistValue(self.m_chanceValueType, CHANCE_VALUE_TYPE.COUNT, CHANCE_VALUE_TYPE.TIMER)) then
        self.m_curChanceValue = 0
    end
end

-------------------------------------
-- function setCoolTime
-------------------------------------
function DragonSkillIndivisualInfoInGame:setCoolTime(sec)
    self.m_cooldownTimer = sec

    if (self.m_chanceValueType == CHANCE_VALUE_TYPE.TIMER) then
        self.m_curChanceValue = sec
    end
end

-------------------------------------
-- function adjustCurCoolTime
-- @brief 현재 남은 쿨타임을 파라미터의 비율로 조정
-------------------------------------
function DragonSkillIndivisualInfoInGame:adjustCurCoolTime(rate)
    self.m_cooldownTimer = self.m_cooldownTimer * rate

    if (self.m_chanceValueType == CHANCE_VALUE_TYPE.TIMER) then
        self.m_curChanceValue = self.m_curChanceValue * rate
    end
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
-- function setEnabled
-------------------------------------
function DragonSkillIndivisualInfoInGame:setEnabled(b)
    self.m_bEnabled = b
end

-------------------------------------
-- function isEnabled
-------------------------------------
function DragonSkillIndivisualInfoInGame:isEnabled()
    return self.m_bEnabled
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

-------------------------------------
-- function setToIgnoreReducedCool
-------------------------------------
function DragonSkillIndivisualInfoInGame:setToIgnoreReducedCool(b)
    self.m_bIgnoreReducedCool = b
end

-------------------------------------
-- function isIgnoreReducedCool
-------------------------------------
function DragonSkillIndivisualInfoInGame:isIgnoreReducedCool()
    return self.m_bIgnoreReducedCool
end

-------------------------------------
-- function getChanceValue
-------------------------------------
function DragonSkillIndivisualInfoInGame:getChanceValue()
    local t_skill = self.m_tSkill or GetSkillTable(self.m_charType):get(self.m_skillID)
    local chance_value = t_skill['chance_value']

    -- 발동 조건값(chance_value)이 수식인 경우 수식을 계산
    if (type(chance_value) == 'function') then
        chance_value = chance_value(self.m_owner, nil, nil, self.m_skillID)
    else
        chance_value = chance_value
    end

    if (isNullOrEmpty(chance_value)) then
        chance_value = 100
    end

    return chance_value
end

-------------------------------------
-- function getUsedCount
-------------------------------------
function DragonSkillIndivisualInfoInGame:getUsedCount()
    return self.m_usedCount
end

-------------------------------------
-- function getTriedCount
-------------------------------------
function DragonSkillIndivisualInfoInGame:getTriedCount()
    return self.m_triedCount
end

-------------------------------------
-- function onBeStoppedInCC
-- @brief 스킬이 발동되어야했지만 cc기로 인해 스킬 사용이 막혔을 때 호출됨
-------------------------------------
function DragonSkillIndivisualInfoInGame:onBeStoppedInCC()
    self.m_triedCount = self.m_triedCount + 1
    --cclog('onBeStoppedInCC : ' .. self.m_triedCount)
end

-------------------------------------
-- function getMapToIgnore
-------------------------------------
function DragonSkillIndivisualInfoInGame:getMapToIgnore()
    return self.m_mIgnore
end