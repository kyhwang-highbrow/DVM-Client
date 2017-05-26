local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Silence
-------------------------------------
StatusEffect_Silence = class(PARENT, {
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Silence:init(file_name, body)
end

-------------------------------------
-- function onApplyCommon
-- @brief 중첩과 관계없이 한번만 적용되어야하는 효과를 적용
-------------------------------------
function StatusEffect_Silence:onApplyCommon()
    StatusEffect.onApplyCommon(self)

    self.m_owner:setSilence(true)
end

-------------------------------------
-- function onUnapplyCommon
-- @brief 중첩과 관계없이 한번만 적용되어야하는 효과를 해제
-------------------------------------
function StatusEffect_Silence:onUnapplyCommon()
    StatusEffect.onUnapplyCommon(self)

    self.m_owner:setSilence(false)
end