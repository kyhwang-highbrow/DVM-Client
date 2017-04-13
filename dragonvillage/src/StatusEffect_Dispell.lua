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
    self:addState('start', StatusEffect_Dispell.st_start, 'center_start', false)
    self:addState('idle', StatusEffect_Dispell.st_idle, 'center_idle', true)
    self:addState('end', StatusEffect_Dispell.st_end, 'center_end', false)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function st_idle
-------------------------------------
function StatusEffect_Dispell.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		if (owner.m_dispellType == 'cure') then
			owner:dispellDebuff()
		elseif (owner.m_dispellType == 'remove') then
			owner:dispellBuff()
		elseif (owner.m_dispellType == 'invalid') then
			owner:dispellAll()
		end
    end
end

-------------------------------------
-- function dispellDebuff
-------------------------------------
function StatusEffect_Dispell:dispellDebuff()
	StatusEffectHelper:releaseStatusEffectDebuff(self.m_owner, self.m_releaseCnt)
end

-------------------------------------
-- function dispellBuff
-------------------------------------
function StatusEffect_Dispell:dispellBuff()
	StatusEffectHelper:releaseStatusEffectBuff(self.m_owner, self.m_releaseCnt)
end

-------------------------------------
-- function dispellAll
-------------------------------------
function StatusEffect_Dispell:dispellAll()
	StatusEffectHelper:releaseStatusEffectAll(self.m_owner, self.m_releaseCnt)
end
