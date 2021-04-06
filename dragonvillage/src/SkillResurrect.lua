local PARENT = Skill

-------------------------------------
-- class SkillResurrect
-------------------------------------
SkillResurrect = class(PARENT, {
    m_effectAnimationName = 'str'
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillResurrect:init(file_name, body, ...)
    self.m_effectAnimationName = ''
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillResurrect:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_range = t_data['size']
	end
end

-------------------------------------
-- function setSkillParams
-- @brief 멤버변수 정의
-------------------------------------
function SkillResurrect:setSkillParams(owner, t_skill, t_data)
    PARENT.setSkillParams(self, owner, t_skill, t_data)

    if (t_skill and t_skill['res_1']) then
        self.m_effectAnimationName = t_skill['res_1']
    end

    if (self.m_targetChar) then
        self.m_targetChar.m_resurrect = self
    end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillResurrect:initState()
	self:setCommonState(self)
    self:addState('start', SkillResurrect.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillResurrect.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 부활
        owner:runResurrect()

		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function runResurrect
-------------------------------------
function SkillResurrect:runResurrect()
    local l_target = self:findTarget()

    for _, target in ipairs(l_target) do
        local atk_dmg = self.m_activityCarrier:getAtkDmg(target)
        local heal = HealCalc_M(atk_dmg) * self.m_activityCarrier:getPowerRate() / 100

        -- 이펙트
        self:makeEffect(target)

        target:doRevive(heal, self.m_owner, true)

        self:onHeal(target)
    end
end


-------------------------------------
-- function makeEffect
-- 이펙트가 있으면 이펙트 출력
-------------------------------------
function SkillResurrect:makeEffect(target)
    if (not target or isNullOrEmpty(self.m_effectAnimationName)) then return end

    local pos_x, pos_y = target:getPosForFormation()
    local res = self.m_effectAnimationName
    local effect = self.m_world:addInstantEffect(res, 'idle', pos_x, pos_y)
end


-------------------------------------
-- function findTarget
-------------------------------------
function SkillResurrect:findTarget()
    local l_target = {}

    if (self.m_targetChar) then
        table.insert(l_target, self.m_targetChar)
    else
        
    end

    return l_target
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillResurrect:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillResurrect(nil)

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