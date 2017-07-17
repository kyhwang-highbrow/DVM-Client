local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Immortal
-- @breif 일정시간동안 체력이 1이하로 내려가지 않음
-------------------------------------
StatusEffect_Immortal = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Immortal:init(file_name, body, ...)
end

-------------------------------------
-- function onStart
-------------------------------------
function StatusEffect_Immortal:onStart()
    self.m_owner:setImmortal(true)
end 

-------------------------------------
-- function onEnd
-------------------------------------
function StatusEffect_Immortal:onEnd()
    self.m_owner:setImmortal(false)
end