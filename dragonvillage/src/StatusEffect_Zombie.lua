local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Zombie
-- @breif HP 0 상태로 죽지 않고 일정시간 뒤 사망처리
-------------------------------------
StatusEffect_Zombie = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Zombie:init(file_name, body, ...)
end

-------------------------------------
-- function onStart
-------------------------------------
function StatusEffect_Zombie:onStart()
    self.m_owner:setZombie(true)
end 

-------------------------------------
-- function onEnd
-------------------------------------
function StatusEffect_Zombie:onEnd()
    self.m_owner:setZombie(false)
    
    -- 종료시 사망처리
    self.m_owner:doDie()
end