local PARENT = Skill

-------------------------------------
-- class SkillHealAoERound
-------------------------------------
SkillHealAoERound = class(PARENT, {
    m_healRate = 'number',
})

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

    self.m_healRate = (self.m_powerRate / 100)
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
    self:addState('start', SkillHealAround.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillHealAround.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:runHeal()

        owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function runHeal
-------------------------------------
function SkillHealAoERound:runHeal()
    local collision = self:findCollision()

    for _, collision in ipairs(l_collision) do
        self:heal(collision)
    end

	self:doCommonAttackEffect()
end

-------------------------------------
-- function heal
-------------------------------------
function SkillHealAoERound:heal(collision)
    local target_char = collision:getTarget()

    local atk_dmg = self.m_owner:getStat('atk')
    local heal = HealCalc_M(atk_dmg) * self.m_healRate

    target_char:healAbs(self.m_owner, heal, true)

    self:onHeal(target_char)
end

-------------------------------------
-- function onHeal
-- @brief 힐(heal) 직후 호출됨
-------------------------------------
function SkillHealAoERound:onHeal(target_char)
    local bUpdateHitTargetCount = false

    -- 피격된 대상 저장
    if (not self.m_hitTargetList[target_char]) then
        self.m_hitTargetList[target_char] = true
        bUpdateHitTargetCount = true
    end

    local hit_target_count = table.count(self.m_hitTargetList)

	-- 상태효과
	local t_event = {l_target = {target_char}}
	self:dispatch(CON_SKILL_HIT, t_event)

    -- 피격된 대상수가 갱신된 경우 해당 이벤트 발동
    if (bUpdateHitTargetCount) then
        self:dispatch(CON_SKILL_HIT_TARGET .. hit_target_count, t_event)
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
