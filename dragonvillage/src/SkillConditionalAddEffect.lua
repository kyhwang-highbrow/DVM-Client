local PARENT = Skill

-------------------------------------
-- class SkillConditionalAddEffect
-------------------------------------
SkillConditionalAddEffect = class(PARENT, {
		m_missileRes = 'str',
		m_addRes = 'str',
		m_conditionType = 'str',
		m_addEffectType = 'str',
		m_addValue = 'num',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillConditionalAddEffect:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillConditionalAddEffect:init_skill(missile_res, add_res, condition_type, add_effect_type, add_value)
    PARENT.init_skill(self)

	-- 멤버 변수
	self.m_missileRes = missile_res
	self.m_addRes = add_res
	self.m_conditionType = condition_type
	self.m_addEffectType = add_effect_type
	self.m_addValue = add_value
end

-------------------------------------
-- function initState
-------------------------------------
function SkillConditionalAddEffect:initState()
	self:setCommonState(self)
    self:addState('start', SkillConditionalAddEffect.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillConditionalAddEffect.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then
		if (owner:checkCondition()) then
			owner:doAddEffect()
		end
        owner:fireMissile()
	else
		owner:changeState('dying')
	end
end

-------------------------------------
-- function checkCondition
-- @brief 추가 효과를 실행할 조건을 체크한다.
-------------------------------------
function SkillConditionalAddEffect:checkCondition()
	local is_satisfy = false

	if (self.m_conditionType == 'release_debuff_ally') then
		-- 아군 디버프를 해제 하는지 체크
		local l_fellow = table.sortRandom(self.m_owner:getFellowList())
		for i, fellow in pairs(l_fellow) do
			-- 해제 해야 탈출
			if (StatusEffectHelper:releaseStatusEffectDebuff(fellow, 1)) then
				is_satisfy = true
				self:makeEffect(self.m_addRes, fellow.pos.x, fellow.pos.y, 'center_start')
				break
			end
		end
	else

	end

	return is_satisfy
end

-------------------------------------
-- function doAddEffect
-- @brief 추가 효과를 실행한다.
-------------------------------------
function SkillConditionalAddEffect:doAddEffect()
	if (self.m_addEffectType == 'add_dmg') then
		local adj_power_rate = self.m_powerRate + self.m_addValue
		self.m_activityCarrier:setPowerRate(adj_power_rate)

	else

	end
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillConditionalAddEffect:fireMissile()
    local char = self.m_owner
    local target = self.m_targetChar
	local attack_pos_x, attack_pos_y = self:getAttackPosition()

    local t_option = {}

    t_option['owner'] = char
    t_option['pos_x'] = char.pos.x + attack_pos_x
    t_option['pos_y'] = char.pos.y + attack_pos_y
	t_option['target'] = table.getRandom(char:getOpponentList())

	t_option['dir'] = getDegree(t_option['pos_x'], t_option['pos_y'], target.pos.x, target.pos.y)
	t_option['rotation'] = t_option['dir']

    t_option['physics_body'] = {0, 0, 30}
    t_option['attack_damage'] = self.m_activityCarrier
    t_option['object_key'] = char:getAttackPhysGroup()
	t_option['attr_name'] = self.m_owner:getAttribute()

	t_option['speed'] = 10
	t_option['h_limit_speed'] = 1500
	t_option['accel'] = 5000
	t_option['accel_delay'] = 0.8
	t_option['movement'] ='guide'
	t_option['missile_type'] = 'NORMAL'
	t_option['bFixedAttack'] = true
	t_option['size_up_time'] = 0.5

    t_option['missile_res_name'] = self.m_missileRes
	t_option['scale'] = self.m_resScale

    self:makeMissile(t_option)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillConditionalAddEffect:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local add_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)

    local condition_type = t_skill['val_1']		-- 조건 체크 타입
	local add_effect_type = t_skill['val_2']	-- 추가 효과 타입
	local add_value = t_skill['val_3']			-- 추가로 사용할 값

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillConditionalAddEffect(nil)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill(missile_res, add_res, condition_type, add_effect_type, add_value)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
