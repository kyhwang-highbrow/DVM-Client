local PARENT = Skill

-------------------------------------
-- class SkillHealingWind
-------------------------------------
SkillHealingWind = class(PARENT, {
        m_skillWidth = 'number',
		m_dmgRate = 'number',
        m_hitCount = 'number',
        m_hitInterval = 'number',

		m_lTarget = 'Character', -- @TODO status effect 담으려고 사용 임시
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillHealingWind:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillHealingWind:init_skill(hit, dmg_rate, skill_width)
    PARENT.init_skill(self)

	-- 멤버 변수
    self.m_skillWidth = skill_width
	self.m_dmgRate = dmg_rate
    self.m_hitCount = hit
    self.m_hitInterval = 0

	self:setPosition(self.m_targetPos.x, 0)

	-- predelay 연출 위해서 .. 
	self.m_animator:setVisible(false)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillHealingWind:initState()
	self:setCommonState(self)
    self:addState('start', SkillHealingWind.st_attack, 'tornado', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillHealingWind.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner.m_animator:setVisible(true)
        owner:addAniHandler(function()
			-- 상태효과
			StatusEffectHelper:doStatusEffectByStr(owner.m_owner, owner.m_lTarget, owner.m_lStatusEffectStr)
            owner:changeState('dying')
        end)
    end

    if (0 < owner.m_hitCount) then
		if (owner.m_hitInterval == 0) then 
			owner.m_hitInterval = (owner.m_hitInterval + 0.2)
            owner:runAttack()
            owner.m_hitCount = (owner.m_hitCount - 1)
		elseif (owner.m_stateTimer - owner.m_hitInterval > 0) then
			owner.m_hitInterval = (owner.m_hitInterval + 0.2)
            owner:runAttack()
            owner.m_hitCount = (owner.m_hitCount - 1)
		end
    end
end

-------------------------------------
-- function attack
-------------------------------------
function SkillHealingWind:runAttack()
    local t_target = self:findTarget(self.pos.x, self.pos.y)

    for i, target_char in ipairs(t_target) do
		self:attack(target_char)	
    end

	self.m_lTarget = t_target
end

-------------------------------------
-- function attack
-------------------------------------
function SkillHealingWind:attack(target_char)
	if (not target_char) then return end

    if (self.m_owner.m_bLeftFormation == target_char.m_bLeftFormation) then
        -- 아군 회복
        local heal_rate = (self.m_powerRate / 100)
        local atk_dmg = self.m_activityCarrier:getStat('atk')
        local heal = HealCalc_M(atk_dmg) * heal_rate
        target_char:healAbs(heal)

        -- 회복 이펙트
        local effect = self.m_world:addInstantEffect('res/effect/effect_heal/effect_heal.vrp', 'idle', target_char.pos.x, target_char.pos.y)
        effect:setScale(1.5)
    else
        -- 적군 공격
        self.m_activityCarrier.m_skillCoefficient = (self.m_dmgRate / 100)
        self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
        target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)

		-- 연출
		self.m_skillHitEffctDirector:doWork()
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillHealingWind:findTarget(x, y)
    local world = self.m_world

    local l_target = world:getTargetList(nil, x, y, 'all', 'x', 'distance_x')
    
    local l_ret = {}

    local half_skill_width = (self.m_skillWidth / 2)

    for i,v in ipairs(l_target) do
        local distance = math_abs(v.pos.x - x)
        if (distance <= half_skill_width) then
            table.insert(l_ret, v)
        else
            break
        end
    end

    return l_ret
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillHealingWind:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
    local hit = t_skill['hit'] -- 공격 횟수
	local dmg_rate = t_skill['val_1']			-- power rate 는 힐, dmg rate 는 공격
	local skill_width = t_skill['val_2']		  -- 공격 반경
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillHealingWind(missile_res)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(hit, dmg_rate, skill_width)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
