local PARENT = SkillAoESquare

-------------------------------------
-- class SkillAoESquare_Height_Top
-------------------------------------
SkillAoESquare_Height_Top = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoESquare_Height_Top:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoESquare_Height_Top:init_skill(hit)
    PARENT.init_skill(self, hit)

	-- Y좌표값 중심으로 세팅
	local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
	self:setPosition(self.m_targetPos.x, cameraHomePosY)

	-- @TODO 핑크벨 확인 위해 임시 처리
	if (self.m_owner.m_charTable['type'] == 'pinkbell') then
		local pos_x = cameraHomePosX + (CRITERIA_RESOLUTION_X / 2) - self.m_targetPos.x
		self.m_animator:setPositionX(pos_x)

		-- 진형에 따라 리소스를 뒤집어준다.
		if (not self.m_owner.m_bLeftFormation) then
			self.m_animator:setFlip(true)
		end	
	end
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillAoESquare_Height_Top:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('square_height', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_skillWidth = t_data['size']
	end
end

-------------------------------------
-- function adjustAnimator
-------------------------------------
function SkillAoESquare_Height_Top:adjustAnimator()    
	if (not self.m_animator) then return end
	
	-- delay state 종료시 켜준다.
	self.m_animator:setVisible(false) 

	-- @TODO 핑크벨 확인 위해 임시 처리
	if (self.m_owner.m_charTable['type'] == 'pinkbell') then
	else
		self.m_animator:setScaleX(self.m_resScale)
	end
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillAoESquare_Height_Top:findCollision()
    local l_target = self:getProperTargetList()
    local x = self.pos.x
	local y = self.pos.y
	local width = (self.m_skillWidth / 2)
	local height = (self.m_skillHeight / 2)

    local l_ret = SkillTargetFinder:findCollision_AoESquare(l_target, x, y, width, height, true)

    -- y값이 큰 순으로 정렬
    if (#l_ret > 1) then
        table.sort(l_ret, function(a, b)
            return a:getPosY() > b:getPosY()
        end)
    end

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoESquare_Height_Top:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)

	local hit = t_skill['hit'] -- 공격 횟수
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoESquare_Height_Top(missile_res)
	
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
