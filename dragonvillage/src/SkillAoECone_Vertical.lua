local PARENT = SkillAoECone

-------------------------------------
-- class SkillAoECone_Vertical
-------------------------------------
SkillAoECone_Vertical = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoECone_Vertical:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoECone_Vertical:init_skill(attack_count, range, angle)
    PARENT.init_skill(self, attack_count, range, angle)

	-- 멤버 변수
	self.m_dir = 90

	-- 위치 설정
	self:setPosition(self.m_targetPos.x, self.m_targetPos.y)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoECone_Vertical:initState()
	self:setCommonState(self)
    self:addState('start', SkillAoECone_Vertical.st_appear, 'appear', false)
    self:addState('attack', SkillAoECone_Vertical.st_idle, 'idle_'..self.m_angle, true)
	self:addState('disappear', SkillAoECone_Vertical.st_disappear, 'disappear', false)
end

-------------------------------------
-- function initConeAnimator
-------------------------------------
function SkillAoECone:initConeAnimator()
	-- NOTHING TO DO
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillAoECone_Vertical.st_appear(owner, dt)
    if (owner.m_stateTimer == 0) then
		if (not owner.m_targetChar) then 
			owner:changeState('dying') 
		end
		owner.m_animator:addAniHandler(function()
			owner:changeState('attack')
		end)
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillAoECone_Vertical.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function escapeAttack
-- @brief 공격이 종료되는 시점에 실행
-------------------------------------
function SkillAoECone:escapeAttack()
	self:changeState('disappear')
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoECone_Vertical:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local attack_count = t_skill['hit']
    local range = t_skill['val_1']
	local angle = t_skill['val_2']
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoECone_Vertical(missile_res)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count, range, angle)
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
        world.m_gameHighlight:addMissile(skill)
    end
end
