local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Recovery
-------------------------------------
StatusEffect_Recovery = class(PARENT, {
		m_healRate = '',
		m_healInterval = '',
		m_healTimer = '',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Recovery:init(file_name, body)
end

-------------------------------------
-- function init_skill
-------------------------------------
function StatusEffect_Recovery:init_recovery(char, t_status_effect)
	self.m_owner = char
	self.m_healRate = t_status_effect['dot_heal']
	self.m_healInterval = t_status_effect['val_1']
	self.m_healTimer = 0
end

-------------------------------------
-- function initState
-------------------------------------
function StatusEffect_Recovery:initState()
    self:addState('start', StatusEffect.st_start, 'center_start', false)
    self:addState('idle', StatusEffect_Recovery.st_idle, 'center_idle', true)
    self:addState('end', StatusEffect.st_end, 'center_end', false)
	self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function st_idle
-------------------------------------
function StatusEffect_Recovery.st_idle(owner, dt)
	if (owner.m_owner.m_bDead) and (owner.m_state ~= 'end') then
        owner:changeState('end')
    end
	-- 반복 공격
    owner.m_healTimer = owner.m_healTimer + dt
    if (owner.m_healTimer > owner.m_healInterval) then
        -- 힐
        owner.m_owner:healPercent(owner.m_healRate)
        owner.m_healTimer = owner.m_healTimer - owner.m_healInterval
    end
end
