local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillMetamorphosis
-------------------------------------
SkillMetamorphosis = class(PARENT, {
    m_bUseMetamorphosis = 'boolean',
    m_duration = 'number'
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillMetamorphosis:init(file_name, body, ...)
    self.m_bUseMetamorphosis = false
    self.m_duration = 0
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillMetamorphosis:init_skill()
    PARENT.init_skill(self)

    self.m_animator:setScale(0.4)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillMetamorphosis:initState()
	self:setCommonState(self)
    self:addState('start', SkillMetamorphosis.st_idle, 'idle', false)
end

-------------------------------------
-- function update
-------------------------------------
function SkillMetamorphosis:update(dt)
    -- 스킬 멈춤 여부 체크
    if (self.m_state ~= 'dying') then
	    if (self.m_owner:checkToStopSkill()) then
            self:changeState('dying', true)
        end
    end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillMetamorphosis.st_idle(owner, dt)
    local dragon = owner.m_owner

	if (owner.m_stateTimer == 0) then
        if (dragon.m_animator) then
            dragon.m_animator:changeAni('change', false)
            
            owner.m_duration = dragon.m_animator:getDuration()
        end

    elseif (owner.m_stateTimer > owner.m_duration) then
        owner.m_bUseMetamorphosis = true

        dragon:undergoMetamorphosis(not dragon.m_bMetamorphosis)

        if (dragon.m_animator) then
            dragon.m_animator:changeAni('idle', true)
        end

        owner:changeState('dying')
	end

    owner:setPosition(dragon.pos['x'], dragon.pos['y'])
end

-------------------------------------
-- function onDying
-- @breif Skill class에 붙을 경우 st_dying 에서 자동으로 동작
-------------------------------------
function SkillMetamorphosis:onDying()
    PARENT.onDying(self)

    -- 변신이 되기 전에 스킬이 종료될 경우 변신 처리
    if (not self.m_bUseMetamorphosis) then
        self.m_bUseMetamorphosis = true

        self.m_owner:undergoMetamorphosis(not self.m_owner.m_bMetamorphosis)
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillMetamorphosis:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local res_name = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
		
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillMetamorphosis(res_name)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill()
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode('bottom')
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end