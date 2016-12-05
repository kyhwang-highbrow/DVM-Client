local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_PassiveSpatter
-------------------------------------
StatusEffect_PassiveSpatter = class(PARENT, {
		m_spatterTriggerName = '',
		m_preActedTime = '',
		m_preState = '',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_PassiveSpatter:init(file_name, body)
	self.m_preActedTime = 0
	self.m_preState = ''
end

-------------------------------------
-- function onTrigger
-------------------------------------
function StatusEffect_PassiveSpatter:onTrigger()
    local owner = self.m_owner

	if (self.m_preActedTime == 0) then
		local t_skill = self.m_subData
		self.m_preActedTime = self.m_stateTimer
		SkillSpatter:makeSkillInstance(owner, t_skill)

	elseif (self.m_stateTimer > self.m_preActedTime + STATUEEFFECT_GLOBAL_COOL) then
		local t_skill = self.m_subData
		self.m_preActedTime = self.m_stateTimer
		SkillSpatter:makeSkillInstance(owner, t_skill)
	end
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffect_PassiveSpatter:update(dt)
	self.m_stateTimer = self.m_stateTimer + dt
end