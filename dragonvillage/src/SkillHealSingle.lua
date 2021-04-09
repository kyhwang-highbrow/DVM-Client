local PARENT = Skill

-------------------------------------
-- class SkillHealSingle
-------------------------------------
SkillHealSingle = class(PARENT, {
		m_res = '',
	})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillHealSingle:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillHealSingle:init_skill(missile_res)
	PARENT.init_skill(self)

    -- 멤버 변수
	self.m_res = missile_res
	
	self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillHealSingle:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_range = t_data['size']
	end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillHealSingle:initState()
	self:setCommonState(self)
    self:addState('start', SkillHealSingle.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillHealSingle.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        
        if (not owner.m_owner.m_reactingInfo) then
            owner.m_owner.m_reactingInfo = {}
        end
        
        -- 죽을 애니메이션 플레이 할지?
        owner.m_owner.m_reactingInfo["is_play_die_animation"] = true

        -- 힐
        owner:runHeal()

        owner.m_animator:addAniHandler(function()

            owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function runHeal
-------------------------------------
function SkillHealSingle:runHeal()
    local l_target = self:findTarget()

    for _, target in ipairs(l_target) do
        self:heal(target, false)

        self.m_world:addInstantEffect(self.m_res, 'heal_effect', target.pos.x, target.pos.y)

        -- 나에게로부터 상대에게 가는 힐 이펙트 생성
        local effect_heal = EffectHeal(self.m_res, {0,0,0})
        effect_heal:initState()
        effect_heal:changeState('move')
        effect_heal:init_EffectHeal(self.pos.x, self.pos.y, target)

        self.m_world.m_physWorld:addObject(PHYS.EFFECT, effect_heal)

        --local worldNode = self.m_world:getMissileNode('bottom')
        local worldNode = self.m_world:getMissileNode()
        worldNode:addChild(effect_heal.m_rootNode, 0)

        self.m_world:addToUnitList(effect_heal)
    end
    
	self:doCommonAttackEffect()
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillHealSingle:findTarget()
    if (self.m_chanceType == 'active') then
        return PARENT.findTarget(self)
    else
        return self:getProperTargetList()
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillHealSingle:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillHealSingle(nil)

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