local PARENT = SkillAoESquare

-------------------------------------
-- class SkillHealAoESquare_Width
-------------------------------------
SkillHealAoESquare_Width = class(PARENT, {
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillHealAoESquare_Width:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillHealAoESquare_Width:init_skill(hit)
    PARENT.init_skill(self, hit)

    -- X좌표값은 화면의 중심으로 세팅
    local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
	self:setPosition(cameraHomePosX + (CRITERIA_RESOLUTION_X / 2), self.m_targetPos.y)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillHealAoESquare_Width:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('square_width', self.m_skillSize)  
        
		self.m_resScale = t_data['scale']
		self.m_skillHeight = t_data['size']
	end
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillHealAoESquare_Width:runAttack()
    self:runHeal()
end

-------------------------------------
-- function adjustAnimator
-------------------------------------
function SkillHealAoESquare_Width:adjustAnimator()    
	if (not self.m_animator) then return end
	
	-- delay state 종료시 켜준다.
	self.m_animator:setVisible(false) 
    self.m_animator:setScaleY(self.m_resScale)

    -- 스킬 애니 속성 세팅
	self.m_animator:setAniAttr(self.m_owner:getAttributeForRes())
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillHealAoESquare_Width:findCollision()
    local l_target = self:getProperTargetList()
    local x = self.pos.x
	local y = self.pos.y
	local width = (self.m_skillWidth / 2)
	local height = (self.m_skillHeight / 2)

    local l_ret = SkillTargetFinder:findCollision_AoESquare(l_target, x, y, width, height, true)

    -- x값이 작은 순으로 정렬
    if (#l_ret > 1) then
        table.sort(l_ret, function(a, b)
            return a:getPosX() < b:getPosX()
        end)
    end

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillHealAoESquare_Width:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)

	local hit = t_skill['hit'] -- 공격 횟수
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillHealAoESquare_Width(missile_res)
	
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
