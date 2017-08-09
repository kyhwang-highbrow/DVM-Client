local PARENT = Skill

-------------------------------------
-- class SkillBind
-------------------------------------
SkillBind = class(PARENT, {
		m_statusDuration = 'num',
		m_statusName = 'str', 
        m_scale = 'number',
	})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillBind:init(file_name, body, ...)
    self.m_scale = 1
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillBind:init_skill()
	PARENT.init_skill(self)

	local struct_status_effect = self.m_lStatusEffect[1]
	self.m_statusDuration = struct_status_effect.m_duration
	self.m_statusName = struct_status_effect.m_type

	self:setPosition(self.m_targetChar.pos.x, self.m_targetChar.pos.y)

    local scale, type = self.m_targetChar:getSizeType()
    self.m_scale = self:calcScale(type, scale)
    print(self.m_scale)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillBind:initState()
	self:setCommonState(self)
    self:addState('start', SkillBind.st_appear, 'appear', false)
	self:addState('idle', SkillBind.st_idle, 'idle', true)
	self:addState('end', SkillBind.st_disappear, 'disappear', false)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillBind.st_appear(owner, dt)
	if (owner.m_stateTimer == 0) then
        owner.m_animator:setScale(owner.m_scale)
		owner.m_animator:addAniHandler(function()
			owner:changeState('idle')
			-- 상태효과
			owner:dispatch(CON_SKILL_HIT, {l_target = {owner.m_targetChar}})
		end)
	end
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillBind.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then
	elseif (owner.m_stateTimer > owner.m_statusDuration) then
		owner:changeState('end')

	else
		-- 해당 상태효과가 제거되었는지 체크
		local isExist = false
		for _, v  in pairs(owner.m_targetChar:getStatusEffectList()) do
			if (owner.m_statusName == v:getTypeName()) then 
				isExist = true
			end 
		end

		if (not isExist) then
			owner:changeState('end')
		end
	end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillBind.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function update
-------------------------------------
function SkillBind:update(dt)
	if (self.m_state ~= 'dying') then
		-- 타겟 사망 체크
		if (self.m_targetChar:isDead()) then
			self:changeState('dying')
		end
	end

	-- 드래곤의 애니와 객체, 스킬 위치 동기화
	self.m_targetChar:syncAniAndPhys()
	self:setPosition(self.m_targetChar.pos.x, self.m_targetChar.pos.y)

    return PARENT.update(self, dt)
end

-------------------------------------
-- function calcScale
-------------------------------------
function SkillBind:calcScale(type, scale)
    print(type, scale)
    if (type == 'monster') then
        if (scale == 'm') then
            return 1.5 --@TODO
        elseif (scale == 'l') then
            return 2 -- @TODO
        elseif (scale == 'xl') then
            return 2.5 -- @TODO
        else
            return 1  -- @TODO
        end
    else
        return scale  -- @TODO
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillBind:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	  -- 광역 스킬 리소스

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillBind(missile_res)

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
end