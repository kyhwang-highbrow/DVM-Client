local PARENT = Skill

-------------------------------------
-- class SkillHealLine
-------------------------------------
SkillHealLine = class(PARENT, {
		m_res = '',
        m_tEffectList = 'List',
	})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillHealLine:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillHealLine:init_skill(missile_res)
	PARENT.init_skill(self)

    -- 멤버 변수
	self.m_res = missile_res
    self.m_tEffectList = {}
end

-------------------------------------
-- function initState
-------------------------------------
function SkillHealLine:initState()
	self:setCommonState(self)
    self:addState('start', SkillHealLine.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillHealLine.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 힐
        owner:runHeal()
    end

    owner:updatePos()
end

-------------------------------------
-- function runHeal
-------------------------------------
function SkillHealLine:runHeal()
    self.m_lTargetChar = self:findTarget()

    for idx, target in ipairs(self.m_lTargetChar) do
        -- 힐
        self:heal(target, false)

        -- 이펙트 생성
        local effect = self:makeEffect(idx)
        table.insert(self.m_tEffectList, effect)
    end
    
	self:doCommonAttackEffect()
end

-------------------------------------
-- function makeEffect
-- @overriding
-------------------------------------
function SkillHealLine:makeEffect(idx)
    local link_effect = EffectLink(self.m_res, nil, nil, nil, 200, 200)
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
function SkillHealLine:updatePos()
    -- 스킬 시작 위치 갱신
    local x = self.m_owner.pos.x + self.m_attackPosOffsetX
    local y = self.m_owner.pos.y + self.m_attackPosOffsetY
    self:setPosition(x, y)

    -- 이펙트 위치 갱신
    local x = 0
    local y = 0

    for i, target in ipairs(self.m_lTargetChar) do
        local effect = self.m_tEffectList[i]
		if (not effect) then return end 

        -- 상대좌표 사용
        local tar_x = target.pos['x'] - self.pos['x']
        local tar_y = target.pos['y'] - self.pos['y']

		EffectLink_refresh(effect, x, y, tar_x , tar_y)

        x = tar_x
        y = tar_y
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillHealLine:findTarget()
    if (self.m_chanceType == 'active') then
        return PARENT.findTarget(self)
    else
        return self:getProperTargetList()
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillHealLine:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillHealLine(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end