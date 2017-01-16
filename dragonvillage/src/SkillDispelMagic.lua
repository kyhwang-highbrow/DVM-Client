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
        owner.m_targetChar:healPercent(owner.m_healRate)
		-- 상태이상 헤제
		StatusEffectHelper:releaseHarmfulStatusEffect(owner.m_targetChar)
		-- 추가 버프 
		--StatusEffectHelper:doStatusEffectByStr(owner.m_owner, {owner.m_targetChar}, owner.m_lStatusEffectStr)
        owner:doStatusEffect({ STATUS_EFFECT_CON__SKILL_HIT }, {owner.m_targetChar})
		
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
function SkillDispelMagic:findTarget(x, y, range)
    return {self.m_targetChar}
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillDispelMagic:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())	  -- 광역 스킬 리소스

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
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end