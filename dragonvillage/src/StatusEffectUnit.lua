-------------------------------------
-- class StatusEffectUnit
-- @brief 상태효과가 중첩시에 개별로 처리하기 위한 클래스
-------------------------------------
StatusEffectUnit = class({
        m_statusEffectName = 'string',
        m_owner = 'Character',		-- 대상자
		m_caster = 'Character',		-- 시전자
        m_skillId = 'number',       -- 스킬 아이디(스킬로 부여된 경우)

        m_value = 'number',         -- 적용값
        m_duration = 'number',      -- 지속 시간. 값이 -1일 경우 무제한

        m_durationTimer = 'number',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffectUnit:init(name, owner, caster, skill_id, value, duration)
    self.m_statusEffectName = name

    self.m_owner = owner
    self.m_caster = caster
    self.m_skillId = skill_id

    self.m_value = value
	self.m_duration = duration

    self.m_durationTimer = self.m_duration
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffectUnit:update(dt)
    if (self.m_duration ~= -1) then
        self.m_durationTimer = (self.m_durationTimer - dt)

        if (self.m_durationTimer <= 0) then
            self.m_durationTimer = 0
            return true
        end
    end
    
    return false
end

-------------------------------------
-- function apply
-------------------------------------
function StatusEffectUnit:apply(lStatus, lStatusAbs)
    local is_dirty_stat = false
    local value = self.m_value / 100

    -- %능력치 적용
    for key, rate in pairs(lStatus) do
        self.m_owner.m_statusCalc:addBuffMulti(key, rate * value)
		is_dirty_stat = true
    end

    -- 절대값 능력치 적용
    for key, rate in pairs(lStatusAbs) do
        self.m_owner.m_statusCalc:addBuffAdd(key, rate * value)
		is_dirty_stat = true
    end

    return is_dirty_stat
end

-------------------------------------
-- function reset
-------------------------------------
function StatusEffectUnit:reset(lStatus, lStatusAbs)
    local is_dirty_stat = false
    local value = self.m_value / 100
    
    -- %능력치 원상 복귀
    for key, rate in pairs(lStatus) do
        self.m_owner.m_statusCalc:addBuffMulti(key, -rate * value)
		is_dirty_stat = true
    end

    -- 절대값 능력치 원상 복귀
    for key, rate in pairs(lStatusAbs) do
        self.m_owner.m_statusCalc:addBuffAdd(key, -rate * value)
		is_dirty_stat = true
    end

    return is_dirty_stat
end

-------------------------------------
-- function getValue
-------------------------------------
function StatusEffectUnit:getValue()
    return self.m_value
end