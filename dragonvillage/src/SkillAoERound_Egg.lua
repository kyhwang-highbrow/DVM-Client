local PARENT = SkillAoERound

-------------------------------------
-- class SkillAoERound_Egg
-------------------------------------
SkillAoERound_Egg = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoERound_Egg:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoERound_Egg:init_skill(attack_count, range, aoe_res, add_damage)
    PARENT.init_skill(self, attack_count, range, aoe_res, add_damage)
	
	self.m_findTargetType = 'ally'
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillAoERound_Egg:runAttack()
    local t_target = self:findTarget()
	self.m_lTarget = t_target

    for i, target_char in ipairs(t_target) do
		-- 타겟별 리소스
		self:makeEffect(target_char.pos.x, target_char.pos.y)
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoERound_Egg:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local attack_count = t_skill['hit']	  -- 공격 횟수
    local range = t_skill['val_1']		  -- 공격 반경
	local add_damage = t_skill['val_2'] -- 추가데미지 필드
	
	local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())	-- 스킬 본연의 리소스
	local aoe_res = string.gsub(t_skill['res_2'], '@', owner:getAttribute())		-- 개별 타겟 이펙트 리소스
	if (missile_res == 'x') then 
		missile_res = nil
	end

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoERound_Egg(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count, range, aoe_res, add_damage)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
