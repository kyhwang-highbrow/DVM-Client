local PARENT = Skill

-------------------------------------
-- class SkillChainLightning
-------------------------------------
SkillChainLightning = class(PARENT, {
		m_lightningRes = '',
        
        m_lCollisionList = 'List',  -- 공격 가능한 타겟리스트의 숫자가 공격 대상의 수
        m_tEffectList = 'List',

        m_targetCount = 'number',   -- 바디별로 공격 대상수를 처리하기 위해 추가

        m_physGroup = 'string',
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
function SkillChainLightning:init_skill(missile_res, target_count)
	PARENT.init_skill(self)

	-- 멤버 변수 초기화
	self.m_lightningRes = missile_res
	self.m_physGroup = self.m_owner:getMissilePhysGroup()
    self.m_tEffectList = {}

    local l_target = self:getProperTargetList()
    local pos_x, pos_y = self:getAttackPositionAtWorld()
    self.m_lCollisionList = SkillTargetFinder:getCollisionFromTargetList(l_target, pos_x, pos_y)

    self.m_targetCount = target_count
end

-------------------------------------
-- function initState
-------------------------------------
function SkillChainLightning:initState()
	self:setCommonState(self)
    self:addState('start', SkillChainLightning.st_idle, 'idle', true)
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
-- function runAttack
-------------------------------------
function SkillChainLightning:runAttack()
    for i, collision in ipairs(self.m_lCollisionList) do
        if (i > self.m_targetCount) then break end

        -- 공격
        self:attack(collision)

        -- 이펙트 생성
        local effect = self:makeEffect(self.m_lightningRes, i)

        table.insert(self.m_tEffectList, effect)
    end

	self:doCommonAttackEffect()
end

-------------------------------------
-- function makeEffect
-- @overriding
-------------------------------------
function SkillChainLightning:makeEffect(res, idx)
    local file_name = res
    local start_ani = nil --'start_idle'
    local link_ani = nil --'bar_idle'
    local end_ani = nil --'end_idle'

    local scale = self:getSkillScaleByStatusEffect()

    local link_effect = EffectLink(file_name, link_ani, start_ani, end_ani, 200 * scale, 200 * scale)
    link_effect.m_bRotateEndEffect = false

    if (idx == 1) then
        link_effect.m_effectNode:addAniHandler(function()
			link_effect:changeCommonAni('idle', false, function() 
				link_effect:changeCommonAni('disappear', false, function() self:changeState('dying') end)
			end)
        end)
    end

    self.m_rootNode:addChild(link_effect.m_node)

    link_effect.m_effectNode:setScaleX(scale)
    link_effect.m_startPointNode:setScale(scale)
    link_effect.m_endPointNode:setScale(scale)

    return link_effect
end

-------------------------------------
-- function updatePos
-------------------------------------
function SkillChainLightning:updatePos()
    local x = 0
    local y = 0

    for i, collision in ipairs(self.m_lCollisionList) do
        local effect = self.m_tEffectList[i]
		if (not effect) then return end 

        local target = collision:getTarget()
        local body_key = collision:getBodyKey()
        local body = target:getBody(body_key)

        -- 상대좌표 사용
        local tar_x = (target.pos.x - self.pos.x) + body.x
        local tar_y = (target.pos.y - self.pos.y) + body.y

		EffectLink_refresh(effect, x, y, tar_x, tar_y)

        x = tar_x
        y = tar_y
    end
end

-------------------------------------
-- function setTemporaryPause
-------------------------------------
function SkillChainLightning:setTemporaryPause(pause)
    if (PARENT.setTemporaryPause(self, pause)) then
        if (pause) then
            for i, effect in ipairs(self.m_tEffectList) do
                effect:setVisible(false)
            end
        else
            for i, effect in ipairs(self.m_tEffectList) do
                effect:setVisible(true)
            end
        end
        return true
    end

    return false
end

-------------------------------------
-- function makeSkillInstance
-- @param missile_res 
-------------------------------------
function SkillChainLightning:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local target_count = t_skill['target_count']
	
	-- 인스턴스 생성부
	------------------------------------------------------	
	-- 1. 스킬 생성
    local skill = SkillChainLightning(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, target_count)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end