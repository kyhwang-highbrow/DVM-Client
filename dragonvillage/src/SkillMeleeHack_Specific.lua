local PARENT = SkillMeleeHack

-------------------------------------
-- class SkillMeleeHack_Specific
-------------------------------------
SkillMeleeHack_Specific = class(PARENT, {
		m_skillId = 'num',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillMeleeHack_Specific:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillMeleeHack_Specific:init_skill(move_speed, comeback_speed, skill_id)
    PARENT.init_skill(self, move_speed, comeback_speed)
	
	-- 1. 멤버 변수
	self.m_skillId = skill_id

	-- 2. 이동 전에 상태효과 시전
	if (self.m_skillId == 210212) then -- 붐버 : 방어력 증가
		StatusEffectHelper:doStatusEffectByType(self.m_owner, self.m_statusEffectType, self.m_statusEffectValue, self.m_statusEffectRate)
	end
end

-------------------------------------
-- function attackMelee
-------------------------------------
function SkillMeleeHack_Specific:attackMelee()
    PARENT.attackMelee(self)
			
	-- 공격시에 상태 효과 시전 
	if isExistValue(self.m_skillId, 210982, 210112) and self.m_targetChar then -- 램곤 : 수면, 애플칙 : 스턴
		StatusEffectHelper:doStatusEffectByType(self.m_targetChar, self.m_statusEffectType, self.m_statusEffectValue, self.m_statusEffectRate)
	end
end

-------------------------------------
-- function release
-------------------------------------
function SkillMeleeHack_Specific:release()
	if (self.m_skillId == 210212) then -- 붐버
		StatusEffectHelper:releaseStatusEffect(self.m_owner, self.m_statusEffectType)
	end
    PARENT.release(self)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillMeleeHack_Specific:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local move_speed = t_skill['val_1'] or 1500
    local comeback_speed = t_skill['val_2'] or 1500
	local skill_id = t_skill['id']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillMeleeHack_Specific('', {0, 0, 0})

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(move_speed, comeback_speed, skill_id)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToUnitList(skill)
end