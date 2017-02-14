local PARENT = Skill

-------------------------------------
-- class SkillChainLightning
-------------------------------------
SkillChainLightning = class(PARENT, {
		m_lightningRes = '',
        
		m_offsetX = 'number',
        m_offsetY = 'number',

        m_tTargetList = 'List',
        m_tEffectList = 'List',

        m_physGroup = 'string',

		m_addDmgRate = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillChainLightning:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillChainLightning:init_skill(missile_res, target_count, add_damage)
	PARENT.init_skill(self)

	-- 멤버 변수 초기화
	self.m_lightningRes = missile_res
	self.m_physGroup = self.m_owner:getAttackPhysGroup()
    self.m_tTargetList = self:getTargetList(target_count)
    self.m_tEffectList = {}
	self.m_addDmgRate = (add_damage/100)
	
	-- 체인 라이트닝 기본 공격 처리
	self.m_activityCarrier:setAttackType('basic')
	self.m_bSkillHitEffect = false
end

-------------------------------------
-- function initState
-------------------------------------
function SkillChainLightning:initState()
	self:setCommonState(self)
    self:addState('start', SkillChainLightning.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillChainLightning.st_idle(owner, dt)
    local x = owner.m_owner.pos.x + owner.m_attackPosOffsetX
    local y = owner.m_owner.pos.y + owner.m_attackPosOffsetY
    owner:setPosition(x, y)

    owner:updatePos()

	if (owner.m_stateTimer == 0) then
        owner:runAttack()
    end
	-- aniHandler로 이펙트에 changeState('dying') 붙임
end

-------------------------------------
-- function getTargetList
-------------------------------------
function SkillChainLightning:getTargetList(count)
    local world = self.m_owner.m_world

    local target_type = nil
    if (self.m_physGroup == PHYS.MISSILE.HERO) then
        target_type = PHYS.ENEMY
    elseif (self.m_physGroup == PHYS.MISSILE.ENEMY) then
        target_type = PHYS.HERO
	else
		error('m_physGroup이 이상하다')
    end

    local t_target_list = {}
    local t_target_phys_list = {}

    local x = self.m_owner.pos.x
    local y = self.m_owner.pos.y

    local target = nil 
    for i=1, count do
        target = world:findTarget(target_type, x, y, t_target_phys_list)
        if target then
            table.insert(t_target_list, target)
            table.insert(t_target_phys_list, target.phys_idx)

            x = target.pos.x
            y = target.pos.y
        end
    end

    return t_target_list
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillChainLightning:runAttack()
    for i, target_char in ipairs(self.m_tTargetList) do
		-- 1번째 타겟 이후에는 데미지계수 조정
		if (i > 1) then 
			self.m_activityCarrier.m_skillCoefficient = self.m_addDmgRate
		end

        -- 공격
        self:attack(target_char)

        -- 이펙트 생성
        local effect = self:makeEffect(i, self.m_lightningRes)
        table.insert(self.m_tEffectList, effect)
    end
end

-------------------------------------
-- function makeEffect
-------------------------------------
function SkillChainLightning:makeEffect(idx, res)
    local file_name = res
    local start_ani = nil --'start_idle'
    local link_ani = nil --'bar_idle'
    local end_ani = nil --'end_idle'

    local link_effect = EffectLink(file_name, link_ani, start_ani, end_ani, 200, 200)
    link_effect.m_bRotateEndEffect = false

    if (idx == 1) then
        link_effect.m_effectNode:addAniHandler(function()
			link_effect:changeCommonAni('idle', false, function() 
				link_effect:changeCommonAni('disappear', false, function() self:changeState('dying') end)
			end)
        end)
    end

    self.m_rootNode:addChild(link_effect.m_node)

    return link_effect
end

-------------------------------------
-- function updatePos
-------------------------------------
function SkillChainLightning:updatePos()
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
function SkillChainLightning:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local target_count = t_skill['hit']
	local add_damage = t_skill['val_1']

	
	-- 인스턴스 생성부
	------------------------------------------------------	
	-- 1. 스킬 생성
    local skill = SkillChainLightning(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, target_count, add_damage)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end