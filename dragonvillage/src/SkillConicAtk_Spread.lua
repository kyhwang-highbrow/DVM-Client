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
	self.m_isSpread = isSpread == 1
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillConicAtk_Spread:runAttack()
    local t_target = self:findTarget(self.m_owner.pos.x, self.m_owner.pos.y, self.m_range, self.m_degree)

    for i, target_char in ipairs(t_target) do
        -- 공격
        self:attack(target_char)
		
		if (self.m_isSpread) then 
			-- @TODO 허리케인 하드코딩... 화상 번짐
			if (self.m_speardCnt == 0) then
				self:spreadStatusEffect(target_char, 'burn', 225)
			end
		end
    end
	self.m_speardCnt = 1

	-- 스킬이 제거할 수 있는 미사일 제거
	self:removeDestructibleMissile()

	-- 상태효과
	StatusEffectHelper:doStatusEffectByStr(self.m_owner, t_target, self.m_lStatusEffectStr)
end

-------------------------------------
-- function spreadStatusEffect
-- @brief 특정 상태이상을 전이... 시킨다
-- @TODO 향후에 상태이상 전이가 늘어난다면... 정형화시킬 필요는 있으나 현재는 하드코딩
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
				
			-- 4. 같은 상태효과를 적용 시킨다.
			local l_status_effect_str = {'burn;target;30;100;100'}
			StatusEffectHelper:doStatusEffectByStr(self.m_owner, l_target, l_status_effect_str)
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
-- function makeSkillInstance
-------------------------------------
function SkillConicAtk_Spread:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local attack_count = t_skill['hit']
    local range = t_skill['val_1']
	local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	local is_spread = t_skill['val_2'] -- 사용하는 인자!

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillConicAtk_Spread(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count, range, is_spread)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end