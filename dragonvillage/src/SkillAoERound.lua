local PARENT = class(Skill, ISkillMultiAttack:getCloneTable())

-------------------------------------
-- class SkillAoERound
-------------------------------------
SkillAoERound = class(PARENT, {
		m_aoeRes = 'str', 
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoERound:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoERound:init_skill(aoe_res, attack_count)
    PARENT.init_skill(self)

	-- 멤버 변수
    self.m_maxAttackCount = attack_count 
	self.m_aoeRes = aoe_res
	--self.m_hitInterval -> attack state에서 지정
	
	self:setPosition(self.m_targetPos.x, self.m_targetPos.y)

	self:makeRangeEffect(RES_RANGE, self.m_range)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillAoERound:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_range = t_data['size']
	end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoERound:initState()
	self:setCommonState(self)
    self:addState('start', SkillAoERound.st_appear, 'appear', false)
    self:addState('attack', SkillAoERound.st_attack, 'idle', true)
	self:addState('disappear', SkillAoERound.st_disappear, 'disappear', false)
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillAoERound:runAttack()
    local l_target = self:findTarget()
	
    for i, target_char in ipairs(l_target) do
        -- 공격
        self:attack(target_char)
		-- 타겟별 리소스
		self:makeEffect(self.m_aoeRes, target_char.pos.x, target_char.pos.y)
    end

	-- 특수한 부가 효과 구현
	self:doSpecialEffect(l_target)

	self:doCommonAttackEffect(l_target)
end

-------------------------------------
-- function setAttackInterval
-- @brief 스킬에 따라 오버라이딩 해서 사용
-------------------------------------
function SkillAoERound:setAttackInterval()
	-- 이펙트 재생 단위 시간
	self.m_hitInterval = self.m_animator:getDuration()
end

-------------------------------------
-- function enterAttack
-------------------------------------
function SkillAoERound:enterAttack()
	-- 이펙트 재생 단위 시간
	self:setAttackInterval()
	-- 첫프레임부터 공격하기 위해서 인터벌 타임으로 설정
	self.m_multiAtkTimer = self.m_hitInterval
	-- 공격 카운트 초기화
	self.m_attackCount = 0
end

-------------------------------------
-- function escapeAttack
-- @brief 공격이 종료되는 시점에 실행
-------------------------------------
function SkillAoERound:escapeAttack()
	self.m_animator:addAniHandler(function()
		self:changeState('disappear')
	end)
end

-------------------------------------
-- function doSpecialEffect (onHit)
-------------------------------------
function SkillAoERound:doSpecialEffect()
end

-------------------------------------
-- function getPoisonAddDamage
-- @TODO 중독 추가 데미지 임시 구현!!!
-------------------------------------
function SkillAoERound:getPoisonAddDamage(target_char)
	local add_value = 0

	if (self.m_addDamage) then 
		if string.find(self.m_addDamage, ';') then	
			local l_str = stringSplit(self.m_addDamage, ';')
			local add_type = l_str[1]
			add_Value = l_str[2]
			for type, status_effect in pairs(target_char:getStatusEffectList()) do
				if (status_effect.m_statusEffectName == add_type) then 
					add_value = l_str[2]
					break
				end
			end
		end
	end

	return add_value
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoERound:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local attack_count = t_skill['hit']	  -- 공격 횟수
	
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	-- 스킬 본연의 리소스
	local aoe_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)		-- 개별 타겟 이펙트 리소스

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoERound(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(aoe_res, attack_count)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
