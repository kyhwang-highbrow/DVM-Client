local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Immune
-------------------------------------
StatusEffect_Immune = class(PARENT, {
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Immune:init(file_name, body)
end

-------------------------------------
-- function init_skill
-------------------------------------
function StatusEffect_Immune:init_status(char)
	self.m_owner = char
	StatusEffectHelper:releaseStatusEffectDebuff(char)
	char:setImmune(true)
end

-------------------------------------
-- function initState
-------------------------------------
function StatusEffect_Immune:initState()
    self:addState('start', StatusEffect.st_start, 'center_start', false)
    self:addState('idle', StatusEffect.st_idle, 'center_idle', true)
    self:addState('end', StatusEffect_Immune.st_end, 'center_end', false)
	self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function st_end
-------------------------------------
function StatusEffect_Immune.st_end(owner, dt)
	if (owner.m_stateTimer == 0) then
        owner:statusEffectReset()
		owner:addAniHandler(function()
			owner.m_owner:setImmune(false)
			owner:changeState('dying')
		end)
    end
end