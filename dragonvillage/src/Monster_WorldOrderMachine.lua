local PARENT = MonsterLua_Boss

local STATE_HUGE_ATTACK = 1
local STATE_BABY_ATTACK = 2
local STATE_STUN_ATTACK = 3

local MAGIC_STATE_INTERVAL = {10, 1, 5}
local MAGIC_STATE_VALUE = {300, 6, 'stun;target;10;100;100'}

-------------------------------------
-- class Monster_WorldOrderMachine
-------------------------------------
Monster_WorldOrderMachine = class(PARENT, {
		m_lAnimator = 'list',

		m_magicState = 'num',
		m_magicStateTimer = 'num',
		m_magicAtkInterval = 'num',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_WorldOrderMachine:init(file_name, body, ...)
	self.m_lAnimator = {}
	self.m_magicState = STATE_HUGE_ATTACK
	self.m_magicStateTimer = 0
	self.m_magicAtkInterval = self:getInterval()
end

-------------------------------------
-- function setAddPhysObject
-------------------------------------
function Monster_WorldOrderMachine:setAddPhysObject()
	-- �߰� object �߰�
	local add_body = {0, 0, 50}
	local phys_obj = self:addPhysObject(self, add_body, -220, -220, nil)
	
    -- �ǰ� ó��
    phys_obj:addDefCallback(function(attacker, defender, i_x, i_y)
		if (attacker.m_activityCarrier:getAttackType() == 'active') then 
			self:threeWonderMagic()
		end
    end)

	-- �߰� object formation ���
	local formation_mgr = self:getFormationMgr()
	local formation = formation_mgr:getFormation(self.pos.x, self.pos.y) 
	formation_mgr:setChangePosCallback(phys_obj, formation)

	-- �߰� object �Ϲ� Ÿ�� ���� ó��

	-- ���Ƴ��� �̹��� ����Ʈ ����
	self:setAnimationList()
end

-------------------------------------
-- function setAnimationList
-------------------------------------
function Monster_WorldOrderMachine:setAnimationList()
	-- �Ӽ� ������
	local attr = self:getAttribute()

	-- ani ����Ʈ ����
	local ani = nil
	for i = 1, 3 do 
		ani = AnimatorHelper:makeMonsterAnimator('res/character/monster/boss_world_order_machine_light/boss_world_order_machine_light_' .. i .. '.spine', attr)
		ani:setFlip(true)
		ani:setVisible(false)
		ani.m_node:retain()
		table.insert(self.m_lAnimator, ani)
	end
end

-------------------------------------
-- function threeWonderMagic
-------------------------------------
function Monster_WorldOrderMachine:threeWonderMagic()
	self.m_animator.m_node:retain() 
	self.m_animator.m_node:removeFromParent(true)
	self.m_animator:setVisible(false)

	self.m_animator = self.m_lAnimator[self:getMagicState()]
	self.m_animator:setVisible(true)
	if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node)
    end

	self.m_magicAtkInterval = self:getInterval()
	self.m_magicStateTimer = 0

	-- ���� ���̴� ȿ�� �� ���� ó���� ���� ����(Spine)
    self:blockMatchingSlotShader('effect_')
end

-------------------------------------
-- function update
-------------------------------------
function Monster_WorldOrderMachine:update(dt)
	self.m_magicStateTimer = self.m_magicStateTimer + dt
	
	if (self.m_magicStateTimer > self.m_magicAtkInterval) then
		self.m_magicStateTimer = self.m_magicStateTimer - self.m_magicAtkInterval
		self:doMagicAttack()
	end

	return PARENT.update(self, dt)
end

-------------------------------------
-- function doMagicAttack
-------------------------------------
function Monster_WorldOrderMachine:doMagicAttack()
	self.m_activityCarrier = self:makeAttackDamageInstance()

	local l_dragon = self.m_world.m_participants

	local state = self.m_magicState
	if (state == STATE_HUGE_ATTACK) then 
		self.m_activityCarrier.m_skillCoefficient = (self:getValue() / 100)
		local target_char = l_dragon[math_random(1, table.count(l_dragon))]
		self:attack(target_char)

	elseif (state == STATE_BABY_ATTACK) then 
		self.m_activityCarrier.m_skillCoefficient = (self:getValue() / 100)
		for i, target_char in pairs(l_dragon) do 
			self:attack(target_char)
		end

	elseif (state == STATE_STUN_ATTACK) then 
		local target_char = l_dragon[math_random(1, table.count(l_dragon))]
		StatusEffectHelper:doStatusEffectByStr(self.m_owner, {target_char}, self:getValue())

	end
end

-------------------------------------
-- function attack
-------------------------------------
function Monster_WorldOrderMachine:attack(target_char)
    -- ����
    self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
    target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)
end

-------------------------------------
-- function getMagicState
-------------------------------------
function Monster_WorldOrderMachine:getMagicState()
	self.m_magicState = self.m_magicState + 1

	if (self.m_magicState > 3) then
		self.m_magicState = 1
	end

	return self.m_magicState
end

-------------------------------------
-- function getInterval
-------------------------------------
function Monster_WorldOrderMachine:getInterval()
	return MAGIC_STATE_INTERVAL[self.m_magicState]
end

-------------------------------------
-- function getValue
-------------------------------------
function Monster_WorldOrderMachine:getValue()
	return MAGIC_STATE_VALUE[self.m_magicState]
end

-------------------------------------
-- function release
-------------------------------------
function Monster_WorldOrderMachine:release()
	-- reference count ����
	for i, ani in paisr(self.m_lAnimator) do
		ani.m_node:release()
	end

    PARENT.release(self)
end