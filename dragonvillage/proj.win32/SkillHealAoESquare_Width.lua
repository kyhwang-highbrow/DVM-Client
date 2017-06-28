local PARENT = SkillAoESquare

-------------------------------------
-- class SkillHealAoESquare_Width
-------------------------------------
SkillHealAoESquare_Width = class(PARENT, {
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillHealAoESquare_Width:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillHealAoESquare_Width:init_skill(hit)
    PARENT.init_skill(self, hit)

	-- Y��ǥ�� �߽����� ����
	local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
	self:setPosition(self.m_targetPos.x, cameraHomePosY)

	-- ������ ���� ���ҽ��� �������ش�.
	if (not self.m_owner.m_bLeftFormation) then
		self.m_animator:setFlip(true)
	end	
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillHealAoESquare_Width:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('square_width', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_skillWidth = t_data['size']
	end
end

-------------------------------------
-- function runAttack
-------------------------------------
function Skill:runAttack()
    self:runHeal()
end

-------------------------------------
-- function adjustAnimator
-------------------------------------
function SkillHealAoESquare_Width:adjustAnimator()    
	if (not self.m_animator) then return end
	
	-- delay state ����� ���ش�.
	self.m_animator:setVisible(false) 
    self.m_animator:setScaleX(self.m_resScale)
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillHealAoESquare_Width:findCollision()
    local l_target = self:getProperTargetList()
    local x = self.pos.x
	local y = self.pos.y
	local width = (self.m_skillWidth / 2)
	local height = (self.m_skillHeight / 2)

    local l_ret = SkillTargetFinder:findCollision_AoESquare(l_target, x, y, width, height, true)

    -- x���� ���� ������ ����
    if (#l_ret > 1) then
        table.sort(l_ret, function(a, b)
            return a:getPosX() < b:getPosX()
        end)
    end

    -- Ÿ�� �� ��ŭ�� ����
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillHealAoESquare_Width:makeSkillInstance(owner, t_skill, t_data)
	-- ���� �����
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)

	local hit = t_skill['hit'] -- ���� Ƚ��
	
	-- �ν��Ͻ� ������
	------------------------------------------------------
	-- 1. ��ų ����
    local skill = SkillHealAoESquare_Width(missile_res)
	
	-- 2. �ʱ�ȭ ���� �Լ�
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill(hit)
	skill:initState()

	-- 3. state ���� 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr�� ���
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
