local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillMetamorphosis
-------------------------------------
SkillMetamorphosis = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillMetamorphosis:init(file_name, body, ...)
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
-- function st_idle
-------------------------------------
function SkillMetamorphosis.st_idle(owner, dt)
    local dragon = owner.m_owner

	if (owner.m_stateTimer == 0) then
        if (dragon.m_animator) then
            dragon.m_animator:changeAni('change', false)
            dragon:addAniHandler(function()
                dragon:undergoMetamorphosis(not dragon.m_bMetamorphosis)

                owner:changeState('dying')
            end)
        else
            dragon:undergoMetamorphosis(not dragon.m_bMetamorphosis)

            owner:changeState('dying')
        end
	end

    owner:setPosition(dragon.pos['x'], dragon.pos['y'])
end


-------------------------------------
-- function metamorphose
-------------------------------------
function SkillMetamorphosis:metamorphose()
    
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