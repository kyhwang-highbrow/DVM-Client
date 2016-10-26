local PARENT = SkillConicAtk

-------------------------------------
-- class SkillConicAtk_Spread
-------------------------------------
SkillConicAtk_Spread = class(PARENT, {
	m_speardCnt = 'num',
	m_isSpread = 'bool',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillConicAtk_Spread:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillConicAtk_Spread:init_skill(attack_count, range, isSpread)
    PARENT.init_skill(self, attack_count, range)
	
	self.m_speardCnt = 0
	self.m_isSpread = isSpread == 0

	if (self.m_skillType == 'skill_breath_gust') then 
		-- @TODO 허리케인 하드코딩... 나중에는 리소스 자체에서 스케일을 주는거로 하자
		self.m_animator.m_node:setScale(self.m_range/800)
	end
end

-------------------------------------
-- function attack
-------------------------------------
function SkillConicAtk_Spread:attack()
    local t_targets = self:findTarget(self.m_owner.pos.x, self.m_owner.pos.y, self.m_range, self.m_degree)

    for i, target_char in ipairs(t_targets) do
        -- 공격
        self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
        target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)
		
		-- @TODO 공격에 묻어나는 이펙트 Carrier 에 담아서..
		StatusEffectHelper:doStatusEffectByType(target_char, self.m_statusEffectType, self.m_statusEffectRate)

		if (self.m_skillType == 'skill_breath_gust') then 
			-- @TODO 허리케인 하드코딩... 화상 번짐
			if (self.m_speardCnt == 0) then
				self:spreadStatusEffect(target_char, 'burn', 225)
			end
		end
    end
	self.m_speardCnt = 1
end

-------------------------------------
-- function spreadStatusEffect
-- @brief 특정 상태이상을 전이... 시킨다
-------------------------------------
function SkillConicAtk_Spread:spreadStatusEffect(target_char, status_effect_type, range)
	
	-- 1. 공격 대상의 상태 효과 검색
	if (target_char:getStatusEffectList()[status_effect_type]) then 
		-- 2. 대상 상태 효과가 있다면 원형 범위의 주의 적에게 
		local world = self.m_world
		local l_target = self:findSpreadTarget(target_char.pos.x, target_char.pos.y, range)

		-- 3. 범위 지정 연출
		local effect1 = MakeAnimator('res/effect/effect_burn/effect_burn.vrp')
		effect1:changeAni('spred', false)
		world.m_missiledNode:addChild(effect1.m_node, 0)
		effect1:setPosition(target_char.pos.x, target_char.pos.y)
		effect1:addAniHandler(function() 
			local duration = effect1.m_node:getDuration()
			effect1.m_node:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))
				
			for _, target in pairs(l_target) do 
				if (target_char.phys_idx ~= target.phys_idx) then 
					-- 4. 같은 상태효과를 적용 시킨다.
					local rate = 100
					StatusEffectHelper:doStatusEffectByType(target, status_effect_type, rate)
				end
			end
		end)
				
	end
end

-------------------------------------
-- function findSpreadTarget
-- @brief 원형 충돌 체크 -- 화염 전이 대상을 찾음
-------------------------------------
function SkillConicAtk_Spread:findSpreadTarget(x, y, range)
	local x = x or self.m_targetPos.x
	local y = y or self.m_targetPos.y
	local range = range or self.m_range

    local world = self.m_world
	local l_target = world:getTargetList(self.m_owner, x, y, 'enemy', 'x', 'distance_line')
    
	local l_ret = {}
    local distance = 0

    for _, target in pairs(l_target) do
		-- 바디사이즈를 감안한 충돌 체크
		if isCollision(x, y, target, range) then 
			table.insert(l_ret, target)
		end
    end
    
    return l_ret
end

-------------------------------------
-- function makeSkillInstnce
-------------------------------------
function SkillConicAtk_Spread:makeSkillInstnce(owner, missile_res, power_rate, target_type, status_effect_type, status_effect_rate, skill_type, tar_x, tar_y, target, attack_count, range, isSpread)
	-- 1. 스킬 생성
    local skill = SkillConicAtk_Spread(missile_res)

	-- 2. 초기화 관련 함수
	skill:setParams(owner, power_rate, target_type, status_effect_type, status_effect_rate, skill_type, tar_x, tar_y, target)
    skill:init_skill(attack_count, range, isSpread)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('idle')

    -- 4. Physics, Node, GameMgr에 등록
    local world = owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToUnitList(skill)
end

-------------------------------------
-- function makeSkillInstnceFromSkill
-------------------------------------
function SkillConicAtk_Spread:makeSkillInstnceFromSkill(owner, t_skill, t_data)
    local owner = owner

	-- 1. 공통 변수
	local power_rate = t_skill['power_rate']
	local target_type = t_skill['target_type']
	local status_effect_type = t_skill['status_effect_type']
	local status_effect_rate = t_skill['status_effect_rate']
	local skill_type = t_skill['type']
	local tar_x = t_data.x
	local tar_y = t_data.y
	local target = t_data.target

	-- 2. 특수 변수
	local attack_count = t_skill['hit']
    local range = t_skill['val_1']
	local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	local isSpread = t_skill['val_2'] -- 사용하는 인자!

    SkillConicAtk_Spread:makeSkillInstnce(owner, missile_res, power_rate, target_type, status_effect_type, status_effect_rate, skill_type, tar_x, tar_y, target, attack_count, range, isSpread)
end
