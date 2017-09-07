local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_ProtectionByTime
-- @breif HP있는 실드 보호막 + resist 보호막
-------------------------------------
StatusEffect_ProtectionByTime = class(PARENT, {

        })


-------------------------------------
-- function init_top
-------------------------------------
function StatusEffect_ProtectionByTime:init_top(file_name)
	-- top을 찍지 않는다
end

-------------------------------------
-- function onStart
-- @brief 해당 상태 효과가 시작시 호출
-------------------------------------
function StatusEffect_ProtectionByTime:onStart()
    self.m_owner
end