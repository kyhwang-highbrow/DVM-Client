local PARENT = MonsterLua_Boss

local STATE_HUGE_ATTACK = 1
local STATE_BABY_ATTACK = 2
local STATE_STUN_ATTACK = 3

local MAGIC_STATE_INTERVAL = {15, 1, 10}
local MAGIC_STATE_VALUE = {450, 6, 'stun;target;10;100;100'}
local MAGIC_STATE_SHAKE_FACTOR = {700, 100, 300}

local WORLD_ORDER_RES = 'res/character/monster/boss_world_order_machine_light/boss_world_order_machine_light_'

local HUGE_EFFECT_RES = 'res/effect/skill_lightning/skill_lightning_fire.vrp'
local BABY_EFFECT_RES = 'res/effect/effect_magic_gas/effect_magic_gas.vrp'
local STUN_EFFECT_RES = 'res/effect/effect_gear_drop/effect_gear_drop.vrp'

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
	-- 추가 object 추가
	local add_body = {0, 0, 50}
	local phys_obj = self:addPhysObject(self, add_body, -220, -220, nil)
	
    -- 피격 처리
    phys_obj:addDefCallback(function(attacker, defender, i_x, i_y)
		if (attacker.m_activityCarrier:getAttackType() == 'active') then 
			self:threeWonderMagic()
		end
    end)

	-- 추가 object formation 등록
	local formation_mgr = self:getFormationMgr()
	local formation = formation_mgr:getFormation(self.pos.x, self.pos.y) 
	formation_mgr:setChangePosCallback(phys_obj, formation)

	-- 추가 object 일반 타겟 예외 처리
	-- -- Character class 에서 복사해올때 임시로 처리

	-- 갈아끼울 이미지 리스트 생성
	self:setAnimationList()
end

-------------------------------------
-- function setAnimationList
-------------------------------------
function Monster_WorldOrderMachine:setAnimationList()
	-- 속성 가져옴
	local attr = self:getAttribute()

	-- ani 리스트 생성
	local ani = nil
	for i = 1, 3 do 
		if (i == 1) then 
			ani = self.m_animator
		else
			ani = AnimatorHelper:makeMonsterAnimator(WORLD_ORDER_RES .. i .. '.spine', attr)
			ani:setFlip(true)
			ani:setVisible(false)
		end
		
		table.insert(self.m_lAnimator, ani)

		-- 생성후 유지되도록 ref_cnt retain 해준다
		ani.m_node:retain()
	end
end

-------------------------------------
-- function threeWonderMagic
-------------------------------------
function Monster_WorldOrderMachine:threeWonderMagic()
	-- 현재 animation은 떼어놓는다
	if self.m_animator then 
		self.m_animator.m_node:removeFromParent(true)
		self.m_animator:setVisible(false)
	end

	-- 다음 state의 animation을 박는다
	self.m_animator = self.m_lAnimator[self:getMagicState()]
	self.m_animator:setVisible(true)
	if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node)
    end

	-- state 관련 수치를 초기화 한다
	self.m_magicAtkInterval = self:getInterval()
	self.m_magicStateTimer = 0

	-- 각종 쉐이더 효과 시 예외 처리할 슬롯 설정(Spine)
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
	if (self.m_bDead) then return end 

	self.m_activityCarrier = self:makeAttackDamageInstance()

	local world = self.m_world
	local l_dragon = world.m_participants

	local state = self.m_magicState
	if (state == STATE_HUGE_ATTACK) then 
		-- activity carrier
		self.m_activityCarrier.m_skillCoefficient = (self:getValue() / 100)
		
		-- attack
		local target_char = l_dragon[math_random(1, table.count(l_dragon))]
		self:attack(target_char)
		
		-- effect
		self:makeEffect(HUGE_EFFECT_RES, target_char.pos.x, target_char.pos.y)

	elseif (state == STATE_BABY_ATTACK) then 
		-- activity carrier
		self.m_activityCarrier.m_skillCoefficient = (self:getValue() / 100)

		-- attack
		for i, target_char in pairs(l_dragon) do 
			self:attack(target_char)
		end

		-- effect
		self:makeEffect(BABY_EFFECT_RES, 320, self.m_homePosY)

	elseif (state == STATE_STUN_ATTACK) then 
		-- status effect
		local target_char = l_dragon[math_random(1, table.count(l_dragon))]

		-- effect
		local effect = self:makeEffect(STUN_EFFECT_RES, target_char.pos.x, target_char.pos.y)
		effect:addAniHandler(function() 
			StatusEffectHelper:doStatusEffectByStr(self, {target_char}, {self:getValue()})
			effect.m_node:runAction(cc.RemoveSelf:create())
		end)
	end
			
	-- shake
	local shake_factor = self:getShakeFactor()
	world.m_shakeMgr:shakeBySpeed(math_random(355-20, 355+20), math_random(shake_factor, shake_factor*3))
end

-------------------------------------
-- function attack
-------------------------------------
function Monster_WorldOrderMachine:attack(target_char)
    -- 공격
    self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
    target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)
end

-------------------------------------
-- function makeEffect
-- @breif 대상에게 생성되는 추가 이펙트 생성
-------------------------------------
function Monster_WorldOrderMachine:makeEffect(res, x, y)
	-- 리소스 없을시 탈출
	if (not res) or (res == 'x') then return end

    -- 이팩트 생성
    local effect = MakeAnimator(res)
    effect:setPosition(x, y)
	effect:changeAni('effect', false)

    self.m_world.m_missiledNode:addChild(effect.m_node, 0)
	effect:addAniHandler(function() 
		effect.m_node:runAction(cc.RemoveSelf:create())
	end)

	return effect
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
-- function getShakeFactor
-------------------------------------
function Monster_WorldOrderMachine:getShakeFactor()
	return MAGIC_STATE_SHAKE_FACTOR[self.m_magicState]
end

-------------------------------------
-- function release
-------------------------------------
function Monster_WorldOrderMachine:release()
	for i, ani in pairs(self.m_lAnimator) do
		ani:release()
	end
    PARENT.release(self)
end