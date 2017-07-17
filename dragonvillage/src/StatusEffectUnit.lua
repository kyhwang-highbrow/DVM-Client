-------------------------------------
-- class StatusEffectUnit
-- @brief 상태효과가 중첩시에 개별로 처리하기 위한 클래스
-------------------------------------
StatusEffectUnit = class({
        m_statusEffectName = 'string',
        m_owner = 'Character',		-- 대상자
		m_caster = 'Character',		-- 시전자
        m_skillId = 'number',       -- 스킬 아이디(스킬로 부여된 경우)
        m_bLeaderSkill = 'booleab', -- 해당 상태효과가 리더 스킬인지 여부

        m_value = 'number',         -- 적용값
        m_source = 'string',        -- 적용스텟
        
        m_duration = 'number',      -- 지속 시간. 값이 -1일 경우 무제한
        m_durationTimer = 'number',

        m_bApply = 'boolean',

        m_tParam = 'table',         -- 추가 정보들을 저장하기 위한 맵형태의 테이블
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffectUnit:init(name, owner, caster, skill_id, value, source, duration)
    --cclog(name .. ' - ' .. duration)
    self.m_statusEffectName = name

    self.m_owner = owner
    self.m_caster = caster
    self.m_skillId = skill_id
    self.m_bLeaderSkill = false

    self.m_value = value

    self.m_source = source
    
	self.m_duration = duration
    self.m_durationTimer = self.m_duration

    self.m_bApply = false

    self.m_tParam = {}

    -- 리더 스킬의 상태효과 인지 여부 확인(리더스킬의 경우 시전자가 죽어도 삭제시키지 않기 위함)
    do
        local leader_skill_id = self.m_caster:getSkillID('leader')
        if (leader_skill_id ~= 0 and leader_skill_id == self.m_skillId) then
            self.m_bLeaderSkill = true
        end
    end
end

-------------------------------------
-- function update
-- @param modified_dt 디법 지속시간 스텟을 적용한 dt
-------------------------------------
function StatusEffectUnit:update(dt, modified_dt)
    if (self.m_duration == -1) then
        -- 리더 스킬이 아닌 경우
        if (not self.m_bLeaderSkill) then
            -- 시전자가 죽었는지 체크
            if (self.m_caster and self.m_caster:isDead()) then
                return true
            end
        end
    else
        -- 대상자가 죽었는지 체크
        if (self.m_owner and self.m_owner:isDead()) then
            return true
        end

        -- 유지 시간 체크
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
        self.m_owner.m_statusCalc:addBuffMulti(key, rate * value)
		is_dirty_stat = true
    end

    -- 절대값 능력치 적용
    for key, rate in pairs(lStatusAbs) do
        self.m_owner.m_statusCalc:addBuffAdd(key, rate * value)
		is_dirty_stat = true
    end

    self.m_bApply = true

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
        self.m_owner.m_statusCalc:addBuffMulti(key, -rate * value)
		is_dirty_stat = true
    end

    -- 절대값 능력치 원상 복귀
    for key, rate in pairs(lStatusAbs) do
        self.m_owner.m_statusCalc:addBuffAdd(key, -rate * value)
		is_dirty_stat = true
    end

    self.m_bApply = false

    return true, is_dirty_stat
end

-------------------------------------
-- function getValue
-------------------------------------
function StatusEffectUnit:getValue()
    return self.m_value
end

-------------------------------------
-- function getStandardStat
-- @brief 해당 상태효과 값(value) 적용시 기준이 되는 스텟 값을 얻음
-------------------------------------
function StatusEffectUnit:getStandardStat()
    local stat

    if (type(self.m_source) == 'function') then
        stat = self.m_source(self.m_caster, self.m_owner)
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