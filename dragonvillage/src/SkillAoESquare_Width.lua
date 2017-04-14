local PARENT = SkillAoESquare

-------------------------------------
-- class SkillAoESquare_Width
-------------------------------------
SkillAoESquare_Width = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoESquare_Width:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoESquare_Width:init_skill(hit)
    PARENT.init_skill(self, hit)

	-- X좌표값은 화면의 중심으로 세팅
    local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
	self:setPosition(cameraHomePosX + (CRITERIA_RESOLUTION_X / 2), self.m_targetPos.y)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoESquare_Width:initState()
	self:setCommonState(self)
	-- @TODO 임시로 통짜리소스 동작되도록 처리... appear, disapper애니 추가 필요
	self:addState('start', SkillAoESquare_Width.st_attack, 'idle', false)
	self:addState('disappear', SkillAoESquare_Width.st_dying, nil, nil, 10)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillAoESquare_Width:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('square_width', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_skillHeight = t_data['size']
	end
end

-------------------------------------
-- function adjustAnimator
-------------------------------------
function SkillAoESquare_Width:adjustAnimator()    
	if (not self.m_animator) then return end
	
	-- delay state 종료시 켜준다.
	self.m_animator:setVisible(false) 

	self.m_animator:setScaleY(self.m_resScale)
		    
    if (not self.m_owner.m_bLeftFormation) then
        self.m_animator:setFlip(true)
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoESquare_Width:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	
	local hit = t_skill['hit'] -- 공격 횟수
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoESquare_Width(missile_res)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill(hit)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
