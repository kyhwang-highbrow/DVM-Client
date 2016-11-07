local PARENT = Skill

-------------------------------------
-- class SkillBuff
-------------------------------------
SkillBuff = class(PARENT, {
        m_isAddedBuff = 'bool',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillBuff:init(file_name, body, ...)    
    self:initState()
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillBuff:init_skill()
    PARENT.init_skill(self)
	
	self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)

	self.m_isAddedBuff = false
end

-------------------------------------
-- function initState
-------------------------------------
function SkillBuff:initState()
	self:setCommonState(self)
    self:addState('start', SkillBuff.st_idle, nil, true)
    self:addState('draw', SkillBuff.st_draw, 'idle', true)
	self:addState('obtain', SkillBuff.st_obtain, 'obtain', false)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillBuff.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:changeState('draw')
    end
end

-------------------------------------
-- function st_draw
-------------------------------------
function SkillBuff.st_draw(owner, dt)
	if (owner.m_stateTimer == 0) then
		-- @TODO
		-- 애플칙 하드 코딩
		local t_status_effect_rate = stringSplit(owner.m_statusEffectRate, ';')
		for i, status_effect_rate in ipairs(t_status_effect_rate) do
			-- 확률 검사
			if (math_random(1, 1000) < status_effect_rate * 10) then 
				-- 추가 버프 실행 판단
				if (i == 2) then 
					owner.m_isAddedBuff = true 
					owner.m_animator:changeAni('idle_gold')
				end 
			end
		end

		-- 투사체 투척
        local target_pos = cc.p(owner.m_targetPos.x, owner.m_targetPos.y)
        local action = cc.JumpTo:create(0.5, target_pos, 250, 1)

		-- state chnage 함수 콜
		local cbFunc = cc.CallFunc:create(function() owner:changeState('obtain') end)

		owner:runAction(cc.Sequence:create(cc.EaseIn:create(action, 1), cbFunc))
    end
end

-------------------------------------
-- function st_obtain
-------------------------------------
function SkillBuff.st_obtain(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 애플칙 하드 코딩
		local t_status_effect_rate = stringSplit(owner.m_statusEffectRate, ';')
		local t_status_effect_value = stringSplit(owner.m_statusEffectValue, ';')
		local t_status_effect_type = stringSplit(owner.m_statusEffectType, ';')
		for i, status_effect_type in ipairs(t_status_effect_type) do
			local status_effect_value = t_status_effect_value[i]
			local status_effect_rate = t_status_effect_rate[i]

			if (i == 1) then 
				StatusEffectHelper:doStatusEffect_simple(owner.m_targetChar, status_effect_type, status_effect_value, status_effect_rate)
			else
				if owner.m_isAddedBuff then 
					StatusEffectHelper:doStatusEffect_simple(owner.m_targetChar, status_effect_type, t_status_effect_value, 100)
				end
			end
		end

		owner.m_animator:setPosition(0, 100)
		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
        end)
    end
end

-------------------------------------
-- function getDefaultTargetPos
-- @brief 디폴트 타겟 좌표
-------------------------------------
function SkillBuff:getDefaultTargetPos()
    return PARENT.getDefaultTargetPos(self) 
end

-------------------------------------
-- function findTarget
-- @brief 공격 대상 찾음
-------------------------------------
function SkillBuff:findTarget()
    return PARENT.findTarget(self) 
end

-------------------------------------
-- function makeSkillInstnce
-------------------------------------
function SkillBuff:makeSkillInstnce(missile_res, ...)
	-- 1. 스킬 생성
    local skill = SkillBuff(missile_res)

	-- 2. 초기화 관련 함수
	skill:setParams(...)
    skill:init_skill()
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToUnitList(skill)
end

-------------------------------------
-- function makeSkillInstnceFromSkill
-------------------------------------
function SkillBuff:makeSkillInstnceFromSkill(owner, t_skill, t_data)
    local owner = owner

	-- 1. 공통 변수
	local power_rate = t_skill['power_rate']
	local target_type = t_skill['target_type']
	local pre_delay = t_skill['pre_delay']
	local status_effect_type = t_skill['status_effect_type']
	local status_effect_value = t_skill['status_effect_value']
	local status_effect_rate = t_skill['status_effect_rate']
	local skill_type = t_skill['type']
	local tar_x = t_data.x
	local tar_y = t_data.y
	local target = t_data.target

	-- 2. 특수 변수
    local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	
    SkillBuff:makeSkillInstnce(missile_res, owner, power_rate, target_type, pre_delay, status_effect_type, status_effect_value, status_effect_rate, skill_type, tar_x, tar_y, target)
end