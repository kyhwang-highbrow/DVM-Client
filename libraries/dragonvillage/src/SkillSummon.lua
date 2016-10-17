-------------------------------------
-- class SkillSummon
-------------------------------------
SkillSummon = class(Entity, {
        m_owner = 'Character',
		m_summonIdx = 'num',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillSummon:init(file_name, body, ...)
    self:initState()
end

-------------------------------------
-- function init_SkillSummon
-------------------------------------
function SkillSummon:init_skill(owner, t_skill)
    self.m_owner = owner
    self.m_summonIdx = t_skill['val_1']
    self:changeState('idle')
end

-------------------------------------
-- function initState
-------------------------------------
function SkillSummon:initState()
    self:addState('idle', SkillSummon.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillSummon.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_world.m_waveMgr:summonWave(owner.m_summonIdx)
    else
        owner:changeState('dying')
    end
end
