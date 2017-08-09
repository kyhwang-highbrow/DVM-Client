local PARENT = Skill

-------------------------------------
-- class SkillBind
-------------------------------------
SkillBind = class(PARENT, {
		m_statusDuration = 'num',
		m_statusName = 'str', 
        m_scale = 'number',
	})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillBind:init(file_name, body, ...)
    self.m_scale = 1
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillBind:init_skill()
	PARENT.init_skill(self)

	local struct_status_effect = self.m_lStatusEffect[1]
	self.m_statusDuration = struct_status_effect.m_duration
	self.m_statusName = struct_status_effect.m_type

	self:setPosition(self.m_targetChar.pos.x, self.m_targetChar.pos.y)

    local scale, type = self.m_targetChar:getSizeType()
    self.m_scale = self:calcScale(type, scale)
    print(self.m_scale)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillBind:initState()
	self:setCommonState(self)
    self:addState('start', SkillBind.st_appear, 'appear', false)
	self:addState('idle', SkillBind.st_idle, 'idle', true)
	self:addState('end', SkillBind.st_disappear, 'disappear', false)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillBind.st_appear(owner, dt)
	if (owner.m_stateTimer == 0) then
        owner.m_animator:setScale(owner.m_scale)
		owner.m_animator:addAniHandler(function()
			owner:changeState('idle')
			-- ����ȿ��
			owner:dispatch(CON_SKILL_HIT, {l_target = {owner.m_targetChar}})
		end)
	end
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillBind.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then
	elseif (owner.m_stateTimer > owner.m_statusDuration) then
		owner:changeState('end')

	else
		-- �ش� ����ȿ���� ���ŵǾ����� üũ
		local isExist = false
		for _, v  in pairs(owner.m_targetChar:getStatusEffectList()) do
			if (owner.m_statusName == v:getTypeName()) then 
				isExist = true
			end 
		end

		if (not isExist) then
			owner:changeState('end')
		end
	end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillBind.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function update
-------------------------------------
function SkillBind:update(dt)
	if (self.m_state ~= 'dying') then
		-- Ÿ�� ��� üũ
		if (self.m_targetChar:isDead()) then
			self:changeState('dying')
		end
	end

	-- �巡���� �ִϿ� ��ü, ��ų ��ġ ����ȭ
	self.m_targetChar:syncAniAndPhys()
	self:setPosition(self.m_targetChar.pos.x, self.m_targetChar.pos.y)

    return PARENT.update(self, dt)
end

-------------------------------------
-- function calcScale
-------------------------------------
function SkillBind:calcScale(type, scale)
    print(type, scale)
    if (type == 'monster') then
        if (scale == 'm') then
            return 1.5 --@TODO
        elseif (scale == 'l') then
            return 2 -- @TODO
        elseif (scale == 'xl') then
            return 2.5 -- @TODO
        else
            return 1  -- @TODO
        end
    else
        return scale  -- @TODO
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillBind:makeSkillInstance(owner, t_skill, t_data)
	-- ���� �����
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	  -- ���� ��ų ���ҽ�

	-- �ν��Ͻ� ������
	------------------------------------------------------
	-- 1. ��ų ����
    local skill = SkillBind(missile_res)

	-- 2. �ʱ�ȭ ���� �Լ�
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill()
	skill:initState()

	-- 3. state ���� 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr�� ���
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end