local PARENT = SkillAoESquare_Height

-------------------------------------
-- class SkillAoESquare_Wonder
-------------------------------------
SkillAoESquare_Wonder = class(PARENT, {
		m_lineCnt = 'num',		-- 줄 갯수
		m_space = 'num',		-- 간격
		m_res = 'str',			-- 리소스
		m_addAtkPower = 'num',	-- 추가 공격 데미지
		m_releaseTargetCnt = 'num',	-- 해제 타겟 수
		m_releaseDebuffCnt = 'num',	-- 해제 디버프 수
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
function SkillAoESquare_Wonder:init_skill(missile_res, line_cnt, add_atk_power, release_target, release_debuff)
    PARENT.init_skill(self, 1)

	-- 멤버 변수
	self.m_res = missile_res
	self.m_lineCnt = line_cnt
	self.m_addAtkPower = add_atk_power
	self.m_releaseTargetCnt = release_target
	self.m_releaseDebuffCnt = release_debuff
	self.m_space = g_constant:get('SKILL', 'WONDER_CLAW_SPACE')
	

	-- 화면 중앙보다 살짝 위에 위치
	local _, camera_home_pos_y = self.m_world.m_gameCamera:getHomePos()
	self:setPosition(self.m_targetPos.x, camera_home_pos_y + 300)	
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillAoESquare_Wonder:initSkillSize()
	local claw_width = g_constant:get('SKILL', 'WONDER_CLAW_WIDTH') -- 30
	self.m_resScale = claw_width/300
	self.m_skillWidth = claw_width
end

-------------------------------------
-- function enterAttack
-------------------------------------
function SkillAoESquare_Wonder:enterAttack()
	PARENT.enterAttack(self)
	local l_pos_x = SkillHelper:calculatePositionX(self.m_lineCnt, self.m_space, self.pos.x)
	local pos_y = self.pos.y

	-- 손톱날 하나 하나 이펙트 만듬
	for i, pos_x in pairs(l_pos_x) do
		local effect = self:makeEffect(self.m_res, pos_x, pos_y, 'idle')
		-- 진형에 따라 리소스를 뒤집어준다.
		if (self:isRightFormation()) then
			effect:setFlip(true)
		end
	end
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillAoESquare_Wonder:findCollision()
    local x = self.pos.x
	local y = self.pos.y	--> init_skill 단계에서 카메라 중심 좌표의 살짝 위로 설정되어있다.

    local l_target = self:getProperTargetList()
    
    local std_width = (self.m_skillWidth / 2)
	local std_height = (self.m_skillHeight / 2)

	-- 좌우로 나열하기 위해 x 좌표값 리스트를 계산한다.
	local l_pos_x = SkillHelper:calculatePositionX(self.m_lineCnt, self.m_space, x)

    local l_ret = SkillTargetFinder:findCollision_AoESquare_Multi(l_target, l_pos_x, y, std_width, std_height)

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoESquare_Wonder:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	
	local line_cnt = t_skill['hit']			-- 줄의 갯수
    local add_atk_power = t_skill['val_1']	-- 추가 공격 데미지
	local release_target = t_skill['val_2']		-- 해제 타겟 수
	local release_debuff = t_skill['val_3']		-- 해제 디버프 수
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoESquare_Wonder(nil)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill(missile_res, line_cnt, add_atk_power, release_target, release_debuff)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
