local PARENT = Skill

-------------------------------------
-- class SkillGuardian
-------------------------------------
SkillGuardian = class(PARENT, {
        m_duration = 'num',
		m_res = 'str'
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillGuardian:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillGuardian:init_skill(duration, res)
	PARENT.init_skill(self)

	-- 멤버 변수
	self.m_duration = duration
	self.m_res = res
end

-------------------------------------
-- function initState
-------------------------------------
function SkillGuardian:initState()
	self:setCommonState(self)
    self:addState('start', SkillGuardian.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillGuardian.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 수호
        local buff = Buff_Guardian()

        local worldNode = owner.m_world:getMissileNode('bottom', owner.m_bHighlight)
        worldNode:addChild(buff.m_rootNode, 10)

        owner.m_world:addToUnitList(buff)
        buff:init_buff(owner.m_owner, owner.m_duration, owner.m_targetChar, owner.m_res)

        -- 하이라이트
        if (owner.m_bHighlight) then
            --owner.m_world.m_gameHighlight:addMissile(buff)
        end
	
		-- 상태효과
        owner:doStatusEffect({
            STATUS_EFFECT_CON__SKILL_HIT,
            STATUS_EFFECT_CON__SKILL_HIT_CRI
        }, {owner.m_targetChar})

        owner:changeState('dying')
        return
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillGuardian:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local duration = t_skill['val_1']
    local def_up_rate = t_skill['val_2']
	local res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillGuardian(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(duration, def_up_rate, res)
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