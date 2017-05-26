local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Dispell
-- @breif 디버프 해제
-------------------------------------
StatusEffect_Dispell = class(PARENT, {
		m_dispellType = 'str',
		m_releaseCnt = 'number', 
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Dispell:init(file_name, body, ...)
end

-------------------------------------
-- function init_status
-------------------------------------
function StatusEffect_Dispell:init_status(status_effect_type, status_effect_value)
	self.m_dispellType = status_effect_type
	self.m_releaseCnt = status_effect_value
end

-------------------------------------
-- function initState
-------------------------------------
function StatusEffect_Dispell:initState()
    PARENT.initState(self)

    self:addState('idle', StatusEffect_Dispell.st_idle, 'center_idle', false)
end

-------------------------------------
-- function st_idle
-------------------------------------
function StatusEffect_Dispell.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 디스펠 시전
		if (owner.m_dispellType == 'cure') then
			owner:dispellDebuff()
		elseif (owner.m_dispellType == 'remove') then
			owner:dispellBuff()
		elseif (owner.m_dispellType == 'invalid') then
			owner:dispellAll()
		end

		-- 애니 1회 동작후 종료
		owner.m_animator:addAniHandler(function()
			owner:changeState('end')
		end)
    end
end

-------------------------------------
-- function dispellDebuff
-- @brief 디버프 해제
-------------------------------------
function StatusEffect_Dispell:dispellDebuff()
	StatusEffectHelper:releaseStatusEffectDebuff(self.m_owner, self.m_releaseCnt)
end

-------------------------------------
-- function dispellBuff
-- @brief 버프 해제
-------------------------------------
function StatusEffect_Dispell:dispellBuff()
	StatusEffectHelper:releaseStatusEffectBuff(self.m_owner, self.m_releaseCnt)
end

-------------------------------------
-- function dispellAll
-- @brief 전부 해제, 버프 숫자도 제한이 없다.
-------------------------------------
function StatusEffect_Dispell:dispellAll()
	StatusEffectHelper:releaseStatusEffectAll(self.m_owner)
end
