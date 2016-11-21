local PARENT = Skill

-------------------------------------
-- class SkillSummon
-------------------------------------
SkillSummon = class(PARENT, {
		m_summonIdx = 'num',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillSummon:init(file_name, body, ...)
end

-------------------------------------
-- function init_SkillSummon
-------------------------------------
function SkillSummon:init_skill(summon_idx)
	PARENT.init_skill(self)

    self.m_summonIdx = summon_idx
end

-------------------------------------
-- function initState
-------------------------------------
function SkillSummon:initState()
	self:setCommonState(self)
    self:addState('start', SkillSummon.st_idle, 'idle', true)
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

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillSummon:makeSkillInstance(owner, t_skill, t_data)
	-- ���� �����
	------------------------------------------------------
	local summon_idx = t_skill['val_1']

    if (not owner.m_world.m_waveMgr:checkSummonable(summon_idx)) then 
        return false
    end

	-- �ν��Ͻ� ������
	------------------------------------------------------
	-- 1. ��ų ����
    local skill = SkillSummon(nil)

	-- 2. �ʱ�ȭ ���� �Լ�
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(summon_idx)
	skill:initState()

	-- 3. state ���� 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr�� ���
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

	return true
end