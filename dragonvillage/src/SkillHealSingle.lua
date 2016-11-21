local PARENT = Skill

-------------------------------------
-- class SkillHealSingle
-------------------------------------
SkillHealSingle = class(PARENT, {
		m_res = '',
		m_healRate = '',
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
	self.m_healRate = self.m_powerRate/100
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
		-- 힐
        owner:doHeal()

		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end

	-- 위치 동기화
	owner:setPosition(owner.m_targetChar.pos.x, owner.m_targetChar.pos.y)
end

-------------------------------------
-- function getDefaultTarget
-- @brief 디폴트 타겟을 반환한다.
-------------------------------------
function SkillHealSingle:getDefaultTarget()
	-- 타겟 설정
	local formation_mgr = nil
	local world = self.m_owner.m_world
	if self.m_owner.m_bLeftFormation then
		formation_mgr = world.m_leftFormationMgr
	else
		formation_mgr = world.m_rightFormationMgr
	end
	return formation_mgr:getRandomHealTarget()
end

-------------------------------------
-- function doHeal
-------------------------------------
function SkillHealSingle:doHeal()
	local target = self.m_targetChar
    -- 타겟에 회복 수행, 이팩트 생성
    if target and (not target.m_bDead) then
        local atk_dmg = self.m_owner.m_statusCalc:getFinalStat('atk')
        local heal = HealCalc_M(atk_dmg)

        local effect = self.m_world:addInstantEffect(self.m_res, 'heal_effect', target.pos.x, target.pos.y)

        target:healAbs(heal * self.m_healRate)

        local effect_heal = EffectHeal(self.m_res, {0,0,0})
        effect_heal:initState()
        effect_heal:changeState('move')
        effect_heal:init_EffectHeal(self.pos.x, self.pos.y, target)

        self.m_world.m_physWorld:addObject('effect', effect_heal)
        self.m_world.m_worldNode:addChild(effect_heal.m_rootNode, 0)
        self.m_world:addToUnitList(effect_heal)
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillHealSingle:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())

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
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end