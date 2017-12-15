--local PARENT = MonsterLua_Boss
local PARENT = Monster

local STATE_HUGE_ATTACK = 1
local STATE_BABY_ATTACK = 2
local STATE_STUN_ATTACK = 3

local MAGIC_STATE_INTERVAL = {15, 1, 10}
local MAGIC_STATE_VALUE = {900, 30, 'stun;target;skill_hit;10;100;100'}
local MAGIC_STATE_SHAKE_FACTOR = {700, 100, 300}

local HUGE_EFFECT_RES = 'res/effect/skill_lightning/skill_lightning_fire.vrp'
local BABY_EFFECT_RES = 'res/effect/effect_magic_gas/effect_magic_gas.vrp'
local STUN_EFFECT_RES = 'res/effect/effect_gear_drop/effect_gear_drop.vrp'

-------------------------------------
-- class Monster_WorldOrderMachine
-------------------------------------
Monster_WorldOrderMachine = class(PARENT, {
		m_magicState = 'num',
		m_magicStateTimer = 'num',
		m_magicAtkInterval = 'num',

		m_isMagicStateChanging = 'bool',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_WorldOrderMachine:init(file_name, body, ...)
	self.m_magicState = STATE_STUN_ATTACK
	self.m_magicStateTimer = 0
	self.m_magicAtkInterval = self:getInterval()

	self.m_isMagicStateChanging = false
end

-------------------------------------
-- function initAnimatorMonster
-------------------------------------
function Monster_WorldOrderMachine:initAnimatorMonster(file_name, attr, scale, size_type)
    PARENT.initAnimatorMonster(self, file_name, attr, nil, size_type)

    self:threeWonderMagic()
end

-------------------------------------
-- function threeWonderMagic
-------------------------------------
function Monster_WorldOrderMachine:threeWonderMagic()
	if (self.m_isMagicStateChanging) then return end

    self:changeMagicState()

	-- state 관련 수치를 초기화 한다
	self.m_magicAtkInterval = self:getInterval()
	self.m_magicStateTimer = 0

    if (self.m_magicState == STATE_HUGE_ATTACK) then
        self:setMatchingSlotShader('color_', SHADER_RED)
    elseif (self.m_magicState == STATE_BABY_ATTACK) then
        self:setMatchingSlotShader('color_', SHADER_GREEN)
    elseif (self.m_magicState == STATE_STUN_ATTACK) then
        self:setMatchingSlotShader('color_', SHADER_BLUE)
    end
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
	if (self:isDead()) then return end 

	self.m_activityCarrier = self:makeAttackDamageInstance()

	local world = self.m_world
	local l_dragon = self:getOpponentList()
    local count = table.count(l_dragon)

	local state = self.m_magicState
	if (state == STATE_HUGE_ATTACK) then 
		-- activity carrier
		self.m_activityCarrier:setPowerRate(self:getValue())
		
		-- attack
        if (count == 0) then return end

		local target_char = l_dragon[math_random(1, count)]
        if (not target_char) then return end

		self:attack(target_char)
		
		-- effect
		self:makeEffect(HUGE_EFFECT_RES, target_char.pos.x, target_char.pos.y)

	elseif (state == STATE_BABY_ATTACK) then 
		-- activity carrier
		self.m_activityCarrier:setPowerRate(self:getValue())

		-- attack
		for i, target_char in pairs(l_dragon) do 
			self:attack(target_char)
		end

		-- effect
		self:makeEffect(BABY_EFFECT_RES, 320, self.m_homePosY)

	elseif (state == STATE_STUN_ATTACK) then 
		-- status effect
        if (count == 0) then return end

		local target_char = l_dragon[math_random(1, count)]
        if (not target_char) then return end

		-- effect
		local effect = self:makeEffect(STUN_EFFECT_RES, target_char.pos.x, target_char.pos.y)
		effect:addAniHandler(function() 
            local struct_status_effect = StructStatusEffect({
		        type = 'stun',
		        target_type = 'target',
                target_count = 1,
		        trigger = 'skill_hit',
		        duration = 10,
		        rate = 100,
		        value = 100
	        })

			StatusEffectHelper:doStatusEffectByStruct(self, {target_char}, {struct_status_effect})
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
-- function setDamage
-------------------------------------
function Monster_WorldOrderMachine:setDamage(attacker, defender, i_x, i_y, damage, t_info)
    PARENT.setDamage(self, attacker, defender, i_x, i_y, damage, t_info)

    if (t_info and t_info['body_key'] == 5) then
        local type = attacker.m_activityCarrier:getAttackType()
        if (attacker.m_activityCarrier:getAttackType() == 'active') then 
			self.m_isMagicStateChanging = true
			self.m_animator:changeAni('skill_1')
			self.m_animator:addAniHandler(function()
				self.m_isMagicStateChanging = false
				self:changeState('attackDelay')
				self:threeWonderMagic()
			end)
			
		end
    end
end

-------------------------------------
-- function makeEffect
-- @breif 대상에게 생성되는 추가 이펙트 생성
-------------------------------------
function Monster_WorldOrderMachine:makeEffect(res, x, y)
	-- 리소스 없을시 탈출
	if (not res) or (res == '') then return end

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
-- function changeMagicState
-------------------------------------
function Monster_WorldOrderMachine:changeMagicState()
	self.m_magicState = self.m_magicState + 1

	if (self.m_magicState > 3) then
		self.m_magicState = 1
	end
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