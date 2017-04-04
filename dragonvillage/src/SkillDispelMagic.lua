local PARENT = Skill

-------------------------------------
-- class SkillDispelMagic
-------------------------------------
SkillDispelMagic = class(PARENT, {
		-- t_skill에서 얻어오는 데이터
		m_healRate = '',
	})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillDispelMagic:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillDispelMagic:init_skill()
	PARENT.init_skill(self)
    -- 멤버 변수
	self.m_healRate = self.m_powerRate/100
end

-------------------------------------
-- function initState
-------------------------------------
function SkillDispelMagic:initState()
	self:setCommonState(self)
    self:addState('start', SkillDispelMagic.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillDispelMagic.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 힐
        owner.m_targetChar:healPercent(nil, owner.m_healRate, true)
		-- 상태이상 헤제
		StatusEffectHelper:releaseHarmfulStatusEffect(owner.m_targetChar)
		-- 추가 상태효과
		owner:dispatch(CON_SKILL_HIT, {l_target = {owner.m_targetChar}})

		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end

	-- 위치 동기화
	owner:setPosition(owner.m_targetChar.pos.x, owner.m_targetChar.pos.y)
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillDispelMagic:findTarget()
    return {self.m_targetChar}
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillDispelMagic:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	  -- 광역 스킬 리소스

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillDispelMagic(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill()
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
end