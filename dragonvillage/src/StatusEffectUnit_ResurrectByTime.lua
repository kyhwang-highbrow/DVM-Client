local PARENT = StatusEffectUnit

-------------------------------------
-- class StatusEffectUnit_ResurrectByTime
-------------------------------------
StatusEffectUnit_ResurrectByTime = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffectUnit_ResurrectByTime:init()
    self.m_bExceptInDie = true
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffectUnit_ResurrectByTime:update(dt, modified_dt)
    local b = PARENT.update(self, dt, modified_dt)

    -- 상태효과가 끝나지 않았고 대상자가 죽었다면 부활시키고 상태효과를 끝냄
    if (not b and self.m_owner:isDead(true)) then
        local hp_rate = self:getValue() / 100
        
        if (self.m_owner:doRevive(hp_rate, self:getCaster())) then
            b = true
        end
    end

    return b
end