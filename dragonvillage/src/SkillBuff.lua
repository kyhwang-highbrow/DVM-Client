local PARENT = Skill

-------------------------------------
-- class SkillBuff
-------------------------------------
SkillBuff = class(PARENT, {
        m_isAddedBuff = 'bool',
		m_addBuffProb = 'num',
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
function SkillBuff:init_skill(add_buff_prob)
    PARENT.init_skill(self)
	
	self.m_addBuffProb = add_buff_prob

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
		local rate = owner.m_addBuffProb
		if (math_random(1, 1000) < rate * 10) then 
			-- 추가 버프 실행 판단
			owner.m_isAddedBuff = true 
			owner.m_animator:changeAni('idle_gold')
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
		if (not owner.m_isAddedBuff) then 
			owner.m_lStatusEffectStr[2] = nil
		end
		StatusEffectHelper:doStatusEffectByStr(owner.m_owner, {owner.m_targetChar}, owner.m_lStatusEffectStr)

		owner.m_animator:setPosition(0, 100)
		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
        end)
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillBuff:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	local add_buff_prob = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillBuff(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(add_buff_prob)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end