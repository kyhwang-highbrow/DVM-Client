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
-- function onStart
-------------------------------------
function StatusEffect_Silence:onStart()
    self.m_owner:setSilence(true)
end

-------------------------------------
-- function onEnd
-------------------------------------
function StatusEffect_Silence:onEnd()
    self.m_owner:setSilence(false)
end