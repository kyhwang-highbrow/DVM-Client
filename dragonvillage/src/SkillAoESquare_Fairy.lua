local PARENT = SkillAoESquare

-------------------------------------
-- class SkillAoESquare_Fairy
-------------------------------------
SkillAoESquare_Fairy = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoESquare_Fairy:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoESquare_Fairy:init_skill(skill_width, skill_height, hit)
    PARENT.init_skill(self, skill_width, skill_height, hit)

	-- 위치 설정
	local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
	self:setPosition(self.m_targetPos.x, cameraHomePosY) -- Y좌표값은 화면의 중심으로 세팅
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoESquare_Fairy:initState()
	self:setCommonState(self)
	self:addState('start', SkillAoESquare_Fairy.st_appear, 'appear', false)
    self:addState('attack', SkillAoESquare_Fairy.st_attack, self.m_idleAniName, true)
	self:addState('disappear', SkillAoESquare_Fairy.st_disappear, 'disappear', false)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillAoESquare_Fairy.st_appear(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner.m_animator:addAniHandler(function()
			owner:changeState('attack')
		end)
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillAoESquare_Fairy.st_attack(owner, dt)
	if (owner.m_stateTimer == 0) then
		owner:runAttack()
		owner:doFairySideEffect()
		owner.m_animator:addAniHandler(function()
			owner:changeState('disappear')
		end)
	end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillAoESquare_Fairy.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end


-------------------------------------
-- function doFairySideEffect
-------------------------------------
function SkillAoESquare_Fairy:doFairySideEffect()
	-- 적을 맞출 횟수
	local release_cnt = #(self:findTarget())

	-- 동료 리스트
	local l_fellow = table.sortRandom(self.m_owner:getFellowList())

	-- 해제
	for i = 1, release_cnt do 
		for _, fellow in pairs(l_fellow) do 
			if StatusEffectHelper:releaseHarmfulStatusEffect(fellow) then 
				-- 로직화 할수 없는것들은 별도로 테이블에 담고 처리 하는것도 괜찮을것같다
				table.insert(self.m_tSpecialTarget, fellow)
				break
			end
		end
	end

end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoESquare_Fairy:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	
	local skill_width = t_skill['val_1']		-- 공격 반경 가로
	local skill_height = t_skill['val_2']		-- 공격 반경 세로
    
	local hit = t_skill['hit'] -- 공격 횟수
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoESquare_Fairy(missile_res)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill(skill_width, skill_height, hit)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
