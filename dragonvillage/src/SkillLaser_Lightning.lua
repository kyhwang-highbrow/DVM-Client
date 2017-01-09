local PARENT = SkillLaser

-------------------------------------
-- class SkillLaser_Lightning
-------------------------------------
SkillLaser_Lightning = class(PARENT, {
        m_lightingDmgRate = 'num', 

		m_tEffectList = 'EffectLink',
		m_tTargetList = 'Monster',
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
function SkillLaser_Lightning:init_skill(missile_res, hit, thickness, lighting_dmg)
	PARENT.init_skill(self, missile_res, hit, thickness)
	self.m_lightingDmgRate = (lighting_dmg / 100)
	self.m_tEffectList = {}
	self.m_tTargetList = {}
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
    
    owner.m_multiHitTimer = owner.m_multiHitTimer + dt
    if (owner.m_multiHitTimer >= owner.m_multiHitTime) and
        (owner.m_clearCount < owner.m_maxClearCount) then
        
		owner:clearCollisionObjectList()
        owner.m_multiHitTimer = owner.m_multiHitTimer - owner.m_multiHitTime
        owner.m_clearCount = owner.m_clearCount + 1

		owner.m_activityCarrier.m_skillCoefficient = owner.m_powerRate

        local t_collision_obj = owner:findTarget()
		owner:collisionAttack(t_collision_obj)

		owner.m_tTargetList = owner.m_world:getEnemyList()
		owner:runAttack()
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
		
		self.m_activityCarrier.m_skillCoefficient = self.m_lightingDmgRate
				
        -- 공격
        self:attack(target_char)

        -- 이펙트 생성
        local effect = self:makeEffect(i)
        table.insert(self.m_tEffectList, effect)
    end
end

-------------------------------------
-- function makeEffect
-------------------------------------
function SkillLaser_Lightning:makeEffect(idx, res)
    local file_name = 'res/missile/shot_thunder_light/shot_thunder_light.spine'
    local start_ani = 'start_idle'
    local link_ani = 'bar_idle'
    local end_ani = 'end_idle'

    local link_effect = EffectLink(file_name, link_ani, start_ani, end_ani, 200, 200)
    link_effect.m_bRotateEndEffect = false
	
    link_effect.m_startPointNode:setScale(0.15)
    link_effect.m_endPointNode:setScale(0.3)

    if (idx == 1) then
        link_effect.m_effectNode:addAniHandler(function()
			self:changeState('dying')
        end)
    end

    self.m_rootNode:addChild(link_effect.m_node)

    return link_effect
end

-------------------------------------
-- function updatePos
-------------------------------------
function SkillLaser_Lightning:updatePos()
    local x = 0
    local y = 0

    for i,v in ipairs(self.m_tTargetList) do
        local effect = self.m_tEffectList[i]
		if (nil == effect) then return end 

        -- 상대좌표 사용
        local tar_x = (v.pos.x - self.pos.x)
        local tar_y = (v.pos.y - self.pos.y)

		EffectLink_refresh(effect, x, y, tar_x, tar_y)

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
    local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	local hit = t_skill['hit']
	local thickness = t_skill['val_1']
	local lighting_dmg = t_skill['val_2']
	
	-- 인스턴스 생성부
	------------------------------------------------------	
	-- 1. 스킬 생성
    local skill = SkillLaser_Lightning(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, hit, thickness, lighting_dmg)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

    skill:refresh(true)
end
