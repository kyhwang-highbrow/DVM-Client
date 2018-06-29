-------------------------------------
-- class StatusEffectUnit
-- @brief 상태효과가 중첩시에 개별로 처리하기 위한 클래스
-------------------------------------
StatusEffectUnit = class({
        m_statusEffectName = 'string',
        m_owner = 'Character',		-- 대상자
		m_caster = 'Character',		-- 시전자
        m_skillId = 'number',       -- 스킬 아이디(스킬로 부여된 경우)
        
        m_bLeaderSkill = 'boolean', -- 해당 상태효과가 리더 스킬인지 여부
        m_bPassiveSkill = 'boolean',-- 해당 상태효과가 패시브 스킬인지 여부
        m_bT2Stat = 'boolean',      -- 스텟 계산시 T2단계로 게산 여부(리더나 패시브 스킬에 포함된 상태효과인 경우)

        m_value = 'number',         -- 적용값
        m_source = 'string',        -- 적용스텟
        
        m_duration = 'number',      -- 지속 시간. 값이 -1일 경우 무제한
        m_durationTimer = 'number',
        m_keepTimer = 'number',     -- 유지된 시간

        m_bApply = 'boolean',

        m_lStatus = 'table',        -- 적용된 스텟 정보
        m_lStatusAbs = 'table',     -- 적용된 스텟 정보

        m_tParam = 'table',         -- 추가 정보들을 저장하기 위한 맵형태의 테이블

        m_bExceptInDie = 'bool',    -- conditional_buff처럼 즉시 제거에 제외되어야 하는 케이스들이 있다.
        m_bJustTransferred = 'bool',-- 방금 전이된 효과인지 여부
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffectUnit:init(name, owner, caster, skill_id, value, source, duration, add_param)
    --cclog(name .. ' - ' .. duration)
    self.m_statusEffectName = name

    self.m_owner = owner
    self.m_caster = caster
    self.m_skillId = skill_id

    self.m_bLeaderSkill = false
    self.m_bPassiveSkill = false
    self.m_bT2Stat = false

    self.m_value = value

    self.m_source = source
    
	self.m_duration = duration
    self.m_durationTimer = duration
    
    if (self.m_duration == -1) then
        self.m_durationTimer = 99999
    end

    self.m_keepTimer = 0

    self.m_bApply = false

    self.m_tParam = add_param or {}

    local skill_type = GetSkillTable(caster:getCharType()):getSkillType(skill_id)

    -- 리더 스킬의 상태효과 인지 여부 확인(리더스킬의 경우 시전자가 죽어도 삭제시키지 않기 위함)
    if (skill_type == 'leader') then
        self.m_bLeaderSkill = true
        self.m_bT2Stat = true
    elseif (skill_type == 'passive') then
        self.m_bPassiveSkill = true
        self.m_bT2Stat = true
    end

    self.m_bExceptInDie = false
    self.m_bJustTransferred = self.m_tParam['just_transferred'] or false
end

-------------------------------------
-- function update
-- @param modified_dt 디법 지속시간 스텟을 적용한 dt
-------------------------------------
function StatusEffectUnit:update(dt, modified_dt)
    -- 드래그 스킬 중에만 유지되는 특수한 케이스의 경우는 일시정지 중에는 해제되지 않도록 함
    if (self.m_duration == 0) then
        if (modified_dt == 0) then return false end
    end
    
    self.m_keepTimer = self.m_keepTimer + dt
    self.m_bJustTransferred = false

    -- 즉시 종료해야하는지 확인
    do
        if (self.m_bLeaderSkill) then
    
        elseif (self.m_bPassiveSkill) then
            if (self.m_owner == self.m_caster) then
                -- 시전자가 자기 자신이면 유지
            elseif (self.m_caster and self.m_caster:isDead()) then
                -- 시전자가 자기 자신이 아니고 죽었다면 해제(적군만 해당)
                if(self.m_bExceptInDie) then
                else
                    return true
                end
            end
        elseif (self.m_owner and self.m_owner:isDead()) then
            -- 대상자가 죽었다면 해제(리더스킬 및 패시브 스킬 제외)
            return true
        end
    end
    
    -- 유지 시간 체크
    if (self.m_duration ~= -1) then
        self.m_durationTimer = (self.m_durationTimer - modified_dt)

        if (self.m_durationTimer <= 0) then
            self.m_durationTimer = 0
            return true
        end
    end
    
    return false
end

-------------------------------------
-- function onApply
-- @brief 대응하는 상태효과에 해당 unit이 추가(중첩)될 때 호출
-------------------------------------
function StatusEffectUnit:onApply(lStatus, lStatusAbs)
    local is_dirty_stat = false
    local value = self.m_value / 100

    if (self.m_bApply) then return false, is_dirty_stat end

    -- %능력치 적용
    for key, rate in pairs(lStatus) do
        self:addStatMulti(key, rate * value, self.m_bT2Stat)
        
		is_dirty_stat = true
    end

    -- 절대값 능력치 적용
    for key, rate in pairs(lStatusAbs) do
        self:addStatAdd(key, rate * value, self.m_bT2Stat)

		is_dirty_stat = true
    end

    self.m_bApply = true

    self.m_lStatus = lStatus
    self.m_lStatusAbs = lStatusAbs

    return true, is_dirty_stat
end

-------------------------------------
-- function onUnapply
-- @brief 대응하는 상태효과에 추가(중첩)되어있던 해당 unit이 해제될 때 호출
-------------------------------------
function StatusEffectUnit:onUnapply(lStatus, lStatusAbs)
    local is_dirty_stat = false
    local value = self.m_value / 100

    if (not self.m_bApply) then return false, is_dirty_stat end
    
    -- %능력치 원상 복귀
    for key, rate in pairs(lStatus) do
        self:addStatMulti(key, -rate * value, self.m_bT2Stat)
        
		is_dirty_stat = true
    end

    -- 절대값 능력치 원상 복귀
    for key, rate in pairs(lStatusAbs) do
        self:addStatAdd(key, -rate * value, self.m_bT2Stat)

		is_dirty_stat = true
    end

    self.m_bApply = false

    self.m_lStatus = nil
    self.m_lStatusAbs = nil

    return true, is_dirty_stat
end

-------------------------------------
-- function onChangeValue
-- @brief 적용값이 변경되었을 경우 호출(StatusEffect_Modify를 통한 적용값 변경 시)
-------------------------------------
function StatusEffectUnit:onChangeValue(new_value)
    if (self.m_value == new_value) then return end

    if (self.m_bApply) then
        local lStatus = self.m_lStatus
        local lStatusAbs = self.m_lStatusAbs

        -- 현재 적용값의 버프를 해제
        self:onUnapply(lStatus, lStatusAbs)

        self.m_value = new_value

        -- 새 적용값으로 버프 적용
        self:onApply(lStatus, lStatusAbs)
    else
        self.m_value = new_value
    end
end

-------------------------------------
-- function makeActivityCarrier
-------------------------------------
function StatusEffectUnit:makeActivityCarrier()
    local activityCarrier = self.m_caster:makeAttackDamageInstance()
	activityCarrier:setPowerRate(self.m_value)
    activityCarrier:setAtkDmgStat(self.m_source)

    local chance_type = self.m_tParam['chance_type']
    if (chance_type) then
        activityCarrier:setAttackType(chance_type)
    end

    -- 수식에서 사용하기 위한 값을 세팅
    EquationHelper:setEquationParamOnMapForStatusEffect(activityCarrier.m_tParam, self)

    return activityCarrier
end

-------------------------------------
-- function finish
-------------------------------------
function StatusEffectUnit:finish()
    self.m_duration = 0
    self.m_durationTimer = 0
end

-------------------------------------
-- function addStatMulti
-------------------------------------
function StatusEffectUnit:addStatMulti(key, value, is_passive)
    if (is_passive) then
        self.m_owner.m_statusCalc:addPassiveMulti(key, value)
    else
        self.m_owner.m_statusCalc:addBuffMulti(key, value)
    end
end

-------------------------------------
-- function addStatAdd
-------------------------------------
function StatusEffectUnit:addStatAdd(key, value, is_passive)
    if (is_passive) then
        self.m_owner.m_statusCalc:addPassiveAdd(key, value)
    else
        self.m_owner.m_statusCalc:addBuffAdd(key, value)
    end
end

-------------------------------------
-- function getValue
-------------------------------------
function StatusEffectUnit:getValue()
    return self.m_value
end

-------------------------------------
-- function getSource
-------------------------------------
function StatusEffectUnit:getSource()
    return self.m_source
end

-------------------------------------
-- function getDuration
-------------------------------------
function StatusEffectUnit:getDuration()
    return self.m_durationTimer
end

-------------------------------------
-- function getKeepTime
-------------------------------------
function StatusEffectUnit:getKeepTime()
    return self.m_keepTimer
end

-------------------------------------
-- function getStandardStat
-- @brief 해당 상태효과 값(value) 적용시 기준이 되는 스텟 값을 얻음
-------------------------------------
function StatusEffectUnit:getStandardStat()
    local stat

    if (type(self.m_source) == 'function') then
        stat = self.m_source(self.m_caster, self.m_owner, self.m_tParam)
    else
        self.m_source = SkillHelper:getValid(self.m_source, 'atk')
        stat = self.m_caster:getStat(self.m_source)
    end

    return stat
end

-------------------------------------
-- function getCaster
-------------------------------------
function StatusEffectUnit:getCaster()
    return self.m_caster
end

-------------------------------------
-- function getSkillId
-------------------------------------
function StatusEffectUnit:getSkillId()
    return self.m_skillId
end

-------------------------------------
-- function setParam
-------------------------------------
function StatusEffectUnit:setParam(key, value)
    self.m_tParam[key] = value
end

-------------------------------------
-- function getParam
-------------------------------------
function StatusEffectUnit:getParam(key)
    return self.m_tParam[key]
end