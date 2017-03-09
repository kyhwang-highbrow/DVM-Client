local PARENT = SkillAoESquare

-------------------------------------
-- class SkillAoESquare_Wonder
-------------------------------------
SkillAoESquare_Wonder = class(PARENT, {

     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoESquare_Wonder:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoESquare_Wonder:init_skill(skill_width, skill_height, hit)
    PARENT.init_skill(self)

	-- 멤버 변수
    self.m_skillWidth = skill_width
	self.m_skillHeight = skill_height

	self.m_maxAttackCnt = hit 
    self.m_attackCnt = 0
    self.m_hitInterval = ONE_FRAME * 7
	self.m_multiAtkTimer = self.m_hitInterval
	
	-- 하드코딩..
	self.m_idleAniName = 'idle'

	-- 위치 설정
	self:setPosition(self.m_targetPos.x, self.m_targetPos.y)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoESquare_Wonder:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	
	local skill_width = t_skill['val_1']		-- 공격 반경 가로
	local skill_height = t_skill['val_2']		-- 공격 반경 세로
    
	local hit = t_skill['hit'] -- 공격 횟수
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoESquare_Wonder(missile_res)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill(skill_width, skill_height, hit)
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
