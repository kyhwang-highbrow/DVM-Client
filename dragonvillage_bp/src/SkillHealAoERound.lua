local PARENT = Skill

-------------------------------------
-- class SkillHealAoERound
-------------------------------------
SkillHealAoERound = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillHealAoERound:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillHealAoERound:init_skill()
	PARENT.init_skill(self)

    self:setPosition(self.m_targetPos.x, self.m_targetPos.y)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillHealAoERound:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', self.m_skillSize)  

		--self.m_resScale = t_data['scale']
		self.m_range = t_data['size']
	end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillHealAoERound:initState()
	self:setCommonState(self)
    self:addState('start', SkillHealAoERound.st_idle, 'idle', false)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillHealAoERound.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:runHeal()

        owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillHealAoERound:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	-- 스킬 본연의 리소스

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillHealAoERound(missile_res)

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
end
