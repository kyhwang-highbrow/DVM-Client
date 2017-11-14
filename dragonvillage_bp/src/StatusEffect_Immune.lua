local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Immune
-- @breif 상태효과 면역
-------------------------------------
StatusEffect_Immune = class(PARENT, {

        })

-------------------------------------
-- function onStart
-- @brief 해당 상태 효과가 시작시 호출
-------------------------------------
function StatusEffect_Immune:onStart()
    self.m_owner:setImmune(true)
end

-------------------------------------
-- function onEnd
-- @brief 해당 상태 효과가 종료시 호출
-------------------------------------
function StatusEffect_Immune:onEnd()
    self.m_owner:setImmune(false)
end