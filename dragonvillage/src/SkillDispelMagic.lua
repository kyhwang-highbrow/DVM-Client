local PARENT = Entity

-------------------------------------
-- class SkillDispelMagic
-------------------------------------
SkillDispelMagic = class(PARENT, {
        m_owner = 'Character',

        -- t_skill에서 얻어오는 데이터
        m_resName = 'string',            
		m_healRate = '',

		m_target = 'character',
		m_effect = 'animation',

		m_tSkill = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillDispelMagic:init(file_name, body, ...)
    self:initState()
end


-------------------------------------
-- function init_skill
-------------------------------------
function SkillDispelMagic:init_skill(owner, t_skill, t_data)
    -- 스킬 시전자
    self.m_owner = owner

	self.m_resName = t_skill['res_1']
	self.m_healRate = t_skill['power_rate']/100
	self.m_tSkill = t_skill

    local target = self:findTarget(t_data)
	self.m_target = target

	self:changeState('idle')
end

-------------------------------------
-- function initState
-------------------------------------
function SkillDispelMagic:initState()
    self:addState('idle', SkillDispelMagic.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function update
-------------------------------------
function SkillDispelMagic:update(dt)
    -- 사망 체크
	if (self.m_owner.m_bDead) and (self.m_state ~= 'dying') then
        self:changeState('dying')
    end
	-- 드래곤과 스킬 위치 동기화
	if (self.m_state ~= 'dying') then 
		self:setPosition(self.m_target.pos.x, self.m_target.pos.y)
	end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillDispelMagic.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 힐
        owner.m_target:healPercent(owner.m_healRate)
		-- 상태이상 헤제
		StatusEffectHelper:releaseHarmfulStatusEffect(owner.m_target)
		-- 추가 버프 
		StatusEffectHelper:doStatusEffect(owner.m_target, owner.m_tSkill)
	elseif (owner.m_stateTimer > owner.m_animator:getDuration()) then 
		owner:changeState('dying')
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillDispelMagic:findTarget(t_data)
    local target = nil 
	if t_data then
        target = t_data['target']
    end

    -- 지정된 타겟이 없을 경우 랜덤으로 사용
    if (not target) then
        local formation_mgr = self.m_owner:getFormationMgr()
        target = formation_mgr:getRandomHealTarget()
    end

	-- 그래도 없다면 자기 자신
	if (not target) then 
		target = self.m_owner
	end

    return target
end
