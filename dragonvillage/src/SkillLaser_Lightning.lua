local PARENT = SkillLaser

-------------------------------------
-- class SkillLaser_Lightning
-------------------------------------
SkillLaser_Lightning = class(PARENT, {
		m_lightningRes = 'str',
        m_lightingDmgRate = 'num', 

		m_tEffectList = 'EffectLink',
		m_tTargetList = 'Monster',

		m_collisionNum = 'num',
		m_lightningCount = 'num',
     })

-------------------------------------
-- function initc
-- @param file_name
-- @param body
-------------------------------------
function SkillLaser_Lightning:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillLaser_Lightning:init_skill(missile_res, hit, lightning_res, lighting_dmg)
	PARENT.init_skill(self, missile_res, hit)

	-- 멤버 변수 
	self.m_lightningRes = lightning_res
	self.m_lightingDmgRate = (lighting_dmg) 
	self.m_tEffectList = {}
	self.m_tTargetList = {}

	self.m_collisionNum = 0
	self.m_lightningCount = 0
end

-------------------------------------
-- function initState
-------------------------------------
function SkillLaser_Lightning:initState()
	self:setCommonState(self)
    self:addState('start', SkillLaser_Lightning.st_idle, 'idle', true)
    self:addState('disappear', SkillLaser_Lightning.st_disappear, 'idle', true)
end


-------------------------------------
-- function st_idle
-------------------------------------
function SkillLaser_Lightning.st_idle(owner, dt)
	-- 0타임에 충돌 적 수 체크 -> 추가공격 횟수로 사용
    if (owner.m_stateTimer == 0) then
		owner.m_collisionNum = table.count(owner:findTarget())

        owner.m_owner.m_animator:changeAni('skill_disappear', false)
	end

    owner.m_multiHitTimer = owner.m_multiHitTimer + dt
    if (owner.m_multiHitTimer >= owner.m_multiHitTime) and
        (owner.m_clearCount < owner.m_maxClearCount) then
        cclog(owner.m_multiHitTimer, owner.m_multiHitTime)
		owner:clearCollisionObjectList()
        owner.m_multiHitTimer = owner.m_multiHitTimer - owner.m_multiHitTime
        owner.m_clearCount = owner.m_clearCount + 1

        local t_collision_obj = owner:findTarget()
		owner:collisionAttack(t_collision_obj)

		-- 번개고룡 궁극 뇌룡포 추가 공격, 공격 주기는 multiHitTime
		if (owner.m_collisionNum > owner.m_lightningCount) then 
			owner.m_tTargetList = owner.m_owner:getOpponentList()
            table.sortRandom(owner.m_tTargetList)
			owner:runAttack()
			owner.m_lightningCount = owner.m_lightningCount + 1
		end
    end

	owner:updatePos()
    owner:refresh()

    if ((not owner.m_owner) or owner.m_owner.m_bDead) or (owner.m_stateTimer >= owner.m_limitTime) then
        owner:changeState('disappear')
        return
    end
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillLaser_Lightning:runAttack()
    for i, target_char in ipairs(self.m_tTargetList) do
		
		self.m_activityCarrier:setPowerRate(self.m_lightingDmgRate)
		self.m_activityCarrier:setAttackType('basic')
				
        -- 공격
        self:attack(target_char)

        -- 이펙트 생성
        local effect = self:makeLightningEffect(i)
		effect.m_node:setVisible(false)
        table.insert(self.m_tEffectList, effect)
    end
end

-------------------------------------
-- function makeLightningEffect
-------------------------------------
function SkillLaser_Lightning:makeLightningEffect(idx, res)
    local file_name = self.m_lightningRes
    local start_ani = 'start_idle'
    local link_ani = 'bar_idle'
    local end_ani = 'end_idle'

    local link_effect = EffectLink(file_name, link_ani, start_ani, end_ani, 200, 200)
    link_effect.m_bRotateEndEffect = false
    self.m_rootNode:addChild(link_effect.m_node)

    return link_effect
end

-------------------------------------
-- function updatePos
-------------------------------------
function SkillLaser_Lightning:updatePos()
	local std_x = self.pos.x
	local std_y = self.pos.y

    local x = 0
    local y = 0

    for i, target in ipairs(self.m_tTargetList) do
        local effect = self.m_tEffectList[i]
		if (nil == effect) then return end 

        -- 상대좌표 사용
        local tar_x = (target.pos.x - std_x)
        local tar_y = (target.pos.y - std_y)

		-- 번개고룡으로부터 뻗어가나는 이펙트는 제외
		if not (i == 1) then 
			effect.m_node:setVisible(true)
			EffectLink_refresh(effect, x, y, tar_x, tar_y)
		end

        x = tar_x
        y = tar_y
    end
end


-------------------------------------
-- function makeSkillInstance
-- @param missile_res 
-------------------------------------
function SkillLaser_Lightning:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local lightning_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)
	local hit = t_skill['hit']
	local lighting_dmg = t_skill['val_1']
	
	-- 인스턴스 생성부
	------------------------------------------------------	
	-- 1. 스킬 생성
    local skill = SkillLaser_Lightning(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, hit, lightning_res, lighting_dmg)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

    -- 5. 하이라이트
    if (skill.m_bHighlight) then
        --world.m_gameHighlight:addMissile(skill)
    end

    skill:refresh(true)
end
