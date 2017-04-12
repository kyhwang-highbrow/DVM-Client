local PARENT = StatusEffect
 
-------------------------------------
-- class StatusEffect_AddDmg
-------------------------------------
StatusEffect_AddDmg = class(PARENT, {
		m_targetStatusEffectType = 'str',
		m_activityCarrier = 'ActivityCarrier',

		m_isSatisfy = 'bool',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_AddDmg:init(file_name, body)
	self:initState()
end

-------------------------------------
-- function init_dotDmg
-------------------------------------
function StatusEffect_AddDmg:init_statusEffect(char, condition, power_rate, caster)
	self.m_owner = char
	self.m_isSatisfy = false
	self.m_targetStatusEffectType = condition
	self.m_activityCarrier = caster:makeAttackDamageInstance()
	self.m_activityCarrier:setPowerRate(power_rate)
	self.m_activityCarrier:setFlag('add_dmg', true)

	self:checkCondition()
end

-------------------------------------
-- function initState
-------------------------------------
function StatusEffect_AddDmg:initState()
    self:addState('start', StatusEffect_AddDmg.st_start, 'center_start', false)
    self:addState('idle', StatusEffect_AddDmg.st_idle, 'center_idle', false)
    self:addState('end', StatusEffect_AddDmg.st_end, 'center_end', false)
	self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function st_idle
-------------------------------------
function StatusEffect_AddDmg.st_idle(owner, dt)
    if (owner.m_stateTimer > 0.3) then
		if (owner:checkCondition()) then
			owner:doAddDamage()
		end
		owner:changeState('end')
    end
end

-------------------------------------
-- function checkCondition
-------------------------------------
function StatusEffect_AddDmg:checkCondition()
	local is_add_damage = false
	for type, status_effect in pairs(self.m_owner:getStatusEffectList()) do
		if (type == self.m_targetStatusEffectType) then
			is_add_damage = true
			break
		end
	end

	self.m_isSatisfy = is_add_damage
	return is_add_damage
end

-------------------------------------
-- function doAddDamage
-------------------------------------
function StatusEffect_AddDmg:doAddDamage()
    self.m_owner:runDefCallback(self, self.m_owner.pos.x, self.m_owner.pos.y)
end
