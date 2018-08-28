local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_ProtectionByTime
-- @breif HP있는 실드 보호막 + resist 보호막
-------------------------------------
StatusEffect_ProtectionByTime = class(PARENT, {
            m_bIsKeeppedHp = 'boolean',   -- 체력 유지 여부
        })


-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_ProtectionByTime:init(file_name, body)
    self.m_bIsKeeppedHp = false
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_ProtectionByTime:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    self.m_bIsKeeppedHp = self:isKeeppedHp()
end

-------------------------------------
-- function init_top
-------------------------------------
function StatusEffect_ProtectionByTime:init_top(file_name)
	-- top을 찍지 않는다
end

-------------------------------------
-- function onApplyOverlab
-- @brief 해당 상태효과가 최초 1회를 포함하여 중첩 적용될시마다 호출
-------------------------------------
function StatusEffect_ProtectionByTime:onApplyOverlab(unit)
    if (self.m_bIsKeeppedHp and not self.m_owner:isDead() and not self.m_owner.m_isZombie) then
        -- value로 설정된 값을 최소 체력 비율값으로 사용
        local min_hp_rate = unit:getValue() / 100
        local min_hp = min_hp_rate * self.m_owner:getMaxHp()

        if (min_hp > self.m_owner:getHp() and min_hp <= self.m_owner.m_prevHp) then
            self.m_owner:setHp(min_hp, true)
        end
    end
end

-------------------------------------
-- function onStart
-- @brief 해당 상태 효과가 시작시 호출
-------------------------------------
function StatusEffect_ProtectionByTime:onStart()
    if (self.m_owner:getStatusEffectCountBySubject('barrier_time') == 1) then
        self.m_owner:setProtected(true)
    end
end

-------------------------------------
-- function onEnd
-- @brief 해당 상태 효과가 종료시 호출
-------------------------------------
function StatusEffect_ProtectionByTime:onEnd()
    if (self.m_owner:getStatusEffectCountBySubject('barrier_time') <= 1) then
        self.m_owner:setProtected(false)
    end
end

-------------------------------------
-- function isKeeppedHp
-------------------------------------
function StatusEffect_ProtectionByTime:isKeeppedHp()
    local t_status_effect = self.m_statusEffectTable

    if (type(t_status_effect['val_1']) ~= 'string') then
        return false
    end

    return (t_status_effect['val_1'] == 'keep_hp')
end