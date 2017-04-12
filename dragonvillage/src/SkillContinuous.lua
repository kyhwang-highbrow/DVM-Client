local PARENT = Skill

-------------------------------------
-- class SkillContinuous
-------------------------------------
SkillContinuous = class(PARENT, {
		m_workingType = 'str',
		m_interval = 'num',
		m_effectRes = 'str',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillContinuous:init(file_name, body)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillContinuous:init_skill(interval, working_type, effect_res)
    PARENT.init_skill(self)

	-- 멤버 변수
   	self.m_interval = interval
	self.m_workingType = working_type
	self.m_effectRes = effect_res
end

-------------------------------------
-- function initState
-------------------------------------
function SkillContinuous:initState()
	self:setCommonState(self)
    self:addState('start', SkillContinuous.st_idle, nil, false)
end

-------------------------------------
-- function update
-------------------------------------
function SkillContinuous.st_idle(owner, dt)
	if (owner.m_stateTimer < owner.m_interval) then 
		return
	end

	-- 상태 효과 실행
	if (owner.m_workingType  == 'default') then
		local char_list = owner.m_owner:getFormationMgr(true):getEntireCharList()
		StatusEffectHelper:doStatusEffectByStruct(owner.m_owner, char_list, owner.m_lStatusEffect)
		
	-- 자기 자신 디버프 해제
	elseif (owner.m_workingType == 'release_debuff') then
		local char = owner.m_owner
		if StatusEffectHelper:releaseStatusEffectDebuff(char) then
			owner:makeEffect(owner.m_effectRes, char.pos.x, char.pos.y, 'center_idle')
		end
	end

	owner.m_stateTimer = 0
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillContinuous:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local effect_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)

	local interval = t_skill['val_1']
	local working_type = t_skill['val_2']
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillContinuous(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(interval, working_type, effect_res)
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