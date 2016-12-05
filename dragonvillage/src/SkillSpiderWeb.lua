local PARENT = Skill

-------------------------------------
-- class SkillSpiderWeb
-------------------------------------
SkillSpiderWeb = class(PARENT, {
		-- t_skill에서 얻어오는 데이터
		m_healRate = '',
	})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillSpiderWeb:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillSpiderWeb:init_skill()
	PARENT.init_skill(self)
	self:setPosition(self.m_targetChar.pos.x, self.m_targetChar.pos.y)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillSpiderWeb:initState()
	self:setCommonState(self)
    self:addState('start', SkillSpiderWeb.st_appear, 'appear', true)
	self:addState('idle', SkillSpiderWeb.st_idle, 'idle', true)
	self:addState('end', SkillSpiderWeb.st_disappear, 'disappear', true)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillSpiderWeb.st_appear(owner, dt)
	if (owner.m_stateTimer == 0) then
		StatusEffectHelper:doStatusEffectByStr(owner.m_owner, {owner.m_targetChar}, owner.m_lStatusEffectStr)
		owner.m_animator:addAniHandler(function()
			owner.m_targetChar.m_animator:setVisible(false)
			owner:changeState('idle')
		end)
	end
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillSpiderWeb.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then
	elseif (owner.m_stateTimer > 10) then
		--@TODO.mskim 하드코딩 숫자
		owner:changeState('end')
	end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillSpiderWeb.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner.m_targetChar.m_animator:setVisible(true)
		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillSpiderWeb:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())	  -- 광역 스킬 리소스
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillSpiderWeb(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill()
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end