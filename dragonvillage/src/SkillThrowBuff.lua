local PARENT = Skill

-------------------------------------
-- class SkillThrowBuff
-------------------------------------
SkillThrowBuff = class(PARENT, {
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillThrowBuff:init(file_name, body, ...)    
    self:initState()
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillThrowBuff:init_skill()
    PARENT.init_skill(self)
	
	self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillThrowBuff:initState()
	self:setCommonState(self)
    self:addState('start', SkillThrowBuff.st_idle, nil, true)
    self:addState('draw', SkillThrowBuff.st_draw, 'idle', true)
	self:addState('obtain', SkillThrowBuff.st_obtain, 'obtain', false)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillThrowBuff.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:changeState('draw')
    end
end

-------------------------------------
-- function st_draw
-------------------------------------
function SkillThrowBuff.st_draw(owner, dt)
	if (owner.m_stateTimer == 0) then
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
function SkillThrowBuff.st_obtain(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:doStatusEffect({
            STATUS_EFFECT_CON__SKILL_HIT,
            STATUS_EFFECT_CON__SKILL_HIT_CRI
        }, {owner.m_targetChar})

		owner.m_animator:setPosition(0, 100)
		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
        end)

        if (owner.m_bHighlight) then
            --owner.m_world.m_gameHighlight:addChar(owner.m_targetChar)
        end
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillThrowBuff:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillThrowBuff(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill()
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

    -- 5. 하이라이트
    if (skill.m_bHighlight) then
        --world.m_gameHighlight:addMissile(skill)
    end
end