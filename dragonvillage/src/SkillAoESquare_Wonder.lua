local PARENT = SkillAoESquare

-------------------------------------
-- class SkillAoESquare_Wonder
-------------------------------------
SkillAoESquare_Wonder = class(PARENT, {
		m_lineCnt = 'num',		-- 줄 갯수
		m_space = 'num',		-- 간격
		m_addAtkPower = 'num',	-- 추가 공격 데미지
		m_res = 'str',			-- 리소스
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
function SkillAoESquare_Wonder:init_skill(line_cnt, each_width, each_space, add_atk_power, missile_res)
    PARENT.init_skill(self, each_width, 2048, 1)

	-- 멤버 변수
	self.m_lineCnt = line_cnt
	self.m_space = each_space
	self.m_addAtkPower = add_atk_power
	self.m_res = missile_res
end

-------------------------------------
-- function enterAttack
-------------------------------------
function SkillAoESquare_Wonder:enterAttack()
	local l_pos_x = self:calculatePositionX()
	local pos_y = self.pos.y

	for i, pos_x in pairs(l_pos_x) do
		local effect = self:makeEffect(self.m_res, pos_x, pos_y, self.m_idleAniName)
	end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillAoESquare_Wonder:findTarget()
    local x = self.pos.x
	local y = self.pos.y

    local world = self.m_world

    local l_target = world:getTargetList(self.m_owner, x, y, self.m_findTargetType, 'x', 'distance_x')
    
    local l_ret = {}

    local std_width = (self.m_skillWidth / 2)
	local std_height = (self.m_skillHeight / 2)

	local l_pos_x = self:calculatePositionX()

    for i, v in ipairs(l_target) do
		for i, pos_x in pairs(l_pos_x) do
			if isCollision_Rect(pos_x, y, v, std_width, std_height) then
				table.insert(l_ret, v)
			end
		end
    end

    return l_ret
end

-------------------------------------
-- function calculatePositionX
-------------------------------------
function SkillAoESquare_Wonder:calculatePositionX()
    local x = self.pos.x
	local space = self.m_space
	local line_cnt = self.m_lineCnt
	
	local ret = {}
	local half = math_floor(line_cnt/2)

	-- 홀수
	if ((line_cnt % 2) == 1) then
		-- 중앙값
		table.insert(ret, x)
		-- 좌우값
		for i = 1, half do
			table.insert(ret, x + (space * i))
			table.insert(ret, x - (space * i))
		end
	-- 짝수
	else
		-- 좌우값
		for i = 1, half do
			table.insert(ret, x + (space * (i - 1 + 0.5)))
			table.insert(ret, x - (space * (i - 1 + 0.5)))
		end
	end

	return ret
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoESquare_Wonder:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	
	local line_cnt = t_skill['hit']			-- 줄의 갯수
	local each_width = t_skill['val_1']		-- 폭
	local each_space = t_skill['val_2']		-- 간격
    local add_atk_power = t_skill['val_3']	-- 추가 공격 데미지
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoESquare_Wonder(nil)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill(line_cnt, each_width, each_space, add_atk_power, missile_res)
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
