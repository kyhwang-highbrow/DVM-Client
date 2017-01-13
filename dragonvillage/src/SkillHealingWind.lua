local PARENT = SkillAoESquare

-------------------------------------
-- class SkillHealingWind
-------------------------------------
SkillHealingWind = class(PARENT, {
		m_healRate = 'number',
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
function SkillHealingWind:init_skill(skill_width, skill_height, hit, heal_rate)
    PARENT.init_skill(self, skill_width, skill_height, hit)
	
	-- 멤버 변수
	self.m_healRate = heal_rate

	-- 위치 설정
	self:setPosition(self.m_targetPos.x, 0) -- Y좌표값은 화면의 중심으로 세팅
end

-------------------------------------
-- function escapeAttack
-------------------------------------
function SkillHealingWind:escapeAttack()
    PARENT.escapeAttack(self)

	-- 상태효과
	local t_target = self:findTarget(self.pos.x, self.pos.y)
	StatusEffectHelper:doStatusEffectByStr(self.m_owner, t_target, self.m_lStatusEffectStr)
end

-------------------------------------
-- function attack
-------------------------------------
function SkillHealingWind:attack(target_char)
	if (not target_char) then return end

    if (self.m_owner.m_bLeftFormation == target_char.m_bLeftFormation) then
        -- 아군 회복
        local heal_rate = (self.m_healRate / 100)
        local atk_dmg = self.m_activityCarrier:getStat('atk')
        local heal = HealCalc_M(atk_dmg) * heal_rate
        target_char:healAbs(heal)

        -- 회복 이펙트
        local effect = self.m_world:addInstantEffect('res/effect/effect_heal/effect_heal.vrp', 'idle', target_char.pos.x, target_char.pos.y)
        effect:setScale(1.5)
    else
        PARENT.attack(self, target_char)
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillHealingWind:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	
	local skill_width = t_skill['val_1']		-- 공격 반경 가로
	local skill_height = t_skill['val_2']		-- 공격 반경 세로
	
	local heal_rate = t_skill['val_3']			-- 힐량 (공격력 대비)
    local hit = t_skill['hit'] -- 공격 횟수

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillHealingWind(missile_res)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill(skill_width, skill_height, hit, heal_rate)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
