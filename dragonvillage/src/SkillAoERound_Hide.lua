local PARENT = SkillAoERound

-------------------------------------
-- class SkillAoERound_Hide
-------------------------------------
SkillAoERound_Hide = class(PARENT, {})

-------------------------------------
-- function initState
-------------------------------------
function SkillAoERound_Hide:initState()
    PARENT.initState(self)

    self:addState('start', SkillAoERound_Hide.st_appear, nil, false)
	self:addState('attack', PARENT.st_attack, 'idle', false)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillAoERound_Hide.st_appear(owner, dt)
	-- 캐릭터가 사라지는 연출과 동시에 돌진 준비 좌표로 보냄
	if (owner.m_stateTimer == 0) then
		local res = 'res/effect/tamer_magic_1/tamer_magic_1.vrp'
		local function cb_func() 
			owner:changeState('attack') 
		end

		local char = owner.m_owner
		owner:makeEffect(res, char.pos.x, char.pos.y, 'bomb', cb_func)
		char.m_rootNode:setVisible(false)
	end
end

-------------------------------------
-- function escapeAttack
-- @brief 공격이 종료되는 시점에 실행
-------------------------------------
function SkillAoERound_Hide:escapeAttack()
    local char = self.m_owner

	char.m_rootNode:setVisible(true)

    PARENT.escapeAttack(self)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoERound_Hide:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local attack_count = t_skill['hit']	  -- 공격 횟수
	local aoe_res_delay = tonumber(t_skill['val_1']) or 0
    
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	-- 스킬 본연의 리소스
	local aoe_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)		-- 개별 타겟 이펙트 리소스

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoERound_Hide(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(aoe_res, attack_count, aoe_res_delay)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end